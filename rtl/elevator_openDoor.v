module elevator_openDoor(clock,currentFloor,door);

parameter floor = 6;

input clock;
input currentFloor;
output [floor-1 :0] door;

reg flag = 1'b0; 先检测到低电平为1，高电平为0
reg [floor-1 :0] Door

initial begin
	
end

assign door = Door;

always @(clock)

	if(!clock) begin
		case(currentFloor)
			1:Door <= 6'b000001;
			2:Door <= 6'b000010;
			3:Door <= 6'b000100;
			4:Door <= 6'b001000;
			5:Door <= 6'b010000;
			6:Door <= 6'b100000;
		endcase
	end
	else begin
		Door <= 6'b000000;
	end

endmodule
