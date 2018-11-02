# mips-subset
An implementation of a subset of MIPS CPU


Report (PDF or MarkDown), including:

Written description and block diagram of your processor architecture. Consider including selected RTL to capture how instructions are implemented.

![alt text](https://github.com/concavegit/mips-subset/blob/master/CPU%20schematic.jpg
)

This the block diagram of our single cycle CPU. All the red wires are control signals coming from the decoder. 
For an example insturction **addi $t0, $t0, 2**

The relevant control signals would be set in the following way by the decoder


**RT** = address of $t0


**ALU_B_SRC_CTRL** = 1(to choose immediate instead of the data in register RT)


**BNE** = 0


**reg_we**= 1 ( write enable would be 1)


**reg_write_address** = address of $t0


**PC_SRC_CTRL** = 00(Icremnets PC by 4 as it should as there is no branch or jump command)


**dm_we** = 0 (as the data memory would not be written to)




Description of your test plan and results

For the testing we had a 3 pronged approach. 

Number 1 was to test all the components individually using Verilog test benches. This helped us debug the integration later too as we could test specific functions of the components using the test-benches.

Number 2 was to write unit tests for all the functions our CPU was capable of doing. This helped us debug control signals and the integration. All the unit tests worked fine.

Number 3 was to write more complex assembly code. We ran programs which calculated the nth Fibonacci term and the sum of N natural numbers, these used multiple immediate and branch functions.

Some performance/area analysis of your design. This can be for the full processor, or a case study of choices made designing a single unit.It can be based on calculation, simulation, Vivado synthesis results, or a mix of all three.

Work plan reflection

According to the workplan we wanted to started wiring up the CPU completely by the last wednesday and complete by saturday, which is something we were successfully able to do. We then started writing the assembly unit tests and test files along with improving the test benches for debugging. We were able to do that by this wednesday. Since then we have been debugging our integrated CPU. We were able to iron out all of the bugs.
