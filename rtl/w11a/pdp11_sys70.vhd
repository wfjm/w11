-- $Id: pdp11_sys70.vhd 1053 2018-10-06 20:34:52Z mueller $
--
-- Copyright 2015-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 3, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_sys70 - syn
-- Description:    pdp11: 11/70 system - single core +rbus,debug,cache
--
-- Dependencies:   w11a/pdp11_core_rbus
--                 w11a/pdp11_core
--                 w11a/pdp11_cache
--                 w11a/pdp11_mem70
--                 ibus/ibd_ibmon
--                 ibus/ib_sres_or_3
--                 w11a/pdp11_dmscnt
--                 w11a/pdp11_dmcmon
--                 w11a/pdp11_dmhpbt
--                 w11a/pdp11_dmpcnt
--                 rbus/rb_sres_or_4
--                 rbus/rb_sres_or_2
--                 w11a/pdp11_tmu_sb           [sim only]
--
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2014.4-2018.2; ghdl 0.33-0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-10-06  1053   1.2.3  drop DM_STAT_SY; add DM_STAT_CA; use _SE.pcload
-- 2018-09-29  1051   1.2.2  add pdp11_dmpcnt
-- 2017-04-22   884   1.2.1  pdp11_dmcmon: use SNUM and AWIDTH generics
-- 2016-03-22   750   1.2    pdp11_cache now configurable size
-- 2015-11-01   712   1.1.4  use sbcntl_sbf_tmu
-- 2015-07-19   702   1.1.3  use DM_STAT_SE
-- 2015-07-04   697   1.1.2  change DM_STAT_SY setup; add dmcmon, dmhbpt;
-- 2015-06-26   695   1.1.1  add pdp11_dmscnt support
-- 2015-05-09   677   1.1    start/stop/suspend overhaul; reset overhaul
-- 2015-05-01   672   1.0    Initial version (extracted from sys_w11a_*)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.pdp11.all;
use work.iblib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity pdp11_sys70 is                   -- 11/70 system 1 core +rbus,debug,cache
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus request  (slave)
    RB_SRES : out rb_sres_type;         -- rbus response
    RB_STAT : out slv4;                 -- rbus status flags
    RB_LAM_CPU : out slbit;             -- rbus lam (cpu)
    GRESET : out slbit;                 -- general reset (from rbus)
    CRESET : out slbit;                 -- cpu reset     (from cp)
    BRESET : out slbit;                 -- bus reset     (from cp or cpu)
    CP_STAT : out cp_stat_type;         -- console port status
    EI_PRI  : in slv3;                  -- external interrupt priority
    EI_VECT : in slv9_2;                -- external interrupt vector
    EI_ACKM : out slbit;                -- external interrupt acknowledge
    ITIMER : out slbit;                 -- instruction timer
    IB_MREQ : out ib_mreq_type;         -- ibus request  (master)
    IB_SRES : in ib_sres_type;          -- ibus response
    MEM_REQ : out slbit;                -- memory: request
    MEM_WE : out slbit;                 -- memory: write enable
    MEM_BUSY : in slbit;                -- memory: controller busy
    MEM_ACK_R : in slbit;               -- memory: acknowledge read
    MEM_ADDR : out slv20;               -- memory: address
    MEM_BE : out slv4;                  -- memory: byte enable
    MEM_DI : out slv32;                 -- memory: data in  (memory view)
    MEM_DO : in slv32;                  -- memory: data out (memory view)
    DM_STAT_DP : out dm_stat_dp_type    -- debug and monitor status - dpath
  );
end pdp11_sys70;

