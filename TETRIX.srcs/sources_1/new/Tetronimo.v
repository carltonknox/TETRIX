`timescale 1ns / 1ps
/***
    Falling block is a "object" representing the currently falling
    Tetronimo. Tetronimo is a module which calculates the coordinates
    of the four block locations of each tetronimo in each orientation. 
    It is very long, but basically follows the picture here:
    https://tetris.fandom.com/wiki/SRS?file=SRS-pieces.png
    Where tetronimo_type is 0-6 along the vertical from top to bottom,
    and "rot" is the rotation, 0-3 from left to right
    You can take the output "block0, block 1, etc" as the x and y coordinates of the 10 by 20 grid
    defined by this image : https://i0.wp.com/colinfahey.com/tetris/tetris_diagram_board_10x20_empty_new.jpg?zoom=2
    The first 4 bits are X and the next 5 bits are Y. 
    Falling_Block uses two Tetronimo module, one to calculate the current block position, and one to calculate the next block position, according to user input. 
    If the next block position results in out of bounds, or collision, the block will remain in the current position. If the fall input is 1,
    and Falling_Block cannot fall, fail_fall will be set to 1.
    init blocks will start out of bounds. If a block is out of bounds and fails to fall, the game should be over
***/


module Falling_Block(
    input [199:0] Game_Board,
    input clock,
    input [2:0] tetronimo_type,
    input init,//set location to top of board
    input fall,
    input [3:0] direct,//0000 = no input, 0001 = right, 0010 = left, 0100 = up (insta fall), 1000 = down (slow fast fall), 0011 = rotate right 1100 = rotate left 
    output reg fail_fall,//cannot fall
    output  [8:0] block0,//Board location of tetronimo{[8:5] = X , [4:0] = Y}
    output  [8:0] block1,
    output  [8:0] block2,
    output  [8:0] block3,
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
    //TODO implement collision detection
    reg [3:0] next_collision;
    reg [1:0] rot;//rotation orientation
    reg [1:0] next_rot;
    assign out_of_bounds[0] = block0[8:5] >9 || block0[4:0] > 19;
    assign out_of_bounds[1] = block1[8:5] >9 || block1[4:0] > 19;
    assign out_of_bounds[2] = block2[8:5] >9 || block2[4:0] > 19;
    assign out_of_bounds[3] = block3[8:5] >9 || block3[4:0] > 19;
    
    
    
    //next block locations and out of bounds
    wire [8:0] next_block0;
    wire [8:0] next_block1;
    wire [8:0] next_block2;
    wire [8:0] next_block3;
    assign next_out_of_bounds[0] = next_block0[8:5] >9 || next_block0[4:0] > 21;
    assign next_out_of_bounds[1] = next_block1[8:5] >9 || next_block1[4:0] > 21;
    assign next_out_of_bounds[2] = next_block2[8:5] >9 || next_block2[4:0] > 21;
    assign next_out_of_bounds[3] = next_block3[8:5] >9 || next_block3[4:0] > 21;
    
    //next collision, check if next location is alerady occupied
    wire [8:5] nX0,nX1,nX2,nX3;
    wire [4:0] nY0,nY1,nY2,nY3;
    assign {nX0,nY0} = next_block0;
    assign {nX1,nY1} = next_block1;
    assign {nX2,nY2} = next_block2;
    assign {nX3,nY3} = next_block3;
    integer coord0,coord1,coord2,coord3;
    
    always@(*) begin
        coord0 = nX0 + nY0*10;
        coord1 = nX1 + nY1*10;
        coord2 = nX2 + nY2*10;
        coord3 = nX3 + nY3*10;
        if(coord0>199 || coord1 > 199 || coord2 > 199 || coord3 > 199)
            next_collision=0;
        else begin
            next_collision[0] = Game_Board[coord0];
            next_collision[1] = Game_Board[coord1];
            next_collision[2] = Game_Board[coord2];
            next_collision[3] = Game_Board[coord3];
        end
    end

    //Tetronimo types and rotations
    Tetronimo T_current(tetronimo_type,rot,{cornerX,cornerY},block0,block1,block2,block3);
    Tetronimo T_next(tetronimo_type,next_rot,{next_cornerX,next_cornerY},next_block0,next_block1,next_block2,next_block3);

    always@(posedge clock) begin
        if(~(next_out_of_bounds || next_collision || init)) begin
                    cornerX <= next_cornerX;
                    cornerY <= next_cornerY;
                    rot <= next_rot;
                    fail_fall <= 0;
                end
            else
                fail_fall <= fall;
        
    end
    
    always@(posedge clock) begin
        if(init) begin
            //set block to top
            cornerX=4;
            cornerY=21;
            next_cornerX=cornerX;
            next_cornerY=cornerY;
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
wire [8:5] X;
wire [4:0] Y;
assign X = corner[8:5];
assign Y = corner[4:0];
always@(*)
    case(tetronimo_type)
        0: begin//Cyan line
            case(rot)
                0: begin
                    block0[8:5] = X;    block0[4:0] = Y-1;
                    block1[8:5] = X+1;  block1[4:0] = Y-1;
                    block2[8:5] = X+2;  block2[4:0] = Y-1;
                    block3[8:5] = X+3;  block3[4:0] = Y-1;
                end
                1: begin
                    block0[8:5] = X+2;  block0[4:0] = Y;
                    block1[8:5] = X+2;  block1[4:0] = Y-1;
                    block2[8:5] = X+2;  block2[4:0] = Y-2;
                    block3[8:5] = X+2;  block3[4:0] = Y-3;
                end
                2: begin
                    block0[8:5] = X;    block0[4:0] = Y-2;
                    block1[8:5] = X+1;  block1[4:0] = Y-2;
                    block2[8:5] = X+2;  block2[4:0] = Y-2;
                    block3[8:5] = X+3;  block3[4:0] = Y-2;
                end
                3: begin
                    block0[8:5] = X+1;      block0[4:0] = Y;
                    block1[8:5] = X+1;      block1[4:0] = Y-1;
                    block2[8:5] = X+1;      block2[4:0] = Y-2;
                    block3[8:5] = X+1;      block3[4:0] = Y-3;
                end
            endcase
        end
        1: begin//blue reverse L
            case(rot)
                0: begin
                    block0[8:5] = X;        block0[4:0] = Y;
                    block1[8:5] = X;        block1[4:0] = Y-1;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X+2;      block3[4:0] = Y-1;
                end
                1: begin
                    block0[8:5] = X+1;      block0[4:0] = Y;
                    block1[8:5] = X+2;      block1[4:0] = Y;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X+1;      block3[4:0] = Y-2;
                end
                2: begin
                    block0[8:5] = X;        block0[4:0] = Y-1;
                    block1[8:5] = X+1;      block1[4:0] = Y-1;
                    block2[8:5] = X+2;      block2[4:0] = Y-1;
                    block3[8:5] = X+2;      block3[4:0] = Y-2;
                end
                3: begin
                    block0[8:5] = X;        block0[4:0] = Y-2;
                    block1[8:5] = X+1;      block1[4:0] = Y;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X+1;      block3[4:0] = Y-2;
                end
            endcase
        end
        2: begin//Orange L
            case(rot)
                0: begin
                    block0[8:5] = X+2;      block0[4:0] = Y;
                    block1[8:5] = X;        block1[4:0] = Y-1;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X+2;      block3[4:0] = Y-1;
                end
                1: begin
                    block0[8:5] = X+1;      block0[4:0] = Y;
                    block1[8:5] = X+2;      block1[4:0] = Y-2;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X+1;      block3[4:0] = Y-2;
                end
                2: begin
                    block0[8:5] = X;        block0[4:0] = Y-1;
                    block1[8:5] = X+1;      block1[4:0] = Y-1;
                    block2[8:5] = X+2;      block2[4:0] = Y-1;
                    block3[8:5] = X;        block3[4:0] = Y-2;
                end
                3: begin
                    block0[8:5] = X;        block0[4:0] = Y;
                    block1[8:5] = X+1;      block1[4:0] = Y;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X+1;      block3[4:0] = Y-2;
                end
            endcase
        end
        3: begin //Yellow square
            block0[8:5] = X+1;      block0[4:0] = Y;
            block1[8:5] = X+2;      block1[4:0] = Y;
            block2[8:5] = X+1;      block2[4:0] = Y-1;
            block3[8:5] = X+2;      block3[4:0] = Y-1;
        end
        4 : begin//green snake
            case(rot)
                0: begin
                    block0[8:5] = X;        block0[4:0] = Y-1;
                    block1[8:5] = X+1;      block1[4:0] = Y;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X+2;      block3[4:0] = Y;
                end
                1: begin
                    block0[8:5] = X+1;      block0[4:0] = Y;
                    block1[8:5] = X+1;      block1[4:0] = Y-1;
                    block2[8:5] = X+2;      block2[4:0] = Y-1;
                    block3[8:5] = X+2;      block3[4:0] = Y-2;
                end
                2: begin
                    block0[8:5] = X;        block0[4:0] = Y-2;
                    block1[8:5] = X+1;      block1[4:0] = Y-1;
                    block2[8:5] = X+1;      block2[4:0] = Y-2;
                    block3[8:5] = X+3;      block3[4:0] = Y-1;
                end
                3: begin
                    block0[8:5] = X;        block0[4:0] = Y;
                    block1[8:5] = X;        block1[4:0] = Y-1;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X+1;      block3[4:0] = Y-2;
                end
            endcase
        end
        5 : begin//purple T
            case(rot)
                0: begin
                    block0[8:5] = X+1;      block0[4:0] = Y;
                    block1[8:5] = X;        block1[4:0] = Y-1;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X+2;      block3[4:0] = Y-1;
                end
                1: begin
                    block0[8:5] = X+2;      block0[4:0] = Y-1;
                    block1[8:5] = X+1;      block1[4:0] = Y;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X+1;      block3[4:0] = Y-2;
                end
                2: begin
                    block0[8:5] = X+1;      block0[4:0] = Y-2;
                    block1[8:5] = X;        block1[4:0] = Y-1;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X+2;      block3[4:0] = Y-1;
                end
                3: begin
                    block0[8:5] = X;        block0[4:0] = Y-1;
                    block1[8:5] = X+1;      block1[4:0] = Y;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X+1;      block3[4:0] = Y-2;
                end
            endcase
        end
        6 : begin//red snake
            case(rot)
                0: begin
                    block0[8:5] = X+2;      block0[4:0] = Y-1;
                    block1[8:5] = X+1;      block1[4:0] = Y;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X;        block3[4:0] = Y;
                end
                1: begin
                    block0[8:5] = X+2;      block0[4:0] = Y;
                    block1[8:5] = X+1;      block1[4:0] = Y-1;
                    block2[8:5] = X+2;      block2[4:0] = Y-1;
                    block3[8:5] = X+1;      block3[4:0] = Y-2;
                end
                2: begin
                    block0[8:5] = X;        block0[4:0] = Y-1;
                    block1[8:5] = X+1;      block1[4:0] = Y-1;
                    block2[8:5] = X+1;      block2[4:0] = Y-2;
                    block3[8:5] = X+3;      block3[4:0] = Y-2;
                end
                3: begin
                    block0[8:5] = X+1;      block0[4:0] = Y;
                    block1[8:5] = X;        block1[4:0] = Y-1;
                    block2[8:5] = X+1;      block2[4:0] = Y-1;
                    block3[8:5] = X;        block3[4:0] = Y-2;
                end
            endcase
        end
        default : begin
            {block0,block1,block2,block3}=0;
        end
    endcase
endmodule

