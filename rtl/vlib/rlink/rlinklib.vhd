-- $Id: rlinklib.vhd 509 2013-04-21 20:46:20Z mueller $
--
-- Copyright 2007-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Tool versions:  xst 8.2, 9.1, 9.2, 11.4, 12.1, 13.3; ghdl 0.18-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-04-21   509   3.3.2  add rlb_moni record definition
-- 2012-12-29   466   3.3.1  add rlink_rlbmux
-- 2011-12-23   444   3.3    CLK_CYCLE now integer
-- 2011-12-21   442   3.2.1  retire old, deprecated interfaces
-- 2011-12-09   437   3.2    add rlink_core8
-- 2011-11-18   427   3.1.3  now numeric_std clean
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
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.serportlib.all;

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
subtype  c_rlink_iint_rbf_itoval is integer range 7 downto 0; -- itoval value

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

type rlb_moni_type is record            -- rlink 8b monitor port
  rxval : slbit;                        -- data in valid
  rxhold : slbit;                       -- data in hold
  txena : slbit;                        -- data out enable
  txbusy : slbit;                       -- data out busy
end record rlb_moni_type;

constant rlb_moni_init : rlb_moni_type :=
  ('0','0','0','0');                    -- rxval,rxhold,txena,txbusy

-- ise 13.1 xst can bug check if generic defaults in a package are defined via 
-- 'slv(to_unsigned())'. The conv_ construct prior to numeric_std was ok.
-- As workaround the ibus default addresses are defined here as constant.
constant rbaddr_rlink_serport : slv8 := slv(to_unsigned(2#11111110#,8));

-- this definition logically belongs into the 'for test benches' section'
-- must be here because it is needed as generic default in rlink_core8
-- simbus sb_cntl field usage for rlink
constant sbcntl_sbf_rlmon : integer := 15;

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

component rlink_core8 is                -- rlink core with 8bit iface
  generic (
    ATOWIDTH : positive :=  5;          -- access timeout counter width
    ITOWIDTH : positive :=  6;          -- idle timeout counter width
    CPREF : slv4 := c_rlink_cpref;      -- comma prefix
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
    RL_MONI : out rl_moni_type;         -- rlink: monitor port
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  );
end component;

component rlink_rlbmux is               -- rlink rlb multiplexer
  port (
    SEL : in slbit;                     -- port select (0:RLB<->P0; 1:RLB<->P1)
    RLB_DI : out slv8;                  -- rlb: data in
    RLB_ENA : out slbit;                -- rlb: data enable
    RLB_BUSY : in slbit;                -- rlb: data busy
    RLB_DO : in slv8;                   -- rlb: data out
    RLB_VAL : in slbit;                 -- rlb: data valid
    RLB_HOLD : out slbit;               -- rlb: data hold
    P0_RXDATA : in slv8;                -- p0: rx data
    P0_RXVAL : in slbit;                -- p0: rx valid
    P0_RXHOLD : out slbit;              -- p0: rx hold
    P0_TXDATA : out slv8;               -- p0: tx data
    P0_TXENA : out slbit;               -- p0: tx enable
    P0_TXBUSY : in slbit;               -- p0: tx busy
    P1_RXDATA : in slv8;                -- p1: rx data
    P1_RXVAL : in slbit;                -- p1: rx valid
    P1_RXHOLD : out slbit;              -- p1: rx hold
    P1_TXDATA : out slv8;               -- p1: tx data
    P1_TXENA : out slbit;               -- p1: tx enable
    P1_TXBUSY : in slbit                -- p1: tx busy
  );
end component;

--
-- core + concrete_interface combo's
--

component rlink_sp1c is                 -- rlink_core8+serport_1clock combo
  generic (
    ATOWIDTH : positive :=  5;          -- access timeout counter width
    ITOWIDTH : positive :=  6;          -- idle timeout counter width
    CPREF : slv4 := c_rlink_cpref;      -- comma prefix
    IFAWIDTH : natural :=  5;           -- input fifo address width  (0=none)
    OFAWIDTH : natural :=  5;           -- output fifo address width (0=none)
    ENAPIN_RLMON : integer := sbcntl_sbf_rlmon;  -- SB_CNTL for rlmon (-1=none)
    ENAPIN_RBMON : integer := sbcntl_sbf_rbmon;  -- SB_CNTL for rbmon (-1=none)
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15);          -- clk divider initial/reset setting
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    CE_INT : in slbit := '0';           -- rri ito time unit clock enable
    RESET  : in slbit;                  -- reset
    ENAXON : in slbit;                  -- enable xon/xoff handling
    ENAESC : in slbit;                  -- enable xon/xoff escaping
    RXSD : in slbit;                    -- receive serial data      (board view)
    TXSD : out slbit;                   -- transmit serial data     (board view)
    CTS_N : in slbit := '0';            -- clear to send   (act.low, board view)
    RTS_N : out slbit;                  -- request to send (act.low, board view)
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3;                  -- rbus: status flags
    RL_MONI : out rl_moni_type;         -- rlink_core: monitor port
    SER_MONI : out serport_moni_type    -- serport: monitor port
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
    CLK_CYCLE : in integer := 0;        -- clock cycle number
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

end package rlinklib;
