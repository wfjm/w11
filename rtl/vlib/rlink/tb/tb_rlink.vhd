-- $Id: tb_rlink.vhd 444 2011-12-25 10:04:58Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_rlink - sim
-- Description:    Test bench for rlink_core
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 genlib/clkdivce
--                 rbus/tbd_tester
--                 rbus/rb_mon
--                 rlink/rlink_mon
--                 tbd_rlink_gen [UUT]
--
-- To test:        rlink_core     (via tbd_rlink_direct)
--                 rlink_base     (via tbd_rlink_serport)
--                 rlink_serport  (via tbd_rlink_serport)
--
-- Target Devices: generic
-- Tool versions:  xst 8.2, 9.1, 9.2, 11.4, 12.1, 13.1; ghdl 0.18-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   3.1    use new simclk/simclkcnt
-- 2011-11-19   427   3.0.7  fix crc8_update_tbl usage; now numeric_std clean
-- 2010-12-29   351   3.0.6  use new rbd_tester addr 111100xx (from 111101xx)
-- 2010-12-26   348   3.0.5  use simbus to export clkcycle (for tbd_..serport)
-- 2010-12-23   347   3.0.4  use rb_mon, rlink_mon directly; rename CP_*->RL_*
-- 2010-12-22   346   3.0.3  add .rlmon and .rbmon commands
-- 2010-12-21   345   3.0.2  rename commands .[rt]x... to [rt]x...;
--                           add .[rt]x(idle|attn) cmds; remove 'bbbbbbbb' cmd
-- 2010-12-12   344   3.0.1  add .attn again; add .txbad, .txoof; ren oob->oof
-- 2010-12-05   343   3.0    rri->rlink renames; port to rbus V3 protocol;
--                           use rbd_tester instead of sim target;
-- 2010-06-06   302   2.5    use sop/eop framing instead of soc+chaining
-- 2010-06-03   299   2.2.2  new init encoding (WE=0/1 int/ext);use sv_ prefix
--                           for shared variables 
-- 2010-05-02   287   2.2.1  ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT signal from interfaces
-- 2010-04-03   274   2.2    add CE_USEC in tbd_rri_gen interface
-- 2009-03-14   197   2.1    remove records in interface to allow _ssim usage
-- 2008-08-24   162   2.0    with new rb_mreq/rb_sres interface
-- 2008-03-24   129   1.1.2  CLK_CYCLE now 31 bits
-- 2008-01-20   112   1.1.1  rename clkgen->clkdivce
-- 2007-11-24    98   1.1    add RP_IINT support, add checkmiss_tx to test
--                           for missing responses
-- 2007-10-26    92   1.0.2  add DONE timestamp at end of execution
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-09-09    81   1.0    Initial version 
------------------------------------------------------------------------------
-- command set:
--   .reset                               assert RESET for 1 clk
--   .rlmon ien                           enable rlink monitor
--   .rbmon ien                           enable rbus monitor
--   .wait n                              wait n clks
--   .iowt n                              wait n clks for rlink i/o; auto-extend
--   .attn dat(16)                        pulse attn lines with dat
--   txsop                                send <sop>
--   txeop                                send <eop>
--   txnak                                send <nak>
--   txidle                               send <idle>
--   txattn                               send <attn>
--   tx8   dat(8)                         send  8 bit value
--   tx16  dat(16)                        send 16 bit value
--   txcrc                                send crc
--   txbad                                send bad (inverted) crc
--   txc   cmd(8)                         send cmd - crc
--   txca  cmd(8) addr(8)                 send cmd - addr - crc
--   txcad cmd(8) addr(8) dat(16)         send cmd - addr - dl dh - crc
--   txcac cmd(8) addr(8) cnt(8)          send cmd - addr - cnt - crc
--   txoof dat(9)                         send out-of-frame symbol
--   rxsop                                reset rx list; expect sop
--   rxeop                                expect <eop>
--   rxnak                                expect <nak>
--   rxidle                               expect <idle>
--   rxattn                               expect <attn>
--   rx8   dat(8)                         expect  8 bit value
--   rx16  dat(16)                        expect 16 bit value
--   rxcrc                                expect crc
--   rxcs  cmd(8) stat(8)                 expect cmd - stat - crc
--   rxcds cmd(8) dat(16) stat(8)         expect cmd - dl dh - stat - crc
--   rxccd cmd(8) ccmd(8) dat(16) stat(8) expect cmd - ccmd - dl dh - stat - crc
--   rxoof dat(9)                         expect out-of-frame symbol
--
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
use work.rbdlib.all;
use work.rlinklib.all;
use work.simlib.all;

