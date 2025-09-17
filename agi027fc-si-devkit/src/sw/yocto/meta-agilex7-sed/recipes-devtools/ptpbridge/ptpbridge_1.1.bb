SUMMARY = "PTP Bridge IP configurator for Linux on ARM"
DESCRIPTION = "PTP Bridge IP configurator executable for Linux to control ptpbridge module"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7c6367005511b6ea56cf4966d5ba33fb"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
 
SRC_URI = "file://ptpbridge_v1.1.tgz"
S = "${WORKDIR}/ptpbridge_v1.1"

#do_compile () {
#	#bbnote "PTPBridge Executing compile... - ${S}. Workdir: ${WORKDIR}"
#	#echo -n "Source Dir - ${S}. Workdir: ${WORKDIR}"
#	#cd ${S}
#	oe_runmake
#}

#do_install () {
#	#bbnote "PTPBridge Executing install... - ${S}. Workdir: ${WORKDIR}"
#	#echo -n "Source Dir - ${S}. Workdir: ${WORKDIR}"
#	install -d ${D}/${bindir}
#	install -p ${S}/ptpbridge  ${D}/${bindir}
#}

inherit autotools pkgconfig
FILES:${PN} += "${bindir}/ptpbridge"
