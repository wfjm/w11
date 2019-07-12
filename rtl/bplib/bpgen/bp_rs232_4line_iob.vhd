-- $Id: bp_rs232_4line_iob.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    bp_rs232_4line_iob - syn
-- Description:    iob's for 4 line rs232 (RXD,TXD and RTS,CTS)
--
-- Dependencies:   xlib/iob_reg_i
--                 xlib/iob_reg_o
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  ise 11.4-14.7; viv 2014.4; ghdl 0.26-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-07-01   386   1.1    moved and renamed to bpgen
-- 2010-04-17   278   1.0    Initial version (as s3_rs232_iob_ext)
------------------------------------------------------------------------------
--    

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;

-- ----------------------------------------------------------------------------

entity bp_rs232_4line_iob is            -- iob's for 4 line rs232 (w/ RTS,CTS)
  port (
    CLK : in slbit;                     -- clock
    RXD : out slbit;                    -- receive data (board view)
    TXD : in slbit;                     -- transmit data (board view)
    CTS_N : out slbit;                  -- clear to send   (act. low)
    RTS_N : in slbit;                   -- request to send (act. low)
    I_RXD : in slbit;                   -- pad-i: receive data (board view)
    O_TXD : out slbit;                  -- pad-o: transmit data (board view)
    I_CTS_N : in slbit;                 -- pad-i: clear to send   (act. low)
    O_RTS_N : out slbit                 -- pad-o: request to send (act. low)
  );
end bp_rs232_4line_iob;

architecture syn of bp_rs232_4line_iob is
begin

  IOB_RXD : iob_reg_i                  -- line idle=1, so init sync flop =1
    generic map (INIT => '1')
    port map (CLK => CLK, CE => '1', DI => RXD,   PAD => I_RXD);
  
  IOB_TXD : iob_reg_o                  -- line idle=1, so init sync flop =1
    generic map (INIT => '1')
    port map (CLK => CLK, CE => '1', DO => TXD,   PAD => O_TXD);

  IOB_CTS : iob_reg_i 
    port map (CLK => CLK, CE => '1', DI => CTS_N, PAD => I_CTS_N);
  
  IOB_RTS : iob_reg_o
    port map (CLK => CLK, CE => '1', DO => RTS_N, PAD => O_RTS_N);
  
end syn;
