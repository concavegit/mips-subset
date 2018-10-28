module memory
  #(
    parameter width = 8,
    wordSz = 4,
    addrWidth = 32,
    depth = 2**addrWidth,
    data = "testmem.dat"
    )
   (
    output [width*wordSz-1:0] dOut,
    input                     clk,
    input [addrWidth-1:0]     addr,
    input                     we,
    input [width*wordSz-1:0]  dIn
    );

   reg [width-1:0]            mem [depth-1:0];

   initial $readmemh(data, mem);
   genvar                     i;
   generate
      for (i = 0; i < wordSz; i = i+1) begin
         always @(posedge clk)
           if (we)
             mem[addr+wordSz-1-i] <= dIn[i*width+:width];
         assign dOut[(wordSz - i - 1) * width+:width] = mem[addr+i];
      end
   endgenerate
endmodule
