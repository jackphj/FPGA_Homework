/**基本功能 ： 升降设计，楼层显示，请求信号显示，门开关，故障显示报警，防夹设置**/

module elevator_input(clk,outsideUp,outsideDown,insideFloor,queueUp,queueDown,queueinside);	//电梯输入处理，假定电梯上下键上下都为开关按键，且按下时为高电平,clk=200MHz

parameter floor = 4;

/****输入输出定义****/
input clk;															//电梯基准时钟
input	 [floor-1 :0] outsideUp;								//电梯外上升请求按钮
input  [floor-1 :0] outsideDown;								//电梯外下降请求按钮
input  [floor-1 :0] insideFloor;								//电梯内楼层按钮
output [floor-1 :0] queueUp,queueDown,queueinside;		//电梯请求楼层序列



/****按键扫描、消抖****/

/*************************************************
*	每一个clk保存3组按键信息到队列中
*	将前后两次按键状态异或得到状态变化存到status中
**************************************************/

reg [floor-1 :0] outsideUp_queue   [3 :0]; //按键检测队列，每次clk上升沿到来，记录新一次数据 [0] [1]用于判断是否有按下 [2]用于延时读取 [3]获取按键
reg [floor-1 :0] outsideDown_queue [3 :0];
reg [floor-1 :0] insideFloor_queue [3 :0];


wire [floor-1 :0]outsideUp_status;		//按键按下状态记录
wire [floor-1 :0]outsideDown_status;
wire [floor-1 :0]insideFloor_status;

reg [31:0] times_outsideUp;
reg flag_outsideUp;    	 //解决同时多个按下或一个没结束另一个按下的问题

reg [31:0] times_outsideDown;
reg flag_outsideDown;    //解决同时多个按下或一个没结束另一个按下的问题

reg [31:0] times_insideFloor;
reg flag_insideFloor;    //解决同时多个按下或一个没结束另一个按下的问题

initial
begin
	times_outsideUp <= 32'd0; //200000 - 0.05s
	times_outsideDown <= 32'd0;
	times_insideFloor <= 32'd0;
	
	flag_outsideUp <= 1'b0;
	flag_outsideDown <= 1'b0;
	flag_insideFloor <= 1'b0;
end


assign outsideUp_status = ~outsideUp_queue[1] & outsideUp_queue[0];			//按键按下0(旧状态)->1(新状态)//按键释放1(旧状态)->0(新状态)
assign outsideDown_status = ~outsideDown_queue[1] & outsideDown_queue[0];	//按键按下0(旧状态)->1(新状态)//按键释放1(旧状态)->0(新状态)
assign insideFloor_status = ~insideFloor_queue[1] & insideFloor_queue[0];	//按键按下0(旧状态)->1(新状态)//按键释放1(旧状态)->0(新状态)


/****按键状态保存队列中****/

/************************
*	前一状态      后一状态
*	  [1] -------> [0]
************************/

always @(posedge clk) begin	
	outsideUp_queue[1] = outsideUp_queue[0];
	outsideUp_queue[0] = outsideUp; 
	
	outsideDown_queue[1] = outsideDown_queue[0];
	outsideDown_queue[0] = outsideDown;
	
	insideFloor_queue[1] = insideFloor_queue[0];
	insideFloor_queue[0] = insideFloor;
end


/****延时****/
always @(clk) begin

/*UP*/
	if(outsideUp_status) begin				//在按下按键刷新计时
		times_outsideUp <= 32'd200;
		flag_outsideUp <= 1'b1;
	end
	else if(times_outsideUp > 32'd0 && flag_outsideUp == 1'b1)	begin		//按键按下后倒计时
		times_outsideUp <= times_outsideUp - 1'b1;
		
	end
	else if(times_outsideUp == 32'd0 && flag_outsideUp == 1'b1) begin	//计时结束
		times_outsideUp = 32'd0;
		
		//$display("times");
	end
	else begin 
		times_outsideUp <= 32'd0;						//无操作时自动保持times_outsideUp值
	end
	
