
// module Dcache (
//     input  wire [4:0]   a,
//     input  wire [137:0] d,
//     input  wire [4:0]   dpra,
//     input  wire         clk,
//     input  wire         we,
//     output wire [137:0] spo,
//     output wire [137:0] dpo
// );

//     // RAM 0：Commit / Store 读取
//     Dcache_sdp u_ram_commit (
//         .wr_addr (a),
//         .wr_data (d),
//         .wr_en   (we),
//         .wr_clk  (clk),

//         .rd_addr (a),
//         .rd_clk  (clk),
//         .rd_data (spo),

//         .rst     (1'b0)
//     );

//     // RAM 1：Load 读取
//     Dcache_sdp u_ram_load (
//         .wr_addr (a),
//         .wr_data (d),
//         .wr_en   (we),
//         .wr_clk  (clk),

//         .rd_addr (dpra),
//         .rd_clk  (clk),
//         .rd_data (dpo),

//         .rst     (1'b0)
//     );

// endmodule


// module PHT_BANK (
//     input  wire [5:0] a,
//     input  wire [1:0] d,
//     input  wire [5:0] dpra,
//     input  wire       clk,
//     input  wire       we,
//     output wire [1:0] spo,
//     output wire [1:0] dpo
// );

//     // 第一份：读取 a 地址
//     PHT_sdp u_pht_spo (
//         .wr_data (d),
//         .wr_addr (a),
//         .rd_addr (a),
//         .wr_clk  (clk),
//         .rd_clk  (clk),
//         .wr_en   (we),
//         .rst     (1'b0),
//         .rd_data (spo)
//     );

//     // 第二份：读取 dpra 地址
//     PHT_sdp u_pht_dpo (
//         .wr_data (d),
//         .wr_addr (a),
//         .rd_addr (dpra),
//         .wr_clk  (clk),
//         .rd_clk  (clk),
//         .wr_en   (we),
//         .rst     (1'b0),
//         .rd_data (dpo)
//     );

// endmodule


// module BHT_BANK (
//     input  wire [5:0] a,
//     input  wire [7:0] d,
//     input  wire [5:0] dpra,
//     input  wire       clk,
//     input  wire       we,
//     output wire [7:0] spo,
//     output wire [7:0] dpo
// );

//     // 第一份：读取 a 地址
//     BHT_sdp u_bht_spo (
//         .wr_data (d),
//         .wr_addr (a),
//         .rd_addr (a),
//         .wr_clk  (clk),
//         .rd_clk  (clk),
//         .wr_en   (we),
//         .rst     (1'b0),
//         .rd_data (spo)
//     );

//     // 第二份：读取 dpra 地址
//     BHT_sdp u_bht_dpo (
//         .wr_data (d),
//         .wr_addr (a),
//         .rd_addr (dpra),
//         .wr_clk  (clk),
//         .rd_clk  (clk),
//         .wr_en   (we),
//         .rst     (1'b0),
//         .rd_data (dpo)
//     );

// endmodule


// module Dcache (
//     input  wire [4:0]   a,
//     input  wire [137:0] d,
//     input  wire [4:0]   dpra,
//     input  wire         clk,
//     input  wire         we,
//     output wire [137:0] spo,
//     output wire [137:0] dpo
// );

//     reg [137:0] mem [0:31] /* synthesis syn_ramstyle = "select_ram" */;

//     always @(posedge clk) begin
//         if (we)
//             mem[a] <= d;
//     end

//     assign spo = mem[a];
//     assign dpo = mem[dpra];

// endmodule


// module PHT_BANK (
//     input  wire [5:0] a,
//     input  wire [1:0] d,
//     input  wire [5:0] dpra,
//     input  wire       clk,
//     input  wire       we,
//     output wire [1:0] spo,
//     output wire [1:0] dpo
// );

//     reg [1:0] mem [0:63];

//     // 同步写
//     always @(posedge clk) begin
//         if (we)
//             mem[a] <= d;
//     end

//     // 双端口异步读
//     assign spo = mem[a];
//     assign dpo = mem[dpra];

// endmodule


// module BHT_BANK (
//     input  wire [5:0] a,
//     input  wire [7:0] d,
//     input  wire [5:0] dpra,
//     input  wire       clk,
//     input  wire       we,
//     output wire [7:0] spo,
//     output wire [7:0] dpo
// );

//     reg [7:0] mem [0:63];

//     // 同步写
//     always @(posedge clk) begin
//         if (we)
//             mem[a] <= d;
//     end

//     // 双端口异步读
//     assign spo = mem[a];
//     assign dpo = mem[dpra];

// endmodule

