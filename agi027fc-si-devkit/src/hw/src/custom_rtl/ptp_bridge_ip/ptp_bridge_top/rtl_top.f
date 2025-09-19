//setenv BRDG_RTL /nfs/site/disks/<workspace>/acds/prototype/ptp_bridge_ip/design/rtl/

-F $BRDG_RTL/ptp_bridge_common/rtl.f
-F $BRDG_RTL/ptp_bridge_wadj/rtl.f
-F $BRDG_RTL/ptp_bridge_igr_arb/rtl.f
-F $BRDG_RTL/ptp_bridge_dmux/rtl.f
-F $BRDG_RTL/ptp_bridge_misc/rtl.f
-F $BRDG_RTL/ptp_bridge_lkup/rtl.f
-F $BRDG_RTL/ptp_bridge_parse_class/rtl.f
-F $BRDG_RTL/ptp_bridge_dbg_components/rtl.f
-F $BRDG_RTL/ptp_bridge_top/rtl.f
  
