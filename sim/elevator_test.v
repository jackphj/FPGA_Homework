`timescale 1ps/1ps

module elevator_test;

reg clk;															//电梯基准时钟
reg  [3 :0] outsideUp;									//电梯外上升请求按钮
reg  [3 :0] outsideDown;								//电梯外下降请求按钮
reg  [3 :0] insideFloor;								//电梯内楼层按钮
wire  [3 :0] queueUp,queueDown,queueinside;		//电梯请求楼层序列


initial begin
	clk = 1'b0;
	outsideUp = 4'b0000;
	outsideDown = 4'b0000;
	insideFloor = 4'b0000;
	
	#2000
	outsideUp = 4'b0010;
	#100
	outsideUp = 4'b0000;
end

always #1 clk = ~clk;

elevator_input test(clk,outsideUp,outsideDown,insideFloor,queueUp,queueDown,queueinside);

endmodule

