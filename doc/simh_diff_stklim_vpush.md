## Known differences between SimH, 11/70, and w11a

### SimH: stack limit check and vector push aborts

In a vector flow, the 11/70 performs an individual stack limit check for the
PS push and the PC push. Therefore, a vector flow can be aborted on the first
or the second push, the red zone is never written.
In case of a stack limit abort during a vector flow, the PS is restored to
the value at the entry of the vector flow, an emergency stack is set up,
and a vector 4 flow is started that will save the PS and PC values present
at the beginning of the aborted vector flow.

SimH implements a substantially different behavior for all PDP-11 models.
A stack limit violation is checked at the end of the vector flow, after the
writes have been performed and one or two values have been potentially written
into the red zone. An emergency stack is set up and a vector 4 flow is started
that will save the PS and PC values taken read in beginning of the aborted
vector flow.
The [tcode](../tools/tcode/README.md)
[cpu_details](../tools/tcode/cpu_details.mac) test A3.5 verifies the 11/70
behaviour and is skipped when executed on SimH.

**Note**: The SimH behavior for vector push aborts caused by an MMU abort is
different. These aborts are detected before the actual write, and the vector
flow handling of the abort saves the PS and PC values present at the beginning
of the initial vector flow. This occurs both for a vector 240 flow when a push
to a non-kernel stack failed, and a vector 4 flow when a push to kernel stack
failed and is converted to a fatal stack error. In these cases, SimH
implements the 11/70 behavior.

The w11 correctly implements the 11/70 behavior in all cases.
