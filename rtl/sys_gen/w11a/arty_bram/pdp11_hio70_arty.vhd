-- $Id: pdp11_hio70_arty.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_hio70_arty - syn
-- Description:    pdp11: hio led and rgb for sys70 for arty
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  viv 2015.4-2018.2; ghdl 0.31-0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-10-07  1054   1.1    use DM_STAT_EXP instead of DM_STAT_DP
-- 2016-02-27   737   1.0    Initial version
------------------------------------------------------------------------------
--
-- collects the output for LED and RGB leds
-- MODE = 00xy
--   LED     IO activity
--             (3)   not SER_MONI.txok       (shows tx back pressure)
--             (2)   SER_MONI.txact          (shows tx activity)
--             (1)   not SER_MONI.rxok       (shows rx back pressure)
--             (0)   SER_MONI.rxact          (shows rx activity)
--   RGB_G   CPU busy       (active cpugo=1, enabled with y=1)
--             (3)   kernel mode, non-wait, pri>0
--             (2)   kernel mode, non-wait, pri=0
--             (1)   supervisor mode
--             (0)   user mode
--   RGB_R   CPU rust       (active cpugo=0, enabled with y=1)
--           (3:0)   cpurust code
--   RGB_B   MEM/cmd busy   (enabled with x=1)
--             (3)   MEM_ACT_W
--             (2)   MEM_ACT_R
--             (1)   cmdbusy (all rlink access, mostly rdma)
--             (0)   not cpugo
--
-- MODE = 0100   (DR emulation)
--   LED     DR(15:12)
--   RGB_B   DR(11:08)
--   RGB_G   DR( 7:04)
--   RGB_R   DR( 3:00)
--
-- MODE = 1xyy   (show lsb or msb of 16 bit register)
--   LED  show upper, RGB_G lower nibble; x=0 shows lsb and x=1 shows msb
--     yy = 00:   abclkdiv & abclkdiv_f
--          01:   PC
--          10:   DISPREG
--          11:   DR emulation
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_hio70_arty is              -- hio led+rgb for sys70 for arty
  port (
    CLK : in slbit;                     -- clock
    MODE : in slv4;                     -- mode select
    MEM_ACT_R : in slbit;               -- memory active read
    MEM_ACT_W : in slbit;               -- memory active write
    CP_STAT : in cp_stat_type;          -- console port status
    DM_STAT_EXP : in dm_stat_exp_type;  -- debug and monitor - exports
    DISPREG : in slv16;                 -- display register
    IOLEDS : in slv4;                   -- serport ioleds
    ABCLKDIV : in slv16;                -- serport clock divider
    LED : out slv4;                     -- hio leds
    RGB_R : out slv4;                   -- hio rgb leds - red 
    RGB_G : out slv4;                   -- hio rgb leds - green
    RGB_B : out slv4                    -- hio rgb leds - blue 
  );
end pdp11_hio70_arty;

architecture syn of pdp11_hio70_arty is

  signal R_LED   : slv4 := (others=>'0');
  signal R_RGB_R : slv4 := (others=>'0');
  signal R_RGB_G : slv4 := (others=>'0');
  signal R_RGB_B : slv4 := (others=>'0');
  
begin

  proc_regs : process (CLK)
    variable idat16 : slv16 := (others=>'0');
    variable idat8  : slv8  := (others=>'0');
    variable iled   : slv4  := (others=>'0');    
    variable irgb_r : slv4  := (others=>'0');    
    variable irgb_g : slv4  := (others=>'0');    
    variable irgb_b : slv4  := (others=>'0');    
  begin 
    if rising_edge(CLK) then

      idat16 := (others=>'0');
      case MODE(1 downto 0) is
        when "00" => idat16 := ABCLKDIV;
        when "01" => idat16 := DM_STAT_EXP.dp_pc;
        when "10" => idat16 := DISPREG;
        when "11" => idat16 := DM_STAT_EXP.dp_dsrc;
        when others => null;
      end case;
      
      if MODE(2) = '0' then
        idat8 := idat16( 7 downto 0);
      else
        idat8 := idat16(15 downto 8);
      end if;
      
      iled   := (others=>'0'); 
      irgb_r := (others=>'0'); 
      irgb_g := (others=>'0'); 
      irgb_b := (others=>'0'); 
      
      if MODE(3) = '0' then 
        if MODE(2) = '0' then           -- LED shows IO; RGB shows CPU/MEM
          iled := IOLEDS;

          if MODE(0) = '1' then
            if CP_STAT.cpugo = '1' then
              case DM_STAT_EXP.dp_psw.cmode is
                when c_psw_kmode =>
                  if CP_STAT.cpuwait = '0' then
                    if unsigned(DM_STAT_EXP.dp_psw.pri) = 0 then
                      irgb_g(2) := '1';
                    else
                      irgb_g(3) := '1';
                    end if;
                  end if;
                when c_psw_smode =>
                  irgb_g(1) := '1';
                when c_psw_umode =>
                  irgb_g(0) := '1';
                when others => null;
              end case;
            else
              irgb_r(3 downto 0) := CP_STAT.cpurust;
            end if;
          end if; -- MODE(0) = '1'
          
          if MODE(1) = '1' then
            irgb_b(3) := MEM_ACT_W;
            irgb_b(2) := MEM_ACT_R;
            irgb_b(1) := CP_STAT.cmdbusy;
            irgb_b(0) := not CP_STAT.cpugo;
          end if;               

        else                            -- LED+RGB show DR emulation
          iled   := DM_STAT_EXP.dp_dsrc(15 downto 12);
          irgb_b := DM_STAT_EXP.dp_dsrc(11 downto  8);
          irgb_g := DM_STAT_EXP.dp_dsrc( 7 downto  4);
          irgb_r := DM_STAT_EXP.dp_dsrc( 3 downto  0);
        end if; -- MODE(2) = '0'

      else                              -- LED+RGB show one of four regs
        iled   := idat8(7 downto 4);
        irgb_g := idat8(3 downto 0);
      end if; -- MODE(3) = '0'
      
      R_LED   <= iled;
      R_RGB_R <= irgb_r;
      R_RGB_G <= irgb_g;
      R_RGB_B <= irgb_b;
    end if;
    
  end process proc_regs;

  LED   <= R_LED;
  RGB_R <= R_RGB_R;
  RGB_G <= R_RGB_G;
  RGB_B <= R_RGB_B;
    
end syn;
