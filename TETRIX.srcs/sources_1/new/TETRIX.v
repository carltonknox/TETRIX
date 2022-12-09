`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2022 02:53:18 PM
// Design Name: 
// Module Name: TETRIX
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


module TETRIX#(parameter fallcycles = 25000000)(
    input clock,
    input reset,
    output uart_tx,
    output [3:0] out_of_bounds,
    output fall_fail,
    input PS2_CLK,
    input PS2_DATA,
    output [3:0] player_0,
    output  [3:0] VGA_R,
     output  [3:0] VGA_G,
     output  [3:0] VGA_B,
     output wire VGA_HS,
     output wire VGA_VS
    );
    reg clock_2;
    reg clock_4;
    initial begin
        clock_2=0;
        clock_4=0;end
    always@(posedge clock)
        clock_2<=~clock_2;
    always@(posedge clock_2)
        clock_4<=~clock_4;
    wire [199:0] G0;
    wire [1599:0] CG0,CG1,CG2,CG3;
    wire [199:0] G1;
    wire [199:0] G2;
    wire [199:0] G3;
    wire [3:0] control0;
    wire [3:0] control1;
    wire [3:0] control2;
    wire [3:0] control3;
    wire [3:0] resets;
    
    assign resets[0]=reset;
    wire [3:0] j;
    wire [4:0] k;
    wire [7:0] c0,c1,c2,c3;
    Tetris #(.fallcycles(fallcycles)) T0(clock_2,control0,resets[0],G0,out_of_bounds,fall_fail,j,k,c0);
    Tetris #(.fallcycles(fallcycles)) T1(clock_2,control1,resets[0],G1,,,j,k,c1);
    Tetris #(.fallcycles(fallcycles)) T2(clock_2,control2,resets[0],G2,,,j,k,c2);
    Tetris #(.fallcycles(fallcycles)) T3(clock_2,control3,resets[0],G3,,,j,k,c3);
    controller players(clock_2,reset,PS2_CLK,PS2_DATA,control0, control1, control2, control3);
    assign player_0=control0;
    wire ready;
    wire [7:0] data;
    wire send;
//    UART_TX_CTRL UTC(.CLK(clock_2),.READY(ready),.UART_TX(uart_tx),.DATA(data),.SEND(send));
//    Graphix_Printer printer(clock_4,ready,data,send,reset,G0,G1,G2,G3,CG0,CG1,CG2,CG3);
    vga_sender VGA(clock,VGA_R,VGA_G,VGA_B,VGA_HS,VGA_VS,j,k,c0,c1,c2,c3);
endmodule
