
module led_flash_tb;

	reg clk, rst;
	wire d;

	parameter CYCLE = 10;

	always #(CYCLE/2) begin
		clk = ~clk;
	end

	flashing flashing(clk, rst, d);

	initial begin
		$dumpfile("led_flash_tb.vcd");
		$dumpvars(0, led_flash_tb);
		clk = 0;
		rst = 0;
		#(CYCLE) rst = 1;
		#(CYCLE) rst = 0;
		#(CYCLE) rst = 1;
		#(CYCLE*10) rst = 0;
		#(CYCLE*5) rst = 1;
		#(10000000)
		$finish;
	end

endmodule