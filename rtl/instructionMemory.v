module instructionMemory
  #(
    parameter width = 32,
    addrWidth = 10,
    depth = 2 ** addrWidth,
    data = "mem/test.dat"
    )
   (
    output [width-1:0]    dOut,
    input [addrWidth-1:0] addr
    );

   reg [width-1:0]        mem [depth-1:0];

   initial $readmemh(data, mem);

   assign dOut = mem[addr];
endmodule
