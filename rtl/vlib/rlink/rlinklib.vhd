-- $Id: rlinklib.vhd 348 2010-12-26 15:23:44Z mueller $
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
-- Package Name:   rlinklib
-- Description:    Definitions for rlink interface and bus entities
--
-- Dependencies:   -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4, 12.1; ghdl 0.18-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-12-25   348   3.1.2  drop RL_FLUSH support, add RL_MONI for rlink_core;
--                           new rlink_serport interface;
--                           rename rlink_core_serport->rlink_base_serport
-- 2010-12-24   347   3.1.1  rename: CP_*->RL->*
-- 2010-12-22   346   3.1    rename: [cd]crc->[cd]err, ioto->rbnak, ioerr->rberr
-- 2010-12-04   343   3.0    move rbus components to rbus/rblib; renames
--                           rri_ -> rlink and c_rri -> c_rlink;
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
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.rblib.all;

package rlinklib is

constant c_rlink_cpref : slv4 := "1000";  -- default comma prefix
constant c_rlink_ncomm : positive := 4;   -- number commas (sop,eop,nak,attn)

constant c_rlink_dat_idle : slv9 := "100000000";
constant c_rlink_dat_sop  : slv9 := "100000001";
constant c_rlink_dat_eop  : slv9 := "100000010";
constant c_rlink_dat_nak  : slv9 := "100000011";
constant c_rlink_dat_attn : slv9 := "100000100";

constant c_rlink_cmd_rreg : slv3 := "000";
constant c_rlink_cmd_rblk : slv3 := "001";
constant c_rlink_cmd_wreg : slv3 := "010";
constant c_rlink_cmd_wblk : slv3 := "011";
constant c_rlink_cmd_stat : slv3 := "100";
constant c_rlink_cmd_attn : slv3 := "101";
constant c_rlink_cmd_init : slv3 := "110";

constant c_rlink_iint_rbf_anena:    integer := 15;         -- anena flag
constant c_rlink_iint_rbf_itoena:   integer := 14;         -- itoena flag
subtype  c_rlink_iint_rbf_itoval is integer range 7 downto 0; -- command code

subtype  c_rlink_cmd_rbf_seq is  integer range 7 downto 3; -- sequence number
subtype  c_rlink_cmd_rbf_code is integer range 2 downto 0; -- command code

subtype  c_rlink_stat_rbf_stat is integer range 7 downto 5;  -- ext status bits
constant c_rlink_stat_rbf_attn:   integer := 4;  -- attention flags set
constant c_rlink_stat_rbf_cerr:   integer := 3;  -- command error
constant c_rlink_stat_rbf_derr:   integer := 2;  -- data error
constant c_rlink_stat_rbf_rbnak:  integer := 1;  -- rbus no ack or timeout
constant c_rlink_stat_rbf_rberr:  integer := 0;  -- rbus err bit set

type rl_moni_type is record             -- rlink_core monitor port
  eop  : slbit;                         -- eop send in last cycle
  attn : slbit;                         -- attn send in last cycle
  lamp : slbit;                         -- attn (lam) pending
end record rl_moni_type;

constant rl_moni_init : rl_moni_type :=
  ('0','0','0');                        -- eop,attn,lamp

component rlink_core is                 -- rlink core with 9bit iface
  generic (
    ATOWIDTH : positive :=  5;          -- access timeout counter width
    ITOWIDTH : positive :=  6);         -- idle timeout counter width
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit := '0';           -- rlink ito time unit clock enable
    RESET  : in slbit;                  -- reset
    RL_DI : in slv9;                    -- rlink 9b: data in
    RL_ENA : in slbit;                  -- rlink 9b: data enable
    RL_BUSY : out slbit;                -- rlink 9b: data busy
    RL_DO : out slv9;                   -- rlink 9b: data out
    RL_VAL : out slbit;                 -- rlink 9b: data valid
    RL_HOLD : in slbit;                 -- rlink 9b: data hold
    RL_MONI : out rl_moni_type;         -- rlink: monitor port
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  );
end component;

