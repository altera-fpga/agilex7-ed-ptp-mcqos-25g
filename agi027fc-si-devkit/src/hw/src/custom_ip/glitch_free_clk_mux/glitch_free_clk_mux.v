//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 

//NOTE: Switching from clock A to clock B requires that clock A continue to operate
// for at least a few cycles. If clock A stops immediately, the design sticks. The 
// select signals are implemented as a “one-hot” control in this example, but you 
// can use other encoding if you prefer. The input side logic is asynchronous and 
// is not critical. This design can tolerate extreme glitching during the switch process.

module glitch_free_clk_mux (clk_in1, clk_in2,clk_select,clk_out);

	parameter num_clocks = 2;

	input                  clk_in1;
	input                  clk_in2;
	input [num_clocks-1:0] clk_select; // one hot
	output clk_out;

	genvar i;

	reg [num_clocks-1:0] ena_r0;
	reg [num_clocks-1:0] ena_r1;
	reg [num_clocks-1:0] ena_r2;
	wire [num_clocks-1:0] qualified_sel;
        wire [num_clocks-1:0] clk;

	// A look-up-table (LUT) can glitch when multiple inputs 
	// change simultaneously. Use the keep attribute to
	// insert a hard logic cell buffer and prevent 
	// the unrelated clocks from appearing on the same LUT.

	wire [num_clocks-1:0] gated_clks /* synthesis keep */;
        assign clk = {clk_in2,clk_in1};

	initial begin
		ena_r0 = 0;
		ena_r1 = 0;
		ena_r2 = 0;
	end

	generate
		for (i=0; i<num_clocks; i=i+1) 
		begin : lp0
			wire [num_clocks-1:0] tmp_mask;
			assign tmp_mask = {num_clocks{1'b1}} ^ (1 << i);

			assign qualified_sel[i] = clk_select[i] & (~|(ena_r2 & tmp_mask));

			always @(posedge clk[i]) begin
				ena_r0[i] <= qualified_sel[i];    	
				ena_r1[i] <= ena_r0[i];    	
			end

			always @(negedge clk[i]) begin
				ena_r2[i] <= ena_r1[i];    	
			end

			assign gated_clks[i] = clk[i] & ena_r2[i];
		end
	endgenerate

	// These will not exhibit simultaneous toggle by construction
	assign clk_out = |gated_clks;

endmodule
