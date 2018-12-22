
This provides a board definition for Snickerdoodle Prime that can be
used to create a PYNQ build (using PetaLinux). It also provides a
PYNQ overlay which has the firmware to emulate the BISC chip and
its interface.


To use this:
cd /path/to/PYNQ
cd sdbuild
make BOARDDIR=/path/to/parent/directory


You can also call make with
   make boot_files
   make sysroot
  
