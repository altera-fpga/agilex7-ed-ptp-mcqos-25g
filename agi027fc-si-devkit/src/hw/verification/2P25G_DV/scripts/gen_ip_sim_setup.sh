########################################################################
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
########################################################################
#-------------------------------------------------------------------------
# Script to gen_ip_setup
#-------------------------------------------------------------------------
SCRIPTNAME="$(basename -- "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd -P)"
#PTP_ROOTDIR="$SCRIPT_DIR/.."
PTP_ROOTDIR="`pwd`"
IP_FLIST=$1

if [ -z $IP_FLIST ]; then
   echo "Usage: sh gen_ip_sim_setup.sh <ip file list>"
   exit -1
fi

set -xe

echo "markdtet gen_ip_sim_setup.sh Started!"
echo "${PTP_ROOTDIR}";

# Get IP .spd file list
ip_spd=""
spd_lst=""
first=1

for ip in `grep -vE '^(\s*$|#)' $IP_FLIST`
do
   ip_dir=$(dirname -- $ip)
   ip_file=$(basename -- $ip)
   ip_name=$(echo $ip_file | sed -e "s/\..*$//g")

   spd="${ip_dir}/${ip_name}/${ip_name}.spd"
   spd_tmp="${ip_dir}/${ip_name}/${ip_name}_tmp.spd"
   cp $spd $spd_tmp
   sed '/\<device name=/d' -i $spd_tmp

   if [ $first == 1 ]; then
      spd_lst="$spd_tmp"
   else
      spd_lst="${spd_lst}, $spd_tmp"
   fi
   first=0;

done
cp ${PTP_ROOTDIR}/top_auto_tiles/top_auto_tiles.spd ${PTP_ROOTDIR}/top_auto_tiles/top_auto_tiles_tmp.spd

spd=${PTP_ROOTDIR}/top_auto_tiles/top_auto_tiles.spd
spd_tmp=${PTP_ROOTDIR}/top_auto_tiles/top_auto_tiles_tmp.spd
spd_lst="${spd_lst}, ${PTP_ROOTDIR}/top_auto_tiles/top_auto_tiles_tmp.spd"

echo $spd_lst > spd.lst
ip-make-simscript --spd="${spd_lst}" --use-relative-paths --output-directory=./qip_sim_script --device-family=agilex

rm -rf spd.lst

set +x
for ip in `grep -vE '^(\s*$|#)' $IP_FLIST`
do
   ip_dir=$(dirname -- $ip)
   ip_file=$(basename -- $ip) 
   ip_name=$(echo $ip_file | sed -e "s/\..*$//g") 
   rm -rf $DESIGN_DIR/${ip_dir}/${ip_name}/${ip_name}_tmp.spd
done

echo "markdtet gen_ip_sim_setup.sh DONE!"