entity tb_rlink is
end tb_rlink;

architecture sim of tb_rlink is
  
  signal CLK : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';
  signal RESET : slbit := '0';
  signal RL_DI : slv9 := (others=>'0');
  signal RL_ENA : slbit := '0';
  signal RL_BUSY : slbit := '0';
  signal RL_DO : slv9 := (others=>'0');
  signal RL_VAL : slbit := '0';
  signal RL_HOLD : slbit := '0';
  signal RB_MREQ_aval : slbit := '0';
  signal RB_MREQ_re : slbit := '0';
  signal RB_MREQ_we : slbit := '0';
  signal RB_MREQ_initt: slbit := '0';
  signal RB_MREQ_addr : slv8 := (others=>'0');
  signal RB_MREQ_din : slv16 := (others=>'0');
  signal RB_SRES_ack : slbit := '0';
  signal RB_SRES_busy : slbit := '0';
  signal RB_SRES_err : slbit := '0';
  signal RB_SRES_dout : slv16 := (others=>'0');
  signal RB_LAM_TBENCH : slv16 := (others=>'0');
  signal RB_LAM_TESTER : slv16 := (others=>'0');
  signal RB_LAM : slv16 := (others=>'0');
  signal RB_STAT : slv3 := (others=>'0');
  signal TXRXACT : slbit := '0';

  signal RLMON_EN : slbit := '0';
  signal RBMON_EN : slbit := '0';

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;
  
  signal CLK_STOP : slbit := '0';
  signal CLK_CYCLE : integer := 0;

  constant slv9_zero  : slv9  := (others=>'0');
  constant slv16_zero : slv16 := (others=>'0');
  
  type slv9_array_type  is array (0 to 255) of slv9;
  type slv16_array_type is array (0 to 255) of slv16;

  shared variable sv_rxlist : slv9_array_type := (others=>slv9_zero);
  shared variable sv_nrxlist : natural := 0;
  shared variable sv_rxind : natural := 0;

  constant clock_period : time :=  20 ns;
  constant clock_offset : time := 200 ns;
  constant setup_time : time :=  5 ns;
  constant c2out_time : time := 10 ns;

component tbd_rlink_gen is              -- rlink, generic tb design interface
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit;                  -- rlink ito time unit clock enable
    CE_USEC : in slbit;                 -- 1 usec clock enable
    RESET  : in slbit;                  -- reset
    RL_DI : in slv9;                    -- rlink: data in
    RL_ENA : in slbit;                  -- rlink: data enable
    RL_BUSY : out slbit;                -- rlink: data busy
    RL_DO : out slv9;                   -- rlink: data out
    RL_VAL : out slbit;                 -- rlink: data valid
    RL_HOLD : in slbit;                 -- rlink: data hold
    RB_MREQ_aval : out slbit;           -- rbus: request - aval
    RB_MREQ_re : out slbit;             -- rbus: request - re
    RB_MREQ_we : out slbit;             -- rbus: request - we
    RB_MREQ_initt: out slbit;           -- rbus: request - init; avoid name coll
    RB_MREQ_addr : out slv8;            -- rbus: request - addr
    RB_MREQ_din : out slv16;            -- rbus: request - din
    RB_SRES_ack : in slbit;             -- rbus: response - ack
    RB_SRES_busy : in slbit;            -- rbus: response - busy
    RB_SRES_err : in slbit;             -- rbus: response - err
    RB_SRES_dout : in slv16;            -- rbus: response - dout
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3;                  -- rbus: status flags
    TXRXACT : out slbit                 -- txrx active flag
  );
