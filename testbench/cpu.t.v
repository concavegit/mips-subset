`include "../rtl/cpu.v"
module cputest();
   reg clk;
   initial clk = 0;
   always #1 clk = ~clk;

   cpu dut(clk);

   initial begin
      $dumpfile("cpu.vcd");
      $dumpvars();
      #10 $finish;
   end
endmodule
