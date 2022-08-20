This directory contains [udev](https://en.wikipedia.org/wiki/Udev) rule files
which ensure that
- FTDI based USB UARTs are operated with low latency
- Digilent FT2232C style FPGA boards receive a persistent device name

Each Digilent FT2232C style FPGA board has a unique serial number
of the USB interface. This can be used to assign a human readable alias
of the form `/dev/fpga_...` to a board.
The file [92-retro-usb-persistent.rules](92-retro-usb-persistent.rules)
contains _example rules_ valid for the boards of the author.
**This file must be adopted to the available boards before it is used.**
Use
```bash
    udevadm info -q all -n /dev/ttyUSB1
    #
    # /dev/ttyUSB1 is correct if the FPGA board is the only USB tty device.
    # If you have other USB tty devices adopt to your needs
    #
```
to determine the `ID_SERIAL_SHORT` and create rules for your boards.

To set up udev rules do
```bash
    cd $RETROBASE/tools/sys
    # !! adopt 92-retro-usb-persistent.rules to your needs !!
    sudo cp -a 91-retro-usb-latency.rules    /etc/udev/rules.d/
    sudo cp -a 92-retro-usb-persistent.rules /etc/udev/rules.d/
    sudo chown root:root /etc/udev/rules.d/*-retro-usb-*.rules
    ls -al /etc/udev/rules.d/

    sudo udevadm control --reload-rules
```

to verify whether usb device has low latency use
```bash
    # --> deterime the /dev/ttyUSB* device of interest
    cat /sys/bus/usb-serial/devices/ttyUSB1/latency_timer
    # --> should show '1' and not '16'
```

and to verify whether persistent device name are applied use
```bash
   ls -al /dev/fpga_*
   # output like
   #  lrwxrwxrwx 1 root root 7 2020-03-15 13:55 /dev/fpga_arty -> ttyUSB1
```
