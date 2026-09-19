`include "defines.vh"

`timescale 1ns / 1ps

// 分支目标缓冲区（二路组相联），用于预测跳转地址
// 组数32（pc[7:3]），标签8位（pc[15:8]），奇偶各二路，共128项
module BTB_64_plus (
    input clk,
    input rst,

    // from IF
    input [31:0] pc,            // 取指阶段PC地址

    // from ex
    input update_en,                        // 执行阶段更新BTB使能
    input [31:0] jump_target,               // 实际跳转目标地址
    input [15:0] ex_pc,                     // 执行阶段的pc
    input is_branch,                        // 是否为分支指令

    // from BPU（取指命中信息，用于LRU更新：命中的路被标记为最近使用）
    input hit_even_way0,                // 偶指令取指命中way0
    input hit_even_way1,                // 偶指令取指命中way1
    input hit_odd_way0,                 // 奇指令取指命中way0
    input hit_odd_way1,                 // 奇指令取指命中way1

    // to PC（二路组相联，奇偶各输出两路）
    output [41:0] pre_port0_way0,       // 偶指令 way0
    output [41:0] pre_port0_way1,       // 偶指令 way1
    output [41:0] pre_port1_way0,       // 奇指令 way0
    output [41:0] pre_port1_way1        // 奇指令 way1
);

// 取指阶段索引/标签
wire [4:0] pc_index;            // pc低位作为组索引
assign pc_index = pc[7:3];

// 执行阶段更新索引/标签
wire [4:0] ex_pc_index;         // 执行阶段pc组索引
assign ex_pc_index = ex_pc[7:3];
wire [7:0] ex_pc_tag;           // 执行阶段pc标签
assign ex_pc_tag = ex_pc[15:8];

// 写数据（两路相同）
wire [41:0] btb_wdata;
assign btb_wdata = {1'b1, is_branch, ex_pc_tag, jump_target};

// 更新时在地址a（ex_pc_index）上异步读出组内表项（spo），用于判断更新时写入哪一路
wire [41:0] btb_spo_even_way0, btb_spo_even_way1, btb_spo_odd_way0, btb_spo_odd_way1;

// LRU：1'b0表示way0为最近最少使用（下次替换way0），1'b1表示替换way1
reg lru_even[0:31];
reg lru_odd[0:31];

wire even_update;               // 偶指令更新
wire odd_update;                // 奇指令更新
assign even_update = update_en && (ex_pc[2] == 1'b0);
assign odd_update  = update_en && (ex_pc[2] == 1'b1);

// 由spo读出的表项判断更新地址是否已在组内（valid && tag匹配）
wire even_way0_hit, even_way1_hit, odd_way0_hit, odd_way1_hit;
assign even_way0_hit = btb_spo_even_way0[41] && (btb_spo_even_way0[39:32] == ex_pc_tag);
assign even_way1_hit = btb_spo_even_way1[41] && (btb_spo_even_way1[39:32] == ex_pc_tag);
assign odd_way0_hit  = btb_spo_odd_way0[41]  && (btb_spo_odd_way0[39:32]  == ex_pc_tag);
assign odd_way1_hit  = btb_spo_odd_way1[41]  && (btb_spo_odd_way1[39:32]  == ex_pc_tag);

// 命中则写命中路（两路都命中时优先way0），未命中则替换LRU路
wire even_sel_way1, odd_sel_way1;
assign even_sel_way1 = (even_way1_hit && !even_way0_hit) || (!even_way0_hit && !even_way1_hit && lru_even[ex_pc_index]);
assign odd_sel_way1  = (odd_way1_hit  && !odd_way0_hit)  || (!odd_way0_hit  && !odd_way1_hit  && lru_odd[ex_pc_index]);

wire even_way0_we, even_way1_we, odd_way0_we, odd_way1_we;
assign even_way0_we = even_update && !even_sel_way1;
assign even_way1_we = even_update &&  even_sel_way1;
assign odd_way0_we  = odd_update  && !odd_sel_way1;
assign odd_way1_we  = odd_update  &&  odd_sel_way1;

// 更新LRU：写（更新）和取指命中都会把被访问的路标记为最近使用（即另一路为LRU）
integer i;
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        for(i = 0; i < 32; i = i + 1) begin
            lru_even[i] <= 1'b0;
            lru_odd[i]  <= 1'b0;
        end
    end
    else begin
        // 取指命中：命中way0则way1为最近最少使用，命中way1则way0为最近最少使用
        if(hit_even_way0) begin
            lru_even[pc_index] <= 1'b1;
        end
        else if(hit_even_way1) begin
            lru_even[pc_index] <= 1'b0;
        end
        if(hit_odd_way0) begin
            lru_odd[pc_index] <= 1'b1;
        end
        else if(hit_odd_way1) begin
            lru_odd[pc_index] <= 1'b0;
        end
        // 更新（写）：同组同时发生时以写为准
        if(even_way0_we) begin
            lru_even[ex_pc_index] <= 1'b1;
        end
        else if(even_way1_we) begin
            lru_even[ex_pc_index] <= 1'b0;
        end
        if(odd_way0_we) begin
            lru_odd[ex_pc_index] <= 1'b1;
        end
        else if(odd_way1_we) begin
            lru_odd[ex_pc_index] <= 1'b0;
        end
    end
end

// 偶指令 way0
BTB_BANK u_BTB_BANK_even_way0(
    .a(ex_pc_index),
    .d(btb_wdata),
    .dpra(pc_index),
    .clk(clk),
    .we(even_way0_we),
    .spo(btb_spo_even_way0),
    .dpo(pre_port0_way0)
);
// 偶指令 way1
BTB_BANK u_BTB_BANK_even_way1(
    .a(ex_pc_index),
    .d(btb_wdata),
    .dpra(pc_index),
    .clk(clk),
    .we(even_way1_we),
    .spo(btb_spo_even_way1),
    .dpo(pre_port0_way1)
);
// 奇指令 way0
BTB_BANK u_BTB_BANK_odd_way0(
    .a(ex_pc_index),
    .d(btb_wdata),
    .dpra(pc_index),
    .clk(clk),
    .we(odd_way0_we),
    .spo(btb_spo_odd_way0),
    .dpo(pre_port1_way0)
);
// 奇指令 way1
BTB_BANK u_BTB_BANK_odd_way1(
    .a(ex_pc_index),
    .d(btb_wdata),
    .dpra(pc_index),
    .clk(clk),
    .we(odd_way1_we),
    .spo(btb_spo_odd_way1),
    .dpo(pre_port1_way1)
);


endmodule 