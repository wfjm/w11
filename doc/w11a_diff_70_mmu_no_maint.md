## Known differences between w11a and KB11-C (11/70)

### MMU maintenance mode not implemented

The 11/70 has an MMU maintenance mode, actived with `MMR0` bit 8.
When activated, only destination mode references will be relocated.

The w11 does not implement this feature.

The xxdp program `ekbee1` uses this feature in test 046. This test is
modified when executed on w11
(see [patch](../tools/xxdp/ekbee1_patch_w11a.tcl)).
