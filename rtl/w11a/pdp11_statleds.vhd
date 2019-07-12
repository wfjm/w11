-- $Id: pdp11_statleds.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_statleds - syn
-- Description:    pdp11: status leds
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2018.2; ghdl 0.31-0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-10-07  1054   1.1    use DM_STAT_EXP instead of DM_STAT_DP
-- 2015-02-20   649   1.0    Initial version 
------------------------------------------------------------------------------
--   LED  (7)    MEM_ACT_W
--        (6)    MEM_ACT_R
--        (5)    cmdbusy (all rlink access, mostly rdma)
--      (4:0)    if cpugo=1 show cpu mode activity
--                  (4) kernel mode, pri>0
--                  (3) kernel mode, pri=0
--                  (2) kernel mode, wait
--                  (1) supervisor mode
--                  (0) user mode
--              if cpugo=0 shows cpurust
--                  (4) '1'
--                (3:0) cpurust code

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_statleds is                -- status leds
  port (
    MEM_ACT_R : in slbit;               -- memory active read
    MEM_ACT_W : in slbit;               -- memory active write
    CP_STAT : in cp_stat_type;          -- console port status
    DM_STAT_EXP : in dm_stat_exp_type;  -- debug and monitor - exports
    STATLEDS : out slv8                 -- 8 bit CPU status 
  );
end pdp11_statleds;

architecture syn of pdp11_statleds is
  
begin

  proc_led: process (MEM_ACT_W, MEM_ACT_R, CP_STAT, DM_STAT_EXP.dp_psw)
    variable iled : slv8 := (others=>'0');
  begin
    iled := (others=>'0');

    iled(7) := MEM_ACT_W;
    iled(6) := MEM_ACT_R;
    iled(5) := CP_STAT.cmdbusy;
    if CP_STAT.cpugo = '1' then
      case DM_STAT_EXP.dp_psw.cmode is
        when c_psw_kmode =>
          if CP_STAT.cpuwait = '1' then
            iled(2) := '1';
          elsif unsigned(DM_STAT_EXP.dp_psw.pri) = 0 then
            iled(3) := '1';
          else
            iled(4) := '1';
          end if;
        when c_psw_smode =>
          iled(1) := '1';
        when c_psw_umode =>
          iled(0) := '1';
        when others => null;
      end case;
    else
      iled(4) := '1';
      iled(3 downto 0) := CP_STAT.cpurust;
    end if;

    STATLEDS <= iled;
    
  end process proc_led;

end syn;
