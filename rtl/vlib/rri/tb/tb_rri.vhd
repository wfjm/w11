-- $Id: tb_rri.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2007-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_rri - sim
-- Description:    Test bench for rri_core
--
-- Dependencies:   simlib/simclk
--                 genlib/clkdivce
--                 tbd_rri_gen [UUT]
--
-- To test:        rri_core
--                 rri_serport
--
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4; ghdl 0.18-0.26
-- Revision History: 
-- Date         Rev Version  Comment
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.genlib.all;
use work.comlib.all;
use work.rrilib.all;
use work.simlib.all;

entity tb_rri is
end tb_rri;

architecture sim of tb_rri is
  
  signal CLK : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';
  signal RESET : slbit := '0';
  signal CP_DI : slv9 := (others=>'0');
  signal CP_ENA : slbit := '0';
  signal CP_BUSY : slbit := '0';
  signal CP_DO : slv9 := (others=>'0');
  signal CP_VAL : slbit := '0';
  signal CP_HOLD : slbit := '0';
  signal RB_MREQ_req : slbit := '0';
  signal RB_MREQ_we : slbit := '0';
  signal RB_MREQ_initt: slbit := '0';
  signal RB_MREQ_addr : slv8 := (others=>'0');
  signal RB_MREQ_din : slv16 := (others=>'0');
  signal RB_SRES_ack : slbit := '0';
  signal RB_SRES_busy : slbit := '0';
  signal RB_SRES_err : slbit := '0';
  signal RB_SRES_dout : slv16 := (others=>'0');
  signal RB_LAM : slv16 := (others=>'0');
  signal RB_STAT : slv3 := (others=>'0');
  signal TXRXACT : slbit := '0';
  
  signal CLK_STOP : slbit := '0';
  signal CLK_CYCLE : slv31 := (others=>'0');

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

