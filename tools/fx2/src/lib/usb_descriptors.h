/* -*- c++ -*- */
/* $Id: usb_descriptors.h 1194 2019-07-20 07:43:21Z mueller $ */
/*-----------------------------------------------------------------------------
 * USB descriptor references
 *-----------------------------------------------------------------------------
 * Code taken from USRP2 firmware (GNU Radio Project), version 3.0.2,
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright 2003 Free Software Foundation, Inc.
 *-----------------------------------------------------------------------------
 * This code is part of usbjtag. usbjtag is free software;
 *-----------------------------------------------------------------------------
 */

extern xdata const char high_speed_device_descr[];
extern xdata const char high_speed_devqual_descr[];
extern xdata const char high_speed_config_descr[];

extern xdata const char full_speed_device_descr[];
extern xdata const char full_speed_devqual_descr[];
extern xdata const char full_speed_config_descr[];

extern xdata unsigned char nstring_descriptors;
extern xdata char * xdata string_descriptors[];

/*
 * We patch these locations with info read from the usrp config eeprom
 */
extern xdata char usb_desc_hw_rev_binary_patch_location_0[];
extern xdata char usb_desc_hw_rev_binary_patch_location_1[];
extern xdata char usb_desc_hw_rev_ascii_patch_location_0[];
extern xdata char usb_desc_serial_number_ascii[];
