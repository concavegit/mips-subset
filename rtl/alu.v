module alu
  #(parameter width = 32)
   (
    output reg signed [width-1:0] result,
    output reg                zero,
                              overflow,
                              carryout,
    input signed [width-1:0]  operandA,
                              operandB,
    input [2:0]               command
    );

   localparam
     ADD = 3'b000,
     SUB = 3'b001,
     XOR = 3'b010,
     SLT = 3'b011,
     AND = 3'b100,
     NAND = 3'b101,
     NOR = 3'b110,
     OR = 3'b111;

   always @(command, operandA, operandB) begin
      case (command)
        ADD: begin
           {carryout, result} = {1'b0, operandA} + {1'b0, operandB};
           overflow = (operandA[width-1] ~^ operandB[width-1]) && (operandA[width-1] ^ result[width-1]) ? 1 : 0;
           zero = result == 0;
        end

        SUB: begin
           {carryout, result} = {1'b0, operandA} + {1'b0, ~operandB} + 1;
           if (operandB  == 0 || operandA == 0) carryout = 0;
           overflow = (operandA[width-1] ^ operandB[width-1]) && (operandA[width-1] ^ result[width-1]) ? 1 : 0;
           zero = result == 0;
        end

        XOR: begin
           result = operandA ^ operandB;
           carryout = 0;
           overflow = 0;
           zero = 0;
        end

        SLT: begin
           result = {{(width-1){1'b0}}, operandA < operandB};
           carryout = 0;
           overflow = 0;
           zero = 0;
        end

        AND: begin
           result = operandA & operandB;
           carryout = 0;
           overflow = 0;
           zero = 0;
        end

        NAND: begin
           result = ~(operandA & operandB);
           carryout = 0;
           overflow = 0;
           zero = 0;
        end

        NOR: begin
           result = ~(operandA | operandB);
           carryout = 0;
           overflow = 0;
           zero = 0;
        end

        OR: begin
           result = operandA | operandB;
           carryout = 0;
           overflow = 0;
           zero = 0;
        end
      endcase
   end
endmodule
