`include "defines.vh"

`timescale 1ns / 1ps

// 浮点寄存器模块
module f_regs (
    input clk,
    input rst,

    // from RF
    input [4:0] rs1_raddr_i,             // 读通用寄存器1地址
    input [4:0] rs2_raddr_i,             // 读通用寄存器2地址
    input [4:0] rs3_raddr_i,             // 读通用寄存器3地址

    // from lsu
    input [4:0] store_rs2_raddr_i,       // store指令rs2寄存器地址
    input load_we_i,                     // load指令写通用寄存器使能
    input [4:0] load_rd_waddr_i,         // load指令写通用寄存器地址
    input [31:0] load_rd_wdata_i,        // load指令写通用寄存器数据

    // from wb
    input rd_we_i,                       // 写通用寄存器使能
    input [4:0] rd_waddr_i,              // 写通用寄存器地址
    input [31:0] rd_wdata_i,             // 写通用寄存器数据

    // from commit
    input commit_rd_we_i,                // 提交写通用寄存器使能

    // to lsu
    output [31:0] store_rs2_rdata_o,     // store指令rs2寄存器数据

    // to RF
    output [31:0] rs1_rdata_o,           // 读通用寄存器1数据
    output [31:0] rs2_rdata_o,           // 读通用寄存器2数据
    output [31:0] rs3_rdata_o            // 读通用寄存器3数据
);

reg [31:0] fregs[0:31];         // 32个32位浮点寄存器
reg [31:0] fregs_wr_buffer;     // 写缓冲寄存器
reg [4:0]  fregs_waddr_d0;      // 写寄存器地址

// wb写
always @(posedge clk) begin
    if (rd_we_i) begin
        fregs_wr_buffer <= rd_wdata_i;
        fregs_waddr_d0 <= rd_waddr_i;
    end
    else if (load_we_i) begin
        fregs_wr_buffer <= load_rd_wdata_i;
        fregs_waddr_d0 <= load_rd_waddr_i;
    end
end

// commit写
integer i;
always @(posedge clk) begin
    if (!rst) begin
        for (i = 0; i < 32; i = i + 1) begin
            fregs[i] <= 32'b0;
        end
    end
    else if (commit_rd_we_i) begin
        fregs[fregs_waddr_d0] <= fregs_wr_buffer;
    end
end

// 读
assign store_rs2_rdata_o = fregs[store_rs2_raddr_i];
assign rs1_rdata_o = fregs[rs1_raddr_i];
assign rs2_rdata_o = fregs[rs2_raddr_i];
assign rs3_rdata_o = fregs[rs3_raddr_i];




endmodule