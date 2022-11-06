`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2022 03:01:33 AM
// Design Name: 
// Module Name: FB_testbench
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


module FB_testbench(

    );
    reg [199:0] Game_Board;
    reg clock;
    reg [2:0] tetronimo_type;
    reg init;//set location to top of board
    reg fall;
    reg [3:0] direct;//0000 = no input, 0001 = right, 0010 = left, 0100 = up (insta fall), 1000 = down (slow fast fall), 0011 = rotate right 1100 = rotate left 
    wire fail_fall;//cannot fall
//    wire [8:0] block0;//Board location of tetronimo{[8:5] = X , [4:0] = Y}
    wire [8:5] X0,X1,X2,X3;
    wire [4:0] Y0,Y1,Y2,Y3;
//    wire [8:0] block1;
//    wire [8:0] block2;
//    wire [8:0] block3;
    wire [3:0] out_of_bounds;//out of bounds
    Falling_Block FB(Game_Board, clock,tetronimo_type, init,//set location to top of board
                    fall,direct, fail_fall,
                    {X0,Y0}, {X1,Y1}, {X2,Y2}, {X3,Y3},
                    out_of_bounds);
    initial begin
        init = 1;
        fall = 0;
        clock = 0;
        Game_Board=0;
        tetronimo_type=1;
        direct = 0;
        #10
        init = 0;
        #10
        fall = 1;
    end
    always begin
        #5 clock =~clock;
    end
endmodule
