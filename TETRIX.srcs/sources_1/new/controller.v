`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2022 04:17:03 PM
// Design Name: 
// Module Name: controller
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


module controller(
    input clock,
          reset,
          PS2_CLK,
          PS2_DATA,
    output reg [3:0] control0,
           reg [3:0] control1,
           reg [3:0] control2,
           reg [3:0] control3
    /*0000 = no input,
      0001 = right,
      1000 = left,
      0100 = up (insta fall),
      0010 = down (slow fast fall),
      0011 = rotate right,
      1100 = rotate left
    */
    );
    wire [31:0]keycode;
    /*
    P1:
    Q - Left Rotate
    W - Fast Fall
    E - Right Rotate
    A - Left
    S - Slow Fall
    D - Right
    */
    PS2Receiver keyboard (
        .clk(clock),
        .kclk(PS2_CLK),
        .kdata(PS2_DATA),
        .keycodeout(keycode[31:0]),
        .flag(flag)
        );
    reg send;
    always@(clock)begin
        send = flag && (keycode[15:8] != 8'hF0) && (keycode[7:0] != 8'hF0);
        if(send) begin 
        case(keycode[7:0])
            

            // P1
            8'h15: control0 <= 4'b1100; // rotate left
            8'h1D: control0 <= 4'b0100; // up
            8'h24: control0 <= 4'b0011; // rotate right
            8'h1C: control0 <= 4'b1000; // left
            8'h1B: control0 <= 4'b0010; // down
            8'h23: control0 <= 4'b0001; // right
            
            // P2
            8'h2D: control1 <= 4'b1100;
            8'h2C: control1 <= 4'b0100;
            8'h35: control1 <= 4'b0011;
            8'h2B: control1 <= 4'b1000;
            8'h34: control1 <= 4'b0010;
            8'h33: control1 <= 4'b0001;
            
            // P3
            8'h3C: control2 <= 4'b1100;
            8'h43: control2 <= 4'b0100;
            8'h44: control2 <= 4'b0011;
            8'h3B: control2 <= 4'b1000;
            8'h42: control2 <= 4'b0010;
            8'h4B: control2 <= 4'b0001;
            
            // P4
            8'h22: control3 <= 4'b1100;
            8'h21: control3 <= 4'b0100;
            8'h2A: control3 <= 4'b0011;
            8'h32: control3 <= 4'b1000;
            8'h31: control3 <= 4'b0010;
            8'h3A: control3 <= 4'b0001;
            
            default: begin 
                control0 <= 4'b0000;
                control1 <= 4'b0000;
                control2 <= 4'b0000;
                control3 <= 4'b0000;
            end
        endcase
        end
        else begin
            control0 <= 4'b0000;
            control1 <= 4'b0000;
            control2 <= 4'b0000;
            control3 <= 4'b0000;
        end
    end
endmodule
