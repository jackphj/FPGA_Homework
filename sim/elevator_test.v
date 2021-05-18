`timescale 1ps/1ps

`include "../rtl/elevator_control.v"

module elevator_test;

//reg clk;															//电梯基准时钟
//reg  [3 :0] outsideUp;									//电梯外上升请求按钮
//reg  [3 :0] outsideDown;								//电梯外下降请求按钮
//reg  [3 :0] insideFloor;								//电梯内楼层按钮
//wire  [3 :0] queueUp,queueDown,queueinside;		//电梯请求楼层序列
//
//
//initial begin
//	clk = 1'b0;
//	outsideUp = 4'b0000;
//	outsideDown = 4'b0000;
//	insideFloor = 4'b0000;
//	
//	#2000
//	outsideUp = 4'b0010;
//	#100
//	outsideUp = 4'b0000;
//end
//
//always #1 clk = ~clk;
//
//elevator_input test(clk,outsideUp,outsideDown,insideFloor,queueUp,queueDown,queueinside);


reg clk;
reg [5 :0] queueUp,queueDown,queueinside;		//电梯请求楼层序列
wire currentFloor;
wire [5 :0] queueUp_new,queueDown_new,queueinside_new;
wire clock;
initial begin
	clk = 1'b0;
	queueUp = 6'b000000;
	queueDown = 6'b000000;
	queueinside = 6'b000000;
	
	
	#25 queueUp=6'b000010;
	
end

always #1 clk = ~clk;

elevator_clk a1(clk,clock);
elevator_control a2(clock,clk,queueUp,queueDown,queueinside,currentFloor,queueUp_new,queueDown_new,queueinside_new);
endmodule

