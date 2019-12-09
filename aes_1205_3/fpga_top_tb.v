`timescale 1ns / 1ps

`include "fpga_top.v"

`define assert(signal, value) \
	if (signal !== value) begin \
	    $display("%6d ASSERTION FAILED in %m: signal != value", $time); \
	    $finish; \
	end else begin \
		$display("%6d ASSERTION OK in %m", $time); \
	end

module fpga_top_tb();

// Testbench uses a 10 MHz clock
parameter c_CLOCK_PERIOD_NS = 100;

reg r_clock = 0;
reg r_rst = 0;
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
	.rst_n(r_rst),
	.uart_tx(w_uart_tx)
);

always
	#(c_CLOCK_PERIOD_NS/2) r_clock <= !r_clock;

initial begin
	$dumpfile("fpga_top_tb.vcd");
	$dumpvars;

	$monitor("%h", fpga_top.w_plain);

	@(posedge r_clock);
	@(posedge r_clock);
	#1000;
	r_rst <= 1;
	#1000;
	r_rst <= 0;

	// Assert initial state
	// `assert(fpga_top.r_plain, 128'h3243f6a8885a308d313198a2e0370734);
	// `assert(fpga_top.r_key, 128'h2b7e151628aed2a6abf7158809cf4f3c);
	// `assert(fpga_top.w_cipher, 128'h0);
	// `assert(fpga_top.aes_top.r_key0, 32'h2b7e1516);
	// `assert(fpga_top.aes_top.r_key1, 32'h28aed2a6);
	// `assert(fpga_top.aes_top.r_key2, 32'habf71588);
	// `assert(fpga_top.aes_top.r_key3, 32'h09cf4f3c);

	// #300;
	// `assert(fpga_top.aes_top.r_data, 128'h3243f6a8885a308d313198a2e0370734);
	// #200
	// `assert(fpga_top.aes_top.r_data, 128'h193de3bea0f4e22b9ac68d2ae9f84808);
	// #200
	// `assert(fpga_top.aes_top.r_data, 128'hd42711aee0bf98f1b8b45de51e415230);
	// #200
	// `assert(fpga_top.aes_top.r_data, 128'hd4bf5d30e0b452aeb84111f11e2798e5);
	// #700
	// `assert(fpga_top.aes_top.r_data, 128'h046681e5e0cb199a48f8d37a2806264c);
	// `assert(fpga_top.aes_top.r_key0, 32'ha0fafe17);
	// `assert(fpga_top.aes_top.r_key1, 32'h88542cb1);
	// `assert(fpga_top.aes_top.r_key2, 32'h23a33939);
	// `assert(fpga_top.aes_top.r_key3, 32'h2a6c7605);
	// #200
	// `assert(fpga_top.aes_top.r_data, 128'ha49c7ff2689f352b6b5bea43026a5049);
	// #200
	// `assert(fpga_top.aes_top.r_data, 128'h49ded28945db96f17f39871a7702533b);
	// #200
	// `assert(fpga_top.aes_top.r_data, 128'h49db873b453953897f02d2f177de961a);

	

	#4000;
	r_rst <= 1;
	#2000;
	r_rst <= 0;

	// Assert initial state
	// `assert(fpga_top.r_plain, 128'h3243f6a8885a308d313198a2e0370734);
	// `assert(fpga_top.r_key, 128'h2b7e151628aed2a6abf7158809cf4f3c);
	// `assert(fpga_top.w_cipher, 128'h0);
	// `assert(fpga_top.aes_top.r_key0, 32'h2b7e1516);
	// `assert(fpga_top.aes_top.r_key1, 32'h28aed2a6);
	// `assert(fpga_top.aes_top.r_key2, 32'habf71588);
	// `assert(fpga_top.aes_top.r_key3, 32'h09cf4f3c);

	// #300;
	// `assert(fpga_top.aes_top.r_data, 128'h3243f6a8885a308d313198a2e0370734);

	// #200
	// `assert(fpga_top.aes_top.r_data, 128'h193de3bea0f4e22b9ac68d2ae9f84808);

	// #1600;
	// `assert(fpga_top.aes_top.r_key0, 32'ha0fafe17);
	// `assert(fpga_top.aes_top.r_key1, 32'h88542cb1);
	// `assert(fpga_top.aes_top.r_key2, 32'h23a33939);
	// `assert(fpga_top.aes_top.r_key3, 32'h2a6c7605);

	// r_plain <= 128'h00112233445566778899aabbccddeeff;
	// r_plain <= 128'h3243f6a8885a308d313198a2e0370734;
	// r_key <= 128'h000102030405060708090a0b0c0d0e0f;
	// r_key <= 128'h2b7e151628aed2a6abf7158809cf4f3c;

	#100000;

	// `assert(fpga_top.r_plain, 128'h3243f6a8885a308d313198a2e0370734);
	// `assert(fpga_top.r_key, 128'h2b7e151628aed2a6abf7158809cf4f3c);
	// `assert(fpga_top.w_cipher, 128'h3925841d02dc09fbdc118597196a0b32);
	$finish;
end
endmodule