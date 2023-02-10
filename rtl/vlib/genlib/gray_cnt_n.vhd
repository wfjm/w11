-- $Id: gray_cnt_n.vhd 1371 2023-02-10 11:14:03Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    gray_cnt_n - syn
-- Description:    Genric width Gray code counter
--
-- Dependencies:   -
-- Test bench:     tb/tb_gray_cnt_n
-- Target Devices: generic
-- Tool versions:  xst 8.1-14.7; viv 2014.4-2022.1; ghdl 0.18-2.0.0
-- Revision History: 
-- Date         Rev Version    Comment
-- 2007-12-26   106   1.0      Initial version 
--
-- Some synthesis results (after synthesis step):
-- - 2023-02-10 viv 2022.1 for xc7a100tcsg324-1:
--   DWIDTH  LUT Flop
--        4    5    5
--        5    6    6
--        6    8    7
--        8   10    9
--       16   24   17
--       32   52   33
--       64  105   65
-- - 2016-03-25 ise 14.7   for xc6slx16-csg324-2:
--   DWIDTH  LUT Flop   clock(xst est.)
--        4    5    5   421MHz/ 2.37ns
--        5    6    6   414MHz/ 2.41ns
--        6    8    7   361MHz/ 2.77ns
--        8   10    9   321MHz/ 3.11ns
--       16   29   17   252MHz/ 3.96ns
--       32   70   33   214MHz/ 4.65ns
--       64  173   65   176MHz/ 5.66ns
-- - 2007-12-27 ise 8.2.03 for xc3s1000-ft256-4:
--   DWIDTH  LUT Flop   clock(xst est.)
--        4    6    5   305MHz/ 3.28ns
--        5    8    6   286MHz/ 2.85ns
--        8   13    9   234MHz/ 4.26ns
--       16   56   17   149MHz/ 6.67ns
--       32   95   33   161MHz/ 6.19ns
--       64  188   68   126MHz/ 7.90ns
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity gray_cnt_n is                    -- n bit gray code counter
  generic (
    DWIDTH : positive := 8);            -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE : in slbit := '1';               -- count enable
    DATA : out slv(DWIDTH-1 downto 0)   -- data out
  );
end entity gray_cnt_n;


architecture syn of gray_cnt_n is

  signal R_AUX : slbit := '1';
  signal R_DATA : slv(DWIDTH-1 downto 0) := (others=>'0');
  signal N_DATA : slv(DWIDTH-1 downto 0) := (others=>'0');

begin
  
  assert DWIDTH>=3
    report "assert(DWIDTH>=3): only 3 bit or larger supported"
    severity failure;

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_AUX  <= '1';
        R_DATA <= (others=>'0');        
      elsif CE = '1' then
        R_AUX  <= not R_AUX;
        R_DATA <= N_DATA;
      end if;
    end if;
  end process proc_regs;
    
  proc_next: process (R_AUX, R_DATA)
    variable r : slv(DWIDTH-1 downto 0) := (others=>'0');
    variable n : slv(DWIDTH-1 downto 0) := (others=>'0');
    variable s : slbit := '0';
  begin

    r := R_DATA;
    n := R_DATA;
    s := '1';
    
    if R_AUX = '1' then
      n(0) := not r(0);
    else
      for i in 1 to DWIDTH-2 loop
        if s='1' and r(i-1)='1' then
          n(i) := not r(i);
        end if;
        s := s and not r(i-1);
      end loop;
      if s = '1' then
        n(DWIDTH-1) := r(DWIDTH-2);
      end if;
    end if;

    N_DATA <= n;
    
  end process proc_next;

  DATA <= R_DATA;

end syn;

