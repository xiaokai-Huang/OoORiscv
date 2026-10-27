`timescale 1ns / 1ps
// Vivado-only compatibility definitions for the PDS-facing Lite RTL.
// Include this file in the Vivado project ONLY; do not add it to PDS.
// Generated Xilinx IPs must be named xil_* (not the public module name).

// BTB_BANK: same public interface as PDS IP; Vivado distributed RAM adapter.
// The Xilinx IP must provide ASYNCHRONOUS dpo read and synchronous write.
module BTB_BANK (
    input  wire [4:0] wr_addr,
    input  wire [41:0] wr_data,
    input  wire [4:0] rd_addr,
    input  wire          wr_clk,
    input  wire          rd_clk,
    input  wire          rst,
    input  wire          wr_en,
    output wire [41:0] rd_data
);
    // Current Lite instances connect rd_clk and wr_clk to the same clock.
    // The original Vivado Dist Mem Generator uses a combinational dpo read.
    // Consequently rd_clk/rst are intentionally not connected to this IP.
    xil_btb_bank u_xilinx_ip (
        .a   (wr_addr),
        .d   (wr_data),
        .dpra(rd_addr),
        .clk (wr_clk),
        .we  (wr_en),
        .dpo (rd_data)
    );
endmodule

// rob_bank: same public interface as PDS IP; Vivado distributed RAM adapter.
// The Xilinx IP must provide ASYNCHRONOUS dpo read and synchronous write.
module rob_bank (
    input  wire [3:0] wr_addr,
    input  wire [63:0] wr_data,
    input  wire [3:0] rd_addr,
    input  wire          wr_clk,
    input  wire          rd_clk,
    input  wire          rst,
    input  wire          wr_en,
    output wire [63:0] rd_data
);
    // Current Lite instances connect rd_clk and wr_clk to the same clock.
    // The original Vivado Dist Mem Generator uses a combinational dpo read.
    // Consequently rd_clk/rst are intentionally not connected to this IP.
    xil_rob_bank u_xilinx_ip (
        .a   (wr_addr),
        .d   (wr_data),
        .dpra(rd_addr),
        .clk (wr_clk),
        .we  (wr_en),
        .dpo (rd_data)
    );
endmodule

// BHT_BANK: same public interface as PDS IP; Vivado distributed RAM adapter.
// The Xilinx IP must provide ASYNCHRONOUS dpo read and synchronous write.
module BHT_BANK (
    input  wire [5:0] wr_addr,
    input  wire [7:0] wr_data,
    input  wire [5:0] rd_addr,
    input  wire          wr_clk,
    input  wire          rd_clk,
    input  wire          rst,
    input  wire          wr_en,
    output wire [7:0] rd_data
);
    // Current Lite instances connect rd_clk and wr_clk to the same clock.
    // The original Vivado Dist Mem Generator uses a combinational dpo read.
    // Consequently rd_clk/rst are intentionally not connected to this IP.
    xil_bht_bank u_xilinx_ip (
        .a   (wr_addr),
        .d   (wr_data),
        .dpra(rd_addr),
        .clk (wr_clk),
        .we  (wr_en),
        .dpo (rd_data)
    );
endmodule

// PHT_BANK: same public interface as PDS IP; Vivado distributed RAM adapter.
// The Xilinx IP must provide ASYNCHRONOUS dpo read and synchronous write.
module PHT_BANK (
    input  wire [5:0] wr_addr,
    input  wire [1:0] wr_data,
    input  wire [5:0] rd_addr,
    input  wire          wr_clk,
    input  wire          rd_clk,
    input  wire          rst,
    input  wire          wr_en,
    output wire [1:0] rd_data
);
    // Current Lite instances connect rd_clk and wr_clk to the same clock.
    // The original Vivado Dist Mem Generator uses a combinational dpo read.
    // Consequently rd_clk/rst are intentionally not connected to this IP.
    xil_pht_bank u_xilinx_ip (
        .a   (wr_addr),
        .d   (wr_data),
        .dpra(rd_addr),
        .clk (wr_clk),
        .we  (wr_en),
        .dpo (rd_data)
    );
endmodule

// dcache_8bit: same public interface as PDS IP; Vivado distributed RAM adapter.
// The Xilinx IP must provide ASYNCHRONOUS dpo read and synchronous write.
module dcache_8bit (
    input  wire [4:0] wr_addr,
    input  wire [7:0] wr_data,
    input  wire [4:0] rd_addr,
    input  wire          wr_clk,
    input  wire          rd_clk,
    input  wire          rst,
    input  wire          wr_en,
    output wire [7:0] rd_data
);
    // Current Lite instances connect rd_clk and wr_clk to the same clock.
    // The original Vivado Dist Mem Generator uses a combinational dpo read.
    // Consequently rd_clk/rst are intentionally not connected to this IP.
    xil_dcache_8bit u_xilinx_ip (
        .a   (wr_addr),
        .d   (wr_data),
        .dpra(rd_addr),
        .clk (wr_clk),
        .we  (wr_en),
        .dpo (rd_data)
    );
endmodule

// dcache_load_tag: same public interface as PDS IP; Vivado distributed RAM adapter.
// The Xilinx IP must provide ASYNCHRONOUS dpo read and synchronous write.
module dcache_load_tag (
    input  wire [4:0] wr_addr,
    input  wire [9:0] wr_data,
    input  wire [4:0] rd_addr,
    input  wire          wr_clk,
    input  wire          rd_clk,
    input  wire          rst,
    input  wire          wr_en,
    output wire [9:0] rd_data
);
    // Current Lite instances connect rd_clk and wr_clk to the same clock.
    // The original Vivado Dist Mem Generator uses a combinational dpo read.
    // Consequently rd_clk/rst are intentionally not connected to this IP.
    xil_dcache_load_tag u_xilinx_ip (
        .a   (wr_addr),
        .d   (wr_data),
        .dpra(rd_addr),
        .clk (wr_clk),
        .we  (wr_en),
        .dpo (rd_data)
    );
endmodule

// dcache_store_tag: same public interface as PDS IP; Vivado distributed RAM adapter.
// The Xilinx IP must provide ASYNCHRONOUS dpo read and synchronous write.
module dcache_store_tag (
    input  wire [4:0] wr_addr,
    input  wire [9:0] wr_data,
    input  wire [4:0] rd_addr,
    input  wire          wr_clk,
    input  wire          rd_clk,
    input  wire          rst,
    input  wire          wr_en,
    output wire [9:0] rd_data
);
    // Current Lite instances connect rd_clk and wr_clk to the same clock.
    // The original Vivado Dist Mem Generator uses a combinational dpo read.
    // Consequently rd_clk/rst are intentionally not connected to this IP.
    xil_dcache_store_tag u_xilinx_ip (
        .a   (wr_addr),
        .d   (wr_data),
        .dpra(rd_addr),
        .clk (wr_clk),
        .we  (wr_en),
        .dpo (rd_data)
    );
endmodule

// Icache: PDS-style interface mapped to the Vivado single-port
// Distributed Memory Generator (asynchronous spo read, synchronous write).
module Icache (
    input  wire [3:0] addr,
    input  wire [255:0] wr_data,
    input  wire          clk,
    input  wire          rst,
    input  wire          wr_en,
    output wire [255:0] rd_data
);
    // A reset port is not available on the original distributed RAM IP.
    xil_icache u_xilinx_ip (
        .a  (addr),
        .d  (wr_data),
        .clk(clk),
        .we (wr_en),
        .spo(rd_data)
    );
endmodule

// icache_tag: PDS-style interface mapped to the Vivado single-port
// Distributed Memory Generator (asynchronous spo read, synchronous write).
module icache_tag (
    input  wire [3:0] addr,
    input  wire [7:0] wr_data,
    input  wire          clk,
    input  wire          rst,
    input  wire          wr_en,
    output wire [7:0] rd_data
);
    // A reset port is not available on the original distributed RAM IP.
    xil_icache_tag u_xilinx_ip (
        .a  (addr),
        .d  (wr_data),
        .clk(clk),
        .we (wr_en),
        .spo(rd_data)
    );
endmodule
