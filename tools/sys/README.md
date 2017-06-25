This directory contains udev rule files which ensure that
- FTDI based USB UARTs are operated with low latency
- Digilent FT2232C style FPGA boards receive a persistent device name

To setup udev rules do
```bash
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

to verify whether persistent device name applied
```bash
   ls -al /dev/fpga_*
```
