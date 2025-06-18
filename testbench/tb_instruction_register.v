`timescale 1ns/1ps

module tb_instruction_register();

    reg clk;
    reg reset;
    reg load;
    reg [31:0] instruction_in;
    wire [31:0] instruction_out;

    // Instancia o módulo sob teste (UUT = Unit Under Test)
    instruction_register uut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .instruction_in(instruction_in),
        .instruction_out(instruction_out)
    );

    // Gera clock: 10ns de período (alterna a cada 5ns)
    always #5 clk = ~clk;

    initial begin
        // Inicializa os sinais
        clk = 0;
        reset = 1;
        load = 0;
        instruction_in = 32'h00000000;

        #10 reset = 0;                    // Desativa reset
        #10 load = 1; instruction_in = 32'h12345678;  // Carrega instrução 1
        #10 load = 0; instruction_in = 32'hFFFFFFFF;  // load desativado, valor não muda
        #10 load = 1; instruction_in = 32'hAABBCCDD;  // Carrega instrução 2
        #10 load = 0;
        #10 reset = 1;                    // Reset ativo
        #10 $stop;                        // Encerra a simulação
    end

endmodule
