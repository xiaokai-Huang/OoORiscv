`include "defines.vh"

`timescale 1ns / 1ps

module dcache (
    input clk,
    input rst,
    input rs1_dep_rf_i,
    // from mem
    input [31:0] mem_addr,
    input mem_ren,
    // from dram
    input [127:0] cache_line,
    // from commit
    input mem_wen,
    input [1:0] mem_mask,
    input [31:0] mem_wdata,
    input [31:0] mem_waddr,
    // to commit
    output reg stall_store,             // store指令暂停标志
    // to mem
    output reg [31:0] mem_rdata,

    // to pipeline/ctrl
    output reg miss_hold,

    // to mem
    output reg cache_miss
);
localparam DRAM_ADDR_START = 32'h8010_0000;
localparam DRAM_ADDR_END   = 32'h8013_FFFF;
wire access_dram = mem_waddr[31] == 1'b1 && mem_waddr[21] == 1'b0;
wire read_dram = mem_addr[31] == 1'b1 && mem_addr[21] == 1'b0;

// 地址映射
wire [8:0] tag;              // 标签
assign tag = mem_addr[17:9];

wire [8:0] wr_tag;           // 写标签
assign wr_tag = mem_waddr[17:9];

wire [4:0] raddr;            // 读索引
assign raddr = mem_addr[8:4];

wire [4:0] waddr;            // 写索引
assign waddr = mem_waddr[8:4];

wire [1:0] offset;           // 读取字偏移
assign offset = mem_addr[3:2];

wire [1:0] wr_offset;        // 写入字偏移
assign wr_offset = mem_waddr[3:2];

wire [1:0] mem_index;        // 写入字节偏移
assign mem_index = mem_waddr[1:0];

reg [1:0] miss_cnt;
wire refill = (miss_cnt == 2);

// 数据阵列写地址：refill 与写命中共用
wire [4:0] data_waddr = refill ? raddr : waddr;

// 数据阵列：16 个 8bit 简单双口 RAM（32 x 8），写口按字节使能，读口异步输出整行
wire [127:0] dcache_rdata;
wire [7:0]   lane_dout[0:15];

// 标签阵列：{valid, tag}，refill 时两块 tag 同时用 raddr 写入
wire [9:0] load_tag_rdata;      // 读口用 raddr，做 load 命中匹配
wire [9:0] store_tag_rdata;     // 读口用 waddr，做 store 命中匹配

wire load_hit  = load_tag_rdata[9]  && (load_tag_rdata[8:0]  == tag);
wire store_hit = store_tag_rdata[9] && (store_tag_rdata[8:0] == wr_tag);
wire write_hit = mem_wen && access_dram && store_hit;

// 判断是否命中
always @(*) begin
    cache_miss = ~load_hit;
end

// 读
always @(*) begin
    case(offset)
        2'b00:   mem_rdata = dcache_rdata[31:0];
        2'b01:   mem_rdata = dcache_rdata[63:32];
        2'b10:   mem_rdata = dcache_rdata[95:64];
        default: mem_rdata = dcache_rdata[127:96];
    endcase
end

// 未命中时等待dram数据输出,进行行替换
// 读写同一行cache
wire access_conflict = mem_wen && access_dram && (raddr == waddr);
always @(posedge clk) begin
    if(!rst) begin
        miss_cnt <= 2'b0;
    end
    else if(access_conflict && cache_miss && mem_ren) begin
        miss_cnt <= 2'b0;
    end
    else if(cache_miss && mem_ren && miss_cnt < 2) begin
        miss_cnt <= miss_cnt + 1;
    end
    else begin
        miss_cnt <= 2'b0;
    end
end

always @(*) begin
    if (cache_miss && read_dram && (miss_cnt < 2 || rs1_dep_rf_i)) begin
        miss_hold = 1'b1;
    end
    else begin
        miss_hold = 1'b0;
    end
end

// 写
// 字节通道索引
reg [15:0] store_byte_we;
always @(*) begin
    case (mem_mask)
        2'b10:   store_byte_we = 16'h000F << {wr_offset, 2'b00};               // sw
        2'b01:   store_byte_we = 16'h0003 << {wr_offset, mem_index[1], 1'b0};  // sh
        2'b00:   store_byte_we = 16'h0001 << mem_waddr[3:0];                   // sb
        default: store_byte_we = 16'b0;
    endcase
end

// 数据阵列例化：16 个 8bit 简单双口 RAM
// 写数据只对实际写入的通道有效，未选中的通道 we=0
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : gen_cache_8bit
        Cache_8bit u_cache_8bit (
            .clk(clk),
            .a(data_waddr),
            .d(refill ? cache_line[i*8 +: 8] : mem_wdata[(i%4)*8 +: 8]),
            .we(refill | (write_hit & store_byte_we[i])),
            .dpra(raddr),
            .dpo(lane_dout[i])
        );
    end
endgenerate

assign dcache_rdata = {lane_dout[15], lane_dout[14], lane_dout[13], lane_dout[12],
                       lane_dout[11], lane_dout[10], lane_dout[9],  lane_dout[8],
                       lane_dout[7],  lane_dout[6],  lane_dout[5],  lane_dout[4],
                       lane_dout[3],  lane_dout[2],  lane_dout[1],  lane_dout[0]};

// 标签阵列例化：refill 时两块 tag 同时用 raddr 写入
load_tag u_load_tag (
    .clk(clk),
    .a(raddr),
    .d({1'b1, tag}),
    .we(refill),
    .dpra(raddr),
    .dpo(load_tag_rdata)
);

store_tag u_store_tag (
    .clk(clk),
    .a(raddr),
    .d({1'b1, tag}),
    .we(refill),
    .dpra(waddr),
    .dpo(store_tag_rdata)
);

always @(*) begin
    stall_store = refill;
end

endmodule