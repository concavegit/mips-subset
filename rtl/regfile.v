module regfile
  #(
    parameter
    width = 32,
    addrWidth = 5,
    depth = 2**addrWidth
    )
   (
    output [width-1:0]    ReadData1,
                          ReadData2,
    input [width-1:0]     WriteData,
    input [addrWidth-1:0] ReadRegister1,
                          ReadRegister2,
                          WriteRegister,
    input                 RegWrite,
    Clk
    );

   reg [width-1:0]        registers [depth-1:0];

   always @(posedge Clk) begin
      if (RegWrite && WriteRegister != 0) begin
         registers[WriteRegister] <= WriteData;
      end
   end

   assign ReadData1 = registers[ReadRegister1];
   assign ReadData2 = registers[ReadRegister2];
endmodule
