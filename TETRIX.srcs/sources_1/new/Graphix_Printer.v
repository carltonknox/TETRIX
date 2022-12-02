`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2022 01:58:51 PM
// Design Name: 
// Module Name: Graphix_Printer
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


module Graphix_Printer(
    input clock,
    input ready,
    output reg [7:0] data,
    output reg send,
    input reset,
    input [199:0] G0,
    input [199:0] G1,
    input [199:0] G2,
    input [199:0] G3
    );
    wire [799:0] G;
    assign G = {G3,G2,G1,G0};
    reg [1:0] g;//game 0-3
    reg [3:0] j;//x 0-9
    reg [4:0] k;//y 0-19
    wire [7:0] g_out,j_out,k_out;
    assign g_out = {6'b0,g};
    assign j_out = {4'b0,j};
    assign k_out = {3'b0,k};
    reg [8:0] state;
    reg [8:0] nstate;
    always @(posedge clock) begin
        if(reset) begin
            {g,j,k}=0;
            send=0;
            state=0;
            nstate = 1;
        end
        else begin
            case(state)
                0: begin//print/wait state
                    if(ready) begin
                        send<=0;
                        state<=nstate;
                    end
                end
                1: begin//set g state
//                    data<=g_out;
                    data<=g_out+48;
                    nstate<=2;
                    send<=1;
                    state<=0;
                end
                2: begin//set j state
//                    data<=j_out;
                    data<=j_out+48;
                    nstate<=3;
                    state<=0;
                    send<=1;
                end
                3: begin //set k state
//                    data<=k_out;
                    data<=k_out+48;
                    nstate<=4;
                    state<=0;
                    send<=1;
                end
                4: begin//set color output state
                    nstate<=5;
                    state<=0;
                    send<=1;
                    data<=(G[g*200 + j+ k*10])?51:52;//3==white, 4==black
//                    data<=(G[g*200 + j+ k*10])?3:4;//3==white, 4==black
                end
                5: begin//newline
                    nstate<=1;
                    state<=0;
                    send<=1;
                    data<=10;//newline in ascii
                    
                    //assuming this is the last state, lets increment gjk
                    if(j==9) begin
                        j<=0;
                        if(k==19) begin
                            k<=0;
                            g<=g+1;
                        end
                        else k<=k+1;
                    end
                    else j<=j+1;
                    
                end
            endcase
        end
    end
endmodule
