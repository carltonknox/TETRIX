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


module TETRIX(
    input clock,
    input reset,
    output uart_tx,
    output [3:0] out_of_bounds,
    output fall_fail
    );
    wire [199:0] G0;
    wire [199:0] G1;
    wire [199:0] G2;
    wire [199:0] G3;
    wire [3:0] control0;
    wire [3:0] control1;
    wire [3:0] control2;
    wire [3:0] control3;
    wire [3:0] resets;
    
    assign resets[0]=reset;
    Tetris T(clock,control0,resets[0],G0,out_of_bounds,fall_fail);
    wire ready;
    wire [7:0] data;
    wire send;
    UART_TX_CTRL UTC(.CLK(clock),.READY(ready),.UART_TX(uart_tx),.DATA(data),.SEND(send));
    Graphix_Printer printer(clock,ready,data,send,reset,G0,G1,G2,G3);
endmodule
