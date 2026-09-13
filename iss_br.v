`include "defines.vh"

`timescale 1ns / 1ps

module iss_br (
    input clk,
    input rst,

    // from issue
    input int_flag_i,                 // 中断标志
    input issue_flag_i,               // 发射标志
    input stall_i,                    // 暂停标志
    input [15:0] inst_addr_i,         // 指令地址
    input [5:0] rob_id_i,             // ROB id
    input bpu_pre_flag_i,             // BPU预测标志
    input [31:0] bpu_pre_addr_i,      // BPU预测地址
    input [7:0] mask_i,               // 分支掩码
    input [2:0] ras_ptr_i,            // RAS快照指针
    input [2:0] mem_wr_ptr_i,         // mem队列写操作快照指针
    input [2:0] sq_ptr_i,             // store queue快照指针
    input [2:0] alu_wr_ptr_i,         // ALU队列写操作快照指针
    input [2:0] branch_wr_ptr_i,      // branch队列写操作快照指针
    input [2:0] mul_div_wr_ptr_i,     // mul_div队列写操作快照指针
    input [2:0] snap_id_i,            // 快照id
    input [2:0] type_i,               // 指令类型
    input [3:0] subtype_i,            // 指令子类型
    input [1:0] op1_src_i,            // 操作数1来源选择
    input [1:0] op2_src_i,            // 操作数2来源选择
    input [5:0] praddr1_i,            // 物理寄存器1读地址
    input [5:0] praddr2_i,            // 物理寄存器2读地址
    input rs1_dep_mem_rf_i,           // rs1依赖访存结果
    input rs2_dep_mem_rf_i,           // rs2依赖访存结果
    input [5:0] pwaddr_i,             // 物理寄存器写地址
    input [31:0] imm_i,               // 立即数
    input [31:0] aux_addr_i,          // 辅助地址

    // from commit
    input free_mask_inst0_i,                   // 指令0释放掩码标志
    input [2:0] free_id_inst0_i,               // 指令0释放id
    input free_mask_inst1_i,                   // 指令1释放掩码标志
    input [2:0] free_id_inst1_i,               // 指令1释放id

    // from branch
    input jump_flag_i,                      // 跳转标志
    input [2:0] kill_mask_id_i,             // 杀死指令掩码id

    // to ex
    output reg inst_valid_o,          // 指令有效标志
    output reg [15:0] inst_addr_o,    // 指令地址
    output reg [5:0] rob_id_o,        // ROB id
    output reg bpu_pre_flag_o,        // BPU预测标志
    output reg [31:0] bpu_pre_addr_o, // BPU预测地址
    output reg [7:0] mask_o,          // 分支掩码
    output reg [2:0] ras_ptr_o,       // RAS快照指针
    output reg [2:0] mem_wr_ptr_o,    // mem队列写操作快照指针
    output reg [2:0] sq_ptr_o,        // store queue快照指针
    output reg [2:0] alu_wr_ptr_o,    // ALU队列写操作快照指针
    output reg [2:0] branch_wr_ptr_o, // branch队列写操作快照指针
    output reg [2:0] mul_div_wr_ptr_o,// mul_div队列写操作快照指针
    output reg [2:0] snap_id_o,       // 快照id
    output reg [2:0] type_o,          // 指令类型
    output reg [3:0] subtype_o,       // 指令子类型
    output reg [1:0] op1_src_o,       // 操作数1
    output reg [1:0] op2_src_o,       // 操作数2
    output reg [5:0] praddr1_o,       // 物理寄存器1读地址
    output reg [5:0] praddr2_o,       // 物理寄存器2读地址
    output reg rs1_dep_mem_rf_o,      // rs1依赖访存结果
    output reg rs2_dep_mem_rf_o,      // rs2依赖访存结果
    output reg [5:0] pwaddr_o,        // 物理寄存器写地址
    output reg [31:0] imm_o,          // 立即数
    output reg [31:0] aux_addr_o      // 辅助地址

);

reg [7:0] next_mask;
always @(*) begin
    next_mask = mask_o;
    if (free_mask_inst0_i) begin
        next_mask[free_id_inst0_i] = 1'b0;
    end
    if (free_mask_inst1_i) begin
        next_mask[free_id_inst1_i] = 1'b0;
    end
end

wire [7:0] kill_mask = jump_flag_i ? (8'b0000_0001 << kill_mask_id_i) : 8'b0000_0000;
wire next_valid = inst_valid_o && ((mask_o & kill_mask) == 0); // 如果指令的掩码位被kill_mask覆盖，则无效

always @(posedge clk) begin
    if (!rst) begin
        inst_valid_o <= 1'b0;
    end
    else if (int_flag_i) begin
        inst_valid_o <= 1'b0;
    end
    else if (issue_flag_i) begin
        inst_valid_o <= 1'b1;
    end
    else if (stall_i) begin
        inst_valid_o <= next_valid;
    end
    else begin
        inst_valid_o <= 1'b0; // 非发射周期指令无效
    end
end

// 动态状态（伴随stall期间更新）
always @(posedge clk) begin
    if (issue_flag_i) begin
        mask_o <= mask_i;
    end
    else if (stall_i) begin
        mask_o <= next_mask; // 在暂停期间允许被动态修改
    end
end

always @(posedge clk) begin
    if (issue_flag_i) begin
        inst_addr_o <= inst_addr_i;
        rob_id_o <= rob_id_i;
        bpu_pre_flag_o <= bpu_pre_flag_i;
        bpu_pre_addr_o <= bpu_pre_addr_i;
        ras_ptr_o <= ras_ptr_i;
        mem_wr_ptr_o <= mem_wr_ptr_i;
        sq_ptr_o <= sq_ptr_i;
        alu_wr_ptr_o <= alu_wr_ptr_i;
        branch_wr_ptr_o <= branch_wr_ptr_i;
        mul_div_wr_ptr_o <= mul_div_wr_ptr_i;
        snap_id_o <= snap_id_i;
        type_o <= type_i;
        subtype_o <= subtype_i;
        op1_src_o <= op1_src_i;
        op2_src_o <= op2_src_i;
        praddr1_o <= praddr1_i;
        praddr2_o <= praddr2_i;
        rs1_dep_mem_rf_o <= rs1_dep_mem_rf_i;
        rs2_dep_mem_rf_o <= rs2_dep_mem_rf_i;
        pwaddr_o <= pwaddr_i;
        imm_o <= imm_i;
        aux_addr_o <= aux_addr_i;
    end
end

endmodule