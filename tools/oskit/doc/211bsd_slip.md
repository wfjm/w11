## Using SLIP (Serial-line-IP) with 211bsd

### Basic setup
[SLIP](https://en.wikipedia.org/wiki/Serial_Line_Internet_Protocol) provides
a point-to-point IP connection between two nodes via a serial line.
On the w11a side a DL11 line or a DZ11 line is connected with a
`slattach` command to a free `sl` device unit.
On the host side the serial line is attached to a
[pty](https://en.wikipedia.org/wiki/Pseudoterminal) which is in turn
connected with a `slattach` command to the Linux host network stack.
The current setup assumes
- w11 and host located on subnet 192.168.178.*
- w11 system has IP address 192.168.178.150
- host system has IP address 192.168.178.20

### Setup in 211bsd
In the [211bsd_rp](../211bsd_rp/README.md) system the last DZ11 line
`/dev/tty07` is already setup at startup time via the
` /etc/netstart` lines
```
    ifconfig sl0 inet 192.168.178.150 192.168.178.20 -arp -trailers ...
    slattach /dev/tty07 9600
```
The setup can be verified with a `netstat` command
```
  netstat -I
    Name  Mtu   Network     Address            Ipkts Ierrs    Opkts Oerrs  Coll
    sl0   1006  192.168.178 192.168.178.150        0     0        0     0     0
    lo0   1536  localnet    127.0.0.1           4600     0     4600     0     0
```

### Setup in ti_w11
To attach the last DZ11 line `cpu0dza7` to a pty use
```
  cpu0dza7 att pty:
  cpu0dza7 set to7bit 0
  cpu0dza7 get channelid
```
The last command returns the Linux pty device name in the form `/dev/pts/nn`.

### Setup in Linux
To connect the pty to the Linux host network stack use
```
  sudo slattach -d -v -p slip /dev/pts/<unit>
  sudo ifconfig sl0 192.168.178.20 pointopoint 192.168.178.150 up
```
where `<unit>` is the pty unit number return by `cpu0dza7 get channelid`.
The setup can be verified with a `route` command
```
  route
    Kernel IP routing table
    Destination     Gateway         Genmask         Flags Metric Ref  Use Iface
    default         fritz.box       0.0.0.0         UG    0      0      0 br0
    192.168.2.150   *               255.255.255.255 UH    0      0      0 sl0
    192.168.178.0   *               255.255.255.0   U     0      0      0 br0
```

### Usage
The setup is currently very minimalistic, no name resolution, no routing.
Simplest way to use the SLIP connection is to `telnet` from the host system
to the 211bsd system with
```
  telnet 192.168.178.150
```
