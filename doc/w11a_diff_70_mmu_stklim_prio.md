## Known differences between w11a and KB11-C (11/70)

### `MMR0` abort flags are set when stack limit abort done

Let's assume a case where two aborts are present:
- the MMU rejects the access, e.g. because the page is non-resident
- the access is a kernel stack write and violates the stack limit

Both checks run in parallel in hardware. The MMU logic uses the access control
field and the page length field to check whether access is allowed.
And the effective address is compared with the stack limit.

In the KB11-C processor, the `MMR0` abort bits are not set in case of a red
zone stack abort. The case described above leads to a vector 4, as it should
be, and does not set an abort bit in `MMR0`.

The w11 does not implement this suppression, the MMU logic and the stack limit
check logic are independent. The case described above leads to a vector 4,
but also sets an abort bit in `MMR0`.

The xxdp program `ekbee1` checks this behavior in test 122. This test is
modified when executed on w11
(see [patch](../tools/xxdp/ekbee1_patch_w11a.tcl)).
