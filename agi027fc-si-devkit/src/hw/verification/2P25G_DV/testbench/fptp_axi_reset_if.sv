//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

/**
 * Abstract:
 * Defines an interface that provides access to a reset signal.  This
 * interface can be used to write sequences to drive the reset logic.
 */

`ifndef FPTP_AXI_RESET_IF
`define FPTP_AXI_RESET_IF

interface fptp_axi_reset_if();

  logic reset;
  logic clk;

  modport axi_reset_modport (input clk, output reset);

endinterface

`endif // FPTP_AXI_RESET_IF
