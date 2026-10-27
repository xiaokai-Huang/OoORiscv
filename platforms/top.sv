`timescale 1ns / 1ps
// Vivado-specific top. The PDS top remains at the repository root.
// Choose this as top ONLY for the Xilinx build.
// Define VIVADO_DIFF_CLK for boards with differential reference clock.
module top (
    input  wire i_sys_clk_p,
    input  wire i_sys_clk_n,

    input  wire i_uart_rx,
    output wire o_uart_tx
);
    wire sys_clk;
    wire cpu_clk;
    wire pll_locked;
    // Vivado Clocking Wizard, rename the IP to xil_pll.
    xil_pll u_clkgen (
        .clk_in1 (sys_clk),
        .clk_out1(cpu_clk),
        .locked  (pll_locked)
    );

    // PDS Lite top does not drive w_clk_50Mhz. Here it is deliberately
    // connected to CPU clock to avoid a floating net. Configure another
    // PLL output and rewire this signal if peripherals require real 50 MHz.
    wire perip_clk = cpu_clk;

    // The current Lite board top has no external virtual switches/keys.
    // Tie them off explicitly on Xilinx instead of leaving X/undriven nets.
    wire [7:0]  virtual_key = 8'b0;
    wire [63:0] virtual_sw  = 64'b0;
    wire [31:0] virtual_led;
    wire [39:0] virtual_seg;

    student_top student_top_inst (
        .w_cpu_clk  (cpu_clk),
        .w_clk_50Mhz(perip_clk),
        .w_clk_rst  (~pll_locked),
        .virtual_key(virtual_key),
        .virtual_sw (virtual_sw),
        .virtual_led(virtual_led),
        .virtual_seg(virtual_seg),
        .rx         (i_uart_rx),
        .tx         (o_uart_tx)
    );
endmodule
