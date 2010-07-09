-- $Id: rrilib.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2007-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   rrilib
-- Description:    Remote Register Interface components
--
-- Dependencies:   -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4; ghdl 0.18-0.26
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-06-18   306   2.5.1  rename rbus data fields to _rbf_
-- 2010-06-06   302   2.5    use sop/eop framing instead of soc+chaining
-- 2010-06-03   300   2.1.5  use FAWIDTH=5 for rri_serport
-- 2010-05-02   287   2.1.4  ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT from interfaces; drop RTSFLUSH generic
-- 2010-05-01   285   2.1.3  remove rri_rb_rpcompat, now obsolete
-- 2010-04-18   279   2.1.2  rri_core_serport: drop RTSFBUF generic
-- 2010-04-10   275   2.1.1  add rri_core_serport
-- 2010-04-03   274   2.1    add CP_FLUSH for rri_core, rri_serport;
--                           CE_USEC, RTSFLUSH, CTS_N, RTS_N  for rri_serport
-- 2008-08-24   162   2.0    all with new rb_mreq/rb_sres interface
-- 2008-08-22   161   1.3    renamed rri_rbres_ -> rb_sres_; drop rri_[24]rp
-- 2008-02-16   116   1.2.1  added rri_wreg(rw|w|r)_3
-- 2008-01-20   113   1.2    added rb_[mreq|sres]; _rbres_or_*; _rb_rpcompat
-- 2007-11-24    98   1.1    added RP_IINT for rri_core.
-- 2007-09-09    81   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package rrilib is

constant c_rri_dat_idle : slv9 := "100000000";
constant c_rri_dat_sop  : slv9 := "100000001";
constant c_rri_dat_eop  : slv9 := "100000010";
constant c_rri_dat_nak  : slv9 := "100000011";
constant c_rri_dat_attn : slv9 := "100000100";

constant c_rri_cmd_rreg : slv3 := "000";
constant c_rri_cmd_rblk : slv3 := "001";
constant c_rri_cmd_wreg : slv3 := "010";
constant c_rri_cmd_wblk : slv3 := "011";
constant c_rri_cmd_stat : slv3 := "100";
constant c_rri_cmd_attn : slv3 := "101";
constant c_rri_cmd_init : slv3 := "110";

constant c_rri_iint_rbf_anena:    integer := 15;         -- anena flag
constant c_rri_iint_rbf_itoena:   integer := 14;         -- itoena flag
subtype  c_rri_iint_rbf_itoval is integer range 7 downto 0; -- command code

subtype  c_rri_cmd_rbf_seq is  integer range 7 downto 3; -- sequence number
subtype  c_rri_cmd_rbf_code is integer range 2 downto 0; -- command code

subtype  c_rri_stat_rbf_stat is integer range 7 downto 5;  -- ext status bits
constant c_rri_stat_rbf_attn:   integer := 4;  -- attention flags set
constant c_rri_stat_rbf_ccrc:   integer := 3;  -- command crc error
constant c_rri_stat_rbf_dcrc:   integer := 2;  -- data crc error
constant c_rri_stat_rbf_ioto:   integer := 1;  -- i/o time out
constant c_rri_stat_rbf_ioerr:  integer := 0;  -- i/o error

type rb_mreq_type is record             -- rribus - master request
  req  : slbit;                         -- request
  we   : slbit;                         -- write enable
  init : slbit;                         -- init
  addr : slv8;                          -- address
  din  : slv16;                         -- data (input to slave)
end record rb_mreq_type;

constant rb_mreq_init : rb_mreq_type :=
  ('0','0','0',                         -- req, we, init
   (others=>'0'),                       -- addr
   (others=>'0'));                      -- din

type rb_sres_type is record             -- rribus - slave response
  ack  : slbit;                         -- acknowledge
  busy : slbit;                         -- busy
  err  : slbit;                         -- error
  dout : slv16;                         -- data (output from slave)
end record rb_sres_type;

constant rb_sres_init : rb_sres_type :=
  ('0','0','0',                         -- ack, busy, err
   (others=>'0'));                      -- dout

component rri_core is                   -- rri, core interface
  generic (
    ATOWIDTH : positive :=  5;          -- access timeout counter width
    ITOWIDTH : positive :=  6);         -- idle timeout counter width
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit := '0';           -- rri ito time unit clock enable
    RESET  : in slbit;                  -- reset
    CP_DI : in slv9;                    -- comm port: data in
    CP_ENA : in slbit;                  -- comm port: data enable
    CP_BUSY : out slbit;                -- comm port: data busy
    CP_DO : out slv9;                   -- comm port: data out
    CP_VAL : out slbit;                 -- comm port: data valid
    CP_HOLD : in slbit;                 -- comm port: data hold
    CP_FLUSH : out slbit;               -- comm port: data flush
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  );
end component;

component rricp_aif is                  -- rri comm port, abstract interface
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit := '0';           -- rri ito time unit clock enable
    RESET  : in slbit :='0';            -- reset
    CP_DI : in slv9;                    -- comm port: data in
    CP_ENA : in slbit;                  -- comm port: data enable
    CP_BUSY : out slbit;                -- comm port: data busy
    CP_DO : out slv9;                   -- comm port: data out
    CP_VAL : out slbit;                 -- comm port: data valid
    CP_HOLD : in slbit := '0'           -- comm port: data hold
  );
