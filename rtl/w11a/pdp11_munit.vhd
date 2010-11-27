-- $Id: pdp11_munit.vhd 330 2010-09-19 17:43:53Z mueller $
--
-- Copyright 2006-2007 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_munit - syn
-- Description:    pdp11: mul/div unit for data (munit)
--
-- Dependencies:   -
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-09-18   300   1.1    renamed from mbox
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_munit is                   -- mul/div unit for data (munit)
  port (
    CLK : in slbit;                     -- clock
    DSRC : in slv16;                    -- 'src' data in
    DDST : in slv16;                    -- 'dst' data in
    DTMP : in slv16;                    -- 'tmp' data in
    GPR_DSRC : in slv16;                -- 'src' data from GPR
    FUNC : in slv2;                     -- function
    S_DIV : in slbit;                   -- s_opg_div state
    S_DIV_CN : in slbit;                -- s_opg_div_cn state
    S_DIV_CR : in slbit;                -- s_opg_div_cr state
    S_ASH : in slbit;                   -- s_opg_ash state
    S_ASH_CN : in slbit;                -- s_opg_ash_cn state
    S_ASHC : in slbit;                  -- s_opg_ashc state
    S_ASHC_CN : in slbit;               -- s_opg_ashc_cn state
    SHC_TC : out slbit;                 -- last shc cycle (shc==0)
    DIV_CR : out slbit;                 -- division: reminder correction needed
    DIV_CQ : out slbit;                 -- division: quotient correction needed
    DIV_ZERO : out slbit;               -- division: divident or divisor zero
    DIV_OVFL : out slbit;               -- division: overflow
    DOUT : out slv16;                   -- data output
    DOUTE : out slv16;                  -- data output extra
    CCOUT : out slv4                    -- condition codes out
  );
end pdp11_munit;

architecture syn of pdp11_munit is

  signal R_DD_L : slv16 := (others=>'0'); -- divident, low order part
  signal R_DDO_LT : slbit := '0';         -- original sign bit of divident
  signal R_DIV_V : slbit := '0';          -- V flag for division
  signal R_SHC : slv6 := (others=>'0');   -- shift counter for div and ash/c
  signal R_C1 : slbit := '0';             -- first cycle indicator
  signal R_MSBO : slbit := '0';           -- original sign bit for ash/c
  signal R_ASH_V : slbit := '0';          -- V flag for ash/c
  signal R_ASH_C : slbit := '0';          -- C flag for ash/c

  signal NEXT_DD_L : slv16 := (others=>'0');
  signal NEXT_DDO_LT : slbit := '0';
  signal NEXT_DIV_V : slbit := '0';
  signal NEXT_SHC : slv6 := (others=>'0');
  signal NEXT_C1 : slbit := '0';
  signal NEXT_MSBO : slbit := '0';
  signal NEXT_ASH_V : slbit := '0';
  signal NEXT_ASH_C : slbit := '0';

  signal SHC_TC_L : slbit := '0';

  signal DDST_ZERO : slbit := '0';
  signal DSRC_ZERO : slbit := '0';
  signal DSRC_ONES : slbit := '0';
  signal DTMP_ZERO : slbit := '0';

  signal DOUT_DIV : slv16 := (others=>'0');
  signal DOUTE_DIV : slv16 := (others=>'0');

  alias DR : slv16 is DDST;             -- divisor  (in DDST)
  alias DD_H : slv16 is DSRC;           -- divident, high order part (in DSRC)
  alias Q : slv16 is DTMP;              -- quotient (accumulated in DTMP)

