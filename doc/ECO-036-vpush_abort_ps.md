# ECO-036: Get correct PS after vector push abort  (2022-12-11)

### Scope
- was in w11a since 2009
- affects: all w11a systems

### Symptom summary
Test 124 of `ekbee1` fails with
```
  SSRA PS RESTORE(1) DOESN'T GET TO RACK E63
  OR E63(5) BAD
  ERRORPC TEST NUMBER
  077344  000124  
```

### Analysis
The test makes page 6 non-resident, sets `SP` to a location in page 6, and
executes a `TRAP` instruction. The `TRAP` vector flow fails at the 1st stack
push, a fatal error is detected, an emergency stack is set up (`SP` := 4)
and a vector 4 flow is started. On an 11/70, such a restarted vector flow
will push the `PS` and `PC` seen at the entry of the initial aborted vector
flow, and therefore restore the `PS` which was already overwritten by the
value read during the vector fetch phase of the initial vector flow.

The w11 did not perform such a recovery and pushed the `PS` fetched in the
initial vector flow. Correct handling of this case is essential for the `MMR0`
instruction complete functionality, which is not yet available but will be
implemented in a later release.

### Fixes
The 11/70 uses a microcode branch and dedicated states to recover `PS` in the
case of re-entry into the vector flow.

w11 uses a new `cpu_state` flag  `in_vecflow` instead.
The current `PS` is saved in register `DTMP` when a vector flow is started
with `do_start_vec`, and later read from `DTMP` in state `s_vec_pushps` when
the first vector push is started. `do_start_vec` is executed in the states
that start a vector flow with a branch to `s_vec_getpc`.

The new state flag `in_vecflow` is set in the state `s_vec_getpc` and cleared
in `s_vec_pushpc_w` when the last push was successful.
In `do_start_vec`, the `PS` is only written to `DTMP` when `in_vecflow` is not
set. The pushed `PS` in a re-entered vector flow comes therefore from the
first entry.

### Hindsight
This deficit had no impact on OS operation and had therefore low priority.
However, the goal of the w11 is to be an as precise as feasible replica of
the 11/70, and it was overdue to fix this.
