`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/23 11:22:51
// Design Name: 
// Module Name: bram_driver
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

module bram_driver (
    input  wire         clk,
    input  wire [17:0]  perip_waddr,
    input  wire [17:0]  perip_addr,
    input  wire [31:0]  perip_wdata,
    input  wire [1:0]   perip_mask,
    input  wire         bram_wen,
    output wire [31:0]  perip_rdata,
    output wire [127:0] dcache_line
);

    wire [15:0] bram_addr;
    wire [13:0] cache_addr;
    wire [ 1:0] offset;
    // wire [31:0] bram_rdata_raw;
    reg  [31:0] bram_data;
    reg  [31:0] dout;
    reg  [ 3:0] bram_byte_en;

    // assign bram_addr = perip_addr[17:2];
    // assign offset = perip_addr[1:0];
    assign {bram_addr, offset} = perip_waddr;
    assign cache_addr = perip_addr[17:4];
    assign perip_rdata = dout;

    // BUFG bufg_clk(
    //     .I(clk),
    //     .O(clk_buf)
    // );

    // MIN_BRAM Mem_BRAM(
    //     .clka(clk),
    //     .ena(1'b1),
    //     .wea(bram_wen? bram_byte_en: 4'b0000),
    //     .addra(bram_addr),
    //     .dina(bram_data),
    //     .douta(bram_rdata_raw)
    // );
    
    // Pango Simple Dual Port RAM
    RAM mem_BRAM (
        // 写端口：32 bit
        .wr_clk     (clk),
        .wr_addr    (bram_addr),
        .wr_data    (bram_data),
        .wr_en      (bram_wen),
        .wr_byte_en (bram_wen ? bram_byte_en : 4'b0000),
        .wr_rst     (1'b0),

        // 读端口：128 bit
        .rd_clk     (clk),
        .rd_addr    (cache_addr),
        .rd_data    (dcache_line),
        .rd_rst     (1'b0)
    );

    // 从 128-bit Cache Line 中选择 32-bit 数据
    always @(*) begin
        // dout = 0;
        // case (perip_mask)
        //     2'b00: // lb/lbu
        //         case (offset)
        //             2'b00:  dout = {24'b0, bram_rdata_raw[7:0]};
        //             2'b01:  dout = {24'b0, bram_rdata_raw[15:8]};
        //             2'b10:  dout = {24'b0, bram_rdata_raw[23:16]};
        //             2'b11:  dout = {24'b0, bram_rdata_raw[31:24]};
        //         endcase
        //     2'b01: // lh/lhu
        //         case (offset[1])
        //             1'b0:  dout = {16'b0, bram_rdata_raw[15:0]};
        //             1'b1:  dout = {16'b0, bram_rdata_raw[31:16]};
        //         endcase
        //     2'b10: dout = bram_rdata_raw;
        //     default: dout = 0;
        // endcase
        // dout = bram_rdata_raw;
        case (perip_addr[3:2])
            2'b00:   dout = dcache_line[31:0];
            2'b01:   dout = dcache_line[63:32];
            2'b10:   dout = dcache_line[95:64];
            2'b11:   dout = dcache_line[127:96];
            default: dout = 32'b0;
        endcase
    end

    // Store Byte / Store Halfword / Store Word
    always @(*) begin
        bram_data    = perip_wdata;
        bram_byte_en = 4'b0000;

        case (perip_mask)
            2'b00: begin  // SB
                case (offset)
                    2'b00: bram_byte_en = 4'b0001;
                    2'b01: bram_byte_en = 4'b0010;
                    2'b10: bram_byte_en = 4'b0100;
                    2'b11: bram_byte_en = 4'b1000;
                endcase
            end

            2'b01: begin  // SH
                case (offset[1])
                    1'b0: bram_byte_en = 4'b0011;
                    1'b1: bram_byte_en = 4'b1100;
                endcase
            end


            2'b10: begin  // SW
                bram_byte_en = 4'b1111;
            end

            default: begin
                bram_byte_en = 4'b0000;
            end
        endcase
    end

endmodule
