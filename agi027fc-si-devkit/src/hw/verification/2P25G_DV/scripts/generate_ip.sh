########################################################################
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
########################################################################
#-------------------------------------------------------------------------
# Script to upgrade IP/Qsys system given a list of .ip/.qsys
#-------------------------------------------------------------------------

usage()
{
   echo "usage: sh upgrade_ip.sh <Path to IP list> "
   echo "       e.g. sh upgrade_ip.sh \$RP_ROOTDIR/syn/ptile_x16/agilex_soc_devkit_ghrd/P_tile_subsystem/design/setup/ip_list.f "
   exit -1
}
echo "markdtet generate_ip Started"

cleanup()
{
   find . -name synth -exec rm -rf {} \;
   find . -name aldec -exec rm -rf {} \;
   find . -name cadence -exec rm -rf {} \;
   find . -name xcelium -exec rm -rf {} \;
   find . -name ncsim_files.tcl -exec rm -rf {} \;
   find . -name riviera_files.tcl -exec rm -rf {} \;
   find . -name xcelium_files.tcl -exec rm -rf {} \;
   find . -name aldec_files.txt -exec rm -rf {} \;
   find . -name cadence_files.txt -exec rm -rf {} \;
   find . -name *_bb.v -exec rm -rf {} \;
   find . -name *.cmp -exec rm -rf {} \;
   find . -name *.csv -exec rm -rf {} \;
   find . -name *.html -exec rm -rf {} \;
   find . -name *_inst.v -exec rm -rf {} \;
   find . -name *_inst.vhd -exec rm -rf {} \;
   find . -name *.qgsimc -exec rm -rf {} \;
   find . -name *.qgsynthc -exec rm -rf {} \;
   find . -name *.rpt -exec rm -rf {} \;
   find . -name *.qip -exec rm -rf {} \;
   find . -name *.sopcinfo -exec rm -rf {} \;
   find . -name *.xml -exec rm -rf {} \;
   find . -name *.ppf -exec rm -rf {} \;
   find . -name *.bsf -exec rm -rf {} \;   
}

IP_FLIST=$1
echo "markdtet generate_ip IP_FLIST $IP_FLIST"

if [ -z $IP_FLIST ]; then
   echo "Error: IP flist is not passed in to the script. "
   usage
fi

echo "markdtet generate_ip IP_FLIST $IP_FLIST"
if [ -z $IP_FLIST ] || [ ! -f $IP_FLIST ]; then
   echo "Error: IP flist \"$IP_FLIST\" does not exist."
   usage
fi

IP_FLIST=$(readlink -f $IP_FLIST)
first=1 

#set -xe

echo "markdtet generate_ip IP_FLIST $IP_FLIST"

for ip in `grep -vE '^(\s*$|#)' $IP_FLIST`
do
    if [ $first -gt 0 ] 
    then
        batch_string="$ip"
        first=0
    else
        batch_string="$batch_string --batch=$ip"
    fi 
    
done

echo "markdtet generate_ip batch_string=$batch_string"

qsys-generate --simulation=VERILOG --simulator=VCS,VCSMX,MODELSIM $batch_string --search-path="$DESIGN_DIR/intel_custom_ip/**/*,$DESIGN_DIR/custom_ip/**/*,$DESIGN_DIR/custom_rtl/**/*,$DESIGN_DIR/ip/**/*,$DESIGN_DIR/ip/**/**/*,$DESIGN_DIR/qsys/**/*,$DESIGN_DIR/../synth/avst_axist_bridge_hw.tcl,$DESIGN_DIR/../synth/conduit_split_1to10_hw.tcl,$DESIGN_DIR/../synth/eth_f_ptp_mtod_top_hw.tcl,$DESIGN_DIR/../synth/eth_ptp_adpt_hw.tcl,$DESIGN_DIR/../synth/hssi_ets_ts_adapter_hw.tcl,$DESIGN_DIR/../synth/port_tod_stack_hw.tcl,$DESIGN_DIR/../synth/tod_conduit_split_hw.tcl,$"
cleanup || true >/dev/null 2>&1
echo "markdtet generate_ip DONE"
