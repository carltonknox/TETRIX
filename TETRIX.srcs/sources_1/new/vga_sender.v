`timescale 1ns / 1ps
// Generate HS, VS signals from pixel clock.
// hcounter & vcounter are the index of the current pixel
// origin (0, 0) at top-left corner of the screen
// valid display range for hcounter: [0, 640)
// valid display range for vcounter: [0, 480)
module vga_controller_640_60 (pixel_clk,HS,VS,hcounter,vcounter,blank);
 input pixel_clk;
 output HS, VS, blank;
 output [10:0] hcounter, vcounter;
 parameter HMAX = 800; // maximum value for the horizontal pixel counter
 parameter VMAX = 525; // maximum value for the vertical pixel counter
 parameter HLINES = 640; // total number of visible columns
 parameter HFP = 648; // value for the horizontal counter where front porch ends
 parameter HSP = 744; // value for the horizontal counter where the synch pulse ends
 parameter VLINES = 480; // total number of visible lines
 parameter VFP = 482; // value for the vertical counter where the front porch ends
 parameter VSP = 484; // value for the vertical counter where the synch pulse ends
parameter SPP = 0;
 wire video_enable;
 reg HS,VS,blank;
 reg [10:0] hcounter,vcounter;
 always@(posedge pixel_clk)begin
 blank <= ~video_enable;
 end
 always@(posedge pixel_clk)begin
 if (hcounter == HMAX) hcounter <= 0;
 else hcounter <= hcounter + 1;
 end
 always@(posedge pixel_clk)begin
 if(hcounter == HMAX) begin
 if(vcounter == VMAX) vcounter <= 0;
 else vcounter <= vcounter + 1;
 end
 end
 always@(posedge pixel_clk)begin
 if(hcounter >= HFP && hcounter < HSP) HS <= SPP;
 else HS <= ~SPP;
 end
  always@(posedge pixel_clk)begin
 if(vcounter >= VFP && vcounter < VSP) VS <= SPP;
 else VS <= ~SPP;
 end
 assign video_enable = (hcounter < HLINES && vcounter < VLINES) ? 1'b1 : 1'b0;
endmodule
// top module that instantiates the VGA controller and generates images
module vga_sender(
 input wire CLK100MHZ,
 output reg [3:0] VGA_R,
 output reg [3:0] VGA_G,
 output reg [3:0] VGA_B,
 output wire VGA_HS,
 output wire VGA_VS,
    output reg [3:0] j,//x 0-9
    output reg [4:0] k,//y 0-19
    input [7:0]c0,
    input [7:0]c1,
    input [7:0]c2,
    input [7:0]c3
 );
    reg [1:0] g;//game 0-3
//    reg [3:0] j;//x 0-9
//    reg [4:0] k;//y 0-19
    reg [7:0] color;
reg pclk_div_cnt;
reg pixel_clk;
wire [10:0] vga_hcnt, vga_vcnt;
wire vga_blank;
// Clock divider. Generate 25MHz pixel_clk from 100MHz clock.
always @(posedge CLK100MHZ) begin
 pclk_div_cnt <= !pclk_div_cnt;
 if (pclk_div_cnt == 1'b1) pixel_clk <= !pixel_clk;
end
// Instantiate VGA controller
vga_controller_640_60 vga_controller(
 .pixel_clk(pixel_clk),
 .HS(VGA_HS),
 .VS(VGA_VS),
 .hcounter(vga_hcnt),
 .vcounter(vga_vcnt),
 .blank(vga_blank)
);
// Generate figure to be displayed
// Decide the color for the current pixel at index (hcnt, vcnt).
// This example displays an white square at the center of the screen with a colored checkerboard background.
always @(*) begin
 // Set pixels to black during Sync. Failure to do so will result in dimmed colors or black screens.
 if (vga_blank) begin
 VGA_R = 0;
 VGA_G = 0;
 VGA_B = 0;
 end
 // Image to be displayed
 else begin
 // Default values for the checkerboard background
 VGA_R = vga_vcnt[6:3];
 VGA_G = vga_hcnt[6:3];
 VGA_B = vga_vcnt[6:3] + vga_hcnt[6:3];

 // White square at the center
 if ((vga_hcnt%(64*10/4) >= 20 && (vga_hcnt%(64*10/4)) <140 ) &&
 (vga_vcnt >= 130 && vga_vcnt < 350)) begin
    if(vga_hcnt%(64*10/4)<30 || vga_hcnt%(64*10/4) >=130 || vga_vcnt < 140 || vga_vcnt >= 340) begin
        VGA_R = 4'hf;
        VGA_G = 4'hf;
        VGA_B = 4'hf;
    end
    else begin
        g=vga_hcnt/(64*10/4);
        j=(vga_hcnt%(64*10/4)-30)/10;
        k=19-((vga_vcnt-140)/10);  
        
        case(g)
            0: color = c0;
            1: color = c1;
            2: color = c2;
            3: color = c3;
        endcase
        case(color)
            default: {VGA_R,VGA_G,VGA_B} = 0;
            7: {VGA_R,VGA_G,VGA_B} = 12'h0ff;
            2: {VGA_R,VGA_G,VGA_B} = 12'h00f;
            13: {VGA_R,VGA_G,VGA_B} = 12'hfa0;
            6: {VGA_R,VGA_G,VGA_B} = 12'hff0;
            1: {VGA_R,VGA_G,VGA_B} = 12'h0f0;
            5: {VGA_R,VGA_G,VGA_B} = 12'hdad;
            0: {VGA_R,VGA_G,VGA_B} = 12'hf00;
        endcase
//        if(color==4)
//            {VGA_R,VGA_G,VGA_B}=0;
//        else begin
        
//            VGA_R = 4'h0;
//            VGA_G = 4'h0;
//            VGA_B = 4'hf;
//        end
        
    end
 end
 end
end
endmodule