`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2022 02:37:17 AM
// Design Name: 
// Module Name: Tetris_TB
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


module Tetris_TB(

    );
    reg clock;
    reg [3:0] control; //0000 = no input, 0001 = right, 0010 = left, 0100 = up (insta fall), 1000 = down (slow fast fall), 0011 = rotate right 1100 = rotate left
    reg reset;
    wire [199:0] Tetris_Board; // Game Board
    Tetris T0(clock,control,reset,Tetris_Board);
    always begin
        #1 clock=~clock;
    end
    initial begin
        reset=1;
        control=0;
        clock=0;
        #10
        reset=0;
        #100 $finish;
    end 
endmodule
