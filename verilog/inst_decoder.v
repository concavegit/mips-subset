module inst_decoder
(
    input    wire [31:0]      instruction,
    output   wire [31:0]      signeximmediate,
    output   wire [25:0]      address,
    output   wire [4:0]       rs,
    output   wire [4:0]       rt,
    output   wire [4:0]       rd,
    output   wire [4:0]       shamt,
    output   wire [5:0]       funct,
    output   wire [3:0]       alu
);

    assign signeximmediate = {{16{instruction[15]}} ,instruction[15:0]};
    assign address = {instruction[25:0]};
    assign rs = {instruction[25:21]};
    assign rt = {instruction[20:16]};
    assign rd = {instruction[15:11]};
    assign shamt = {instruction[10:6]};
    assign funct = {instruction[5:0]};

endmodule