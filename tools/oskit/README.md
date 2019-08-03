This directory tree contains **OS disk/tape image kits** and is organized in

| Directory | Content |
| --------- | ------- |
| [doc](doc)   | auxiliary documentation |
| [hook](hook) | `ti_w11` startup hook files |
| [test](test) | `ostest` configuration files |
| _all other_  | folders with individual OS kits |

The available OS kits are summarized in the table below with
- **DL**: number of DL11 lines supported by OS (for bsd also with active ttys)
- **DZ**: number of DZ11 lines supported by OS (for bsd also with active ttys)
- **PC**: PC11 (paper tape reader/puncher) support
- **XU**: DEUNA support
- **MinMem**: minimal required memory size

| Directory | DL  | DZ  | PC  | XU  | MinMem | Content |
| --------- | --: | --: | --: | --: | -----: | :------ |
| [211bsd_rk](211bsd_rk)         | 2/2 | 2/8 | n | n | 1024k | 2.11BSD system on RK05 volumes |
| [211bsd_rl](211bsd_rl)         | 2/2 | 2/8 | n | n | 1024k | 2.11BSD system on RL02 volumes |
| [211bsd_rp](211bsd_rp)         | 2/2 | 4/8 | n | n | 1024k | 2.11BSD system on RP06 volume |
| [211bsd_rpeth](211bsd_rpeth)   | 2/2 | 4/8 | n | y | 1024k | 2.11BSD system on RP06 volume with Ethernet |
| [211bsd_rpmin](211bsd_rpmin)   | 1/2 | 1/8 | n | n | 512k | 2.11BSD system on RP06 volume - minimal memory system |
| [211bsd_tm](211bsd_tm)         | 1/2 | 0/8 | n | n | 1024k | 2.11BSD system on a TM11 tape distribution kit |
| [rsx11m-31_rk](rsx11m-31_rk)   |   2 |   8 | y | n | 176k | RSX-11M V3.1 system on RK05 volumes |
| [rsx11m-40_rk](rsx11m-40_rk)   |   2 |   8 | y | n | 176k | RSX-11M V4.0 system on RK05 volumes |
| [rsx11mp-30_rp](rsx11mp-30_rp) |   2 |   8 | y | n | 672k | RSX-11Mplus V3.0 system on RP06 volume |
| [rt11-40_rk](rt11-40_rk)       |   1 |   - | y | n | 64k | RT-11 V4.0 system on RK05 volumes |
| [rt11-53_rl](rt11-53_rl)       |   1 |   - | y | n | 64k | RT-11 V5.3 system on a RL02 volume |
| [u5ed_rk](u5ed_rk)             |   1 |   - | n | n | 672k | Unix 5th Edition system on RK05 volumes |
| [u7ed_rp](u7ed_rp)             |   1 |   - | n | n | 672k | Unix 7th Edition system on RP04 volume |
| [xxdp_rl](xxdp_rl)             |   1 |   - | y | n | 64k | XXDP V2.2 and V2.5 system on RL02 volumes |
