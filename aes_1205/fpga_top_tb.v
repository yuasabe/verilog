`timescale 1ns / 1ps

`include "fpga_top.v"

module fpga_top_tb();

// Testbench uses a 10 MHz clock
parameter c_CLOCK_PERIOD_NS = 100;

reg r_clock = 0;
// reg [0:127] r_plain = 0;
// reg [0:127] r_key = 0;
// wire [0:127] w_cipher;
wire w_uart_tx;

// aes_top aes_top_inst (
// 	.i_clock(r_clock),
// 	.i_plain(r_plain),
// 	.i_key(r_key),
// 	.o_cipher(w_cipher)
// );

fpga_top fpga_top(
	.clk(r_clock),
	.uart_tx(w_uart_tx)
);

always
	#(c_CLOCK_PERIOD_NS/2) r_clock <= !r_clock;

initial begin
	$dumpfile("fpga_top_tb.vcd");
	$dumpvars;

	@(posedge r_clock);
	// r_plain <= 128'h00112233445566778899aabbccddeeff;
	// r_plain <= 128'h3243f6a8885a308d313198a2e0370734;
	// r_key <= 128'h000102030405060708090a0b0c0d0e0f;
	// r_key <= 128'h2b7e151628aed2a6abf7158809cf4f3c;

	#10000000;
	$finish;
end
endmodule