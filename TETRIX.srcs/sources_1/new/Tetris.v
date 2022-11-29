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


module Tetris(input clock,
    input [3:0] control, //0000 = no input, 0001 = right, 0010 = left, 0100 = up (insta fall), 1000 = down (slow fast fall), 0011 = rotate right 1100 = rotate left
    input reset,
    output reg [199:0] Tetris_Board // Game Board | Falling Block location
    );
//    module Falling_Block(
//    input [199:0] Game_Board,
//    input clock,
//    input [2:0] tetronimo_type,
//    input init,//set location to top of board
//    input fall,
//    input [3:0] direct,//0000 = no input, 0001 = right, 0010 = left, 0100 = up (insta fall), 1000 = down (slow fast fall), 0011 = rotate right 1100 = rotate left 
//    output reg fail_fall,//cannot fall
//    output  [8:0] block0,//Board location of tetronimo{[8:5] = X , [4:0] = Y}
//    output  [8:0] block1,
//    output  [8:0] block2,
//    output  [8:0] block3,
//    output [3:0] out_of_bounds//out of bounds
//    );
    reg [199:0] Game_Board; //10x20 game board index using X+Y*10
    reg [2:0] tetronimo_type; // type of tetronimo of falling block
    reg init;//set location to top of board
    reg fall;
    wire fail_fall;//cannot fall. If the block cannot fall, then "round" over
    wire [8:5] X0,X1,X2,X3;
    wire [4:0] Y0,Y1,Y2,Y3;//X and Y coordinates for 4 block pixels
    wire [3:0] out_of_bounds;//out of bounds values for current falling block. If the block can't fall, and is out of bounds, Game Over
    Falling_Block FB(Game_Board,clock,tetronimo_type,init,fall,control,
                     fail_fall,
                     {X0,Y0},
                     {X1,Y1},
                     {X2,Y2},
                     {X3,Y3},
                     out_of_bounds);
                     
    always@(*) begin
        Tetris_Board = Game_Board;
        if(!out_of_bounds) begin
            Tetris_Board[X0+Y0*10]=1;
            Tetris_Board[X1+Y1*10]=1;
            Tetris_Board[X2+Y2*10]=1;
            Tetris_Board[X3+Y3*10]=1;
        end
    end           
    reg [2:0] counter;
    always@(posedge clock) begin
        if(reset) begin
            counter<=0;
            Game_Board<=0;
            tetronimo_type<=counter;
            init<=1;
            fall<=0;
        end
        else begin
            init<=0;
            fall<=1;
            counter<=counter+1;
        end
    end
endmodule
