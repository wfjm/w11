## Ethernet setup for 211bsd

### Basic setup
The w11a uses an emulated `DEUNA` interface which interacts via a _tap_
device with the Linux host system. The _tap_ device in turn is usually
connected to an internal _bridge_. This way the w11a can exchange packets
with the Linux host as well as with any other node.

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
five bytes mean in ASCII "Retro", easy to pick out in _tcpdump -xx_ traces.

### Setup in ti_w11
Is contained in the boot tcl files, just three lines
```
    cpu0xua  set type deuna
    cpu0xua  set dpa  retro:00
    cpu0xua0 att tap:tap0
```

to select DEUNA emulation, the MAC address, and connect to _tap0_.

### Setup in 211bsd
The current setup is very simple, expects to live in a 192.168.178.* subnet,
and does not use
[DNS](https://en.wikipedia.org/wiki/Domain_Name_System),
`/etc/resolv.conf` is empty, uses only `/etc/hosts`
```
    127.0.0.1         localhost
    192.168.178.150   w11a
    192.168.178.20    athome
```

The parameters in `/etc/netstart` are
```
    hostname=w11a
    netmask=255.255.255.0
    broadcast=192.168.178.255
    default=192.168.178.1
```

### Usage from 211bsd
Since name resolution is not yet activated and only the backend host
_athome_ is defined in `/etc/hosts` all other nodes must be specified
by IP-Address, which can be inquired via `nslookup`
```
  ping athome
    PING athome (192.168.178.20): 56 data bytes
    64 bytes from 192.168.178.20: icmp_seq=0 ttl=64 time=40 ms
    64 bytes from 192.168.178.20: icmp_seq=1 ttl=64 time=20 ms

  ping 8.8.8.8
    PING 8.8.8.8 (8.8.8.8): 56 data bytes
    64 bytes from 8.8.8.8: icmp_seq=0 ttl=56 time=40 ms
    64 bytes from 8.8.8.8: icmp_seq=1 ttl=56 time=20 ms

  nslookup www.cern.ch 8.8.8.8
    Server:  google-public-dns-a.google.com
    Address:  8.8.8.8

    Non-authoritative answer:
    Name:    webrlb02.cern.ch
    Address:  188.184.9.235
    Aliases:  www.cern.ch
  
  telnet 188.184.9.235 80
    Trying...
    Connected to 188.184.9.235.
    Escape character is '^]'.
    GET / HTTP/1.0

    HTTP/1.1 302 Found
    Content-Type: text/html; charset=utf-8
    Location: http://home.web.cern.ch/
    Server: Microsoft-IIS/8.5
    X-Powered-By: ASP.NET
    Date: Thu, 30 May 2019 10:13:27 GMT
    Connection: close
    Content-Length: 141
    
    <html><head><title>Object moved</title></head><body>
    <h2>Object moved to <a href="http://home.web.cern.ch/">here</a>.</h2>
    </body></html>
    Connection closed by foreign host.
```

### Usage from Linux
Simply use `telnet`:
```
  telnet 192.168.178.150
  Trying 192.168.178.150...
  Connected to 192.168.178.150.
  Escape character is '^]'.


  2.11 BSD UNIX (w11a)

  login: root
  erase, kill ^U, intr ^C
  #
```