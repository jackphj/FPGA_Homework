/**基本功能 ： 升降设计，楼层显示，请求信号显示，门开关，故障显示报警，防夹设置**/


module elevator(clk,outsideUp,outsideDown,insideFloor);

parameter floor = 6;

input clk;															//电梯基准时钟
input	 [floor-1 :0] outsideUp;								//电梯外上升请求按钮
input  [floor-1 :0] outsideDown;								//电梯外下降请求按钮
input  [floor-1 :0] insideFloor;								//电梯内楼层按钮

reg clock;
wire [floor-1 :0] currentFloor;
wire [floor-1 :0] queueUp,queueDown,queueinside;		//电梯请求楼层序列
reg [floor-1 :0] queueUp_new,queueDown_new,queueinside_new;


assign queueUp = queueUp ^~ queueUp_new;		//自动去除已到达楼层
assign queueDown = queueDown ^~ queueDown_new;
assign queueinside = queueinside ^~ queueinside_new;


elevator_clk clk(clk,clock);
elevator_input input_process(clk,outsideUp,outsideDown,insideFloor,queueUp,queueDown,queueinside);
elevator_control control(clock,clk,queueUp,queueDown,queueinside,currentFloor,queueUp_new,queueDown_new,queueinside_new);


endmodule
