//===========================================//
// Testbench: Memória de Dados               //
//===========================================//
`timescale 1ns/1ps

module tb_data_memory;

    reg clk;
    reg MemWrite, MemRead;
    reg [31:0] address;
    reg [31:0] write_data;
    wire [31:0] read_data;

    // Instancia o módulo
    data_memory uut (
        .clk(clk),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    // Geração de clock
    always #5 clk = ~clk;

    initial begin
        // Inicialização
        clk = 0;
        MemWrite = 0;
        MemRead = 0;
        address = 0;
        write_data = 0;

        // Escreve na posição 0
        #10;
        address = 32'd0;
        write_data = 32'hDEADBEEF;
        MemWrite = 1; MemRead = 0;
        #10;
        MemWrite = 0;

        // Escreve na posição 4
        address = 32'd4;
        write_data = 32'hCAFEBABE;
        MemWrite = 1;
        #10;
        MemWrite = 0;

        // Lê da posição 0
        address = 32'd0;
        MemRead = 1;
        #10;

        // Lê da posição 4
        address = 32'd4;
        #10;

        // Lê da posição 8 (espera-se 0)
        address = 32'd8;
        #10;

        MemRead = 0;

        $stop;
    end

endmodule
