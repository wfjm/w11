# ECO-035:  STKLIM, yellow and tbit trap fixes (2022-12-06)

### Scope
- mostly in w11a since 2008
- affects: all w11a systems

### Symptom summary
The w11 had several deficits in the stack protection, the yellow stack trap,
and T-bit trace trap logic. They caused diagnostic messages in the xxdp
programs `ekbee1` and `eqkce1`.

### Background
The 11/70, and also the 11/45, differ from most other PDP-11 models in the
implementation of the stack protection and trace traps.
The 11/70 does stack protection checks for write accesses in mode 1,2,4, and 6,
while for example the J11 only checks for mode 4 and 5.
The service order for trap and interrupt processing also differs, on the 11/70
interrupts have priority over tbit traps, while on the J11 and most other
models interrupts have lowest priority.
The SimH simulator uses J11 behavior in both cases, even in 11/70 mode.
In some cases, the w11 implementation followed the SimH implementation, and
as a result, some J11 behaviors crept into the w11.

### Issues and Fixes
- do `STKLIM` check for mode 1,2,4,6 in `dstr` flows
  - issue: stack limit checks were only done in the `dstw` flow used for `MOV`
    and `CLR` instructions, but not in the `dstr` flow used for all instructions
    that perform destination read-modify-write, like `ADD` or `BIS`.
  - fix: stack limits checks are now done in both `dstw` and `dstr` flows for
    all instructions that write to memory.
- correct red/yellow zone boundary
  - issues: detection logic for the yellow and red zone was faulty and produced
      yellow islands in the red area. Highly unlikely to detect that in normal
      operation, it was found in a code review.
  - fix: the first 16 words below the stack limit are now detected as yellow
      zone, all below as red zone.  
- correct ysv flow implementation
  - issues: the w11 implementation used a hack to prevent that the vector flow
      caused by a yellow stack trap causes another yellow stack trap and did
      yellow stack traps only if the respective bit in `CPUERR` was zero.
      That caused several xxdp diagnostics for missing traps.
  - fix: the hack is removed and replaced by proper protection logic.
- correct mmu trap handing in `s_idecode`
  - issues: in case of register-register operate instructions, like `INC R0`
      or `ADD R1,R2`, that execute in two cycles, the w11 starts in `s_idecode`
      the fetch of the next instruction. That logic checked for interrupts but
      not for MMU traps. MMU traps were therefore only taken at the first
      instruction that was fetch pipelined.
  - fix: correct prefetch logic, suppress prefetch also in case of pending
      traps.
- correct traps vs interrupt priority
  - issues: the w11 had an incorrect service order, and interrupts had higher
      precedence than mmu, ysv and tbit traps.
  - fix: implemented correct 11/70 style precedence, with tbit trap lowest,
      interrupts above tbit traps, and all other traps above interrupts.
- trace trap logic overhaul
  - issues: the w11 decided at the end of an instruction whether tbit trap
      must be taken and the deferral of tbit trap of the `RTT` instruction
      was implanted by ignoring any break condition. This gives the expected
      behavior in all most all cases but deviates in a few corner cases like
      single stepping code.
  - fix: implement the approach used by 11/70, but also J11, to set a request
      flag at the beginning of instruction processing, in state `s_idecode`,
      and take the tbit trap decision based on that flag at the end of
      instruction execution.
- `RESET` wait time
  - issues: on the w11 the `RESET` instruction caused a one-cycle `breset`
      pulse and continued immediately. The clearing of pending interrupts takes
      2 cycles until it is visible in the CPU trap and interrupt dispatch logic.
      If there was an interrupt pending when a `RESET` was executed it was
      taken due to this delay. This is visible with a carefully constructed
      `SPL` and `RESET` sequence and was not relevant for normal operation.
  - fix: the `RESET` instruction now waits for 7 cycles after the `breset`
      pulse was generated. That is long enough for all implemented devices.

### Hindsight
All deficits had no impact on OS operation and had therefore low priority.
However, the goal of the w11 is to be an as precise as feasible replica of
the 11/70, and it was overdue to fix them.