end component;

component rrirp_aif is                  -- rri reg port, abstract interface
  port (
    CLK  : in slbit;                    -- clock
    RESET  : in slbit := '0';           -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_LAM : out slv16;                 -- rbus: look at me
    RB_STAT : out slv3                  -- rbus: status flags
  );
end component;

component rri_serport is                -- rri serport adapter
  generic (
    CPREF : slv4 :=  "1000";            -- comma prefix
    FAWIDTH : positive :=  5;           -- rx fifo address port width
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15);          -- clk divider initial/reset setting
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    RESET  : in slbit;                  -- reset
    RXSD : in slbit;                    -- receive serial data      (board view)
    TXSD : out slbit;                   -- transmit serial data     (board view)
    CTS_N : in slbit := '0';            -- clear to send   (act.low, board view)
    RTS_N : out slbit;                  -- request to send (act.low, board view)
    CP_DI : out slv9;                   -- comm port: data in
    CP_ENA : out slbit;                 -- comm port: data enable
    CP_BUSY : in slbit;                 -- comm port: data busy
    CP_DO : in slv9;                    -- comm port: data out
    CP_VAL : in slbit;                  -- comm port: data valid
    CP_HOLD : out slbit;                -- comm port: data hold
    CP_FLUSH : in slbit := '0'          -- comm port: data flush
  );
end component;

component rri_core_serport is           -- rri, core+serport with cpmon+rbmon
  generic (
    ATOWIDTH : positive :=  5;          -- access timeout counter width
    ITOWIDTH : positive :=  6;          -- idle timeout counter width
    FAWIDTH : positive :=  5;           -- rx fifo address port width
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15);          -- clk divider initial/reset setting
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    CE_INT : in slbit := '0';           -- rri ito time unit clock enable
    RESET  : in slbit;                  -- reset
    RXSD : in slbit;                    -- receive serial data      (board view)
    TXSD : out slbit;                   -- transmit serial data     (board view)
    CTS_N : in slbit := '0';            -- clear to send   (act.low, board view)
    RTS_N : out slbit;                  -- request to send (act.low, board view)
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  );
end component;

component rb_sres_or_2 is               -- rribus result or, 2 input
  port (
    RB_SRES_1  :  in rb_sres_type;                 -- rb_sres input 1
    RB_SRES_2  :  in rb_sres_type := rb_sres_init; -- rb_sres input 2
    RB_SRES_OR : out rb_sres_type       -- rb_sres or'ed output
  );
end component;
component rb_sres_or_3 is               -- rribus result or, 3 input
  port (
    RB_SRES_1  :  in rb_sres_type;                 -- rb_sres input 1
    RB_SRES_2  :  in rb_sres_type := rb_sres_init; -- rb_sres input 2
    RB_SRES_3  :  in rb_sres_type := rb_sres_init; -- rb_sres input 3
    RB_SRES_OR : out rb_sres_type       -- rb_sres or'ed output
  );
end component;
component rb_sres_or_4 is               -- rribus result or, 4 input
  port (
    RB_SRES_1  :  in rb_sres_type;                 -- rb_sres input 1
    RB_SRES_2  :  in rb_sres_type := rb_sres_init; -- rb_sres input 2
    RB_SRES_3  :  in rb_sres_type := rb_sres_init; -- rb_sres input 3
    RB_SRES_4  :  in rb_sres_type := rb_sres_init; -- rb_sres input 4
    RB_SRES_OR : out rb_sres_type       -- rb_sres or'ed output
  );
end component;

component rri_wreg_rw_3 is              -- rri: wide register r/w 3 bit select
  generic (
    DWIDTH : positive := 16);
  port (
    CLK  : in slbit;                    -- clock
    RESET  : in slbit;                  -- reset
    FADDR : slv3;                       -- field address
    SEL : slbit;                        -- select
    DATA : out slv(DWIDTH-1 downto 0);  -- data
    RB_MREQ :  in rb_mreq_type;         -- rribus request
    RB_SRES : out rb_sres_type          -- rribus response
  );
end component;

component rri_wreg_w_3 is               -- rri: wide register w-o 3 bit select
  generic (
    DWIDTH : positive := 16);
  port (
    CLK  : in slbit;                    -- clock
    RESET  : in slbit;                  -- reset
    FADDR : slv3;                       -- field address
    SEL : slbit;                        -- select
    DATA : out slv(DWIDTH-1 downto 0);  -- data
    RB_MREQ :  in rb_mreq_type;         -- rribus request
    RB_SRES : out rb_sres_type          -- rribus response
  );
end component;

component rri_wreg_r_3 is               -- rri: wide register r-o 3 bit select
  generic (
    DWIDTH : positive := 16);
  port (
    FADDR : slv3;                       -- field address
    SEL : slbit;                        -- select
    DATA : in slv(DWIDTH-1 downto 0);   -- data
    RB_SRES : out rb_sres_type          -- rribus response
  );
end component;

end rrilib;
