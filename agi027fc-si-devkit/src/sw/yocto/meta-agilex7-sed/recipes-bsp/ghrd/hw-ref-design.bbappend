FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit deploy

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Proprietary;md5=0557f9d92cf58f2ccdd50f62f8ac0b28"

IMAGE_TYPE ?= "gsrd"
ARM64_GHRD_CORE_RBF = "ghrd.core.rbf"

sha256sum_PTP_2P25G_MCQ = "9840a269a627a5bb079227736954b19b3674150a29eee71357bc84fa90a324ba"

SRC_URI:agilex7_dk_si_agi027fc = "\
                file://${MACHINE}_gsrd_ghrd_${SOLUTION}.core.rbf;name=agilex7_gsrd_core \
                "

SRC_URI[agilex7_gsrd_core.sha256sum] = "${@ d.getVar('sha256sum_'+"d.getVar('SOLUTION')")"}"

do_install () {
        if [[ "${MACHINE}" == *"agilex"* ]]; then
                install -D -m 0644 ${WORKDIR}/${MACHINE}_gsrd_ghrd_${SOLUTION}.core.rbf ${D}/boot/${ARM64_GHRD_CORE_RBF}
	fi
}

do_deploy () {
        if [[ "${MACHINE}" == *"agilex"* ]]; then
                install -D -m 0644 ${WORKDIR}/${MACHINE}_gsrd_ghrd_${SOLUTION}.core.rbf ${DEPLOYDIR}/${MACHINE}_${IMAGE_TYPE}_ghrd/${ARM64_GHRD_CORE_RBF}
	fi
}
