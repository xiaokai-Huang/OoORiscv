`ifndef HEAD
`define HEAD

`timescale 1ns / 1ps

// `define DEBUG
`define use_m_extension
`define use_f_extension


// RV32IM
`define INST_LUI      7'b0110111     // 加载立即数到高位
`define INST_AUIPC    7'b0010111     // 向PC高位加上立即数

// J type
`define INST_JAL      7'b1101111
`define INST_JALR     7'b1100111

// B type
`define INST_TYPE_B   7'b1100011
`define INST_BEQ      3'b000
`define INST_BNE      3'b001
`define INST_BLT      3'b100
`define INST_BGE      3'b101
`define INST_BLTU     3'b110
`define INST_BGEU     3'b111

// L type
`define INST_TYPE_L   7'b0000011
`define INST_LB       3'b000
`define INST_LH       3'b001
`define INST_LW       3'b010
`define INST_LBU      3'b100
`define INST_LHU      3'b101

// S type
`define INST_TYPE_S   7'b0100011
`define INST_SB       3'b000
`define INST_SH       3'b001
`define INST_SW       3'b010

// I type 
`define INST_TYPE_I   7'b0010011
`define INST_ADDI     3'b000
`define INST_SLTI     3'b010
`define INST_SLTIU    3'b011
`define INST_XORI     3'b100
`define INST_ORI      3'b110
`define INST_ANDI     3'b111
`define INST_SLLI     3'b001
`define INST_SRI      3'b101          //算术右移SRAI和逻辑右移SRLI的funct3相同，需要在执行阶段通过funct7，即inst[30]来判断

// R type 
`define INST_TYPE_R   7'b0110011
`define INST_ADD_SUB  3'b000          //加法和减法的funct3也相同，需要根据inst[30]进一步判断
`define INST_SLL      3'b001
`define INST_SLT      3'b010
`define INST_SLTU     3'b011
`define INST_XOR      3'b100
`define INST_SR       3'b101          //右移包括算数右移和逻辑右移，同上
`define INST_OR       3'b110
`define INST_AND      3'b111
// M extension(M扩展的opcode与R类型相同)
`define INST_MUL    3'b000
`define INST_MULH   3'b001
`define INST_MULHSU 3'b010
`define INST_MULHU  3'b011
`define INST_DIV    3'b100
`define INST_DIVU   3'b101
`define INST_REM    3'b110
`define INST_REMU   3'b111


`define INST_NOP      32'h0000_0013      //空操作，用ADDI指令对x0寄存器加0，无效操作

// CSR inst
`define INST_CSR      7'b1110011
`define INST_CSRRW    3'b001
`define INST_CSRRS    3'b010
`define INST_CSRRC    3'b011
`define INST_CSRRWI   3'b101
`define INST_CSRRSI   3'b110
`define INST_CSRRCI   3'b111

// CSR reg addr
`define CSR_CYCLE    12'hc00
`define CSR_CYCLEH   12'hc80
`define CSR_MTVEC    12'h305
`define CSR_MCAUSE   12'h342
`define CSR_MEPC     12'h341
`define CSR_MIE      12'h304
`define CSR_MSTATUS  12'h300
`define CSR_MSCRATCH 12'h340
`define CSR_MIP      12'h344

`define INST_FENCE  7'b0001111
`define INST_ECALL  32'h73
`define INST_EBREAK 32'h0010_0073
`define INST_MRET   32'h3020_0073


