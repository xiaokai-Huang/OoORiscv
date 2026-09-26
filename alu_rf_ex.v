`include "defines.vh"

`timescale 1ns / 1ps

module alu_rf_ex (
    input clk,
    input rst,

    // from RF
    input inst_valid_i,                 // ALU指令有效标志
    input [5:0] rob_id_i,               // ALU ROB id
    input [7:0] mask_i,                 // ALU分支掩码
    input [3:0] subtype_i,              // ALU指令子类型
    input [31:0] op1_i,                 // ALU操作数1（RF阶段已选好）
    input [31:0] op2_i,                 // ALU操作数2（RF阶段已选好）
    input [5:0] pwaddr_i,               // ALU物理寄存器写地址

    // from clint
    input int_flag_i,                   // 中断标志

    // to ex
    output reg inst_valid_o,             // ALU指令有效标志
    output reg [5:0] rob_id_o,           // ALU ROB id
    output reg [7:0] mask_o,             // ALU分支掩码
    output reg [3:0] subtype_o,          // ALU指令子类型
    output reg [31:0] op1_o,             // ALU操作数1（RF阶段已选好）
    output reg [31:0] op2_o,             // ALU操作数2（RF阶段已选好）
    output reg [5:0] pwaddr_o            // 物理寄存器写地址
);

always @(posedge clk) begin
    if (!rst) begin
        inst_valid_o <= 1'b0;
        pwaddr_o <= 6'b0;
    end
    else if (int_flag_i) begin
        inst_valid_o <= 1'b0; // 中断发生时清空流水线
        pwaddr_o <= 6'b0;
    end
    else begin
        inst_valid_o <= inst_valid_i;
        pwaddr_o <= pwaddr_i;
    end
end

always @(posedge clk) begin
    rob_id_o <= rob_id_i;
    mask_o <= mask_i;
    subtype_o <= subtype_i;
    op1_o <= op1_i;
    op2_o <= op2_i;
end


endmodule