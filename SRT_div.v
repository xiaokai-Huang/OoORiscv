`include "defines.vh"

`timescale 1ns / 1ps

module SRT_div (
    input           clk,
    input           rst_n,
    input           start,
    input           signed_div,    // 有符号除法标志
    input  [31:0]   dividend,      // 被除数
    input  [31:0]   divisor,       // 除数
    output [31:0]   quotient,      // 商
    output [31:0]   remainder,     // 余数
    output          ready_for_wakeup,
    output          done
    // output          busy
);

    parameter IDLE = 2'b00;
    parameter RUN  = 2'b01;
    parameter FIX  = 2'b10;

    reg [1:0]   state, state_n;
    reg [31:0]  dvd_reg;    // 被除数寄存器存储绝对值
    reg [31:0]  dvs_reg;    // 除数寄存器存储绝对值
    // reg         sgn_reg;
    reg [4:0]   cnt;

    // 37位宽：防止溢出
    // bit[36:34] : 符号与溢出保护 (3位)
    // bit[33:1]  : 32位整数数据
    // bit[0]     : 定点小数位 (Scale=2, 恒为0)
    reg signed [36:0] rem;
    reg [31:0]  q_pos, q_neg;   // 正商与负商

    wire        dvd_sign     = signed_div & dividend[31];
    wire        dvs_sign     = signed_div & divisor[31];
    wire [31:0] dvd_abs      = dvd_sign ? (~dividend + 1'b1) : dividend;
    wire [31:0] dvs_abs      = dvs_sign ? (~divisor + 1'b1) : divisor;
    wire        q_final_sign = dvd_sign ^ dvs_sign;
    wire        r_final_sign = dvd_sign;
    wire        div_zero     = (divisor == 32'd0);

    // --- 定点化扩展 (Scale = 2) ---
    // dvs_ext = 2 * D
    reg signed [36:0] dvs_ext;

    reg signed [36:0] rem_sh, rem_step;
    reg               q_pos_sel;          // 1: 减除数, 0: 加除数
    reg [31:0] q_pos_next, q_neg_next;
    reg [31:0] dvd_next; 

    always @(*) begin
        // 默认值
        rem_step = rem;
        q_pos_next = q_pos; 
        q_neg_next = q_neg;
        dvd_next = dvd_reg << 1;

        // 移入被除数的高1位。
        // 35'b0 + 1位数据 + 1'b0 = 37位
        rem_sh = (rem <<< 1) | {35'b0, dvd_reg[31], 1'b0};

        // 不恢复余数法：符号位决定加减
        q_pos_sel = ~rem_sh[36];

        // 更新余数
        rem_step = q_pos_sel ? (rem_sh - dvs_ext) : (rem_sh + dvs_ext);

        // 更新商（每周期移入1位）
        q_pos_next = {q_pos[30:0], 1'b0};
        q_neg_next = {q_neg[30:0], 1'b0};

        q_pos_next[0] =  q_pos_sel;
        q_neg_next[0] = ~q_pos_sel;

    end

    // 时序逻辑
    always @(posedge clk) begin
        if (!rst_n) begin
            state   <= IDLE;
            dvd_reg <= 0; 
            dvs_reg <= 0;
            dvs_ext <= 0;
            // sgn_reg <= 0;
            rem     <= 0; 
            q_pos   <= 0; 
            q_neg   <= 0; 
            cnt     <= 0;
        end 
        else begin
            state <= state_n;
            case (state)
                IDLE: begin
                    if (start) begin
                        dvd_reg <= dvd_abs;
                        dvs_reg <= dvs_abs;
                        dvs_ext <= {3'b0, dvs_abs, 1'b0};      // 2 * D
                        // sgn_reg <= signed_div;
                        rem     <= 0;
                        q_pos   <= 0; 
                        q_neg   <= 0; 
                        cnt     <= 0;
                    end
                end
                RUN: begin
                    rem     <= rem_step;
                    q_pos   <= q_pos_next;
                    q_neg   <= q_neg_next;
                    dvd_reg <= dvd_next;
                    cnt     <= cnt + 1'b1;
                end
                FIX: ;
            endcase
        end
    end

    always @(*) begin
        state_n = state;
        case (state)
            IDLE: if (start) state_n = RUN;
            RUN: begin
                if (~start) state_n = IDLE;
                else if (cnt == 5'd31) state_n = FIX;
            end
            FIX:  state_n = IDLE;
            default: state_n = IDLE;
        endcase
    end

    assign ready_for_wakeup = (state == RUN) && (cnt == 5'd31);

    // 输出逻辑
    reg [31:0] q_raw, r_raw;
    always @(*) begin
        q_raw = q_pos - q_neg;
        
        // 还原余数：Scale=2，所以舍弃低1位
        // rem[33:1] 对应 32位整数
        r_raw = rem[33:1]; 

        // 修正逻辑：如果余数是负数，加回除数
        if (rem[36] == 1'b1) begin
            r_raw = r_raw + dvs_reg;
            q_raw = q_raw - 1'b1;
        end
    end

    assign quotient  = div_zero ? 32'hFFFF_FFFF : (q_final_sign ? (~q_raw + 1'b1) : q_raw);
    assign remainder = div_zero ? dividend     : (r_final_sign ? (~r_raw + 1'b1) : r_raw);
    assign done      = (state == FIX);
    // assign busy      = (state != IDLE);

endmodule