## Known differences between w11a and KB11-C (11/70)

### MMU aborts have priority over NXM aborts

Let's assume a case where two address errors are present:
- the MMU rejects the access
- the MMU translated physical address is located in non-existent memory

Both checks run in parallel in hardware. The MMU logic uses the access control
field and the page length field to check whether access is allowed.
And the physical address is formed from the selected PAR and the resulting
virtual address and compared with the memory size register.

In the KB11-C processor, the NXM condition is handled before the MMU condition.
This leads to the surprising situation that the access is aborted with a
vector 4 flow rather than a vector 250 flow.

The w11 logic inspects the MMU condition first and then the NXM condition.
So a case like the one described above is terminated with a vector 250 flow.

The `ekbee1` diagnostic tests this behavior in test 122. In fact, the code
distinguishes between the KB11-B/C processor and the KB11-E processor
that never made it to market.
In the case of KB11-C, NXM takes precedence over MMU, and and in the case of
KB11-E, MMU takes precedence over NXM.

In case of an MMU plus NXM double error, the w11 therefore behaves like
a KB11-E and not like a KB11-C.
