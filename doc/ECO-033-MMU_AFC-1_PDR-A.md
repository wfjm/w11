# ECO-033:  MMU: ACF=1 trap and PDR A fix (2022-09-07)

### Scope
- was in w11a since 2009
- affects: all w11a systems

### Symptom summary
- part 1: ACF=1 traps on any access  
  Test 055 of `ekbee1` fails with
  ```
      MEMORY MANAGEMENT TRAP OR ABORT HAD INCORRECT CONDITION
      EXPECTD ERROR   AUTOI/D VIRTUAL
      CONDITN REGISTR REGISTR ADDRESS TESTNO  PC AT ABORT
      020011  030011  013427  054032  000055  054040
  ```

- part 2: `PDR` A bit is set for every access  
  This was discovered in a code review. The `PDR` A bit was set for
  all accesses.  The `PDR` A bit should be set only when
  _"trap condition met by the Access Control Field (ACF)"_ is fulfilled.
  Thus for
  ```
     ACF=001 read-only    trap and A bit on read
     ACF=100 read/write   trap and A bit on read or write
     ACF=101 read/write   trap and A bit on write
  ```

  `ekbee1` only checks whether this bit is set when expected, but does
  _not_ verify that is stays '0' when it should.

### Analysis
- part 1: ACF=1 traps on any access
  Caused by a simple mistake in the `ACF` handling in pdp11_mmu.vhd
  ```vhdl
      case PARPDR.acf is                -- evaluate accecc control field
      when "001" =>                     -- read-only; trap on read
        if CNTL.wacc='1' or CNTL.macc='1' then
          abo_rdonly := '1';
        end if;
        dotrap := '1';                  -- <== BUG, should be 'not write'
  ```
- part 2: PDR A bit is set for every access
  Caused simplistic AIB handling in pdp11_mmu.vhd
  ```vhdl
        if doabort = '0' then
          AIB_SETA <= '1';              -- <== BUG, should be 'dotrap'
          AIB_SETW <= CNTL.wacc or CNTL.macc;
        end if;
  ```

### Fixes
- part 1: `AIB_SETA <= dotrap;`
- part 2: `dotrap := not iswrite;`

### Hindsight
Took 13 years to fix. The MMU traps and `PDR` A and W bits are 11/45 and 11/70
specific and not used by any operating system. Only tests like `ekbee1` use
this functionality.
