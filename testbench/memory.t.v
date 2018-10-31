`include "../rtl/memory.v"

module memorytest();
   reg clk, we;
   reg [31:0] addr, dIn, instrAddr;
   wire [31:0] dOut, instrOut;
   memory m
     (
      .dOut(dOut),
      .instrOut(instrOut),
      .clk(clk),
      .addr(addr),
      .instrAddr(instrAddr),
      .we(we),
      .dIn(dIn)
      );

   initial begin
      clk = 0;
      we = 0;
      addr = 4;
      instrAddr = 4;
      dIn = 0;
      #5 clk = 1;
      #5 clk = 0;
      $display("%h", dOut);
   end
endmodule
