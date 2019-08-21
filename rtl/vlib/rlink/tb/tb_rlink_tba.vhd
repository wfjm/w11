-- $Id: tb_rlink_tba.vhd 1203 2019-08-19 21:41:03Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    tb_rlink_tba - sim
-- Description:    Test bench for rbus devices via rlink_tba
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 genlib/tb/clkdivce_tb
--                 rlink_tba
--                 rlink_core
--                 rbtba_aif   [UUT]
--                 rlink_mon
--                 rb_mon
--
-- To test:        generic, any rbtba_aif target
--
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; viv 2016.2-2019.1; ghdl 0.18-0.36
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-08-17  1203   4.0.2  fix for ghdl V0.36 -Whide warnings
-- 2016-09-10   806   4.0.1  use clkdivce_tb
-- 2014-12-20   616   4.0.1  add dcnt check (with -n=) and .ndef
-- 2014-09-21   595   4.0    now full rlink v4 iface, 4 bit STAT
-- 2014-08-15   583   3.5    rb_mreq addr now 16 bit
-- 2011-12-23   444   3.2    use new simclk/simclkcnt
-- 2011-11-22   432   3.1.1  now numeric_std clean
-- 2010-12-29   351   3.1    use rbtba_aif now, support _ssim level again
-- 2010-12-28   350   3.0.3  list cmd address, list send data for wreg/init
-- 2010-12-27   349   3.0.2  suppress D CHECK message for all masked rreg/rblk
-- 2010-12-25   348   3.0.1  drop RL_FLUSH support, add RL_MONI for rlink_core
-- 2010-12-24   347   3.0    rm tb_rritba->tb_rlink_tba, CP_*->RL_*;rbus v3 port
-- 2010-06-07   302   2.5    use sop/eop framing instead of soc+chaining
-- 2010-06-05   301   2.1.3  rename _rpmon -> _rbmon, .rpmon -> .rbmon
-- 2010-06-03   299   2.1.2  use sv_ prefix for shared variables
-- 2010-05-02   287   2.1.1  ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT signal from interfaces
-- 2010-04-03   274   2.1    add CP_FLUSH for rri_core
-- 2008-08-24   162   2.0    with new rb_mreq/rb_sres interface
-- 2008-03-24   129   1.1.4  CLK_CYCLE now 31 bits
-- 2008-03-02   121   1.1.3  default .sdef now checks for errors, ignore
--                           status bits and the attn flag.
-- 2008-01-20   112   1.1.2  rename clkgen->clkdivce
-- 2007-12-23   105   1.1.1  add .dbas[io] (allows to set base for data values)
-- 2007-11-24    98   1.1    add RP_IINT support
-- 2007-10-26    92   1.0.2  use DONE timestamp at end of execution
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-09-09    81   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.genlib.all;
use work.comlib.all;
use work.rblib.all;
use work.rlinklib.all;
use work.rlinktblib.all;
use work.simlib.all;

entity tb_rlink_tba is
end tb_rlink_tba;

