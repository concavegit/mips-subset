module dataMemory
  #(
    parameter addrWidth = 7,
    depth = 2**addrWidth,
    width = 8
    )
   (
    output reg [width-1:0] dOut,
    input                  clk,
    input [addrWidth-1:0]  addr,
    input                  we,
    input [width-1:0]      dIn
    );

   reg [width-1:0]         mem [depth-1:0];

   always @(posedge clk) begin
      if (we) mem[addr] <= dIn;
   end

   assign dOut = mem[addr];
endmodule
