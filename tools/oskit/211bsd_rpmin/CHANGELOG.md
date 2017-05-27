# Changelog for 211bsd_rpmin oskit

## 2017-05-26: initial system setup
Derived from the [211bsd_rp](../211bsd_rp/CHANGELOG.md). Just a new kernel with
```
  NBUF       40             # was 160
  MAXUSERS   10             # was  10
  NPTY        8             # was  16
  INET       NO             # was YES, no networking
  NSL         1             # was   1, remove network drivers
```
