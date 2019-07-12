-- $Id: rgbdrv_3x2mux.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    rgbdrv_3x2mux - syn
-- Description:    rgbled driver: mux three 2bit inputs
--
-- Dependencies:   xlib/iob_reg_o_gen
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  viv 2017.2-2018.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-08-11  1038   1.0    Initial version (derived from rgbdrv_3x4mux)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;

entity rgbdrv_3x2mux is                 -- rgbled driver: mux three 2bit inputs
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_USEC : in slbit;                 -- 1 us clock enable
    DATR : in slv2;                     -- red   data
    DATG : in slv2;                     -- green data
    DATB : in slv2;                     -- blue  data
    O_RGBLED0 : out slv3;               -- pad-o: rgb led 0
    O_RGBLED1 : out slv3                -- pad-o: rgb led 1
  );
end rgbdrv_3x2mux;


architecture syn of rgbdrv_3x2mux is

  signal R_LED : slv4  := "0001";       -- keep 4 states to keep brightness !
  signal R_COL : slv3  := "001";
  signal R_DIM : slbit := '1';

  signal RGB0  : slv3 := (others=>'0');
  signal RGB1  : slv3 := (others=>'0');

begin

  IOB_RGB0: iob_reg_o_gen
    generic map (DWIDTH => 3)
    port map (CLK => CLK, CE => '1', DO => RGB0, PAD => O_RGBLED0);
  IOB_RGB1: iob_reg_o_gen
    generic map (DWIDTH => 3)
    port map (CLK => CLK, CE => '1', DO => RGB1, PAD => O_RGBLED1);

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_LED <= "0001";
        R_COL <= "001";
        R_DIM <= '1';
      else
        if CE_USEC = '1' then
          R_DIM <= not R_DIM;
          if R_DIM = '1' then
            R_COL <= R_COL(1) & R_COL(0) & R_COL(2);
            if R_COL(2) = '1' then
              R_LED <= R_LED(2) & R_LED(1) & R_LED(0) & R_LED(3);
            end if;
          end if;
        end if;
      end if;
    end if;

  end process proc_regs;

  proc_mux: process (R_DIM, R_COL, R_LED, DATR, DATG, DATB)
  begin
    RGB0(0) <= (not R_DIM) and R_COL(0) and R_LED(0) and DATR(0);
    RGB0(1) <= (not R_DIM) and R_COL(1) and R_LED(0) and DATG(0);
    RGB0(2) <= (not R_DIM) and R_COL(2) and R_LED(0) and DATB(0);

    RGB1(0) <= (not R_DIM) and R_COL(0) and R_LED(1) and DATR(1);
    RGB1(1) <= (not R_DIM) and R_COL(1) and R_LED(1) and DATG(1);
    RGB1(2) <= (not R_DIM) and R_COL(2) and R_LED(1) and DATB(1);
  end process proc_mux;
  
end syn;