component tbd_rri_gen is                -- rri, generic tb design interface
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit;                  -- rri ito time unit clock enable
    CE_USEC : in slbit;                 -- 1 usec clock enable
    RESET  : in slbit;                  -- reset
    CP_DI : in slv9;                    -- comm port: data in
    CP_ENA : in slbit;                  -- comm port: data enable
    CP_BUSY : out slbit;                -- comm port: data busy
    CP_DO : out slv9;                   -- comm port: data out
    CP_VAL : out slbit;                 -- comm port: data valid
    CP_HOLD : in slbit;                 -- comm port: data hold
    RB_MREQ_req : out slbit;            -- rbus: request - req
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

  SYSCLK : simclk
    generic map (
      PERIOD => clock_period,
      OFFSET => clock_offset)
    port map (
      CLK       => CLK,
      CLK_CYCLE => CLK_CYCLE,
      CLK_STOP  => CLK_STOP
    );

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 6,
      USECDIV  => 4,
      MSECDIV  => 5
      )
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  UUT : tbd_rri_gen
    port map (
      CLK          => CLK,
      CE_INT       => CE_MSEC,
      CE_USEC      => CE_USEC,
      RESET        => RESET,
      CP_DI        => CP_DI,
      CP_ENA       => CP_ENA,
      CP_BUSY      => CP_BUSY,
      CP_DO        => CP_DO,
      CP_VAL       => CP_VAL,
      CP_HOLD      => CP_HOLD,
      RB_MREQ_req  => RB_MREQ_req,
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
    file fstim : text open read_mode is "tb_rri_stim";
    variable iline : line;
    variable oline : line;
    variable icmd  : slv8 := (others=>'0');
    variable iaddr : slv8 := (others=>'0');
    variable icnt  : slv8 := (others=>'0');
    variable istat : slv3 := (others=>'0');
    variable iattn : slv8 := (others=>'0');
    variable idata : slv16 := (others=>'0');
    variable ioob  : slv9 := (others=>'0');
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
      crc8_update_tbl(txcrc, data);
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
      crc8_update_tbl(rxcrc, data);
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

      readcommand(iline, dname, ok);
      if ok then
        case dname is
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

          when ".stat " =>              -- .stat
            read_ea(iline, istat);
            RB_STAT <= istat;             -- set ext. status lines
            wait for clock_period;        -- ensure some setling

          when ".attn " =>              -- .attn
            read_ea(iline, iattn);
            RB_LAM(7 downto 0) <= iattn;  -- pulse lsb attn lines
            wait for clock_period;                     -- for 1 clock
            RB_LAM(7 downto 0) <= (others=>'0');

          when ".txsop" =>              -- .txsop  send sop
            txlist(0) := c_rri_dat_sop;
            ntxlist := 1;
            txcrc := (others=>'0');
          when ".txeop" =>              -- .txeop  send eop
            txlist(0) := c_rri_dat_eop;
            ntxlist := 1;
            txcrc := (others=>'0');
          when ".txnak" =>              -- .txnak  send nak
            txlist(0) := c_rri_dat_nak;
            ntxlist := 1;
            txcrc := (others=>'0');
          when ".tx8  " =>              -- .tx8    send 8 bit value
            read_ea(iline, iaddr);
            ntxlist := 0;
            do_tx8(iaddr);
          when ".tx16 " =>              -- .tx16   send 16 bit value
            read_ea(iline, idata);
            ntxlist := 0;
            do_tx16(idata);
          when ".txcrc" =>              -- .txcrc  send crc  
            txlist(0) := '0' & txcrc;
            ntxlist := 1;

          when ".txc  " =>              -- .txc    send: cmd crc
            read_ea(iline, icmd);
            ntxlist := 0;
            do_tx8(icmd);
            txlist(ntxlist) := '0' & txcrc;
            ntxlist := ntxlist + 1;

          when ".txca " =>              -- .txc    send: cmd addr crc
            read_ea(iline, icmd);
            read_ea(iline, iaddr);
            ntxlist := 0;
            do_tx8(icmd);
            do_tx8(iaddr);
            txlist(ntxlist) := '0' & txcrc;
            ntxlist := ntxlist + 1;

          when ".txcad" =>              -- .txc    send: cmd addr data crc
            read_ea(iline, icmd);
            read_ea(iline, iaddr);
            read_ea(iline, idata);
            ntxlist := 0;
            do_tx8(icmd);
            do_tx8(iaddr);
            do_tx16(idata);
            txlist(ntxlist) := '0' & txcrc;
            ntxlist := ntxlist + 1;

          when ".txcac" =>              -- .txc    send: cmd addr cnt crc
            read_ea(iline, icmd);
            read_ea(iline, iaddr);
            read_ea(iline, icnt);
            ntxlist := 0;
            do_tx8(icmd);
            do_tx8(iaddr);
            do_tx8(icnt);
            txlist(ntxlist) := '0' & txcrc;
            ntxlist := ntxlist + 1;

          when ".rxsop" =>              -- .rxsop  expect sop
            checkmiss_rx;
            sv_rxlist(0) := c_rri_dat_sop;
            sv_nrxlist := 1;
            sv_rxind := 0;
            rxcrc := (others=>'0');
          when ".rxeop" =>              -- .rxeop  expect eop
            sv_rxlist(sv_nrxlist) := c_rri_dat_eop;
            sv_nrxlist := sv_nrxlist + 1;
          when ".rxnak" =>              -- .rxnak  expect nak
            sv_rxlist(sv_nrxlist) := c_rri_dat_nak;
            sv_nrxlist := sv_nrxlist + 1;
          when ".rx8  " =>              -- .rx8    expect 8 bit value
            read_ea(iline, iaddr);
            do_rx8(iaddr);
          when ".rx16 " =>              -- .rx16   expect 16 bit value
            read_ea(iline, idata);
            do_rx16(idata);
          when ".rxcrc" =>              -- .rxcrc  expect crc
            sv_rxlist(sv_nrxlist) := '0' & rxcrc;
            sv_nrxlist := sv_nrxlist+1;

          when ".rxcs " =>              -- .rxcs   expect: cmd stat crc
            read_ea(iline, icmd);
            read_ea(iline, iaddr);
            do_rx8(icmd);
            do_rx8(iaddr);
            sv_rxlist(sv_nrxlist) := '0' & rxcrc;
            sv_nrxlist := sv_nrxlist + 1;

          when ".rxcds" =>              -- .rxcsd  expect: cmd data stat crc
            read_ea(iline, icmd);
            read_ea(iline, idata); 
            read_ea(iline, iaddr);
            do_rx8(icmd);
            do_rx16(idata);
            do_rx8(iaddr);
            sv_rxlist(sv_nrxlist) := '0' & rxcrc;
            sv_nrxlist := sv_nrxlist + 1;

          when ".rxccd" =>              -- .rxccd  expect: cmd ccmd dat stat crc
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

          when ".rxoob" =>              -- .rxoob  expect: out-of-band symbol
            read_ea(iline, ioob);
            sv_rxlist(sv_nrxlist) := ioob;
            sv_nrxlist := sv_nrxlist + 1;

          when others =>                -- bad directive
            write(oline, string'("?? unknown directive: "));
            write(oline, dname);
            writeline(output, oline);
            report "aborting" severity failure;
        end case;

      else
        read_ea(iline, txlist(0));
        ntxlist := 1;

      end if;

      next file_loop when ntxlist=0;
      
      for i in 0 to ntxlist-1 loop
        
        CP_DI <= txlist(i);
        CP_ENA <= '1';

        writetimestamp(oline, CLK_CYCLE, ": stim ");
        write(oline, txlist(i)(8), right, 3);
        write(oline, txlist(i)(7 downto 0), right, 9);
        if txlist(i)(8) = '1' then
          case txlist(i) is
            when c_rri_dat_idle =>
              write(oline, string'(" (idle)"));
            when c_rri_dat_sop =>
              write(oline, string'(" (sop) "));
            when c_rri_dat_eop =>
              write(oline, string'(" (eop) "));
            when c_rri_dat_nak =>
              write(oline, string'(" (nak) "));
            when c_rri_dat_attn =>
              write(oline, string'(" (attn)"));
            when others => 
              write(oline, string'(" (????)"));
          end case;
        end if;
        writeline(output, oline);
      
        wait for clock_period;
        while CP_BUSY = '1' loop
          wait for clock_period;
        end loop;
        CP_ENA <= '0';
      
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
      wait until CLK'event and CLK='1';
      wait for c2out_time;

      if CP_VAL = '1' then
        writetimestamp(oline, CLK_CYCLE, ": moni ");
        write(oline, CP_DO(8), right, 3);
        write(oline, CP_DO(7 downto 0), right, 9);
        if CP_DO(8) = '1' then
          case CP_DO is
            when c_rri_dat_idle =>
              write(oline, string'(" (idle)"));
            when c_rri_dat_sop =>
              write(oline, string'(" (sop) "));
            when c_rri_dat_eop =>
              write(oline, string'(" (eop) "));
            when c_rri_dat_nak =>
              write(oline, string'(" (nak) "));
            when c_rri_dat_attn =>
              write(oline, string'(" (attn)"));
            when others => 
              write(oline, string'(" (????)"));
          end case;
        end if;
        if sv_nrxlist > 0 then
          write(oline, string'("  CHECK"));
          if sv_rxind < sv_nrxlist then
            if CP_DO = sv_rxlist(sv_rxind) then
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


-- simulated target:
--    00000000 ... 00111111:  64 registers, no wait states
--    00010000             :  (16) pointer register for mem 0
--    00010001             :  (17) pointer register for mem 1
--    00010010             :  (18) counter for init's
--    01000000 ... 01111111:  64 registers, addr(5 downto 0)+1 wait states
--    10000000             :  256 word memory, addressed by reg(00010000)
--    10000001             :  256 word memory, addressed by reg(00010001)
--    10000010             :  ping RB_LAM(15 downto 8) on WE access
--    11000000             :  signal err, write noop, read 10101010
--    others               :  no ack
-- 

  proc_targ: process
    variable reg0 : slv16_array_type := (others=>slv16_zero);
    variable reg1 : slv16_array_type := (others=>slv16_zero);
    variable mem0 : slv16_array_type := (others=>slv16_zero);
    variable mem1 : slv16_array_type := (others=>slv16_zero);
    variable iack : slbit := '0';
    variable ierr : slbit := '0';
    variable nhold : integer := 0;
    variable addr  : slv8 := (others=>'0');
    variable idout : slv16 := (others=>'0');
    variable ind   : integer := 0;
    variable oline : line;

    constant c2out_setup : time := clock_period-c2out_time-setup_time;

    type acc_type is (acc_reg0, acc_reg1, acc_mem0, acc_mem1, acc_lam,
                      acc_err, acc_bad);
    variable acc : acc_type := acc_bad;

    procedure write_data (pref : in string;
                          data : in slv16;
                          iack : in slbit;
                          ierr : in slbit;
                          nhold : in integer)  is
      variable oline : line;
    begin
      writetimestamp(oline, CLK_CYCLE, pref);
      write(oline, RB_MREQ_addr, right, 10);
      write(oline, data, right, 18);
      if nhold > 0 then
        write(oline, string'("  nhold="));
        write(oline, nhold, right, 2);        
      end if;
      if iack = '0' then
        write(oline, string'("  ACK=0"));
      end if;
      if ierr = '1' then
        write(oline, string'("  ERR=1"));
      end if;
      writeline(output, oline);     
   end procedure write_data;

  begin

--    assert c2out_setup>0 report "assert(x>0)" severity FAILURE;
    
    wait until CLK'event and CLK='1';
    wait for c2out_time;

    RB_SRES_ack  <= '0';
    RB_SRES_busy <= '0';
    RB_SRES_err  <= '0';
    RB_SRES_dout <= (others=>'1');

    addr  := RB_MREQ_addr;
    idout := (others=>'0');
    nhold := 0;

    acc := acc_bad;
    if unsigned(addr) <= 2#00111111# then
      acc := acc_reg0;
    elsif unsigned(addr) <= 2#01111111# then
      acc := acc_reg1;
      nhold := conv_integer(unsigned(addr and "00111111")) + 1;
    elsif unsigned(addr) = 2#10000000# then
      acc := acc_mem0;
    elsif unsigned(addr) = 2#10000001# then
      acc := acc_mem1;
    elsif unsigned(addr) = 2#10000010# then
      acc := acc_lam;
    elsif unsigned(addr) = 2#11000000# then
      acc := acc_err;
    end if;

    iack := '1';
    ierr := '0';
    
    if acc = acc_bad then               -- if bad address
      iack := '0';                        -- don't acknowledge
    end if;

    RB_SRES_ack  <= iack;

    RB_LAM(15 downto 8) <= (others=>'0');
    
    if RB_MREQ_req = '1' then
      
      -- handle WE transactions
      if RB_MREQ_we  ='1' then
        case acc is
          when acc_reg0 =>
            reg0(conv_integer(unsigned(addr))) := RB_MREQ_din;
          when acc_reg1 =>
            reg1(conv_integer(unsigned(addr))) := RB_MREQ_din;
          when acc_mem0 =>
            ind := conv_integer(unsigned(reg0(16) and X"00ff"));
            mem0(ind) := RB_MREQ_din;
            reg0(16) := unsigned(reg0(16)) + 1;
          when acc_mem1 =>
            ind := conv_integer(unsigned(reg0(17) and X"00ff"));
            mem1(ind) := RB_MREQ_din;
            reg0(17) := unsigned(reg0(17)) + 1;
          when acc_lam =>
            RB_LAM(15 downto 8) <= RB_MREQ_din(15 downto 8);
            writetimestamp(oline, CLK_CYCLE,
                         ": targ w ap_lam(15 downto 8) pinged");
            writeline(output, oline);     
          when acc_err =>
            ierr := '1';
          when others => null;
        end case;
      
        write_data(": targ w ", RB_MREQ_din, iack, ierr, nhold);

        while nhold>0 and RB_MREQ_req='1' loop
          RB_SRES_busy <= '1';
          wait for clock_period;
          nhold := nhold - 1;
        end loop;
        RB_SRES_ack  <= iack;
        RB_SRES_err  <= ierr;
        RB_SRES_busy <= '0';

      -- handle RE transactions
      else
        case acc is
          when acc_reg0 =>
            idout := reg0(conv_integer(unsigned(addr)));
          when acc_reg1 =>
            idout := reg1(conv_integer(unsigned(addr)));
          when acc_mem0 =>
            ind := conv_integer(unsigned(reg0(16) and X"00ff"));
            idout := mem0(ind);
            reg0(16) := unsigned(reg0(16)) + 1;
          when acc_mem1 =>
            ind := conv_integer(unsigned(reg0(17) and X"00ff"));
            idout := mem1(ind);
            reg0(17) := unsigned(reg0(17)) + 1;
          when acc_err =>
            ierr := '1';
            idout := "1010101010101010";
          when acc_bad =>
            idout := "1010101010101010";
          when others => null;
        end case;
      
        write_data(": targ r ", idout, iack, ierr, nhold);

        RB_SRES_dout <= "0101010101010101";
        wait for c2out_setup;

        while nhold>0 and RB_MREQ_req='1' loop
          RB_SRES_busy <= '1';
          wait for clock_period;
          nhold := nhold - 1;
        end loop;
        RB_SRES_ack  <= iack;
        RB_SRES_err  <= ierr;
        RB_SRES_busy <= '0';

        RB_SRES_dout <= idout;
      
      end if;
    end if;

    -- handle INIT transactions (ext and int) (just for monitoring...)
    
    if RB_MREQ_initt = '1' then
      if RB_MREQ_we = '1' then          -- ext init
        write_data(": targ i ", RB_MREQ_din, '1', '0', 0);
        reg0(18) := unsigned(reg0(18)) + 1;
      else                              -- int init
        write_data(": iint   ", RB_MREQ_din, '1', '0', 0);
      end if;
    end if;

  end process proc_targ;


end sim;
