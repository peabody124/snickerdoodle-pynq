SRC_URI_append = " file://platform-top.h"
SRC_URI += " file://ethernet_spi.cfg"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
