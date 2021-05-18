/***中控，控制上下行和开关门和***/

module elevator_control(clock,clk,queueUp,queueDown,queueinside,currentFloor,queueUp_new,queueDown_new,queueinside_new);		//clk=1Hz

parameter floor = 6;

input clock,clk;
input [floor-1 :0] queueUp,queueDown,queueinside;		//电梯请求楼层序列
output [floor-1 :0] currentFloor;
//output [floor-1 :0] LED;


output reg [floor-1 :0] queueUp_new,queueDown_new,queueinside_new;

reg [floor-1 :0] Floor;
reg [31 :0] times;
reg openDoor;	
reg status [1 :0];		//0:停止 1:上升 2：下降 [0]当前状态 [1]下一个状态
reg [floor-1 :0] temp_floor;

reg [floor-1 :0] temp;
wire [floor-1 :0] temp_queueUp;
wire [floor-1 :0] temp_queueDown;
wire [floor-1 :0] temp_queueinside;
reg flag_dir;
reg reset;
reg reseted;

output [floor-1 :0] door;

initial begin
	Floor = 1'd1;  //初始状态在1楼
	times = 32'd0;
	openDoor = 1'b0;
	status[0] = 1'd0;
	status[1] = 1'd0;
	temp = 6'b000001;
	flag_dir = 1'd0;
	reset = 1'b1;
	reseted = 1'b0;
	temp_floor = 6'b000001;
	queueUp_new = queueUp;
	queueDown_new = queueDown;
	queueinside_new =queueinside_new;
end

assign currentFloor = Floor;


/********电梯运动********/
always @(clock) begin
	if(clock) begin
		status[0] <= status[1];
		$display("clock |||");
	end
	else begin						//检测下一个状态以得到楼层，每次运动1层
		$display("clock ...");
		if(status[1] == 1'd0)
			Floor = Floor;	
		else if(status[1] == 1'd1)
			Floor = Floor + 1'd1;
		else if(status[1] == 1'd2)
			Floor = Floor - 1'd1;
		else
			$display("error");
		reset <= 1'd1;
		
		$display("floor:%d",Floor);			//楼层显示
		
		if(Floor == 1) temp_floor = 6'b000001;			//我也不知道为什么不能用1'd1:和case，用了仿真老出错，还是if稳定
		else if(Floor == 2) temp_floor = 6'b000010;
		else if(Floor == 3) temp_floor = 6'b000100;
		else if(Floor == 4) temp_floor = 6'b001000;
		else if(Floor == 5) temp_floor = 6'b010000;
		else if(Floor == 6) temp_floor = 6'b100000;

		$display("temp floor:%b",temp_floor);
		if(temp_floor & (queueUp | queueDown | queueinside)) begin	//将当前楼层与所有请求队列与操作检测是否需要开门
			$display("111111");
			openDoor <= 1'b1;
			elevator_openDoor D(clock,currentFloor,door);
			if(status[0] == 1'd0) begin										//清空队列中当前开门的楼层
				queueDown_new <= queueDown ^ temp_floor & queueDown;
				queueUp_new <= queueUp ^ temp_floor & queueUp;
				queueinside_new <= queueinside ^ temp_floor & queueinside;
				
			end
			else if(status[0] == 1'd1) begin									//清空队列中当前开门的楼层
				queueUp_new <= queueUp ^ temp_floor & queueUp;
				queueinside_new <= queueinside ^ temp_floor & queueinside;
			end
			else if(status[0] == 1'd2) begin									//清空队列中当前开门的楼层
				queueDown_new <= queueDown ^ temp_floor & queueDown;
				queueinside_new <= queueinside ^ temp_floor & queueinside;
			end
		end
		else begin
			openDoor <= 1'b0;
		end	
		//$display("queueUp_new:%b",queueUp_new);//调试
	end
end


assign temp_queueUp = queueUp & temp;
assign temp_queueDown = queueDown & temp;
assign temp_queueinside = queueinside & temp;

always @(clk) begin

	if(reset) begin
	
		reset <= 1'd0;
		$display("currentFloor:%d",currentFloor);
		
		if(currentFloor == 1) temp = 6'b000001;
		else if(currentFloor == 2) temp = 6'b000010;
		else if(currentFloor == 3) temp = 6'b000100;
		else if(currentFloor == 4) temp = 6'b001000;
		else if(currentFloor == 5) temp = 6'b010000;
		else if(currentFloor == 6) temp = 6'b100000;

	end
	
	//$display("temp_queueUp:%b",temp_queueUp);//调试
	
	if(status[0] == 1'd0 || status[0] ==1'd1) begin					//遍历请求序列，优先向上且保持运动反向，同时先检测最近的楼层
		if (temp_queueUp || temp_queueDown || temp_queueinside) begin		//遇到有请求设置运动方向
			case(flag_dir)
				0: status[1] = 1'd0;			//这里case好像不会出问题
				1: status[1] = 1'd1;
				2: status[1] = 1'd2;
			endcase
			//$display("status:%d",status[1]);//调试
		end
		else if(temp < 6'b100000 && reseted == 1'b0) begin		
			temp = temp << 1;
			flag_dir <= 1'd1;
			//$display("0:1 %b",temp);//调试
		end
		else if(temp == 6'b100000 && reseted == 1'b0) begin
			reset <= 1'd1;
			reseted = 1'b1;
			//$display("0:2 %b",temp);//调试
		end
		else if(temp > 6'd000001 && reseted == 1'b1) begin
			temp = temp >> 1;
			flag_dir <= 1'd2;
			//$display("0:3 %b",temp);//调试
		end
		else if(temp == 6'd000001 && reseted == 1'b1) begin
			reset <= 1'd1;
			reseted = 1'b0;
			//$display("0:4 %b",temp);//调试
		end
	end
	
	else if(status[0] == 1'd2) begin
		if (temp_queueUp || temp_queueDown || temp_queueinside) begin
			case(flag_dir)
				0: status[1] = 1'd0;
				1: status[1] = 1'd1;
				2: status[1] = 1'd2;
			endcase
		end
		else if(temp > 6'd000001 && reseted == 1'b0) begin
			temp = temp >> 1;
			flag_dir <= 1'd2;
			//$display("1:1 %b",temp);//调试
		end
		else if(temp == 6'd000001 && reseted == 1'b0) begin
			reset <= 1'd1;
			reseted = 1'b1;
			//$display("1:2 %b",temp);//调试
		end
		else if(temp > 6'd100000 && reseted == 1'b1) begin
			temp = temp << 1;
			flag_dir <= 1'd1;
			//$display("1:3 %b",temp);//调试
		end
		else if(temp == 6'd100000 && reseted == 1'b1) begin
			reset <= 1'd1;
			reseted = 1'b0;
			//$display("1:4 %b",temp);
		end
		
	end
end

endmodule
