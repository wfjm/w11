## Known differences between w11a and KB11-C (11/70)

### A 'red stack violation' loses PSW, a 0 is pushed onto the stack

The 11/70, together with the 11/45, has the most elaborate stack protection
system of all PDP-11 models. A stack push via kernel stack is aborted when the
stack pointer is in the 'red zone' 16 words below the stack limit.
An emergency stack is set up, `SP` is set to 4, and PSW and PC are stored.

The w11a loses the PSW, a 0 is pushed.

'red stack aborts' are never recovered, all OS treat them as fatal errors.
This difference is therefore considered an acceptable implementation difference.
