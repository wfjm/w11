## Ethernet setup for 211bsd

### Basic setup
The w11a uses an emulated `DEUNA` interface which interacts via a _tap_
device with the linux host system. The _tap_ device in turn is usually
connected to an internal _bridge_. This way the w11a can exchange packets
with the linux host as well as with any other node.

### Setup of _tap_ and _bridge_
The _tap_ device should be created such that it is accessible by the
account under with _ti_w11_ executes. This way only setting up _tap_
and _bridge_ require root access, but not subsequent usage.

Two support scripts help in the setup
```
    ip_create_br
```

creates a bridge named _br0_ and re-connects the physical ethernet interface.
The script works on a PC with a single physical Ethernet interface.
```
    ip_create_tap [tap-name]
```

add a user-mode _tap_ device to the bridge _br0_. If the bridge doesn't exist
`ip_create_br` is called. If no name is given _tap0_ is used.

### Used MAC addresses
The MAC addresses used by w11a are
```
    52:65:74:72:6f:??
```

which are in the range of locally administered MAC addresses. The first
five bytes mean in ASCII "Retro", easy to pick out in tcpdump -xx traces.

### Setup in ti_w11
Is contained in the boot tcl files, just three lines
```
    cpu0xua  set type deuna
    cpu0xua  set dpa  retro:00
    cpu0xua0 att tap:tap0
```

to select DEUNA emulation, the MAC address, and connect to _tap0_.

### Setup in 211bsd
The current setup is very simple, expects to live in a 192.168.2.* subnet,
and does not use DNS, /etc/resolv.conf is empty, uses only /etc/hosts
```
    127.0.0.1       localhost
    192.168.2.150   w11a
    192.168.2.25    athome
```

The parameters in /etc/netstart are
```
    hostname=w11a
    netmask=255.255.255.0
    broadcast=192.168.2.255
    default=192.168.2.1
```

