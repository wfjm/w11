-- $Id: sramif_mig_nexys4d.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    sramif_mig_nexys4d - syn
-- Description:    SRAM to DDR via MIG for nexys4d
--
-- Dependencies:   bplib/mig/sramif2migui_core
--                 cdclib/cdc_pulse
--                 cdclib/cdc_value
--                 migui_nexys4d                (generated core)
-- Test bench:     tb_tst_sram_nexys4d
-- Target Devices: nexys4 DDRboard
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-01-02  1101   1.0.1  Initial version
-- 2018-12-30  1099   1.0    First draft (cloned from arty)
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.cdclib.all;
use work.miglib.all;
use work.miglib_nexys4d.all;

entity sramif_mig_nexys4d is            -- SRAM to DDR via MIG for nexyx4d
  port (
    CLK    : in slbit;                  -- clock
    RESET  : in slbit;                  -- reset
    REQ    : in slbit;                  -- request
    WE     : in slbit;                  -- write enable
    BUSY   : out slbit;                 -- controller busy
    ACK_R  : out slbit;                 -- acknowledge read
    ACK_W  : out slbit;                 -- acknowledge write
    ACT_R  : out slbit;                 -- signal active read
    ACT_W  : out slbit;                 -- signal active write
    ADDR   : in slv20;                  -- address  (32 bit word address)
    BE     : in slv4;                   -- byte enable
    DI     : in slv32;                  -- data in  (memory view)
    DO     : out slv32;                 -- data out (memory view)
    CLKMIG : in slbit;                  -- sys clock for mig core
    CLKREF : in slbit;                  -- ref clock for mig core
    TEMP   : in slv12;                  -- xadc die temp for mig core
    MONI   : out sramif2migui_moni_type;-- monitor signals
    DDR2_DQ      : inout slv16;         -- dram: data in/out
    DDR2_DQS_P   : inout slv2;          -- dram: data strobe (diff-p)
    DDR2_DQS_N   : inout slv2;          -- dram: data strobe (diff-n)
    DDR2_ADDR    : out   slv13;         -- dram: address
    DDR2_BA      : out   slv3;          -- dram: bank address
    DDR2_RAS_N   : out   slbit;         -- dram: row addr strobe    (act.low)
    DDR2_CAS_N   : out   slbit;         -- dram: column addr strobe (act.low)
    DDR2_WE_N    : out   slbit;         -- dram: write enable       (act.low)
    DDR2_CK_P    : out   slv1;          -- dram: clock (diff-p)
    DDR2_CK_N    : out   slv1;          -- dram: clock (diff-n)
    DDR2_CKE     : out   slv1;          -- dram: clock enable
    DDR2_CS_N    : out   slv1;          -- dram: chip select        (act.low)
    DDR2_DM      : out   slv2;          -- dram: data input mask
    DDR2_ODT     : out   slv1           -- dram: on-die termination
  );
end sramif_mig_nexys4d;


architecture syn of sramif_mig_nexys4d is
  
  signal MIG_BUSY     : slbit := '0';

  signal APP_RDY           : slbit := '0';
  signal APP_EN            : slbit := '0';
  signal APP_CMD           : slv3 := (others=>'0');
  signal APP_ADDR          : slv(mig_mawidth-1 downto 0) := (others=>'0');
  signal APP_WDF_RDY       : slbit := '0';
  signal APP_WDF_WREN      : slbit := '0';
  signal APP_WDF_DATA      : slv(mig_dwidth-1 downto 0)  := (others=>'0');
  signal APP_WDF_MASK      : slv(mig_mwidth-1 downto 0)  := (others=>'0');
  signal APP_WDF_END       : slbit := '0';
  signal APP_RD_DATA_VALID : slbit := '0';
  signal APP_RD_DATA       : slv(mig_dwidth-1 downto 0)  := (others=>'0');
  signal APP_RD_DATA_END   : slbit := '0';
  
  signal UI_CLK_SYNC_RST     : slbit := '0';
  signal INIT_CALIB_COMPLETE : slbit := '0';
  
  signal SYS_RST      : slbit := '0';
  signal SYS_RST_BUSY : slbit := '0';

  signal CLKMUI : slbit := '0';
  signal TEMP_MUI : slv12 := (others=>'0'); -- xadc die temp; on CLKMUI

