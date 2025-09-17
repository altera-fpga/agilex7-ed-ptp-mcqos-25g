FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:agilex7 = " file://uboot.txt file://uboot_script.its"
SRC_URI:agilex7_dk_si_agi027fc = "file://uboot.txt file://uboot_script.its"

do_compile() {
        if [[ "${MACHINE}" == *"agilex7"* ]]; then
                mkimage -f "${WORKDIR}/uboot_script.its" ${WORKDIR}/boot.scr.uimg
        fi
}

do_deploy() {
        install -d ${DEPLOYDIR}
        if [[ "${MACHINE}" == *"agilex7"* ]] || [[ "${MACHINE}" == "stratix10" ]]; then
                install -m 0755 ${WORKDIR}/uboot.txt ${DEPLOYDIR}/u-boot.txt
                install -m 0644 ${WORKDIR}/boot.scr.uimg ${DEPLOYDIR}/boot.scr.uimg
        fi
}

