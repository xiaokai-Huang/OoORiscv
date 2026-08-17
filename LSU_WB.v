`include "defines.vh"

`timescale 1ns / 1ps

module LSU_WB (
    // from mem
    input inst_valid_i,                 // 指令有效标志
    input [3:0] subtype_i,              // 指令子类型
    input [5:0] rob_id_i,               // ROB id
    input [5:0] pwaddr_i,               // 物理寄存器写地址
    input [31:0] reg_wdata_i,           // 写寄存器数据

    `ifdef use_f_extension
    input rd_is_float_i,                // 写回寄存器是否为浮点寄存器
    `endif

    // to regs
    output reg_wflag_o,                 // 写回阶段写寄存器标志
    output [5:0] reg_waddr_o,           // 写回阶段写寄存器地址
    output [31:0] reg_wdata_o,          // 写回阶段写寄存器数据

    `ifdef use_f_extension
    output float_reg_wflag_o,           // 写回阶段写浮点寄存器标志
    `endif

    // to ROB
    output load_complete_flag_o,              // load指令完成标志
    output [5:0] load_commit_rob_id_o         // load提交ROB id
);

`ifdef use_f_extension
assign reg_wflag_o = inst_valid_i && (subtype_i[3] == 1'b0) && !rd_is_float_i; // 只有load指令才写寄存器
`else
assign reg_wflag_o = inst_valid_i && (subtype_i[3] == 1'b0); // 只有load指令才写寄存器
`endif
`ifdef use_f_extension
assign float_reg_wflag_o = inst_valid_i && (subtype_i[3] == 1'b0) && rd_is_float_i;
`endif
assign reg_waddr_o = pwaddr_i;
assign reg_wdata_o = reg_wdata_i;
assign load_complete_flag_o = inst_valid_i && (subtype_i[3] == 1'b0); // 只有load指令才完成
assign load_commit_rob_id_o = rob_id_i;







endmodule