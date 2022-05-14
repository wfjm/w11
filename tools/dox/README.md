This directory holds the doxygen setup files for VHDL and C++ documentation.

Currently there is not much real documentation included in the source
files. The doxygen generated html output is nevertheless very useful
to browse and navigate through the source code. C++ and Vhdl source are
covered by setup files contained in this directory.

The doxygen generated source code view of the latest release is
directly available from
- [VHDL module list](https://www.retro11.de/doxy/w11/vhd/html/hierarchy.html)
- [sys_w11a_arty source](https://www.retro11.de/doxy/w11/vhd/html/sys__w11a__n3_8vhd_source.html)
- [C++ class list](https://www.retro11.de/doxy/w11/cpp/html/hierarchy.html)

To locally generate the html files use
```
  cd $RETROBASE/tools/dox
  export RETRODOXY <desired root of html documentation>
  ./make_doxy
```
If `RETRODOXY` is not defined `/tmp` is used. To view the top level
of the generated doxygen output use
```
  firefox $RETRODOXY/w11/cpp/html/index.html &
  firefox $RETRODOXY/w11/vhd/html/index.html &
```
Better entry points for code navigation are
```
  firefox $RETRODOXY/w11/vhd/html/hierarchy.html
  firefox $RETRODOXY/w11/vhd/html/sys__w11a__arty_8vhd_source.html
  firefox $RETRODOXY/w11/cpp/html/hierarchy.html
```
