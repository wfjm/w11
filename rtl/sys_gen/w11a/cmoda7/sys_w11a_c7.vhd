-- $Id: sys_w11a_c7.vhd 1389 2023-05-20 15:48:59Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_w11a_c7 - syn
-- Description:    w11a test design for Cmod A7
--
-- Dependencies:   bplib/bpgen/s7_cmt_1ce1ce
--                 bplib/bpgen/bp_rs232_2line_iob
--                 vlib/rlink/rlink_sp2c
--                 w11a/pdp11_sys70
--                 ibus/ibdr_maxisys
--                 bplib/cmoda7/c7_cram_memctl
--                 w11a/pdp11_bram_memctl
--                 bplib/fx2rlink/ioleds_sp1c
--                 w11a/pdp11_hio70
--                 bplib/bpgen/sn_humanio_emu_rbus
--                 bplib/sysmon/sysmonx_rbus_base
--                 vlib/rbus/rbd_usracc
--                 vlib/rbus/rb_sres_or_4
--                 vlib/xlib/iob_reg_o_gen
--
-- Test bench:     tb/tb_sys_w11a_c7
--
-- Target Devices: generic
-- Tool versions:  viv 2017.2-2023.1; ghdl 0.34-2.0.0
--
-- Synthesized:
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2023-05-19  1388 2023.1  xc7a35t-1    3455  6055   279  50.0  1992
-- 2023-01-11  1349 2022.1  xc7a35t-1    3451  6019   279  50.0  2006
-- 2023-01-02  1342 2022.1  xc7a35t-1    3434  6005   279  50.0  1969
-- 2022-12-31  1340 2022.1  xc7a35t-1    3450  6018   279  50.0  1986
-- 2022-12-27  1339 2022.1  xc7a35t-1    3454  6026   279  50.0  2013
-- 2022-12-06  1324 2022.1  xc7a35t-1    3447  5998   278  50.0  1992
-- 2022-07-05  1247 2022.1  xc7a35t-1    3411  6189   279  50.0  2021
-- 2019-05-19  1150 2017.2  xc7a35t-1    3369  6994   285  50.0  2099 +dz11
-- 2019-04-27  1140 2017.2  xc7a35t-1    3243  6618   260  50.0  2009 +ibtst
-- 2019-03-02  1116 2017.2  xc7a35t-1    3156  6332   198  50.0  1918 +ibtst
-- 2019-02-02  1108 2018.3  xc7a35t-1    3112  6457   182  50.0  1936 
-- 2019-02-02  1108 2017.2  xc7a35t-1    3107  6216   182  50.0  1884 
-- 2018-10-13  1055 2017.2  xc7a35t-1    3107  6215   182  50.0  1889 +dmpcnt
-- 2018-09-15  1045 2017.2  xc7a35t-1    2883  5891   150  50.0  1826 +KW11P
-- 2017-06-27   918 2017.1  xc7a35t-1    2823  5827   150  50.0  1814 16kB cache
-- 2017-06-25   916 2017.1  xc7a35t-1    2823  5796   150  47.5  1744 +BRAM
-- 2017-06-24   914 2017.1  xc7a35t-1    2708  5668   150  26.0  1787
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-16  1086   1.3    use s7_cmt_1ce1ce
-- 2018-10-13  1055   1.2    use DM_STAT_EXP; IDEC to maxisys; setup PERFEXT
-- 2017-06-27   918   1.1.1  use 16 kB cache (all BRAM's used up)
-- 2017-06-25   916   1.1    add bram_memctl for 672 kB total memory
-- 2017-06-24   914   1.0    Initial version (derived from sys_w11a_n4)
------------------------------------------------------------------------------
--
-- w11a test design for Cmod A7 (using SRAM+BRAM as memory)
--    w11a + rlink + serport
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;
use work.serportlib.all;
use work.rblib.all;
use work.rbdlib.all;
use work.rlinklib.all;
use work.bpgenlib.all;
use work.bpgenrbuslib.all;
use work.sysmonrbuslib.all;
use work.cmoda7lib.all;
use work.iblib.all;
use work.ibdlib.all;
use work.pdp11.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_w11a_c7 is                   -- top level
                                        -- implements cmoda7_sram_aif
  port (
    I_CLK12 : in slbit;                 -- 12 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_BTN : in slv2;                    -- c7 buttons
    O_LED : out slv2;                   -- c7 leds
    O_RGBLED0_N : out slv3;             -- c7 rgb-led 0
    O_MEM_CE_N : out slbit;             -- sram: chip enable   (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv19;            -- sram: address lines
    IO_MEM_DATA : inout slv8            -- sram: data lines
  );
end sys_w11a_c7;

architecture syn of sys_w11a_c7 is

  signal CLK :   slbit := '0';

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal CLKS :  slbit := '0';
  signal CES_MSEC : slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
    
  signal RB_MREQ        : rb_mreq_type := rb_mreq_init;
  signal RB_SRES        : rb_sres_type := rb_sres_init;
  signal RB_SRES_CPU    : rb_sres_type := rb_sres_init;
  signal RB_SRES_HIO    : rb_sres_type := rb_sres_init;
  signal RB_SRES_SYSMON : rb_sres_type := rb_sres_init;
  signal RB_SRES_USRACC : rb_sres_type := rb_sres_init;

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4  := (others=>'0');
  
  signal SER_MONI : serport_moni_type := serport_moni_init;

  signal GRESET  : slbit := '0';        -- general reset (from rbus)
  signal CRESET  : slbit := '0';        -- cpu reset     (from cp)
  signal BRESET  : slbit := '0';        -- bus reset     (from cp or cpu)
  signal PERFEXT : slv8  := (others=>'0');

  signal EI_PRI  : slv3   := (others=>'0');
  signal EI_VECT : slv9_2 := (others=>'0');
  signal EI_ACKM : slbit  := '0';
  signal CP_STAT : cp_stat_type := cp_stat_init;
  signal DM_STAT_EXP : dm_stat_exp_type := dm_stat_exp_init;
  
  signal MEM_REQ   : slbit := '0';
  signal MEM_WE    : slbit := '0';
  signal MEM_BUSY  : slbit := '0';
  signal MEM_ACK_R : slbit := '0';
  signal MEM_ACT_R : slbit := '0';
  signal MEM_ACT_W : slbit := '0';
  signal MEM_ADDR  : slv20 := (others=>'0');
  signal MEM_BE    : slv4  := (others=>'0');
  signal MEM_DI    : slv32 := (others=>'0');
  signal MEM_DO    : slv32 := (others=>'0');

  signal MEM_REQ_SRAM   : slbit := '0';
  signal MEM_BUSY_SRAM  : slbit := '0';
  signal MEM_ACK_R_SRAM : slbit := '0';
  signal MEM_ACT_R_SRAM : slbit := '0';
  signal MEM_ACT_W_SRAM : slbit := '0';
  signal MEM_DO_SRAM    : slv32 := (others=>'0');

  signal MEM_REQ_BRAM   : slbit := '0';
  signal MEM_BUSY_BRAM  : slbit := '0';
  signal MEM_ACK_R_BRAM : slbit := '0';
  signal MEM_ACT_R_BRAM : slbit := '0';
  signal MEM_ACT_W_BRAM : slbit := '0';
  signal MEM_ADDR_BRAM  : slv20 := (others=>'0');
  signal MEM_DO_BRAM    : slv32 := (others=>'0');

  signal R_MEM_A17 : slbit := '0';

  signal IB_MREQ : ib_mreq_type := ib_mreq_init;
  signal IB_SRES_IBDR  : ib_sres_type := ib_sres_init;

  signal DISPREG  : slv16 := (others=>'0');
  signal ABCLKDIV : slv16 := (others=>'0');

  signal ESWI     : slv16 := (others=>'0');
  signal EBTN     : slv5  := (others=>'0');
  signal ELED     : slv16 := (others=>'0');
  signal EDSP_DAT : slv32 := (others=>'0');
  signal EDSP_DP  : slv8  := (others=>'0');

  signal LED      : slv2  := (others=>'0');

  constant rbaddr_rbmon : slv16 := x"ffe8"; -- ffe8/0008: 1111 1111 1110 1xxx
  constant rbaddr_hio   : slv16 := x"fef0"; -- fef0/0008: 1111 1110 1111 0xxx
  constant rbaddr_sysmon: slv16 := x"fb00"; -- fb00/0080: 1111 1011 0xxx xxxx

  constant sysid_proj  : slv16 := x"0201";   -- w11a
  constant sysid_board : slv8  := x"09";     -- cmoda7
  constant sysid_vers  : slv8  := x"00";

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;
  
  GEN_CLKALL : s7_cmt_1ce1ce            -- clock generator system ------------
    generic map (
      CLKIN_PERIOD   => 83.3,
      CLKIN_JITTER   => 0.01,
      STARTUP_WAIT   => false,
      CLK0_VCODIV    => sys_conf_clksys_vcodivide,
      CLK0_VCOMUL    => sys_conf_clksys_vcomultiply,
      CLK0_OUTDIV    => sys_conf_clksys_outdivide,
      CLK0_GENTYPE   => sys_conf_clksys_gentype,
      CLK0_CDUWIDTH  => 7,
      CLK0_USECDIV   => sys_conf_clksys_mhz,
      CLK0_MSECDIV   => 1000,      
      CLK1_VCODIV    => sys_conf_clkser_vcodivide,
      CLK1_VCOMUL    => sys_conf_clkser_vcomultiply,
      CLK1_OUTDIV    => sys_conf_clkser_outdivide,
      CLK1_GENTYPE   => sys_conf_clkser_gentype,
      CLK1_CDUWIDTH  => 7,
      CLK1_USECDIV   => sys_conf_clkser_mhz,
      CLK1_MSECDIV   => 1000)
    port map (
      CLKIN     => I_CLK12,
      CLK0      => CLK,
      CE0_USEC  => CE_USEC,
      CE0_MSEC  => CE_MSEC,
      CLK1      => CLKS,
      CE1_USEC  => open,
      CE1_MSEC  => CES_MSEC,
      LOCKED    => open
    );

  IOB_RS232 : bp_rs232_2line_iob         -- serport iob ----------------------
    port map (
      CLK      => CLKS,
      RXD      => RXD,
      TXD      => TXD,
      I_RXD    => I_RXD,
      O_TXD    => O_TXD
    );

  RLINK : rlink_sp2c                    -- rlink for serport -----------------
    generic map (
      BTOWIDTH     => 7,                -- 128 cycles access timeout
      RTAWIDTH     => 12,
      SYSID        => sysid_proj & sysid_board & sysid_vers,
      IFAWIDTH     => 5,                --  32 word input fifo
      OFAWIDTH     => 5,                --  32 word output fifo
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 12,
      CDINIT       => sys_conf_ser2rri_cdinit,
      RBMON_AWIDTH => sys_conf_rbmon_awidth,
      RBMON_RBADDR => rbaddr_rbmon)
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => RESET,
      CLKS     => CLKS,
      CES_MSEC => CES_MSEC,
      ENAXON   => '1',                  -- XON statically enabled !
      ESCFILL  => '0',
      RXSD     => RXD,
      TXSD     => TXD,
      CTS_N    => '0',
      RTS_N    => open,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT,
      RL_MONI  => open,
      SER_MONI => SER_MONI
    );

  PERFEXT(0) <= '0';                    -- unused (ext_rdrhit)
  PERFEXT(1) <= '0';                    -- unused (ext_wrrhit)
  PERFEXT(2) <= '0';                    -- unused (ext_wrflush)
  PERFEXT(3) <= SER_MONI.rxact;         -- ext_rlrxact
  PERFEXT(4) <= not SER_MONI.rxok;      -- ext_rlrxback
  PERFEXT(5) <= SER_MONI.txact;         -- ext_rltxact
  PERFEXT(6) <= not SER_MONI.txok;      -- ext_rltxback
  PERFEXT(7) <= CE_USEC;                -- ext_usec
  
  SYS70 : pdp11_sys70                   -- 1 cpu system ----------------------
    port map (
      CLK         => CLK,
      RESET       => RESET,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_CPU,
      RB_STAT     => RB_STAT,
      RB_LAM_CPU  => RB_LAM(0),
      GRESET      => GRESET,
      CRESET      => CRESET,
      BRESET      => BRESET,
      CP_STAT     => CP_STAT,
      EI_PRI      => EI_PRI,
      EI_VECT     => EI_VECT,
      EI_ACKM     => EI_ACKM,
      PERFEXT     => PERFEXT,
      IB_MREQ     => IB_MREQ,
      IB_SRES     => IB_SRES_IBDR,
      MEM_REQ     => MEM_REQ,
      MEM_WE      => MEM_WE,
      MEM_BUSY    => MEM_BUSY,
      MEM_ACK_R   => MEM_ACK_R,
      MEM_ADDR    => MEM_ADDR,
      MEM_BE      => MEM_BE,
      MEM_DI      => MEM_DI,
      MEM_DO      => MEM_DO,
      DM_STAT_EXP => DM_STAT_EXP
    );


  IBDR_SYS : ibdr_maxisys               -- IO system -------------------------
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      RESET    => GRESET,
      BRESET   => BRESET,
      ITIMER   => DM_STAT_EXP.se_itimer,
      IDEC     => DM_STAT_EXP.se_idec,
      CPUSUSP  => CP_STAT.cpususp,
      RB_LAM   => RB_LAM(15 downto 1),
      IB_MREQ  => IB_MREQ,
      IB_SRES  => IB_SRES_IBDR,
      EI_ACKM  => EI_ACKM,
      EI_PRI   => EI_PRI,
      EI_VECT  => EI_VECT,
      DISPREG  => DISPREG
    );

  -- logic to distribute/collect request/response to SRAM/BRAM
  proc_a17reg: process (CLK)
  begin
    
    if rising_edge(CLK) then
      if GRESET = '1' then
        R_MEM_A17 <= '0';
      else
        if MEM_REQ = '1' then
          R_MEM_A17 <= MEM_ADDR(17);
        end if;
      end if;
    end if;
    
  end process proc_a17reg;

  proc_a17mux: process (R_MEM_A17, MEM_REQ, MEM_ADDR,
                        MEM_BUSY_SRAM,  MEM_BUSY_BRAM,
                        MEM_ACK_R_SRAM, MEM_ACK_R_BRAM,
                        MEM_ACT_R_SRAM, MEM_ACT_R_BRAM,
                        MEM_ACT_W_SRAM, MEM_ACT_W_BRAM,
                        MEM_DO_SRAM,    MEM_DO_BRAM)
  begin
    
    MEM_REQ_SRAM  <= MEM_REQ and not MEM_ADDR(17);
    MEM_REQ_BRAM  <= MEM_REQ and     MEM_ADDR(17);
    MEM_ADDR_BRAM <= "000" & MEM_ADDR(16 downto 0);
    
    if R_MEM_A17 = '0' then
      MEM_BUSY  <= MEM_BUSY_SRAM;
      MEM_ACK_R <= MEM_ACK_R_SRAM;
      MEM_ACT_R <= MEM_ACT_R_SRAM;
      MEM_ACT_W <= MEM_ACT_W_SRAM;
      MEM_DO    <= MEM_DO_SRAM;
    else
      MEM_BUSY  <= MEM_BUSY_BRAM;
      MEM_ACK_R <= MEM_ACK_R_BRAM;
      MEM_ACT_R <= MEM_ACT_R_BRAM;
      MEM_ACT_W <= MEM_ACT_W_BRAM;
      MEM_DO    <= MEM_DO_BRAM;
    end if;
    
  end process proc_a17mux;
  
  SRAM_CTL : c7_sram_memctl             -- SRAM memory controller ------------
    port map (
      CLK     => CLK,
      RESET   => GRESET,
      REQ     => MEM_REQ_SRAM,
      WE      => MEM_WE,
      BUSY    => MEM_BUSY_SRAM,
      ACK_R   => MEM_ACK_R_SRAM,
      ACK_W   => open,
      ACT_R   => MEM_ACT_R_SRAM,
      ACT_W   => MEM_ACT_W_SRAM,
      ADDR    => MEM_ADDR(16 downto 0),
      BE      => MEM_BE,
      DI      => MEM_DI,
      DO      => MEM_DO_SRAM,
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

  BRAM_CTL: pdp11_bram_memctl           -- BRAM memory controller ------------
    generic map (
      MAWIDTH => sys_conf_memctl_mawidth,
      NBLOCK  => sys_conf_memctl_nblock)
    port map (
      CLK     => CLK,
      RESET   => GRESET,
      REQ     => MEM_REQ_BRAM,
      WE      => MEM_WE,
      BUSY    => MEM_BUSY_BRAM,
      ACK_R   => MEM_ACK_R_BRAM,
      ACK_W   => open,
      ACT_R   => MEM_ACT_R_BRAM,
      ACT_W   => MEM_ACT_W_BRAM,
      ADDR    => MEM_ADDR_BRAM,
      BE      => MEM_BE,
      DI      => MEM_DI,
      DO      => MEM_DO_BRAM
    );

  LED_IO : ioleds_sp1c                  -- hio leds from serport -------------
    port map (
      SER_MONI => SER_MONI,
      IOLEDS   => EDSP_DP(3 downto 0)
    );

  ABCLKDIV <= SER_MONI.abclkdiv(11 downto 0) & '0' & SER_MONI.abclkdiv_f;

  HIO70 : pdp11_hio70                   -- hio from sys70 --------------------
    generic map (
      LWIDTH => ELED'length,
      DCWIDTH => 3)
    port map (
      SEL_LED     => ESWI(3),
      SEL_DSP     => ESWI(5 downto 4),
      MEM_ACT_R   => MEM_ACT_R,
      MEM_ACT_W   => MEM_ACT_W,
      CP_STAT     => CP_STAT,
      DM_STAT_EXP => DM_STAT_EXP,
      ABCLKDIV    => ABCLKDIV,
      DISPREG     => DISPREG,
      LED         => ELED,
      DSP_DAT     => EDSP_DAT
    );

  EHIO : sn_humanio_emu_rbus            -- emulated hio ----------------------
    generic map (
      SWIDTH   => 16,
      BWIDTH   =>  5,
      LWIDTH   => 16,
      DCWIDTH  =>  3)
    port map (
      CLK     => CLK,
      RESET   => '0',
      RB_MREQ => RB_MREQ,
      RB_SRES => RB_SRES_HIO,
      SWI     => ESWI,
      BTN     => EBTN,
      LED     => ELED,
      DSP_DAT => EDSP_DAT,
      DSP_DP  => EDSP_DP
    );

  SMRB : if sys_conf_rbd_sysmon  generate    
    I0: sysmonx_rbus_base
      generic map (                     -- use default INIT_ (LP: Vccint=1.00)
        CLK_MHZ  => sys_conf_clksys_mhz,
        RB_ADDR  => rbaddr_sysmon)
      port map (
        CLK      => CLK,
        RESET    => RESET,
        RB_MREQ  => RB_MREQ,
        RB_SRES  => RB_SRES_SYSMON,
        ALM      => open,
        OT       => open,
        TEMP     => open
      );
  end generate SMRB;

  UARB : rbd_usracc
    port map (
      CLK     => CLK,
      RB_MREQ => RB_MREQ,
      RB_SRES => RB_SRES_USRACC
    );

  RB_SRES_OR : rb_sres_or_4             -- rbus or ---------------------------
    port map (
      RB_SRES_1  => RB_SRES_CPU,
      RB_SRES_2  => RB_SRES_HIO,
      RB_SRES_3  => RB_SRES_SYSMON,
      RB_SRES_4  => RB_SRES_USRACC,
      RB_SRES_OR => RB_SRES
    );
  
  IOB_LED : iob_reg_o_gen
    generic map (DWIDTH => O_LED'length)
    port map (CLK => CLK, CE => '1', DO => LED,    PAD => O_LED);

  LED(1) <= SER_MONI.txact;
  LED(0) <= SER_MONI.rxact;

  -- setup unused outputs in cmoda7
  O_RGBLED0_N <= (others=>'1');

end syn;
