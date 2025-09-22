########################################################################
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
########################################################################
#Makefile 
########################################################################
export WORKDIR=$(PTP_ROOTDIR)/
SCRIPTS_DIR = $(WORKDIR)/scripts
QIP_DIR = $(SCRIPTS_DIR)
VIPDIR = $(WORKDIR)/vip
VCDFILE = $(WORKDIR)/scripts/vpd_dump.key
IP_FLIST_PATH = $(SCRIPTS_DIR)/ip_list.f
IP_SETUP_LIST = $(SCRIPTS_DIR)/ip_setup_list.f

VLOG_OPT = -kdb -full64 -kdb +verilog2001ext+.v -error=noMPD -ntb_opts uvm-1.2 +vcs+initreg+random +vcs+lic+wait -sverilog +vcs+lic+wait -l ./../sim/vlog.log -Mdir=./../sim/output/csrc +warn=noBCNACMBP -CFLAGS +error+1000 +define+UVM_DISABLE_AUTO_ITEM_RECORDING +define+UVM_NO_DEPRECATED +define+UVM_PACKER_MAX_BYTES=1500000 -debug_acc -timescale=1ns/1ps +libext+.v+.sv+.svi +define+UVM_VERDI_NO_COMPWAVE -debug_acc +define+SVT_UVM_TECHNOLOGY +define+SYNOPSYS_SV -notice -work work 

VLOG_OPT += +incdir+./
VLOG_OPT += +incdir+$(VIPDIR)/axi_vip/src/sverilog/vcs
VLOG_OPT += +incdir+$(VIPDIR)/axi_vip/include/sverilog
VLOG_OPT += +incdir+$(VIPDIR)/axi_vip/src/verilog/vcs
VLOG_OPT += +incdir+$(VIPDIR)/axi_vip/include/verilog
VLOG_OPT += -y $(VIPDIR)/axi_vip/src/sverilog/vcs
VLOG_OPT += -y $(VIPDIR)/axi_vip/src/verilog/vcs
VLOG_OPT += +incdir+$(UVM_HOME)
VLOG_OPT += +incdir+$(UVM_HOME)/src
VLOG_OPT += +incdir+$(UVM_HOME)/src/vcs
VLOG_OPT += +incdir+$(DESIGNWARE_HOME)/vip/svt/amba_svt/latest/sverilog/src/vcs/
VLOG_OPT += +incdir+$(DESIGN_DIR)/custom_rtl/hssi/rtl/inc
VLOG_OPT += +incdir+$(DESIGN_DIR)
VLOG_OPT += +incdir+$(WORKDIR)/testbench
VLOG_OPT += +incdir+$(WORKDIR)/tests
VLOG_OPT += +incdir+$(WORKDIR)/tests/sequences

ifdef HSSI_25G
	VLOG_OPT += +define+RTLSIM +define+__ALTERA_STD__METASTABLE_SIM +define+UNHIDE_cr3v0 -hsopt=gates +systemverilogext+.sv +define+TIMESCALE_EN +define+RTLSIM +define+IP7581SERDES_UXS2T1R1PGD_PIPE_SPEC_FORCE +define+IP7581SERDES_UXS2T1R1PGD_PIPE_SIMULATION +define+IP7581SERDES_UXS2T1R1PGD_PIPE_FAST_SIM +define+INTC_FUNCTIONAL +define+SPEC_FORCE +define+__ALTERA_STD__METASTABLE_SIM +define+RDY_LAT=0 +define+EHIP +define+FAST_CLK +define+CRETE3 +define+ACDS_19_1 +define+SIM_MODE +define+FTILE_PTP_HSSI_10G_25G +define+FTILE_PTP_HSSI_25G +define+MAC_SRD_CFG_25G +define+HSSI_2P25G 
endif 

VLOG_OPT += $(QUARTUS_INSTALL_DIR)/eda/sim_lib2/quartus_dpi.c +define+QUARTUS_ENABLE_DPI_FORCE $(QUARTUS_INSTALL_DIR)/eda/sim_lib2/simsf_dpi.cpp

VCS_OPT = -full64 -ntb_opts uvm-1.2 -licqueue   -xlrm module_xmr  +vcs+lic+wait -ignore initializer_driver_checks -l vcs.log -debug_access+all +error+100
VCS_OPT  += $(QUARTUS_INSTALL_DIR)/eda/sim_lib2/quartus_dpi.c $(QUARTUS_INSTALL_DIR)/eda/sim_lib2/simsf_dpi.cpp -debug_region+cell+lib