begin

  proc_regs: process (CLK)
  begin
    if CLK'event and CLK='1' then
      R_DD_L   <= NEXT_DD_L;
      R_DDO_LT <= NEXT_DDO_LT;
      R_DIV_V  <= NEXT_DIV_V;
      R_SHC    <= NEXT_SHC;
      R_C1     <= NEXT_C1;
      R_MSBO   <= NEXT_MSBO;
      R_ASH_V  <= NEXT_ASH_V;
      R_ASH_C  <= NEXT_ASH_C;
    end if;
  end process proc_regs;
  
  proc_comm: process (DDST, DSRC, DTMP)
  begin
    
    DDST_ZERO <= '0';
    DSRC_ZERO <= '0';
    DSRC_ONES <= '0';
    DTMP_ZERO <= '0';

    if unsigned(DDST) = 0 then
      DDST_ZERO <= '1';
    end if;
    if unsigned(DSRC) = 0 then
      DSRC_ZERO <= '1';
    end if;
    if   signed(DSRC) = -1 then
      DSRC_ONES <= '1';
    end if;
    if unsigned(DTMP) = 0 then
      DTMP_ZERO <= '1';
    end if;
                     
  end process proc_comm;
                     
  proc_shc: process (DDST, R_SHC, R_C1,
                     S_DIV, S_DIV_CN, S_ASH, S_ASH_CN, S_ASHC, S_ASHC_CN)
  begin
    
    NEXT_SHC    <= R_SHC;
    NEXT_C1     <= R_C1;

    if S_ASH='1' or S_ASHC='1' then
      NEXT_SHC <= DDST(5 downto 0);
      NEXT_C1 <= '1';
    end if;
    if S_DIV = '1' then
      NEXT_SHC <= "001111";
      NEXT_C1 <= '1';
    end if;

    if S_DIV_CN='1' or S_ASH_CN='1' or S_ASHC_CN='1' then
      if R_SHC(5) = '0' then
        NEXT_SHC <= unsigned(R_SHC) - 1;
      else
        NEXT_SHC <= unsigned(R_SHC) + 1;
      end if;
      NEXT_C1 <= '0';
    end if;

    SHC_TC_L <= '0';
    if unsigned(R_SHC) = 0 then
      SHC_TC_L <= '1';
    end if;
    
  end process proc_shc;
  
  proc_div: process (DDST, DSRC, DTMP, GPR_DSRC, DR, DD_H, Q,
                     R_DD_L, R_DDO_LT, R_DIV_V, R_SHC, R_C1, 
                     S_DIV, S_DIV_CN, S_DIV_CR,
                     DDST_ZERO, DSRC_ZERO, DTMP_ZERO)
    
    variable shftdd : slbit := '0';
    variable subadd : slbit := '0';

    variable dd_gt : slbit := '0';
    
    variable qbit :   slbit := '0';
    variable qbit_1 : slbit := '0';
    variable qbit_n : slbit := '0';

    variable dd_h_old : slv16 := (others=>'0');  -- dd_h before add/sub
    variable dd_h_new : slv16 := (others=>'0');  -- dd_h after  add/sub
    
  begin
    
    NEXT_DD_L   <= R_DD_L;
    NEXT_DDO_LT <= R_DDO_LT;
    NEXT_DIV_V  <= R_DIV_V;

    DIV_ZERO <= '0';
    DIV_OVFL <= '0';

    qbit_1 := not (DR(15) xor DD_H(15)); -- !(dr<0 ^ dd_h<0)
    
    shftdd := not S_DIV_CR;
    if shftdd = '1' then
      dd_h_old := DD_H(14 downto 0) & R_DD_L(15);
    else
      dd_h_old := DD_H(15 downto 0);
    end if;
    
    if R_C1 = '1' then
      subadd := qbit_1;
      DIV_ZERO <= DDST_ZERO or
                  (DSRC_ZERO and DTMP_ZERO); -- note: DTMP here still dd_low !
    else
      subadd := Q(0);
    end if;
    
    if subadd = '0' then
      dd_h_new := signed(dd_h_old) + signed(DR);
    else
      dd_h_new := signed(dd_h_old) - signed(DR);
    end if;

    dd_gt := '0';
    if dd_h_new(15) = '0' and
       (unsigned(dd_h_new(14 downto 0))/=0 or
        unsigned(R_DD_L(14 downto 0))/=0)
    then
      dd_gt := '1';                     -- set if dd_new > 0
    end if;
    
    if R_DDO_LT = '0' then
      qbit_n := DR(15) xor not dd_h_new(15);  -- b_dr_lt ^ !b_dd_lt
    else
      qbit_n := DR(15) xor dd_gt;             -- b_dr_lt ^  b_dd_gt
    end if;    
    
    if S_DIV = '1' then
      NEXT_DDO_LT <= DD_H(15);
      NEXT_DD_L <= GPR_DSRC;
    end if;
    
    if R_C1 = '1' then
      NEXT_DIV_V <= (DD_H(15) xor DD_H(14)) or
                    (DD_H(15) xor (DR(15) xor qbit_n));
      DIV_OVFL <= (DD_H(15) xor DD_H(14)) or               --??? cleanup
                    (DD_H(15) xor (DR(15) xor qbit_n));    --??? cleanup
    end if;

    if S_DIV_CN = '1' then
      NEXT_DD_L <= R_DD_L(14 downto 0) & '0';
    end if;

    if S_DIV_CN = '1' then
      qbit := qbit_n;
    else
      qbit := qbit_1;
    end if;

    DIV_CR <= not (R_DDO_LT xor
                   (DR(15) xor Q(0)));  --!(b_ddo_lt ^ (b_dr_lt ^ b_qbit));
    DIV_CQ <= R_DDO_LT xor DR(15);      -- b_ddo_lt ^ b_dr_lt;
    
    DOUT_DIV  <= dd_h_new;
    DOUTE_DIV <= Q(14 downto 0) & qbit;

  end process proc_div;
  
  proc_ash: process (R_MSBO, R_ASH_V, R_ASH_C, R_SHC, DSRC, DTMP, FUNC,
                     S_ASH, S_ASH_CN, S_ASHC, S_ASHC_CN, SHC_TC_L)
  begin
    
    NEXT_MSBO   <= R_MSBO;
    NEXT_ASH_V  <= R_ASH_V;
    NEXT_ASH_C  <= R_ASH_C;

    if S_ASH='1' or S_ASHC='1' then
      NEXT_MSBO <= DSRC(15);
      NEXT_ASH_V <= '0';
      NEXT_ASH_C <= '0';
    end if;
    
    if (S_ASH_CN='1' or S_ASHC_CN='1') and SHC_TC_L='0' then
      if R_SHC(5) = '0' then            -- left shift
        if (R_MSBO xor DSRC(14))='1' then
          NEXT_ASH_V <= '1';
        end if;
        NEXT_ASH_C <= DSRC(15);
      else                              -- right shift
        if FUNC = c_munit_func_ash then
          NEXT_ASH_C <= DSRC(0);
        else
          NEXT_ASH_C <= DTMP(0);
        end if;
      end if;    
    end if;
      
  end process proc_ash;  

  proc_omux: process (DSRC, DDST, DTMP, FUNC,
                      R_ASH_V, R_ASH_C, R_SHC, R_DIV_V,
                      DOUT_DIV, DOUTE_DIV,
                      DSRC_ZERO, DSRC_ONES, DTMP_ZERO, DDST_ZERO)
    
    variable prod : slv32 := (others=>'0');
    variable omux_sel : slv2 := "00";
    variable ash_dout0 : slbit := '0';

    variable mul_c : slbit := '0';

  begin

    prod := signed(DSRC) * signed(DDST);

    case FUNC is
      when c_munit_func_mul =>
        omux_sel := "00";
      when c_munit_func_div =>
        omux_sel := "01";
      when c_munit_func_ash |c_munit_func_ashc =>
        if R_SHC(5) = '0' then
          omux_sel := "10";
        else
          omux_sel := "11";
        end if;
      when others => null;
    end case;

    if FUNC = c_munit_func_ash then
      ash_dout0 := '0';
    else
      ash_dout0 := DTMP(15);
    end if;

    case omux_sel is
      when "00"  =>                     -- MUL
        DOUT  <= prod(31 downto 16);
        DOUTE <= prod(15 downto 0); 
      when  "01" =>                     -- DIV
        DOUT  <= DOUT_DIV;
        DOUTE <= DOUTE_DIV; 
      when  "10" =>                     -- shift left
        DOUT  <= DSRC(14 downto 0) & ash_dout0;
        DOUTE <= DTMP(14 downto 0) & "0";
      when  "11" =>                     -- shift right
        DOUT  <= DSRC(15) & DSRC(15 downto 1);
        DOUTE <= DSRC(0) & DTMP(15 downto 1);
      when others => null;
    end case;
    
    mul_c := '0';                       -- MUL C codes is set if
    if DSRC(15) = '0' then
      if DSRC_ZERO='0' or DTMP(15)='1' then -- for positive results when
        mul_c := '1';                   --   product > 2^15-1
      end if;
    else                                -- for negative results when
      if DSRC_ONES='0' or DTMP(15)='0' then
        mul_c := '1';                   --   product < -2^15
      end if;
    end if;
    
    case FUNC is
      when c_munit_func_mul =>
        CCOUT(3) <= DSRC(15);               -- N
        CCOUT(2) <= DSRC_ZERO and DTMP_ZERO;-- Z
        CCOUT(1) <= '0';                    -- V=0
        CCOUT(0) <= mul_c;                  -- C

      when c_munit_func_div =>
        if DDST_ZERO = '1' then
          CCOUT(3) <= '0';                    -- N=0 if div/0
          CCOUT(2) <= '1';                    -- Z=1 if div/0
        elsif R_DIV_V = '1' then
          CCOUT(3) <= DSRC(15) xor DDST(15);  -- N (from unchanged reg)
          CCOUT(2) <= '0';                    -- Z (from unchanged reg) ??? veri
        else
          CCOUT(3) <= DTMP(15);               -- N (from Q (DTMP))
          CCOUT(2) <= DTMP_ZERO;              -- Z (from Q (DTMP)) ??? verify
        end if;
        CCOUT(1) <= R_DIV_V or DDST_ZERO;     -- V
        CCOUT(0) <= DDST_ZERO;                -- C (dst=0)

      when c_munit_func_ash =>
        CCOUT(3) <= DSRC(15);               -- N
        CCOUT(2) <= DSRC_ZERO;              -- Z
        CCOUT(1) <= R_ASH_V;                -- V
        CCOUT(0) <= R_ASH_C;                -- C

      when c_munit_func_ashc =>
        CCOUT(3) <= DSRC(15);               -- N
        CCOUT(2) <= DSRC_ZERO and DTMP_ZERO;-- Z
        CCOUT(1) <= R_ASH_V;                -- V
        CCOUT(0) <= R_ASH_C;                -- C

      when others => null;
    end case;        
        
  end process proc_omux;

  SHC_TC <= SHC_TC_L;
  
end syn;
