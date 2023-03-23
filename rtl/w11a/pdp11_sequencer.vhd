-- $Id: pdp11_sequencer.vhd 1384 2023-03-22 07:35:32Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2006-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_sequencer - syn
-- Description:    pdp11: CPU sequencer
--
-- Dependencies:   ib_sel
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4-2022.1; ghdl 0.18-2.0.0
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2023-03-21  1384   1.6.29 BUGFIX: restore PSW after vector push abort
-- 2023-01-11  1349   1.6.28 BUGFIX: handle CPUERR.rsv correctly
-- 2023-01-02  1342   1.6.27 BUGFIX: cc state unchanged after abort
-- 2022-12-26  1337   1.6.26 tbit logic overhaul 2, now fully 11/70 compatible
-- 2022-12-12  1330   1.6.25 implement MMR0,MMR2 instruction complete
-- 2022-12-10  1329   1.6.24 BUGFIX: store correct PS after vector push abort
-- 2022-12-05  1324   1.6.23 tbit logic overhaul; use treq_tbit; cleanups
--                           use resetcnt for 8 cycle RESET wait
-- 2022-11-29  1323   1.6.22 rename adderr -> oddadr, don't set after err_mmu
-- 2022-11-28  1322   1.6.21 BUGFIX: correct mmu trap vs interrupt priority
-- 2022-11-24  1321   1.6.20 BUGFIX: correct mmu trap handing in s_idecode
-- 2022-11-21  1320   1.6.19 rename some rsv->ser and cpustat_type trap_->treq_;
--                           remove vm_cntl_type.trap_done;
--                           BUGFIX: correct ysv flow implementation
-- 2022-11-18  1316   1.6.18 BUGFIX: use is_kstackdst1246 also in dstr flow
-- 2022-10-29  1312   1.6.17 rename s_int_* -> s_vec_*, s_trap_* -> s_abort_*
-- 2022-10-25  1309   1.6.16 rename _gpr -> _gr
-- 2022-10-03  1301   1.6.15 finalize fix for I space mode=1 in s_dstr_def
-- 2022-09-08  1296   1.6.14 BUGFIX: use I space for all mode=1,2,3 if reg=pc
-- 2022-08-13  1279   1.6.13 ssr->mmr rename
-- 2019-08-17  1203   1.6.12 fix for ghdl V0.36 -Whide warnings
-- 2018-10-07  1054   1.6.11 drop ITIMER, use DM_STAT_SE.itimer
-- 2018-10-06  1053   1.6.10 add DM_STAT_SE.(cpbusy,idec,pcload)
-- 2017-04-23   885   1.6.9  not sys_conf_dmscnt: set SNUM from state category;
--                           change waitsusp logic; add WAIT to idm_idone
-- 2016-12-27   831   1.6.8  CPUERR now cleared with creset
-- 2016-10-03   812   1.6.7  always define DM_STAT_SE.snum
-- 2016-05-26   768   1.6.6  don't init N_REGS (vivado fix for fsm inference)
--                           proc_snum conditional (vivado fsm workaround)
-- 2015-08-02   708   1.6.5  BUGFIX: proper trap_mmu and trap_ysv handling
-- 2015-08-01   707   1.6.4  set dm_idone in s_(trap_10|op_trap); add dm_vfetch
-- 2015-07-19   702   1.6.3  add DM_STAT_SE, drop SNUM port
-- 2015-07-10   700   1.6.2  use c_cpurust_hbpt
-- 2015-06-26   695   1.6.1  add SNUM (state number) port
-- 2015-05-10   678   1.6    start/stop/suspend overhaul; reset overhaul
-- 2015-02-07   643   1.5.2  s_op_wait: load R0 in DSRC for DR emulation
-- 2014-07-12   569   1.5.1  rename s_opg_div_zero -> s_opg_div_quit;
--                           use DP_STAT.div_quit; set munit_s_div_sr;
--                           BUGFIX: s_opg_div_sr: check for late div_quit
-- 2014-04-20   554   1.5    now vivado compatible (add dummy assigns in procs)
-- 2011-11-18   427   1.4.2  now numeric_std clean
-- 2010-10-23   335   1.4.1  use ib_sel
-- 2010-10-17   333   1.4    use ibus V2 interface
-- 2010-09-18   300   1.3.2  rename (adlm)box->(oalm)unit
-- 2010-06-20   307   1.3.1  rename cpacc to cacc in vm_cntl_type
-- 2010-06-13   305   1.3    remove CPDIN_WE, CPDOUT_WE out ports; set
--                           CNTL.cpdout_we instead of CPDOUT_WE
-- 2010-06-12   304   1.2.8  signal cpuwait when spinning in s_op_wait
-- 2009-05-30   220   1.2.7  final removal of snoopers (were already commented)
-- 2009-05-09   213   1.2.6  BUGFIX: use is_kstackdst1246, stklim for mode=6
-- 2009-05-02   211   1.2.5  BUGFIX: 11/70 spl semantics again in kernel mode
-- 2009-04-26   209   1.2.4  BUGFIX: give interrupts priority over trap handling
-- 2008-12-14   177   1.2.3  BUGFIX: use is_dstkstack124, fix stklim check bug
-- 2008-12-13   176   1.2.2  BUGFIX: use is_pci in s_dstw_inc if DSTDEF='1'
-- 2008-11-30   174   1.2.1  BUGFIX: add updt_dstadsrc; prevent stale DSRC
-- 2008-08-22   161   1.2    rename ubf_ -> ibf_; use iblib
-- 2008-05-03   143   1.1.9  rename _cpursta->_cpurust; cp reset sets now
--                           c_cpurust_reset; proper c_cpurust_vfail handling
-- 2008-04-27   140   1.1.8  BUGFIX: halt cpu in case of a vector fetch error
--                           use cpursta to encode why cpu halts, remove cpufail
-- 2008-04-27   139   1.1.7  BUGFIX: correct bytop handling for address fetches;
--                           BUGFIX: redo mtp flow; add fork_dsta fork and ddst
--                                   reload in s_opa_mtp_pop_w;
-- 2008-04-19   137   1.1.6  BUGFIX: fix loop state in s_rti_getpc_w
-- 2008-03-30   131   1.1.5  BUGFIX: inc/dec by 2 for byte mode -(sp),(sp)+
--                             inc/dec by 2 for @(R)+ and @-(R) also for bytop's
-- 2008-03-02   121   1.1.4  remove snoopers; add waitsusp, redo WAIT handling
-- 2008-02-24   119   1.1.3  add lah,rps,wps command; revamp cp memory access
--                           change WAIT logic, now also bails out on cp command
-- 2008-01-20   112   1.1.2  rename PRESET->BRESET
-- 2008-01-05   110   1.1.1  rename IB_MREQ(ena->req) SRES(sel->ack, hold->busy)
-- 2007-12-30   107   1.1    use IB_MREQ/IB_SRES interface now
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;
use work.pdp11.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity pdp11_sequencer is               -- CPU sequencer
  port (
    CLK : in slbit;                     -- clock
    GRESET : in slbit;                  -- general reset
    PSW : in psw_type;                  -- processor status
    IREG : in slv16;                    -- IREG
    ID_STAT : in decode_stat_type;      -- instr. decoder status
    DP_STAT : in dpath_stat_type;       -- data path status
    CP_CNTL : in cp_cntl_type;          -- console port control
    VM_STAT : in vm_stat_type;          -- virtual memory status port
    INT_PRI : in slv3;                  -- interrupt priority
    INT_VECT : in slv9_2;               -- interrupt vector
    INT_ACK : out slbit;                -- interrupt acknowledge
    CRESET : out slbit;                 -- cpu reset
    BRESET : out slbit;                 -- bus reset
    MMU_MONI : out mmu_moni_type;       -- mmu monitor port
    DP_CNTL : out dpath_cntl_type;      -- data path control
    VM_CNTL : out vm_cntl_type;         -- virtual memory control port
    CP_STAT : out cp_stat_type;         -- console port status
    ESUSP_O : out slbit;                -- external suspend output
    ESUSP_I : in slbit;                 -- external suspend input
    HBPT : in slbit;                    -- hardware bpt
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response    
    DM_STAT_SE : out dm_stat_se_type    -- debug and monitor status - sequencer
  );
end pdp11_sequencer;

