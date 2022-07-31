## divtst: BSD version

Copy all files from this directory and the files `testall.dat` and `veri.dat`
from the parent directorty to the target system. To build the task simply use
```
  make
```
and to execute it use
```
  ./divtst <tstall.dat >tstall.log
  ./divtst <veri.dat >veri.log
```
The `DIV` test results are in file `tstall.log`.
The file `veri.log` checks the error flagging and should give an error for
each line.