SIMV_OPT = +UVM_TESTNAME=$(TESTNAME) -l ./simulate_$(TESTNAME).log run +UVM_VERBOSITY=UVM_DEBUG +UVM_OBJECTION_TRACE +seqname=$(SEQNAME)
SIMV_OPT += $(QUARTUS_INSTALL_DIR)/eda/sim_lib2/quartus_dpi.c


ifdef DUMP
    VLOG_OPT += -debug_access+all +define+VCS_DUMP
    VCS_OPT += -debug_access+all
    SIMV_OPT += -ucli -i $(VCDFILE)
endif

ifdef COV
    VLOG_OPT += +define+COV -cm line+cond+fsm+tgl+branch -cm_name $(WORKDIR)/sim/ -cm_dir simv.vdb
    VCS_OPT  += -cm line+cond+fsm+tgl+branch -cm_name $(WORKDIR)/sim/ -cm_dir simv.vdb
    SIMV_OPT += -cm line+cond+fsm+tgl+branch -cm_name $(TESTNAME) -cm_dir ../regression.vdb
endif

ifndef SEED
    SIMV_OPT += +ntb_random_seed_automatic
else
    SIMV_OPT += +ntb_random_seed=$(SEED)
endif

create_new_flist:
	cp $(SYNTH_DIR)/ip_list.tcl $(SCRIPTS_DIR)/ip_list.tcl
	cp $(SYNTH_DIR)/rtl_list.tcl $(SCRIPTS_DIR)/rtl_list.tcl
	perl ip_script.pl ip_list.tcl
	perl rtl_script.pl rtl_list.tcl
	cp $(SCRIPTS_DIR)/ip_list.f $(SCRIPTS_DIR)/ip_setup_list.f
	sh support_logic_gen.sh 

cmplib:	create_new_flist gen_qip gen_ip_lib gen_vip

gen_qip:
	sh generate_ip.sh $(IP_FLIST_PATH) 
	gen_ip_sim_setup.sh $(IP_SETUP_LIST)
	perl parser_for_PTP.pl $(DESIGN_DIR)

gen_ip_lib:
	mkdir -p ../ip_libraries
	cp -f qip_sim_script/synopsys/vcsmx/synopsys_sim.setup ../ip_libraries/
	cd ../ip_libraries && sh ../scripts/qip_sim_script/synopsys/vcsmx/vcsmx_setup.sh SKIP_SIM=1 QSYS_SIMDIR=../scripts/qip_sim_script QUARTUS_INSTALL_DIR=$(QUARTUS_HOME) DEVICES_SIM_LIB_DIR=$(QUARTUS_INSTALL_DIR)/../devices/sim_lib2 QUARTUS_SIM_LIB_DIR=$(QUARTUS_INSTALL_DIR)/eda/sim_lib2 USER_DEFINED_COMPILE_OPTIONS="+define+__ALTERA_STD__METASTABLE_SIM TOP_LEVEL_NAME=qsys_top.qsys_top" 

gen_vip:
	mkdir -p ../vip/axi_vip/
	@$(DESIGNWARE_HOME)/bin/dw_vip_setup -path ../vip/axi_vip/ -e amba_svt/tb_axi_svt_uvm_basic_sys -svtb

build: vlog vcs

vlog:
	mkdir -p ../sim && cd ../sim/ && mkdir -p output logs 
	rsync -avz --checksum --ignore-times ../ip_libraries/* $(WORKDIR)/sim/
	cd $(WORKDIR)/sim && vlogan -ntb_opts uvm-1.2 -sverilog
	cd $(WORKDIR)/sim && vlogan $(VLOG_OPT) -f $(SCRIPTS_DIR)/rtl_list.f  -f $(SCRIPTS_DIR)/rtl_filelist.f  -f $(SCRIPTS_DIR)/../ver_list.f
		
vcs: 
	cd $(WORKDIR)/sim/ && vcs $(VCS_OPT) fptp_top_tb 
        

run:
	sh rename_prev_testdir.sh $(TESTNAME)
	cd $(WORKDIR)/sim/ && mkdir -p $(TESTNAME) && cd $(TESTNAME) && cp -f ../*.hex . && cp -f ../*.mif . && ../simv $(SIMV_OPT)


