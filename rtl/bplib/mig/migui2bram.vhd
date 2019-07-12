-- $Id: migui2bram.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    migui2bram - sim
-- Description:    MIG to BRAM adapter
--
-- Dependencies:   xlib/s7_cmt_sfs
--                 memlib/ram_1swsr_wfirst_gen
--                 cdclib/cdc_signal_s1_as
-- Test bench:     -
-- Target Devices: 7-Series
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-28  1096   1.0    Initial version
-- 2018-11-10  1067   0.1    First draft 
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.cdclib.all;
use work.xlib.all;

entity migui2bram is                    -- MIG to BRAM adapter
  generic (
    BAWIDTH    : positive :=  4;        -- byte address width
    MAWIDTH    : positive := 28;        -- memory address width
    RAWIDTH    : positive := 19;        -- BRAM memory address width
    RDELAY     : positive :=  5;        -- read response delay
    CLKMUI_MUL     : positive :=  6;    -- multiplier for MIGUI clock
    CLKMUI_DIV     : positive := 12;    -- divider for MIGUI clock
    CLKMSYS_PERIOD : real := 6.000);    -- MIG SYS_CLK period
  port (
    SYS_CLK             : in  slbit;    -- system clock
    SYS_RST             : in  slbit;    -- system reset
    UI_CLK              : out slbit;    -- MIGUI clock
    UI_CLK_SYNC_RST     : out slbit;    -- MIGUI reset
    INIT_CALIB_COMPLETE : out slbit;    -- MIGUI calibration done
    APP_RDY             : out slbit;    -- MIGUI ready for cmd
    APP_EN              : in  slbit;    -- MIGUI command enable
    APP_CMD             : in  slv3;     -- MIGUI command
    APP_ADDR            : in  slv(MAWIDTH-1 downto 0); -- MIGUI address
    APP_WDF_RDY         : out slbit;      -- MIGUI ready for data write
    APP_WDF_WREN        : in  slbit;      -- MIGUI data write enable
    APP_WDF_DATA        : in  slv(8*(2**BAWIDTH)-1 downto 0);-- MIGUI write data
    APP_WDF_MASK        : in  slv((2**BAWIDTH)-1 downto 0);  -- MIGUI write mask
    APP_WDF_END         : in  slbit;                         -- MIGUI write end
    APP_RD_DATA_VALID   : out slbit;                         -- MIGUI read valid
    APP_RD_DATA         : out slv(8*(2**BAWIDTH)-1 downto 0);-- MIGUI read data
    APP_RD_DATA_END     : out slbit                          -- MIGUI read end
  );
end migui2bram;


architecture syn of migui2bram is
  
  constant mwidth : positive  := 2**BAWIDTH;     -- mask width (8 or 16)
  
  signal CLKFX   : slbit := '0';
  signal CLK     : slbit := '0';        -- local copy of UI_CLK
  signal R_RDVAL : slv(RDELAY downto 0) := (others=>'0');
  
  signal LOCKED        : slbit := '0';  -- raw from mmcm
  signal LOCKED_UICLK  : slbit := '0';  -- sync'ed to UI_CLK


begin
  
  assert BAWIDTH = 3 or BAWIDTH = 4
    report "assert( BAWIDTH = 3 or 4 )"
    severity failure;
  
  GEN_CLKMUI : s7_cmt_sfs               -- ui clock ------------
    generic map (
      VCO_DIVIDE     => 1,
      VCO_MULTIPLY   => CLKMUI_MUL,
      OUT_DIVIDE     => CLKMUI_DIV,
      CLKIN_PERIOD   => CLKMSYS_PERIOD,
      CLKIN_JITTER   => 0.01,
      STARTUP_WAIT   => false,
      GEN_TYPE       => "MMCM")
    port map (
      CLKIN   => SYS_CLK,
      CLKFX   => CLKFX,
      LOCKED  => LOCKED
    );

  CLK    <= CLKFX;                      -- !! copy both local CLK and exported 
  UI_CLK <= CLKFX;                      -- !! UI_CLK to avoid delta cycle diff

  CDC_LOCKED : cdc_signal_s1_as
    port map (
      CLKO  => CLK,
      DI    => LOCKED,
      DO    => LOCKED_UICLK
    );
  
  MARRAY: for col in mwidth-1 downto 0 generate
    signal MEM_WE : slbit := '0';
  begin
    MEM_WE <= APP_WDF_WREN and not APP_WDF_MASK(col); -- WE = not MASK !
    MCELL : ram_1swsr_wfirst_gen
      generic map (
        AWIDTH => RAWIDTH-BAWIDTH,
        DWIDTH =>  8)                 -- byte wide
      port map (
        CLK  => CLK,
        EN   => APP_EN,
        WE   => MEM_WE,
        ADDR => APP_ADDR(RAWIDTH-1 downto BAWIDTH),
        DI   => APP_WDF_DATA(8*col+7 downto 8*col),
        DO   => APP_RD_DATA(8*col+7 downto 8*col)
      );
  end generate MARRAY;

  UI_CLK_SYNC_RST     <= not LOCKED_UICLK;
  INIT_CALIB_COMPLETE <= LOCKED_UICLK;
    
  APP_RDY     <= '1';
  APP_WDF_RDY <= '1';
  
  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if SYS_RST = '1' then
        R_RDVAL <= (others=>'0');
      else
        R_RDVAL(0) <= APP_EN and not APP_WDF_WREN;
        R_RDVAL(RDELAY downto 1) <= R_RDVAL(RDELAY-1 downto 0);
      end if;
    end if;

  end process proc_regs;

  APP_RD_DATA_VALID <= R_RDVAL(RDELAY);
  APP_RD_DATA_END   <= R_RDVAL(RDELAY);

-- synthesis translate_off

  proc_moni: process (CLK)
  begin
    if rising_edge(CLK) then
      if SYS_RST = '0' then
        if APP_EN = '1' then
          assert unsigned(APP_ADDR(MAWIDTH-1 downto RAWIDTH)) = 0
            report "migui2bram: FAIL: out of memory size access"
            severity error;
        else
          assert APP_WDF_WREN = '0'
            report "migui2bram: FAIL: APP_WDF_WREN=1 when APP_EN=0"
            severity error;
        end if;
        assert APP_WDF_WREN = APP_WDF_END
          report "migui2bram: FAIL: APP_WDF_WREN /= APP_WDF_END"
          severity error;
      end if;
    end if;
  end process proc_moni;

-- synthesis translate_on

end syn;