architecture syn of pdp11_sys70 is
  
  signal RB_SRES_CORE   : rb_sres_type := rb_sres_init;
  signal RB_SRES_DMSCNT : rb_sres_type := rb_sres_init;
  signal RB_SRES_DMPCNT : rb_sres_type := rb_sres_init;
  signal RB_SRES_DMHBPT : rb_sres_type := rb_sres_init;
  signal RB_SRES_DMCMON : rb_sres_type := rb_sres_init;
  signal RB_SRES_DM     : rb_sres_type := rb_sres_init;
  signal RB_SRES_L      : rb_sres_type := rb_sres_init;

  signal CP_CNTL : cp_cntl_type := cp_cntl_init;
  signal CP_ADDR : cp_addr_type := cp_addr_init;
  signal CP_DIN  : slv16 := (others=>'0');
  signal CP_STAT_L : cp_stat_type := cp_stat_init;
  signal CP_DOUT : slv16 := (others=>'0');
  
  signal EI_ACKM_L : slbit := '0';

  signal EM_MREQ : em_mreq_type := em_mreq_init;
  signal EM_SRES : em_sres_type := em_sres_init;
  
  signal GRESET_L : slbit := '0';
  signal CRESET_L : slbit := '0';
  signal BRESET_L : slbit := '0';

  signal HM_ENA      : slbit := '0';
  signal MEM70_FMISS : slbit := '0';
  signal CACHE_FMISS : slbit := '0';

  signal HBPT        : slbit := '0';

  signal DM_STAT_SE   : dm_stat_se_type := dm_stat_se_init;
  signal DM_STAT_DP_L : dm_stat_dp_type := dm_stat_dp_init;
  signal DM_STAT_VM   : dm_stat_vm_type := dm_stat_vm_init;
  signal DM_STAT_CO   : dm_stat_co_type := dm_stat_co_init;
  signal DM_STAT_CA   : dm_stat_ca_type := dm_stat_ca_init;

  signal IB_MREQ_M : ib_mreq_type := ib_mreq_init;
  signal IB_SRES_M : ib_sres_type := ib_sres_init;
  signal IB_SRES_MEM70 : ib_sres_type := ib_sres_init;
  signal IB_SRES_IBMON : ib_sres_type := ib_sres_init;

  constant rbaddr_ibus0 : slv16 := x"4000"; -- 4000/1000: 0100 xxxx xxxx xxxx
  constant rbaddr_core0 : slv16 := x"0000"; -- 0000/0020: 0000 0000 000x xxxx

