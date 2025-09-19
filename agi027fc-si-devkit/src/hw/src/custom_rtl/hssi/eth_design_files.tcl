# ######################################################################## 
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
# ######################################################################## 

#
# Ethernet
#--------------------

set_global_assignment -name SEARCH_PATH "hssi/rtl/inc"

#-----------------
# HSSI Common Files
#-----------------
set_global_assignment -name SYSTEMVERILOG_FILE    hssi/rtl/inc/ofs_fim_eth_plat_defines.svh 
set_global_assignment -name SYSTEMVERILOG_FILE    hssi/rtl/inc/ofs_fim_eth_plat_if_pkg.sv 
set_global_assignment -name SYSTEMVERILOG_FILE    hssi/rtl/inc/ofs_fim_eth_if_pkg.sv 
set_global_assignment -name SYSTEMVERILOG_FILE    hssi/rtl/inc/ofs_fim_eth_if.sv 
set_global_assignment -name SYSTEMVERILOG_FILE    hssi/rtl/inc/ofs_fim_eth_avst_if_pkg.sv 
set_global_assignment -name SYSTEMVERILOG_FILE    hssi/rtl/inc/ofs_fim_eth_avst_if.sv 
set_global_assignment -name SYSTEMVERILOG_FILE    hssi/rtl/lib/ofs_fim_eth_afu_avst_to_fim_axis_bridge.sv 
set_global_assignment -name SYSTEMVERILOG_FILE    hssi/rtl/lib/ofs_fim_eth_sb_afu_avst_to_fim_axis_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE    hssi/rtl/lib/mm_ctrl_xcvr.sv
set_global_assignment -name SYSTEMVERILOG_FILE    hssi/rtl/lib/rst_ack.sv
set_global_assignment -name SYSTEMVERILOG_FILE    hssi/rtl/lib/fim_resync.sv

#-----------------
# HSSI SS IP
#-----------------
#set_global_assignment -name IP_FILE                hssi/qip/hssi_ss/hssi_ss_1.ip
#set_global_assignment -name IP_FILE               hssi/qip/ptp_iopll/ptp_sample_clk_pll.ip
#
##----------------------------------
## HSSI SS CSR Interconnect
##----------------------------------
#set_global_assignment -name QSYS_FILE             hssi/qip/axilite_ic/hssi_ss_csr_ic.qsys
#set_global_assignment -name IP_FILE               hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_csr_ic_clock_in.ip
#set_global_assignment -name IP_FILE               hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_csr_ic_reset_in.ip
#set_global_assignment -name IP_FILE               hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_csr_mst.ip
#set_global_assignment -name IP_FILE               hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_ip_slv.ip
#set_global_assignment -name IP_FILE               hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_wrapper_slv.ip

#-----------------
# HSSI SS top
#-----------------
#set_global_assignment -name SYSTEMVERILOG_FILE    hssi/rtl/hssi_wrapper_csr.sv
#set_global_assignment -name SYSTEMVERILOG_FILE    hssi/rtl/hssi_wrapper.sv

#-----------------
# QSFP Controller
#-----------------
#set_global_assignment -name IP_FILE               qsfp/ip/qsfp_ctrl.qsys
#set_global_assignment -name IP_FILE               qsfp/ip/qsfp_ctrl_reset_in.ip
#set_global_assignment -name IP_FILE               qsfp/ip/qsfp_ctrl_i2c_0.ip
#set_global_assignment -name IP_FILE               qsfp/ip/qsfp_ctrl_onchip_memory2_0.ip
#set_global_assignment -name IP_FILE               qsfp/ip/qsfp_ctrl_clock_in.ip
#
#set_global_assignment -name SYSTEMVERILOG_FILE    qsfp/rtl/csr_wr_logic.sv
#set_global_assignment -name SYSTEMVERILOG_FILE    qsfp/rtl/poller_fsm.sv
#set_global_assignment -name SYSTEMVERILOG_FILE    qsfp/rtl/qsfp_com.sv
#set_global_assignment -name SYSTEMVERILOG_FILE    qsfp/rtl/qsfp_top.sv

