module led_matrix_data_path(
	input CLK, 
	input RESET, 
	input CE, 
	input WE, 
	input [4:0] row0, 
	input [3:0] col0, 
	input [2:0] color0,
	input [4:0] row1,
	input [3:0] col1,
	input [2:0] color1,
	output [2:0] RGB0,
	output [2:0] RGB1
	);
	
	reg [7:0] addr;
	always @(posedge CLK, posedge RESET) begin
		if(RESET) begin
			addr <= 0;
		end
		else if(CE) begin
			addr <= addr + 8'b1;
		end
		else begin
			addr <= addr;
		end
	end
	
	two_port_ram color_matrix(
		.reset(RESET),
		.address_a((WE) ? {row0,col0} : {1'b0, addr}),
		.address_b((WE) ? {row1,col1} : {1'b1, addr}),
		.clock(CLK),
		.data_a(color0),
		.data_b(color1),
		.wren_a(WE),
		.wren_b(WE),
		.q_a(RGB0),
		.q_b(RGB1)
	);
endmodule
module two_port_ram(
	input reset,
	input [8:0] address_a,
	input [8:0] address_b,
	input clock,
	input [2:0] data_a,
	input [2:0] data_b,
	input wren_a,
	input wren_b,
	output [2:0] q_a,
	output [2:0] q_b
	);
	
	reg [8:0] address_a_pipe;
	reg [8:0] address_b_pipe;
	reg [2:0] data_a_pipe;
	reg [2:0] data_b_pipe;
	reg wren_a_pipe;
	reg wren_b_pipe;
	
	reg [2:0] mem [511:0];
	
	reg [2:0] q_a_pipe;
	reg [2:0] q_b_pipe;
	integer i;
	
	always @(negedge clock) begin
		if(reset) begin
			address_a_pipe <= 0;
			address_b_pipe <= 0;
			data_a_pipe <= 0;
			data_b_pipe <= 0;
			wren_a_pipe <= 0;
			wren_b_pipe <= 0;
			q_a_pipe <= 0;
			q_b_pipe <= 0;
			for(i = 0; i < 512; i = i + 1) begin
//				mem[i] <= 3'b111;
				mem[i] <= i;
			end
			mem[0] <= 3'b000;
			mem[1] <= 3'b001;
			mem[2] <= 3'b010;
			mem[3] <= 3'b011;
			mem[4] <= 3'b100;
			mem[5] <= 3'b101;
			mem[6] <= 3'b110;
			mem[7] <= 3'b111;
		end
		else begin
			address_a_pipe <= address_a;
			address_b_pipe <= address_b;
			data_a_pipe <= data_a;
			data_b_pipe <= data_b;
			wren_a_pipe <= wren_a;
			wren_b_pipe <= wren_b;
			q_a_pipe <= mem[address_a_pipe];
			q_b_pipe <= mem[address_b_pipe];
		end
	end
	
	assign q_a = q_a_pipe;
	assign q_b = q_b_pipe;
	
endmodule 
module led_matrix_ctrl_path(
input CLK,
input RESET,
output reg CE,
output reg CLK_EN,
output reg LAT,
output reg OE,
output reg busy,
output reg [3:0] row_addr
);
	
parameter INIT = 4'd0, PRE = 4'd1, DATA = 4'd2, POST = 4'd3, 
LATCH = 4'd4, OUTPUT = 4'd5, DEAD = 4'd6, INC = 4'd7, DEADinc = 4'd8;
	
reg [31:0] cycle_count;
reg [3:0] state;
reg [3:0] next_state;
//Next State Logic
always @ (*) begin
case(state)
	INIT:   next_state = PRE;
	PRE:    next_state = (cycle_count == 1) ? DATA : PRE;
	DATA:   next_state = (cycle_count == 29) ? POST : DATA;
	POST:   next_state = (cycle_count == 1) ? LATCH : POST;
	LATCH:  next_state = OUTPUT;
	OUTPUT: next_state = (cycle_count == 15000) ? DEAD : OUTPUT;
	DEAD:   next_state = (cycle_count == 250) ? INC : DEAD;
	INC:    next_state = DEADinc;
	DEADinc:next_state = (cycle_count == 250) ? PRE : DEADinc;
	default: next_state = INIT;
endcase
end
	
//Output Logic
always @ (state) begin
	case(state)
	INIT:   begin CE = 1'b0; CLK_EN = 1'b0; LAT = 1'b0; OE = 1'b1; busy = 0; end
	PRE:    begin CE = 1'b1; CLK_EN = 1'b0; LAT = 1'b0; OE = 1'b1; busy = 1; end
	DATA:   begin CE = 1'b1; CLK_EN = 1'b1; LAT = 1'b0; OE = 1'b1; busy = 1; end
	POST:   begin CE = 1'b0; CLK_EN = 1'b1; LAT = 1'b0; OE = 1'b1; busy = 1; end
	LATCH:  begin CE = 1'b0; CLK_EN = 1'b0; LAT = 1'b1; OE = 1'b1; busy = 0; end
	OUTPUT: begin CE = 1'b0; CLK_EN = 1'b0; LAT = 1'b0; OE = 1'b0; busy = 0; end
	DEAD:   begin CE = 1'b0; CLK_EN = 1'b0; LAT = 1'b0; OE = 1'b1; busy = 0; end
	INC:    begin CE = 1'b0; CLK_EN = 1'b0; LAT = 1'b0; OE = 1'b1; busy = 0; end
	DEADinc:begin CE = 1'b0; CLK_EN = 1'b0; LAT = 1'b0; OE = 1'b1; busy = 0; end
	default:begin CE = 1'b0; CLK_EN = 1'b0; LAT = 1'b0; OE = 1'b1; busy = 0; end
endcase	
end
	
//State Transition Logic
always @ (posedge CLK, posedge RESET) begin
	if(RESET) begin
		state <= INIT;
		cycle_count <= 0;
	end
	else if(next_state != state) begin
		state <= next_state;
		cycle_count <= 0;
	end
	else begin 
		state <= next_state;
		cycle_count <= cycle_count + 1; 
	end
end
	
//Row Address Logic
always @ (posedge CLK, posedge RESET) begin
	if(RESET) begin
		row_addr <= 0;
	end
	else if(state == INC) begin
		row_addr <= row_addr + 1;
	end
	else begin 
		row_addr <= row_addr;
	end
end
endmodule
module top_level(
	input CLK, 
	input reset, 
	output clk_out, 
	output [2:0] RGB0,
	output [2:0] RGB1,
	output LAT, 
	output OE, 
	output [3:0] led_addr,
	output [3:0] gnd
);
wire CLK_DIV;
clock_div_22#(20) cd(CLK,reset,CLK_DIV);
//clock_div_22#(2) cd(CLK,reset,CLK_DIV);
	
wire CE;
wire CLK_EN;
wire WE;

//reg CLK_SLO;

assign clk_out = CLK_EN & CLK_DIV;
assign gnd = 4'b0000;

//Clock Divider (50 MHz -> 25Mhz)
//always @(posedge CLK, posedge RESET) begin
//	if(RESET) begin 
//		CLK_DIV <= 0;
//	end
//	else begin
//		CLK_DIV <= ~CLK_DIV;
//	end
//end

led_matrix_data_path data_path(
		.CLK(CLK_DIV), 
		.RESET(reset), 
		.CE(CE), 
		.WE(1'b0), 
		.row0(5'b00000), 
		.col0(4'b0000), 
		.color0(3'b000),
		.row1(5'b00000),
		.col1(4'b0000),
		.color1(3'b000),
		.RGB0(RGB0),
		.RGB1(RGB1)
);
	
led_matrix_ctrl_path ctrl_path(
	.CLK(CLK_DIV),
	.RESET(reset),
	.CE(CE),
	.CLK_EN(CLK_EN),
	.LAT(LAT),
	.OE(OE),
	.busy(busy),
	.row_addr(led_addr)
);
endmodule