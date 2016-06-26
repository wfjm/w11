$Id: README_known_issues.txt 779 2016-06-26 15:37:16Z mueller $

Known issues for this release.
The case id indicates the release when the issue was first recognized.

- V0.73-1: as of vivado 2016.2 xelab shows sometimes extremely long build times,
    especially for generated post-synthesis vhdl models. But also building a 
    behavioral simulation for a w11a design can take 25 min. Even though 
    post-synthesis or post-routing models are now generated in verilog working 
    with xsim is cumbersome and time consuming.
- V0.73-2: Many post-synthesis functional and especially post-routing timing 
    simulations currently fail due to startup and initialization problems. 
    Cause is MMCM/PLL startup, which is not properly reflected in the test 
    bench. Will be resolved in an upcoming release.
- V0.73-3: The 'state number generator' code in pdp11_sequencer causes in vivado
    2016.1 (and .2) that the main FSM isn't re-coded anymore, which has high 
    impact on achievable clock rate. The two optional debug units depending on 
    the state number, dmscnt and dmcmon, are therefore currently deactivated in
    all Artix based systems (but are available on all Spartan based systems).

- V0.66-1: the TM11 controller transfers data byte wise (all disk do it 16bit 
    word wise) and allows for odd byte length transfers. Odd length transfers
    are currently not supported and rejected as invalid command. Odd byte 
    length records aren't used by OS, if at all, so in practice this limitation 
    isn't relevant.

- V0.65-1: ti_rri sometimes crashes in normal rundown (exit or ^D) when
    a cuff: type rlink is active. One gets
      terminate called after throwing an instance of 'Retro::Rexception'
        what():  RlinkPortCuff::Cleanup(): driver thread failed to stop
    doesn't affect normal operation, will be fixed in upcoming release.
- V0.65-2: some exotic RH70/RP/RM features and conditions not implemented yet
    - last block transfered flag (in DS)
    - CS2.BAI currently ignored and not handled
    - read or write 'with header' gives currently ILF
    All this isn't used by any OS, so in practice not relevant.

- V0.64-6: IO delays still unconstraint in vivado. All critical IOs use
    explicitly IOB flops, thus timing well defined.
- V0.64-2: rlink throughput on basys3/nexys4 limited by serial port stack 
    round trip times. Will be overcome by libusb based custom driver.
- V0.64-1: The large default transfer size for disk accesses leads to bad
    throughput in the DL11 emulation for low speed links, like the
    460kBaud the S3board is limited too. Will be overcome by a DL11
    controller with more buffering.

- V0.62-2: rlink v4 error recovery not yet implemented, will crash on error
- V0.62-1: Command lists aren't split to fit in retransmit buffer size
    {last two issues not relevant for w11 backend over USB usage because 
    the backend produces proper command lists and the USB channel is 
    usually error free}
