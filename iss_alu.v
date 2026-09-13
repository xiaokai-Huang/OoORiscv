`include "defines.vh"

`timescale 1ns / 1ps

module iss_alu (
    input clk,
    input rst,

    // from issue
    input int_flag_i,                     // 中断标志
    input issue_flag_i,                   // 发射标志
    input stall_i,                        // 暂停标志
    input [5:0] alu_rob_id_i,             // ROB id
    input [7:0] alu_mask_i,               // 分支掩码
    input [3:0] alu_subtype_i,            // 指令子类型
    input [1:0] alu_op1_src_i,            // 操作数1来源选择
    input [1:0] alu_op2_src_i,            // 操作数2来源选择
    input [5:0] alu_praddr1_i,            // 物理寄存器1读地址
    input [5:0] alu_praddr2_i,            // 物理寄存器2读地址
    input alu_rs1_dep_mem_rf_i,           // rs1依赖访存结果
    input alu_rs2_dep_mem_rf_i,           // rs2依赖访存结果
    input [5:0] alu_pwaddr_i,             // 物理寄存器写地址
    input [31:0] alu_imm_i,               // 立即数

    // from commit
    input free_mask_inst0_i,                   // 指令0释放掩码标志
    input [2:0] free_id_inst0_i,               // 指令0释放id
    input free_mask_inst1_i,                   // 指令1释放掩码标志
    input [2:0] free_id_inst1_i,               // 指令1释放id

    // from branch
    input jump_flag_i,                      // 跳转标志
    input [2:0] kill_mask_id_i,             // 杀死指令掩码id

    // to ex
    output reg alu_inst_valid_o,          // 指令有效标志
    output reg [5:0] alu_rob_id_o,        // ROB id
    output reg [7:0] alu_mask_o,          // 分支掩码
    output reg [3:0] alu_subtype_o,       // 指令子类型
    output reg [1:0] alu_op1_src_o,       // 操作数1
    output reg [1:0] alu_op2_src_o,       // 操作数2
    output reg [5:0] alu_praddr1_o,       // 物理寄存器1读地址
    output reg [5:0] alu_praddr2_o,       // 物理寄存器2读地址
    output reg alu_rs1_dep_mem_rf_o,      // rs1依赖访存结果
    output reg alu_rs2_dep_mem_rf_o,      // rs2依赖访存结果
    output reg [5:0] alu_pwaddr_o,        // 物理寄存器写地址
    output reg [31:0] alu_imm_o           // 立即数

);

reg [7:0] next_mask;
always @(*) begin
    next_mask = alu_mask_o;
    if (free_mask_inst0_i) begin
        next_mask[free_id_inst0_i] = 1'b0;
    end
    if (free_mask_inst1_i) begin
        next_mask[free_id_inst1_i] = 1'b0;
    end
end

wire [7:0] kill_mask = jump_flag_i ? (8'b0000_0001 << kill_mask_id_i) : 8'b0000_0000;
wire next_valid = alu_inst_valid_o && ((alu_mask_o & kill_mask) == 0); // 如果指令的掩码位被kill_mask覆盖，则无效

always @(posedge clk) begin
    if (!rst) begin
        alu_inst_valid_o <= 1'b0;
        alu_pwaddr_o <= 6'b0;
    end
    else if (int_flag_i) begin
        alu_inst_valid_o <= 1'b0; // 中断发生时清空流水线
        alu_pwaddr_o <= 6'b0;
    end
    else if (issue_flag_i) begin
        alu_inst_valid_o <= 1'b1;
        alu_pwaddr_o <= alu_pwaddr_i;
    end
    else if (stall_i) begin
        alu_inst_valid_o <= next_valid;
        alu_pwaddr_o     <= next_valid ? alu_pwaddr_o : 6'd0;
    end
    else begin
        alu_inst_valid_o <= 1'b0; // 非发射周期指令无效
        alu_pwaddr_o <= 6'b0;
    end
end

// 动态状态（伴随stall期间更新）
always @(posedge clk) begin
    if (issue_flag_i) begin
        alu_mask_o <= alu_mask_i;
    end
    else if (stall_i) begin
        alu_mask_o <= next_mask; // 在暂停期间允许被动态修改
    end
end

always @(posedge clk) begin
    if (issue_flag_i) begin
        alu_rob_id_o <= alu_rob_id_i;
        alu_subtype_o <= alu_subtype_i;
        alu_op1_src_o <= alu_op1_src_i;
        alu_op2_src_o <= alu_op2_src_i;
        alu_praddr1_o <= alu_praddr1_i;
        alu_praddr2_o <= alu_praddr2_i;
        alu_rs1_dep_mem_rf_o <= alu_rs1_dep_mem_rf_i;
        alu_rs2_dep_mem_rf_o <= alu_rs2_dep_mem_rf_i;
        alu_imm_o <= alu_imm_i;
    end
end

endmodule