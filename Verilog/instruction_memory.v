module instruction_memory (
    input wire [31:0] address,           // Endereço da instrução (vindo do PC)
    output wire [31:0] instruction       // Instrução lida da memória
);

    reg [31:0] memory [0:255];           // Memória com 256 posições (32 bits cada)

    initial begin
        // Exemplo de instruções MIPS em hexadecimal:
        memory[0] = 32'h20080001; // addi $t0, $zero, 1
        memory[1] = 32'h20090002; // addi $t1, $zero, 2
        memory[2] = 32'h01095020; // add  $t2, $t0, $t1
        memory[3] = 32'hAC0A0000; // sw   $t2, 0($zero)
        memory[4] = 32'h8C0B0000; // lw   $t3, 0($zero)
        memory[5] = 32'h00000000; // nop
    end

    // Endereçamento por palavra (ignora bits 0 e 1)
    assign instruction = memory[address[9:2]];

endmodule
