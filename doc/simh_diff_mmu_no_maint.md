## Known differences between SimH, 11/70, and w11a

### SimH: MMU maintenance mode not implemented

The 11/70 has an MMU maintenance mode, actived with `MMR0` bit 8.
When activated, only destination mode references will be relocated.

The SimH does not implement this feature.

The xxdp program `ekbee1` uses this feature in test 046.
This test is modified when executed on w11
(see [patch](../tools/xxdp/ekbee1_patch_1170.scmd)).
