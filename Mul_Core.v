`include "defines.vh"

`timescale 1ns / 1ps

// 无符号乘法器
module Mul_Core (
    input clk,
    input rst_n,
    input [31:0] op1,
    input [31:0] op2,
    output reg [63:0] product
);

// 拆分32位输入为高低16位
reg [15:0] op1_l_s1, op1_h_s1;
reg [15:0] op2_l_s1, op2_h_s1;

always @(posedge clk) begin
    op1_l_s1 <= op1[15:0];  
    op1_h_s1 <= op1[31:16];
    op2_l_s1 <= op2[15:0];  
    op2_h_s1 <= op2[31:16];
end

// 计算4个16位乘法的中间结果，并存入寄存器
(* use_dsp = "yes" *) reg [31:0] mul_ll_s2; // Low * Low
(* use_dsp = "yes" *) reg [31:0] mul_lh_s2; // Low * High
(* use_dsp = "yes" *) reg [31:0] mul_hl_s2; // High * Low
(* use_dsp = "yes" *) reg [31:0] mul_hh_s2; // High * High

always @(posedge clk) begin
    mul_ll_s2 <= op1_l_s1 * op2_l_s1;
    mul_lh_s2 <= op1_l_s1 * op2_h_s1;
    mul_hl_s2 <= op1_h_s1 * op2_l_s1;
    mul_hh_s2 <= op1_h_s1 * op2_h_s1;
end

// 合并中间结果（移位+加法），得到最终64位乘法结果
wire [32:0] mid = {1'b0, mul_lh_s2} + {1'b0, mul_hl_s2};
wire [16:0] t1  = {1'b0, mul_ll_s2[31:16]} + {1'b0, mid[15:0]};
wire [32:0] hi  = {1'b0, mul_hh_s2} + {16'b0, mid[32:16]} + {32'b0, t1[16]};
always @(posedge clk) product <= {hi[31:0], t1[15:0], mul_ll_s2[15:0]};







endmodule