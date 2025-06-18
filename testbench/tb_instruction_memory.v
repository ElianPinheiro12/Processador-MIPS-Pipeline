//============================================//
// Testbench: Memória de Instrução (MIPS)     //
//============================================//
`timescale 1ns/1ps

module tb_instruction_memory;

    reg [31:0] address;
    wire [31:0] instruction;

    // Instancia o módulo de memória
    instruction_memory uut (
        .address(address),
        .instruction(instruction)
    );

    initial begin
        // Início da simulação
        $display("===== Teste da Memória de Instrução =====");

        address = 0;     #20;
        $display("address: %d => instruction: %h", address, instruction);

        address = 4;     #20;
        $display("address: %d => instruction: %h", address, instruction);

        address = 8;     #20;
        $display("address: %d => instruction: %h", address, instruction);

        address = 12;    #20;
        $display("address: %d => instruction: %h", address, instruction);

        address = 16;    #20;
        $display("address: %d => instruction: %h", address, instruction);

        address = 20;    #20;
        $display("address: %d => instruction: %h", address, instruction);

        $display("===== Fim do Teste =====");
        $stop;
    end

endmodule
