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
    parameter fallcycles = 16500000)(
    input clock,
    input [3:0] control, //0000 = no input, 0001 = right, 0010 = left, 0100 = up (insta fall), 1000 = down (slow fast fall), 0011 = rotate right 1100 = rotate left
    input reset,
    output reg [199:0] Tetris_Board, // Game Board | Falling Block location
    output [3:0] out_of_bounds,
    output fail_fall,
    output reg [1599:0] Color_Board//10x20 game board of 8 bit colors
    );
    reg [199:0] Game_Board; //10x20 game board index using X+Y*10
    reg [1599:0] Game_Board_Color;
//    reg [1599:0] Color_Board;//10x20 game board of 8 bit colors
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
    wire [7:0] fb_color;
    Tetronimo_Color TC(tetronimo_type,fb_color);      
    always@(*) begin
        Tetris_Board = Game_Board;
        Color_Board = Game_Board_Color;//TODO change to GAME_BOARD
        if(~out_of_bounds[0])
            Tetris_Board[X0+Y0*10]=1;
            Color_Board[(X0+Y0*10)*8 +:8]=fb_color;
        if(~out_of_bounds[1])
            Tetris_Board[X1+Y1*10]=1;
            Color_Board[(X1+Y1*10)*8 +:8]=fb_color;
        if(~out_of_bounds[2])
            Tetris_Board[X2+Y2*10]=1;
            Color_Board[(X2+Y2*10)*8 +:8]=fb_color;
        if(~out_of_bounds[3])
            Tetris_Board[X3+Y3*10]=1;
            Color_Board[(X3+Y3*10)*8 +:8]=fb_color;
    end           
    reg [24:0] counter;
    wire [24:0] counterlimit;
    assign counterlimit = (control==4'b0100)?0:((control==4'b0010)?fallcycles/:fallcycles);
    reg [3:0] state;
    reg done_breaking;
    initial counter<=0;
    always@(posedge clock) begin
        counter<=counter+1;
        if(reset) begin
            Game_Board<=0;
            state=0;
            tetronimo_type<=counter[2:0];
            init<=1;
            fall<=0;
            Game_Board_Color<={200{8'h04}};
        end
        else begin
            case(state)
                0: begin 
                    init<=1;
                    fall<=0;
                    tetronimo_type<=counter%7;
                    state<=1;//begin "freefall"
                    
                end
                1: begin //freefall
                    init<=0;
                    if(counter>=counterlimit) begin
                        counter<={21'b0,counter[2:0]};
                        fall<=1;
                        if(fail_fall) begin
                            state<=2;//begin "set in stone" stage
                        end
                    end
                    else
                        fall<=0;
                    if(fail_fall) begin
                        state<=2;//begin "set in stone" stage
                    end
                end
                2: begin//set in stone
                    Game_Board[X3+Y3*10]<=1;
                    Game_Board_Color[(X3+Y3*10)*8 +:8]<=fb_color;
                    Game_Board[X2+Y2*10]<=1;
                    Game_Board_Color[(X2+Y2*10)*8 +:8]<=fb_color;
                    Game_Board[X1+Y1*10]<=1;
                    Game_Board_Color[(X1+Y1*10)*8 +:8]<=fb_color;
                    Game_Board[X0+Y0*10]<=1;
                    Game_Board_Color[(X0+Y0*10)*8 +:8]<=fb_color;
                    init<=1;
                    state<=3;
                end
                3: begin//break lines
                    done_breaking<=1;
                    if(done_breaking)
                        state<=0;//new tetronimo time
                end
            endcase
        end
    end
endmodule
