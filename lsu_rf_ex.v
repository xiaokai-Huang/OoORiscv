`include "defines.vh"

`timescale 1ns / 1ps

module lsu_rf_ex (
    // from rf
    input inst_valid_i,               // 指令有效标志
    input [5:0] rob_id_i,             // ROB id
    input [3:0] mask_i,               // 分支掩码
    input [1:0] sq_id_i,              // SQ id
    input [3:0] subtype_i,            // 指令子类型
    input [31:0] rs1_data_i,          // rs1数据
    input [31:0] rs2_data_i,          // rs2数据

    `ifdef use_f_extension
    input [31:0] float_rs2_data_i,     // 浮点rs2数据
    `endif

    input [5:0] pwaddr_i,             // 物理寄存器写地址
    input [31:0] imm_i,               // 立即数

    // to ex
    output inst_valid_o,               // 指令有效标志
    output [5:0] rob_id_o,             // ROB id
    output [3:0] mask_o,               // 分支掩码
    output [1:0] sq_id_o,              // SQ id
    output [3:0] subtype_o,            // 指令子类型
    output [31:0] rs1_data_o,          // rs1数据
    output [31:0] rs2_data_o,          // rs2数据

    `ifdef use_f_extension
    output [31:0] float_rs2_data_o,    // 浮点rs2数据
    `endif

    output [5:0] pwaddr_o,             // 物理寄存器写地址
    output [31:0] imm_o                // 立即数
);

assign inst_valid_o = inst_valid_i;
assign rob_id_o     = rob_id_i;
assign mask_o       = mask_i;
assign sq_id_o      = sq_id_i;
assign subtype_o    = subtype_i;
assign rs1_data_o   = rs1_data_i;
assign rs2_data_o   = rs2_data_i;
`ifdef use_f_extension
assign float_rs2_data_o = float_rs2_data_i;
`endif
assign pwaddr_o     = pwaddr_i;
assign imm_o        = imm_i;





endmodule