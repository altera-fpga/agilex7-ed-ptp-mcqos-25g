//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 

// Description
//-----------------------------------------------------------------------------
//
//  This package contains the parameter and struct definition for 
//  MACSec System reference design
//
//----------------------------------------------------------------------------

package macsec_srd_pkg;

`ifdef PCIE_USR_DATA_WIDTH_X16
localparam PCIE_LANE_W         = 16;
localparam PCIE_AXIST_DATA_W   = 512;
localparam NO_OF_QSFP          = 2;
localparam LANE_MASK          = "x16";
`else // PCIE_USR_DATA_WIDTH_X8
localparam PCIE_LANE_W         = 8;
localparam PCIE_AXIST_DATA_W   = 256;
localparam NO_OF_QSFP          = 1;
localparam LANE_MASK          = "x8";
`endif

localparam NUM_MACSEC_INST     = 2; //minimum 2

localparam MACSEC_CSR_ADDR_W   = 25;
localparam MACSEC_CSR_DATA_W   = 64;

localparam PKTCLI_CSR_ADDR_W   = 12;
localparam PKTCLI_CSR_DATA_W   = 32;

localparam AXIST_UCTRL_DATA_W  = 512;

localparam AXIST_UCTRL_USER_W  = 10;

localparam NUM_MAC_CHANNELS    = 2;

`define ETILE_SIM_MODE

`ifdef MAC_SRD_CFG_25G
localparam AXIST_CTRL_DATA_W   		   = 64;
localparam MAX_DATA_PATH_RATE  		   = 25;
localparam TRANSFER_RATE       		   = 12;
localparam TRANSFER_RATE_UNCONTROLLED_PORT = 4;
`else //if MAC_SRD_CFG_100G
localparam AXIST_CTRL_DATA_W   		   = 256;
localparam MAX_DATA_PATH_RATE  		   = 100;
localparam TRANSFER_RATE      		   = 60;
localparam TRANSFER_RATE_UNCONTROLLED_PORT = 12;
`endif

localparam AVST_DATA_W         = 64;

`ifdef MAC_SRD_CFG_25G
localparam ETH_DATA_WIDTH      = 64;
localparam ETH_EMPTY_WIDTH     = 3;
localparam NUM_LANES           = 1;
`else // MAC_SRD_CFG_100G
localparam ETH_DATA_WIDTH      = 512;
localparam ETH_EMPTY_WIDTH     = 6;
localparam NUM_LANES           = 4;
`endif

localparam AXIST_CTRL_USER_W   = 10;

endpackage : macsec_srd_pkg
