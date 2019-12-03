`timescale 1ns / 1ps

module fpga_top_tb();

// Testbench uses a 100 MHz clock
parameter c_CLOCK_PERIOD_NS = 10;

reg r_clock;
reg r_rst;


fpga_top fpga_top_inst  (
	.clk(r_clock),
	.rst_n(r_rst),
	
);

always
	#(c_CLOCK_PERIOD_NS/2) r_clock <= !r_clock;

initial begin
	$dumpfile("aes_tb.vcd");
	$dumpvars;

	@(posedge r_clock);
	

	#10000;
	$finish;
end

endmodule