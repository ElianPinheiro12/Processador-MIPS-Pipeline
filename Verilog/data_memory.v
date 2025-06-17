module data_memory (
    input wire clk,                   // Clock para escrita
    input wire MemWrite,             // Habilita escrita
    input wire MemRead,              // Habilita leitura
    input wire [31:0] address,       // Endereço da memória
    input wire [31:0] write_data,    // Dado a ser escrito
    output reg [31:0] read_data      // Dado lido
);

    reg [31:0] memory [0:255];       // Memória com 256 posições de 32 bits

    always @(posedge clk) begin
        if (MemWrite)
            memory[address[9:2]] <= write_data; // Escrita sincronizada
    end

    always @(*) begin
        if (MemRead)
            read_data = memory[address[9:2]];   // Leitura combinacional
        else
            read_data = 32'b0;
    end

endmodule
