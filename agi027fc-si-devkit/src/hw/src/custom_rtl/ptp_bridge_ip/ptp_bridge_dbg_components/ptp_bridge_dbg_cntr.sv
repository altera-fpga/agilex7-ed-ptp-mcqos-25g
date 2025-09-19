//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 

module ptp_bridge_dbg_cntr #(
    parameter CNTR_WIDTH=32,
    parameter NUM_CNTR=1
)(
   input logic                                    clk
  ,input logic                                    rst
  ,input logic [NUM_CNTR-1:0]                     enable
  ,input logic [NUM_CNTR-1:0] [CNTR_WIDTH-1:0]    cntr_i
  ,output logic [NUM_CNTR-1:0] [CNTR_WIDTH-1:0]   cntr_o
);

  // genvar cntr_n;
  always_ff @(posedge clk) begin
    for (int cntr_n = 0; cntr_n < NUM_CNTR; cntr_n++) begin
      if (rst) begin
        cntr_o <= '0;
      end
      if (enable[cntr_n] && !(cntr_i[cntr_n] == '1)) begin
          cntr_o[cntr_n] <= cntr_i[cntr_n] + 1'b1;
      end
    end
  end
endmodule
