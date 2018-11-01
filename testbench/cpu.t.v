`include "../rtl/cpu2.v"
module cputest();
   reg clk;
   initial clk = 0;
   cpu2 dut(clk);
   always #1 clk = ~clk;

   always #2 $display("%h, %h, %h", dut.instr, dut.pc, dut.dmOut);

   initial begin
      $dumpfile("cpu.vcd");
      $dumpvars();
      $display("%h, %h", dut.instr, dut.pc, dut.dmOut);
      #50 $finish;
   end
endmodule