// RV32F
// opcode
`define INST_TYPE_FL   7'b0000111     // FLW浮点加载指令opcode
`define INST_TYPE_FS   7'b0100111     // FSW浮点存储指令opcode
`define INST_FMADD     7'b1000011     // FMADD.S浮点融合乘加指令opcode
`define INST_FMSUB     7'b1000111     // FMSUB.S浮点融合乘减指令opcode
`define INST_FNMSUB    7'b1001011     // FNMSUB.S浮点负融合乘减指令opcode
`define INST_FNMADD    7'b1001111     // FNMADD.S浮点负融合乘加指令opcode
`define INST_TYPE_F    7'b1010011     // 普通RV32F浮点运算指令opcode

// funct3 / rm
`define INST_FLW       3'b010          // FLW浮点加载指令funct3
`define INST_FSW       3'b010          // FSW浮点存储指令funct3
`define INST_FSGNJ     3'b000          // FSGNJ.S浮点符号注入指令funct3
`define INST_FSGNJN    3'b001          // FSGNJN.S浮点取反符号注入指令funct3
`define INST_FSGNJX    3'b010          // FSGNJX.S浮点异或符号注入指令funct3
`define INST_FMIN      3'b000          // FMIN.S浮点最小值指令funct3
`define INST_FMAX      3'b001          // FMAX.S浮点最大值指令funct3
`define INST_FLE       3'b000          // FLE.S浮点小于等于比较指令funct3
`define INST_FLT       3'b001          // FLT.S浮点小于比较指令funct3
`define INST_FEQ       3'b010          // FEQ.S浮点相等比较指令funct3
`define INST_FMV_X_W   3'b000          // FMV.X.W浮点到整数搬运指令funct3
`define INST_FCLASS    3'b001          // FCLASS.S浮点分类指令funct3
`define INST_FMV_W_X   3'b000          // FMV.W.X整数到浮点搬运指令funct3

`define INST_RM_RNE    3'b000          // 浮点舍入模式RNE
`define INST_RM_RTZ    3'b001          // 浮点舍入模式RTZ
`define INST_RM_RDN    3'b010          // 浮点舍入模式RDN
`define INST_RM_RUP    3'b011          // 浮点舍入模式RUP
`define INST_RM_RMM    3'b100          // 浮点舍入模式RMM
`define INST_RM_DYN    3'b111          // 浮点舍入模式DYN

// funct7
`define INST_FADD_S         7'b0000000   // FADD.S浮点加法指令funct7
`define INST_FSUB_S         7'b0000100   // FSUB.S浮点减法指令funct7
`define INST_FMUL_S         7'b0001000   // FMUL.S浮点乘法指令funct7
`define INST_FDIV_S         7'b0001100   // FDIV.S浮点除法指令funct7
`define INST_FSGNJ_S        7'b0010000   // FSGNJ.S/FSGNJN.S/FSGNJX.S浮点符号注入指令funct7
`define INST_FMIN_MAX_S     7'b0010100   // FMIN.S/FMAX.S浮点最值指令funct7
`define INST_FSQRT_S        7'b0101100   // FSQRT.S浮点平方根指令funct7
`define INST_FCMP_S         7'b1010000   // FEQ.S/FLT.S/FLE.S浮点比较指令funct7
`define INST_FCVT_W_S       7'b1100000   // FCVT.W.S/FCVT.WU.S浮点转整数指令funct7
`define INST_FCVT_S_W       7'b1101000   // FCVT.S.W/FCVT.S.WU整数转浮点指令funct7
`define INST_FMV_X_W_CLASS  7'b1110000   // FMV.X.W/FCLASS.S浮点到整数搬运或分类指令funct7
`define INST_FMV_W_X_F7     7'b1111000   // FMV.W.X整数到浮点搬运指令funct7

// rs2 field
`define INST_F_RS2_W        5'b00000     // FCVT中表示有符号32位整数W
`define INST_F_RS2_WU       5'b00001     // FCVT中表示无符号32位整数WU