component rlink_aif is                  -- rlink, abstract interface
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit := '0';           -- rlink ito time unit clock enable
    RESET  : in slbit :='0';            -- reset
    RL_DI : in slv9;                    -- rlink 9b: data in
    RL_ENA : in slbit;                  -- rlink 9b: data enable
    RL_BUSY : out slbit;                -- rlink 9b: data busy
    RL_DO : out slv9;                   -- rlink 9b: data out
    RL_VAL : out slbit;                 -- rlink 9b: data valid
    RL_HOLD : in slbit := '0'           -- rlink 9b: data hold
  );
end component;

component rlink_rlb2rl is               -- rlink 8 bit(rlb) to 9 bit(rl) adapter
  generic (
    CPREF : slv4 := c_rlink_cpref;      -- comma prefix
    IFAWIDTH : natural :=  5;           -- input fifo address width  (0=none)
    OFAWIDTH : natural :=  5);          -- output fifo address width (0=none)
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RLB_DI : in slv8;                   -- rlink 8b: data in
    RLB_ENA : in slbit;                 -- rlink 8b: data enable
    RLB_BUSY : out slbit;               -- rlink 8b: data busy
    RLB_DO : out slv8;                  -- rlink 8b: data out
    RLB_VAL : out slbit;                -- rlink 8b: data valid
    RLB_HOLD : in slbit;                -- rlink 8b: data hold
    IFIFO_SIZE : out slv4;              --  input fifo size (4 msb's)
    OFIFO_SIZE : out slv4;              -- output fifo fill (4 msb's)
    RL_DI : out slv9;                   -- rlink 9b: data in
    RL_ENA : out slbit;                 -- rlink 9b: data enable
    RL_BUSY : in slbit;                 -- rlink 9b: data busy
    RL_DO : in slv9;                    -- rlink 9b: data out
    RL_VAL : in slbit;                  -- rlink 9b: data valid
    RL_HOLD : out slbit                 -- rlink 9b: data hold
  );
end component;

-- this definition logically belongs into the 'for test benches' section'
-- must be here because it is needed as generic default in rlink_base
-- simbus sb_cntl field usage for rlink
  constant sbcntl_sbf_rlmon : integer := 15;

component rlink_base is                 -- rlink base: core+rl2rlb+rlmon+rbmon
                                        -- with buffered 8bit interface
  generic (
    ATOWIDTH : positive :=  5;          -- access timeout counter width
    ITOWIDTH : positive :=  6;          -- idle timeout counter width
    CPREF : slv4 := c_rlink_cpref;      -- comma prefix
    IFAWIDTH : natural :=  5;           -- input fifo address width  (0=none)
    OFAWIDTH : natural :=  5;           -- output fifo address width (0=none)
    ENAPIN_RLMON : integer := sbcntl_sbf_rlmon;  -- SB_CNTL for rlmon (-1=none)
    ENAPIN_RBMON : integer := sbcntl_sbf_rbmon); -- SB_CNTL for rbmon (-1=none)
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit := '0';           -- rlink ito time unit clock enable
    RESET  : in slbit;                  -- reset
    RLB_DI : in slv8;                   -- rlink 8b: data in
    RLB_ENA : in slbit;                 -- rlink 8b: data enable
    RLB_BUSY : out slbit;               -- rlink 8b: data busy
    RLB_DO : out slv8;                  -- rlink 8b: data out
    RLB_VAL : out slbit;                -- rlink 8b: data valid
    RLB_HOLD : in slbit;                -- rlink 8b: data hold
    IFIFO_SIZE : out slv4;              --  input fifo size (4 msb's)
    OFIFO_SIZE : out slv4;              -- output fifo fill (4 msb's)
    RL_MONI : out rl_moni_type;         -- rlink: monitor port
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  );
end component;

type rl_ser_moni_type is record         -- rlink_serport monitor port
  rxerr : slbit;                        -- rx err
  rxdrop : slbit;                       -- rx drop
  rxact : slbit;                        -- rx active
  txact : slbit;                        -- tx active
  abact : slbit;                        -- ab active
  abdone : slbit;                       -- ab done
  clkdiv : slv16;                       -- clock divider
end record rl_ser_moni_type;

constant rl_ser_moni_init : rl_ser_moni_type :=
  ('0','0',                             -- rxerr,rxdrop
   '0','0',                             -- rxact,txact
   '0','0',                             -- abact,abdone
   (others=>'0'));                      -- clkdiv

constant c_rlink_serport_rbf_fena:     integer := 12;             -- 
subtype  c_rlink_serport_rbf_fwidth is integer range 11 downto 9; -- 
subtype  c_rlink_serport_rbf_fdelay is integer range  8 downto 6; -- 
subtype  c_rlink_serport_rbf_rtsoff is integer range  5 downto 3; -- 
subtype  c_rlink_serport_rbf_rtson  is integer range  2 downto 0; -- 

component rlink_serport is              -- rlink serport adapter
  generic (
    RB_ADDR : slv8 := conv_std_logic_vector(2#11111110#,8);
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
    RLB_DI : out slv8;                  -- rlink 8b: data in
    RLB_ENA : out slbit;                -- rlink 8b: data enable
    RLB_BUSY : in slbit;                -- rlink 8b: data busy
    RLB_DO : in slv8;                   -- rlink 8b: data out
    RLB_VAL : in slbit;                 -- rlink 8b: data valid
    RLB_HOLD : out slbit;               -- rlink 8b: data hold
    RB_MREQ : in rb_mreq_type;          -- rbus: request (for inits only)
    IFIFO_SIZE : in slv4;               -- rlink_rlb2rb: input fifo size
    RL_MONI : in rl_moni_type;          -- rlink_core: monitor port
    RL_SER_MONI : out rl_ser_moni_type  -- rlink_serport: monitor port
  );
end component;

component rlink_base_serport is         -- rlink base+serport combo
  generic (
    ATOWIDTH : positive :=  5;          -- access timeout counter width
    ITOWIDTH : positive :=  6;          -- idle timeout counter width
    CPREF : slv4 := c_rlink_cpref;      -- comma prefix
    IFAWIDTH : natural :=  5;           -- input fifo address width  (0=none)
    OFAWIDTH : natural :=  5;           -- output fifo address width (0=none)
    ENAPIN_RLMON : integer := sbcntl_sbf_rlmon;  -- SB_CNTL for rlmon (-1=none)
    ENAPIN_RBMON : integer := sbcntl_sbf_rbmon;  -- SB_CNTL for rbmon (-1=none)
    RB_ADDR : slv8 := conv_std_logic_vector(2#11111110#,8);
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
    RB_STAT : in slv3;                  -- rbus: status flags
    RL_MONI : out rl_moni_type;         -- rlink_core: monitor port
    RL_SER_MONI : out rl_ser_moni_type  -- rlink_serport: monitor port
  );
end component;

--
-- components for use in test benches (not synthesizable)
--

component rlink_mon is                  -- rlink monitor
  generic (
    DWIDTH : positive :=  9);           -- data port width (8 or 9)
  port (
    CLK  : in slbit;                    -- clock
    CLK_CYCLE : in slv31 := (others=>'0');  -- clock cycle number
    ENA  : in slbit := '1';             -- enable monitor output
    RL_DI : in slv(DWIDTH-1 downto 0);  -- rlink: data in
    RL_ENA : in slbit;                  -- rlink: data enable
    RL_BUSY : in slbit;                 -- rlink: data busy
    RL_DO : in slv(DWIDTH-1 downto 0);  -- rlink: data out
    RL_VAL : in slbit;                  -- rlink: data valid
    RL_HOLD : in slbit                  -- rlink: data hold
  );
end component;

component rlink_mon_sb is              -- simbus wrap for rlink monitor
  generic (
    DWIDTH : positive :=  9;            -- data port width (8 or 9)
    ENAPIN : integer := sbcntl_sbf_rlmon); -- SB_CNTL signal to use for enable
  port (
    CLK  : in slbit;                    -- clock
    RL_DI : in slv(DWIDTH-1 downto 0);  -- rlink: data in
    RL_ENA : in slbit;                  -- rlink: data enable
    RL_BUSY : in slbit;                 -- rlink: data busy
    RL_DO : in slv(DWIDTH-1 downto 0);  -- rlink: data out
    RL_VAL : in slbit;                  -- rlink: data valid
    RL_HOLD : in slbit                  -- rlink: data hold
  );
end component;

end rlinklib;
