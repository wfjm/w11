-- $Id: rlink_cext_iface_vhpi.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    rlink_cext_iface - sim
-- Description:    Interface to external C code for tbcore_rlink - VHPI version
--
-- Dependencies:   -
--
-- To test:        -
--
-- Target Devices: generic
-- Tool versions:  ghdl 0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-02-07   729   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.rlink_cext_vhpi.all;

entity rlink_cext_iface is              -- interface to external C code - VHPI
  port (
    CLK : in slbit;                     -- clock
    CLK_CYCLE : in slv32;               -- clock cycle number
    RX_DATA : out slv32;                -- read data         (data ext->tb)
    RX_VAL : out slbit;                 -- read data valid   (data ext->tb)
    RX_HOLD : in slbit;                 -- read data hold    (data ext->tb)
    TX_DATA : in slv8;                  -- write data        (data tb->ext)
    TX_ENA : in slbit                   -- write data enable (data tb->ext)
  );
end rlink_cext_iface;

architecture sim of rlink_cext_iface is
  signal R_RXDATA : slv32 := (others=>'1');
  signal R_RXVAL  : slbit := '0';
begin
  
  proc_put: process (CLK)
    variable itxrc : integer := 0;
  begin
    if rising_edge(CLK) then
      if TX_ENA = '1' then
        itxrc := rlink_cext_putbyte(to_integer(unsigned(TX_DATA)));
        assert itxrc=0
          report "rlink_cext_putbyte error: "  & integer'image(itxrc)
          severity failure;        
      end if;
      
    end if;

  end process proc_put;

  proc_get: process (CLK)
    variable irxint : integer := 0;
  begin
    if rising_edge(CLK) then
      if RX_HOLD = '0' or R_RXVAL = '0' then
        irxint := rlink_cext_getbyte(to_integer(signed(CLK_CYCLE)));
        R_RXDATA <= slv(to_signed(irxint, 32));
        if irxint >= 0 then
          R_RXVAL <= '1';
        else
          R_RXVAL <= '0';
        end if;
      end if;
    end if;

  end process proc_get;

  RX_DATA <= R_RXDATA;
  RX_VAL  <= R_RXVAL;

end sim;
