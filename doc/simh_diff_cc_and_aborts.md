## Known differences between SimH, 11/70, and w11a

### SimH: condition codes are not always unchanged after an abort

The PDP-11 architecture requires that
- for direct writes to the `PSW`, the cc state of the write must prevail
- the cc state must remain unchanged after an instruction abort

To satisfy the first requirement, SimH updates the condition codes
for `MOV`, `CLR`, `SXT`, `MFP*`, and `MTP*` _before_ the last write is
executed.  This ensures that in direct writes to the `PSW` the cc state
of the write prevails, simply because an explicit `PSW` write is done
_after_ the instruction level condition code update and overwrites it.

However, an address error abort on the last write would leave the CPU in a
state with modified condition codes, which violates of the second requirement.

A detailed analysis shows that this bug has in practice no consequences
- `SXT` depends on the `N` bit, but this bit is not changed by this
  instruction, so a re-execution with Z, V, or C changed will give a
  correct result.
- the other affected instructions don't depend on the cc state, so a
  re-execution with a changed initial cc state will give the same result.

Confirmed deficiency, might be fixed in a future release.

The w11 implements instruction aborts correctly, the condition codes are not
unchanged when an instruction is aborted. The corresponding tests are skipped
when executed on SimH
(see [cpu_details.mac](../tools/tcode/cpu_details.mac) tests B3.1-3).

Tested with SimH V3.12-3.
