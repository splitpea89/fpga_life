`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2026 09:54:11 PM
// Design Name: 
// Module Name: main
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


module main(
    input logic clk,
    input logic [11:0] sw,
    input logic R,
    output logic [11:0] rgb_out,
    output logic h_sync,
    output logic v_sync,
    output logic frame_led
    );
    
    logic [11:0] rgb_reg;
    logic [9:0] x, y;
    logic v_on;
    
    VGA_Controller controller(.clk(clk), .R(R), .vid_on(v_on), .pix_x(x), .pix_y(y), .h_sync(h_sync), .v_sync(v_sync), .p_tick());
    
    logic [11:0] sw1, sw2;
    
    always_ff @(posedge clk) begin
        sw1 <= sw;
        sw2 <= sw1;
    end
    
    logic [7:0] frame_cnt;
    
    always_ff @(posedge clk or posedge R) begin
        if(R) begin
            frame_cnt <= '0;
            frame_led <= '0;
        end else if(x == 0 && y == 0) begin
            frame_cnt <= frame_cnt + 1;
            if(frame_cnt >= 239) begin // since each x,y = (0,0) will get counted 4 times
                frame_cnt <= '0;
                frame_led <= ~frame_led;
            end
        end
    end
    
    always_ff @(posedge clk or posedge R) begin
        if(R) rgb_reg <= '0;
        else if(x == 0 && y == 480) begin
            rgb_reg <= sw2;
        end
    end
    
    assign rgb_out = (v_on) ? rgb_reg : '0;
    
    
endmodule