// B_type_ex_function
`define BRANCH_EX_LOGIC(condition) \
    branch_taken = condition; \
    if(condition && br_bpu_pre_addr_i == br_aux_addr_i) begin \
        jump_flag_o = 1'b0; \
        jump_addr_o = 32'h0; \
    end \
    else if(br_bpu_pre_flag_i && !condition) begin \
        jump_flag_o = 1'b1; \
        jump_addr_o = {16'h8000, br_inst_addr_i} + 32'h4; \
    end \
    else begin \
        jump_flag_o = condition; \
        jump_addr_o = br_aux_addr_i; \
    end \
    btb_update_en = (condition && br_bpu_pre_addr_i != br_aux_addr_i);

// read_reg function
`ifdef use_m_extension
    `define read_reg(raddr, rdata) \
        if (raddr == 6'b0) \
            rdata = 32'b0; \
        else if (alu0_wflag_i && (alu0_waddr_i == raddr)) \
            rdata = alu0_wdata_i; \
        else if (alu1_wflag_i && (alu1_waddr_i == raddr)) \
            rdata = alu1_wdata_i; \
        else if (branch_wflag_i && (branch_waddr_i == raddr)) \
            rdata = branch_wdata_i; \
        else if (mem_wflag_i && (mem_waddr_i == raddr)) \
            rdata = mem_wdata_i; \
        else if (mul_wflag_i && (mul_waddr_i == raddr)) \
            rdata = mul_wdata_i; \
        else if (div_wflag_i && (div_waddr_i == raddr)) \
            rdata = div_wdata_i; \
        else \
            rdata = regs[raddr];
`else
    `define read_reg(raddr, rdata) \
        if (raddr == 6'b0) \
            rdata = 32'b0; \
        else if (alu0_wflag_i && (alu0_waddr_i == raddr)) \
            rdata = alu0_wdata_i; \
        else if (alu1_wflag_i && (alu1_waddr_i == raddr)) \
            rdata = alu1_wdata_i; \
        else if (branch_wflag_i && (branch_waddr_i == raddr)) \
            rdata = branch_wdata_i; \
        else if (mem_wflag_i && (mem_waddr_i == raddr)) \
            rdata = mem_wdata_i; \
        else \
            rdata = regs[raddr];
`endif


// μOp
// 1. 指令大类 (Inst Type) - 用于 Dispatch 路由
`define TYPE_ALU    3'd0      // 整数运算 (包含 LUI, AUIPC)
`define TYPE_MEM    3'd1      // 访存 (Load/Store)
`define TYPE_BR     3'd2      // 分支 (Branch)
`define TYPE_JAL    3'd3      // 跳转 (JAL/JALR)
`define TYPE_CSR    3'd4      // 系统指令 (CSR)
`define TYPE_M_EXT  3'd5      // 乘除法 (M Extension)
`define TYPE_F_EXT  3'd6      // 浮点指令 (F Extension)

// 2. 执行子码 
// --- TYPE_ALU 子码 ---
`define ALU_ADD     4'd0
`define ALU_SUB     4'd1
`define ALU_AND     4'd2
`define ALU_OR      4'd3
`define ALU_XOR     4'd4
`define ALU_SLL     4'd5
`define ALU_SRL     4'd6
`define ALU_SRA     4'd7
`define ALU_SLT     4'd8
`define ALU_SLTU    4'd9
`define ALU_LUI     4'd10
`define ALU_AUIPC   4'd11

// --- TYPE_MEM (LSU) 子码 ---
// Bit 3: Store/Load (1=Store)
// Bit 2: Unsigned/Signed (1=Unsigned) -- 针对 LB/LH  |  Float/Integer (1=Float) -- 针对 word operations (LW/SW)
// Bit 1:0: Size (0=Byte, 1=Half, 2=Word)
`define MEM_LB      4'd0  // 0000
`define MEM_LH      4'd1  // 0001
`define MEM_LW      4'd2  // 0010

