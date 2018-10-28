`include "alu.v"
`include "decoder.v"
`include "memory.v"
`include "regfile.v"
`include "mux.v"
`include "mux4way.v"

module cpu
  (input clk);

   // Decoder Pins
   wire [25:0] jAddr;
   wire [4:0]  rd, rt, rs, regWAddr;
   wire [2:0]  op;
   wire [1:0]  pcSrcCtrl, regDInCtrl;
   wire        regWe, dmWe, aluBSrcCtrl;
   wire [31:0] imm, instr;

   decoder decoder0
     (
      .jAddr(jAddr),
      .rd(rd),
      .rt(rt),
      .rs(rs),
      .op(op),
      .pcSrcCtrl(pcSrcCtrl),
      .regDInCtrl(regDInCtrl),
      .regWAddr(regWAddr),
      .regWe(regWe),
      .dmWe(dmWe),
      .aluBSrcCtrl(aluBSrcCtrl),
      .imm(imm),
      .instr(instr)
      );

   // Regfile pins
   wire [31:0] regAOut, regBOut, regDIn;

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

   // ALU pins
   wire [31:0] aluOut;
   wire        aluZero;
   wire        aluBSrc;

   alu alu0
     (
      .result(aluOut),
      .zero(aluZero),
      .operandA(regAOut),
      .operandB(aluBSrc),
      .command(op)
      );

   // DataMemory pins
   wire [31:0] dmOut;

   memory dataMemory
     (
      .dOut(dmOut),
      .clk(clk),
      .addr(aluOut),
      .we(dmWe),
      .dIn(regBOut)
      );

   // Instruction Memory
   wire [31:0] pcSrc;

   memory instructionMemory
     (
      .dOut(instr),
      .clk(clk),
      .addr(pcSrc),
      .we(0),
      .dIn(0)
      );

   // AluBSrcCtrl
   mux mux0
     (
      .out(aluBSrc),
      .sel(aluBSrcCtrl),
      .in0(regBOut),
      .in1(imm)
      );

   // BNE
   wire [31:0] bne, bneAddr, pcNext;

   assign bneAddr = pcSrc + imm;
   assign pcNext = pcSrc + 4;

   mux mux1
     (
      .out(bne),
      .sel(aluZero),
      .in0(bneAddr),
      .in1(pcNext)
      );

   wire [31:0] extJAddr;
   assign extJAddr = {pcSrc[31:28], jAddr, 2'b0};

   // Choose what the next instruction should be
   mux4way mux2
     (
      .out(pcSrc),
      .sel(pcSrcCtrl),
      .in0(pcNext),
      .in1(extJAddr),
      .in2(regAOut),
      .in3(bne)
      );
   // Choose what data to write to regfile
   mux4way mux3
     (
      .out(regDIn),
      .sel(regDInCtrl),
      .in0(aluOut),
      .in1(dmOut),
      .in2(pcNext),
      .in3(0)
      );

endmodule
