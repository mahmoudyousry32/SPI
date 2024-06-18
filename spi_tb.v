`timescale 1ps/1ps
module spi_tb;
parameter DVSR = 65536;
parameter dvsr_w = $clog2(DVSR);
parameter D_BITS = 8;
parameter SYS_CLOCK = 10;

//************************ Signal declarations **********************************************************
reg clk;
reg rst;
reg start;
reg [dvsr_w - 1 :0] dvsr;
reg miso;
reg [D_BITS-1:0] din;
reg cpha;
reg cpol;
reg [D_BITS-1:0] miso_reg;
reg [D_BITS-1:0] slave_reg_1;
reg [D_BITS-1:0] slave_reg_2;
reg ss_1;
reg ss_2;


wire mosi;
wire sclk;
wire done;
wire ready;
wire [D_BITS-1:0] dout;
wire sclk_reg;

//************************ SPI instantiation **********************************************************
spi_ctrlr	DUT(clk,
				rst,
				start,
			    dvsr,
				din,
			    dout,
				miso,
				mosi,
				sclk,
				done,
				cpha,
				cpol,
				ready,
				sclk_reg);
				
//************************ Tasks **********************************************************
task MASTER_SEND;
input [D_BITS-1:0] data;
begin
din = data ;
start <= 1;
repeat(2) begin
@(posedge clk);
end
start <= 0;
end
endtask



task RESET;
begin
rst = 0;
#20 
rst = 1;
end
endtask

task SET_DVSR;
input [dvsr_w - 1 :0] divisor;
begin
dvsr = divisor;
end
endtask

task SET_MODE;
input integer mode;
begin
case(mode)
0			:			{cpol,cpha} = 2'b00;
1			:			{cpol,cpha} = 2'b01;
2			:			{cpol,cpha} = 2'b10;
3			:			{cpol,cpha} = 2'b11;
endcase
end
endtask
//************************ MAIN tb**********************************************************

always begin
clk = 0;
#SYS_CLOCK ;
clk = 1;
#SYS_CLOCK ;
end

initial begin
RESET();
SET_DVSR(5);
SET_MODE(0);
MASTER_SEND(8'b10101010);
wait(done);
@(posedge clk);
SET_MODE(1);
@(posedge clk);
#2000;
MASTER_SEND(8'b11001101);
wait(done);
@(posedge clk);
SET_MODE(2);
@(posedge clk);
#2000;
MASTER_SEND(8'b00110101);
wait(done);
@(posedge clk);
SET_MODE(3);
@(posedge clk);
#2000;
MASTER_SEND(8'b10101010);
wait(done);
#2000;
$stop;
end

initial begin 
slave_reg_1 = 8'b11001100;
slave_reg_2 = 8'b10011011;
ss_1 = 1;
ss_2 = 1;
end

always@(negedge sclk) begin
if(!ss_1) 
slave_reg_1 = {slave_reg_1[6:0],1'b0};
end

always@(posedge sclk) begin
if(!ss_2) 
slave_reg_2 = {slave_reg_2[6:0],1'b0};
end

always@* begin
case({cpol,cpha}) 

2'b00			:		miso = slave_reg_1[7];
2'b01			:		miso = slave_reg_2[7];
2'b10			:		miso = slave_reg_2[7];
2'b11			:		miso = slave_reg_1[7];
endcase
end

endmodule