/*Down*/
	if(outsideDown_status) begin				//在按下按键刷新计时
		times_outsideDown <= 32'd200;
		flag_outsideDown <= 1'b1;
	end
	else if(times_outsideDown > 0 && flag_outsideDown == 1'b1)	begin		//按键按下后倒计时
		times_outsideDown <= times_outsideDown - 1'b1;
	end
	else if(times_outsideDown == 0 && flag_outsideDown == 1'b1) begin	//计时结束
		times_outsideDown <= 32'd0;
		
	end
	else begin
		times_outsideDown <= 32'd0;						//无操作时自动保持times_outsideDown值
	end
	
/*inside*/
	if(insideFloor_status) begin				//在按下按键刷新计时
		times_insideFloor <= 32'd200;
		flag_insideFloor <= 1'b1;
	end
	else if(times_insideFloor > 0 && flag_insideFloor == 1'b1)	begin		//按键按下后倒计时
		times_insideFloor <= times_insideFloor - 1'b1;
	end
	else if(times_insideFloor == 0 && flag_insideFloor == 1'b1) begin	//计时结束
		times_insideFloor <= 32'd0;
		
	end
	else begin
		times_insideFloor <= 32'd0;	
	end
	
end



/****延时读取结果****/
always @(clk) begin

/*UP*/
	if(outsideUp_status) begin									   //每按下按键记录当前数值
		outsideUp_queue[2] <=  outsideUp_queue[2] | outsideUp;
	end
	else if(times_outsideUp > 0 && flag_outsideUp == 1'b1) begin		//按下第一次后,保存按下时状态
		outsideUp_queue[2] <=  outsideUp_queue[2];
		//$display("%d",times_outsideUp);
	end
	else if(times_outsideUp == 0 && flag_outsideUp == 1'b1) begin	//延时结束，得到变化的电平0->1 即为请求楼层
		flag_outsideUp = 1'b0;
		outsideUp_queue[3]<= outsideUp_queue[2] ^ outsideUp;
	end
	else outsideUp_queue[2] <=  outsideUp;						//若没有任何操作，一直保存刷新实时值
	
	
/*Down*/
	if(outsideDown_status) begin									   //每按下按键记录当前数值
		outsideDown_queue[2] <=  outsideDown_queue[2] | outsideUp;
	end
	else if(times_outsideUp > 0 && flag_outsideDown == 1'b1) begin		//按下第一次后,保存按下时状态
		outsideDown_queue[2] <=  outsideDown_queue[2];
	end
	else if(times_outsideUp == 0 && flag_outsideDown == 1'b1) begin	//延时结束，得到变化的电平0->1 即为请求楼层
		flag_outsideDown <= 1'b0;
		outsideDown_queue[3] <= outsideDown_queue[2] ^ outsideUp;
	end
	else outsideDown_queue[2] <=  outsideUp;						//若没有任何操作，一直保存刷新实时值
	
	
/*inside*/
	if(insideFloor_status) begin									   //每按下按键记录当前数值
		insideFloor_queue[2] <=  insideFloor_queue[2] | outsideUp;
	end
	else if(times_outsideUp > 0 && flag_insideFloor == 1'b1) begin		//按下第一次后,保存按下时状态
		insideFloor_queue[2] <=  insideFloor_queue[2];
	end
	else if(times_outsideUp == 0 && flag_insideFloor == 1'b1) begin	//延时结束，得到变化的电平0->1 即为请求楼层
		flag_insideFloor <= 1'b0;
		outsideDown_queue[3] <= insideFloor_queue[2] ^ outsideUp;
	end
	else insideFloor_queue[2] <=  outsideUp;						//若没有任何操作，一直保存刷新实时值
	
end

assign queueUp = outsideUp_queue[3];
assign queueDown = outsideDown_queue[3];
assign queueinside = insideFloor_queue[3];

endmodule
