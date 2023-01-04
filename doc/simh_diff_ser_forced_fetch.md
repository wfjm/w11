## Known differences between SimH, 11/70, and w11a

### SimH: No unconditional instruction fetch after stack error abort

The 11/70 suppresses the recognition of _break requests_ at the end of
a vector flow of a stack error abort. The processor manual states

> 6.2.2.3 Timing of Stack Error Aborts  
> BRQ STROBE is thus inhibited, not only during ZAP.00, but also during  
> SVC.90, thus guaranteeing the execution of the first instruction of the  
> error subroutine before any other error can be processed.

The rationale behind was apparently to ensure that the handler, which
is called with `SP=0` pointing to an emergency stack, can set up a new
stack before any other condition interferes.

SimH does not implement this behavior, nor does w11.
Beyond that, it would be very difficult to verify this extreme corner case.
