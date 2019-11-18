// module flashing
// 	#(
// 		parameter counter_bits = 8,
// 		parameter counter_bits_1 = counter_bits - 1)

// 	(
// 		input clk,
// 		input rst,
// 		output d
// 	);

// 	reg [counter_bits_1:0] counter;
// 	reg clk_count;
// 	wire d1,d2,d3;
// 	reg [2:0] state;



// 	always @(posedge clk or negedge rst) begin
// 		if (!rst) begin
// 			counter <= {counter_bits{1'b0}};
// 		end else begin
// 			counter <= counter + {{counter_bits_1{1'b0}}, 1'b1};
// 			if (counter[counter_bits_1] == 1'b1)
// 		end
// 	end

// 	always @(negedge d3) begin
// 		state <= counter_bits_1-1;
// 	end

// 	always @(negedge d1) begin
// 		state <= counter_bits_1-3;
// 	end

// 	assign d = counter[state];
// 	assign d1 = counter[counter_bits_1-1];
// 	assign d2 = counter[counter_bits_1-2];
// 	assign d3 = counter[counter_bits_1-3];

// endmodule

module flashing ( clk, rstb, led_0);
  input clk;    //clk 40MHz
  input rstb;   //reset 0:reset 
  output led_0; //led control 0:on 1:off
  reg  rstb_dff1;
  reg  rstb_dff2;
  reg  rstb_dff3;
  reg  rst_sig;
  reg  start_sig;
  reg  led_0;
  reg  [31:0] led_cnt;
  reg  [31:0] led_cnt_max;

//スイッチ入力のメタステーブル対策   
always @ (posedge clk  )begin
   rstb_dff1 <= rstb ;
   rstb_dff2 <= rstb_dff1 ;
   rstb_dff3 <= rstb_dff2 ;
end

//入力信号の立下り検出　カウンタ初期化信号
always @ (posedge clk  )begin
  if ((rstb_dff2 == 1'b0)&&(rstb_dff3==1'b1))
    rst_sig <= 1'b1;
  else
    rst_sig <= 1'b0;
end

//入力信号の立上がり検出　カウント開始信号
always @ (posedge clk  )begin
  if ((rstb_dff2 == 1'b1)&&(rstb_dff3==1'b0))
    start_sig <= 1'b1;
  else
    start_sig <= 1'b0;
end

//カウンタ最大値の記録   
always @ (posedge clk )
  if (rst_sig==1'b1) 
    led_cnt_max <= 32'hffffffff;
  else if (start_sig == 1'b1)
    led_cnt_max <= led_cnt;

//カウンタ
always @ (posedge clk )
  if (rst_sig==1'b1) 
    led_cnt <= 26'b0;
  //カウントスタートorカウンタ最大値
  else if ((start_sig == 1'b1)||(led_cnt == led_cnt_max))
    led_cnt <= 26'b0; //カウンタを0
  else
    led_cnt <= led_cnt + 26'd1; //カウントアップ

//LED制御
always @ (posedge clk)
  if (rst_sig==1'b1)
    led_0 <= 1'b0;
  else if (start_sig == 1'b1)
    led_0 <= 1'b1;
  else if (led_cnt == led_cnt_max) 
    led_0 <= ~led_0;
  else
    led_0 <= led_0;

endmodule