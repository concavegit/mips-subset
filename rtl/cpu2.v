`include "alu.v"
`include "decoder.v"
`include "memory.v"
`include "regfile.v"
`include "mux.v"
`include "mux4way.v"

module cpu2 (input clk);
   reg [31:0]  pc, pcInc;
   wire        pcSrcCtrl;
   wire [25:0] jAddr26;
   wire [31:0] jAddr, regAOut, bneRes;

   initial pc = 0;
   always @(pc) pcInc = pcInc + 4;
   always @(jAddr26, pc) jAddr = {pc, jAddr, 2'b0};

   always @(posedge(clk))
     case (pcSrcCtrl)
       0: pc = pcInc;
       1: pc = jAddr;
       2: pc = regAOut;
       3: pc = bneRes;
     endcase

   wire [4:0]  rd, rt, rs, regWAddr;
   wire [2:0]  op;
   wire [1:0]  pcSrcCtrl, regDInCtrl;
   wire        regWe, dmWe, aluSrcCtrl, bneCtrl;
   wire [31:0] imm, instr;

   decoder decoder0
     (
      .jAddr(jAddr26),
      .rd(rd),
      .rt(rt),
      .rs(rs),
      .op(op),
      .pcSrcCtrl(pcSrcCtrl),
      .regDInCtrl(regDInCtrl),
      .regWAddr(regWAddr),
      .regWe(regWe),
      .dmWe(dmWe),
      .bneCtrl(bneCtrl),
      .aluBSrcCtrl(aluBSrcCtrl),
      .imm(imm),
      .instr(instr)
      );

   wire [31:0] regBOut, regDIn;

   regfile regfile0
     (
      .ReadData1(regAOut),
      .ReadData2(regBOut),
      .WriteData(regDIn),
      .ReadRegister1(rs),
      .ReadRegister2(rt),
      .WriteRegister(regWAddr),
      .RegWrite(regWe),
      .Clk(clk)
      );

   wire [31:0] aluOut, aluBSrc;
   wire        aluZero, aluOverflow;

   alu alu0
     (
      .result(aluOut),
      .zero(aluZero),
      .overflow(aluOverflow),
      .operandA(regAOut),
      .operandB(aluBSrc),
      .command(op)
      );

   memory #(.data("mem/instructions.dat")) mem
     (
      .dOut(instr),
      .instrOut(instr),
      .instrAddr(pc),
      .clk(clk),
      .addr(pcSrc),
      .we(1'b0),
      .dIn(0)
      );

   mux aluBMux
     (
      .out(aluBSrc),
      .sel(aluBSrcCtrl),
      .in0(regBOut),
      .in1(imm)
      );

   wire        bneMuxCtrl;
   xor (bneMuxCtrl, bneCtrl, aluZero);

   always @(pc, imm) bneAddr = pc + (imm << 2);

   wire [31:0] bneRes;

   mux bneMux
     (
      .out(bneRes),
      .sel(bneMuxCtrl),
      .in0(bneAddr),
      .in1(pcInc)
      );

   wire [31:0] pcNext;

   mux regMux
     (
      .out(regDIn),
      .sel(regDInCtrl),
      .in0(aluOut),
      .in1(dmOut),
      .in2(pcNext),
      .in3(0)
      );
endmodule
