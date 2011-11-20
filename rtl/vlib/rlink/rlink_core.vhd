-- $Id: rlink_core.vhd 427 2011-11-19 21:04:11Z mueller $
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
-- Module Name:    rlink_core - syn
-- Description:    rlink core with 9bit interface
--
-- Dependencies:   comlib/crc8
--
-- Test bench:     tb/tb_rlink_direct
--                 tb/tb_rlink_serport
--                 tb/tb_rlink_tba_ttcombo
--
-- Target Devices: generic
-- Tool versions:  xst 8.2, 9.1, 9.2, 11.4, 12.1, 13.1; ghdl 0.18-0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-12-04   343 12.1    M53d xc3s1000-4   155  322    0  199 s  8.9
-- 2010-06-06   302 11.4    L68  xc3s1000-4   151  323    0  197 s  8.9
-- 2010-04-03   274 11.4    L68  xc3s1000-4   148  313    0  190 s  8.0
-- 2009-07-11   232 10.1.03 K39  xc3s1000-4   147  321    0  197 s  8.3
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-19   427   3.1.3  now numeric_std clean
-- 2010-12-25   348   3.1.2  drop RL_FLUSH support, add RL_MONI for rlink_core;
-- 2010-12-24   347   3.1.1  rename: CP_*->RL->*
-- 2010-12-22   346   3.1    wblk dcrc error: send nak, transit to s_error now;
--                           rename stat flags: [cd]crc->[cd]err, ioto->rbnak,
--                           ioerr->rberr; '111' cmd now aborts via s_txnak and
--                           sets cerr flag; set [cd]err on eop/nak aborts;
-- 2010-12-04   343   3.0    renamed rri_ -> rlink_; rbus V3 interface: use now
--                           aval,re,we; add new states: s_rstart, s_wstart
-- 2010-06-20   308   2.6    use rbinit,rbreq,rbwe state flops to drive rb_mreq;
--                           now nak on reserved cmd 111; use do_comma_abort();
-- 2010-06-18   306   2.5.1  rename rbus data fields to _rbf_
-- 2010-06-06   302   2.5    use sop/eop framing instead of soc+chaining
-- 2010-06-03   299   2.1.2  drop unneeded unsigned casts; change init encoding
-- 2010-05-02   287   2.1.1  ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT signal from interfaces
-- 2010-04-03   274   2.1    add CP_FLUSH output
-- 2009-07-12   233   2.0.1  remove snoopers
-- 2008-08-24   162   2.0    with new rb_mreq/rb_sres interface
-- 2008-03-02   121   1.1.1  comment out snoopers
-- 2007-11-24    98   1.1    new internal init handling (addr=11111111)
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-09-15    82   1.0    Initial version, fully functional
-- 2007-06-17    58   0.5    First preliminary version
------------------------------------------------------------------------------
--
-- Overall protocol:
--   _idle : expect
--             sop   -> _txsop    (echo sop,     , to _txsop, _rxcmd)
--             eop   -> _txeop    (send nak,eop  , to _txnak, _txeop, _idle)
--             nak   -> _txnak    (silently ignore nak)
--             attn  -> _txito    (send ito      , to _idle)
--             data  -> _idle     (silently ignore data)
--   _error: expect
--             sop   -> _txnak    (send nak      , to _txnak, _error)
--             eop   -> _txeop    (echo eop      , to _txeop, _idle)
--             nak   -> _txnak    (echo nak      , to _txnak, _error)
--             attn  -> _txito    (silently ignore attn)
--             data  -> _idle     (silently ignore data)
--   _rxcmd: expect
--             sop   -> _txnak    (send nak      , to _txnak, _error)
--             eop   -> _txeop    (echo eop      , to _txeop, _idle)
--             nak   -> _txnak    (echo nak      , to _txnak, _error)
--             attn  -> _txito    (silently ignore attn)
--             data  -> _idle     (decode command)
--   _rx...: expect
--             sop   -> _txnak    (send nak      , to _txnak, _error)
--             eop   -> _txnak    (send nak,eop  , to _txnak, _txeop, _idle)
--             nak   -> _txnak    (echo nak      , to _txnak, _error)
--             attn  -> _txito    (silently ignore attn)
--             data  -> _idle     (decode data)
--
--  7 supported commands:
--
--   000 read reg (rreg):
--        rx: cmd addr ccrc
--        tx: cmd dl dh stat crc
--       seq: _rxcmd _rxaddr _rxccrc (_txcmd|_txnak)
--            _rstart _rreg _txdatl _txdath _txstat _txcrc -> _rxcmd
--
--   001 read blk (rblk):
--        rx: cmd addr cnt ccrc
--        tx: cmd cnt dl dh ... stat crc
--       seq: _rxcmd _rxaddr _rxcnt _rxccrc (_txcmd|_txnak) _txcnt
--            {_rstart _rreg _txdatl _txdath _blk}*
--            _txstat _txcrc -> _rxcmd
--
--   010 write reg (wreg):
--        rx: cmd addr dl dh ccrc
--        tx: cmd stat crc
--       seq: _rxcmd _rxaddr _rxdatl _rxdath _rxccrc (_txcmd|_txnak)
--            _wstart _wreg _txstat _txcrc -> _rxcmd
--
--   011 write blk (wblk):
--        rx: cmd addr cnt ccrc dl dh ... dcrc
--        tx: cmd stat crc
--       seq: _rxcmd _rxaddr _rxcnt _rxccrc (_txcmd|_txnak)
--            {_rxdatl _rxdath _wstart _wreg _blk}*
--            _rxdcrc _txstat _txcrc -> (_rxcmd|_txnak)
--
--   100 read stat (stat):
--        rx: cmd ccrc
--        tx: cmd ccmd dl dh stat crc
--       seq: _rxcmd _rxccrc (_txcmd|_txnak)
--            _txccmd _txdatl _txdath _txstat _txcrc -> _rxcmd
--
--   101 read attn (attn):
--        rx: cmd ccrc
--        tx: cmd dl dh stat crc
--       seq: _rxcmd _rxccrc (_txcmd|_txnak)
--            _attn _txdatl _txdath _txstat _txcrc -> _rxcmd
--
--   110 write init (init):
--        rx: cmd addr dl dh ccrc
--        tx: cmd stat crc
--       seq: _rxcmd _rxaddr _rxdatl _rxdath _rxccrc (_txcmd|_txnak)
--            _txstat _txcrc -> _rxcmd
--       like wreg, but no rp_we - rp_hold, just a 1 cycle rp_init pulse
--
--   111 is currently not a legal command and causes a nak
--       seq: _txnak
--
-- The state bits nakcerr and nakderr determine whether cerr/derr is set
-- when s_txnak is entered. cerr is '1' during command receive, derr is '1'
-- during data wblk data receive phase:
--   nakcerr set in s_rxcmd  (when command received, unless it's stat)
--           clr in s_txcmd  (when wblk)
--           clr in s_txnak
--           clr in s_txcrc  (for sucessful completion)
--   nakderr set in s_txcmd  (when wblk)
--           clr in s_txnak
--           clr in s_txcrc  (for sucessful completion)
--
-- The different rbus cycle types are encoded as:
--
--        init aval re we
--          0    0   0  0   idle
--          0    0   1  0   not allowed
--          0    0   0  1   not allowed
--          0    1   1  0   read 
--          0    1   0  1   write
--          1    0   0  0   internal init
--          1    0   0  1   external init
--          1    0   1  0   not allowed
--          *    *   1  1   not allowed
--          1    1   *  *   not allowed
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.comlib.all;
use work.rblib.all;
use work.rlinklib.all;

entity rlink_core is                    -- rlink core with 9bit interface
  generic (
    ATOWIDTH : positive :=  5;          -- access timeout counter width
    ITOWIDTH : positive :=  6);         -- idle timeout counter width
  port (
    CLK  : in slbit;                    -- clock      
    CE_INT : in slbit := '0';           -- rri ito time unit clock enable
    RESET  : in slbit;                  -- reset
    RL_DI : in slv9;                    -- rlink 9b: data in
    RL_ENA : in slbit;                  -- rlink 9b: data enable
    RL_BUSY : out slbit;                -- rlink 9b: data busy
    RL_DO : out slv9;                   -- rlink 9b: data out
    RL_VAL : out slbit;                 -- rlink 9b: data valid
    RL_HOLD : in slbit;                 -- rlink 9b: data hold
    RL_MONI : out rl_moni_type;         -- rlink: monitor port
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  );
end entity rlink_core;  


architecture syn of rlink_core is

  type state_type is (
    s_idle,                             -- s_idle: wait for sop
    s_txito,                            -- s_txito: send timeout symbol
    s_txsop,                            -- s_txsop: send sop
    s_txnak,                            -- s_txnak: send nak
    s_txeop,                            -- s_txeop: send eop
    s_error,                            -- s_error: wait for eop
    s_rxcmd,                            -- s_rxcmd: wait for cmd
    s_rxaddr,                           -- s_rxaddr: wait for addr
    s_rxdatl,                           -- s_rxdatl: wait for data low
    s_rxdath,                           -- s_rxdath: wait for data high
    s_rxcnt,                            -- s_rxcnt: wait for count
    s_rxccrc,                           -- s_rxccrc: wait for command crc
    s_txcmd,                            -- s_txcmd: send cmd
    s_txcnt,                            -- s_txcnt: send cnt
    s_rstart,                           -- s_rstart: start reg or blk read
    s_rreg,                             -- s_rreg:   do reg or blk read
    s_txdatl,                           -- s_txdatl: send data low
    s_txdath,                           -- s_txdath: send data high
    s_wstart,                           -- s_wstart: start reg or blk write
    s_wreg,                             -- s_wreg:   do reg or blk write
    s_blk,                              -- s_blk: block count handling
    s_rxdcrc,                           -- s_rxdcrc: wait for data crc
    s_attn,                             -- s_attn: handle attention flags
    s_txccmd,                           -- s_txccmd: send last command
    s_txstat,                           -- s_txstat: send status
    s_txcrc                             -- s_txcrc: send crc
  );

  type regs_type is record
    state : state_type;                 -- state
    rcmd : slv8;                        -- received command
    ccmd : slv8;                        -- current command
    addr : slv8;                        -- register address
    dil : slv8;                         -- input data, lsb
    dih : slv8;                         -- input data, msb
    dol : slv8;                         -- output data, lsb
    doh : slv8;                         -- output data, msb
    cnt : slv8;                         -- block transfer count
    attn : slv16;                       -- attn mask
    atocnt : slv(ATOWIDTH-1 downto 0);  -- access timeout counter
    itocnt : slv(ITOWIDTH-1 downto 0);  -- idle timeout counter
    itoval : slv(ITOWIDTH-1 downto 0);  -- idle timeout value
    itoena : slbit;                     -- idle timeout enable flag
    anena : slbit;                      -- attn notification enable flag
    andone : slbit;                     -- attn notification done
    cerr : slbit;                       -- stat: command error
    derr : slbit;                       -- stat: data error
    rbnak: slbit;                       -- stat: rbus no ack or timeout
    rberr : slbit;                      -- stat: rbus err bit set
    nakeop : slbit;                     -- send eop after nak
    nakcerr : slbit;                    -- set cerr after nak
    nakderr : slbit;                    -- set derr after nak
    rbinit : slbit;                     -- rbus init signal
    rbaval : slbit;                     -- rbus aval signal
    rbre : slbit;                       -- rbus re signal
    rbwe : slbit;                       -- rbus we signal
    moneop : slbit;                     -- rl_moni: eop send pulse
    monattn : slbit;                    -- rl_moni: attn send pulse
    monlamp : slbit;                    -- rl_moni: attn pending state
    stat : slv3;                        -- external status flags
  end record regs_type;

  constant atocnt_init : slv(ATOWIDTH-1 downto 0) := (others=>'1');
  constant itocnt_init : slv(ITOWIDTH-1 downto 0) := (others=>'0');

  constant c_idle : slv4 := "0000";
  constant c_sop  : slv4 := "0001";
  constant c_eop  : slv4 := "0010";
  constant c_nak  : slv4 := "0011";
  constant c_attn : slv4 := "0100";

  constant regs_init : regs_type := (
    s_idle,                             --
    (others=>'0'),                      -- rcmd
    (others=>'0'),                      -- ccmd
    (others=>'0'),                      -- addr
    (others=>'0'),                      -- dil
    (others=>'0'),                      -- dih
    (others=>'0'),                      -- dol
    (others=>'0'),                      -- doh
    (others=>'0'),                      -- cnt
    (others=>'0'),                      -- attn
    atocnt_init,                        -- atocnt
    itocnt_init,                        -- itocnt
    itocnt_init,                        -- itoval
    '0',                                -- itoena
    '0','0',                            -- anena, andone
    '0','0','0','0',                    -- stat flags
    '0','0','0',                        -- nakeop,nakcerr,nakderr
    '0','0','0','0',                    -- rbinit,rbaval,rbre,rbwe
    '0','0','0',                        -- moneop,monattn,monlamp
    (others=>'0')                       -- stat
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  signal CRC_RESET : slbit := '0';
  signal ICRC_ENA : slbit := '0';
  signal OCRC_ENA : slbit := '0';
  signal ICRC_OUT : slv8 := (others=>'0');
  signal OCRC_OUT : slv8 := (others=>'0');
  signal OCRC_IN : slv8 := (others=>'0');

begin

  assert ITOWIDTH<=8
    report "assert(ITOWIDTH<=8): max byte size ITO counter supported"
    severity failure;
  
  ICRC : crc8                           -- crc generator for input data
  port map (
    CLK   => CLK,
    RESET => CRC_RESET,
    ENA   => ICRC_ENA,
    DI    => RL_DI(7 downto 0),
    CRC   => ICRC_OUT
  );

  OCRC : crc8                           -- crc generator for output data
  port map (
    CLK   => CLK,
    RESET => CRC_RESET,
    ENA   => OCRC_ENA,
    DI    => OCRC_IN,
    CRC   => OCRC_OUT
  );

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, CE_INT, RL_DI, RL_ENA, RL_HOLD, RB_LAM,
                      RB_SRES, RB_STAT, ICRC_OUT, OCRC_OUT)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable ival : slbit := '0';
    variable ibusy : slbit := '0';
    variable ido : slv9 := (others=>'0');
    variable ato_go : slbit := '0';
    variable ato_end : slbit := '0';
    variable ito_go : slbit := '0';
    variable ito_end : slbit := '0';
    variable crcreset : slbit := '0';
    variable icrcena : slbit := '0';
    variable ocrcena : slbit := '0';
    variable has_attn : slbit := '0';
    variable snd_attn : slbit := '0';
    variable idi8 : slv8 := (others=>'0');
    variable is_comma : slbit := '0';
    variable comma_typ : slv4 := "0000";

    procedure do_comma_abort(nstate  : inout state_type;
                             nnakeop : inout slbit;
                             comma_typ  : in slv4) is
    begin
      if comma_typ=c_sop or comma_typ=c_eop or comma_typ=c_nak then
        if comma_typ = c_eop then
          nnakeop := '1';
        end if;
        nstate  := s_txnak;             -- next: send nak
      end if;
    end procedure do_comma_abort;

  begin

    r := R_REGS;
    n := R_REGS;

    idi8      := RL_DI(7 downto 0);     -- get data part of RL_DI
    is_comma  := RL_DI(8);              -- get comma marker
    comma_typ := RL_DI(3 downto 0);     -- get comma type

    n.rbinit  := '0';                   -- clear rb(init|aval|re|we) by default
    n.rbaval  := '0';                   --   they must always be set by the
    n.rbre    := '0';                   --   'previous state'
    n.rbwe    := '0';                   -- 
    
    n.moneop  := '0';                   -- default '0', only set by states
    n.monattn := '0';                   -- "
    n.monlamp := '0';                   -- 

    ibusy := '1';                       -- default is to hold input
    ival := '0';
    ido  := (others=>'0');

    crcreset := '0';
    icrcena  := '0';
    ocrcena  := '0';
    
    for i in RB_LAM'range loop          -- handle attention "LAM's"
      if RB_LAM(i) = '1' then           -- if LAM bit set
        n.attn(i) := '1';               -- set attention bit
      end if;
    end loop;

    has_attn := '0';
    snd_attn := '0';
    
    if unsigned(r.attn) /= 0 then       -- is any of the attn bits set ?
      has_attn  := '1';
      if r.anena='1' and r.andone='0' then -- is attn notification to be send ?
        snd_attn := '1';
        n.monlamp := '1';                    -- set lamp flag in rl_moni
      end if;
    end if;

    ato_go := '0';                      -- default: keep access timeout in reset
    ato_end := '0';
    if unsigned(r.atocnt) = 0 then      -- if access timeout count at zero
      ato_end := '1';                   -- signal expiration
    end if;
    
    ito_go := '0';                      -- default: keep idle timeout in reset
    ito_end := '0';
    if unsigned(r.itocnt) = 0 then      -- if idle timeout count at zero
      ito_end := '1';                   -- signal expiration
    end if;
    
    case r.state is
      when s_idle =>                    -- s_idle: wait for sop --------------
        ito_go := '1';                    -- idle timeout active
        if snd_attn = '1' then            -- if attn notification to be send
          n.state := s_txito;               -- next: send ito byte
        else
          ibusy := '0';                   -- accept input
          if RL_ENA = '1' then            -- if input
            if is_comma = '1' then          -- if comma
              case comma_typ is
                when c_sop =>                 -- if sop
                  crcreset := '1';              -- reset crc generators
                  n.state := s_txsop;           -- next: echo it
                when c_eop =>                 -- if eop (unexpected)
                  n.nakeop := '1';              -- send nak,eop
                  n.state   := s_txnak;         -- next: send nak
                when c_attn =>                -- if attn
                  n.state := s_txito;           -- next: send ito byte
                when others => null;          -- other commas: silently ignore
              end case;
            else                             -- if normal data
              n.state := s_idle;               -- silently dropped
            end if;
          elsif (r.itoena='1' and             -- if ito enable, expired and XSEC
                 ito_end='1' and CE_INT='1') then
            n.state := s_txito;             -- next: send ito byte
          end if;
        end if;
          
      when s_txito =>                   -- s_txito: send timeout symbol ------
        if has_attn = '1' then              
          ido := c_rlink_dat_attn;        -- if attn pending: send attn symbol
          n.andone := '1';
        else
          ido := c_rlink_dat_idle;        -- otherwise: send idle symbol
        end if;
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          n.monattn := has_attn;            -- signal on rl_moni
          n.state := s_idle;                -- next: wait for sop
        end if;

      when s_txsop =>                   -- s_txsop: send sop -----------------
        ido := c_rlink_dat_sop;           -- send sop character
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          n.state := s_rxcmd;             -- next: read first command
        end if;
        
      when s_txnak =>                   -- s_txnak: send nak -----------------
        ido := c_rlink_dat_nak;           -- send nak character
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          n.nakeop  := '0';               -- clear all 'do on nak' state flags
          n.nakcerr := '0';
          n.nakderr := '0';
          if r.nakcerr = '1' then         -- if setting cerr requested
            n.cerr := '1';                  -- do it
          end if;
          if r.nakderr = '1' then         -- if settung derr requested
            n.derr := '1';                  -- do it
          end if;
          if r.nakeop = '1' then           -- if eop after nak requested
            n.state := s_txeop;             -- next: send eop
          else
            n.state := s_error;             -- next: error state, wait for eop
          end if;
        end if;
        
      when s_txeop =>                   -- s_txeop: send eop -----------------
        ido := c_rlink_dat_eop;           -- send eop character
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          n.moneop := '1';                  -- signal on rl_moni
          n.state := s_idle;                -- next: idle state, wait for sop
        end if;
        
      when s_error =>                   -- s_error: wait for eop -------------
        ibusy := '0';                     -- accept input
        if RL_ENA = '1' then
          if is_comma = '1' then          -- if comma
            case comma_typ is
              when c_sop =>                 -- if sop (unexpected)
                n.state  := s_txnak;          -- next: send nak
              when c_eop =>                 -- if eop
                n.state  := s_txeop;          -- next: echo eop
              when c_nak =>                 -- if nak
                n.state  := s_txnak;          -- next: echo nak
              when others => null;          -- other commas: silently ignore
            end case;
          else                             -- if normal data
            n.state := s_error;              -- silently dropped
          end if;
        end if;

      when s_rxcmd =>                   -- s_rxcmd: wait for cmd -------------
        ibusy := '0';                     -- accept input
        if RL_ENA = '1' then
          if is_comma = '1' then          -- if comma
            case comma_typ is
              when c_sop =>                 -- if sop (unexpected)
                n.state  := s_txnak;          -- next: send nak
              when c_eop =>                 -- if eop
                n.state  := s_txeop;          -- next: echo eop
              when c_nak =>                 -- if nak
                n.state  := s_txnak;          -- next: echo nak
              when others => null;          --other commas: silently ignore
            end case;
          else                            -- if not comma
            icrcena   := '1';               -- update input crc
            n.rcmd    := idi8;              -- latch received command code
                                            -- unless the command is stat
            if RL_DI(c_rlink_cmd_rbf_code) /= c_rlink_cmd_stat then 
              n.nakcerr := '1';               -- set cerr on eop/nak abort
            end if;
            case RL_DI(c_rlink_cmd_rbf_code) is
              when c_rlink_cmd_rreg |
                   c_rlink_cmd_rblk |
                   c_rlink_cmd_wreg |
                   c_rlink_cmd_wblk |
                   c_rlink_cmd_init =>      -- for commands needing addr(data)
                n.state := s_rxaddr;          -- next: read address
              when c_rlink_cmd_stat |
                   c_rlink_cmd_attn =>      -- stat and attn commands
                n.state := s_rxccrc;          -- next: read command crc
              when others =>
                n.state := s_txnak;           -- next: send nak
            end case;                     -- rcmd,ccmd always hold good cmd 
          end if;
        end if;
        
      when s_rxaddr =>                  -- s_rxaddr: wait for addr -----------
        ibusy := '0';                     -- accept input
        if RL_ENA = '1' then
          if is_comma = '1' then          -- if comma
            do_comma_abort(n.state, n.nakeop, comma_typ);
          else
            icrcena  := '1';              -- update input crc
            n.addr := idi8;               -- latch read address
            case r.rcmd(c_rlink_cmd_rbf_code) is
              when c_rlink_cmd_rreg =>      -- for rreg command
                n.state := s_rxccrc;          -- next: read command crc
              when c_rlink_cmd_wreg |
                   c_rlink_cmd_init =>      -- for wreg, init command
                n.state := s_rxdatl;          -- next: read data lsb
              when others =>                -- for rblk or wblk
                n.state := s_rxcnt;           -- next: read count
            end case;
          end if;
        end if;
        
      when s_rxdatl =>                  -- s_rxdatl: wait for data low -------
        ibusy := '0';                     -- accept input
        if RL_ENA = '1' then
          if is_comma = '1' then          -- if comma 
            do_comma_abort(n.state, n.nakeop, comma_typ);
         else
            icrcena  := '1';              -- update input crc
            n.dil := idi8;                -- latch data lsb part
            n.state := s_rxdath;          -- next: read data msb
          end if;
        end if;
        
      when s_rxdath =>                  -- s_rxdath: wait for data high ------
        ibusy := '0';                     -- accept input
        if RL_ENA = '1' then
          if is_comma = '1' then          -- if comma
            do_comma_abort(n.state, n.nakeop, comma_typ);
          else
            icrcena  := '1';              -- update input crc
            n.dih := idi8;                -- latch data msb part
            if r.rcmd(c_rlink_cmd_rbf_code) = c_rlink_cmd_wblk then  -- if wblk
              n.rbaval := '1';              -- prepare rbus cycle
              n.state  := s_wstart;         -- next: start write reg
           else                           -- otherwise
             n.state := s_rxccrc;         -- next: read command crc
           end if;
          end if;
        end if;
        
      when s_rxcnt =>                   -- s_rxcnt: wait for count -----------
        ibusy := '0';                     -- accept input
        if RL_ENA = '1' then
          if is_comma = '1' then            -- if comma
            do_comma_abort(n.state, n.nakeop, comma_typ);
          else
            icrcena  := '1';              -- update input crc
            n.cnt := idi8;                -- latch count
            n.state := s_rxccrc;          -- next: read command crc
          end if;
        end if;

      when s_rxccrc =>                  -- s_rxccrc: wait for command crc ----
        ibusy := '0';                     -- accept input
        if RL_ENA = '1' then
          if is_comma = '1' then            -- if comma
            do_comma_abort(n.state, n.nakeop, comma_typ);
          else
            if idi8 /= ICRC_OUT then        -- if crc error
                                              -- unless the command is stat
              if r.rcmd(c_rlink_cmd_rbf_code) /= c_rlink_cmd_stat then
                n.cerr := '1';                   -- set command error flag
              end if;
              n.state  := s_txnak;            -- next: send nak
            else                            -- if crc ok
              n.state := s_txcmd;             -- next: echo command
            end if;
          end if;
        end if;
        
      when s_txcmd =>                   -- s_txcmd: send cmd -----------------
        ido := '0' & r.rcmd;              -- send read command
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          ocrcena  := '1';                  -- update output crc
          if r.rcmd(c_rlink_cmd_rbf_code) /= c_rlink_cmd_stat then --unless stat
            n.ccmd  := r.rcmd;                -- latch current command in ccmd
            n.stat  := RB_STAT;               -- latch external status bits
            n.cerr  := '0';
            n.derr  := '0';
            n.rbnak := '0';
            n.rberr := '0';
          end if;
          n.nakcerr := '0';                 -- all command rx done up to here

          case r.rcmd(c_rlink_cmd_rbf_code) is -- main command dispatcher
            when c_rlink_cmd_rreg  =>          -- rreg ----------------
              n.rbaval := '1';                   -- prepare rbus cycle
              n.state := s_rstart;               -- next: start read reg
            when c_rlink_cmd_rblk =>           -- rblk ----------------
              n.state := s_txcnt; 
            when c_rlink_cmd_wreg =>           -- wreg ----------------
              n.rbaval := '1';                   -- prepare rbus cycle
              n.state := s_wstart;               -- next: start write reg
            when c_rlink_cmd_wblk =>           -- wblk ----------------
              n.nakderr := '1';                  -- set derr on eop/nak abort
              n.state := s_rxdatl;
            when c_rlink_cmd_stat =>           -- stat ----------------
              n.state := s_txccmd;
            when c_rlink_cmd_attn =>           -- attn ----------------
              n.state := s_attn;
              
            when c_rlink_cmd_init =>           -- init ----------------
              n.rbinit := '1';                   -- send init pulse
              if r.addr(7 downto 3) = "11111" then   -- is internal init
                if r.addr(2 downto 0) = "111" then     -- is rri init 
                  n.anena  := r.dih(c_rlink_iint_rbf_anena  - 8);
                  n.itoena := r.dih(c_rlink_iint_rbf_itoena - 8);
                  n.itoval := r.dil(ITOWIDTH-1 downto 0);
                                            -- note: itocnt will load in next
                                            -- cycle because ito_go=0, so no
                                            -- action required here
                  
                end if;
              else                                -- is external init
                n.rbwe := '1';                      -- send init with we
              end if;
              n.state := s_txstat;
              
            when others =>                    -- '111' ---------------
              n.state := s_txnak;               -- send NAK on reserved command
          end case;
        end if;
        
      when s_txcnt =>                   -- s_txcnt: send cnt -----------------
        ido := '0' & r.cnt;               -- send cnt
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          ocrcena  := '1';                  -- update output crc
          n.rbaval := '1';                  -- prepare rbus cycle
          n.state  := s_rstart;             -- next: start first read reg
        end if;

      when s_rstart =>                  -- s_rstart: start reg or blk read ---
        n.rbaval := '1';                  -- start actual read cycle
        n.rbre   := '1';
        n.state  := s_rreg;               -- next: reg read 

      when s_rreg =>                    -- s_rreg: do reg or blk read --------
        -- this state handles all rbus reads
        ato_go := '1';                    -- activate timeout counter
        if RB_SRES.err = '1' then         -- latch rbus error flag
          n.rberr := '1';
        end if;
        n.doh := RB_SRES.dout(15 downto 8); -- latch data
        n.dol := RB_SRES.dout( 7 downto 0);
        n.stat := RB_STAT;                -- latch external status bits
        if RB_SRES.busy='0' or ato_end='1' then -- wait for non-busy or timeout
          if RB_SRES.busy='1' and ato_end='1' then -- if timeout and still busy
            n.rbnak := '1';                   -- set rbus nak flag
          elsif RB_SRES.ack = '0' then      -- if non-busy and no ack
            n.rbnak := '1';                    -- set rbus nak flag            
          end if;
          n.state := s_txdatl;              -- next: send data lsb
        else                              -- otherwise rbus read continues
          n.rbaval := '1';                  -- extend cycle
          n.rbre   := '1';
        end if;
    
      when s_txdatl =>                  -- s_txdatl: send data low -----------
        ido := '0' & r.dol;               -- send data
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          ocrcena  := '1';                -- update output crc
          n.state := s_txdath;            -- next: send data msb
        end if;
        
      when s_txdath =>                  -- s_txdath: send data high
        ido := '0' & r.doh;               -- send data
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          ocrcena  := '1';                -- update output crc
          if r.rcmd(c_rlink_cmd_rbf_code) = c_rlink_cmd_rblk then -- if rblk
            n.state := s_blk;             -- next: block count handling
          else                            -- otherwise
            n.state := s_txstat;          -- next: send stat
          end if;
        end if;
        
      when s_wstart =>                  -- s_wstart: start reg or blk write --
        n.rbaval := '1';                  -- start actual write cycle
        n.rbwe   := '1';
        n.state  := s_wreg;               -- next: reg write 
        
      when s_wreg =>                    -- s_wreg: do reg or blk write -------
        -- this state handles all rbus writes
        ato_go := '1';                    -- activate timeout counter
        if RB_SRES.err = '1' then         -- latch rbus error flag
          n.rberr := '1';
        end if;
        n.stat := RB_STAT;                -- latch external status bits
        if RB_SRES.busy='0' or ato_end='1' then -- wait for non-busy or timeout
          if RB_SRES.busy='1' and ato_end='1' then -- if timeout and still busy
            n.rbnak := '1';                    -- set rbus nak flag
          elsif RB_SRES.ack='0' then        -- if non-busy and no ack
            n.rbnak := '1';                    -- set rbus nak flag            
          end if;
          if r.rcmd(c_rlink_cmd_rbf_code) = c_rlink_cmd_wblk then   -- if wblk
            n.state := s_blk;               -- next: block count handling
          else                              -- otherwise
            n.state := s_txstat;            -- next: send stat
          end if;
        else                              -- otherwise rbus write continues
          n.rbaval := '1';                  -- extend cycle
          n.rbwe   := '1';
        end if;
          
      when s_blk =>                     -- s_blk: block count handling -------
        n.cnt := slv(unsigned(r.cnt) - 1);-- decrement transfer count
        if unsigned(r.cnt) = 0 then       -- if last transfer 
          if r.rcmd(c_rlink_cmd_rbf_code) = c_rlink_cmd_rblk then -- if rblk
            n.state := s_txstat;          -- next: send stat
          else                            -- otherwise
            n.state := s_rxdcrc;          -- next: read data crc
          end if;

        else                              -- otherwise more to transfer
          if r.rcmd(c_rlink_cmd_rbf_code) = c_rlink_cmd_rblk then   -- if rblk
            n.rbaval := '1';                -- prepare rbus cycle
            n.state := s_rstart;            -- next: start read blk
          else                            -- otherwise
            n.state := s_rxdatl;            -- next: read data
          end if;
        end if;
        
      when s_rxdcrc =>                  -- s_rxdcrc: wait for data crc -------
        ibusy := '0';                     -- accept input
        if RL_ENA = '1' then
          if is_comma = '1' then            -- if comma
            do_comma_abort(n.state, n.nakeop, comma_typ);
          else
            if idi8 /= ICRC_OUT then        -- if crc error
              n.derr := '1';                  -- set data error flag
            end if;
            n.state := s_txstat;          -- next: echo command
          end if;
        end if;
        
      when s_attn =>                    -- s_attn: handle attention flags ----
        n.dol := r.attn(7 downto 0);      -- move attention flags to do buffer
        n.doh := r.attn(15 downto 8);
        n.attn := RB_LAM;                 -- LAM in current cycle send next time
        n.andone := '0';                  -- reenable attn nofification
        n.state := s_txdatl;              -- next: send data lsb
        
      when s_txccmd =>                  -- s_txccmd: send last command
        ido := '0' & r.ccmd;              -- send last accepted command
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
          ocrcena  := '1';                -- update output crc
          n.state := s_txdatl;            -- next: send last data lsb
        end if;
        
      when s_txstat =>                  -- s_txstat: send status -------------
        ido := (others=>'0');
        ido(c_rlink_stat_rbf_stat)  := r.stat;
        ido(c_rlink_stat_rbf_attn)  := has_attn;
        ido(c_rlink_stat_rbf_cerr)  := r.cerr;
        ido(c_rlink_stat_rbf_derr)  := r.derr;
        ido(c_rlink_stat_rbf_rbnak) := r.rbnak;
        ido(c_rlink_stat_rbf_rberr) := r.rberr;
        ival := '1';
        if RL_HOLD  ='0' then             -- wait for accept
          ocrcena  := '1';                -- update output crc
          n.state := s_txcrc;             -- next: send crc
        end if;
        
      when s_txcrc =>                   -- s_txcrc: send crc -----------------
        ido := "0" & OCRC_OUT;            -- send crc code
        ival := '1';
        if RL_HOLD = '0' then             -- wait for accept
                                            -- if dcrc seen in wblk
          if r.rcmd(c_rlink_cmd_rbf_code)=c_rlink_cmd_wblk and r.derr='1' then
            n.state := s_txnak;             -- next: send nak
          else                            -- otherwise
            n.nakcerr := '0';               -- clear 'set on nak' requests
            n.nakderr := '0';
            n.state := s_rxcmd;             -- next: read command or eop
          end if;
        end if;
        
      when others => null;              -- <> --------------------------------
    end case;

    if ato_go = '0' then                -- handle access timeout counter
      n.atocnt := atocnt_init;          -- if ato_go=0, keep in reset
    else
      n.atocnt := slv(unsigned(r.atocnt) - 1);-- otherwise count down
    end if;
    
    if ito_go = '0' then                -- handle idle timeout counter
      n.itocnt := r.itoval;             -- if ito_go=0, keep at start value
    else
      if CE_INT = '1' then
        n.itocnt := slv(unsigned(r.itocnt) - 1);-- otherwise cnt dn every CE_INT
      end if;
    end if;
    
    N_REGS <= n;

    RL_BUSY  <= ibusy;
    RL_DO    <= ido;
    RL_VAL   <= ival;

    RL_MONI.eop  <= r.moneop;
    RL_MONI.attn <= r.monattn;
    RL_MONI.lamp <= r.monlamp;
    
    RB_MREQ      <= rb_mreq_init;
    RB_MREQ.aval <= r.rbaval;
    RB_MREQ.re   <= r.rbre;
    RB_MREQ.we   <= r.rbwe;
    RB_MREQ.init <= r.rbinit;
    RB_MREQ.addr <= r.addr;
    RB_MREQ.din  <= r.dih & r.dil;

    CRC_RESET <= crcreset;
    ICRC_ENA  <= icrcena;
    OCRC_ENA  <= ocrcena;
    OCRC_IN   <= ido(7 downto 0);

  end process proc_next;

end syn;
