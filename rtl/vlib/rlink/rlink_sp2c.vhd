-- $Id: rlink_sp2c.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    rlink_sp2c - syn
-- Description:    rlink_core8 + serport_2clock2 combo
--
-- Dependencies:   rlink_core8
--                 serport/serport_2clock2
--                 rbus/rbd_rbmon
--                 rbus/rb_sres_or_2
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  viv 2015.4-2019.1; ghdl 0.33-0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-06-02  1159   1.0.1  use rbaddr_ constants
-- 2016-03-28   755   1.0    Initial version (derived from rlink_sp1c)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.rbdlib.all;
use work.rlinklib.all;
use work.serportlib.all;

entity rlink_sp2c is                    -- rlink_core8+serport_2clock2 combo
  generic (
    BTOWIDTH : positive :=  5;          -- rbus timeout counter width
    RTAWIDTH : positive :=  12;         -- retransmit buffer address width
    SYSID : slv32 := (others=>'0');     -- rlink system id
    IFAWIDTH : natural :=  5;           -- input fifo address width  (0=none)
    OFAWIDTH : natural :=  5;           -- output fifo address width (0=none)
    ENAPIN_RLMON : integer := -1;       -- SB_CNTL for rlmon  (-1=none)
    ENAPIN_RLBMON: integer := -1;       -- SB_CNTL for rlbmon (-1=none)
    ENAPIN_RBMON : integer := -1;       -- SB_CNTL for rbmon  (-1=none)
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15;           -- clk divider initial/reset setting
    RBMON_AWIDTH : natural := 0;        -- rbmon: buffer size, (0=none)
    RBMON_RBADDR : slv16 := rbaddr_rbmon); -- rbmon: base addr
  port (
    CLK  : in slbit;                    -- U|clock (user design)
    CE_USEC : in slbit;                 -- U|1 usec clock enable
    CE_MSEC : in slbit;                 -- U|1 msec clock enable
    CE_INT : in slbit := '0';           -- U|rri ato time unit clock enable
    RESET  : in slbit;                  -- U|reset
    CLKS : in slbit;                    -- S|clock (frontend:serial)
    CES_MSEC : in slbit;                -- S|1 msec clock enable
    ENAXON : in slbit;                  -- U|enable xon/xoff handling
    ESCFILL : in slbit;                 -- U|enable fill escaping
    RXSD : in slbit;                    -- S|receive serial data    (board view)
    TXSD : out slbit;                   -- S|transmit serial data   (board view)
    CTS_N : in slbit := '0';            -- S|clear to send (act.low, board view)
    RTS_N : out slbit;                  -- S|request to send (act.low, brd view)
    RB_MREQ : out rb_mreq_type;         -- U|rbus: request
    RB_SRES : in rb_sres_type;          -- U|rbus: response
    RB_LAM : in slv16;                  -- U|rbus: look at me
    RB_STAT : in slv4;                  -- U|rbus: status flags
    RL_MONI : out rl_moni_type;         -- U|rlink_core: monitor port
    SER_MONI : out serport_moni_type    -- U|serport: monitor port
  );
end entity rlink_sp2c;


architecture syn of rlink_sp2c is

  signal RLB_DI : slv8 := (others=>'0');
  signal RLB_ENA : slbit := '0';
  signal RLB_BUSY : slbit := '0';
  signal RLB_DO : slv8 := (others=>'0');
  signal RLB_VAL : slbit := '0';
  signal RLB_HOLD : slbit := '0';

  signal RB_MREQ_M     : rb_mreq_type := rb_mreq_init;
  signal RB_SRES_M     : rb_sres_type := rb_sres_init;
  signal RB_SRES_RBMON : rb_sres_type := rb_sres_init;

begin
  
  CORE : rlink_core8                    -- rlink master ----------------------
    generic map (
      BTOWIDTH     => BTOWIDTH,
      RTAWIDTH     => RTAWIDTH,
      SYSID        => SYSID,
      ENAPIN_RLMON => ENAPIN_RLMON,
      ENAPIN_RLBMON=> ENAPIN_RLBMON,
      ENAPIN_RBMON => ENAPIN_RBMON)
    port map (
      CLK        => CLK,
      CE_INT     => CE_INT,
      RESET      => RESET,
      ESCXON     => ENAXON,
      ESCFILL    => ESCFILL,
      RLB_DI     => RLB_DI,
      RLB_ENA    => RLB_ENA,
      RLB_BUSY   => RLB_BUSY,
      RLB_DO     => RLB_DO,
      RLB_VAL    => RLB_VAL,
      RLB_HOLD   => RLB_HOLD,
      RL_MONI    => RL_MONI,
      RB_MREQ    => RB_MREQ_M,
      RB_SRES    => RB_SRES_M,
      RB_LAM     => RB_LAM,
      RB_STAT    => RB_STAT
    );
  
  SERPORT : serport_2clock2             -- serport interface -----------------
    generic map (
      CDWIDTH   => CDWIDTH,
      CDINIT    => CDINIT,
      RXFAWIDTH => IFAWIDTH,
      TXFAWIDTH => OFAWIDTH)
    port map (
      CLKU     => CLK,
      RESET    => RESET,
      CLKS     => CLKS,
      CES_MSEC => CES_MSEC,
      ENAXON   => ENAXON,
      ENAESC   => '0',                  -- escaping now in rlink_core8
      RXDATA   => RLB_DI,
      RXVAL    => RLB_ENA,
      RXHOLD   => RLB_BUSY,
      TXDATA   => RLB_DO,
      TXENA    => RLB_VAL,
      TXBUSY   => RLB_HOLD,
      MONI     => SER_MONI,
      RXSD     => RXSD,
      TXSD     => TXSD,
      RXRTS_N  => RTS_N,
      TXCTS_N  => CTS_N
    );
  
  RBMON : if RBMON_AWIDTH > 0 generate  -- rbus monitor --------------
  begin
    I0 : rbd_rbmon
      generic map (
        RB_ADDR => RBMON_RBADDR,
        AWIDTH  => RBMON_AWIDTH)
      port map (
        CLK         => CLK,
        RESET       => RESET,
        RB_MREQ     => RB_MREQ_M,
        RB_SRES     => RB_SRES_RBMON,
        RB_SRES_SUM => RB_SRES_M
      );
  end generate RBMON;

  RB_SRES_OR : rb_sres_or_2             -- rbus or ---------------------------
    port map (
      RB_SRES_1  => RB_SRES,
      RB_SRES_2  => RB_SRES_RBMON,
      RB_SRES_OR => RB_SRES_M
    );

  RB_MREQ         <= RB_MREQ_M;         -- setup output signals

end syn;
