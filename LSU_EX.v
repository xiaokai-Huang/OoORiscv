`include "defines.vh"

`timescale 1ns / 1ps

module LSU_EX (
    // from rf
    input inst_valid_i,               // 指令有效标志
    input [5:0] rob_id_i,             // ROB id
    input [7:0] mask_i,               // 分支掩码
    input [1:0] sq_id_i,              // SQ id
    input [3:0] subtype_i,            // 指令子类型
    input [31:0] rs1_data_i,          // rs1数据（寄存器读出的原始数据）
    input [1:0] rs1_fwd_sel_i,        // rs1转发选择（2 位 one-hot：01=ALU0, 10=ALU1, 00=不转发）
    input [31:0] alu0_exe_wdata_i,    // ALU0 执行阶段结果（转发模块不搬运数据，由 ALU 直连）
    input [31:0] alu1_exe_wdata_i,    // ALU1 执行阶段结果（转发模块不搬运数据，由 ALU 直连）
    input [31:0] rs2_data_i,          // rs2数据

    `ifdef use_f_extension
    input [31:0] float_rs2_data_i,     // 浮点rs2数据
    `endif

    input [5:0] pwaddr_i,             // 物理寄存器写地址
    input [31:0] imm_i,               // 立即数

    // from branch
    input jump_flag_i,                 // 跳转标志
    input [2:0] kill_mask_id_i,        // 分支掩码id

    // from branch
    input free_mask_inst0_i,                   // 释放掩码标志
    input [2:0] free_id_inst0_i,               // 释放id

    // to mem
    output inst_valid_o,               // 指令有效标志
    output [5:0] rob_id_o,             // ROB id
    output reg [7:0] mask_o,           // 分支掩码
    output [1:0] sq_id_o,              // SQ id
    output [3:0] subtype_o,            // 指令子类型
    output [31:0] rs2_data_o,          // rs2数据

    `ifdef use_f_extension
    output [31:0] float_rs2_data_o,    // 浮点rs2数据
    `endif

    output [5:0] pwaddr_o,             // 物理寄存器写地址
    output [31:0] mem_addr_reg,
    output [31:0] mem_addr_alu0,
    output [31:0] mem_addr_alu1
);

wire kill_mask = jump_flag_i && (mask_i != 8'b0);
assign inst_valid_o = inst_valid_i && !kill_mask; // 如果指令的掩码位被kill_mask覆盖，则无效
assign rob_id_o = rob_id_i;
assign sq_id_o = sq_id_i;
assign subtype_o = subtype_i;
assign rs2_data_o = rs2_data_i;
`ifdef use_f_extension
assign float_rs2_data_o = float_rs2_data_i;
`endif
assign pwaddr_o = pwaddr_i;

// 访存地址：三路并行加法 + 末级选择
assign mem_addr_reg  = {8'h80, rs1_data_i[23:0]       + imm_i[23:0]};   // 寄存器读数据 + 立即数
assign mem_addr_alu0 = {8'h80, alu0_exe_wdata_i[23:0] + imm_i[23:0]};   // ALU0 结果 + 立即数
assign mem_addr_alu1 = {8'h80, alu1_exe_wdata_i[23:0] + imm_i[23:0]};   // ALU1 结果 + 立即数

always @(*) begin
    mask_o = mask_i;
    if (free_mask_inst0_i) begin
        mask_o[free_id_inst0_i] = 1'b0;
    end
end


endmodule