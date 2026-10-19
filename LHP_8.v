`include "defines.vh"

`timescale 1ns / 1ps

module LHP_8 (
    input clk,
    input rst,
    // from if
    input [31:0] if_pc,      // 取指阶段分支指令的PC地址（用于查表预测）


    // from ex（旧值随流水线送回）
    input update_en,                 // 更新使能
    input branch_taken,              // 实际跳转结果(1为跳转)
    input [15:0] ex_pc,              // 执行阶段分支指令的PC地址（用于更新标签）
    input [9:0] update_lhp_state_i,  // 取指时读到的旧值 {LHR[7:0], PHT计数[1:0]}

    // to selector
    output prediction_port0,        // 预测结果(1为跳转)
    output prediction_port1,        // 预测结果(1为跳转)

    // to if pipeline（旧值随预测一起下发）
    output [9:0] lhp_state_port0_o, // 偶指令 {LHR[7:0], PHT计数[1:0]}
    output [9:0] lhp_state_port1_o  // 奇指令 {LHR[7:0], PHT计数[1:0]}
);

// 回送的旧值拆包
wire [7:0] upd_lhr = update_lhp_state_i[9:2];
wire [1:0] upd_pht = update_lhp_state_i[1:0];

// wire [6:0] BHT_raddr;       // 分支历史表索引
// assign BHT_raddr = if_pc[8:2];

// wire [6:0] BHT_waddr;       // 分支历史表索引
// assign BHT_waddr = ex_pc[8:2];

wire [7:0] BHT_rdata[0:1];
wire [7:0] BHT_wdata[0:1];
assign BHT_wdata[0] = {upd_lhr[6:0], branch_taken};
assign BHT_wdata[1] = {upd_lhr[6:0], branch_taken};
// 偶
BHT_BANK u_BHT_BANK_0(
    .wr_addr(ex_pc[8:3]),
    .wr_data(BHT_wdata[0]),
    .rd_addr(if_pc[8:3]),
    .wr_clk(clk),
    .rd_clk(clk),
    .rst(1'b0),
    .wr_en(update_en && (ex_pc[2] == 1'b0)),    // 只有偶数指令才更新偶数BHT
    .rd_data(BHT_rdata[0])
);
// 奇
BHT_BANK u_BHT_BANK_1(
    .wr_addr(ex_pc[8:3]),
    .wr_data(BHT_wdata[1]),
    .rd_addr(if_pc[8:3]),
    .wr_clk(clk),
    .rd_clk(clk),
    .rst(1'b0),
    .wr_en(update_en && (ex_pc[2] == 1'b1)),    // 只有奇数指令才更新奇数BHT
    .rd_data(BHT_rdata[1])
);

wire [7:0] PHT_raddr_odd = {if_pc[10:8] ^ if_pc[7:5], if_pc[12:11] ^ if_pc[4:3], 3'b0} ^ {BHT_rdata[1]};     // 奇
wire [7:0] PHT_raddr_even = {if_pc[10:8] ^ if_pc[7:5], if_pc[12:11] ^ if_pc[4:3], 3'b0} ^ {BHT_rdata[0]};    // 偶

wire [7:0] PHT_waddr_odd = {ex_pc[10:8] ^ ex_pc[7:5], ex_pc[12:11] ^ ex_pc[4:3], 3'b0} ^ upd_lhr;     // 奇
wire [7:0] PHT_waddr_even = {ex_pc[10:8] ^ ex_pc[7:5], ex_pc[12:11] ^ ex_pc[4:3], 3'b0} ^ upd_lhr;    // 偶

reg [1:0] PHT_wdata_odd, PHT_wdata_even;
wire [1:0] PHT_rdata_odd[0:3];
wire [1:0] PHT_rdata_even[0:3];

generate
    genvar i,j;
    for (i = 0; i < 4; i = i + 1) begin:PHT_BANK_odd
        PHT_BANK u_PHT_64_odd(
            .wr_addr(PHT_waddr_odd[5:0]),
            .wr_data(PHT_wdata_odd),
            .rd_addr(PHT_raddr_odd[5:0]),
            .wr_clk(clk),
            .rd_clk(clk),
            .rst(1'b0),
            .wr_en(update_en && (ex_pc[2] == 1'b1) && PHT_waddr_odd[7:6] == i),   
            .rd_data(PHT_rdata_odd[i])
        );
    end

    for (j = 0; j < 4; j = j + 1) begin:PHT_BANK_even
        PHT_BANK u_PHT_64_even(
            .wr_addr(PHT_waddr_even[5:0]),
            .wr_data(PHT_wdata_even),
            .rd_addr(PHT_raddr_even[5:0]),
            .wr_clk(clk),
            .rd_clk(clk),
            .rst(1'b0),
            .wr_en(update_en && (ex_pc[2] == 1'b0) && PHT_waddr_even[7:6] == j),    
            .rd_data(PHT_rdata_even[j])
        );
    end
endgenerate

// 取指阶段预测
assign prediction_port0 = PHT_rdata_even[PHT_raddr_even[7:6]][1];
assign prediction_port1 = PHT_rdata_odd[PHT_raddr_odd[7:6]][1];

// 取指阶段把旧值随预测一起下发，供分支执行完后送回更新
assign lhp_state_port0_o = {BHT_rdata[0], PHT_rdata_even[PHT_raddr_even[7:6]]};
assign lhp_state_port1_o = {BHT_rdata[1], PHT_rdata_odd[PHT_raddr_odd[7:6]]};


// 更新PHT：旧计数来自流水线送回的值
always @(*) begin
    if(branch_taken && upd_pht != 2'b11) begin
        PHT_wdata_odd = upd_pht + 1;
    end
    else if(!branch_taken && upd_pht != 2'b00) begin
        PHT_wdata_odd = upd_pht - 1;
    end
    else begin
        PHT_wdata_odd = upd_pht;
    end
end

always @(*) begin
    if(branch_taken && upd_pht != 2'b11) begin
        PHT_wdata_even = upd_pht + 1;
    end
    else if(!branch_taken && upd_pht != 2'b00) begin
        PHT_wdata_even = upd_pht - 1;
    end
    else begin
        PHT_wdata_even = upd_pht;
    end
end



endmodule 