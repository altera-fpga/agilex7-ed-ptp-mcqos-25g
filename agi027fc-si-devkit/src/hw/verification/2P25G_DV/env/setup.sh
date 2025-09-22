########################################################################
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
########################################################################
# Contais TB ENV Varibales used for Simulation
########################################################################

export WORKDIR=PTP_ROOTDIR
export DESIGN_DIR=$PTP_ROOTDIR/../../src
export QUARTUS_HOME=$QUARTUS_ROOTDIR
export QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
export QUARTUS_ROOTDIR_OVERRIDE=$QUARTUS_ROOTDIR
export DESIGNWARE_HOME= <synopsys vip location> version -vip_R-2020.09A
export UVM_HOME=$VCS_HOME/etc/uvm-1.2
export SYNTH_DIR=$PTP_ROOTDIR/../../synth


echo "VCS                 " $VCS_HOME
echo "QUARTUS_HOME        " $QUARTUS_HOME
echo "IMPORT_IP_ROOTDIR   " $IMPORT_IP_ROOTDIR
echo "PTP_ROOTDIR         " $PTP_ROOTDIR
echo "SCRIPT_DIR          " $SCRIPT_DIR
echo "DESIGN_DIR          " $DESIGN_DIR
echo "SYNTH_DIR           " $SYNTH_DIR

