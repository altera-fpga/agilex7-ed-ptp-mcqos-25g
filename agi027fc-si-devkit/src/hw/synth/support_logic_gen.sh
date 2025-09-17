
#-------------------------------------------------------------------------
# Script to upgrade IP/Qsys system given a list of .ip/.qsys
#-------------------------------------------------------------------------

usage()
{
   echo "Usage: sh support_logic_gen.sh  <target> <10G/25G/50G/100G speed>"
   echo "eg: sh support_logic_gen.sh 25G"
   exit -1
}

ETH_SPEED="${1}"

WORK_SYN_TOP_PATH=${SRD_ROOTDIR}/src/hw/synth/

# Create work directory copying from qsf and qpf files
echo $WORK_SYN_TOP_PATH



# #Based on speed select the MACRO
# if [ $ETH_SPEED = 2G ]; then
#    sed -i "s/MAC_SRD_CFG_25G/MAC_SRD_CFG_100G/" ${WORK_SYN_TOP_PATH}/macsec_srd.qsf
# else
#    sed -i "s/MAC_SRD_CFG_100G/MAC_SRD_CFG_25G/" ${WORK_SYN_TOP_PATH}/macsec_srd.qsf
# 
# fi

# Goto work directory and generate IP and Support logic
cd ${WORK_SYN_TOP_PATH}
quartus_ipgenerate top -c top --run_default_mode_op 

echo "IP Generation generation DONE"

quartus_tlg --read_settings_files=on --write_settings_files=off  top -c top 
echo "Support logic generation DONE"

