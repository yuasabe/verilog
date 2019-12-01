`timescale 1ns / 1ps

`include "aes.v"

module aes_tb();

// Testbench uses a 10 MHz clock
parameter c_CLOCK_PERIOD_NS = 100;

reg r_clock = 0;
reg [0:127] r_plain = 0;
reg [0:127] r_key = 0;
wire [0:127] w_cipher = 0;

aes_top aes_top_inst (
	.i_clock(r_clock),
	.i_plain(r_plain),
	.i_key(r_key),
	.o_cipher(w_cipher)
);

always
	#(c_CLOCK_PERIOD_NS/2) r_clock <= !r_clock;

initial begin
	$dumpfile("aes_tb.vcd");
	$dumpvars;

	@(posedge r_clock);
	r_plain <= 128'h00112233445566778899aabbccddeeff;
	r_key <= 128'h000102030405060708090a0b0c0d0e0f;

	#10000;
	$finish;
end
endmodule