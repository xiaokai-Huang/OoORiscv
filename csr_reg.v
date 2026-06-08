`include "defines.vh"

`timescale 1ns / 1ps

module csr_reg (
    input clk,
    input rst,

    // from id
    input [11:0] raddr_i,        // id模块读寄存器地址

    // from ex
    input we_i,                  // ex模块写寄存器标志
    input [11:0] waddr_i,        // ex模块写寄存器地址
    input [31:0] data_i,         // ex模块写寄存器数据

    // from clint
    // input [11:0] clint_raddr_i,        // clint模块读寄存器地址
    input mepc_we_i,                     // 写mepc寄存器标志
    input mstatus_we_i,                  // 写mstatus寄存器标志
    input mcause_we_i,                   // 写mcause寄存器标志
    input mip_we_i,                      // 写mip寄存器标志
    input [31:0] mepc_wdata_i,           // 写mepc寄存器数据
    input [31:0] mstatus_wdata_i,        // 写mstatus寄存器数据
    input [31:0] mcause_wdata_i,         // 写mcause寄存器数据
    input [31:0] mip_wdata_i,            // 写mip寄存器数据

    input uart_int_clear,                // MIP外部中断位清零
    input timer_int_clear,               // MIP定时器中断位清零

    // to clint
    output global_int_en_o,              // 全局中断使能标志
    output mie_MEIE,                     // 外部中断使能标志
    output mie_MTIE,                     // 定时器中断使能标志
    output mip_MEIP,                     // 外部中断挂起标志
    output mip_MTIP,                     // 定时器中断挂起标志
    // output reg[31:0] clint_data_o,       // clint模块读寄存器数据
    output [31:0] clint_csr_mtvec,       // mtvec
    output [31:0] clint_csr_mepc,        // mepc
    output [31:0] clint_csr_mstatus,     // mstatus

    // to id
    output reg[31:0] data_o              // id模块读寄存器数据

);

reg [31:0] mtvec;
reg [31:0] mcause;
reg [31:0] mepc;
reg [31:0] mstatus;

assign global_int_en_o = mstatus[3];

assign clint_csr_mtvec = mtvec;
assign clint_csr_mepc = mepc;
assign clint_csr_mstatus = mstatus;



// 写
always @ (posedge clk) begin
    if (!rst) begin
        mtvec <= 32'b0;    // 后续由软件初始化为中断向量表起始地址
        mcause <= 32'b0;
        mepc <= 32'b0;
        mstatus <= 32'b0;
    end
    else begin
        // clint模块写操作
        if (mepc_we_i) begin
            mepc <= mepc_wdata_i;
        end
        if (mstatus_we_i) begin
            mstatus <= mstatus_wdata_i;
        end
        if (mcause_we_i) begin
            mcause <= mcause_wdata_i;
        end
        // ex模块的写操作
        if (we_i) begin
            case (waddr_i)
                `CSR_MTVEC: begin
                    mtvec <= data_i;
                end
                `CSR_MCAUSE: begin
                    mcause <= data_i;
                end
                `CSR_MEPC: begin
                    mepc <= data_i;
                end
                `CSR_MSTATUS: begin
                    mstatus <= data_i;
                end
                default: ;
            endcase
        end
    end
end

// 读
always @ (*) begin
    case (raddr_i)
        `CSR_MTVEC: begin
            data_o = mtvec;
        end
        `CSR_MCAUSE: begin
            data_o = mcause;
        end
        `CSR_MEPC: begin
            data_o = mepc;
        end
        `CSR_MSTATUS: begin
            data_o = mstatus;
        end
        default: begin
            data_o = 32'b0;
        end
    endcase
end




endmodule