begin
  
  SR2MIG: sramif2migui_core             -- SRAM to MIG iface -----------------
    generic map (
      BAWIDTH => mig_bawidth,
      MAWIDTH => mig_mawidth)
    port map (
      CLK         => CLK,
      RESET       => RESET,
      REQ         => REQ,
      WE          => WE,
      BUSY        => MIG_BUSY,
      ACK_R       => ACK_R,
      ACK_W       => ACK_W,
      ACT_R       => ACT_R,
      ACT_W       => ACT_W,
      ADDR        => ADDR,
      BE          => BE,
      DI          => DI,
      DO          => DO,
      MONI        => MONI,
      UI_CLK              => CLKMUI,
      UI_CLK_SYNC_RST     => UI_CLK_SYNC_RST,
      INIT_CALIB_COMPLETE => INIT_CALIB_COMPLETE,
      APP_RDY             => APP_RDY,
      APP_EN              => APP_EN,
      APP_CMD             => APP_CMD,
      APP_ADDR            => APP_ADDR,
      APP_WDF_RDY         => APP_WDF_RDY,
      APP_WDF_WREN        => APP_WDF_WREN,
      APP_WDF_DATA        => APP_WDF_DATA,
      APP_WDF_MASK        => APP_WDF_MASK,
      APP_WDF_END         => APP_WDF_END,
      APP_RD_DATA_VALID   => APP_RD_DATA_VALID,
      APP_RD_DATA         => APP_RD_DATA,
      APP_RD_DATA_END     => APP_RD_DATA_END  
    );

  CDC_SYSRST: cdc_pulse
    generic map (
      POUT_SINGLE => false,
      BUSY_WACK   => true)
    port map (
      CLKM  => CLK,
      RESET => '0',
      CLKS  => CLKMIG,
      PIN   => RESET,
      BUSY  => SYS_RST_BUSY,
      POUT  => SYS_RST
    );

  CDC_TEMP: cdc_value
    generic map (
      DWIDTH => TEMP'length)
    port map (
      CLKI => CLK,
      CLKO => CLKMUI,
      DI   => TEMP,
      DO   => TEMP_MUI,
      UPDT => open
    );

  MIG_CTL: migui_nexys4d
    port map (
      DDR2_DQ      => DDR2_DQ,
      DDR2_DQS_P   => DDR2_DQS_P,
      DDR2_DQS_N   => DDR2_DQS_N,
      DDR2_ADDR    => DDR2_ADDR,
      DDR2_BA      => DDR2_BA,
      DDR2_RAS_N   => DDR2_RAS_N,
      DDR2_CAS_N   => DDR2_CAS_N,
      DDR2_WE_N    => DDR2_WE_N,
      DDR2_CK_P    => DDR2_CK_P,
      DDR2_CK_N    => DDR2_CK_N,
      DDR2_CKE     => DDR2_CKE,
      DDR2_CS_N    => DDR2_CS_N,
      DDR2_DM      => DDR2_DM,
      DDR2_ODT     => DDR2_ODT,
      APP_ADDR            => APP_ADDR,
      APP_CMD             => APP_CMD,
      APP_EN              => APP_EN,
      APP_WDF_DATA        => APP_WDF_DATA,
      APP_WDF_END         => APP_WDF_END,
      APP_WDF_MASK        => APP_WDF_MASK,
      APP_WDF_WREN        => APP_WDF_WREN,
      APP_RD_DATA         => APP_RD_DATA,
      APP_RD_DATA_END     => APP_RD_DATA_END,
      APP_RD_DATA_VALID   => APP_RD_DATA_VALID,
      APP_RDY             => APP_RDY,
      APP_WDF_RDY         => APP_WDF_RDY,
      APP_SR_REQ          => '0',
      APP_REF_REQ         => '0',
      APP_ZQ_REQ          => '0',
      APP_SR_ACTIVE       => open,
      APP_REF_ACK         => open,
      APP_ZQ_ACK          => open,
      UI_CLK              => CLKMUI,
      UI_CLK_SYNC_RST     => UI_CLK_SYNC_RST,
      INIT_CALIB_COMPLETE => INIT_CALIB_COMPLETE,
      SYS_CLK_I           => CLKMIG,
      CLK_REF_I           => CLKREF,
      DEVICE_TEMP_I       => TEMP_MUI,
      SYS_RST             => SYS_RST
    );

  BUSY <= MIG_BUSY or SYS_RST_BUSY;

end syn;
