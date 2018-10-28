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
            aluBSrcCtrl;
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
    instr={6'd2, 26'd0};
    #10
    $display("%b", op);
  end

endmodule