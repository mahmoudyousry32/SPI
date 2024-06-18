module spi_ctrlr(clk,
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
				 
parameter DVSR = 65536;
parameter dvsr_w = $clog2(DVSR);
parameter D_BITS = 8;
localparam bit_counter_w = $clog2(D_BITS);
localparam IDLE	= 2'b00;
localparam WAIT_1 = 2'b01;
localparam WAIT_2 = 2'b10;
localparam MODE_0 = 2'b00;
localparam MODE_1 = 2'b01;
localparam MODE_2 = 2'b10;
localparam MODE_3 = 2'b11;

input clk;
input rst;
input start;
input [dvsr_w - 1 :0] dvsr;
input miso;
input [D_BITS - 1 :0] din;
input cpha;
input cpol;


output mosi;
output sclk;
output done;
output ready;
output [D_BITS - 1:0] dout;
output sclk_reg;

reg [dvsr_w :0] dvsr_reg;
reg [D_BITS - 1 :0] TX_reg;
reg [D_BITS - 1 :0] RX_reg;
reg [bit_counter_w - 1:0] bit_counter;
reg [1:0] state_reg;
reg [3:0] mode ;
reg sclk;
reg sclk_reg;
reg [3:0] next_state;
wire p_clk;
wire sclk_next;

always@(posedge clk ,negedge rst) 
if(!rst) sclk_reg <= 0;
else sclk_reg <= sclk_next;

always@(posedge clk ,negedge rst)
if(!rst)begin
state_reg <= IDLE;
bit_counter <= 0;
dvsr_reg <= 0;
RX_reg <=0;
TX_reg <= 0 ;
sclk <= 0;
end


else 
case(state_reg)

IDLE		:		begin
					if(start) begin 
					TX_reg <= din;
					bit_counter <= 0 ;
					dvsr_reg <= 0;
					state_reg <= WAIT_1;
					if(mode[0] || mode[3] ) sclk <= 0;
					else if( mode[1] || mode[2]) sclk <= 1;
					end
					else begin
					if(mode[0] || mode[1] ) sclk <= 0;
					else if( mode[2] || mode[3]) sclk <= 1;
					end
					end

WAIT_1		:		begin
					if(dvsr_reg == dvsr) begin
					state_reg <= WAIT_2;
					RX_reg <= {RX_reg[6:0],miso};
					dvsr_reg <= 0;
					if(mode[0] || mode[3] ) sclk <= 1;
					else if( mode[1] || mode[2]) sclk <= 0;
					end
					else 
					dvsr_reg <= dvsr_reg + 1;
					
					end

WAIT_2		:		begin
					if(dvsr_reg == dvsr) begin
					dvsr_reg <= 0;
					TX_reg <= {TX_reg[6:0],1'b0};
					if(bit_counter == D_BITS-1)begin					
					state_reg <= IDLE;
					if(mode[0] || mode[1] ) sclk <= 0;
					else if( mode[2] || mode[3]) sclk <= 1;
					end
					else begin
					bit_counter <= bit_counter + 1;
					state_reg <= WAIT_1;
					if(mode[0] || mode[3] ) sclk <= 0;
					else if( mode[1] || mode[2]) sclk <= 1;
					end
					end
					else dvsr_reg <= dvsr_reg + 1;
					end
endcase


always@* begin
mode = 0;
case({cpol,cpha})

MODE_0			:		mode = 4'b0001;

MODE_1			:		mode = 4'b0010;

MODE_2			:		mode = 4'b0100;

MODE_3			:		mode = 4'b1000;
endcase
end

always@* begin
next_state = state_reg ;
case(state_reg)
IDLE		:			 begin
						 if(start)begin
						 next_state = WAIT_1;
						 end
						 end


WAIT_1		:			 begin						 
						 if(dvsr_reg == dvsr) next_state = WAIT_2;
						 end
						 
WAIT_2		:			 begin
						 if(dvsr_reg == dvsr )
						 if(bit_counter == dvsr)
						 next_state = IDLE;
						 else next_state = WAIT_1; 
						 end
						 
endcase
end


assign p_clk = (next_state == WAIT_1 && mode[1] ) || (next_state == WAIT_2 && mode[0]);
assign sclk_next = cpol ? ~p_clk : p_clk;
assign mosi = TX_reg[D_BITS-1];
assign ready = state_reg == IDLE;
assign done = state_reg == WAIT_2 && (dvsr_reg == dvsr) && (bit_counter == D_BITS-1);
assign dout = RX_reg;



endmodule



						 