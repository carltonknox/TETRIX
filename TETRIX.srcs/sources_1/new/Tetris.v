`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2022 02:56:27 AM
// Design Name: 
// Module Name: Tetris
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


module Tetris#(
    parameter fallcycles = 25000000)(
    input clock,
    input [3:0] control, //0000 = no input, 0001 = right, 0010 = left, 0100 = up (insta fall), 1000 = down (slow fast fall), 0011 = rotate right 1100 = rotate left
    input reset,
    output reg [199:0] Tetris_Board, // Game Board | Falling Block location
    output [3:0] out_of_bounds,
    output fail_fall
    );
    reg [199:0] Game_Board; //10x20 game board index using X+Y*10
    reg [2:0] tetronimo_type; // type of tetronimo of falling block
    reg init;//set location to top of board
    reg fall;
//    wire fail_fall;//cannot fall. If the block cannot fall, then "round" over
    wire [8:5] X0,X1,X2,X3;
    wire [4:0] Y0,Y1,Y2,Y3;//X and Y coordinates for 4 block pixels
//    wire [3:0] out_of_bounds;//out of bounds values for current falling block. If the block can't fall, and is out of bounds, Game Over
    Falling_Block FB(Game_Board,clock,tetronimo_type,init,fall,control,
                     fail_fall,
                     {X0,Y0},
                     {X1,Y1},
                     {X2,Y2},
                     {X3,Y3},
                     out_of_bounds);
                     
    always@(*) begin
        Tetris_Board = Game_Board;
        if(~out_of_bounds[0])
            Tetris_Board[X0+Y0*10]=1;
        if(~out_of_bounds[1])
            Tetris_Board[X1+Y1*10]=1;
        if(~out_of_bounds[2])
            Tetris_Board[X2+Y2*10]=1;
        if(~out_of_bounds[3])
            Tetris_Board[X3+Y3*10]=1;
    end           
    reg [24:0] counter;
    always@(posedge clock) begin
        if(reset) begin
            counter<=0;
            Game_Board<=0;
            tetronimo_type<=counter[2:0];
            init<=1;
            fall<=0;
        end
        else begin
            init<=0;
            counter<=counter+1;
            if(counter==fallcycles) begin
                counter<=0;
                fall<=1;
            end
            else
                fall<=0;
        end
    end
endmodule
