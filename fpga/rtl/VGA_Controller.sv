`timescale 1ns / 1ps
// 640x480 @ 60 Hz VGA timing generator
// Runs entirely on the 100 MHz clock; p_tick is a 25 MHz clock ENABLE.

module VGA_Controller (
    input  logic       clk,     // 100 MHz
    input  logic       R,       // active-high reset
    output logic [9:0] pix_x,
    output logic [9:0] pix_y,
    output logic       vid_on,
    output logic       h_sync,  // active low
    output logic       v_sync,  // active low
    output logic       p_tick   // 1-in-4 enable pulse (25 MHz)
);

    // ---------------- Timing parameters ----------------
    localparam int H_DISP  = 640;
    localparam int H_FP    = 16;
    localparam int H_SYNC  = 96;
    localparam int H_BP    = 48;
    localparam int H_TOTAL = H_DISP + H_FP + H_SYNC + H_BP;   // 800

    localparam int V_DISP  = 480;
    localparam int V_FP    = 10;
    localparam int V_SYNC  = 2;
    localparam int V_BP    = 33;
    localparam int V_TOTAL = V_DISP + V_FP + V_SYNC + V_BP;   // 525

    // ---------------- 25 MHz enable ----------------
    logic [1:0] clk_cntr;

    always_ff @(posedge clk or posedge R) begin
        if (R) clk_cntr <= '0;
        else   clk_cntr <= clk_cntr + 1;
    end

    assign p_tick = (clk_cntr == 2'd0);

    // ---------------- State registers ----------------
    logic [9:0] h_count, h_count_next;
    logic [9:0] v_count, v_count_next;
    logic       h_sync_reg, h_sync_next;
    logic       v_sync_reg, v_sync_next;

    always_ff @(posedge clk or posedge R) begin
        if (R) begin
            h_count    <= '0;
            v_count    <= '0;
            h_sync_reg <= 1'b1;   // idle high (active-low sync)
            v_sync_reg <= 1'b1;
        end else if (p_tick) begin
            h_count    <= h_count_next;
            v_count    <= v_count_next;
            h_sync_reg <= h_sync_next;
            v_sync_reg <= v_sync_next;
        end
    end

    // ---------------- Next-state logic ----------------
    always_comb begin
        // defaults: hold value (prevents latches)
        h_count_next = h_count;
        v_count_next = v_count;

        if (h_count == H_TOTAL - 1) begin
            h_count_next = '0;
            if (v_count == V_TOTAL - 1)
                v_count_next = '0;
            else
                v_count_next = v_count + 1;
        end else begin
            h_count_next = h_count + 1;
        end
    end

    // Computed from the *next* count so the registered sync lines up
    // exactly with h_count/v_count (no one-pixel lag).
    assign h_sync_next = ~((h_count_next >= H_DISP + H_FP) &&
                           (h_count_next <  H_DISP + H_FP + H_SYNC));
    assign v_sync_next = ~((v_count_next >= V_DISP + V_FP) &&
                           (v_count_next <  V_DISP + V_FP + V_SYNC));

    // ---------------- Outputs ----------------
    assign vid_on = (h_count < H_DISP) && (v_count < V_DISP);
    assign pix_x  = h_count;
    assign pix_y  = v_count;
    assign h_sync = h_sync_reg;
    assign v_sync = v_sync_reg;

endmodule