architecture syn of pdp11_sequencer is

  constant ibaddr_cpuerr : slv16 := slv(to_unsigned(8#177766#,16));
  
  constant cpuerr_ibf_illhlt : integer := 7;
  constant cpuerr_ibf_oddadr : integer := 6;
  constant cpuerr_ibf_nxm : integer := 5;
  constant cpuerr_ibf_iobto : integer := 4;
  constant cpuerr_ibf_ysv : integer := 3;
  constant cpuerr_ibf_rsv : integer := 2;

  type state_type is (
    s_idle,
    s_cp_regread,
    s_cp_rps,
    s_cp_memr_w,
    s_cp_memw_w,
    s_ifetch,
    s_ifetch_w,
    s_idecode,

    s_srcr_def,
    s_srcr_def_w,
    s_srcr_inc,
    s_srcr_inc_w,
    s_srcr_dec,
    s_srcr_dec1,
    s_srcr_ind,
    s_srcr_ind1_w,
    s_srcr_ind2,
    s_srcr_ind2_w,

    s_dstr_def,
    s_dstr_def_w,
    s_dstr_inc,
    s_dstr_inc_w,
    s_dstr_dec,
    s_dstr_dec1,
    s_dstr_ind,
    s_dstr_ind1_w,
    s_dstr_ind2,
    s_dstr_ind2_w,

    s_dstw_def,
    s_dstw_def_w,
    s_dstw_inc,
    s_dstw_inc_w,
    s_dstw_incdef_w,
    s_dstw_dec,
    s_dstw_dec1,
    s_dstw_ind,
    s_dstw_ind_w,
    s_dstw_def246,

    s_dsta_inc,
    s_dsta_incdef_w,
    s_dsta_dec,
    s_dsta_dec1,
    s_dsta_ind,
    s_dsta_ind_w,

    s_op_halt,
    s_op_wait,
    s_op_trap,
    s_op_reset,
    s_op_rts,
    s_op_rts_pop,
    s_op_rts_pop_w,
    s_op_spl,
    s_op_mcc,
    s_op_br,
    s_op_mark,
    s_op_mark1,
    s_op_mark_pop,
    s_op_mark_pop_w,
    s_op_sob,
    s_op_sob1,

    s_opg_gen,
    s_opg_gen_rmw_w,
    s_opg_mul,
    s_opg_mul1,
    s_opg_div,
    s_opg_div_cn,
    s_opg_div_cr,
    s_opg_div_sq,
    s_opg_div_sr,
    s_opg_div_quit,
    s_opg_ash,
    s_opg_ash_cn,
    s_opg_ashc,
    s_opg_ashc_cn,
    s_opg_ashc_wl,

    s_opa_jsr,
    s_opa_jsr1,
    s_opa_jsr_push,
    s_opa_jsr_push_w,
    s_opa_jsr2,
    s_opa_jmp,
    s_opa_mtp,
    s_opa_mtp_pop_w,
    s_opa_mtp_reg,
    s_opa_mtp_mem,
    s_opa_mtp_mem_w,
    s_opa_mfp_reg,
    s_opa_mfp_mem,
    s_opa_mfp_mem_w,
    s_opa_mfp_dec,
    s_opa_mfp_push,
    s_opa_mfp_push_w,
    
    s_abort_4,
    s_abort_10,
    s_trap_disp,

    s_int_ext,

    s_vec_getpc,
    s_vec_getpc_w,
    s_vec_getps,
    s_vec_getps_w,
    s_vec_getsp,
    s_vec_decsp,
    s_vec_pushps,
    s_vec_pushps_w,
    s_vec_pushpc,
    s_vec_pushpc_w,

    s_rti_getpc,
    s_rti_getpc_w,
    s_rti_getps,
    s_rti_getps_w,
    s_rti_newpc,
    
    s_vmerr,
    s_cpufail
  );

  signal R_STATE : state_type := s_idle;-- state register
  signal N_STATE : state_type;          -- don't init (vivado fix for fsm infer)

  attribute fsm_encoding : string;
  attribute fsm_encoding of R_STATE : signal is "one_hot";  

  signal R_STATUS : cpustat_type := cpustat_init;
  signal N_STATUS : cpustat_type := cpustat_init;
  signal R_CPUERR : cpuerr_type := cpuerr_init;
  signal N_CPUERR : cpuerr_type := cpuerr_init;

  signal R_IDSTAT : decode_stat_type := decode_stat_init;
  signal N_IDSTAT : decode_stat_type := decode_stat_init;

  signal R_VMSTAT : vm_stat_type := vm_stat_init;

  signal IBSEL_CPUERR : slbit := '0';
  
  signal VM_CNTL_L : vm_cntl_type := vm_cntl_init;

begin

  SEL : ib_sel
    generic map (
      IB_ADDR => ibaddr_cpuerr)
    port map (
      CLK     => CLK,
      IB_MREQ => IB_MREQ,
      SEL     => IBSEL_CPUERR
    );

  proc_ibres : process (IBSEL_CPUERR, IB_MREQ, R_CPUERR)
    variable idout : slv16 := (others=>'0');
  begin
    idout := (others=>'0');
    if IBSEL_CPUERR = '1' then
      idout(cpuerr_ibf_illhlt) := R_CPUERR.illhlt;
      idout(cpuerr_ibf_oddadr) := R_CPUERR.oddadr;
      idout(cpuerr_ibf_nxm)    := R_CPUERR.nxm;
      idout(cpuerr_ibf_iobto)  := R_CPUERR.iobto;
      idout(cpuerr_ibf_ysv)    := R_CPUERR.ysv;
      idout(cpuerr_ibf_rsv)    := R_CPUERR.rsv;
    end if;
    IB_SRES.dout <= idout;
    IB_SRES.ack  <= IBSEL_CPUERR and (IB_MREQ.re or IB_MREQ.we); -- ack all
    IB_SRES.busy <= '0';
  end process proc_ibres;

  proc_status: process (CLK)
  begin
    if rising_edge(CLK) then
      if GRESET = '1' then
        R_STATUS <= cpustat_init;
        R_IDSTAT <= decode_stat_init;
        R_VMSTAT <= vm_stat_init;
      else
        R_STATUS <= N_STATUS;
        R_IDSTAT <= N_IDSTAT;
        R_VMSTAT <= VM_STAT;
      end if;
    end if;
  end process proc_status;

  -- ensure that CPUERR is reset with GRESET and CRESET 
  proc_cpuerr: process (CLK)
  begin
    if rising_edge(CLK) then
      if GRESET = '1' or R_STATUS.creset = '1' then
        R_CPUERR <= cpuerr_init;
      else
        R_CPUERR <= N_CPUERR;
      end if;
    end if;
  end process proc_cpuerr;

  proc_state: process (CLK)
  begin
    if rising_edge(CLK) then
      if GRESET = '1' then
        R_STATE <= s_idle;
      else
        R_STATE <= N_STATE;
      end if;
    end if;
  end process proc_state;

  proc_next: process (R_STATE, R_STATUS, PSW, CP_CNTL,
                      ID_STAT, R_IDSTAT, IREG, VM_STAT, DP_STAT,
                      R_CPUERR, R_VMSTAT, IB_MREQ, IBSEL_CPUERR,
                      INT_PRI, INT_VECT, ESUSP_I, HBPT)
    
    variable nstate : state_type;
    variable nstatus : cpustat_type := cpustat_init;
    variable ncpuerr : cpuerr_type := cpuerr_init;

    variable ndpcntl : dpath_cntl_type := dpath_cntl_init;
    variable nvmcntl : vm_cntl_type := vm_cntl_init;
    variable nidstat : decode_stat_type := decode_stat_init;
    variable nmmumoni : mmu_moni_type := mmu_moni_init;
    
    variable imemok : boolean;
    variable bytop : slbit := '0';           -- local bytop  access flag
    variable macc  : slbit := '0';           -- local modify access flag

    variable lvector : slv9_2 := (others=>'0'); -- local trap/interrupt vector
    
    variable brcode : slv4 := (others=>'0'); -- reduced br opcode (15,10-8)
    variable brcond : slbit := '0';          -- br condition value

    variable is_kmode : slbit := '0';        -- cmode is kernel mode
    variable is_kstackdst1246 : slbit := '0'; -- dest is k-stack & mode= 1,2,4,6

    variable int_pending : slbit := '0';     -- an interrupt is pending

    variable idm_idle   : slbit := '0';      -- idle   for dm_stat_se
    variable idm_cpbusy : slbit := '0';      -- cpbusy for dm_stat_se
    variable idm_idec   : slbit := '0';      -- idec   for dm_stat_se
    variable idm_idone  : slbit := '0';      -- idone  for dm_stat_se
    variable idm_pcload : slbit := '0';      -- pcload for dm_stat_se
    
    alias SRCMOD : slv2 is IREG(11 downto 10); -- src register mode high
    alias SRCDEF : slbit is IREG(9);           -- src register mode defered
    alias SRCREG : slv3 is IREG(8 downto 6);   -- src register number
    alias DSTMODF : slv3 is IREG(5 downto 3);  -- dst register full mode
    alias DSTMOD : slv2 is IREG(5 downto 4);   -- dst register mode high
    alias DSTDEF : slbit is IREG(3);           -- dst register mode defered
    alias DSTREG : slv3 is IREG(2 downto 0);   -- dst register number

    procedure do_memread_i(pnstate  : inout state_type;
                           pndpcntl : inout dpath_cntl_type;
                           pnvmcntl : inout vm_cntl_type;
                           pwstate  : in state_type) is
    begin
      pndpcntl.vmaddr_sel := c_dpath_vmaddr_pc;       -- VA = PC
      pnvmcntl.dspace := '0';
      pnvmcntl.req := '1';
      pndpcntl.gr_pcinc := '1';                       -- (pc)++
      pnstate := pwstate;
    end procedure do_memread_i;
    
    procedure do_memread_d(pnstate  : inout state_type;
                           pnvmcntl : inout vm_cntl_type;
                           pwstate  : in state_type;
                           pbytop   : in slbit := '0';
                           pmacc    : in slbit := '0';
                           pispace  : in slbit := '0';
                           pkstack  : in slbit := '0') is
    begin
      pnvmcntl.dspace := not pispace;
      pnvmcntl.bytop  := pbytop;
      pnvmcntl.macc   := pmacc;
      pnvmcntl.kstack := pkstack;
      pnvmcntl.req    := '1';
      pnstate := pwstate;
    end procedure do_memread_d;
    
    procedure do_memread_srcinc(pnstate   : inout state_type;
                                pndpcntl  : inout dpath_cntl_type;
                                pnvmcntl  : inout vm_cntl_type;
                                pwstate   : in state_type;
                                pnmmumoni : inout mmu_moni_type;
                                pupdt_sp  : in slbit := '0') is
    begin
      pndpcntl.ounit_asel := c_ounit_asel_dsrc;   -- OUNIT A=DSRC
      pndpcntl.ounit_const := "000000010";        -- OUNIT const=2
      pndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const
      pndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
      pndpcntl.dsrc_sel := c_dpath_dsrc_res;      -- DSRC = DRES
      pndpcntl.dsrc_we := '1';                    -- update DSRC
      if pupdt_sp = '1' then
        pnmmumoni.regmod := '1';
        pnmmumoni.isdec := '0';
        pndpcntl.gr_adst := c_gr_sp;              -- update SP too
        pndpcntl.gr_we := '1';
      end if;
      pndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
      pnvmcntl.dspace := '1';
      pnvmcntl.req := '1';
      pnstate := pwstate;
    end procedure do_memread_srcinc;
    
    procedure do_memwrite(pnstate  : inout state_type;
                          pnvmcntl : inout vm_cntl_type;
                          pwstate  : in state_type;
                          pmacc    : in slbit :='0';
                          pispace  : in slbit := '0') is
    begin
      pnvmcntl.dspace := not pispace;
      pnvmcntl.bytop := R_IDSTAT.is_bytop;
      pnvmcntl.wacc := '1';
      pnvmcntl.macc := pmacc;
      pnvmcntl.req := '1';
      pnstate := pwstate;
    end procedure do_memwrite;
    
    procedure do_memcheck(pnstate  : inout state_type;
                          pnstatus : inout cpustat_type;
                          pmok     : out boolean) is
    begin
      pnstate  := pnstate;              -- dummy to add driver (vivado)
      pnstatus := pnstatus;             -- "
      pmok := false;
      if VM_STAT.ack = '1' then
        pmok := true;
        if VM_STAT.trap_mmu = '1' then  -- remember trap_mmu, may happen on any
          pnstatus.treq_mmu := '1';       --   memory access of an instruction
        end if;
        if VM_STAT.trap_ysv = '1' then  -- remember trap_ysv (on final writes)
          if R_STATUS.in_vecysv = '0' then  -- trap when not in ysv vector flow
            pnstatus.treq_ysv := '1';
          end if;
        end if;
      elsif VM_STAT.err='1' or VM_STAT.fail='1' then
        pnstate := s_vmerr;
      end if;
    end procedure do_memcheck;

    procedure do_const_opsize(pndpcntl : inout dpath_cntl_type;
                              pbytop   : in slbit;
                              pisdef   : in slbit;
                              pregnum  : in slv3) is
    begin
      pndpcntl := pndpcntl;             -- dummy to add driver (vivado)
      if pbytop='0' or pisdef='1' or
         pregnum=c_gr_pc or pregnum=c_gr_sp then
        pndpcntl.ounit_const := "000000010";
      else
        pndpcntl.ounit_const := "000000001";
      end if;
    end procedure do_const_opsize;

    procedure do_fork_dstr(pnstate : inout state_type;
                           pidstat : in decode_stat_type) is
    begin
      case pidstat.fork_dstr is
        when c_fork_dstr_def => pnstate := s_dstr_def;
        when c_fork_dstr_inc => pnstate := s_dstr_inc;
        when c_fork_dstr_dec => pnstate := s_dstr_dec;
        when c_fork_dstr_ind => pnstate := s_dstr_ind;
        when others => pnstate := s_cpufail;
      end case;
    end procedure do_fork_dstr;

    procedure do_fork_opg(pnstate : inout state_type;
                          pidstat : in decode_stat_type) is
    begin
      case pidstat.fork_opg is
        when c_fork_opg_gen  => pnstate := s_opg_gen;
        when c_fork_opg_wdef => pnstate := s_dstw_def;
        when c_fork_opg_winc => pnstate := s_dstw_inc;
        when c_fork_opg_wdec => pnstate := s_dstw_dec;
        when c_fork_opg_wind => pnstate := s_dstw_ind;
        when c_fork_opg_mul  => pnstate := s_opg_mul;
        when c_fork_opg_div  => pnstate := s_opg_div;
        when c_fork_opg_ash  => pnstate := s_opg_ash;
        when c_fork_opg_ashc => pnstate := s_opg_ashc;
        when others => pnstate := s_cpufail;
      end case;
    end procedure do_fork_opg;

    procedure do_fork_opa(pnstate : inout state_type;
                          pidstat : in decode_stat_type) is
    begin
      case pidstat.fork_opa is
        when c_fork_opa_jmp => pnstate := s_opa_jmp;
        when c_fork_opa_jsr => pnstate := s_opa_jsr;
        when c_fork_opa_mtp => pnstate := s_opa_mtp_mem;
        when c_fork_opa_mfp_reg => pnstate := s_opa_mfp_reg;
        when c_fork_opa_mfp_mem => pnstate := s_opa_mfp_mem;
        when others => pnstate := s_cpufail;
      end case;
    end procedure do_fork_opa;

    procedure do_fork_next(pnstate   : inout state_type;
                           pnstatus  : inout cpustat_type;
                           pnmmumoni : inout mmu_moni_type) is
    begin
                                                        -- priority order
      if pnstatus.treq_mmu='1' or                       -- mmu trap
           pnstatus.treq_ysv='1' then                   -- ysv trap
        pnstate := s_trap_disp;
      elsif unsigned(INT_PRI) > unsigned(PSW.pri) then  -- interrupts
        pnstate := s_idle;
      elsif pnstatus.treq_tbit='1' then                 -- tbit trap
        pnstate := s_trap_disp;
      elsif R_STATUS.cpugo='1' and        -- running
            R_STATUS.cpususp='0' and      --   and not suspended
            not R_STATUS.cmdbusy='1' then --   and no cmd pending
        pnstate := s_ifetch;                -- fetch next
      else
        pnstate := s_idle;                  -- otherwise idle
      end if;
    end procedure do_fork_next;
    
    procedure do_fork_next_pref(pnstate   : inout state_type;
                                pnstatus  : inout cpustat_type;
                                pndpcntl  : inout dpath_cntl_type;
                                pnvmcntl  : inout vm_cntl_type;
                                pnmmumoni : inout mmu_moni_type) is
    begin
      pndpcntl := pndpcntl;             -- dummy to add driver (vivado)
      pnvmcntl := pnvmcntl;             -- "
                                                        -- priority order
      if pnstatus.treq_mmu='1' or                       -- mmu trap
            pnstatus.treq_ysv='1' then                  -- ysv trap
        pnstate := s_trap_disp;
      elsif unsigned(INT_PRI) > unsigned(PSW.pri) then  -- interrupts
        pnstate := s_idle;
      elsif pnstatus.treq_tbit='1' then                 -- tbit trap
        pnstate := s_trap_disp;
      elsif R_STATUS.cpugo='1' and       -- running
            R_STATUS.cpususp='0' and      --   and not suspended
            not R_STATUS.cmdbusy='1' then --   and no cmd pending
        pnvmcntl.req := '1';                -- read next instruction
        pndpcntl.gr_pcinc := '1' ;          -- inc PC
        pnmmumoni.istart := '1';            -- signal istart to MMU
        pnstate := s_ifetch_w;              -- next: wait for fetched instruction
      else
        pnstate := s_idle;                  -- otherwise idle
      end if;
    end procedure do_fork_next_pref;
    
    procedure do_start_vec(pnstate  : inout state_type;
                           pndpcntl : inout dpath_cntl_type;
                           pvector  : in slv9_2) is
    begin
      pndpcntl.dtmp_sel := c_dpath_dtmp_psw;    -- DTMP = PSW 
      pndpcntl.dtmp_we := '1';                  -- save PS
      pndpcntl.ounit_azero := '1';              -- OUNIT A = 0
      pndpcntl.ounit_const := pvector & "00";   -- vector
      pndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const(vector)
      pndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
      pndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
      pndpcntl.dsrc_we := '1';                  -- DSRC = vector
      pnstate := s_vec_getpc;
    end procedure do_start_vec;
    
  begin
    
    nstate  := R_STATE;
    nstatus := R_STATUS;
    ncpuerr := R_CPUERR;

    nstatus.cpuwait := '0';             -- wait flag 0 unless set in s_op_wait

    -- itimer pulse logic:
    --   if neither running nor suspended --> free run, set itimer = 1
    --   otherwise clear to ensure single cycle pulses generated by
    --   s_idecode or s_op_wait
    if R_STATUS.cpugo='0' and R_STATUS.cpususp='0' then
      nstatus.itimer := '1';            
    else
      nstatus.itimer := '0';
    end if;
    
    nstatus.creset := '0';              -- ensure single cycle pulse
    nstatus.breset := '0';              -- dito
    nstatus.intack := '0';              -- dito
    
    nidstat := R_IDSTAT;

    if IBSEL_CPUERR='1' and IB_MREQ.we='1' then -- write to CPUERR clears it !
      ncpuerr := cpuerr_init;
    end if;

    int_pending := '0';
    if unsigned(INT_PRI) > unsigned(PSW.pri) then
      int_pending := '1';
    end if;
    nstatus.intpend := int_pending;

    idm_idle   := '0';
    idm_cpbusy := '0';
    idm_idec   := '0';
    idm_idone  := '0';
    idm_pcload := '0';
    
    imemok := false;

    nmmumoni := mmu_moni_init;
    nmmumoni.vflow := R_STATUS.in_vecflow;
    
    macc  := '0';
    bytop := '0';
    brcode := IREG(15) & IREG(10 downto 8);
    brcond := '1';

    is_kmode := '0';
    is_kstackdst1246 := '0';
    
    if PSW.cmode = c_psw_kmode then
      is_kmode := '1';
      if DSTREG = c_gr_sp and
         (DSTMODF="001" or DSTMODF="010" or
          DSTMODF="100" or DSTMODF="110") then
        is_kstackdst1246 := '1';
      end if;      
    end if;
      
    lvector := (others=>'0');
    
    nvmcntl := vm_cntl_init;
    nvmcntl.dspace := '1';                -- DEFAULT
    nvmcntl.mode := PSW.cmode;            -- DEFAULT
    nvmcntl.vecser := R_STATUS.in_vecser; -- DEFAULT
    
    ndpcntl := dpath_cntl_init;
    ndpcntl.gr_asrc := SRCREG;            -- DEFAULT
    ndpcntl.gr_adst := DSTREG;            -- DEFAULT
    ndpcntl.gr_mode := PSW.cmode;         -- DEFAULT
    ndpcntl.gr_rset := PSW.rset;          -- DEFAULT
    ndpcntl.gr_we := '0';                 -- DEFAULT
    ndpcntl.gr_bytop := '0';              -- DEFAULT
    ndpcntl.gr_pcinc := '0';              -- DEFAULT

    ndpcntl.psr_ccwe := '0';              -- DEFAULT
    ndpcntl.psr_we := '0';                -- DEFAULT
    ndpcntl.psr_func := "000";            -- DEFAULT

    ndpcntl.dsrc_sel := c_dpath_dsrc_src;
    ndpcntl.dsrc_we := '0';
    ndpcntl.ddst_sel := c_dpath_ddst_dst;
    ndpcntl.ddst_we := '0';
    ndpcntl.dtmp_sel := c_dpath_dtmp_dsrc;
    ndpcntl.dtmp_we := '0';

    ndpcntl.ounit_asel  := c_ounit_asel_ddst;
    ndpcntl.ounit_azero := '0';            -- DEFAULT
    ndpcntl.ounit_const := (others=>'0');  -- DEFAULT
    ndpcntl.ounit_bsel  := c_ounit_bsel_const;
    ndpcntl.ounit_opsub := '0';            -- DEFAULT

    ndpcntl.aunit_srcmod := R_IDSTAT.aunit_srcmod; -- STATIC
    ndpcntl.aunit_dstmod := R_IDSTAT.aunit_dstmod; -- STATIC
    ndpcntl.aunit_cimod  := R_IDSTAT.aunit_cimod;  -- STATIC
    ndpcntl.aunit_cc1op  := R_IDSTAT.aunit_cc1op;  -- STATIC
    ndpcntl.aunit_ccmode := R_IDSTAT.aunit_ccmode; -- STATIC
    ndpcntl.aunit_bytop  := R_IDSTAT.is_bytop;     -- STATIC

    ndpcntl.lunit_func   := R_IDSTAT.lunit_func;   -- STATIC
    ndpcntl.lunit_bytop  := R_IDSTAT.is_bytop;     -- STATIC

    ndpcntl.munit_func := R_IDSTAT.munit_func;     -- STATIC

    ndpcntl.ireg_we := '0';

    ndpcntl.cres_sel := R_IDSTAT.res_sel;        -- DEFAULT
    ndpcntl.dres_sel := c_dpath_res_ounit;
    ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc;

    if CP_CNTL.req='1' and R_STATUS.cmdbusy='0' then
      nstatus.cmdbusy := '1';
      nstatus.cpfunc  := CP_CNTL.func;
      nstatus.cprnum  := CP_CNTL.rnum;
    end if;
    
    if R_STATUS.cmdack = '1' then
      nstatus.cmdack  := '0';
      nstatus.cmderr  := '0';
      nstatus.cmdmerr := '0';
    end if;
    
    case R_STATE is
      
  -- idle and command port states ---------------------------------------------
      
      when s_idle =>                    -- ------------------------------------
        -- Note: s_idle was entered from suspended WAIT when waitsusp='1'
        -- --> all exits must check this and either return to s_op_wait
        --     or abort the WAIT and set waitsusp='0'

        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst;   -- VA = DDST (do mux early)
        nstatus.cpustep := '0';
        idm_idle := '1';                        -- signal sequencer idle
        
        if R_STATUS.cmdbusy = '1' then
          idm_cpbusy := '1';                    -- signal cp busy
          case R_STATUS.cpfunc is

            when c_cpfunc_noop =>       -- noop : no operation -------
              nstatus.cmdack   := '1';
              nstate := s_idle;                  

            when c_cpfunc_start =>      -- start : cpu start ---------
              nstatus.cmdack   := '1';
              if R_STATUS.cpugo = '1' then -- if already running
                nstatus.cmderr := '1';       -- reject
              else                         -- if not running
                nstatus.cpugo    := '1';     -- start cpu
                nstatus.cpurust  := c_cpurust_runs;
                nstatus.waitsusp := '0';
              end if;
              nstate := s_idle;                  

            when c_cpfunc_stop =>       -- stop : cpu stop -----------
              nstatus.cmdack   := '1';
              nstatus.cpugo    := '0';
              nstatus.cpurust  := c_cpurust_stop;
              nstatus.waitsusp := '0';
              nstate := s_idle;                  

            when c_cpfunc_step =>       -- step : cpu step -----------
              nstatus.cmdack   := '1';
              nstatus.cpustep  := '1';
              nstatus.cpurust  := c_cpurust_step;
              nstatus.waitsusp := '0';
              if int_pending = '1' then
                nstatus.intack  := '1';
                nstatus.intvect := INT_VECT;
                nstate := s_int_ext;
              else
                nstate := s_ifetch;
              end if;

            when c_cpfunc_creset =>     -- creset : cpu reset --------
              nstatus.cmdack   := '1';
              if R_STATUS.cpugo = '1' then -- if already running
                nstatus.cmderr := '1';       -- reject
              else                         -- if not running
                nstatus.creset    := '1';     --  do cpu reset
                nstatus.breset    := '1';     -- and bus reset !
                nstatus.suspint   := '0';     -- clear suspend
                nstatus.treq_mmu  := '0';     -- cancel trap requests
                nstatus.treq_ysv  := '0';
                nstatus.treq_tbit := '0';
                nstatus.in_vecflow := '0';    -- cancel in_* flags
                nstatus.in_vecser  := '0';
                nstatus.in_vecysv  := '0';
                nstatus.cpurust := c_cpurust_init;
              end if;
              nstate := s_idle;                  

            when c_cpfunc_breset =>     -- breset : bus reset --------
              nstatus.cmdack   := '1';
              if R_STATUS.cpugo = '1' then -- if already running
                nstatus.cmderr := '1';       -- reject
              else                         -- if not running
                nstatus.breset := '1';        -- do bus reset only
              end if;
              nstate := s_idle;                  

            when c_cpfunc_suspend =>    -- suspend : cpu suspend -----
              nstatus.cmdack   := '1';
              nstatus.suspint  := '1';
              nstatus.cpurust  := c_cpurust_susp;
              nstate := s_idle;                  

            when c_cpfunc_resume =>     -- resume : cpu resume -------
              nstatus.cmdack   := '1';
              nstatus.suspint  := '0';
              if R_STATUS.cpugo = '1' then
                nstatus.cpurust  := c_cpurust_runs;
              else
                nstatus.cpurust  := c_cpurust_stop;
              end if;  
              nstate := s_idle;                  

            when c_cpfunc_rreg =>       -- rreg : read register ------
              ndpcntl.gr_adst := R_STATUS.cprnum;
              ndpcntl.ddst_sel := c_dpath_ddst_dst;
              ndpcntl.ddst_we := '1';
              nstate := s_cp_regread;

            when c_cpfunc_wreg =>       -- wreg : write register -----
              ndpcntl.dres_sel := c_dpath_res_cpdin;  -- DRES = CPDIN
              ndpcntl.gr_adst := R_STATUS.cprnum;
              ndpcntl.gr_we := '1';
              nstatus.cmdack := '1';
              nstate := s_idle;

            when c_cpfunc_rpsw =>       -- rpsw : read psw -----------
              ndpcntl.dtmp_sel := c_dpath_dtmp_psw;   -- DTMP = PSW 
              ndpcntl.dtmp_we := '1';
              nstate := s_cp_rps;

            when c_cpfunc_wpsw =>       -- wpsw : write psw ----------
              ndpcntl.dres_sel := c_dpath_res_cpdin;  -- DRES = CPDIN
              ndpcntl.psr_func := c_psr_func_wall;    -- write all fields
              ndpcntl.psr_we := '1';                  -- load new PS
              nstatus.cmdack := '1';
              nstate := s_idle;

            when c_cpfunc_rmem =>       -- rmem : read memory --------
              nvmcntl.cacc := '1';
              nvmcntl.req  := '1';
              nstate := s_cp_memr_w;
              
            when c_cpfunc_wmem =>       -- wmem : write memory -------
              ndpcntl.dres_sel := c_dpath_res_cpdin;     -- DRES = CPDIN
              nvmcntl.wacc := '1';                       -- write mem
              nvmcntl.cacc := '1';
              nvmcntl.req  := '1';
              nstate := s_cp_memw_w;

            when others => 
              nstatus.cmdack := '1';
              nstatus.cmderr := '1';
              nstate := s_idle;

          end case;

        elsif R_STATUS.waitsusp = '1' then
          nstate := s_op_wait;            --waitsusp is cleared in s_op_wait

        elsif R_STATUS.cpugo = '1' and    -- running
               R_STATUS.cpususp='0' then   --   and not suspended
                                           -- proceed in priority order
          if R_STATUS.treq_mmu='1' and         -- mmu trap
              R_STATUS.treq_ysv='1' then       -- ysv trap
            nstate := s_trap_disp;
          elsif R_STATUS.intpend = '1' then    -- interrupts
            nstatus.intack  := '1';              -- acknowledle it
            nstatus.intvect := INT_VECT;         -- latch vector address
            nstate := s_int_ext;                 -- and handle
          elsif R_STATUS.treq_tbit = '1' then  -- tbit trap
            nstate := s_trap_disp;
          else
            nstate := s_ifetch;                -- otherwise fetch intruction
          end if;
        end if;

      when s_cp_regread =>              -- -----------------------------------
        idm_cpbusy := '1';                        -- signal cp busy
        ndpcntl.ounit_asel := c_ounit_asel_ddst;  -- OUNIT A = DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B = const(0)
        ndpcntl.dres_sel  := c_dpath_res_ounit;   -- DRES = OUNIT
        nstatus.cmdack := '1';
        nstate := s_idle;
        
      when s_cp_rps =>                  -- -----------------------------------
        idm_cpbusy := '1';                        -- signal cp busy
        ndpcntl.ounit_asel := c_ounit_asel_dtmp;  -- OUNIT A = DTMP
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B = const(0)
        ndpcntl.dres_sel  := c_dpath_res_ounit;   -- DRES = OUNIT
        nstatus.cmdack := '1';
        nstate := s_idle;

      when s_cp_memr_w =>               -- -----------------------------------
        idm_cpbusy := '1';                       -- signal cp busy
        nstate := s_cp_memr_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        if (VM_STAT.ack or VM_STAT.err or VM_STAT.fail)='1' then
          nstatus.cmdack   := '1';
          nstatus.cmdmerr  := VM_STAT.err or VM_STAT.fail;
          nstate := s_idle;
        end if;

      when s_cp_memw_w =>               -- -----------------------------------
        idm_cpbusy := '1';                       -- signal cp busy
        nstate := s_cp_memw_w;
        if (VM_STAT.ack or VM_STAT.err or VM_STAT.fail)='1' then
          nstatus.cmdack   := '1';
          nstatus.cmdmerr  := VM_STAT.err or VM_STAT.fail;
          nstate := s_idle;
        end if;
        
  -- instruction fetch and decode ---------------------------------------------

      when s_ifetch =>                  -- -----------------------------------
        nmmumoni.istart := '1';         -- do here; memread_i inc PC ! 
        do_memread_i(nstate, ndpcntl, nvmcntl, s_ifetch_w);
        
      when s_ifetch_w =>                -- -----------------------------------
        nstate := s_ifetch_w;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ireg_we := '1';
          nstate := s_idecode;
        end if;
        
      when s_idecode =>                 -- -----------------------------------
        idm_idec := '1';                -- signal instruction started
        nstatus.itimer := '1';          -- itimer counts each decode
        nidstat := ID_STAT;             -- register decode status
        if ID_STAT.force_srcsp = '1' then
          ndpcntl.gr_asrc := c_gr_sp;
        end if;
        ndpcntl.dsrc_sel := c_dpath_dsrc_src;
        ndpcntl.dsrc_we := '1';
        ndpcntl.ddst_sel := c_dpath_ddst_dst;
        ndpcntl.ddst_we := '1';

        nvmcntl.dspace := '0';
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_pc;       -- VA = PC

        nstatus.resetcnt := "111";      -- set RESET wait timer

        nstatus.treq_tbit := PSW.tflag; -- copy PSW.tflag to treq_bit
        if PSW.tflag = '0' then         -- if PSW tbit clear consider prefetch
          -- The prefetch decision path can be critical (and was on s3). It uses
          -- R_STATUS.intpend instead of int_pending, using the status latched
          -- at the previous state is OK. It uses R_STATUS.treq_mmu because
          -- no MMU trap can occur during this state (only in *_w states).
          -- It does not check treq_ysv because pipelined instructions can't
          -- trigger ysv traps, in contrast to MMU traps.
          if ID_STAT.do_pref_dec='1' and          -- prefetch possible
            R_STATUS.intpend='0' and              -- no interrupts
            R_STATUS.treq_mmu='0' and             -- no MMU trap request
            R_STATUS.cpugo='1' and                -- CPU on go
            R_STATUS.cpususp='0' and              -- CPU not suspended
            not R_STATUS.cmdbusy='1'              -- and no command pending
          then                                    -- then go for prefetch
            nvmcntl.req := '1';
            ndpcntl.gr_pcinc := '1';                     -- (pc)++
            nmmumoni.istart := '1';
            nstatus.prefdone := '1';
          end if;
        end if;
        
        if ID_STAT.do_fork_op = '1' then
          case ID_STAT.fork_op is
            when c_fork_op_halt => nstate := s_op_halt;
            when c_fork_op_wait => nstate := s_op_wait;
            when c_fork_op_rtti => nstate := s_rti_getpc;
            when c_fork_op_trap => nstate := s_op_trap;
            when c_fork_op_reset=> nstate := s_op_reset;
            when c_fork_op_rts  => nstate := s_op_rts;
            when c_fork_op_spl  => nstate := s_op_spl;
            when c_fork_op_mcc  => nstate := s_op_mcc;
            when c_fork_op_br   => nstate := s_op_br;
            when c_fork_op_mark => nstate := s_op_mark;
            when c_fork_op_sob  => nstate := s_op_sob;
            when c_fork_op_mtp  => nstate := s_opa_mtp;
            when others => nstate := s_cpufail;
          end case;
        elsif ID_STAT.do_fork_srcr = '1' then
          case ID_STAT.fork_srcr is
            when c_fork_srcr_def => nstate := s_srcr_def;
            when c_fork_srcr_inc => nstate := s_srcr_inc;
            when c_fork_srcr_dec => nstate := s_srcr_dec;
            when c_fork_srcr_ind => nstate := s_srcr_ind;
            when others => nstate := s_cpufail;
          end case;
        elsif ID_STAT.do_fork_dstr = '1' then
          do_fork_dstr(nstate, ID_STAT);
        elsif ID_STAT.do_fork_dsta = '1' then
          case ID_STAT.fork_dsta is         -- 2nd dsta fork in s_opa_mtp_pop_w
            when c_fork_dsta_def => do_fork_opa(nstate, ID_STAT);
            when c_fork_dsta_inc => nstate := s_dsta_inc;
            when c_fork_dsta_dec => nstate := s_dsta_dec;
            when c_fork_dsta_ind => nstate := s_dsta_ind;
            when others => nstate := s_cpufail;
          end case;
        elsif ID_STAT.do_fork_opg = '1' then
          do_fork_opg(nstate, ID_STAT);
        elsif ID_STAT.is_res = '1' then
          nstate := s_abort_10;          -- do vector 10 abort;
        else
          nstate := s_cpufail;           -- catch mistakes here...
        end if;

  -- source read states -------------------------------------------------------
  --   flows:
  --     1  (r)    s_srcr_def           req (r)
  --               s_srcr_def_w         get (r)
  --               -> do_fork_dstr or do_fork_opg
  --              
  --     2  (r)+   s_srcr_inc           req (r); r+=s
  --               s_srcr_inc_w         get (r)
  --               -> do_fork_dstr or do_fork_opg
  --
  --     3  @(r)+  s_srcr_inc           req (r); r+=s
  --               s_srcr_inc_w         get (r)
  --               s_srcr_def           req @(r)
  --               s_srcr_def_w         get @(r)
  --               -> do_fork_dstr or do_fork_opg
  --
  --     4  -(r)   s_srcr_dec           r-=s
  --               s_srcr_dec1          req (r)
  --               s_srcr_inc_w         get (r)
  --               -> do_fork_dstr or do_fork_opg
  --
  --     5  @-(r)  s_srcr_dec           r-=s
  --               s_srcr_dec1          req (r)
  --               s_srcr_inc_w         get (r)
  --               s_srcr_def           req @(r)
  --               s_srcr_def_w         get @(r)
  --               -> do_fork_dstr or do_fork_opg
  --
  --     6  n(r)   s_srcr_ind           req n
  --               s_srcr_ind1_w        get n; ea=r+n
  --               s_srcr_ind2          req n(r)
  --               s_srcr_ind2_w        get n(r)
  --               -> do_fork_dstr or do_fork_opg
  --
  --     7  @n(r)  s_srcr_ind           req n
  --               s_srcr_ind1_w        get n; ea=r+n
  --               s_srcr_ind2          req n(r)
  --               s_srcr_ind2_w        get n(r)
  --               s_srcr_def           req @n(r)
  --               s_srcr_def_w         get @n(r)
  --               -> do_fork_dstr or do_fork_opg
        
      when s_srcr_def =>                -- -----------------------------------
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        do_memread_d(nstate, nvmcntl, s_srcr_def_w,
                     pbytop=>R_IDSTAT.is_bytop,
                     pispace=>R_IDSTAT.is_srcpcmode1);

      when s_srcr_def_w =>              -- -----------------------------------
        nstate := s_srcr_def_w;
        do_memcheck(nstate, nstatus, imemok);
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        if imemok then
          ndpcntl.dsrc_we := '1';                -- update DSRC
          if R_IDSTAT.do_fork_dstr = '1' then
            do_fork_dstr(nstate, R_IDSTAT);
          else
            do_fork_opg(nstate, R_IDSTAT);
          end if;
        end if;

      when s_srcr_inc =>                -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_dsrc;  -- OUNIT A=DSRC
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, SRCDEF, SRCREG);
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.gr_adst := SRCREG;
        ndpcntl.gr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '0';
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES (for if)
        if DSTREG = SRCREG then                  -- prevent stale DDST copy 
          ndpcntl.ddst_we := '1';                -- update DDST
        end if;
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        bytop := R_IDSTAT.is_bytop and not SRCDEF;
        do_memread_d(nstate, nvmcntl, s_srcr_inc_w,
                     pbytop=>bytop, pispace=>R_IDSTAT.is_srcpc);
        
      when s_srcr_inc_w =>              -- -----------------------------------
        nstate := s_srcr_inc_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.dsrc_we := '1';                -- update DSRC
          if SRCDEF = '1' then
            nstate := s_srcr_def;
          else
            if R_IDSTAT.do_fork_dstr = '1' then
              do_fork_dstr(nstate, R_IDSTAT);
            else
              do_fork_opg(nstate, R_IDSTAT);
            end if;
          end if;
        end if;
        
      when s_srcr_dec =>                -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_dsrc; -- OUNIT A=DSRC
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, SRCDEF, SRCREG);
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        ndpcntl.dsrc_we := '1';                  -- update DSRC
        ndpcntl.gr_adst := SRCREG;
        ndpcntl.gr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '1';
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES (for if)
        if DSTREG = SRCREG then                  -- prevent stale DDST copy
          ndpcntl.ddst_we := '1';                -- update DDST
        end if;
        nstate := s_srcr_dec1;

      when s_srcr_dec1 =>               -- -----------------------------------
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        bytop := R_IDSTAT.is_bytop and not SRCDEF;
        do_memread_d(nstate, nvmcntl, s_srcr_inc_w, pbytop=>bytop);

      when s_srcr_ind =>                -- -----------------------------------
        do_memread_i(nstate, ndpcntl, nvmcntl, s_srcr_ind1_w);

      when s_srcr_ind1_w =>             -- -----------------------------------
        nstate := s_srcr_ind1_w;
        if R_IDSTAT.is_srcpc = '0' then
          ndpcntl.ounit_asel := c_ounit_asel_dsrc; -- OUNIT A = DSRC
        else
          ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC (for nn(pc))
        end if;
        ndpcntl.ounit_bsel := c_ounit_bsel_vmdout; -- OUNIT B = VMDOUT
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        ndpcntl.ddst_sel := c_dpath_ddst_dst;    -- DDST = R(DST)
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.dsrc_we := '1';                -- update DSRC
          ndpcntl.ddst_we := '1';                -- update DDST (to reload PC)
          nstate := s_srcr_ind2;
        end if;

      when s_srcr_ind2 =>               -- -----------------------------------
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        bytop := R_IDSTAT.is_bytop and not SRCDEF;
        do_memread_d(nstate, nvmcntl, s_srcr_ind2_w, pbytop=>bytop);

      when s_srcr_ind2_w =>             -- -----------------------------------
        nstate := s_srcr_ind2_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.dsrc_we := '1';                -- update DSRC
          if SRCDEF = '1' then
            nstate := s_srcr_def;
          else
            if R_IDSTAT.do_fork_dstr = '1' then
              do_fork_dstr(nstate, R_IDSTAT);
            else
              do_fork_opg(nstate, R_IDSTAT);
            end if;
          end if;
        end if;
        
  -- destination read states --------------------------------------------------
  --   flows:
  --     1  (r)    s_dstr_def           req (r) (rmw if rmw op)
  --               s_dstr_def_w         get (r)
  --               -> do_fork_opg
  --              
  --     2  (r)+   s_dstr_inc           req (r); r+=s (rmw if rmw op)
  --               s_dstr_inc_w         get (r)
  --               -> do_fork_opg
  --
  --     3  @(r)+  s_dstr_inc           req (r); r+=s
  --               s_dstr_inc_w         get (r)
  --               s_dstr_def           req @(r) (rmw if rmw op)
  --               s_dstr_def_w         get @(r)
  --               -> do_fork_opg
  --
  --     4  -(r)   s_dstr_dec           r-=s
  --               s_dstr_dec1          req (r) (rmw if rmw op)
  --               s_dstr_inc_w         get (r)
  --               -> do_fork_opg
  --
  --     5  @-(r)  s_dstr_dec           r-=s
  --               s_dstr_dec1          req (r)
  --               s_dstr_inc_w         get (r)
  --               s_dstr_def           req @(r) (rmw if rmw op)
  --               s_dstr_def_w         get @(r)
  --               -> do_fork_opg
  --
  --     6  n(r)   s_dstr_ind           req n
  --               s_dstr_ind1_w        get n; ea=r+n
  --               s_dstr_ind2          req n(r) (rmw if rmw op)
  --               s_dstr_ind2_w        get n(r)
  --               -> do_fork_opg
  --
  --     7  @n(r)  s_dstr_ind           req n
  --               s_dstr_ind1_w        get n; ea=r+n
  --               s_dstr_ind2          req n(r)
  --               s_dstr_ind2_w        get n(r)
  --               s_dstr_def           req @n(r) (rmw if rmw op)
  --               s_dstr_def_w         get @n(r)
  --               -> do_fork_opg

      when s_dstr_def =>                -- -----------------------------------
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        do_memread_d(nstate, nvmcntl, s_dstr_def_w,
                     pbytop=>R_IDSTAT.is_bytop, pmacc=>R_IDSTAT.is_rmwop,
                     pispace=>R_IDSTAT.is_dstpcmode1,
                     pkstack=>is_kstackdst1246 and R_IDSTAT.is_rmwop);

      when s_dstr_def_w =>              -- -----------------------------------
        nstate := s_dstr_def_w;
        do_memcheck(nstate, nstatus, imemok);
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          do_fork_opg(nstate, R_IDSTAT);
        end if;

      when s_dstr_inc =>                -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A=DDST
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, DSTDEF, DSTREG);
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.gr_adst := DSTREG;
        ndpcntl.gr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '0';
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        macc  := R_IDSTAT.is_rmwop and not DSTDEF;
        bytop := R_IDSTAT.is_bytop and not DSTDEF;
        do_memread_d(nstate, nvmcntl, s_dstr_inc_w,
                     pbytop=>bytop, pmacc=>macc, pispace=>R_IDSTAT.is_dstpc,
                     pkstack=>is_kstackdst1246 and R_IDSTAT.is_rmwop);
        
      when s_dstr_inc_w =>              -- -----------------------------------
        nstate := s_dstr_inc_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          if DSTDEF = '1' then
            nstate := s_dstr_def;
          else
            do_fork_opg(nstate, R_IDSTAT);
          end if;
        end if;
        
      when s_dstr_dec =>                -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A=DDST
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, DSTDEF, DSTREG);
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        ndpcntl.ddst_we := '1';                  -- update DDST
        ndpcntl.gr_adst := DSTREG;
        ndpcntl.gr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '1';
        nstate := s_dstr_dec1;

      when s_dstr_dec1 =>               -- -----------------------------------
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        macc  := R_IDSTAT.is_rmwop and not DSTDEF;
        bytop := R_IDSTAT.is_bytop and not DSTDEF;
        do_memread_d(nstate, nvmcntl, s_dstr_inc_w,
                     pbytop=>bytop, pmacc=>macc,
                     pkstack=>is_kstackdst1246 and R_IDSTAT.is_rmwop);

      when s_dstr_ind =>                -- -----------------------------------
        do_memread_i(nstate, ndpcntl, nvmcntl, s_dstr_ind1_w);

      when s_dstr_ind1_w =>             -- -----------------------------------
        nstate := s_dstr_ind1_w;
        if R_IDSTAT.is_dstpc = '0' then
          ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A = DDST
        else
          ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC (for nn(pc))
        end if;
        ndpcntl.ounit_bsel := c_ounit_bsel_vmdout;-- OUNIT B = VMDOUT
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          nstate := s_dstr_ind2;
        end if;

      when s_dstr_ind2 =>               -- -----------------------------------
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        macc  := R_IDSTAT.is_rmwop and not DSTDEF;
        bytop := R_IDSTAT.is_bytop and not DSTDEF;
        do_memread_d(nstate, nvmcntl, s_dstr_ind2_w,
                     pbytop=>bytop, pmacc=>macc,
                     pkstack=>is_kstackdst1246 and R_IDSTAT.is_rmwop);

      when s_dstr_ind2_w =>             -- -----------------------------------
        nstate := s_dstr_ind2_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          if DSTDEF = '1' then
            nstate := s_dstr_def;
          else
            do_fork_opg(nstate, R_IDSTAT);
          end if;
        end if;
        
  -- destination write states -------------------------------------------------
  --   flows:
  --     1  (r)    s_dstw_def           wreq (r)            check kstack
  --               s_dstw_def_w         ack  (r)
  --               -> do_fork_next
  --              
  --     2  (r)+   s_dstw_inc           wreq (r)            check kstack
  --               s_dstw_inc_w         ack  (r); r+=s
  --               -> do_fork_next
  --
  --     3  @(r)+  s_dstw_inc           rreq (r); r+=s
  --               s_dstw_incdef_w      get  (r)
  --               s_dstw_def246        wreq @(r)
  --               s_dstw_def_w         ack  @(r)
  --               -> do_fork_next
  --
  --     4  -(r)   s_dstw_dec           r-=s
  --               s_dstw_dec1          wreq (r)            check kstack
  --               s_dstw_def_w         ack  (r)
  --               -> do_fork_next
  --
  --     5  @-(r)  s_dstw_dec           r-=s
  --               s_dstw_dec1          rreq (r)
  --               s_dstw_incdef_w      get  (r)
  --               s_dstw_def246        wreq @(r)
  --               s_dstw_def_w         ack  @(r)
  --               -> do_fork_next
  --
  --     6  n(r)   s_dstw_ind           rreq n
  --               s_dstw_ind_w         get  n; ea=r+n
  --               s_dstw_dec1          wreq n(r)           check kstack
  --               s_dstw_def_w         ack  n(r)
  --               -> do_fork_next
  --
  --     7  @n(r)  s_dstw_ind           rreq n
  --               s_dstw_ind_w         get  n; ea=r+n
  --               s_dstw_dec1          rreq n(r)
  --               s_dstw_incdef_w      get  n(r)
  --               s_dstw_def246        wreq @n(r)
  --               s_dstw_def_w         ack  @n(r)
  --               -> do_fork_next

      when s_dstw_def =>                -- -----------------------------------
        ndpcntl.dres_sel := R_IDSTAT.res_sel;      -- DRES = choice of idec
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        nvmcntl.kstack := is_kstackdst1246;
        do_memwrite(nstate, nvmcntl, s_dstw_def_w, pispace=>R_IDSTAT.is_dstpc);
        
      when s_dstw_def_w =>              -- -----------------------------------
        nstate := s_dstw_def_w;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.psr_ccwe := '1';
          idm_idone := '1';                        -- instruction done
          do_fork_next(nstate, nstatus, nmmumoni);  -- fetch next
        end if;

      when s_dstw_inc =>                -- -----------------------------------
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst;   -- VA = DDST
        ndpcntl.ounit_asel := c_ounit_asel_ddst;     -- OUNIT A=DDST  (for else)
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, DSTDEF, DSTREG);  --(...)
        ndpcntl.ounit_bsel := c_ounit_bsel_const;    -- OUNIT B=const (for else)
        if DSTDEF = '0' then
          ndpcntl.dres_sel := R_IDSTAT.res_sel;      -- DRES = choice of idec
          nvmcntl.kstack := is_kstackdst1246;
          do_memwrite(nstate, nvmcntl, s_dstw_inc_w, pispace=>R_IDSTAT.is_dstpc);
          nstatus.do_grwe := '1';
        else
          ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
          ndpcntl.gr_adst := DSTREG;
          ndpcntl.gr_we := '1';
          nmmumoni.regmod := '1';
          nmmumoni.isdec := '0';
          do_memread_d(nstate, nvmcntl, s_dstw_incdef_w,
                       pispace=>R_IDSTAT.is_dstpc);
        end if;
        
      when s_dstw_inc_w =>              -- -----------------------------------
        nstate := s_dstw_inc_w;
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, DSTDEF, DSTREG);
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gr_adst := DSTREG;
        if R_STATUS.do_grwe = '1' then
          nmmumoni.regmod := '1';
          nmmumoni.isdec := '0';
          nmmumoni.trace_prev := '1';              -- mmr freeze of prev state
          ndpcntl.gr_we := '1';                    -- update DST reg
        end if;
        nstatus.do_grwe := '0';
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.psr_ccwe := '1';
          idm_idone := '1';                        -- instruction done
          do_fork_next(nstate, nstatus, nmmumoni); -- fetch next
        end if;

      when s_dstw_incdef_w =>           -- -----------------------------------
        nstate := s_dstw_incdef_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          nstate := s_dstw_def246;
        end if;

      when s_dstw_dec =>                -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A=DDST
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, DSTDEF, DSTREG);
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        ndpcntl.ddst_we := '1';                  -- update DDST
        ndpcntl.gr_adst := DSTREG;
        ndpcntl.gr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '1';
        nstate := s_dstw_dec1;
        
      when s_dstw_dec1 =>               -- -----------------------------------
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        ndpcntl.dres_sel := R_IDSTAT.res_sel;      -- DRES = from idec (for if)
        if DSTDEF = '0' then
          nvmcntl.kstack := is_kstackdst1246;
          do_memwrite(nstate, nvmcntl, s_dstw_def_w);
        else
          do_memread_d(nstate, nvmcntl, s_dstw_incdef_w);
        end if;          

      when s_dstw_ind =>                -- -----------------------------------
        do_memread_i(nstate, ndpcntl, nvmcntl, s_dstw_ind_w);

      when s_dstw_ind_w =>              -- -----------------------------------
        nstate := s_dstw_ind_w;
        if R_IDSTAT.is_dstpc = '0' then
          ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A = DDST
        else
          ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC (for nn(pc))
        end if;
        ndpcntl.ounit_bsel := c_ounit_bsel_vmdout;-- OUNIT B = VMDOUT
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          nstate := s_dstw_dec1;
        end if;        

      when s_dstw_def246 =>             -- -----------------------------------
        ndpcntl.dres_sel := R_IDSTAT.res_sel;      -- DRES = choice of idec
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        do_memwrite(nstate, nvmcntl, s_dstw_def_w);

  -- destination address states -----------------------------------------------
  --   flows:
  --     1  (r)    -> do_fork_opa
  --              
  --     2  (r)+   s_dsta_inc           r+=2
  --               -> do_fork_opa
  --
  --     3  @(r)+  s_dsta_inc           req (r); r+=s
  --               s_dsta_incdef_w      get (r)
  --               -> do_fork_opa
  --
  --     4  -(r)   s_dsta_dec           r-=s
  --               s_dsta_dec1          ?? FIXME ?? what is done here ??
  --               -> do_fork_opa
  --
  --     5  @-(r)  s_dsta_dec           r-=s
  --               s_dsta_dec1          req (r)
  --               s_dsta_incdef_w      get (r)
  --               -> do_fork_opa
  --
  --     6  n(r)   s_dsta_ind           req n
  --               s_dsta_ind_w         get n; ea=r+n
  --               s_dsta_dec1          ?? FIXME ?? what is done here ??
  --               -> do_fork_opa
  --
  --     7  @n(r)  s_dsta_ind           req n
  --               s_dsta_ind_w         get n; ea=r+n
  --               s_dsta_dec1          req n(r)
  --               s_dsta_incdef_w      get n(r)
  --               -> do_fork_opa

      when s_dsta_inc =>                -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        ndpcntl.ounit_const := "000000010";
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(2)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gr_adst := DSTREG;
        ndpcntl.gr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '0';
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;      -- DSRC = DRES (for if)
        if R_IDSTAT.updt_dstadsrc = '1' then       -- prevent stale DSRC copy 
          ndpcntl.dsrc_we := '1';                    -- update DSRC
        end if;
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        if DSTDEF = '0' then
          do_fork_opa(nstate, R_IDSTAT);
        else
          do_memread_d(nstate, nvmcntl, s_dsta_incdef_w,
                       pispace=>R_IDSTAT.is_dstpc);
        end if;
          
      when s_dsta_incdef_w =>           -- -----------------------------------
        nstate := s_dsta_incdef_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          do_fork_opa(nstate, R_IDSTAT);
        end if;    
    
      when s_dsta_dec =>                -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A=DDST
        ndpcntl.ounit_const := "000000010";
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const(2)
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        ndpcntl.ddst_we := '1';                  -- update DDST
        ndpcntl.gr_adst := DSTREG;
        ndpcntl.gr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '1';
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES (for if)
        if R_IDSTAT.updt_dstadsrc = '1' then     -- prevent stale DSRC copy 
          ndpcntl.dsrc_we := '1';                -- update DSRC
        end if;
        nstate := s_dsta_dec1;
        
      when s_dsta_dec1 =>               -- -----------------------------------
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        if DSTDEF = '0' then                       -- check here used also by
          do_fork_opa(nstate, R_IDSTAT);           -- s_dsta_ind flow !!
        else
          do_memread_d(nstate, nvmcntl, s_dsta_incdef_w);
        end if;          

      when s_dsta_ind =>                -- -----------------------------------
        do_memread_i(nstate, ndpcntl, nvmcntl, s_dsta_ind_w);
        
      when s_dsta_ind_w =>              -- -----------------------------------
        nstate := s_dsta_ind_w;
        if R_IDSTAT.is_dstpc = '0' then
          ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A = DDST
        else
          ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC (for nn(pc))
        end if;
        ndpcntl.ounit_bsel := c_ounit_bsel_vmdout;-- OUNIT B = VMDOUT
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          nstate := s_dsta_dec1;
        end if;
        
  -- instruction operate states -----------------------------------------------

      when s_op_halt =>                 -- HALT -------------------------------
        idm_idone := '1';               -- instruction done
        if is_kmode = '1' then          -- if in kernel mode execute
          nstatus.cpugo := '0';
          nstatus.cpurust := c_cpurust_halt;
          nstate := s_idle;
        else                            -- otherwise trap
          ncpuerr.illhlt := '1';
          nstate := s_abort_4;          -- vector 4 abort like 11/70
        end if;

      when s_op_wait =>                 -- WAIT ------------------------------
        -- Note: wait is the only interruptable instruction. The CPU spins
        --   in s_op_wait until an interrupt or a control command is seen.
        --   In case of a control command R_STATUS.waitsusp is set and
        --   control transfered to s_idle. If the control command returns
        --   to s_op_wait, waitsusp is cleared here. This ensures that the
        --   idm_idone logic (for dmcmon) sees only one WAIT even if it is
        --   interrupted by control commands.
        ndpcntl.gr_asrc := "000";       -- load R0 in DSRC for DR emulation
        ndpcntl.dsrc_sel := c_dpath_dsrc_src;
        ndpcntl.dsrc_we  := '1';
        nstatus.waitsusp := '0';        -- in case of returning from s_idle

        -- signal idone in the first cycle of a WAIT instruction to dmcmon
        -- ensures that a WAIT is logged once and only once
        idm_idone := not (R_STATUS.waitsusp or R_STATUS.cpuwait);

        nstate := s_op_wait;            -- spin here
        if is_kmode = '0' then          -- but act as nop if not in kernel
          nstate := s_idle;
        elsif int_pending = '1' or      -- bail out if pending interrupt
          R_STATUS.cpustep='1' then     --  or the instruction is only stepped
          nstate := s_idle;
        elsif R_STATUS.cmdbusy = '1' then -- suspend if a cp command is pending
          nstatus.waitsusp := '1';
          nstate := s_idle;
        else
          nstatus.cpuwait := '1';       -- if spinning here, signal with cpuwait
          nstatus.itimer  := '1';       -- itimer will stay 1 during a WAIT
       end if;

      when s_op_trap =>                 -- trap instructions (IOT,BPT,..) ----
        idm_idone := '1';                      -- instruction done
        lvector := "0000" & R_IDSTAT.trap_vec; -- vector
        do_start_vec(nstate, ndpcntl, lvector);
        
      when s_op_reset =>                -- RESET -----------------------------
        nstate := s_op_reset;           -- default is spin till timer expire
        nstatus.resetcnt := slv(unsigned(R_STATUS.resetcnt) - 1);  -- dec timer
        if is_kmode = '1' then          -- if in kernel mode execute
          if R_STATUS.resetcnt = "111" then   -- in first cycle
            nstatus.breset := '1';            -- issue bus reset
          end if;
          if R_STATUS.resetcnt = "000" then   -- in last cycle
            nstate := s_idle;                 -- done, continue via s_idle
          end if;
        else                             -- if not in kernel mode
          nstate := s_idle;                -- nop, continue via s_idle
        end if;
        
      when s_op_rts =>                  -- RTS -------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gr_adst := c_gr_pc;
        ndpcntl.gr_we := '1';                      -- load PC with reg(dst)
        idm_pcload := '1';                         -- signal flow change
        nstate := s_op_rts_pop;

      when s_op_rts_pop =>              -- -----------------------------------
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_op_rts_pop_w,
                          nmmumoni, pupdt_sp=>'1');
        
      when s_op_rts_pop_w =>            -- -----------------------------------
        nstate := s_op_rts_pop_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;   -- DRES = VMDOUT
        ndpcntl.gr_adst := DSTREG;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then          
          ndpcntl.gr_we := '1';                   -- load R with (SP)+
          idm_idone := '1';                       -- instruction done
          do_fork_next(nstate, nstatus, nmmumoni);  -- fetch next
        end if;
        
      when s_op_spl =>                  -- SPL -------------------------------
        ndpcntl.dres_sel := c_dpath_res_ireg;    -- DRES = IREG
        ndpcntl.psr_func := c_psr_func_wspl;
        idm_idone := '1';                        -- instruction done
        if is_kmode = '1' then                   -- active only in kernel mode
          ndpcntl.psr_we := '1';
          nstate := s_ifetch;                    -- unconditionally fetch next
                                                 -- instruction like a 11/70
                                                 -- no interrupt recognition !
        else
          do_fork_next(nstate, nstatus, nmmumoni);  -- in non-kernel, noop
        end if;

      when s_op_mcc =>                  -- CLx/SEx ---------------------------
        ndpcntl.dres_sel := c_dpath_res_ireg;    -- DRES = IREG
        ndpcntl.psr_func := c_psr_func_wcc;
        ndpcntl.psr_we := '1';
        idm_idone := '1';                        -- instruction done
        do_fork_next(nstate, nstatus, nmmumoni); -- fetch next
        
      when s_op_br =>                   -- BR --------------------------------
        nvmcntl.dspace := '0';                   -- prepare do_fork_next_pref
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_pc; -- VA = PC
        ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC
        ndpcntl.ounit_bsel := c_ounit_bsel_ireg8;-- OUNIT B = IREG8
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        -- note: cc are NZVC
        case brcode(3 downto 1) is
          when "000" =>                 -- BR
            brcond := '1';
          when "001" =>                 -- BNE/BEQ: if Z = x
            brcond := PSW.cc(2);
          when "010" =>                 -- BGE/BLT: if N xor V = x
            brcond := PSW.cc(3) xor PSW.cc(1);
          when "011" =>                 -- BGT/BLE: if Z or (N xor V) = x
            brcond := PSW.cc(2) or (PSW.cc(3) xor PSW.cc(1));
          when "100" =>                 -- BPL/BMI: if N = x
            brcond := PSW.cc(3);
          when "101" =>                 -- BHI/BLOS:if C or Z = x
            brcond := PSW.cc(2) or PSW.cc(0);
          when "110" =>                 -- BVC/BVS: if V = x
            brcond := PSW.cc(1);
          when "111" =>                 -- BCC/BCS: if C = x
            brcond := PSW.cc(0);
          when others => null;
        end case;

        ndpcntl.gr_adst := c_gr_pc;
        idm_idone := '1';               -- instruction done
        if brcond = brcode(0) then      -- this coding creates redundant code
          ndpcntl.gr_we := '1';         --   but synthesis optimizes this way !
          idm_pcload := '1';            -- signal flow change
          do_fork_next(nstate, nstatus, nmmumoni);
        else
          do_fork_next_pref(nstate, nstatus, ndpcntl, nvmcntl, nmmumoni);
        end if;
        
      when s_op_mark =>                 -- MARK ------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC
        ndpcntl.ounit_bsel := c_ounit_bsel_ireg6;-- OUNIT B = IREG6
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        ndpcntl.dsrc_we := '1';                  -- update DSRC (with PC+2*nn)
        ndpcntl.gr_adst := c_gr_r5;              -- fetch r5
        ndpcntl.ddst_sel := c_dpath_ddst_dst;
        ndpcntl.ddst_we := '1';
        nstate := s_op_mark1;

      when s_op_mark1 =>                -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A = DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B = const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.gr_adst := c_gr_pc;
        ndpcntl.gr_we := '1';                    -- load PC with r5
        idm_pcload := '1';                       -- signal flow change
        nstate := s_op_mark_pop;

      when s_op_mark_pop =>             -- -----------------------------------
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_op_mark_pop_w,
                          nmmumoni, pupdt_sp=>'1');

      when s_op_mark_pop_w =>           -- -----------------------------------
        nstate := s_op_mark_pop_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.gr_adst := c_gr_r5;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then          
          ndpcntl.gr_we := '1';                  -- load R5 with (sp)+
          idm_idone := '1';                      -- instruction done
          do_fork_next(nstate, nstatus, nmmumoni);  -- fetch next
        end if;
        
      when s_op_sob =>                  -- SOB (dec) -------------------------
        -- comment fork_next_pref out (blog 2006-10-02) due to synthesis impact
        --nvmcntl.dspace := '0';                   -- prepare do_fork_next_pref
        --ndpcntl.vmaddr_sel := c_dpath_vmaddr_pc; -- VA = PC
        ndpcntl.dres_sel := R_IDSTAT.res_sel;
        ndpcntl.gr_adst := SRCREG;
        ndpcntl.gr_we := '1';

        if DP_STAT.ccout_z = '0' then        -- if z=0 branch, if z=1 fall thru
          nstate := s_op_sob1;
        else
          --do_fork_next_pref(nstate, ndpcntl, nvmcntl, nmmumoni);
          idm_idone := '1';                  -- instruction done
          do_fork_next(nstate, nstatus, nmmumoni);  -- fetch next
        end if;
        
      when s_op_sob1 =>                 -- SOB (br) --------------------------
        ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC
        ndpcntl.ounit_bsel := c_ounit_bsel_ireg6;-- OUNIT B = IREG6
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A - B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.gr_adst := c_gr_pc;
        ndpcntl.gr_we := '1';
        idm_pcload := '1';                       -- signal flow change
        idm_idone := '1';                        -- instruction done
        do_fork_next(nstate, nstatus, nmmumoni);  -- fetch next

      when s_opg_gen =>                 -- -----------------------------------
        nvmcntl.dspace := '0';                   -- prepare do_fork_next_pref
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_pc; -- VA = PC
        ndpcntl.gr_bytop := R_IDSTAT.is_bytop;
        ndpcntl.dres_sel := R_IDSTAT.res_sel;    -- DRES = choice of idec
        
        if R_IDSTAT.op_mov = '1' then            -- in case of MOV xx,R
          ndpcntl.gr_bytop := '0';               --  no bytop, do sign extend
        end if;

        ndpcntl.psr_ccwe := '1';  -- acceptable even here though before the final
                                  -- write which is a macc completion. That can
                                  -- only fail due to a ibus timeout, all other
                                  -- errors were caught during initial read.

        if R_IDSTAT.is_dstw_reg = '1' then
          ndpcntl.gr_we := '1';
        end if;

        if R_IDSTAT.is_rmwop = '1' then
          do_memwrite(nstate, nvmcntl, s_opg_gen_rmw_w, pmacc=>'1');
        else           
          idm_idone := '1';                      -- instruction done
          if R_STATUS.prefdone = '1' then
            nstatus.prefdone :='0';
            nstate := s_ifetch_w;
            do_memcheck(nstate, nstatus, imemok);
            if imemok then
              ndpcntl.ireg_we := '1';
              nstate := s_idecode;
            end if;
          else
            if R_IDSTAT.is_dstw_pc = '1' then
              nstate := s_idle;
            else
              do_fork_next_pref(nstate, nstatus, ndpcntl, nvmcntl, nmmumoni);
            end if;      
          end if;
        end if;           

      when s_opg_gen_rmw_w =>           -- -----------------------------------
        nstate := s_opg_gen_rmw_w;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          idm_idone := '1';                      -- instruction done
          do_fork_next(nstate, nstatus, nmmumoni); -- fetch next
        end if;

      when s_opg_mul =>                 -- MUL (oper) ------------------------
        ndpcntl.dres_sel := R_IDSTAT.res_sel;   -- DRES = choice of idec
        ndpcntl.gr_adst := SRCREG;              -- write high order result
        ndpcntl.gr_we := '1';
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;   -- DSRC = DRES
        ndpcntl.dsrc_we := '1';                 -- capture high order part
        ndpcntl.dtmp_sel := c_dpath_dtmp_drese; -- DTMP = DRESE
        ndpcntl.dtmp_we := '1';                 -- capture low order part
        nstate := s_opg_mul1;
        
      when s_opg_mul1 =>                -- MUL (write odd reg) ---------------
        ndpcntl.ounit_asel := c_ounit_asel_dtmp; -- OUNIT A = DTMP
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B = const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.gr_adst := SRCREG(2 downto 1) & "1"; -- write odd reg !
        ndpcntl.gr_we := '1';
        ndpcntl.psr_ccwe := '1';
        idm_idone := '1';                        -- instruction done
        do_fork_next(nstate, nstatus, nmmumoni);  -- fetch next
        
      when s_opg_div =>                 -- DIV (load dd_low) -----------------
        ndpcntl.munit_s_div := '1';
        ndpcntl.gr_asrc := SRCREG(2 downto 1) & "1"; -- read odd reg !
        ndpcntl.dtmp_sel := c_dpath_dtmp_dsrc;
        ndpcntl.dtmp_we := '1';
        nstate := s_opg_div_cn;

      when s_opg_div_cn =>              -- DIV (1st...16th cycle) ------------
        ndpcntl.munit_s_div_cn := '1';
        ndpcntl.dres_sel := R_IDSTAT.res_sel;     -- DRES = choice of idec
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;     -- DSRC = DRES
        ndpcntl.dtmp_sel := c_dpath_dtmp_drese;   -- DTMP = DRESE
        nstate := s_opg_div_cn;
        if DP_STAT.div_quit = '1' then
          nstate := s_opg_div_quit;
        else
          ndpcntl.dsrc_we := '1';                 -- update DSRC
          ndpcntl.dtmp_we := '1';                 -- update DTMP
        end if;
        if DP_STAT.shc_tc = '1' then
          nstate := s_opg_div_cr;
        end if;

      when s_opg_div_cr =>              -- DIV (remainder correction) --------
        ndpcntl.munit_s_div_cr := '1';
        ndpcntl.dres_sel := R_IDSTAT.res_sel;     -- DRES = choice of idec
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;     -- DSRC = DRES
        ndpcntl.dsrc_we := DP_STAT.div_cr;        -- update DSRC
        nstate := s_opg_div_sq;
        
      when s_opg_div_sq =>              -- DIV (correct and store quotient) --
        ndpcntl.ounit_asel := c_ounit_asel_dtmp;  -- OUNIT A=DTMP
        ndpcntl.ounit_const := "00000000"&DP_STAT.div_cq;-- OUNIT const = Q corr.
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const (q cor)
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.gr_adst := SRCREG;                -- write result
        ndpcntl.gr_we := '1';
        ndpcntl.dtmp_sel := c_dpath_dtmp_dres;    -- DTMP = DRES
        ndpcntl.dtmp_we := '1';                   -- update DTMP (Q)
        nstate := s_opg_div_sr;

      when s_opg_div_sr =>              -- DIV (store remainder) -------------
        ndpcntl.munit_s_div_sr := '1';
        ndpcntl.ounit_asel := c_ounit_asel_dsrc;  -- OUNIT A=DSRC
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const (0)
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.gr_adst := SRCREG(2 downto 1) & "1"; -- write odd reg !
        ndpcntl.gr_we := '1';
        ndpcntl.psr_ccwe := '1';
        if DP_STAT.div_quit = '1' then
          nstate := s_opg_div_quit;
        else
          idm_idone := '1';                       -- instruction done
          do_fork_next(nstate, nstatus, nmmumoni);  -- fetch next
        end if;
        
      when s_opg_div_quit =>            -- DIV (0/ or /0 or V=1 aborts) ------
        ndpcntl.psr_ccwe := '1';
        idm_idone := '1';               -- instruction done
        do_fork_next(nstate, nstatus, nmmumoni);  -- fetch next

      when s_opg_ash =>                 -- ASH (load shc) --------------------
        ndpcntl.munit_s_ash := '1';
        nstate := s_opg_ash_cn;

      when s_opg_ash_cn =>              -- ASH (shift cycles) ----------------
        nvmcntl.dspace := '0';                    -- prepare do_fork_next_pref
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;     -- DSRC = DRES
        ndpcntl.ounit_asel := c_ounit_asel_dsrc;  -- OUNIT A=DSRC
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const(0)
        ndpcntl.gr_adst := SRCREG;                -- write result
        ndpcntl.munit_s_ash_cn := '1';
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_pc;  -- VA = PC
        nstate := s_opg_ash_cn;
        if DP_STAT.shc_tc = '0' then
          ndpcntl.dres_sel := R_IDSTAT.res_sel;   -- DRES = choice of idec
          ndpcntl.dsrc_we := '1';                 -- update DSRC
        else
          ndpcntl.dres_sel := c_dpath_res_ounit;  -- DRES = OUNIT
          ndpcntl.gr_we := '1';
          ndpcntl.psr_ccwe := '1';
          idm_idone := '1';                       -- instruction done
          do_fork_next_pref(nstate, nstatus, ndpcntl, nvmcntl, nmmumoni);
        end if;
          
      when s_opg_ashc =>                -- ASHC (load low, load shc) ---------
        ndpcntl.gr_asrc := SRCREG(2 downto 1) & "1"; -- read odd reg !
        ndpcntl.dtmp_sel := c_dpath_dtmp_dsrc;
        ndpcntl.dtmp_we := '1';
        ndpcntl.munit_s_ashc := '1';
        nstate := s_opg_ashc_cn;

      when s_opg_ashc_cn =>             -- ASHC (shift cycles) ---------------
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;     -- DSRC = DRES
        ndpcntl.dtmp_sel := c_dpath_dtmp_drese;   -- DTMP = DRESE
        ndpcntl.ounit_asel := c_ounit_asel_dsrc;  -- OUNIT A=DSRC
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const(0)
        ndpcntl.gr_adst := SRCREG;                -- write result
        ndpcntl.munit_s_ashc_cn := '1';
        nstate := s_opg_ashc_cn;
        if DP_STAT.shc_tc = '0' then
          ndpcntl.dres_sel := R_IDSTAT.res_sel;   -- DRES = choice of idec
          ndpcntl.dsrc_we := '1';                 -- update DSRC
          ndpcntl.dtmp_we := '1';                 -- update DTMP
        else
          ndpcntl.dres_sel := c_dpath_res_ounit;  -- DRES = OUNIT
          ndpcntl.gr_we := '1';
          ndpcntl.psr_ccwe := '1';
          nstate := s_opg_ashc_wl;
        end if;

      when s_opg_ashc_wl =>             -- ASHC (write low) ------------------
        ndpcntl.ounit_asel := c_ounit_asel_dtmp; -- OUNIT A = DTMP
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B = const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.gr_adst := SRCREG(2 downto 1) & "1"; -- write odd reg !
        ndpcntl.gr_we := '1';
        idm_idone := '1';                        -- instruction done
        do_fork_next(nstate, nstatus, nmmumoni);  -- fetch next

  -- dsta mode operations -----------------------------------------------------

      when s_opa_jsr =>                 -- -----------------------------------
        ndpcntl.gr_asrc := c_gr_sp;                --                (for else)
        ndpcntl.dsrc_sel := c_dpath_dsrc_src;      -- DSRC = regfile (for else)
        if R_IDSTAT.is_dstmode0 = '1' then
          nstate := s_abort_10;                    -- vector 10 abort like 11/70
        else
          ndpcntl.dsrc_we := '1';
          nstate := s_opa_jsr1;
        end if;

      when s_opa_jsr1 =>                -- -----------------------------------
        ndpcntl.gr_asrc := SRCREG;
        ndpcntl.dtmp_sel := c_dpath_dtmp_dsrc;     -- DTMP = regfile
        ndpcntl.dtmp_we := '1';
        
        ndpcntl.ounit_asel := c_ounit_asel_dsrc;   -- OUNIT A=DSRC
        ndpcntl.ounit_const := "000000010";
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(2)
        ndpcntl.ounit_opsub := '1';                -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;      -- DDST = DRES
        ndpcntl.dsrc_we := '1';                    -- update DDST
        ndpcntl.gr_adst := c_gr_sp;
        ndpcntl.gr_we := '1';                      -- update SP
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '1';
        nstate := s_opa_jsr_push;

      when s_opa_jsr_push =>            -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_dtmp;   -- OUNIT A=DTMP
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        nvmcntl.dspace := '1';
        nvmcntl.kstack := is_kmode;
        nvmcntl.wacc := '1';
        nvmcntl.req := '1';
        nstate := s_opa_jsr_push_w;

      when s_opa_jsr_push_w =>          -- -----------------------------------
        nstate := s_opa_jsr_push_w;
        ndpcntl.ounit_asel := c_ounit_asel_pc;     -- OUNIT A=PC
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gr_adst := SRCREG;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.gr_we := '1';                    -- load R with PC
          nstate := s_opa_jsr2;
        end if;

      when s_opa_jsr2 =>                -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gr_adst := c_gr_pc;
        ndpcntl.gr_we := '1';                      -- load PC with dsta
        idm_pcload := '1';                         -- signal flow change
        idm_idone := '1';                          -- instruction done
        do_fork_next(nstate, nstatus, nmmumoni);   -- fetch next

      when s_opa_jmp =>                 -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gr_adst := c_gr_pc;
        if R_IDSTAT.is_dstmode0 = '1' then
          nstate := s_abort_10;                    -- vector 10 abort like 11/70
        else
          ndpcntl.gr_we := '1';                    -- load PC with dsta
          idm_pcload := '1';                       -- signal flow change
          idm_idone := '1';                        -- instruction done
          do_fork_next(nstate, nstatus, nmmumoni);  -- fetch next
        end if;

      when s_opa_mtp =>                 -- -----------------------------------
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_opa_mtp_pop_w,
                          nmmumoni, pupdt_sp=>'1');
        
      when s_opa_mtp_pop_w =>           -- -----------------------------------
        nstate := s_opa_mtp_pop_w;
        ndpcntl.ddst_sel := c_dpath_ddst_dst;     -- DDST = R(DST)
        ndpcntl.ddst_we  := '1';                  -- update DDST (needed for sp)
        ndpcntl.dres_sel := c_dpath_res_vmdout;   -- DRES = VMDOUT
        ndpcntl.dtmp_sel := c_dpath_dtmp_dres;    -- DTMP = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then          
          ndpcntl.dtmp_we := '1';                 -- load DTMP
          if R_IDSTAT.is_dstmode0 = '1' then      -- handle register access
            nstate := s_opa_mtp_reg;
          else
            case R_IDSTAT.fork_dsta is            -- 2nd dsta fork in s_idecode
              when c_fork_dsta_def => nstate := s_opa_mtp_mem;
              when c_fork_dsta_inc => nstate := s_dsta_inc;
              when c_fork_dsta_dec => nstate := s_dsta_dec;
              when c_fork_dsta_ind => nstate := s_dsta_ind;
              when others => nstate := s_cpufail;
            end case;
          end if;
        end if;

      when s_opa_mtp_reg =>             -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_dtmp;  -- OUNIT A = DTMP
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B = const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.psr_ccwe := '1';                  -- set cc (from ounit too)
        ndpcntl.gr_mode := PSW.pmode;             -- load reg in pmode
        ndpcntl.gr_we := '1';
        idm_idone := '1';                         -- instruction done
        do_fork_next(nstate, nstatus, nmmumoni);  -- fetch next

      when s_opa_mtp_mem =>             -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_dtmp;  -- OUNIT A = DTMP
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B = const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst;-- VA = DDST
        nvmcntl.dspace := IREG(15);            -- msb indicates I/D: 0->I, 1->D
        nvmcntl.mode := PSW.pmode;
        nvmcntl.wacc := '1';
        nvmcntl.req := '1';
        nstate := s_opa_mtp_mem_w;
        
      when s_opa_mtp_mem_w =>           -- -----------------------------------
        nstate := s_opa_mtp_mem_w;
        ndpcntl.ounit_asel := c_ounit_asel_dtmp;  -- OUNIT A = DTMP     (for cc)
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B = const(0) (for cc)
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.psr_ccwe := '1';                -- set cc (ounit via res_sel)
          idm_idone := '1';                       -- instruction done
          do_fork_next(nstate, nstatus, nmmumoni);  -- fetch next
        end if;

      when s_opa_mfp_reg =>             -- -----------------------------------
        ndpcntl.gr_mode := PSW.pmode;            -- fetch reg in pmode
        ndpcntl.ddst_sel := c_dpath_ddst_dst;    -- DDST = reg(dst)
        ndpcntl.ddst_we := '1';
        nstate := s_opa_mfp_dec;
        
      when s_opa_mfp_mem =>             -- -----------------------------------
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst;   -- VA = DDST
        if PSW.cmode=c_psw_umode and                 -- if cm=pm=user then
           PSW.cmode=c_psw_umode then                -- MFPI works like it
          nvmcntl.dspace := '1';                     -- were MFPD
        else
          nvmcntl.dspace := IREG(15);          -- msb indicates I/D: 0->I, 1->D
        end if;
        nvmcntl.mode := PSW.pmode;
        nvmcntl.req := '1';
        nstate := s_opa_mfp_mem_w;

      when s_opa_mfp_mem_w =>           -- -----------------------------------
        nstate := s_opa_mfp_mem_w;
        do_memcheck(nstate, nstatus, imemok);
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        if imemok then
          ndpcntl.ddst_we := '1';
          nstate := s_opa_mfp_dec;
        end if;

      when s_opa_mfp_dec =>             -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_dsrc;   -- OUNIT A=DSRC
        ndpcntl.ounit_const := "000000010";
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(2)
        ndpcntl.ounit_opsub := '1';                -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;      -- DSRC = DRES
        ndpcntl.dsrc_we := '1';                    -- update DSRC
        ndpcntl.gr_adst := c_gr_sp;
        ndpcntl.gr_we := '1';                      -- update SP
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '1';
        nstate := s_opa_mfp_push;

      when s_opa_mfp_push =>            -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        nvmcntl.dspace := '1';
        nvmcntl.kstack := is_kmode;
        nvmcntl.wacc := '1';
        nvmcntl.req := '1';
        nstate := s_opa_mfp_push_w;

      when s_opa_mfp_push_w =>          -- -----------------------------------
        nstate := s_opa_mfp_push_w;
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST     (for cc)
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(0) (for cc)
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.psr_ccwe := '1';                -- set cc (ounit via res_sel)
          idm_idone := '1';                       -- instruction done
          do_fork_next(nstate, nstatus, nmmumoni);  -- fetch next
        end if;

  -- trap and interrupt handling states --------------------------------------

      when s_abort_4 =>                 -- -----------------------------------
        lvector := "0000001";           -- vector (4)
        do_start_vec(nstate, ndpcntl, lvector);

      when s_abort_10 =>                -- -----------------------------------
        idm_idone := '1';               -- instruction done
        lvector := "0000010";           -- vector (10)
        do_start_vec(nstate, ndpcntl, lvector);

      when s_trap_disp =>               -- -----------------------------------
        if R_STATUS.treq_mmu = '1' then -- mmu trap requested ? 
          lvector := "0101010";         -- mmu trap: vector (250)
        elsif R_STATUS.treq_ysv = '1' then  -- ysv trap requested ?
          lvector := "0000001";         -- ysv trap: vector (4)          
          ncpuerr.ysv := '1';
          nstatus.in_vecysv := '1';     -- signal start of ysv vector flow
        else
          lvector := "0000011";         -- trace trap: vector (14)
        end if;
        nstatus.treq_mmu  := '0';       -- clear trap request flags
        nstatus.treq_ysv  := '0';       --
        nstatus.treq_tbit := '0';       --
        do_start_vec(nstate, ndpcntl, lvector);

      when s_int_ext =>                 -- -----------------------------------
        lvector := R_STATUS.intvect;    -- external vector
        do_start_vec(nstate, ndpcntl, lvector);

  -- vector flow states ------------------------------------------------------

      when s_vec_getpc =>               -- -----------------------------------
        nmmumoni.vstart := '1';         -- signal vstart
        nstatus.in_vecflow := '1';      -- signal vector flow
        nvmcntl.mode := c_psw_kmode;    -- fetch PC from kernel D space
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_vec_getpc_w, nmmumoni);

      when s_vec_getpc_w =>             -- -----------------------------------
        nstate := s_vec_getpc_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;   -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;     -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if VM_STAT.err = '1' then                 -- in case of vm-err
          nstatus.cpugo   := '0';                 -- non-recoverable error
          nstatus.cpurust := c_cpurust_vecfet;    -- halt CPU
          nstate := s_idle;          
        end if;
        if imemok then
          ndpcntl.ddst_we := '1';                 -- DDST = new PC
          nstate := s_vec_getps;
        end if;

      when s_vec_getps =>               -- -----------------------------------
        nvmcntl.mode := c_psw_kmode;    -- fetch PS from kernel D space
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_vec_getps_w, nmmumoni);

      when s_vec_getps_w =>             -- -----------------------------------
        nstate := s_vec_getps_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;   -- DRES = VMDOUT
        ndpcntl.psr_func := c_psr_func_wint;      -- interupt mode write
        do_memcheck(nstate, nstatus, imemok);
        if VM_STAT.err = '1' then                 -- in case of vm-err
          nstatus.cpugo   := '0';                 -- non-recoverable error
          nstatus.cpurust := c_cpurust_vecfet;    -- halt CPU
          nstate := s_idle;          
        end if;
        if imemok then
          ndpcntl.psr_we := '1';                  -- store new PS
          nstate := s_vec_getsp;
        end if;

      when s_vec_getsp =>               -- -----------------------------------
        ndpcntl.gr_asrc := c_gr_sp;
        ndpcntl.dsrc_we := '1';                  -- DSRC = SP (in new mode)
        nstate := s_vec_decsp;

      when s_vec_decsp =>               -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_dsrc; -- OUNIT A=DSRC
        ndpcntl.ounit_const := "000000010";      -- OUNIT const=2
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        ndpcntl.dsrc_we := '1';                  -- update DSRC
        ndpcntl.gr_adst := c_gr_sp;
        ndpcntl.gr_we := '1';                    -- update SP too
        nmmumoni.regmod := '1';                  -- record vector push in MMR1
        nmmumoni.isdec := '1';
        nstate := s_vec_pushps;

      when s_vec_pushps =>              -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_dtmp;   -- OUNIT A=DTMP (old PS)
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const (0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        nvmcntl.wacc := '1';                       -- write mem
        nvmcntl.dspace := '1';
        nvmcntl.kstack := is_kmode;
        nvmcntl.req := '1';
        nstate := s_vec_pushps_w;

      when s_vec_pushps_w =>            -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_dsrc; -- OUNIT A=DSRC
        ndpcntl.ounit_const := "000000010";      -- OUNIT const=2
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        ndpcntl.gr_adst := c_gr_sp;

        nstate := s_vec_pushps_w;
        do_memcheck(nstate, nstatus, imemok);
        if VM_STAT.err = '1' then                -- if err restore PS from DTMP
          ndpcntl.ounit_asel := c_ounit_asel_dtmp;   -- OUNIT A=DTMP
          ndpcntl.ounit_const := "000000000";        -- OUNIT const=0
          ndpcntl.psr_func := c_psr_func_wall;       -- write all fields
          ndpcntl.psr_we := '1';                     -- re-store PS from DTMP
        end if;
        if imemok then
          ndpcntl.dsrc_we := '1';                -- update DSRC
          ndpcntl.gr_we := '1';                  -- update SP too
          nmmumoni.regmod := '1';                -- record vector push in MMR1
          nmmumoni.isdec := '1';
          nstate := s_vec_pushpc;
        end if;
        
      when s_vec_pushpc =>              -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_pc;     -- OUNIT A=PC
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const (0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        nvmcntl.wacc := '1';                       -- write mem
        nvmcntl.dspace := '1';
        nvmcntl.kstack := is_kmode;
        nvmcntl.req := '1';
        nstate := s_vec_pushpc_w;

      when s_vec_pushpc_w =>            -- -----------------------------------
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const (0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gr_adst := c_gr_pc;

        nstate := s_vec_pushpc_w;
        do_memcheck(nstate, nstatus, imemok);
        if VM_STAT.err = '1' then                  -- if err restore PS from DTMP
          ndpcntl.ounit_asel := c_ounit_asel_dtmp; -- OUNIT A=DTMP
          ndpcntl.ounit_const := "000000000";      -- OUNIT const=0
          ndpcntl.psr_func := c_psr_func_wall;     -- write all fields
          ndpcntl.psr_we := '1';                   -- re-store PS from DTMP
        end if;
        if imemok then
          nstatus.treq_tbit := PSW.tflag;          -- copy PSW.tflag to treq_bit
          nstatus.in_vecflow := '0';               -- signal end vector flow
          nstatus.in_vecser  := '0';               -- signal end of ser flow
          nstatus.in_vecysv  := '0';               -- signal end of ysv flow
          ndpcntl.gr_we := '1';                    -- load new PC
          idm_pcload := '1';                       -- signal flow change
          do_fork_next(nstate, nstatus, nmmumoni);         -- ???
        end if;
        
  -- return from trap or interrupt handling states ----------------------------

      when s_rti_getpc =>               -- -----------------------------------
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_rti_getpc_w,
                          nmmumoni, pupdt_sp=>'1');

      when s_rti_getpc_w =>             -- -----------------------------------
        nstate := s_rti_getpc_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;   -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;     -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                 -- DDST = new PC
          nstate := s_rti_getps;
        end if;

      when s_rti_getps =>               -- -----------------------------------
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_rti_getps_w,
                          nmmumoni, pupdt_sp=>'1');

      when s_rti_getps_w =>             -- -----------------------------------
        nstate := s_rti_getps_w;
        do_memcheck(nstate, nstatus, imemok);
        ndpcntl.dres_sel := c_dpath_res_vmdout;   -- DRES = VMDOUT
        if is_kmode = '1' then                    -- if in kernel mode
          ndpcntl.psr_func := c_psr_func_wall;    --   write all fields
        else
          ndpcntl.psr_func := c_psr_func_wrti;    --   otherwise filter
        end if;
        if imemok then
          ndpcntl.psr_we := '1';                  -- load new PS
          nstate := s_rti_newpc;
        end if;

      when s_rti_newpc =>               -- -----------------------------------
        if R_IDSTAT.op_rti = '1' then           -- if RTI instruction
          nstatus.treq_tbit := PSW.tflag;       --   copy PSW.tflag to treq_bit
        else                                    -- else RTT
          nstatus.treq_tbit := '0';             --   no tbit trap
        end if;
        ndpcntl.ounit_asel := c_ounit_asel_ddst;  -- OUNIT A=DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const (0)
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.gr_adst := c_gr_pc;
        ndpcntl.gr_we := '1';                     -- load new PC
        idm_pcload := '1';                        -- signal flow change
        idm_idone := '1';                         -- instruction done
        do_fork_next(nstate, nstatus, nmmumoni);

  -- exception abort states ---------------------------------------------------

      when s_vmerr =>                   -- -----------------------------------
        nstate := s_cpufail;

                                            -- setup for R_VMSTAT.err_ser='1'
        ndpcntl.ounit_azero := '1';               -- OUNIT A = 0
        ndpcntl.ounit_const := "000000100";       -- emergency stack pointer
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const(vector)
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.gr_mode := c_psw_kmode;           -- set kmode SP to 4
        ndpcntl.gr_adst := c_gr_sp;
        
        nstatus.treq_mmu  := '0';                 -- cancel mmu  trap request
        nstatus.treq_ysv  := '0';                 -- cancel ysv  trap request
        nstatus.treq_tbit := '0';                 -- cancel tbit trap request

        if R_VMSTAT.fail = '1' then               -- vmbox failure
          nstatus.cpugo   := '0';                   -- halt cpu
          nstatus.cpurust := c_cpurust_vfail;
          nstate := s_idle; 

        elsif R_STATUS.in_vecser = '1' then       -- double fatal stack error
          nstatus.cpugo := '0';                     -- give up, HALT cpu
          nstatus.cpurust := c_cpurust_recser;
          nstate := s_idle;
          
        elsif R_VMSTAT.err = '1' then            -- normal vm errors
          if R_VMSTAT.err_ser = '1' then
            nstatus.in_vecser := '1';              -- signal start of ser flow
            nstatus.in_vecysv := '0';              -- cancel ysv flow
            ndpcntl.gr_we := '1';

            if R_VMSTAT.err_odd='1' then
              ncpuerr.oddadr := '1';
            elsif R_VMSTAT.err_nxm = '1' then
              ncpuerr.nxm := '1';
            elsif R_VMSTAT.err_iobto = '1' then
              ncpuerr.iobto := '1';
            elsif R_VMSTAT.err_rsv = '1' then
              ncpuerr.rsv := '1';
            end if;
            nstate := s_abort_4;

          elsif R_VMSTAT.err_odd = '1' then
            ncpuerr.oddadr := '1';
            nstate := s_abort_4;
          elsif R_VMSTAT.err_nxm = '1' then
            ncpuerr.nxm := '1';
            nstate := s_abort_4;
          elsif R_VMSTAT.err_iobto = '1' then
            ncpuerr.iobto := '1';
            nstate := s_abort_4;

          elsif R_VMSTAT.err_mmu = '1' then
            lvector := "0101010";                    -- vector (250)
            do_start_vec(nstate, ndpcntl, lvector);
          end if;
        end if;

      when s_cpufail =>                 -- -----------------------------------
        nstatus.cpugo   := '0';
        nstatus.cpurust := c_cpurust_sfail;
        nstate := s_idle; 
        
      when others =>                    -- -----------------------------------
        nstate := s_cpufail;             --!!! catch undefined states !!!

    end case;

    if HBPT = '1' then                  -- handle hardware bpt
      nstatus.cpurust := c_cpurust_hbpt;
      nstatus.suspint :='1';
    end if;
    nstatus.suspext := ESUSP_I;

    -- handle cpususp transitions 
    if nstatus.suspint='1' or nstatus.suspext='1' then
      nstatus.cpususp := '1';
    elsif R_STATUS.suspint='0' and R_STATUS.suspext='0' then
      nstatus.cpususp := '0';
    end if;
    
    if nstatus.cmdack = '1' then        -- cmdack in next cycle ? Yes we test
                                           -- nstatus here !!
      nstatus.cmdbusy := '0';
      ndpcntl.cpdout_we := '1';
    end if;

    N_STATE  <= nstate;
    N_STATUS <= nstatus;
    N_CPUERR <= ncpuerr;
    N_IDSTAT <= nidstat;
    
    INT_ACK <= R_STATUS.intack;
    CRESET  <= R_STATUS.creset;
    BRESET  <= R_STATUS.breset;
    ESUSP_O <= R_STATUS.suspint;     -- FIXME_code: handle masking later
    
    DP_CNTL   <= ndpcntl;
    VM_CNTL   <= nvmcntl;
    VM_CNTL_L <= nvmcntl;

    nmmumoni.regnum := ndpcntl.gr_adst;
    nmmumoni.delta  := ndpcntl.ounit_const(3 downto 0);
    MMU_MONI <= nmmumoni;

    DM_STAT_SE.idle   <= idm_idle;
    DM_STAT_SE.cpbusy <= idm_cpbusy;
    DM_STAT_SE.istart <= nmmumoni.istart;
    DM_STAT_SE.idec   <= idm_idec;
    DM_STAT_SE.idone  <= idm_idone;
    DM_STAT_SE.itimer <= R_STATUS.itimer;
    DM_STAT_SE.pcload <= idm_pcload;
    DM_STAT_SE.vstart <= nmmumoni.vstart;

  end process proc_next;

  proc_cpstat : process (R_STATUS)
  begin
    CP_STAT         <= cp_stat_init;
    CP_STAT.cmdbusy <= R_STATUS.cmdbusy;
    CP_STAT.cmdack  <= R_STATUS.cmdack;
    CP_STAT.cmderr  <= R_STATUS.cmderr;
    CP_STAT.cmdmerr <= R_STATUS.cmdmerr;
    CP_STAT.cpugo   <= R_STATUS.cpugo;
    CP_STAT.cpustep <= R_STATUS.cpustep;
    CP_STAT.cpuwait <= R_STATUS.cpuwait;
    CP_STAT.cpususp <= R_STATUS.cpususp;
    CP_STAT.cpurust <= R_STATUS.cpurust;
    CP_STAT.suspint <= R_STATUS.suspint;
    CP_STAT.suspext <= R_STATUS.suspext;
  end process proc_cpstat;

  -- SNUM creation logic is conditional due to synthesis impact in vivado.
  -- SNUM = 'full state number' only available when dmscnt unit enabled.
  SNUM1 : if sys_conf_dmscnt generate
  begin
    proc_snum : process (R_STATE)
      variable isnum : slv8 := (others=>'0');
    begin
      isnum := (others=>'0');
      case R_STATE is
        -- STATE2SNUM mapper begin
        when s_idle           => isnum := x"00";
        when s_cp_regread     => isnum := x"01";
        when s_cp_rps         => isnum := x"02";
        when s_cp_memr_w      => isnum := x"03";
        when s_cp_memw_w      => isnum := x"04";
        when s_ifetch         => isnum := x"05";
        when s_ifetch_w       => isnum := x"06";
        when s_idecode        => isnum := x"07";
                                 
        when s_srcr_def       => isnum := x"08";
        when s_srcr_def_w     => isnum := x"09";
        when s_srcr_inc       => isnum := x"0a";
        when s_srcr_inc_w     => isnum := x"0b";
        when s_srcr_dec       => isnum := x"0c";
        when s_srcr_dec1      => isnum := x"0d";
        when s_srcr_ind       => isnum := x"0e";
        when s_srcr_ind1_w    => isnum := x"0f";
        when s_srcr_ind2      => isnum := x"10";
        when s_srcr_ind2_w    => isnum := x"11";
                                 
        when s_dstr_def       => isnum := x"12";
        when s_dstr_def_w     => isnum := x"13";
        when s_dstr_inc       => isnum := x"14";
        when s_dstr_inc_w     => isnum := x"15";
        when s_dstr_dec       => isnum := x"16";
        when s_dstr_dec1      => isnum := x"17";
        when s_dstr_ind       => isnum := x"18";
        when s_dstr_ind1_w    => isnum := x"19";
        when s_dstr_ind2      => isnum := x"1a";
        when s_dstr_ind2_w    => isnum := x"1b";
                                 
        when s_dstw_def       => isnum := x"1c";
        when s_dstw_def_w     => isnum := x"1d";
        when s_dstw_inc       => isnum := x"1e";
        when s_dstw_inc_w     => isnum := x"1f";
        when s_dstw_incdef_w  => isnum := x"20";
        when s_dstw_dec       => isnum := x"21";
        when s_dstw_dec1      => isnum := x"22";
        when s_dstw_ind       => isnum := x"23";
        when s_dstw_ind_w     => isnum := x"24";
        when s_dstw_def246    => isnum := x"25";
                                 
        when s_dsta_inc       => isnum := x"26";
        when s_dsta_incdef_w  => isnum := x"27";
        when s_dsta_dec       => isnum := x"28";
        when s_dsta_dec1      => isnum := x"29";
        when s_dsta_ind       => isnum := x"2a";
        when s_dsta_ind_w     => isnum := x"2b";
                                 
        when s_op_halt        => isnum := x"2c";
        when s_op_wait        => isnum := x"2d";
        when s_op_trap        => isnum := x"2e";
        when s_op_reset       => isnum := x"2f";
        when s_op_rts         => isnum := x"30";
        when s_op_rts_pop     => isnum := x"31";
        when s_op_rts_pop_w   => isnum := x"32";
        when s_op_spl         => isnum := x"33";
        when s_op_mcc         => isnum := x"34";
        when s_op_br          => isnum := x"35";
        when s_op_mark        => isnum := x"36";
        when s_op_mark1       => isnum := x"37";
        when s_op_mark_pop    => isnum := x"38";
        when s_op_mark_pop_w  => isnum := x"39";
        when s_op_sob         => isnum := x"3a";
        when s_op_sob1        => isnum := x"3b";
                                 
        when s_opg_gen        => isnum := x"3c";
        when s_opg_gen_rmw_w  => isnum := x"3d";
        when s_opg_mul        => isnum := x"3e";
        when s_opg_mul1       => isnum := x"3f";
        when s_opg_div        => isnum := x"40";
        when s_opg_div_cn     => isnum := x"41";
        when s_opg_div_cr     => isnum := x"42";
        when s_opg_div_sq     => isnum := x"43";
        when s_opg_div_sr     => isnum := x"44";
        when s_opg_div_quit   => isnum := x"45";
        when s_opg_ash        => isnum := x"46";
        when s_opg_ash_cn     => isnum := x"47";
        when s_opg_ashc       => isnum := x"48";
        when s_opg_ashc_cn    => isnum := x"49";
        when s_opg_ashc_wl    => isnum := x"4a";
                                 
        when s_opa_jsr        => isnum := x"4b";
        when s_opa_jsr1       => isnum := x"4c";
        when s_opa_jsr_push   => isnum := x"4d";
        when s_opa_jsr_push_w => isnum := x"4e";
        when s_opa_jsr2       => isnum := x"4f";
        when s_opa_jmp        => isnum := x"50";
        when s_opa_mtp        => isnum := x"51";
        when s_opa_mtp_pop_w  => isnum := x"52";
        when s_opa_mtp_reg    => isnum := x"53";
        when s_opa_mtp_mem    => isnum := x"54";
        when s_opa_mtp_mem_w  => isnum := x"55";
        when s_opa_mfp_reg    => isnum := x"56";
        when s_opa_mfp_mem    => isnum := x"57";
        when s_opa_mfp_mem_w  => isnum := x"58";
        when s_opa_mfp_dec    => isnum := x"59";
        when s_opa_mfp_push   => isnum := x"5a";
        when s_opa_mfp_push_w => isnum := x"5b";
                                 
        when s_abort_4        => isnum := x"5c";
        when s_abort_10       => isnum := x"5d";
        when s_trap_disp      => isnum := x"5e";
                                 
        when s_int_ext        => isnum := x"5f";
                                 
        when s_vec_getpc      => isnum := x"60";
        when s_vec_getpc_w    => isnum := x"61";
        when s_vec_getps      => isnum := x"62";
        when s_vec_getps_w    => isnum := x"63";
        when s_vec_getsp      => isnum := x"64";
        when s_vec_decsp      => isnum := x"65";
        when s_vec_pushps     => isnum := x"66";
        when s_vec_pushps_w   => isnum := x"67";
        when s_vec_pushpc     => isnum := x"68";
        when s_vec_pushpc_w   => isnum := x"69";
                                 
        when s_rti_getpc      => isnum := x"6a";
        when s_rti_getpc_w    => isnum := x"6b";
        when s_rti_getps      => isnum := x"6c";
        when s_rti_getps_w    => isnum := x"6d";
        when s_rti_newpc      => isnum := x"6e";
                                 
        when s_vmerr          => isnum := x"6f";
        when s_cpufail        => isnum := x"70";
                                 
        -- STATE2SNUM mapper end
        when others           => isnum := x"ff";
      end case;
      DM_STAT_SE.snum   <= isnum;
    end process proc_snum;
  end generate SNUM1;

  -- if dmscnt not enable setup SNUM based on state categories (currently 4)
  -- and a 'wait' indicator determined from monitoring VM_CNTL and VM_STAT
  SNUM0 : if not sys_conf_dmscnt generate
    signal R_VMWAIT : slbit := '0';  -- vmwait flag
  begin

    proc_vmwait: process (CLK)
    begin
      if rising_edge(CLK) then
        if GRESET = '1' then
          R_VMWAIT <= '0';
        else
          if VM_CNTL_L.req = '1' then
            R_VMWAIT <= '1';
          elsif VM_STAT.ack = '1' or VM_STAT.err = '1' or VM_STAT.fail='1' then
            R_VMWAIT <= '0';
          end if;
        end if;
      end if;
    end process proc_vmwait;

    proc_snum : process (R_STATE, R_VMWAIT)
      variable isnum_con : slbit := '0';
      variable isnum_ins : slbit := '0';
      variable isnum_vec : slbit := '0';
      variable isnum_err : slbit := '0';
    begin
      isnum_con := '0';
      isnum_ins := '0';
      isnum_vec := '0';
      isnum_err := '0';
      case R_STATE is
        when s_idle           => null;
        when s_cp_regread     => isnum_con := '1';
        when s_cp_rps         => isnum_con := '1';
        when s_cp_memr_w      => isnum_con := '1';
        when s_cp_memw_w      => isnum_con := '1';
        when s_ifetch         => isnum_ins := '1';
        when s_ifetch_w       => isnum_ins := '1';
        when s_idecode        => isnum_ins := '1';
                                 
        when s_srcr_def       => isnum_ins := '1';
        when s_srcr_def_w     => isnum_ins := '1';
        when s_srcr_inc       => isnum_ins := '1';
        when s_srcr_inc_w     => isnum_ins := '1';
        when s_srcr_dec       => isnum_ins := '1';
        when s_srcr_dec1      => isnum_ins := '1';
        when s_srcr_ind       => isnum_ins := '1';
        when s_srcr_ind1_w    => isnum_ins := '1';
        when s_srcr_ind2      => isnum_ins := '1';
        when s_srcr_ind2_w    => isnum_ins := '1';
                                 
        when s_dstr_def       => isnum_ins := '1';
        when s_dstr_def_w     => isnum_ins := '1';
        when s_dstr_inc       => isnum_ins := '1';
        when s_dstr_inc_w     => isnum_ins := '1';
        when s_dstr_dec       => isnum_ins := '1';
        when s_dstr_dec1      => isnum_ins := '1';
        when s_dstr_ind       => isnum_ins := '1';
        when s_dstr_ind1_w    => isnum_ins := '1';
        when s_dstr_ind2      => isnum_ins := '1';
        when s_dstr_ind2_w    => isnum_ins := '1';
                                 
        when s_dstw_def       => isnum_ins := '1';
        when s_dstw_def_w     => isnum_ins := '1';
        when s_dstw_inc       => isnum_ins := '1';
        when s_dstw_inc_w     => isnum_ins := '1';
        when s_dstw_incdef_w  => isnum_ins := '1';
        when s_dstw_dec       => isnum_ins := '1';
        when s_dstw_dec1      => isnum_ins := '1';
        when s_dstw_ind       => isnum_ins := '1';
        when s_dstw_ind_w     => isnum_ins := '1';
        when s_dstw_def246    => isnum_ins := '1';
                                 
        when s_dsta_inc       => isnum_ins := '1';
        when s_dsta_incdef_w  => isnum_ins := '1';
        when s_dsta_dec       => isnum_ins := '1';
        when s_dsta_dec1      => isnum_ins := '1';
        when s_dsta_ind       => isnum_ins := '1';
        when s_dsta_ind_w     => isnum_ins := '1';
                                 
        when s_op_halt        => isnum_ins := '1';
        when s_op_wait        => isnum_ins := '1';
        when s_op_trap        => isnum_ins := '1';
        when s_op_reset       => isnum_ins := '1';
        when s_op_rts         => isnum_ins := '1';
        when s_op_rts_pop     => isnum_ins := '1';
        when s_op_rts_pop_w   => isnum_ins := '1';
        when s_op_spl         => isnum_ins := '1';
        when s_op_mcc         => isnum_ins := '1';
        when s_op_br          => isnum_ins := '1';
        when s_op_mark        => isnum_ins := '1';
        when s_op_mark1       => isnum_ins := '1';
        when s_op_mark_pop    => isnum_ins := '1';
        when s_op_mark_pop_w  => isnum_ins := '1';
        when s_op_sob         => isnum_ins := '1';
        when s_op_sob1        => isnum_ins := '1';
                                 
        when s_opg_gen        => isnum_ins := '1';
        when s_opg_gen_rmw_w  => isnum_ins := '1';
        when s_opg_mul        => isnum_ins := '1';
        when s_opg_mul1       => isnum_ins := '1';
        when s_opg_div        => isnum_ins := '1';
        when s_opg_div_cn     => isnum_ins := '1';
        when s_opg_div_cr     => isnum_ins := '1';
        when s_opg_div_sq     => isnum_ins := '1';
        when s_opg_div_sr     => isnum_ins := '1';
        when s_opg_div_quit   => isnum_ins := '1';
        when s_opg_ash        => isnum_ins := '1';
        when s_opg_ash_cn     => isnum_ins := '1';
        when s_opg_ashc       => isnum_ins := '1';
        when s_opg_ashc_cn    => isnum_ins := '1';
        when s_opg_ashc_wl    => isnum_ins := '1';
                                 
        when s_opa_jsr        => isnum_ins := '1';
        when s_opa_jsr1       => isnum_ins := '1';
        when s_opa_jsr_push   => isnum_ins := '1';
        when s_opa_jsr_push_w => isnum_ins := '1';
        when s_opa_jsr2       => isnum_ins := '1';
        when s_opa_jmp        => isnum_ins := '1';
        when s_opa_mtp        => isnum_ins := '1';
        when s_opa_mtp_pop_w  => isnum_ins := '1';
        when s_opa_mtp_reg    => isnum_ins := '1';
        when s_opa_mtp_mem    => isnum_ins := '1';
        when s_opa_mtp_mem_w  => isnum_ins := '1';
        when s_opa_mfp_reg    => isnum_ins := '1';
        when s_opa_mfp_mem    => isnum_ins := '1';
        when s_opa_mfp_mem_w  => isnum_ins := '1';
        when s_opa_mfp_dec    => isnum_ins := '1';
        when s_opa_mfp_push   => isnum_ins := '1';
        when s_opa_mfp_push_w => isnum_ins := '1';
                                 
        when s_abort_4        => isnum_ins := '1';
        when s_abort_10       => isnum_ins := '1';
        when s_trap_disp      => isnum_ins := '1';
                                 
        when s_int_ext        => isnum_vec := '1';
                                 
        when s_vec_getpc      => isnum_vec := '1';
        when s_vec_getpc_w    => isnum_vec := '1';
        when s_vec_getps      => isnum_vec := '1';
        when s_vec_getps_w    => isnum_vec := '1';
        when s_vec_getsp      => isnum_vec := '1';
        when s_vec_decsp      => isnum_vec := '1';
        when s_vec_pushps     => isnum_vec := '1';
        when s_vec_pushps_w   => isnum_vec := '1';
        when s_vec_pushpc     => isnum_vec := '1';
        when s_vec_pushpc_w   => isnum_vec := '1';
                                 
        when s_rti_getpc      => isnum_vec := '1';
        when s_rti_getpc_w    => isnum_vec := '1';
        when s_rti_getps      => isnum_vec := '1';
        when s_rti_getps_w    => isnum_vec := '1';
        when s_rti_newpc      => isnum_vec := '1';
                                 
        when s_vmerr          => isnum_err := '1';
        when s_cpufail        => isnum_err := '1';
                                 
        when others           => null;
      end case;
      
      DM_STAT_SE.snum <= (others=>'0');
      DM_STAT_SE.snum(c_snum_f_con) <= isnum_con;
      DM_STAT_SE.snum(c_snum_f_ins) <= isnum_ins;
      DM_STAT_SE.snum(c_snum_f_vec) <= isnum_vec;
      DM_STAT_SE.snum(c_snum_f_err) <= isnum_err;
      DM_STAT_SE.snum(c_snum_f_vmw) <= R_VMWAIT;
      
    end process proc_snum;
  end generate SNUM0;
  
end syn;
