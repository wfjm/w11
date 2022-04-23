# Installation of the SimH pdp11 simulator 

The w11 project uses the pdp11 simulator from the
[SimH](https://en.wikipedia.org/wiki/SIMH) project. The project was started
by Bob Supnik under [simh.trailing-edge.com](http://simh.trailing-edge.com).
This site contains the "classic" version of SimH, the 3.X stream, with v3.11-1
as the last release. Since about 2014 the project is continued by a team led by
Mark Pizzolato as GitHub project [simh/simh](https://github.com/simh/simh).
The new, functionally much enhanced, version is called V4.*. However, the
team decided not to provide releases anymore, just a stream of commits,
more than 4200 as of April 2022.

Debian and Ubuntu offer `simh` packages, but with the obsolete version V3.8.1,
released in February 2009. The main obstacle to the inclusion of newer
versions is, according to the Debian maintainer, the unclear license situation.

The only practical way to obtain the pdp11 simulator is by installation from
sources. The GitHub repository contains also the classical versions, nicely
marked with tags.

The `scmd` scripts provided in the w11 project were originally developed for
SimH 3.8, and worked for SimH 3.9 and later releases. The SimH 4.* development
over time became incompatible with the `scmd` scripts used for w11 verification.
See issue [#30](https://github.com/wfjm/w11/issues/30) for details.

The bottom line at the moment:
- install SimH from [simh/simh](https://github.com/simh/simh)
- checkout `v3.11-1`

