# $Id: README.txt 446 2011-12-29 23:27:48Z mueller $

to setup udev rules do

  sudo cp -a 99-retro-usb-permissions.rules /etc/udev/rules.d/
  sudo chown root:root /etc/udev/rules.d/99-retro-usb-permissions.rules
  dir /etc/udev/rules.d/

  sudo udevadm control --reload-rules

to verify whether usb device was really put into group 'plugdev'

  lsusb
    --> look for bus/dev of interest

  find /dev/bus/usb -type c | sort| xargs ls -l
    --> check whether bus/dev of interest is in group plugdev
