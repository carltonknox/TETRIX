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
    output uart_tx
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
    Tetris T(control0,resets[0],G0);
    wire ready;
    reg [7:0] data;
    reg send;
    UART_TX_CTRL UTC(.CLK(clock),.READY(ready),.UART_TX(uart_tx),.DATA(data),.SEND(send));
endmodule
