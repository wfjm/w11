This directory contains udev rules which ensure that the Cypress FX2 on
- Digilent Nexys2
- Digilent Nexys3
- Digilent Atlys

is read/write accessible for user land processes, either in
- original power on state          _(thus Digilent VID/PID)_
- after custom firmware is loaded  _(thus VOTI VID/PID)_

> **The rules assume that eligible user accounts are in group `plugdev`.  
> Check with the `groups` command whether your account is in group `plugdev`,  
> in not, add this group to your accounts groups list.**

To setup udev rules do
```bash
    sudo cp -a 99-retro-usb-permissions.rules /etc/udev/rules.d/
    sudo chown root:root /etc/udev/rules.d/99-retro-usb-permissions.rules
    dir /etc/udev/rules.d/

    sudo udevadm control --reload-rules
```

to verify whether usb device was really put into group `plugdev`
```bash
  lsusb
    # --> look for bus/dev of interest

  find /dev/bus/usb -type c | sort| xargs ls -l
    # --> check whether bus/dev of interest is in group plugdev
```
