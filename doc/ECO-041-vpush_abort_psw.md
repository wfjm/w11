# ECO-041: Get correct `PSW` after vector push abort  (2023-03-22)

### Scope
- [ECO-036](ECO-036-vpush_abort_ps.md) fixed only part of the problem
- affects: all w11a systems

### Symptom summary
The tcode [cpu_mmu.mac](../tools/tcode/cpu_mmu.mac) failed in test D2.1 when
running on the E11 simulator while it happily executed on w11.

### Analysis
The changes done in [ECO-036](ECO-036-vpush_abort_ps.md) ensured that the
correct `PS` was saved on the stack. But they did not restore the `PSW` of
the CPU. The vector flow has therefore
- loaded the `PSW` with current mode = supervisor in the initial PIRQ
  vector fetch
- was aborted during a vector push
- loaded again the `PSW` in the following MMU vector fetch. Because the `PSW`
  wasn't rolled back, the current mode was still supervisor, which now became
  the previous mode, the only field not taken from the new `PS`.

The previous mode in the `PSW` should, of course, reflect the current mode
active before the first entry in the vector flow. In the test D2.1 this is
kernel mode.

### Fixes
The states `s_vec_pushps_w` and `s_vec_pushpc_w` now restore the `PSW`
when an abort is detected. This also ensures that the correct `PS` is
saved when the vector flow is re-entered. The special handling in
`do_start_vec` that was introduced in [ECO-036](ECO-036-vpush_abort_ps.md)
was removed.

### Hindsight
This bug was first discovered by cross-checking with the E11 simulator. 
cpu_mmu.mac test D2.1 failed under E11 and worked on w11. The reason was that
the test was faulty too and expected that the `PSW` previous mode is already
the mode of the failed stack push. So a bug in the test hid a bug in the CPU.
Great to have a second PDP-11 simulator which provides a very close 11/70
replica. That helps to avoid such double errors in the future.
