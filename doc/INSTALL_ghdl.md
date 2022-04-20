# Installation of GHDL

The w11 project uses the open source VHDL simulator **GHDL**.

It used to be part of most distributions. Unfortunately the Debian maintainer 
for GHDL refused at some point to integrate GHDL into Debian 4 "Etch".
GHDL was part of Debian 5 "Lenny", and again of Debian 6 "Squeeze", and was 
missing again in Debian 7 "Wheezy", Debian 8 "Jessy", and Debian 9 "Stretch".
It was finally re-integrated in Debian 10 "Buster" (with V0.35) and
Debian 11 "Bullseye" (with V1.0.0).

The glitch at Debian unfortunately lead to the removal of GHDL from Ubuntu, 
which is based on Debian. Ubuntu 10.04 "Lucid" up to 11.10 "Oneiric" included 
GHDL,  while 12.04 LTS "Precise", 14.04 LTS "Trusty", 16.04 LTS "Xenial",
and 18.04 "Bionic" didn't. It was finally re-integrated in Ubuntu in
20.04 LTS "Focal" (with V0.37) and 22.04 LTS "Jammy" (with V1.0.0).

However, the recent Debian packages do not include the `VITAL` libraries anymore,
see [issue 1939910](https://bugs.launchpad.net/ubuntu/+source/ghdl/+bug/1939910)
and [comment 899552686](https://github.com/ghdl/ghdl/pull/1841#issuecomment-899552686)
The response was that they were removed due to license issues, see
[comment 899576418](https://github.com/ghdl/ghdl/pull/1841#issuecomment-899576418). The recent Ubuntu packages also do not include the `VITAL` libraries.

The Debian/Ubuntu packages are therefore useless for w11 verification.

The only solution is to install GHDL from sources.
That had been a bit quirky at times, but since V0.37 it works without
any problems.
