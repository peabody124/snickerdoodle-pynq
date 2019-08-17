SRC_URI_append = " file://platform-top.h"
SRC_URI += " file://0001-u-boot-snickerdoodle-create-files-as-patch.patch"
SRC_URI += " file://ethernet_spi.cfg"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
