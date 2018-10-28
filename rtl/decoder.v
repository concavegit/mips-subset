/*
 * @module decoder
 */

module decoder
  (
   output [25:0]    jAddr,
   output [4:0]     rd,
                    rt,
                    rs,
   output reg [4:0] regWAddr,
   output reg [2:0] op,
   output reg [1:0] pcSrcCtrl,
                    regDInCtrl,
   output reg       regWe,
                    dmWe,
   output           aluBSrcCtrl,
   output [31:0]    imm,
   input [31:0]     instr
   );

   wire [5:0]       opcode, funct;


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

   assign
     funct = instr[5:0],
     rd = instr[15:11],
     rt = instr[20:16],
     rs = instr[25:21],
     opcode = instr[31:26],
     jAddr = instr[25:0],
     imm = {{16{instr[15]}}, instr[15:0]},
     aluBSrcCtrl = opcode == RTYPE ? ALU_B_REG : ALU_B_IMM;

   always @(opcode) begin
      case (opcode)
        LW: begin
           regWe = 1;
           op = ADD;
           pcSrcCtrl = PC_INC4;
           regDInCtrl = REG_DIN_ALU;
           dmWe = 0;
           regWAddr = rt;
        end

        SW: begin
           regWe = 0;
           op = ADD;
           pcSrcCtrl = PC_INC4;
           regDInCtrl = REG_DIN_ALU;
           dmWe = 1;
           regWAddr = rt;
        end

        J: begin
           regWe = 0;
           op = ADD;
           pcSrcCtrl = PC_J;
           dmWe = 0;
           regWAddr = rt;
        end

        JAL: begin
           regWe = 1;
           op = ADD;
           pcSrcCtrl = PC_J;
           dmWe = 0;
           regWAddr = 31;
        end

        BNE: begin
           regWe = 0;
           op = SUB;
           pcSrcCtrl = PC_BNE;
           dmWe = 0;
           regWAddr = rt;
        end

        XORI: begin
           regWe = 1;
           op = XOR;
           pcSrcCtrl = PC_INC4;
           dmWe = 0;
           regWAddr = rt;
        end

        ADDI: begin
           regWe = 1;
           op = ADD;
           pcSrcCtrl = PC_INC4;
           dmWe = 0;
           regWAddr = rt;
        end

        RTYPE: begin
           regWAddr = rd;
           dmWe = 0;

           case (funct)
             R_JR: begin
                regWe = 0;
                op = ADD;
                pcSrcCtrl = PC_J;
             end

             R_ADD: begin
                regWe = 1;
                op = ADD;
                pcSrcCtrl = PC_INC4;
             end

             R_SUB: begin
                regWe = 1;
                op = SUB;
                pcSrcCtrl = PC_INC4;
             end

             R_SLT: begin
                regWe = 1;
                op = SLT;
                pcSrcCtrl = PC_INC4;
             end

             default: begin
                regWe = 0;
                op = ADD;
                pcSrcCtrl = PC_INC4;
             end
           endcase
        end

        default: begin
           regWe = 0;
           op = ADD;
           pcSrcCtrl = PC_INC4;
           dmWe = 0;
        end

      endcase
   end
endmodule
