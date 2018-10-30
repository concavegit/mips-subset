//------------------------------------------------------------------------------
// Test harness validates hw4testbench by connecting it to various functional 
// or broken register files, and verifying that it correctly identifies each
//------------------------------------------------------------------------------

`include "../rtl/decoder.v"

module decodertestbenchharness();

  wire[25:0]	jAddr;
  wire[4:0]	rd,
            rt,
            rs,
            regWAddr;
  wire[2:0] op;
  wire[1:0] pcSrcCtrl,
            regDInCtrl;
  wire      regWe,
            dmWe,
            aluBSrcCtrl,
            bneCtrl;
  wire[31:0]      imm;
  reg [31:0] instr;
  reg		begintest;	// Set High to begin testing register file
  wire  	endtest;    	// Set High to signal test completion 
  wire		dutpassed;	// Indicates whether register file passed tests

  // Instantiate the register file being tested.  DUT = Device Under Test
  decoder DUT
  (
    .jAddr(jAddr),
    .rd(rd),
    .rt(rt),
    .rs(rs),
    .regWAddr(regWAddr),
    .op(op),
    .pcSrcCtrl(pcSrcCtrl),
    .regDInCtrl(regDInCtrl),
    .regWe(regWe),
    .dmWe(dmWe),
    .bneCtrl(bneCtrl),
    .aluBSrcCtrl(aluBSrcCtrl),
    .imm(imm),
    .instr(instr)
  );

//  $dumpfile("decoder.vcd");
//  $dumpvars();
  
  // Test harness asserts 'begintest' for 1000 time steps, starting at time 10
  initial begin
    instr=32'b0;
    #10
    $display("%b", instr);
    #10
    instr={6'd2, 26'd231435};
    #10
    $display("%b", instr);
    #10
    instr={6'h23, 26'd23342};
    #10
    if ((op !== 0) || (pcSrcCtrl !== 0) || (regWe !== 1) || (aluBSrcCtrl !== 1)
         || (dmWe !== 0) || (regDInCtrl !== 0) || (bneCtrl !== 0)) begin
      $display("Test Case 1 (LW) Failed");
    end
    
    instr={6'h2b, 26'd34192};
    #10
    if ((op !== 0) || (pcSrcCtrl !== 0) || (regWe !== 0) || (aluBSrcCtrl !== 1)
         || (dmWe !== 1) || (bneCtrl !== 0)) begin
      $display("Test Case 2 (SW) Failed");
    end
    
    instr={6'h2, 26'd9932992};
    #10
    if ((op !== 0) || (pcSrcCtrl !== 1) || (regWe !== 0) || (aluBSrcCtrl !== 1)
         || (dmWe !== 0) || (bneCtrl !== 0)) begin
      $display("Test Case 3 (J) Failed");
    end
    
    instr={6'h0, 20'd29992, 6'h8};
    #10
    if ((op !== 0) || (pcSrcCtrl !== 2) || (regWe !== 0) || (aluBSrcCtrl !== 0)
         || (dmWe !== 0) || (bneCtrl !== 0)) begin
      $display("Test Case 4 (JR) Failed");
    end
    
    instr={6'h3, 20'd29934, 6'h12};
    #10
    if ((op !== 0) || (pcSrcCtrl !== 1) || (regWe !== 1) || (aluBSrcCtrl !== 1)
         || (dmWe !== 0) || (regWAddr !== 31)|| (bneCtrl !== 0)) begin
      $display("Test Case 5 (JAL) Failed");
    end
    
    instr={6'h4, 20'd2921, 6'h8};
    #10
    if ((op !== 1) || (pcSrcCtrl !== 3) || (regWe !== 0) || (aluBSrcCtrl !== 1)
         || (dmWe !== 0) || (bneCtrl !== 0)) begin
      $display("Test Case 6 (BEQ) Failed, %b", aluBSrcCtrl);
    end
    
    instr={6'h5, 20'd2291, 6'h1};
    #10
    if ((op !== 1) || (pcSrcCtrl !== 3) || (regWe !== 0) || (aluBSrcCtrl !== 1)
         || (dmWe !== 0) || (bneCtrl !== 1)) begin
      $display("Test Case 7 (BNE) Failed, %b", aluBSrcCtrl);
    end
    
    instr={6'he, 20'd349291, 6'h38};
    #10
    if ((op !== 2) || (pcSrcCtrl !== 0) || (regWe !== 1) || (aluBSrcCtrl !== 1)
         || (dmWe !== 0) || (bneCtrl !== 0) || (regDInCtrl !== 0)) begin
      $display("Test Case 8 (XORI) Failed");
    end
    
    instr={6'h8, 20'd349291, 6'h38};
    #10
    if ((op !== 0) || (pcSrcCtrl !== 0) || (regWe !== 1) || (aluBSrcCtrl !== 1)
         || (dmWe !== 0) || (bneCtrl !== 0) || (regDInCtrl !== 0)) begin
      $display("Test Case 9 (ADDI) Failed");
    end
    
    instr={6'h0, 20'd349291, 6'h20};
    #10
    if ((op !== 0) || (pcSrcCtrl !== 0) || (regWe !== 1) || (aluBSrcCtrl !== 0)
         || (dmWe !== 0) || (bneCtrl !== 0) || (regDInCtrl !== 0) || (regWAddr !== rd)) begin
      $display("Test Case 10 (ADD) Failed, %b", regWe);
    end
    
    instr={6'h0, 20'd34921, 6'h22};
    #10
    if ((op !== 1) || (pcSrcCtrl !== 0) || (regWe !== 1) || (aluBSrcCtrl !== 0)
         || (dmWe !== 0) || (bneCtrl !== 0) || (regDInCtrl !== 0) || (regWAddr !== rd)) begin
      $display("Test Case 11 (SUB) Failed, %b", op);
    end
    
    instr={6'h0, 20'd34921, 6'h2a};
    #10
    if ((op !== 3) || (pcSrcCtrl !== 0) || (regWe !== 1) || (aluBSrcCtrl !== 0)
         || (dmWe !== 0) || (bneCtrl !== 0) || (regDInCtrl !== 0) || (regWAddr !== rd)) begin
      $display("Test Case 12 (SLT) Failed, %b", op);
    end
  end

endmodule