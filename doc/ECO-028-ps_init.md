# ECO-028:  `PS` init fix (2016-12-26)

### Scope
- Was in w11a from the very beginning
- Affects: all w11a systems

### Symptom summary
The `PS` was at start-up and after CPU reset initialized to `000340`, thus 
`psw.pri = 7`, thus with interrupts disabled. The real 11/70 actually started
with `000000` and `psw.pri = 0`, thus with interrupts enabled.

### Background
The `PS` reset behavior in the w11a was simply copied from the `simh`
simulator in 2007, which at this time initialized the `PS` with `000340`.
Only in 2013 (!) it was realized by Bob Supnik that this was incorrect.
See the full story in the exhaustive commit message for 
[simh commit f0d41f1](https://github.com/simh/simh/commit/f0d41f15d792b9abc31e8530ee275453c7440a8c).

### Fixes
`PS` now initialized with `000000` to stay in line with the real 11/70 and SimH.

### Side effects
Hopefully none. All `ibus` devices come up with interrupts disabled, so there
shouldn't be any spurious interrupts at start-up.

### Hindsights
Even a very plausible behavior like _"disable all interrupts at power on"_ can
be the incorrect one.
