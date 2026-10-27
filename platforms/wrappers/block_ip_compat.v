`timescale 1ns / 1ps
// Vivado-only compatibility definitions: block ROM and asymmetric RAM.

// IROM: 2,048 x 256-bit = 64 KiB. Contents must be initialized by
// xil_irom using the SAME firmware image as PDS IROM.
module IROM (
    input  wire [10:0] addr,
    input  wire        clk,
    input  wire        rst,
    output wire [255:0] rd_data
);
    xil_irom u_xilinx_ip (
        .clka  (clk),
        .addra (addr),
        .douta (rd_data)
    );
endmodule

// Main DRAM: 65,536 x 32-bit write + 16,384 x 128-bit read = 256 KiB.
// Configure xil_main_ram as an asymmetric TRUE dual-port Block Memory Gen.
// A: 128-bit read-only; B: 32-bit write with 4 byte enables.
module RAM (
    input  wire         wr_clk,
    input  wire [15:0]  wr_addr,
    input  wire [31:0]  wr_data,
    input  wire         wr_en,
    input  wire [3:0]   wr_byte_en,
    input  wire         wr_rst,
    input  wire         rd_clk,
    input  wire [13:0]  rd_addr,
    output wire [127:0] rd_data,
    input  wire         rd_rst
);
    wire [31:0] ignored_b_read_data;
    // rst pins in current Lite are tied low. Keep existing ROM/RAM
    // runtime behavior by NOT adding an additional output register stage.
    xil_main_ram u_xilinx_ip (
        .clka  (rd_clk),
        .addra (rd_addr),
        .dina  (128'b0),
        .wea   (16'b0),
        .douta (rd_data),
        .clkb  (wr_clk),
        .addrb (wr_addr),
        .dinb  (wr_data),
        .web   (wr_en ? wr_byte_en : 4'b0000),
        .doutb (ignored_b_read_data)
    );
endmodule
