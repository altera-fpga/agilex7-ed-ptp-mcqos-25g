########################################################################
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
########################################################################
#-------------------------------------------------------------------------
# Script to upgrade IP/Qsys system given a list of .ip/.qsys
#-------------------------------------------------------------------------

usage()
{
   echo "Usage: sh support_logic_gen.sh  "
   echo "eg: sh support_logic_gen.sh  "
   exit -1
}
WORK_SYN_TOP_PATH=${PTP_ROOTDIR}/../../synth/
SYN_TOP_PATH=${DESIGN_DIR}/

# Create work directory copying from qsf and qpf files
echo $WORK_SYN_TOP_PATH
mkdir -p $WORK_SYN_TOP_PATH
cp -rf $DESIGN_DIR/*  $WORK_SYN_TOP_PATH/

# Goto work directory and generate IP and Support logic
cd ${WORK_SYN_TOP_PATH}
quartus_ipgenerate top -c top --run_default_mode_op 

echo "IP Generation generation DONE"

quartus_tlg --read_settings_files=on --write_settings_files=off  top -c top 
echo "Support logic generation DONE"

cp -rf $WORK_SYN_TOP_PATH/support_logic/* ${PTP_ROOTDIR}/scripts/top_auto_tiles/
cp ${PTP_ROOTDIR}/scripts/top_auto_tiles/top_auto_tiles.spd ${PTP_ROOTDIR}/scripts/top_auto_tiles/top_auto_tiles_tmp.spd
echo "Support logic copied to sim directory"

#rm -rf $WORK_SYN_TOP_PATH/
#echo "Removed temporary work directory"
