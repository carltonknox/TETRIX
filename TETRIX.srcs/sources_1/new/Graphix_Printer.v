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
    input [199:0] G3,
    input [1599:0] CG0,
    input [1599:0] CG1,
    input [1599:0] CG2,
    input [1599:0] CG3
    );
    wire [799:0] G;
    reg [799:0] old_G;
    wire [6399:0] CG;
    reg [6399:0] CGp;
    reg [7:0] color;
    assign G = {G3,G2,G1,G0};
    assign CG = {CG3,CG2,CG1,CG0};
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
            CGp<={200*4{8'h04}};
            old_G<=0;
        end
        else begin
            case(state)
                0: begin//print/wait state
                    if(ready & send) begin
                        send<=0;
                        state<=nstate;
                    end
                    else send<=1;
                end
                1: begin//set g state

                    data<=g_out+48;
                    nstate<=2;
//                    CGp[g*1600 + (j+k*10)*8 +:8]<=CG[g*1600 + (j+k*10)*8 +:8];
//                    if(G[g*200 + j+ k*10]==old_G[g*200 + j+ k*10]) begin
                    if(CG[g*1600 + (j+k*10)*8 +:8]==CGp[g*1600 + (j+k*10)*8 +:8]) begin
                         if(j==9) begin
                            j<=0;
                            if(k==19) begin
                                k<=0;
                                g<=g+1;
                            end
                            else k<=k+1;
                        end
                        else j<=j+1;
                        state<=1;
                    end
                    else begin
                        color<=CG[g*1600 + (j+k*10)*8 +:8];
                        nstate<=2;
                        state<=0;
                    end
                end
                2: begin//set j state
                    data<=j_out+48;
                    nstate<=3;
                    state<=0;

                end
                3: begin //set k state
                    data<=k_out+48;
                    nstate<=4;
                    state<=0;

                end
                4: begin//set color output state
                    nstate<=5;
                    state<=0;

//                    data<=(G[g*200 + j+ k*10])?51:52;//3==white, 4==black
                    data<=color+48;
                    CGp[g*1600 + (j+k*10)*8 +:8]<=color;
                end
                5: begin//newline
                    nstate<=1;
                    state<=0;
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
