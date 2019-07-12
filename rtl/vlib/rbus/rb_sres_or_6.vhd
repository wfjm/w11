-- $Id: rb_sres_or_6.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    rb_sres_or_6 - syn
-- Description:    rbus result or, 6 input
--
-- Dependencies:   rb_sres_or_mon    [sim only]
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 14.7; viv 2015.4; ghdl 0.33
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-04-02   758   1.0    Initial version 
-- 2016-03-12   741   0.1    First draft 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.rblib.all;

-- ----------------------------------------------------------------------------

entity rb_sres_or_6 is                  -- rbus result or, 6 input
  port (
    RB_SRES_1  :  in rb_sres_type;                 -- rb_sres input 1
    RB_SRES_2  :  in rb_sres_type := rb_sres_init; -- rb_sres input 2
    RB_SRES_3  :  in rb_sres_type := rb_sres_init; -- rb_sres input 3
    RB_SRES_4  :  in rb_sres_type := rb_sres_init; -- rb_sres input 4
    RB_SRES_5  :  in rb_sres_type := rb_sres_init; -- rb_sres input 5
    RB_SRES_6  :  in rb_sres_type := rb_sres_init; -- rb_sres input 6
    RB_SRES_OR : out rb_sres_type       -- rb_sres or'ed output
  );
end rb_sres_or_6;

architecture syn of rb_sres_or_6 is
  
begin

  proc_comb : process (RB_SRES_1, RB_SRES_2, RB_SRES_3,
                       RB_SRES_4, RB_SRES_5, RB_SRES_6)
                       
  begin

    RB_SRES_OR.ack  <= RB_SRES_1.ack or
                       RB_SRES_2.ack or
                       RB_SRES_3.ack or
                       RB_SRES_4.ack or
                       RB_SRES_5.ack or
                       RB_SRES_6.ack;
    RB_SRES_OR.busy <= RB_SRES_1.busy or
                       RB_SRES_2.busy or
                       RB_SRES_3.busy or
                       RB_SRES_4.busy or
                       RB_SRES_5.busy or
                       RB_SRES_6.busy;
    RB_SRES_OR.err  <= RB_SRES_1.err or
                       RB_SRES_2.err or
                       RB_SRES_3.err or
                       RB_SRES_4.err or
                       RB_SRES_5.err or
                       RB_SRES_6.err;
    RB_SRES_OR.dout <= RB_SRES_1.dout or
                       RB_SRES_2.dout or
                       RB_SRES_3.dout or
                       RB_SRES_4.dout or
                       RB_SRES_5.dout or
                       RB_SRES_6.dout;
    
  end process proc_comb;
  
-- synthesis translate_off
  ORMON : rb_sres_or_mon
    port map (
      RB_SRES_1 => RB_SRES_1,
      RB_SRES_2 => RB_SRES_2,
      RB_SRES_3 => RB_SRES_3,
      RB_SRES_4 => RB_SRES_4,
      RB_SRES_5 => RB_SRES_5,
      RB_SRES_6 => RB_SRES_6
    );
-- synthesis translate_on

end syn;
