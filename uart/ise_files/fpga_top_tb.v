`timescale 1ns / 1ps
`include "fpga_top.v"

module fpga_top_tb();

// Testbench uses a 100 MHz clock
parameter c_CLOCK_PERIOD_NS = 10;

reg r_clock = 0;
reg r_rst = 0;
wire w_uart_tx;


fpga_top fpga_top_inst  (
	.clk(r_clock),
	.rst_n(r_rst),
	.uart_tx(w_uart_tx)
);

always
	#(c_CLOCK_PERIOD_NS/2) r_clock <= !r_clock;

initial begin
	$dumpfile("aes_tb.vcd");
	$dumpvars;

	@(posedge r_clock);
	r_rst <= 1;
	@(posedge r_clock);
	

	#1000000;
	$finish;
end

endmodule