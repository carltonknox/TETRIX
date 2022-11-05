`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2022 07:56:01 PM
// Design Name: 
// Module Name: Tetronimo
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


module Falling_Block(
    input [199:0] Game_Board,
    input clock,
    input [2:0] tetronimo_type,
    input init,//set location to top of board
    input fall,
    input [3:0] direct,//0000 = no input, 0001 = right, 0010 = left, 0100 = up (insta fall), 1000 = down (slow fast fall), 0011 = rotate right 1100 = rotate left 
    output reg fail_fall,//cannot fall
    output reg [8:0] block0,//Board location of tetronimo{[8:5] = X , [4:0] = Y}
    output reg [8:0] block1,
    output reg [8:0] block2,
    output reg [8:0] block3,
    output [3:0] out_of_bounds//out of bounds
    
    );
    /**
    A generic tetronimo is defined by a 4by4 space, and each tetronimos has 4 blocks in this space. cornerX and Y define the bottom left corner. 
    This is for ease of rotation. Each rotation will just be a redefinition of blocks 0-3 relative to the corner.
    **/
    reg [8:5] cornerX;
    reg [4:0] cornerY;
    reg [8:5] next_cornerX;
    reg [4:0] next_cornerY;
    wire [3:0] next_out_of_bounds;
    wire [3:0] next_collision;
    reg [1:0] rot;//rotation orientation
    reg [1:0] next_rot;
    assign out_of_bounds[0] = block0[8:5] >9 || block0[4:0] > 19;
    assign out_of_bounds[1] = block1[8:5] >9 || block1[4:0] > 19;
    assign out_of_bounds[2] = block2[8:5] >9 || block2[4:0] > 19;
    assign out_of_bounds[3] = block3[8:5] >9 || block3[4:0] > 19;
    
    
    //next block locations and out of bounds
    reg [8:0] next_block0;
    reg [8:0] next_block1;
    reg [8:0] next_block2;
    reg [8:0] next_block3;
    assign next_out_of_bounds[0] = next_block0[8:5] >9 || next_block0[4:0] > 19;
    assign next_out_of_bounds[1] = next_block1[8:5] >9 || next_block1[4:0] > 19;
    assign next_out_of_bounds[2] = next_block2[8:5] >9 || next_block2[4:0] > 19;
    assign next_out_of_bounds[3] = next_block3[8:5] >9 || next_block3[4:0] > 19;
    
    
    
    
    always@(posedge clock) begin
        if(init) begin
            //set block to top
            cornerX=4;
            cornerY=18;
            rot=0;
            fail_fall=fall;
        end
        else begin
            {next_cornerX,next_cornerY,next_rot}={cornerX,cornerY,rot};
            if(fall) begin
                next_cornerY = cornerY-1;
            end
            else begin
                case(direct)
                4'b0001 : begin//move right
                    next_cornerX = cornerX+1;
                end
                4'b0010 : begin //move left
                    next_cornerX = cornerX+1;
                end
                4'b0100 : begin//instant fall //probably not handled here
                
                end
                4'b1000 : begin//slow fast fall //probably not handled here
                
                end
                4'b0011 : begin//rotate right
                    next_rot = rot+1;
                end
                4'b1100 : begin//rotate left
                    next_rot = rot-1;
                end
                default : begin
                    
                end
                
                endcase
            end
            
            if(~(next_out_of_bounds || next_collision)) begin
                    cornerX = next_cornerX;
                    cornerY = next_cornerY;
                    rot = next_rot;
                    fail_fall = 0;
                end
            else 
                fail_fall = fall;
        end
    end
endmodule

module Tetronimo(
input [2:0] tetronimo_type,
input [1:0] rot,
input [8:0] corner,

output reg [8:0] block0,//Board location of tetronimo{[8:5] = X , [4:0] = Y}
output reg [8:0] block1,
output reg [8:0] block2,
output reg [8:0] block3);
wire X,Y;
assign X = corner[8:5];
assign Y = corner[4:0];
always@(*)
    case(tetronimo_type)
        0: begin//Cyan line
            case(rot)
                0: begin
                    block0 ={X,Y-1};
                    block1={X+1,Y-1};
                    block2={X+2,Y-1};
                    block3={X+3,Y-1};
                end
                1: begin
                    block0={X+2,Y};
                    block1={X+2,Y-1};
                    block2={X+2,Y-2};
                    block3={X+2,Y-3};
                end
                2: begin
                    block0 ={X,Y-2};
                    block1={X+1,Y-2};
                    block2={X+2,Y-2};
                    block3={X+3,Y-2};
                end
                3: begin
                    block0 ={X+1,Y};
                    block1={X+1,Y-1};
                    block2={X+1,Y-2};
                    block3={X+1,Y-3};
                end
            endcase
        end
        1: begin//blue reverse L
            case(rot)
                0: begin
                    block0 ={X,Y};
                    block1={X,Y-1};
                    block2={X+1,Y-1};
                    block3={X+2,Y-1};
                end
                1: begin
                    block0={X+1,Y};
                    block1={X+2,Y};
                    block2={X+1,Y-1};
                    block3={X+1,Y-2};
                end
                2: begin
                    block0 ={X,Y-1};
                    block1={X+1,Y-1};
                    block2={X+2,Y-1};
                    block3={X+2,Y-2};
                end
                3: begin
                    block0 ={X,Y-2};
                    block1={X+1,Y};
                    block2={X+1,Y-1};
                    block3={X+1,Y-2};
                end
            endcase
        end
        2: begin//Orange L
            case(rot)
                0: begin
                    block0 ={X+2,Y};
                    block1={X,Y-1};
                    block2={X+1,Y-1};
                    block3={X+2,Y-1};
                end
                1: begin
                    block0={X+1,Y};
                    block1={X+2,Y-2};
                    block2={X+1,Y-1};
                    block3={X+1,Y-2};
                end
                2: begin
                    block0 ={X,Y-1};
                    block1={X+1,Y-1};
                    block2={X+2,Y-1};
                    block3={X,Y-2};
                end
                3: begin
                    block0 ={X,Y};
                    block1={X+1,Y};
                    block2={X+1,Y-1};
                    block3={X+1,Y-2};
                end
            endcase
        end
        3: begin //Yellow square
            block0 ={X+1,Y};
            block1={X+2,Y};
            block2={X+1,Y-1};
            block3={X+2,Y-1}; 
        end
        4 : begin//green snake
            case(rot)
                0: begin
                    block0 ={X,Y-1};
                    block1={X+1,Y};
                    block2={X+1,Y-1};
                    block3={X+2,Y};
                end
                1: begin
                    block0={X+1,Y};
                    block1={X+1,Y-1};
                    block2={X+2,Y-1};
                    block3={X+2,Y-2};
                end
                2: begin
                    block0 ={X,Y-2};
                    block1={X+1,Y-1};
                    block2={X+1,Y-2};
                    block3={X+3,Y-1};
                end
                3: begin
                    block0 ={X,Y};
                    block1={X,Y-1};
                    block2={X+1,Y-1};
                    block3={X+1,Y-2};
                end
            endcase
        end
        5 : begin//purple T
            case(rot)
                0: begin
                    block0 ={X+1,Y};
                    block1={X,Y-1};
                    block2={X+1,Y-1};
                    block3={X+2,Y-1};
                end
                1: begin
                    block0={X+2,Y-1};
                    block1={X+1,Y};
                    block2={X+1,Y-1};
                    block3={X+1,Y-2};
                end
                2: begin
                    block0 ={X+1,Y-2};
                    block1={X,Y-1};
                    block2={X+1,Y-1};
                    block3={X+2,Y-1};
                end
                3: begin
                    block0 ={X,Y-1};
                    block1={X+1,Y};
                    block2={X+1,Y-1};
                    block3={X+1,Y-2};
                end
            endcase
        end
        5 : begin//red snake
            case(rot)
                0: begin
                    block0 ={X+2,Y-1};
                    block1={X+1,Y};
                    block2={X+1,Y-1};
                    block3={X,Y};
                end
                1: begin
                    block0={X+2,Y};
                    block1={X+1,Y-1};
                    block2={X+2,Y-1};
                    block3={X+1,Y-2};
                end
                2: begin
                    block0 ={X,Y-1};
                    block1={X+1,Y-1};
                    block2={X+1,Y-2};
                    block3={X+3,Y-2};
                end
                3: begin
                    block0 ={X+1,Y};
                    block1={X,Y-1};
                    block2={X+1,Y-1};
                    block3={X,Y-2};
                end
            endcase
        end
        default : begin
            {block0,block1,block2,block3}=0;
        end
    endcase
endmodule

