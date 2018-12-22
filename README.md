# PYNQ on a Snickerdoodle Prime

This provides a board definition for Snickerdoodle Prime that can be used to create a PYNQ build (using PetaLinux). This allows creating a python interface to the custom PL hardware running on the FPGA. The default implementation here currently does nothing.

This build process will create an SD card that should work without issues. It is largely based on https://pynq.readthedocs.io/en/v2.3/pynq_sd_card.html with some modifications as I am using Xilinx 2018.3 which is not yet supported. It was tested with Ubuntu 16.04 in Virtualbox (fresh install) and I found it did not work on Ubuntu 18.04 as PetaLinux does not install on this properly

## Prerequisites
### Install PetaLinux

* You must use bash instead of dash to avoid isntallation failures with PetaLinux
    sudo dpkg-reconfigure dash
        select no to use bash
* start a new shell (for that to take effect)
* ```sudo apt-get install xinetd tftpd-hpa zlib1g:i386 chrpath socat gcc-multilib```
* install petalinux into your home directory in the virtual machine. make sure the name has 2018.3 in the path. PYNQ looks at the path as a hacky approach for version checking (or if using Ubuntu 18.04 see this note https://forums.xilinx.com/t5/Embedded-Linux/PetaLinux-2018-1-Install-Fails-on-Debian-Stretch/td-p/887733 and install a sed into /usr/local/bin that fixes the installation script)


### Install Xilinx Vivado 2018.3 (use SDAccel version)

You need to use SDAccel to use a clean PYNQ distribution as it checks for sdx. However this isn't required for our build so you can just comment it out in the Makefile checks.

Install the Snickerdoodle board files
From https://github.com/krtkl/snickerdoodle-board-files
copy snickerdoodle_prime_le to Vivado/2018.3/data/boards/board_files

### Prepare PYNQ

You need to use this fork for Snickerdoodle and 2018.3. The necessary changes on master, but are not compatible with default boards.

```git clone http://github.com/peabody124/PYNQ```

```./sdbuild/scripts/setup_host.sh```                                # installs more requirements on system

## Get it running
### Build the board SD card files

    source /opt/Xilinx/PetaLinux-2018.3/settings.sh
    source /opt/Xilinx/Vivado/2018.3/settings64.sh
    source /opt/Xilinx/SDx/2018.3/settings64.sh
    cd /path/to/PYNQ/sdbuild
    make BOARDDIR=/path/to/snickerdoodle-pynq

**Make sure you use an absolute path to the the repository. The build process breaks with relative paths.**

Note if you are testing or debugging you can also call
    make boot_files BOARDDIR...
    make sysroot BOARDDIR ...

### Run SD card
* flash SD card (I use https://www.balena.io/etcher/)
* put into Snickerdoodle and boot away
* default username is xilinx and password is xilinx

### Networking to web
via command line below. **note there is also a jupyter notebook to do this in common/wifi.ipynb**

## Create your AP configuration (e.g.)
wpa_passphrase ssid password > /etc/wpa_supplicant.conf

and into /etc/network/interfaces.d/wlan0 write
```
auto wlan0
iface wlan0 inet dhcp
    wireless_mode managed
     wireless_essid ssid
     wpa-driver nl80211
     wpa-conf /etc/wpa_supplicant.conf
```

Then run

```wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf -D nl80211```

```dhclient wlan0```

### Connect to jupyter

* Connect to AP: The system should create a wifi access point "pynq-mac_address" that runs a DHCP client
* In a browser go to http://192.168.2.1
* Use the password "xilinx"

