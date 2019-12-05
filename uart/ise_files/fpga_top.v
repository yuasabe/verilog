// `timescale 1ns / 1ps

`include "uart.v"

module fpga_top(
	input clk, // AD8 100MHz
	input rst_n, // T23
	// input BUTTON_C, // B21
	output uart_tx // AD14
	// output LED_C, // T22
	// output LED_E, // Y18
	// output LED_W, // AA18
	// output LED_S, // AA8
	// output LED_N, // Y8
	// output [7:0] LED
);
 
reg [7:0] r_tx_byte;
  
wire uart_we;
reg r_uart_we;
wire uart_OUT_data;
wire uart_busy;
	 
uart uart0(
    .uart_tx(uart_OUT_data),
	.uart_busy(uart_busy),
    .uart_wr_i(uart_we),
    .uart_dat_i(r_tx_byte),
    .sys_clk_i(clk),
    .sys_rstn_i(rst_n)
);
	 
	assign uart_tx = uart_OUT_data;
	assign uart_we = r_uart_we;
	
	wire [7:0] w_byte_A = 8'h41;
	wire [7:0] w_byte_B = 8'h42;
	wire [7:0] w_chars [0:31];
	reg [2:0] r_sm_main = 0;
	reg [2:0] uart_counter = 3'b000;
	
assign w_chars[0] = w_byte_A;
assign w_chars[1] = w_byte_B;
  
always @(posedge clk) begin
	case (r_sm_main)
		3'b000 : begin
			r_uart_we <= 0;
			r_tx_byte <= w_byte_A;
			r_sm_main <= 3'b001;
		end
		3'b001 : begin
			r_uart_we <= 1;
			r_sm_main <= 3'b010;
		end
		3'b010 : begin
			r_sm_main <= 3'b011;
		end
		3'b011 : begin
			if (~uart_busy) begin // not busy
				r_sm_main <= 3'b100;
			end
		end
		3'b100 : begin
			if (~rst_n) begin // reset
				r_sm_main <= 3'b000;
			end
		end
	endcase
end

endmodule
