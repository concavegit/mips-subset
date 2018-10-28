/*
 * @module decoder
 */

module decoder
  (
   output [4:0]  rd,
                 rt,
                 rs,
   output [2:0]  op,
   output [1:0]  pcSrc,
                 regDIn,
                 regWAddr,
   output        regWe,
                 dmWe,
                 aluBSrc,
   output [25:0] jAddr,
   output [31:0] imm,
   input [31:0]  instr
   );

   wire [5:0]    opcode, funct;

   assign
     funct = instr[5:0],
     rd = instr[15:11],
     rt = instr[20:16],
     rs = instr[25:21],
     opcode = instr[31:26],
     jAddr = instr[25:0],
     imm = {{16{instr[15]}}, instr[15:0]};

   localparam
     LW = 6'h23,
     SW = 6'h2b,
     J = 6'h2,
     JAL = 6'h3,
     BNE = 6'h5,
     XORI = 6'he,
     ADDI = 6'h8,
     RTYPE = 6'h0,

     R_JR = 6'h8,
     R_ADD = 6'h0,
     R_SUB = 6'h22,
     R_SLT = 6'h2a,

     PC_INC4 = 2'h0,
     PC_J = 2'h1,
     PC_JR = 2'h2,
     PC_BNE = 2'h3,

     ALU_B_REG = 1'b0,
     ALU_B_IMM = 1'b1,

     REG_WADDR_RD = 2'h0,
     REG_WADDR_RT = 2'h1,
     REG_WADDR_31 = 2'h2,

     REG_DIN_ALU = 2'h0,
     REG_DIN_DM = 2'h1,
     REG_DIN_JAL = 2'h2,

     ADD = 3'h0,
     SUB = 3'h1,
     XOR = 3'h2,
     SLT = 3'h3,
     AND = 3'h4,
     NAND = 3'h5,
     NOR = 3'h6,
     OR = 3'h7;

   always @(opcode) begin
      case (opcode)
        LW: begin
           regWe = 1;
           op = ADD;
           pcSrc = PC_INC4;
           regDIn = REG_DIN_ALU;
           dmWe = 0;
           aluBSrc = ALU_B_IMM;
           regWAddr = REG_WADDR_RT;
        end

        SW: begin
           regWe = 0;
           op = ADD;
           pcSrc = PC_INC4;
           regDIn = REG_DIN_ALU;
           dmWe = 1;
           aluBSrc = ALU_B_IMM;
           regWAddr = REG_WADDR_RT;
        end

        J: begin
           regWe = 0;
           op = ADD;
           pcSrc = PC_J;
           dmWe = 0;
           aluBSrc = ALU_B_IMM;
           regWAddr = REG_WADDR_RT;
        end

        JAL: begin
           regWe = 1;
           op = ADD;
           pcSrc = PC_J;
           dmWe = 0;
           aluBSrc = ALU_B_IMM;
           regWAddr = REG_WADDR_31;
        end

        BNE: begin
           regWe = 0;
           op = SUB;
           pcSrc = PC_BNE;
           dmWe = 0;
           aluBSrc = ALU_B_IMM;
           regWAddr = REG_WADDR_RT;
        end

        XORI: begin
           regWe = 1;
           op = XOR;
           pcSrc = PC_INC4;
           dmWe = 0;
           aluBSrc = ALU_B_IMM;
           // regWAddr = REG_WADDR_RT;
        end

        ADDI: begin
           regWe = 1;
           op = ADD;
           pcSrc = PC_INC4;
           dmWe = 0;
           aluBSrc = ALU_B_IMM;
           regWAddr = REG_WADDR_RT;
        end

        RTYPE: begin
           regWAddr = REG_WADDR_RD;
           aluBSrc = ALU_B_REG;
           case (funct)
             R_JR: begin
                regWe = 0;
                op = ADD;
                pcSrc = PC_INC4;
                dmWe = 0;
             end

             R_ADD: begin
                regWe = 1;
                op = ADD;
                pcSrc = PC_INC4;
                dmWe = 0;
             end

             R_SUB: begin
                regWe = 1;
                op = SUB;
                pcSrc = PC_INC4;
                dmWe = 0;
             end

             R_SLT: begin
                regWe = 1;
                op = SLT;
                pcSrc = PC_INC4;
                dmWe = 0;
             end

             default: begin
                regWe = 0;
                op = ADD;
                pcSrc = PC_INC4;
                dmWe = 0;
             end
           endcase
        end

        default: begin
           regWe = 0;
           op = ADD;
           pcSrc = PC_INC4;
           dmWe = 0;
           aluBSrc = ALU_B_IMM;
        end

      endcase
   end
endmodule
