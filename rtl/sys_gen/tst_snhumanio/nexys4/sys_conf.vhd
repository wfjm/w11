-- $Id: sys_conf.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_tst_snhumanio_n4 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  viv 2014.4; ghdl 0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-01-31   640   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  constant sys_conf_hio_debounce : boolean := true;    -- instantiate debouncers

end package sys_conf;

