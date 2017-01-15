# Changelog: w11a_V0.74 -> HEAD

### Table of contents
- Current [HEAD](#user-content-head)
- Release [w11a_V0.742](#user-content-w11a_V0.742)
- Release [w11a_V0.741](#user-content-w11a_V0.741)
- [CHANGELOG for w11a_V.70 to w11a_V0.74](CHANGELOG-w11a_V0.70-w11a_V0.74.md)
- [CHANGELOG for w11a_V.60 to w11a_V0.70](CHANGELOG-w11a_V0.60-w11a_V0.70.md)
- [CHANGELOG for w11a_V.50 to w11a_V0.60](CHANGELOG-w11a_V0.50-w11a_V0.60.md)

<!-- --------------------------------------------------------------------- -->
---
## HEAD <a name="head"></a>
### Proviso
_The HEAD version shows the current development. No guarantees that
software or firmware builds or that the documentation is consistent.
The full set of tests is only run for tagged releases._

### Summary
- man pages now [available online](http://www.retro11.de/manp/w11/man/cat1/).
- add `sysmon_rbus` in `sys_tst_sram_n4`
- Auto-dection of Digilent boards with `FT2232HQ` interface for
  [ti_rri](http://www.retro11.de/manp/w11/man/cat1/ti_rri.0.html) and
  [ti_w11](http://www.retro11.de/manp/w11/man/cat1/ti_w11.0.html).

<!-- --------------------------------------------------------------------- -->
---
## 2017-01-07: [w11a_V0.742](https://github.com/wfjm/w11/releases/tag/w11a_V0.742) - rev 841(wfjm) <a name="w11a_V0.742"></a>

### Summary
- fixes for Vivado 2016.4; all designs build under vivado 2016.4
- added **preliminary** support for Nexys4 DDR board (thanks to [Michael Lyle](https://github.com/mlyle) for testing!)
- [w11 shell](../tools/tcl/rw11/shell.tcl) re-organized and expanded,
  now default in [ti_w11](../tools/bin/ti_w11)
- `CPUERR` cleared with cpu reset (see [ECO-029](ECO-029-cpuerr_creset.md))
- `PS` initialized now with `000000` (see [ECO-028](ECO-028-ps_init.md))

<!-- --------------------------------------------------------------------- -->
---
## 2016-12-23: [w11a_V0.741](https://github.com/wfjm/w11/releases/tag/w11a_V0.741) - rev 826(wfjm) <a name="w11a_V0.741"></a>
### Summary
- moved w11 repository from OpenCores to GitHub
  [wfjm/w11](https://github.com/wfjm/w11/)
- moved w11 project pages from OpenCores to GitHub-Pages
  [wfjm.github.io/home/w11](https://wfjm.github.io/home/w11/)
- converted existing documentation from plain text to markdown
- added README.md files in sub-directories