`define MEM_LBU     4'd4  // 0100
`define MEM_LHU     4'd5  // 0101
`define MEM_FLW     4'd6  // 0110 浮点字加载FLW

`define MEM_SB      4'd8  // 1000
`define MEM_SH      4'd9  // 1001
`define MEM_SW      4'd10 // 1010
`define MEM_FSW     4'd14 // 1110 浮点字存储FSW

// --- TYPE_BR (Branch) 子码 ---
`define BR_EQ       4'd0
`define BR_NE       4'd1
`define BR_LT       4'd2
`define BR_GE       4'd3
`define BR_LTU      4'd4
`define BR_GEU      4'd5

// --- TYPE_JAL 子码 ---
`define JUMP_JAL    4'd0
`define JUMP_JALR   4'd1

// --- TYPE_M_EXT (Mul/Div) 子码 ---
`define M_MUL       4'd0
`define M_MULH      4'd1
`define M_MULHSU    4'd2
`define M_MULHU     4'd3
`define M_DIV       4'd4
`define M_DIVU      4'd5
`define M_REM       4'd6
`define M_REMU      4'd7

// --- TYPE_CSR 子码 ---
`define CSR_RW      4'd0  // CSRRW, CSRRWI
`define CSR_RS      4'd1  // CSRRS, CSRRSI
`define CSR_RC      4'd2  // CSRRC, CSRRCI
`define CSR_MRET    4'd3
`define CSR_ECALL   4'd4
`define CSR_EBREAK  4'd5
`define CSR_FENCE   4'd6

// --- TYPE_F_EXT (Float) 子码 ---
// FLW/FSW复用TYPE_MEM，分别使用MEM_FLW/MEM_FSW
`define F_FMADD_S   5'd0  // FMADD.S浮点融合乘加
`define F_FMSUB_S   5'd1  // FMSUB.S浮点融合乘减
`define F_FNMSUB_S  5'd2  // FNMSUB.S浮点负融合乘减
`define F_FNMADD_S  5'd3  // FNMADD.S浮点负融合乘加
`define F_FADD_S    5'd4  // FADD.S浮点加法
`define F_FSUB_S    5'd5  // FSUB.S浮点减法
`define F_FMUL_S    5'd6  // FMUL.S浮点乘法
`define F_FDIV_S    5'd7  // FDIV.S浮点除法
`define F_FSQRT_S   5'd8  // FSQRT.S浮点平方根
`define F_FSGNJ_S   5'd9  // FSGNJ.S浮点符号注入
`define F_FSGNJN_S  5'd10 // FSGNJN.S浮点取反符号注入
`define F_FSGNJX_S  5'd11 // FSGNJX.S浮点异或符号注入
`define F_FMIN_S    5'd12 // FMIN.S浮点最小值
`define F_FMAX_S    5'd13 // FMAX.S浮点最大值
`define F_FCVT_W_S  5'd14 // FCVT.W.S浮点转有符号整数
`define F_FCVT_WU_S 5'd15 // FCVT.WU.S浮点转无符号整数
`define F_FMV_X_W   5'd16 // FMV.X.W浮点位模式搬到整数
`define F_FEQ_S     5'd17 // FEQ.S浮点相等比较
`define F_FLT_S     5'd18 // FLT.S浮点小于比较
`define F_FLE_S     5'd19 // FLE.S浮点小于等于比较
`define F_FCLASS_S  5'd20 // FCLASS.S浮点分类
`define F_FCVT_S_W  5'd21 // FCVT.S.W有符号整数转浮点
`define F_FCVT_S_WU 5'd22 // FCVT.S.WU无符号整数转浮点
`define F_FMV_W_X   5'd23 // FMV.W.X整数位模式搬到浮点

// 3. 操作数来源选择 (Operand Select)
`define OP1_REG     2'd0
`define OP1_PC      2'd1  // 用于 AUIPC, JAL, Branch (PC)
`define OP1_CSR     2'd2  // CSR 旧值作为源操作数
`define OP1_ZERO    2'd3  // 用于 LUI (0)

`define OP2_REG     2'd0
`define OP2_IMM     2'd1  // 用于 I-Type, S-Type (Immediate)
`define OP2_4       2'd2  // 用于 JAL/JALR 保存 PC + 4 到 rd





`endif