architecture sim of tb_rlink_tba is
  
  signal CLK : slbit := '0';
  signal CE_MSEC : slbit := '0';
  signal RESET : slbit := '0';
  signal TBA_CNTL : rlink_tba_cntl_type := rlink_tba_cntl_init;
  signal TBA_DI : slv16 := (others=>'0');
  signal TBA_STAT : rlink_tba_stat_type := rlink_tba_stat_init;
  signal TBA_DO : slv16 := (others=>'0');
  signal RL_DI : slv9 := (others=>'0');
  signal RL_ENA : slbit := '0';
  signal RL_BUSY : slbit := '0';
  signal RL_DO : slv9 := (others=>'0');
  signal RL_VAL : slbit := '0';
  signal RL_HOLD : slbit := '0';
  signal RL_MONI : rl_moni_type := rl_moni_init;
  
  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;
  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4 := (others=>'0');

  signal RB_MREQ_aval : slbit := '0';
  signal RB_MREQ_re   : slbit := '0';
  signal RB_MREQ_we   : slbit := '0';
  signal RB_MREQ_initt: slbit := '0';
  signal RB_MREQ_addr : slv16 := (others=>'0');
  signal RB_MREQ_din  : slv16 := (others=>'0');
  signal RB_SRES_ack  : slbit := '0';
  signal RB_SRES_busy : slbit := '0';
  signal RB_SRES_err  : slbit := '0';
  signal RB_SRES_dout : slv16 := (others=>'0');

  signal RLMON_EN : slbit := '0';
  signal RBMON_EN : slbit := '0';

  signal N_CMD_CODE : string(1 to 4) := (others=>' ');
  signal N_CMD_ADDR : slv16 := (others=>'0');
  signal N_CMD_DATA : slv16 := (others=>'0');
  signal N_CHK_DATA : boolean := false;
  signal N_REF_DATA : slv16 := (others=>'0');
  signal N_MSK_DATA : slv16 := (others=>'0');
  signal N_CHK_DONE : boolean := false;
  signal N_REF_DONE : slv16 := (others=>'0');
  signal N_CHK_STAT : boolean := false;
  signal N_REF_STAT : slv8 := (others=>'0');
  signal N_MSK_STAT : slv8 := (others=>'0');

  signal R_CMD_CODE : string(1 to 4) := (others=>' ');
  signal R_CMD_ADDR : slv16 := (others=>'0');
  signal R_CMD_DATA : slv16 := (others=>'0');
  signal R_CHK_DATA : boolean := false;
  signal R_REF_DATA : slv16 := (others=>'0');
  signal R_MSK_DATA : slv16 := (others=>'0');
  signal R_CHK_DONE : boolean := false;
  signal R_REF_DONE : slv16 := (others=>'0');
  signal R_CHK_STAT : boolean := false;
  signal R_REF_STAT : slv8 := (others=>'0');
  signal R_MSK_STAT : slv8 := (others=>'0');

  signal CLK_STOP : slbit := '0';
  signal CLK_CYCLE : integer := 0;

  shared variable sv_dbasi : integer := 2;
  shared variable sv_dbaso : integer := 2;

  constant clock_period : Delay_length :=  20 ns;
  constant clock_offset : Delay_length := 200 ns;
  constant setup_time : Delay_length :=  5 ns;
  constant c2out_time : Delay_length := 10 ns;

