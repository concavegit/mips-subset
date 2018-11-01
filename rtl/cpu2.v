`include "alu.v"
`include "decoder.v"
`include "memory.v"
`include "regfile.v"
`include "mux.v"
`include "mux4way.v"

module cpu2 #(parameter mem="mem/mips1.dat") (input clk);
   reg [31:0]  pc, pcInc;
   wire [1:0]  pcSrcCtrl;
   wire [25:0] jAddr26;
   reg [31:0]  jAddr;
   wire [31:0] regAOut, bneRes;

   initial pc = 0;
   always @(pc) pcInc = pc + 4;
   always @(jAddr26, pc) jAddr = {pc[31:28], jAddr26, 2'b0};

   always @(posedge(clk))
     case (pcSrcCtrl)
       0: pc <= pcInc;
       1: pc <= jAddr;
       2: pc <= regAOut;
       3: pc <= bneRes;
     endcase

   wire [4:0]  rd, rt, rs, regWAddr;
   wire [2:0]  op;
   wire [1:0]  regDInCtrl;
   wire        regWe, dmWe, bneCtrl;
   wire [31:0] imm, instr;
   wire        aluBSrcCtrl;

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

   wire [31:0] dmOut;
   memory #(.data(mem)) mem0
     (
      .dOut(dmOut),
      .instrOut(instr),
      .instrAddr(pc),
      .clk(clk),
      .addr(aluOut),
      .we(dmWe),
      .dIn(regBOut)
      );

   mux aluBMux
     (
      .out(aluBSrc),
      .sel(aluBSrcCtrl),
      .in0(regBOut),
      .in1(imm)
      );

   wire        bneMuxCtrl;
   wire        aluOverflowInv;       
   not (aluOverflowInv, aluOverflow);

   wire        notOverflowAndZero;       
   and (notOverflowAndZero, aluOverflowInv, aluZero);

   xor (bneMuxCtrl, bneCtrl, notOverflowAndZero);
   reg [31:0]  bneAddr;

   always @(pc, imm) bneAddr = pc + (imm << 2);

   mux bneMux
     (
      .out(bneRes),
      .sel(bneMuxCtrl),
      .in0(bneAddr),
      .in1(pcInc)
      );

   mux4way regMux
     (
      .out(regDIn),
      .sel(regDInCtrl),
      .in0(aluOut),
      .in1(dmOut),
      .in2(pcInc),
      .in3(0)
      );
endmodule
