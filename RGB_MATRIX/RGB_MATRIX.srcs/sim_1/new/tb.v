`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2022 09:39:36 AM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb(

    );
//    module top_level(
//	input CLK, 
//	input reset, 
//	output clk_out, 
//	output [2:0] RGB0,
//	output [2:0] RGB1,
//	output LAT, 
//	output OE, 
//	output [2:0] led_addr,
//	output [3:0] gnd
//);
    reg CLK,reset;
    wire clk_out,LAT,OE;
    wire[2:0] RGB0,RGB1,led_addr;
    
    top_level tl(CLK,reset,clk_out,RGB0,RGB1,LAT,OE,led_addr,);
    
    initial begin
    CLK = 0;
    #5 reset = 1;
    #5 reset = 0;
    end
    always #1 CLK = ~CLK;
endmodule