begin

  CLKGEN : simclk
    generic map (
      PERIOD => clock_period,
      OFFSET => clock_offset)
    port map (
      CLK       => CLK,
      CLK_STOP  => CLK_STOP
    );

  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);

  CLKDIV : entity work.clkdivce_tb
    generic map (
      CDUWIDTH => 6,
      USECDIV  => 4,
      MSECDIV  => 5)
    port map (
      CLK     => CLK,
      CE_USEC => open,
      CE_MSEC => CE_MSEC
    );

  TBA : rlink_tba
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CNTL    => TBA_CNTL,
      DI      => TBA_DI,
      STAT    => TBA_STAT,
      DO      => TBA_DO,
      RL_DI   => RL_DI,
      RL_ENA  => RL_ENA,
      RL_BUSY => RL_BUSY,
      RL_DO   => RL_DO,
      RL_VAL  => RL_VAL,
      RL_HOLD => RL_HOLD
    );

  RLINK : rlink_core
    generic map (
      BTOWIDTH =>  6,
      RTAWIDTH => 12,
      SYSID    => (others=>'0'))
    port map (
      CLK      => CLK,
      CE_INT   => CE_MSEC,
      RESET    => RESET,
      RL_DI    => RL_DI,
      RL_ENA   => RL_ENA,
      RL_BUSY  => RL_BUSY,
      RL_DO    => RL_DO,
      RL_VAL   => RL_VAL,
      RL_HOLD  => RL_HOLD,
      RL_MONI  => RL_MONI,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,      
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT
    );

  RB_MREQ_aval <= RB_MREQ.aval;
  RB_MREQ_re   <= RB_MREQ.re;
  RB_MREQ_we   <= RB_MREQ.we;
  RB_MREQ_initt<= RB_MREQ.init;
  RB_MREQ_addr <= RB_MREQ.addr;
  RB_MREQ_din  <= RB_MREQ.din;

  RB_SRES.ack  <= RB_SRES_ack;
  RB_SRES.busy <= RB_SRES_busy;
  RB_SRES.err  <= RB_SRES_err;
  RB_SRES.dout <= RB_SRES_dout;
  
  UUT : rbtba_aif
    port map (
      CLK          => CLK,
      RESET        => RESET,
      RB_MREQ_aval => RB_MREQ_aval,
      RB_MREQ_re   => RB_MREQ_re,
      RB_MREQ_we   => RB_MREQ_we,
      RB_MREQ_initt=> RB_MREQ_initt,
      RB_MREQ_addr => RB_MREQ_addr,
      RB_MREQ_din  => RB_MREQ_din,
      RB_SRES_ack  => RB_SRES_ack,  
      RB_SRES_busy => RB_SRES_busy, 
      RB_SRES_err  => RB_SRES_err,  
      RB_SRES_dout => RB_SRES_dout, 
      RB_LAM       => RB_LAM,
      RB_STAT      => RB_STAT
    );
  
  RLMON : rlink_mon
    generic map (
      DWIDTH => RL_DI'length)
    port map (
      CLK       => CLK,
      CLK_CYCLE => CLK_CYCLE,
      ENA       => RLMON_EN,
      RL_DI     => RL_DI,
      RL_ENA    => RL_ENA,
      RL_BUSY   => RL_BUSY,
      RL_DO     => RL_DO,
      RL_VAL    => RL_VAL,
      RL_HOLD   => RL_HOLD
    );

  RBMON : rb_mon
    port map (
      CLK       => CLK,
      CLK_CYCLE => CLK_CYCLE,
      ENA       => RBMON_EN,
      RB_MREQ   => RB_MREQ,
      RB_SRES   => RB_SRES,      
      RB_LAM    => RB_LAM,
      RB_STAT   => RB_STAT
    );

  proc_stim: process
    file fstim : text open read_mode is "tb_rlink_tba_stim";
    variable iline : line;
    variable oline : line;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable idelta : integer := 0;
    variable ien : slbit := '0';
    variable iaddr : slv16 := (others=>'0');
    variable idata : slv16 := (others=>'0');
    variable bcnt : integer := 0;
    variable ccnt : integer := 0;
    variable cmax : integer := 32;
    variable nwait : integer := 0;
    variable amnemo : string(1 to 6) := (others=>' ');
    variable newline : boolean := true;
    variable chk_data : boolean := false;
    variable ref_data : slv16 := (others=>'0');
    variable msk_data : slv16 := (others=>'0');
    variable chk_stat : boolean := false;
    variable ref_stat : slv8 := (others=>'0');
    variable msk_stat : slv8 := (others=>'0');
    variable chk_sdef : boolean := true;
    variable ref_sdef : slv8 := (others=>'0');
    variable msk_sdef : slv8 := "11111000";  -- ignore status bits and attn
    variable chk_ndef : boolean := true;

    type amrec_type is record
      name : string(1 to 6);
      addr : slv16;
    end record;
    constant amrec_init : amrec_type := ((others=>' '),
                                         (others=>'0'));
    
    constant amtbl_size : integer := 256;
    type amtbl_type is array (1 to amtbl_size) of amrec_type;

    variable amtbl_defs : integer := 0;
    variable amtbl : amtbl_type := (others=>amrec_init);
    
    procedure get_addr(L: inout line;
                       addr: out slv16) is
      variable ichar : character := ' ';
      variable name : string(1 to 6) := (others=>' ');
      variable lok : boolean := false;
      variable liaddr : slv16 := (others=>'0');
      variable iaddr_or : slv16 := (others=>'0');
    begin

      readwhite(L);

      readoptchar(L, '.', lok);
      if lok then
        readword_ea(L, name);
        for i in 1 to amtbl_defs loop
          if amtbl(i).name = name then
            liaddr := amtbl(i).addr;
            readoptchar(L, '|', lok);
            if lok then
              readgen_ea(L, iaddr_or);
              for j in iaddr_or'range loop
                if iaddr_or(j) = '1' then
                  liaddr(j) := '1';
                end if;
              end loop;
            end if;
            addr := liaddr;
            return;
          end if;
        end loop;
        report "address mnemonic not defined: " & name
          severity failure;
      end if;
      
      readgen_ea(L, addr);
      
    end procedure get_addr;

    procedure cmd_waitdone is
      variable lnwait : integer := 0;
    begin
      lnwait := 0;
      while TBA_STAT.busy='1' loop
        lnwait := lnwait + 1;
        assert lnwait<2000 report "assert(lnwait<2000)" severity failure;
        wait for clock_period;
      end loop;
    end procedure cmd_waitdone;

    procedure setup_check_n (
      pbcnt : in integer)
    is
      variable chk_done : boolean := false;
      variable ref_done : slv16 := (others=>'0');
    begin
      readtagval_ea(iline, "n", chk_done, ref_done, 10);
      if chk_done then
        N_CHK_DONE <= chk_done;
        N_REF_DONE <= ref_done;
      else
        N_CHK_DONE <= chk_ndef;
        N_REF_DONE <= slv(to_unsigned(pbcnt,16));
      end if;
    end procedure setup_check_n;

    procedure setup_check_d is
      variable lchk_data : boolean := false;
      variable lref_data : slv16 := (others=>'0');
      variable lmsk_data : slv16 := (others=>'0');
    begin
      readtagval2_ea(iline, "d", lchk_data, lref_data, lmsk_data, sv_dbasi);
      N_CHK_DATA <= lchk_data;
      N_REF_DATA <= lref_data;
      N_MSK_DATA <= lmsk_data;
    end procedure setup_check_d;

    procedure setup_check_s is
      variable lchk_stat : boolean := false;
      variable lref_stat : slv8 := (others=>'0');
      variable lmsk_stat : slv8 := (others=>'0');
    begin
      readtagval2_ea(iline, "s", lchk_stat, lref_stat, lmsk_stat);
      if lchk_stat then
        N_CHK_STAT <= lchk_stat;
        N_REF_STAT <= lref_stat;
        N_MSK_STAT <= lmsk_stat;
      else
        N_CHK_STAT <= chk_sdef;
        N_REF_STAT <= ref_sdef;
        N_MSK_STAT <= msk_sdef;
      end if;
    end procedure setup_check_s;

    procedure cmd_start (
      pcmd : in slv3;
      paddr : in slv16 := (others=>'0');
      pdata : in slv16 := (others=>'0');
      pbcnt : in integer := 1) is
    begin                  
      TBA_CNTL      <= rlink_tba_cntl_init;
      TBA_CNTL.cmd  <= pcmd;
      TBA_CNTl.addr <= paddr;
      TBA_CNTL.cnt  <= slv(to_unsigned(pbcnt,16));
      TBA_DI        <= pdata;

      ccnt := ccnt + 1;
      if ccnt >= cmax then
        ccnt := 0;
        TBA_CNTL.eop  <= '1';
      end if;

      TBA_CNTL.ena  <= '1';
      wait for clock_period;
      TBA_CNTL.ena  <= '0';
      TBA_CNTL.eop  <= '0';
      
    end procedure cmd_start;
      
  begin
    
    wait for clock_offset - setup_time;

    file_loop: while not endfile(fstim) loop

      readline (fstim, iline);
      
      if TBA_STAT.ack = '1' and         -- if ack cycle
         iline'length>0 then              -- and non empty line
        if iline(1) = 'C' then            -- and leading 'C'
          wait for clock_period;            -- wait cycle to ensure that comment
                                            -- comes after moni response
        end if;
      end if;
      
      readcomment(iline, ok);
      next file_loop when ok;

      readword(iline, dname, ok);
      if ok then
        
        N_CMD_CODE <= "    ";
        N_CHK_DATA <= false;
        N_CHK_DONE <= false;
        N_CHK_STAT <= false;

        case dname is
          when ".mode " =>              -- .mode
            readword_ea(iline, dname);
            assert dname="rri   "
              report "assert .mode == rri" severity failure;

          when ".rlmon" =>              -- .rlmon
            read_ea(iline, ien);
            RLMON_EN <= ien;
            wait for 2*clock_period;      -- wait for monitor to start

          when ".rbmon" =>              -- .rbmon
            read_ea(iline, ien);
            RBMON_EN <= ien;
            wait for 2*clock_period;      -- wait for monitor to start

          when ".sdef " =>              -- .sdef , set default for status chk
            readtagval2_ea(iline, "s", chk_sdef, ref_sdef, msk_sdef);

          when ".ndef " =>              -- .ndef , enable/disable done chk
            read_ea(iline, idata(0));
            chk_ndef := idata(0) = '1';

          when ".amclr" =>              -- .amclr , clear addr mnemo table
            amtbl_defs := 0;
            amtbl := (others=>amrec_init);
            
          when ".amdef" =>              -- .amdef , define addr mnemo table
            assert amtbl_defs<amtbl_size
              report "assert(amtbl_defs<amtbl_size): too many .amdef's"
              severity failure;
            readword_ea(iline, amnemo);
            readgen_ea(iline, iaddr);
            amtbl_defs := amtbl_defs + 1;
            amtbl(amtbl_defs).name := amnemo;
            amtbl(amtbl_defs).addr := iaddr;
            
          when ".dbasi" =>              -- .dbasi
            read_ea(iline, idelta);
            assert idelta=2 or idelta=8 or idelta=16
              report "assert(dbasi = 2,8, or 16)"
              severity failure;
            sv_dbasi := idelta;
            
          when ".dbaso" =>              -- .dbaso
            read_ea(iline, idelta);
            assert idelta=2 or idelta=8 or idelta=16
              report "assert(dbaso = 2,8, or 16)"
              severity failure;
            sv_dbaso := idelta;

          when ".cmax " =>              -- .cmax
            readint_ea(iline, cmax, 1, 32);

          when ".reset" =>              -- .reset 
            write(oline, string'(".reset"));
            writeline(output, oline);
            RESET <= '1';
            wait for clock_period;
            RESET <= '0';
            wait for 9*clock_period;
            
          when ".wait " =>              -- .wait
            read_ea(iline, idelta);
            wait for idelta*clock_period;
            
          when ".wtlam" =>              -- .wtlam
            read_ea(iline, idelta);
            nwait := 0;
            loop
              if TBA_STAT.ano='1' or nwait>=idelta then
                writetimestamp(oline, CLK_CYCLE, ": .wtlam" & "  nwait=");
                write(oline, nwait, left);
                if TBA_STAT.ano = '0' then
                  write(oline, string'(" FAIL TIMEOUT"));
                end if;
                writeline(output, oline);
                exit;
              end if;
              nwait := nwait + 1;
              wait for clock_period;
            end loop;

          when ".eop  " =>              -- .eop
            TBA_CNTL     <= rlink_tba_cntl_init;
            TBA_CNTL.eop <= '1';
            wait for clock_period;
            TBA_CNTL.eop <= '0';
            wait for clock_period;        -- wait (or rlink_tba will hang...)
            ccnt := 0;
            
          when "rreg  " =>              -- rreg
            N_CMD_CODE <= dname(N_CMD_CODE'range);
            get_addr(iline, iaddr);
            N_CMD_ADDR <= iaddr;
            N_CMD_DATA <= (others=>'Z');
            setup_check_d;
            setup_check_s;
            cmd_start(pcmd=>c_rlink_cmd_rreg, paddr=>iaddr);
            cmd_waitdone;
                        
          when "rblk  " =>              -- rblk
            N_CMD_CODE <= dname(N_CMD_CODE'range);
            get_addr(iline, iaddr);
            N_CMD_ADDR <= iaddr;
            N_CMD_DATA <= (others=>'Z');
            read_ea(iline, bcnt);
            assert bcnt>0 report "assert(bcnt>0)" severity failure;
            setup_check_n(bcnt);
            setup_check_s;
            cmd_start(pcmd=>c_rlink_cmd_rblk, paddr=>iaddr, pbcnt=>bcnt);

            testempty_ea(iline);
            newline := true;
            for i in 1 to bcnt loop
              while TBA_STAT.bwe='0' loop
                wait for clock_period;
              end loop;
              
              if newline then
                rblk_line: loop
                  readline (fstim, iline);
                  readcomment(iline, ok);
                  exit rblk_line when not ok;
                end loop;
              end if;
              readtagval2_ea(iline, "d", chk_data, ref_data, msk_data,sv_dbasi);
              N_CHK_DATA <= chk_data;
              N_REF_DATA <= ref_data;
              N_MSK_DATA <= msk_data;
              testempty(iline, newline);
              wait for clock_period;
            end loop;
            N_CHK_DATA <= false;
            cmd_waitdone;
            
          when "wreg  " =>              -- wreg
            N_CMD_CODE <= dname(N_CMD_CODE'range);
            get_addr(iline, iaddr);
            N_CMD_ADDR <= iaddr;
            readgen_ea(iline, idata, sv_dbasi);
            N_CMD_DATA <= idata;
            setup_check_s;
            cmd_start(pcmd=>c_rlink_cmd_wreg, paddr=>iaddr, pdata=>idata);
            cmd_waitdone;
            
          when "wblk  " =>              -- wblk
            N_CMD_CODE <= dname(N_CMD_CODE'range);
            get_addr(iline, iaddr);
            N_CMD_ADDR <= iaddr;
            N_CMD_DATA <= (others=>'Z');
            read_ea(iline, bcnt);
            assert bcnt>0 report "assert(bcnt>0)" severity failure;
            setup_check_n(bcnt);
            setup_check_s;
            cmd_start(pcmd=>c_rlink_cmd_wblk, paddr=>iaddr, pbcnt=>bcnt);

            testempty_ea(iline);
            newline := true;
            for i in 1 to bcnt loop
              while TBA_STAT.bre='0' loop
                wait for clock_period;
              end loop;
              if newline then
                wblk_line: loop
                  readline (fstim, iline);
                  readcomment(iline, ok);
                  exit wblk_line when not ok;
                end loop;
              end if;
              readgen_ea(iline, idata, sv_dbasi);
              TBA_DI <= idata;
              testempty(iline, newline);
              wait for clock_period;
            end loop;            
            cmd_waitdone;
            
          when "labo  " =>              -- labo
            N_CMD_CODE <= dname(N_CMD_CODE'range);
            N_CMD_ADDR <= (others=>'0');
            N_CMD_DATA <= (others=>'Z');
            setup_check_d;
            setup_check_s;
            cmd_start(pcmd=>c_rlink_cmd_labo);
            cmd_waitdone;
            
          when "attn  " =>              -- attn
            N_CMD_CODE <= dname(N_CMD_CODE'range);
            N_CMD_ADDR <= (others=>'0');
            N_CMD_DATA <= (others=>'Z');
            setup_check_d;
            setup_check_s;
            cmd_start(pcmd=>c_rlink_cmd_attn);
            cmd_waitdone;
            
          when "init  " =>              -- init
            N_CMD_CODE <= dname(N_CMD_CODE'range);
            get_addr(iline, iaddr);
            N_CMD_ADDR <= iaddr;
            readgen_ea(iline, idata, sv_dbasi);
            N_CMD_DATA <= idata;
            setup_check_s;
            cmd_start(pcmd=>c_rlink_cmd_init, paddr=>iaddr, pdata=>idata);
            cmd_waitdone;
            
          when others =>                -- bad command
            write(oline, string'("?? unknown command: "));
            write(oline, dname);
            writeline(output, oline);
            report "aborting" severity failure;
        end case;

      else
        report "failed to find command" severity failure;

      end if;

      testempty_ea(iline);
      
    end loop; -- file_loop:

    wait for 4*clock_period;
    CLK_STOP <= '1';

    writetimestamp(oline, CLK_CYCLE, ": DONE ");
    writeline(output, oline);

    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end

  end process proc_stim;

  proc_moni: process
    variable oline : line;
    variable chk_ok : boolean := true;
  begin

    loop
      wait until rising_edge(CLK);
      R_CMD_CODE <= N_CMD_CODE;
      R_CMD_ADDR <= N_CMD_ADDR;
      R_CMD_DATA <= N_CMD_DATA;
      R_CHK_DATA <= N_CHK_DATA;
      R_REF_DATA <= N_REF_DATA;
      R_MSK_DATA <= N_MSK_DATA;
      R_CHK_DONE <= N_CHK_DONE;
      R_REF_DONE <= N_REF_DONE;
      R_CHK_STAT <= N_CHK_STAT;
      R_REF_STAT <= N_REF_STAT;
      R_MSK_STAT <= N_MSK_STAT;

      if TBA_STAT.bwe = '1' then
        writetimestamp(oline, CLK_CYCLE, ": rblk ");
        writehex(oline, R_CMD_ADDR, right, 4);
        write(oline, string'("     bwe=1   "));
        writegen(oline, TBA_DO, right, base=>sv_dbaso);
        if N_CHK_DATA then
          if N_MSK_DATA /= "1111111111111111" then -- not all masked off
            write(oline, string'("  .D.-CHECK"));
          else
            write(oline, string'("  ...-CHECK"));
          end if;
          if unsigned((TBA_DO xor N_REF_DATA) and (not N_MSK_DATA)) /= 0 then
            write(oline, string'(" FAIL d="));
            writegen(oline, N_REF_DATA, base=>sv_dbaso);
            if unsigned(N_MSK_DATA) /= 0 then
              write(oline, string'(","));
              writegen(oline, N_MSK_DATA, base=>sv_dbaso);
              end if;
          else
            write(oline, string'(" OK"));
          end if;
        end if;
        writeline(output, oline);
      end if;
        
      if TBA_STAT.ack = '1' then
        writetimestamp(oline, CLK_CYCLE, ": ");
        write(oline, R_CMD_CODE);
        writehex(oline, R_CMD_ADDR, right, 5);
        write(oline, string'("  "));
        write(oline, TBA_STAT.err, right, 1);
        write(oline, TBA_STAT.stat, right, 9);
        write(oline, string'(" "));
        if R_CMD_CODE="wreg" or R_CMD_CODE="init" then
          writegen(oline, R_CMD_DATA, right, base=>sv_dbaso);
        else
          writegen(oline, TBA_DO, right, base=>sv_dbaso);
        end if;
        if R_CHK_DATA or R_CHK_DONE or R_CHK_STAT then
          chk_ok := true;
          write(oline, string'("  "));
          if R_CHK_DONE then
            write(oline, string'("N"));
          else
            write(oline, string'("."));
          end if;
          if R_CHK_DATA and R_MSK_DATA/="1111111111111111" then
            write(oline, string'("D"));
          else
            write(oline, string'("."));
          end if;
          if R_CHK_STAT and R_MSK_STAT/="11111111" then
            write(oline, string'("S"));
          else
            write(oline, string'("."));
          end if;
          write(oline, string'("-CHECK"));
          if R_CHK_DONE then
            if TBA_STAT.dcnt /=  R_REF_DONE then
              chk_ok := false;
              write(oline, string'(" FAIL n="));
              write(oline, to_integer(unsigned(R_REF_DONE)));
            end if;
          end if;
          if R_CHK_DATA then
            if unsigned((TBA_DO xor R_REF_DATA) and (not R_MSK_DATA)) /= 0 then
              chk_ok := false;
              write(oline, string'(" FAIL d="));
              writegen(oline, R_REF_DATA, base=>sv_dbaso);
              if unsigned(R_MSK_DATA) /= 0 then
                write(oline, string'(","));
                writegen(oline, R_MSK_DATA, base=>sv_dbaso);
              end if;
            end if;
          end if;
          if R_CHK_STAT then
            if unsigned((TBA_STAT.stat xor R_REF_STAT) and
                        (not R_MSK_STAT)) /= 0 then
              chk_ok := false;
              write(oline, string'(" FAIL s="));
              write(oline, R_REF_STAT);
              if unsigned(R_MSK_STAT) /= 0 then
                write(oline, string'(","));
                write(oline, R_MSK_STAT);
              end if;
            end if;
          end if;
          if chk_ok then
            write(oline, string'(" OK"));
          end if;
        end if;
        writeline(output, oline);
        
      end if;
      
      if TBA_STAT.ano = '1' then
        writetimestamp(oline, CLK_CYCLE, ": ---- attn notify ---- ");
        write(oline, TBA_STAT.apat, right, 16);
        writeline(output, oline);
      end if;
        
    end loop;
      
  end process proc_moni;

end sim;
