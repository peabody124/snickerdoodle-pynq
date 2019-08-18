# PYNQ on a Snickerdoodle Black (and Prime LE)

This provides a board definition for Snickerdoodle Prime that can be used to create a PYNQ build (using PetaLinux). This allows creating a python interface to the custom PL hardware running on the FPGA. The interface for the SnickerdoodleBlack also has support for the PiSmasher Ethernet hardware, and shoudl be fairly straightforward to extend with things like audio and HDMI support as an optional overlay.

This build process will create an SD card that should work without issues. It is largely based on https://pynq.readthedocs.io/en/v2.4/pynq_sd_card.html. It was tested with Ubuntu 16.04 in Virtualbox (fresh install) and I found it did not work on Ubuntu 18.04 as PetaLinux does not install on this properly.

**Quick start** if you have a PYNQ respository and all the prerequisites in place:
```
cd <your_location>/PYNQ/sdbuild
make BOARDDIR=/path/to/snickerdoodle-pynq BOARDS=SnickerdoodleBlack
```

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

At this point you should be able to use the official PYNQ v2.4 repository, although I was having issues from the gcc-mb (microblaze support) so you can use my branch if that is an issue. 

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

# Known issues

* PetaLinux 2018.3 breaks the kernel configuration for UIO (via pulling in opanamp) as it makes one part the UIO driver a module and trumps changes from other sources. I could not find a way to override this from the meta-layer. For now you can edit your PetaLinux install. ```PetaLinxu-2018.3/components/yocto/source/arm/conf/bblayers.conf```. Note, that this is required to perform asynchronous DMA transfers.

* gcc-mb does not compile (which I'll keep pushing on, because I'd like the coprocessor). One part of this requires this patch.
```
cat 0001-Fix-gcc-mb-build.patch 
From b1c56e886733d632f071ac7b8beb57862ec84172 Mon Sep 17 00:00:00 2001
From: James Cotton <peabody124@gmail.com>
Date: Sun, 23 Dec 2018 19:54:27 -0600
Subject: [PATCH 1/2] Fix gcc-mb build

---
 .../samples/aarch64-linux-gnu,microblazeel-xilinx-elf/crosstool.config   | 1 +
 .../samples/arm-linux-gnueabihf,microblazeel-xilinx-elf/crosstool.config | 1 +
 2 files changed, 2 insertions(+)

diff --git a/sdbuild/packages/gcc-mb/samples/aarch64-linux-gnu,microblazeel-xilinx-elf/crosstool.config b/sdbuild/packages/gcc-mb/samples/aarch64-linux-gnu,microblazeel-xilinx-elf/crosstool.config
index 4e68dc9..42938dd 100644
--- a/sdbuild/packages/gcc-mb/samples/aarch64-linux-gnu,microblazeel-xilinx-elf/crosstool.config
+++ b/sdbuild/packages/gcc-mb/samples/aarch64-linux-gnu,microblazeel-xilinx-elf/crosstool.config
@@ -12,4 +12,5 @@ CT_HOST="aarch64-linux-gnu"
 CT_BINUTILS_V_2_23_2=y
 CT_BINUTILS_CUSTOM=y
 CT_BINUTILS_CUSTOM_LOCATION="${CT_COMPILE_ROOT}/binutils"
+CT_BINUTILS_CUSTOM_VERSION="2_23_2"
 CT_CC_LANG_CXX=y
diff --git a/sdbuild/packages/gcc-mb/samples/arm-linux-gnueabihf,microblazeel-xilinx-elf/crosstool.config b/sdbuild/packages/gcc-mb/samples/arm-linux-gnueabihf,microblazeel-xilinx-elf/crosstool.config
index 81f3d52..d80d37d 100644
--- a/sdbuild/packages/gcc-mb/samples/arm-linux-gnueabihf,microblazeel-xilinx-elf/crosstool.config
+++ b/sdbuild/packages/gcc-mb/samples/arm-linux-gnueabihf,microblazeel-xilinx-elf/crosstool.config
@@ -12,4 +12,5 @@ CT_HOST="arm-linux-gnueabihf"
 CT_BINUTILS_V_2_23_2=y
 CT_BINUTILS_CUSTOM=y
 CT_BINUTILS_CUSTOM_LOCATION="${CT_COMPILE_ROOT}/binutils"
+CT_BINUTILS_CUSTOM_VERSION="2_23_2"
 CT_CC_LANG_CXX=y
-- 
2.7.4
```

But I'm still working on another related to the gcc not building with Ubuntu's compiler.
