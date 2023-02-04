# Installation of the SimH pdp11 simulator 

## SimH Classic
The w11 project uses the pdp11 simulator from the
[SimH](https://en.wikipedia.org/wiki/SIMH) project. The project was started
by Bob Supnik under [simh.trailing-edge.com](http://simh.trailing-edge.com),
is still maintained, and offers the 3.X stream of SimH releases.

## GitHub simh/simH
Since about 2014 the project is expanded and continued as GitHub project
[simh/simh](https://github.com/simh/simh) led by Mark Pizzolato.
The new, functionally much enhanced, version is called V4.*. However, this
project decided not to provide releases anymore, just a stream of commits,
more than 4200 as of April 2022.

The maintainer of the [simh/simh](https://github.com/simh/simh) GitHub project,
[Mark Pizzolato](https://github.com/markpizz), decided on May 15th, 2022 with
commit [ce2adce6](https://github.com/simh/simh/commit/ce2adce6) to change the
license of the repository. The bottom line of the change is, that some files
are declared proprietary and this repository is no longer a
[FOSS](https://en.wikipedia.org/wiki/Free_and_open-source_software) project,
see also issue [#1163](https://github.com/simh/simh/issues/1163).
This triggered massive reactions, see issue
[#1161](https://github.com/simh/simh/issues/1161) and discussions on the
SimH mailing list [simh@groups.io](https://groups.io/g/simh), starting with post
[New license?](https://groups.io/g/simh/topic/new_license/91108560).
See especially Bob Supnik's post
[SimH licensing and the state of the project](https://groups.io/g/simh/topic/simh_licensing_and_the_state/91173868).

## GitHub open-simh/simh
The post
[Announcing the Open SIMH project](https://groups.io/g/simh/topic/91528716)
announed on 2022-06-03 a re-launch of SimH as FOSS project.
A new repository [open-simh/simh](https://github.com/open-simh/simh#readme)
has been set up and provides the SimH code-base under an
[MIT-style licence](https://en.wikipedia.org/wiki/MIT_License), see
[LICENSE.txt](https://github.com/open-simh/simh/blob/master/LICENSE.txt).
Releases are being prepared, but not offered as of 2023-02-03.

## Debian packages
Debian and Ubuntu offer `simh` packages, but with the obsolete version V3.8.1,
released in February 2009. The main obstacle to the inclusion of newer
versions is, according to the Debian maintainer, the unclear license situation.

## Installing SimH
The only practical way to obtain an up-to-date SimH PDP-11 simulator is by
installation from sources. The currently best solution is to install the
latest SimH classic release, URL see above.

## SimH startup script provided in the w11 project
The `scmd` scripts provided in the w11 project were originally developed for
SimH Classic 3.8, and worked for SimH Classic 3.9 and later releases.
They should also work for simh/simh and open-simh/simh, but are currently
most tested with Classic.
