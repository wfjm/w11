## divtst: RSX version

Copy all files from this directory and the files `testall.dat` and `veri.dat`
from the parent directorty to the target system. To build the task simply use
```
  @divtstbld
```
and to execute it use
```
    run divtst
    @divtst
```
which is equivalent to
```
    >run divtst
    div>/o=tstall
    div>@tstall.dat
    div>^Z
```
The `DIV` test results are in file `tstall.log`.
