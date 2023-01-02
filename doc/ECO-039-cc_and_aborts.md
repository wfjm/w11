# ECO-039: fix cc after abort behavior (2022-12-31)

### Scope
- was in w11a since 2008
- affects: all w11a systems

### Background
The PDP-11 architecture requires that
- for direct writes to the `PSW`, the cc state of the write must prevail
- the cc state must remain unchanged after an instruction abort

The first requirement implies that the usual updating of cc's after an
instruction must be suppressed when the `PSW` is written (e.g. with `MOV`)
or modified (e.g. with `BIS`/`BIC`). The second requirement is a natural
consequence of the needs of a recovery from an MMU abort. When the aborted
instruction is re-executed, it must be done in the original environment,
thus with the original condition code status.

### Symptom summary
The current w11 implementation updates the condition codes in some cases
_before_ the final write, and thus before the last possibility of an
instruction abort. An address error abort on the last write would therefore
leave the CPU in a state with modified condition codes.

This was initially detected in a code review of the `dstw` flow used by
`MOV(B)`, `CLR(B)` and `SXT` instructions. The condition code update was
done in the entry states `s_dstw_def`, `s_dstw_inc`, `s_dstw_dec`, and
`s_dstw_ind`. This ensured that in direct writes to the `PSW` the cc state
of the write prevailed, simply because this was done several cycles later.

A closer examination revealed that the `MFP*` and `MTP*` instructions have a
similar problem, but in different flows.

### Analysis
Simply moving the condition code updates into the `*_w` states that conclude
the last write fixes the abort problem, but will overwrite the condition codes,
which is a violation the first requirement and causes errors in xxdp code
`eqkce1` for tests 036, 043 and 053.

### Fixes
The correct solution is to _move the condition code updates_ into the `*_w`
states that conclude the last write _and to add an overwrite protection_.
Such an overwrite protection has been added to `pdp11_psr` with a very simple
logic: a `CCWE` request is ignored in the cycle following a `PSW` write access.

In a first round, the `dstw` flow was fixed. The condition code requests
`ndpcntl.psr_ccwe := '1';` were removed from the flow entry states `s_dstw_def`,
`s_dstw_inc`, `s_dstw_dec`, and `s_dstw_ind` and add to the two exit states
`s_dstw_def_w` and `s_dstw_inc_w`.

In a second round, the `MTP*` and `MFP*` instructions, which use the `dsta`
flow, were fixed. Again, the `ndpcntl.psr_ccwe := '1';` was moved to the
last `*_w` state of the respective flows.

### Hindsight
Further analysis showed that this bug had in practice no consequences
- `MOV` and `CLR` don't depend on the cc state, so a re-execution with a
  changed initial cc state will give the same result. Indeed, these two
  instructions are often re-executed under 2.11bsd when they trigger a stack
  extension. `MFP*` and `MTP*` also don't depend on the cc state and
  re-execution will give correct results. Moreover, they are  usually used
  in kernel mode and therefore never re-executed in 2.11bsd.  
- `SXT` depends on the `N` bit, but this bit is not changed by this
  instruction, so a re-execution with Z, V, or C changed will give a
  correct result.
