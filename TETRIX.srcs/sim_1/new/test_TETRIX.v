`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2022 06:13:16 PM
// Design Name: 
// Module Name: test_TETRIX
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


module test_TETRIX(

    );
    reg clock,
     reset;
    wire uart_tx;
    wire [3:0] out_of_bounds;
    wire fall_fail;
    TETRIX  #(.fallcycles(10))TX(clock,reset,uart_tx,out_of_bounds,fall_fail);
    initial {clock,reset}=0;
    initial #10 reset=1;
    initial #20 reset=0;
    always #1 clock=~clock;
endmodule