begin

  RB2CP : pdp11_core_rbus
    generic map (
      RB_ADDR_CORE => rbaddr_core0,
      RB_ADDR_IBUS => rbaddr_ibus0)
    port map (
      CLK       => CLK,
      RESET     => RESET,
      RB_MREQ   => RB_MREQ,
      RB_SRES   => RB_SRES_CORE,
      RB_STAT   => RB_STAT,
      RB_LAM    => RB_LAM_CPU,
      GRESET    => GRESET_L,
      CP_CNTL   => CP_CNTL,
      CP_ADDR   => CP_ADDR,
      CP_DIN    => CP_DIN,
      CP_STAT   => CP_STAT_L,
      CP_DOUT   => CP_DOUT      
    );

  W11A : pdp11_core
    port map (
      CLK       => CLK,
      RESET     => GRESET_L,
      CP_CNTL   => CP_CNTL,
      CP_ADDR   => CP_ADDR,
      CP_DIN    => CP_DIN,
      CP_STAT   => CP_STAT_L,
      CP_DOUT   => CP_DOUT,
      ESUSP_O   => open,
      ESUSP_I   => '0',
      ITIMER    => ITIMER,
      HBPT      => HBPT,
      EI_PRI    => EI_PRI,
      EI_VECT   => EI_VECT,
      EI_ACKM   => EI_ACKM_L,
      EM_MREQ   => EM_MREQ,
      EM_SRES   => EM_SRES,
      CRESET    => CRESET_L,
      BRESET    => BRESET_L,
      IB_MREQ_M => IB_MREQ_M,
      IB_SRES_M => IB_SRES_M,
      DM_STAT_SE => DM_STAT_SE,
      DM_STAT_DP => DM_STAT_DP_L,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO
    );  

  CACHE: pdp11_cache
    generic map (
      TWIDTH => sys_conf_cache_twidth)
    port map (
      CLK        => CLK,
      GRESET     => GRESET_L,
      EM_MREQ    => EM_MREQ,
      EM_SRES    => EM_SRES,
      FMISS      => CACHE_FMISS,
      MEM_REQ    => MEM_REQ,
      MEM_WE     => MEM_WE,
      MEM_BUSY   => MEM_BUSY,
      MEM_ACK_R  => MEM_ACK_R,
      MEM_ADDR   => MEM_ADDR,
      MEM_BE     => MEM_BE,
      MEM_DI     => MEM_DI,
      MEM_DO     => MEM_DO,
      DM_STAT_CA => DM_STAT_CA
    );

  MEM70: pdp11_mem70
    port map (
      CLK         => CLK,
      CRESET      => BRESET_L,
      HM_ENA      => HM_ENA,
      HM_VAL      => DM_STAT_CA.rdhit,
      CACHE_FMISS => MEM70_FMISS,
      IB_MREQ     => IB_MREQ_M,
      IB_SRES     => IB_SRES_MEM70
    );

  HM_ENA      <= EM_SRES.ack_r or EM_SRES.ack_w;
  CACHE_FMISS <= MEM70_FMISS or sys_conf_cache_fmiss;
  
  IBMON : if sys_conf_ibmon_awidth > 0 generate
  begin
    I0 : ibd_ibmon
      generic map (
        IB_ADDR => slv(to_unsigned(8#160000#,16)),
        AWIDTH  => sys_conf_ibmon_awidth)
      port map (
        CLK         => CLK,
        RESET       => RESET,
        IB_MREQ     => IB_MREQ_M,
        IB_SRES     => IB_SRES_IBMON,
        IB_SRES_SUM => DM_STAT_VM.ibsres
      );
  end generate IBMON;

  IB_SRES_OR : ib_sres_or_3
    port map (
      IB_SRES_1  => IB_SRES_MEM70,
      IB_SRES_2  => IB_SRES,
      IB_SRES_3  => IB_SRES_IBMON,
      IB_SRES_OR => IB_SRES_M
    );

  DMSCNT : if sys_conf_dmscnt generate
  begin
    I0: pdp11_dmscnt
      generic map (
        RB_ADDR => slv(to_unsigned(16#0040#,16)))
      port map (
        CLK         => CLK,
        RESET       => RESET,
        RB_MREQ     => RB_MREQ,
        RB_SRES     => RB_SRES_DMSCNT,
        DM_STAT_SE  => DM_STAT_SE,
        DM_STAT_DP  => DM_STAT_DP_L,
        DM_STAT_CO  => DM_STAT_CO
      );
  end generate DMSCNT;

  DMCMON : if sys_conf_dmcmon_awidth > 0 generate
  begin
    I0: pdp11_dmcmon
      generic map (
        RB_ADDR => slv(to_unsigned(16#0048#,16)),
        AWIDTH  => sys_conf_dmcmon_awidth,
        SNUM    => sys_conf_dmscnt)
      port map (
        CLK         => CLK,
        RESET       => RESET,
        RB_MREQ     => RB_MREQ,
        RB_SRES     => RB_SRES_DMCMON,
        DM_STAT_SE  => DM_STAT_SE,
        DM_STAT_DP  => DM_STAT_DP_L,
        DM_STAT_VM  => DM_STAT_VM,
        DM_STAT_CO  => DM_STAT_CO
      );
  end generate DMCMON;

  DMHBPT : if sys_conf_dmhbpt_nunit > 0 generate
  begin
    I0: pdp11_dmhbpt
      generic map (
        RB_ADDR => slv(to_unsigned(16#0050#,16)),
        NUNIT   => sys_conf_dmhbpt_nunit)
      port map (
        CLK         => CLK,
        RESET       => RESET,
        RB_MREQ     => RB_MREQ,
        RB_SRES     => RB_SRES_DMHBPT,
        DM_STAT_SE  => DM_STAT_SE,
        DM_STAT_DP  => DM_STAT_DP_L,
        DM_STAT_VM  => DM_STAT_VM,
        DM_STAT_CO  => DM_STAT_CO,
        HBPT        => HBPT
      );
  end generate DMHBPT;

  DMPCNT : if sys_conf_dmpcnt generate
    signal PERFSIG : slv32 := (others=>'0');
  begin
    proc_sig: process (CP_STAT_L, DM_STAT_SE, DM_STAT_DP_L, DM_STAT_DP_L.psw,
                       DM_STAT_CA, RB_MREQ, RB_SRES_L,
                       DM_STAT_VM.ibmreq, DM_STAT_VM.ibsres)
      variable isig : slv32 := (others=>'0');
    begin
      
      isig := (others=>'0');

      if DM_STAT_SE.cpbusy = '1' then
        isig(0)  := '1';                    -- cpu_cpbusy
      elsif CP_STAT_L.cpugo = '1' then
        case DM_STAT_DP_L.psw.cmode is
          when c_psw_kmode =>
            if CP_STAT_L.cpuwait = '1' then
              isig(3) := '1';               -- cpu_km_wait
            elsif unsigned(DM_STAT_DP_L.psw.pri) = 0 then
              isig(2) := '1';               -- cpu_km_pri0
            else
              isig(1) := '1';               -- cpu_km_prix
            end if;
          when c_psw_smode =>
            isig(4) := '1';                 -- cpu_sm
          when c_psw_umode =>
            isig(5) := '1';                 -- cpu_um
          when others => null;
        end case;
      end if;

      isig(6)  := DM_STAT_SE.idec;          -- cpu_idec
      isig(7)  := DM_STAT_SE.pcload;        -- cpu_pcload
      isig(8)  := DM_STAT_SE.vfetch;        -- cpu_vfetch
      isig(9)  := EI_ACKM_L;                -- cpu_irupt (not counting PIRQ!)
      
      isig(10) := DM_STAT_CA.rd;            -- ca_rd
      isig(11) := DM_STAT_CA.wr;            -- ca_wr
      isig(12) := DM_STAT_CA.rdhit;         -- ca_rdhit
      isig(13) := DM_STAT_CA.wrhit;         -- ca_wrhit
      isig(14) := DM_STAT_CA.rdmem;         -- ca_rdmem
      isig(15) := DM_STAT_CA.wrmem;         -- ca_wrmem
      isig(16) := DM_STAT_CA.rdwait;        -- ca_rdwait
      isig(17) := DM_STAT_CA.wrwait;        -- ca_wrwait

      if DM_STAT_VM.ibmreq.aval='1' then
        if DM_STAT_VM. ibsres.busy='0' then
          isig(18) := DM_STAT_VM.ibmreq.re; -- ib_rd
          isig(19) := DM_STAT_VM.ibmreq.we; -- ib_wr
        else
          isig(20) := DM_STAT_VM.ibmreq.re or DM_STAT_VM.ibmreq.we; -- ib_busy
        end if;
      end if;

      -- a hack too, for 1 core systems is addr(15)='0' when CPU addressed
      if RB_MREQ.aval='1' and RB_MREQ.addr(15)='0' then
        if RB_SRES_L.busy='0' then
          isig(21) := RB_MREQ.re;               -- rb_rd
          isig(22) := RB_MREQ.we;               -- rb_wr
        else
          isig(23) := RB_MREQ.re or RB_MREQ.we; -- rb_busy
        end if;
        
      end if;

      isig(24) := '0';                      -- ext_rdrhit
      isig(25) := '0';                      -- ext_wrrhit
      isig(26) := '0';                      -- ext_wrflush
      isig(27) := '0';                      -- ext_rlrdbusy
      isig(28) := '0';                      -- ext_rlrdback
      isig(29) := '0';                      -- ext_rlwrbusy
      isig(30) := '0';                      -- ext_rlwrback
      isig(31) := '1';                      -- usec (now clock)
      
      PERFSIG <= isig;
    end process proc_sig;
      
      
    I0: pdp11_dmpcnt
      generic map (
        RB_ADDR => slv(to_unsigned(16#0060#,16)),  -- rbus address
        VERS    => slv(to_unsigned(1, 8)),         -- counter layout version
                --  33222222222211111111110000000000
                --  10987654321098765432109876543210
        CENA    => "10000000111111111111111111111111") -- counter enables
      port map (
        CLK         => CLK,
        RESET       => RESET,
        RB_MREQ     => RB_MREQ,
        RB_SRES     => RB_SRES_DMPCNT,
        PERFSIG     => PERFSIG
      );
  end generate DMPCNT;
  
  RB_SRES_DMOR : rb_sres_or_4
    port map (
      RB_SRES_1  => RB_SRES_DMSCNT,
      RB_SRES_2  => RB_SRES_DMPCNT,
      RB_SRES_3  => RB_SRES_DMHBPT,
      RB_SRES_4  => RB_SRES_DMCMON,
      RB_SRES_OR => RB_SRES_DM
      );
  
  RB_SRES_OR : rb_sres_or_2
    port map (
      RB_SRES_1  => RB_SRES_CORE,
      RB_SRES_2  => RB_SRES_DM,
      RB_SRES_OR => RB_SRES_L
    );

  RB_SRES    <= RB_SRES_L;          -- setup output signals
  IB_MREQ    <= IB_MREQ_M;
  GRESET     <= GRESET_L;
  CRESET     <= CRESET_L;
  BRESET     <= BRESET_L;
  CP_STAT    <= CP_STAT_L;
  EI_ACKM    <= EI_ACKM_L;
  DM_STAT_DP <= DM_STAT_DP_L;
  
-- synthesis translate_off
  
  TMU : pdp11_tmu_sb
    generic map (
      ENAPIN => sbcntl_sbf_tmu)
    port map (
      CLK        => CLK,
      DM_STAT_DP => DM_STAT_DP_L,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO,
      DM_STAT_CA => DM_STAT_CA
    );
-- synthesis translate_on
  
end syn;