end component;

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

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 6,
      USECDIV  => 4,
      MSECDIV  => 5)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  RB_MREQ.aval <= RB_MREQ_aval;
  RB_MREQ.re   <= RB_MREQ_re;
  RB_MREQ.we   <= RB_MREQ_we;
  RB_MREQ.init <= RB_MREQ_initt;
  RB_MREQ.addr <= RB_MREQ_addr;
  RB_MREQ.din  <= RB_MREQ_din;

  RB_SRES_ack   <= RB_SRES.ack;
  RB_SRES_busy  <= RB_SRES.busy;
  RB_SRES_err   <= RB_SRES.err;
  RB_SRES_dout  <= RB_SRES.dout;

  RBTEST : rbd_tester
    generic map (
      RB_ADDR => slv(to_unsigned(2#11110000#,8)))
    port map (
      CLK      => CLK,
      RESET    => '0',
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM_TESTER,
      RB_STAT  => RB_STAT
    );

  RB_LAM <= RB_LAM_TESTER or RB_LAM_TBENCH;
    
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
    generic map (
      DBASE  => 2)
    port map (
      CLK       => CLK,
      CLK_CYCLE => CLK_CYCLE,
      ENA       => RBMON_EN,
      RB_MREQ   => RB_MREQ,
      RB_SRES   => RB_SRES,
      RB_LAM    => RB_LAM,
      RB_STAT   => RB_STAT
    );

  UUT : tbd_rlink_gen
    port map (
      CLK          => CLK,
      CE_INT       => CE_MSEC,
      CE_USEC      => CE_USEC,
      RESET        => RESET,
      RL_DI        => RL_DI,
      RL_ENA       => RL_ENA,
      RL_BUSY      => RL_BUSY,
      RL_DO        => RL_DO,
      RL_VAL       => RL_VAL,
      RL_HOLD      => RL_HOLD,
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
      RB_STAT      => RB_STAT,
      TXRXACT      => TXRXACT
    );

  proc_stim: process
    file fstim : text open read_mode is "tb_rlink_stim";
    variable iline : line;
    variable oline : line;
    variable ien   : slbit := '0';
    variable icmd  : slv8 := (others=>'0');
    variable iaddr : slv8 := (others=>'0');
    variable icnt  : slv8 := (others=>'0');
    variable istat : slv3 := (others=>'0');
    variable iattn : slv16 := (others=>'0');
    variable idata : slv16 := (others=>'0');
    variable ioof  : slv9 := (others=>'0');
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable idelta : integer := 0;
    variable iowait : integer := 0;
    variable txcrc,rxcrc : slv8 := (others=>'0');
    variable txlist : slv9_array_type := (others=>slv9_zero);
    variable ntxlist : natural := 0;

    procedure do_tx8 (data : inout slv8)  is
    begin
      txlist(ntxlist) := '0' & data;
      ntxlist := ntxlist + 1;
      txcrc := crc8_update_tbl(txcrc, data);
    end procedure do_tx8;
    
    procedure do_tx16 (data : inout slv16)  is
    begin
      do_tx8(data( 7 downto 0));
      do_tx8(data(15 downto 8));
    end procedure do_tx16;

    procedure do_rx8 (data : inout slv8)  is
    begin
      sv_rxlist(sv_nrxlist) := '0' & data;
      sv_nrxlist := sv_nrxlist + 1;
      rxcrc := crc8_update_tbl(rxcrc, data);
    end procedure do_rx8;

    procedure do_rx16 (data : inout slv16)  is
    begin
      do_rx8(data( 7 downto 0));
      do_rx8(data(15 downto 8));
    end procedure do_rx16;
            
    procedure checkmiss_rx is
    begin
      if sv_rxind < sv_nrxlist then
        for i in sv_rxind to sv_nrxlist-1 loop
          writetimestamp(oline, CLK_CYCLE, ": moni ");
          write(oline, string'("  FAIL MISSING DATA="));
          write(oline, sv_rxlist(i)(8));
          write(oline, string'(" "));
          write(oline, sv_rxlist(i)(7 downto 0));
          writeline(output, oline);
        end loop;

      end if;
    end procedure checkmiss_rx;
            
  begin
    
    wait for clock_offset - setup_time;

    file_loop: while not endfile(fstim) loop

      readline (fstim, iline);
      
      readcomment(iline, ok);
      next file_loop when ok;

      readword(iline, dname, ok);
      
      if ok then
        case dname is
          when ".reset" =>              -- .reset 
            write(oline, string'(".reset"));
            writeline(output, oline);
            RESET <= '1';
            wait for clock_period;
            RESET <= '0';
            wait for 9*clock_period;

          when ".rlmon" =>              -- .rlmon
            read_ea(iline, ien);
            RLMON_EN <= ien;
            wait for 2*clock_period;      -- wait for monitor to start

          when ".rbmon" =>              -- .rbmon
            read_ea(iline, ien);
            RBMON_EN <= ien;
            wait for 2*clock_period;      -- wait for monitor to start

          when ".wait " =>              -- .wait
            read_ea(iline, idelta);
            wait for idelta*clock_period;
            
          when ".iowt " =>              -- .iowt
            read_ea(iline, iowait);
            idelta := iowait;
            while idelta > 0 loop       -- until time has expired
              if TXRXACT = '1' then     -- if any io activity
                idelta := iowait;       -- restart timer
              else
                idelta := idelta - 1;   -- otherwise count down time
              end if;
              wait for clock_period;
            end loop;

          when ".attn " =>              -- .attn
            read_ea(iline, iattn);
            RB_LAM_TBENCH <= iattn;       -- pulse attn lines
            wait for clock_period;        -- for 1 clock
            RB_LAM_TBENCH <= (others=>'0');

          when "txsop " =>              -- txsop   send sop
            txlist(0) := c_rlink_dat_sop;
            ntxlist := 1;
            txcrc := (others=>'0');
          when "txeop " =>              -- txeop   send eop
            txlist(0) := c_rlink_dat_eop;
            ntxlist := 1;
            txcrc := (others=>'0');

          when "txnak " =>              -- txnak   send nak
            txlist(0) := c_rlink_dat_nak;
            ntxlist := 1;
            txcrc := (others=>'0');

          when "txidle" =>              -- txidle  send idle
            txlist(0) := c_rlink_dat_idle;
            ntxlist := 1;
          when "txattn" =>              -- txattn  send attn
            txlist(0) := c_rlink_dat_attn;
            ntxlist := 1;

          when "tx8   " =>              -- tx8     send 8 bit value
            read_ea(iline, iaddr);
            ntxlist := 0;
            do_tx8(iaddr);
          when "tx16  " =>              -- tx16    send 16 bit value
            read_ea(iline, idata);
            ntxlist := 0;
            do_tx16(idata);

          when "txcrc " =>              -- txcrc   send crc  
            txlist(0) := '0' & txcrc;
            ntxlist := 1;

          when "txbad " =>              -- txbad   send bad crc  
            txlist(0) := '0' & (not txcrc);
            ntxlist := 1;

          when "txc   " =>              -- txc     send: cmd crc
            read_ea(iline, icmd);
            ntxlist := 0;
            do_tx8(icmd);
            txlist(ntxlist) := '0' & txcrc;
            ntxlist := ntxlist + 1;

          when "txca  " =>              -- txc     send: cmd addr crc
            read_ea(iline, icmd);
            read_ea(iline, iaddr);
            ntxlist := 0;
            do_tx8(icmd);
            do_tx8(iaddr);
            txlist(ntxlist) := '0' & txcrc;
            ntxlist := ntxlist + 1;

          when "txcad " =>              -- txc     send: cmd addr data crc
            read_ea(iline, icmd);
            read_ea(iline, iaddr);
            read_ea(iline, idata);
            ntxlist := 0;
            do_tx8(icmd);
            do_tx8(iaddr);
            do_tx16(idata);
            txlist(ntxlist) := '0' & txcrc;
            ntxlist := ntxlist + 1;

          when "txcac " =>              -- txc     send: cmd addr cnt crc
            read_ea(iline, icmd);
            read_ea(iline, iaddr);
            read_ea(iline, icnt);
            ntxlist := 0;
            do_tx8(icmd);
            do_tx8(iaddr);
            do_tx8(icnt);
            txlist(ntxlist) := '0' & txcrc;
            ntxlist := ntxlist + 1;

          when "txoof " =>              -- txoof   send out-of-frame symbol
            read_ea(iline, txlist(0));
            ntxlist := 1;
            
          when "rxsop " =>              -- rxsop   expect sop
            checkmiss_rx;
            sv_rxlist(0) := c_rlink_dat_sop;
            sv_nrxlist := 1;
            sv_rxind := 0;
            rxcrc := (others=>'0');
          when "rxeop " =>              -- rxeop   expect eop
            sv_rxlist(sv_nrxlist) := c_rlink_dat_eop;
            sv_nrxlist := sv_nrxlist + 1;

          when "rxnak " =>              -- rxnak   expect nak
            sv_rxlist(sv_nrxlist) := c_rlink_dat_nak;
            sv_nrxlist := sv_nrxlist + 1;
          when "rxidle" =>              -- rxidle  expect idle
            sv_rxlist(sv_nrxlist) := c_rlink_dat_idle;
            sv_nrxlist := sv_nrxlist + 1;
          when "rxattn" =>              -- rxattn  expect attn
            sv_rxlist(sv_nrxlist) := c_rlink_dat_attn;
            sv_nrxlist := sv_nrxlist + 1;

          when "rx8   " =>              -- rx8     expect 8 bit value
            read_ea(iline, iaddr);
            do_rx8(iaddr);
          when "rx16  " =>              -- rx16    expect 16 bit value
            read_ea(iline, idata);
            do_rx16(idata);

          when "rxcrc " =>              -- rxcrc   expect crc
            sv_rxlist(sv_nrxlist) := '0' & rxcrc;
            sv_nrxlist := sv_nrxlist+1;

          when "rxcs  " =>              -- rxcs    expect: cmd stat crc
            read_ea(iline, icmd);
            read_ea(iline, iaddr);
            do_rx8(icmd);
            do_rx8(iaddr);
            sv_rxlist(sv_nrxlist) := '0' & rxcrc;
            sv_nrxlist := sv_nrxlist + 1;

          when "rxcds " =>              -- rxcsd   expect: cmd data stat crc
            read_ea(iline, icmd);
            read_ea(iline, idata); 
            read_ea(iline, iaddr);
            do_rx8(icmd);
            do_rx16(idata);
            do_rx8(iaddr);
            sv_rxlist(sv_nrxlist) := '0' & rxcrc;
            sv_nrxlist := sv_nrxlist + 1;

          when "rxccd " =>              -- rxccd   expect: cmd ccmd dat stat crc
            read_ea(iline, icmd);
            read_ea(iline, icnt);
            read_ea(iline, idata); 
            read_ea(iline, iaddr);
            do_rx8(icmd);
            do_rx8(icnt);
            do_rx16(idata);
            do_rx8(iaddr);
            sv_rxlist(sv_nrxlist) := '0' & rxcrc;
            sv_nrxlist := sv_nrxlist + 1;

          when "rxoof " =>              -- rxoof   expect: out-of-frame symbol
            read_ea(iline, ioof);
            sv_rxlist(sv_nrxlist) := ioof;
            sv_nrxlist := sv_nrxlist + 1;

          when others =>                -- bad command
            write(oline, string'("?? unknown command: "));
            write(oline, dname);
            writeline(output, oline);
            report "aborting" severity failure;
        end case;

      else
        report "failed to find command" severity failure;
      end if;

      next file_loop when ntxlist=0;
      
      for i in 0 to ntxlist-1 loop
        
        RL_DI <= txlist(i);
        RL_ENA <= '1';

        writetimestamp(oline, CLK_CYCLE, ": stim");
        write(oline, txlist(i)(8), right, 3);
        write(oline, txlist(i)(7 downto 0), right, 9);
        if txlist(i)(8) = '1' then
          case txlist(i) is
            when c_rlink_dat_idle =>
              write(oline, string'(" (idle)"));
            when c_rlink_dat_sop =>
              write(oline, string'(" (sop) "));
            when c_rlink_dat_eop =>
              write(oline, string'(" (eop) "));
            when c_rlink_dat_nak =>
              write(oline, string'(" (nak) "));
            when c_rlink_dat_attn =>
              write(oline, string'(" (attn)"));
            when others => 
              write(oline, string'(" (????)"));
          end case;
        end if;
        writeline(output, oline);
      
        wait for clock_period;
        while RL_BUSY = '1' loop
          wait for clock_period;
        end loop;
        RL_ENA <= '0';
      
      end loop;  -- i

      ntxlist := 0;
      
    end loop; -- file fstim

    wait for 50*clock_period;

    checkmiss_rx;
    writetimestamp(oline, CLK_CYCLE, ": DONE ");
    writeline(output, oline);

    CLK_STOP <= '1';

    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end

  end process proc_stim;

  
  proc_moni: process
    variable oline : line;
  begin

    loop 
      wait until rising_edge(CLK);
      wait for c2out_time;

      if RL_VAL = '1' then
        writetimestamp(oline, CLK_CYCLE, ": moni");
        write(oline, RL_DO(8), right, 3);
        write(oline, RL_DO(7 downto 0), right, 9);
        if RL_DO(8) = '1' then
          case RL_DO is
            when c_rlink_dat_idle =>
              write(oline, string'(" (idle)"));
            when c_rlink_dat_sop =>
              write(oline, string'(" (sop) "));
            when c_rlink_dat_eop =>
              write(oline, string'(" (eop) "));
            when c_rlink_dat_nak =>
              write(oline, string'(" (nak) "));
            when c_rlink_dat_attn =>
              write(oline, string'(" (attn)"));
            when others => 
              write(oline, string'(" (????)"));
          end case;
        end if;
        if sv_nrxlist > 0 then
          write(oline, string'("  CHECK"));
          if sv_rxind < sv_nrxlist then
            if RL_DO = sv_rxlist(sv_rxind) then
              write(oline, string'(" OK"));
            else
              write(oline, string'(" FAIL, exp="));
              write(oline, sv_rxlist(sv_rxind)(8), right, 2);
              write(oline, sv_rxlist(sv_rxind)(7 downto 0), right, 9);
            end if;
            sv_rxind := sv_rxind + 1;
          else
            write(oline, string'(" FAIL, UNEXPECTED"));
          end if;
        end if;
        writeline(output, oline);
      end if;
      
    end loop;
    
  end process proc_moni;

end sim;
