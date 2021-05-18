module elevator_clk(clk,clock);

input clk;
output reg clock;

reg [31 :0] times;
reg flag;

initial begin
	clock = 1'b0;
	times = 32'd0;
	flag = 1'b0;
end

always @(clk) begin
	if(times < 32'd16 && flag == 1'b0) begin  //产生1Hz信号 占空比80%
		times <= times + 32'd1;
	end
	else if(times == 32'd16 && flag == 1'b0) begin
		times <= 32'd0;
		clock <= 1'b0;
		flag <= 1'b1;
	end
	else if(times < 32'd4 && flag == 1'b1) begin  
		times <= times + 32'd1;
	end
	else if(times == 32'd4 && flag == 1'b1) begin
		times <= 32'd0;
		clock <= 1'b1;
		flag <= 1'b0;
	end
end
endmodule
