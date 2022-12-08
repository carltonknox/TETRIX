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
    
    // game states 
    parameter S_INIT = 2'h0, S_FALL = 2'h1, S_SET = 2'h2, S_BREAK = 2'h3;
    
    // player control inputs
    parameter NO_INPUT = 4'b0000, RIGHT = 4'b0001, LEFT = 4'b1000, INSTA_FALL = 4'b0100, FAST_FALL = 4'b0010, ROTATE_RIGHT = 4'b0011, ROTATE_LEFT = 4'b1100;
    
    reg [199:0] Game_Board; //10x20 game board index using X+Y*10
    reg [1599:0] Game_Board_Color;
    reg [2:0] tetronimo_type; // type of tetronimo of falling block
    reg init;//set location to top of board
    reg fall;
    wire [8:5] X0,X1,X2,X3;
    wire [4:0] Y0,Y1,Y2,Y3;//X and Y coordinates for 4 block pixels
    
    Falling_Block FB(Game_Board,clock,tetronimo_type,init,fall,control,
                     fail_fall,
                     {X0,Y0},
                     {X1,Y1},
                     {X2,Y2},
                     {X3,Y3},
                     out_of_bounds);
                     
    wire [7:0] fb_color;
    Tetronimo_Color TC(tetronimo_type,fb_color);  
        
    always@(posedge clock) begin
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
    assign counterlimit = (control==4'b0100) ? 0 : ((control==4'b0010) ? (fallcycles>>2) : fallcycles);
    
    reg [1:0] state;
    reg done_breaking;
    initial counter<=0;
    
    // line break
    
    reg [5:0] line_number;
    reg [5:0] line_replace;
    
    always@(posedge clock or posedge reset) begin
        counter<=counter+1;
        if(reset) begin
            Game_Board<=0;
            state <= S_INIT;
            tetronimo_type <= counter[2:0];
            init <= 1;
            fall <= 0;
            Game_Board_Color <= {200{8'h04}};
        end
        else begin
            case(state)
                S_INIT: begin // inital state
                    init <= 1;
                    fall <= 0;
                    tetronimo_type<=counter%7;
                    state <= S_FALL;//begin "freefall"
                    
                end
                S_FALL: begin // freefall state
                    init <= 0;
                    if(counter >= counterlimit) begin
                        counter <= {21'b0,counter[2:0]};
                        fall <= 1;
                    end
                    else begin
                        fall <= 0;
                    end 
                    if(fail_fall) begin
                        state <= S_SET;//begin "set in stone" stage
                    end
                end
                S_SET: begin// set in stone stage
                    Game_Board[X3+Y3*10] <= 1;
                    Game_Board_Color[(X3+Y3*10)*8 +:8] <= fb_color;
                    Game_Board[X2+Y2*10] <= 1;
                    Game_Board_Color[(X2+Y2*10)*8 +:8] <= fb_color;
                    Game_Board[X1+Y1*10] <= 1;
                    Game_Board_Color[(X1+Y1*10)*8 +:8] <= fb_color;
                    Game_Board[X0+Y0*10] <= 1;
                    Game_Board_Color[(X0+Y0*10)*8 +:8] <= fb_color;
                    init  <= 1;
                    state <= S_BREAK;
                    line_number <= 0;
                    line_replace <= 0;
                end
                S_BREAK: begin// line break state
                
                    // check if target replace line to shift into broken line in range
                    if (line_replace <= 20) begin
                        // if in range, check if line is to be broken
                        if (Game_Board[line_replace * 10 +: 10] == 10'b11111_11111) begin
                            // if to be broken, check next target line
                            line_replace <= line_replace + 1;
                        end
                        else begin
                            // if not to be broken, shift line into line_number
                            Game_Board[line_number * 10 +: 10] <= Game_Board[line_replace * 10 +: 10];
                            Game_Board_Color[line_number * 80 +: 80] <= Game_Board_Color[line_replace * 80 +: 80];
                            line_number <= line_number + 1; // next line
                            line_replace <= line_replace + 1;
                        end
                    end 
                    // if not in range, put in zeros for line
                    else begin
                        Game_Board[line_number * 10 +: 10] <= 10'b00000_00000;
                        Game_Board_Color[line_number * 80 +: 80] <= {10{8'h4}} ;
                        line_number <= line_number + 1; // next line
                    end
                        
                    // check if we are done
                    if(line_number >= 20) begin
                        state <= S_INIT;                // new tetronimo time
                    end
                end
            endcase
        end
    end
endmodule
