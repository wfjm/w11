# $Id: generic_asm11.mk 1275 2022-08-10 08:10:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2013-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2022-08-08  1275   1.1    add auto-dependency rule
# 2013-04-06   503   1.0.1  use --hostinc for mac2lda
# 2013-03-22   496   1.0    Initial version
#---
#

ASM11    = asm-11
ASM11EXP = asm-11_expect

MAC2LDA  = mac2lda

ifdef ASM11COMMAND
ASM11 = $(ASM11COMMAND)
endif
ifdef ASM11EXPCOMMAND
ASM11EXP = $(ASM11EXPCOMMAND)
endif

#
# Compile rules
#
%.lda : %.mac
	$(ASM11) --lda --lst $< 
%.cof : %.mac
	$(ASM11) --cof --lst $< 
#
%.lst : %.mac
	$(ASM11) --lst $< 
#
%.lsterr : %.mac
	$(ASM11) --olst=%.lsterr $< || true
#
%.lstrt %ldart : %.mac
	$(MAC2LDA) --hostinc --suff=rt $*
#
# Expect rules
#
%.lstexp : %.lst
	$(ASM11EXP) $<
#
%.lstexp : %.lsterr
	$(ASM11EXP) $<
#
# auto-dependency rule
#
%.dep : %.mac
	$(ASM11) -M $< > $@
