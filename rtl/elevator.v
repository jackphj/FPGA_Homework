//基本功能 ： 升降设计，楼层显示，请求信号显示，门开关，故障显示报警，防夹设置

module elevator_input(up1,up2,up3,up4,down1,down2,down3,down4);	//电梯输入处理，假定电梯上下键上下都为开关按键，且按下时为高电平

input up1,up2,up3,up4;
input down1,down2,down3,down4;

endmodule