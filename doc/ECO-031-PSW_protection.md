# ECO-031:  `PSW` privilege escalation protection overzealous (2022-08-27)

### Scope
- Was in w11a from the very beginning (2007)
- Affects: all w11a systems

### Symptom summary
No Symptoms. Was discovered in a code review.

### Background
The privilege escalation protection for RTT/RTI ensures that a lower
privileged code can't increase the mode. In non-kernel mode, this is done
by or'ing' the new pm,cm,rset values to the existing value. With
```
  kernel 00
  super  01
  user   11
```
this fulfills the objective.

### Analysis
A code review showed a discrepancy between SimH and w11a handling
In SimH this is done in in pdp11_cpu.c in put_PSW()
```
  if (prot) {                                       /* protected? */
      cm = cm | ((val >> PSW_V_CM) & 03);           /* or to cm,pm,rs */
      pm = pm | ((val >> PSW_V_PM) & 03);           /* can't change ipl */
      rs = rs | ((val >> PSW_V_RS) & 01);
      }
  else {
      cm = (val >> PSW_V_CM) & 03;                  /* write cm,pm,rs,ipl */
      pm = (val >> PSW_V_PM) & 03;
      rs = (val >> PSW_V_RS) & 01;
      ipl = (val >> PSW_V_IPL) & 07;
      }
```
In w11a in pdp11_psr.vhd the handling was
```
      R_PSW.cmode <= R_PSW.cmode or DIN(psw_ibf_cmode);
      R_PSW.pmode <= R_PSW.pmode or DIN(psw_ibf_pmode) or
                     R_PSW.cmode or DIN(psw_ibf_cmode);
      R_PSW.rset  <= R_PSW.rset or DIN(psw_ibf_rset);
```
Unclear why for `pmode` the `cmode` bits where or'ed in too.
Further analysis
- a scan through documentation did not find a hint
- EK-KB11C-TM-001_1170procMan.pdf page 132 states
  _prev mode protected like curr mode_
- MP0KB11-C0_1170engDrw_Nov75.pdf
  - PSW logic in drawing PDRD on page 59.
  - pm has the logic to set it from cm in vector pushes
  - but in the RTT/RTI update case, pm is handled like cm and reset

### Fixes
Simply remove the extra term, now
```
      R_PSW.pmode <= R_PSW.pmode or DIN(psw_ibf_pmode);
```

### Hindsight
Unclear why it was implemented with this extra term. It is the responsibility
of the software to ensure previous mode is not more privileged than the
current mode when a process is started.
