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
    // player control inputs
    parameter NO_INPUT = 4'b0000, RIGHT = 4'b0001, LEFT = 4'b1000, INSTA_FALL = 4'b0100, FAST_FALL = 4'b0010, ROTATE_RIGHT = 4'b0011, ROTATE_LEFT = 4'b1100;
    
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
    always@(posedge clock)begin
        send = flag && (keycode[15:8] != 8'hF0) && (keycode[7:0] != 8'hF0);
        if(send) begin 
        case(keycode[7:0])
            

            // P1
            8'h15: control0 <= ROTATE_LEFT; // rotate left
            8'h1D: control0 <= INSTA_FALL; // up
            8'h24: control0 <= ROTATE_RIGHT; // rotate right
            8'h1C: control0 <= LEFT; // left
            8'h1B: control0 <= FAST_FALL; // down
            8'h23: control0 <= RIGHT; // right
            
            // P2
            8'h2D: control1 <= ROTATE_LEFT;
            8'h2C: control1 <= INSTA_FALL;
            8'h35: control1 <= ROTATE_RIGHT;
            8'h2B: control1 <= LEFT;
            8'h34: control1 <= FAST_FALL;
            8'h33: control1 <= RIGHT;
            
            // P3
            8'h3C: control2 <= ROTATE_LEFT;
            8'h43: control2 <= INSTA_FALL;
            8'h44: control2 <= ROTATE_RIGHT;
            8'h3B: control2 <= LEFT;
            8'h42: control2 <= FAST_FALL;
            8'h4B: control2 <= RIGHT;
            
            // P4
            8'h22: control3 <= ROTATE_LEFT;
            8'h21: control3 <= INSTA_FALL;
            8'h2A: control3 <= ROTATE_RIGHT;
            8'h32: control3 <= LEFT;
            8'h31: control3 <= FAST_FALL;
            8'h3A: control3 <= RIGHT;
            
            default: begin 
                control0 <= NO_INPUT;
                control1 <= NO_INPUT;
                control2 <= NO_INPUT;
                control3 <= NO_INPUT;
            end
        endcase
        end
        else begin
            control0 <= NO_INPUT;
            control1 <= NO_INPUT;
            control2 <= NO_INPUT;
            control3 <= NO_INPUT;
        end
    end
endmodule
