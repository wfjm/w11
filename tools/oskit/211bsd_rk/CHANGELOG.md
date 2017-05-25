# Changelog for 211bsd_rk oskit

## 2017-05-25: major update
- kernel config unchanged
- kernel rebuild (to reflect node name ect)
- disk set re-build from [211bsd_rp](../211bsd_rp) master
  - main change is the group 7 fixup done for 211bsd_rp

## 2009-xx-xx: initial system setup
- use 211bsd_rp system as base
- configure a kernel RETRONFPRK, as non-networking, main differences
  ```
    IDENT         RETRONFPNW     -->  RETRONFPRK
    BOOTDEV       rm             -->  rk
    DUMPDEV       makedev(10,1)  -->  makedev(6,1)
    DUMPROUTINE   xpdump         -->  rkdump
    INET          YES            -->  NO
    NPTY          16             -->  8
  ```
- create a set of 4 disks with a absolute minimal non-networking system
  ```
    /dev/rk0h       /       ufs
    /dev/rk1h       none    swap
    /dev/rk2h       /tmp    ufs
    /dev/rk3h       /bin    ufs
    /dev/rk4h       /usr    ufs
  ```
- provisos
  - /tmp stays on '/'
  - /home is not mounted
  - absolute minimal system, suitable for a 'root' user
