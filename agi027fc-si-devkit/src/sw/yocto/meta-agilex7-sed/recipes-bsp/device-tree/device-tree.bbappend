do_configure:append() {
        if [[ "${MACHINE}" == *"agilex"* ]]; then
                # DTB Generation
                cp ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts/intel/socfpga_fm87_ftile_25g_2port_mcq_ptp.dts ${WORKDIR}/socfpga_fm87_ftile_25g_2port_mcq_ptp.dts
                cp ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts/intel/fm87_ftile_25g_2port_mcq_ptp.dtsi ${WORKDIR}/fm87_ftile_25g_2port_mcq_ptp.dtsi
                cp ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts/intel/fm87_agilex_ftile.dtsi ${WORKDIR}/fm87_agilex_ftile.dtsi
        fi
}

