-- $Id: migui_arty_gsim.vhd 1201 2019-08-10 16:51:22Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    migui_arty - sim
-- Description:    MIG generated for arty - simple simulator
--
-- Dependencies:   bplib/mig/migui_core_gsim
-- Test bench:     tb_tst_sram_arty
-- Target Devices: arty board
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-25  1093   1.0    Initial version
-- 2018-11-17  1071   0.1    First draft
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.miglib.all;
use work.miglib_arty.all;

entity migui_arty is                    -- MIG generated for arty
  port (
    DDR3_DQ      : inout slv16;         -- dram: data in/out
    DDR3_DQS_P   : inout slv2;          -- dram: data strobe (diff-p)
    DDR3_DQS_N   : inout slv2;          -- dram: data strobe (diff-n)
    DDR3_ADDR    : out   slv14;         -- dram: address
    DDR3_BA      : out   slv3;          -- dram: bank address
    DDR3_RAS_N   : out   slbit;         -- dram: row addr strobe    (act.low)
    DDR3_CAS_N   : out   slbit;         -- dram: column addr strobe (act.low)
    DDR3_WE_N    : out   slbit;         -- dram: write enable       (act.low)
    DDR3_RESET_N : out   slbit;         -- dram: reset              (act.low)
    DDR3_CK_P    : out   slv1;          -- dram: clock (diff-p)
    DDR3_CK_N    : out   slv1;          -- dram: clock (diff-n)
    DDR3_CKE     : out   slv1;          -- dram: clock enable
    DDR3_CS_N    : out   slv1;          -- dram: chip select        (act.low)
    DDR3_DM      : out   slv2;          -- dram: data input mask
    DDR3_ODT     : out   slv1;          -- dram: on-die termination
    APP_ADDR            : in  slv(mig_mawidth-1 downto 0); -- MIGUI address
    APP_CMD             : in  slv3;     -- MIGUI command
    APP_EN              : in  slbit;    -- MIGUI command enable
    APP_WDF_DATA        : in  slv(mig_dwidth-1 downto 0);-- MIGUI write data
    APP_WDF_END         : in  slbit;                     -- MIGUI write end
    APP_WDF_MASK        : in  slv(mig_mwidth-1 downto 0); -- MIGUI write mask
    APP_WDF_WREN        : in  slbit;      -- MIGUI data write enable
    APP_RD_DATA         : out slv(mig_dwidth-1 downto 0); -- MIGUI read data
    APP_RD_DATA_END     : out slbit;                      -- MIGUI read end
    APP_RD_DATA_VALID   : out slbit;                      -- MIGUI read valid
    APP_RDY             : out slbit;    -- MIGUI ready for cmd
    APP_WDF_RDY         : out slbit;    -- MIGUI ready for data write
    APP_SR_REQ          : in  slbit;    -- MIGUI reserved (tie to 0)
    APP_REF_REQ         : in  slbit;    -- MIGUI refresh request
    APP_ZQ_REQ          : in  slbit;    -- MIGUI ZQ calibrate request
    APP_SR_ACTIVE       : out slbit;    -- MIGUI reserved (ignore)
    APP_REF_ACK         : out slbit;    -- MIGUI refresh acknowledge
    APP_ZQ_ACK          : out slbit;    -- MIGUI ZQ calibrate acknowledge
    UI_CLK              : out slbit;    -- MIGUI clock
    UI_CLK_SYNC_RST     : out slbit;    -- MIGUI reset
    INIT_CALIB_COMPLETE : out slbit;    -- MIGUI inital calibration complete
    SYS_CLK_I           : in  slbit;    -- MIGUI system clock
    CLK_REF_I           : in  slbit;    -- MIGUI reference clock
    DEVICE_TEMP_I       : in  slv12;    -- MIGUI xadc temperature
    SYS_RST             : in  slbit     -- MIGUI system reset
  );
end migui_arty;


architecture sim of migui_arty is
  
begin

  -- On Arty we have
  --   SYS_CLK_I   166.6 Mhz
  --   controller  333.3 MHz
  --   UI_CLK       83.3 MHz   (4:1)
  -- therefore for simulation
  --   f_vco    1000 MHz
  --   --> mul   6        (f_vco/SYS_CLK)
  --   --> div  12        (f_vco/UI_CLK)

  MIG_SIM : migui_core_gsim
    generic map (
      BAWIDTH => mig_bawidth,
      MAWIDTH => mig_mawidth,
      SAWIDTH => 24,
      CLKMUI_MUL =>  6,
      CLKMUI_DIV => 12)
    port map (
      SYS_CLK             => SYS_CLK_I,
      SYS_RST             => SYS_RST,
      UI_CLK              => UI_CLK,
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
      APP_RD_DATA_END     => APP_RD_DATA_END,
      APP_REF_REQ         => APP_REF_REQ,
      APP_ZQ_REQ          => APP_ZQ_REQ,
      APP_REF_ACK         => APP_REF_ACK,
      APP_ZQ_ACK          => APP_ZQ_ACK
    );

    DDR3_DQ      <= (others=>'Z');
    DDR3_DQS_P   <= (others=>'Z');
    DDR3_DQS_N   <= (others=>'Z');
    DDR3_ADDR    <= (others=>'0');
    DDR3_BA      <= (others=>'0');
    DDR3_RAS_N   <= '1';
    DDR3_CAS_N   <= '1';
    DDR3_WE_N    <= '1';
    DDR3_RESET_N <= '1';
    DDR3_CK_P    <= (others=>'0');
    DDR3_CK_N    <= (others=>'1');
    DDR3_CKE     <= (others=>'0');
    DDR3_CS_N    <= (others=>'1');
    DDR3_DM      <= (others=>'0');
    DDR3_ODT     <= (others=>'0');
  
    APP_SR_ACTIVE       <= '0';

end sim;
