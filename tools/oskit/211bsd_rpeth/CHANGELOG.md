# Changelog for 211bsd_rpeth oskit

## 2017-05-26: initial system setup
Derived from the [211bsd_rp](../211bsd_rp/CHANGELOG.md). A new kernel with
```
  NETHER      1             # was   0, enable ethernet
  NDE         1             # was   0, enable DEUNA
  NSL         1             # was   1, remove slip
```

In /etc/netstart the networking is enabled with
```
hostname=w11a
netmask=255.255.255.0
broadcast=192.168.2.255
default=192.168.2.1
...
ifconfig de0 inet netmask $netmask $hostname broadcast $broadcast
route add default $default 1
```
