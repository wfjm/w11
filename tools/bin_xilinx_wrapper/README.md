This directory contains wrappers for general system tools called from within
Xilinx IDE (ISE or Vivado). The wrappers reset the environment used inside the
IDE to a very basic default environment with

    unset LD_LIBRARY_PATH
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

and finally execute the chosen tool via `exec` like

    exec firefox "$@"

This ensures that these tools work properly and don't fail due to conflicting
library versions.
