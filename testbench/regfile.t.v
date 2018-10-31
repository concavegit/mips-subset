`include "../rtl/regfile.v"

module hw4testbenchharness();

   wire[31:0]	ReadData1;	// Data from first register read
   wire [31:0]  ReadData2;	// Data from second register read
   wire [31:0]  WriteData;	// Data to write to register
   wire [4:0]   ReadRegister1;	// Address of first register to read
   wire [4:0]   ReadRegister2;	// Address of second register to read
   wire [4:0]   WriteRegister;  // Address of register to write
   wire		RegWrite;	// Enable writing of register when High
   wire		Clk;		// Clock (Positive Edge Triggered)

   reg		begintest;	// Set High to begin testing register file
   wire		dutpassed;	// Indicates whether register file passed tests

   // Instantiate the register file being tested.  DUT = Device Under Test
   regfile DUT
     (
      .ReadData1(ReadData1),
      .ReadData2(ReadData2),
      .WriteData(WriteData),
      .ReadRegister1(ReadRegister1),
      .ReadRegister2(ReadRegister2),
      .WriteRegister(WriteRegister),
      .RegWrite(RegWrite),
      .Clk(Clk)
      );

   // Instantiate test bench to test the DUT
   hw4testbench tester
     (
      .begintest(begintest),
      .endtest(endtest),
      .dutpassed(dutpassed),
      .ReadData1(ReadData1),
      .ReadData2(ReadData2),
      .WriteData(WriteData),
      .ReadRegister1(ReadRegister1),
      .ReadRegister2(ReadRegister2),
      .WriteRegister(WriteRegister),
      .RegWrite(RegWrite),
      .Clk(Clk)
      );

   // Test harness asserts 'begintest' for 1000 time steps, starting at time 10
   initial begin
      begintest=0;
      #10;
      begintest=1;
      #1000;
   end

   always @(posedge endtest) begin
      $display("DUT passed?: %b", dutpassed);
   end

endmodule


//------------------------------------------------------------------------------
// Your HW4 test bench
//   Generates signals to drive register file and passes them back up one
//   layer to the test harness. This lets us plug in various working and
//   broken register files to test.
//
//   Once 'begintest' is asserted, begin testing the register file.
//   Once your test is conclusive, set 'dutpassed' appropriately and then
//   raise 'endtest'.
//------------------------------------------------------------------------------

module hw4testbench
  (
   // Test bench driver signal connections
   input             begintest, // Triggers start of testing
   output reg        endtest, // Raise once test completes
   output reg        dutpassed, // Signal test result

   // Register File DUT connections
   input [31:0]      ReadData1,
   input [31:0]      ReadData2,
   output reg [31:0] WriteData,
   output reg [4:0]  ReadRegister1,
   output reg [4:0]  ReadRegister2,
   output reg [4:0]  WriteRegister,
   output reg        RegWrite,
   output reg        Clk
   );

   // For looping through cases
   reg [5:0]         i;

   // Initialize register driver signals
   initial begin
      WriteData=32'd0;
      ReadRegister1=5'd0;
      ReadRegister2=5'd0;
      WriteRegister=5'd0;
      RegWrite=0;
      Clk=0;
   end

   // Once 'begintest' is asserted, start running test cases
   always @(posedge begintest) begin
      endtest = 0;
      dutpassed = 1;
      #10

        // Test Case 1:
        //   Write '42' to register 2, verify with Read Ports 1 and 2
        //   (Passes because example register file is hardwired to return 42)
        WriteRegister = 5'd2;
      WriteData = 32'd42;
      RegWrite = 1;
      ReadRegister1 = 5'd2;
      ReadRegister2 = 5'd2;
      #5 Clk=1; #5 Clk=0;	// Generate single clock pulse

      // Verify expectations and report test result
      if((ReadData1 != 42) || (ReadData2 != 42)) begin
         dutpassed = 0;	// Set to 'false' on failure
         $display("Test Case 1 Failed");
      end

      // Test Case 2:
      //   Write '15' to register 2, verify with Read Ports 1 and 2
      //   (Fails with example register file, but should pass with yours)
      WriteRegister = 5'd2;
      WriteData = 32'd15;
      RegWrite = 1;
      ReadRegister1 = 5'd2;
      ReadRegister2 = 5'd2;
      #5 Clk=1; #5 Clk=0;

      if((ReadData1 != 15) || (ReadData2 != 15)) begin
         dutpassed = 0;
         $display("Test Case 2 Failed");
      end

      // Test Cases 3 All nonzero registers can be written to.
      // Write 283492 to given register, verify with read ports 1 and 2

      for (i = 1; i < 32; i = i+1) begin

         WriteRegister = i[4:0];
         WriteData = 32'd283492;
         RegWrite = 1;
         ReadRegister1 = i[4:0];
         ReadRegister2 = i[4:0];
         #5 Clk=1; #5 Clk=0;

         if((ReadData1 != 283492) || (ReadData2 != 283492)) begin
            dutpassed = 0;
            $display("Test Case Failed Wrote 283492 r:%b Read %d from %b and %d from %b", i[4:0], ReadData1, ReadRegister1, ReadData2, ReadRegister2);
         end

      end

      // Test Case 4: Check if WriteEnable works
      // Write 9834 to all registers with RegWrite = 0, verify all ports are still 283492

      for (i = 1; i < 32; i = i+1) begin

         WriteRegister = i[4:0];
         WriteData = 32'd9834;
         RegWrite = 0;
         ReadRegister1 = i[4:0];
         ReadRegister2 = i[4:0];
         #5 Clk=1; #5 Clk=0;

         if((ReadData1 != 283492) || (ReadData2 != 283492)) begin
            dutpassed = 0;
            $display("Test Case WriteEnable Failed r:%b Read %d from %b and %d from %b", i[4:0], ReadData1, ReadRegister1, ReadData2, ReadRegister2);
         end

      end

      // Test Case 5: Test decoder works and only one register is being written
      // Write 6983 to address 11, read address 16 and 18 as 283492 still

      WriteRegister = 5'd11;
      WriteData = 299;
      RegWrite = 1;
      ReadRegister1 = 16;
      ReadRegister2 = 18;
      #5 Clk=1; #5 Clk=0;

      if((ReadData1 != 283492) || (ReadData2 != 283492)) begin
         dutpassed = 0;
         $display("Test Case decoder Failed Wrote %d to %b and Read %d from %b and %d from %b", WriteData, WriteRegister, ReadData1, ReadRegister1, ReadData2, ReadRegister2);
      end


      // Test Case 6: Zero register working test cases
      // Write 9999 to register address zero, read zero from ports 1 and 2
      WriteRegister = 0;
      WriteData = 9999;
      RegWrite = 1;
      ReadRegister1 = 0;
      ReadRegister2 = 0;
      #5 Clk=1; #5 Clk=0;

      $display("%d, %d", ReadData1, ReadRegister1);
      if((ReadData1 != 0) || (ReadData2 != 0)) begin
         dutpassed = 0;
         $display("Test Case zero reg Failed Read %d from %b and %d from %b", ReadData1, ReadRegister1, ReadData2, ReadRegister2);
      end

      // Test Case 7: Check if port 2 works.
      // Make port 2 read register 11 for value 299, then read register 18 for 283492.
      ReadRegister2 = 11;
      #5 Clk = 1;
      #5 Clk = 0;
      if (ReadData2 != 299) begin
         dutpassed = 0;
         $display("Test Case Read %d from %b", ReadData2, ReadRegister2);
      end

      
      #5 Clk = 1;
      #5 Clk = 0;
      ReadRegister2 = 18;
      
      if (ReadData2 != 283492) begin
         dutpassed = 0;
         $display("Test Case Read %d from %b", ReadData2, ReadRegister2);
      end

      // All done!  Wait a moment and signal test completion.
      #5
        endtest = 1;

   end

endmodule
