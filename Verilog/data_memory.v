// data_memory.v
module data_memory #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 8  // Para 2^8 = 256 palavras
)(
    input clk,
    input MemWrite, // Habilita a escrita
    input MemRead,  // Habilita a leitura (opcional, mas bom para clareza)
    input [ADDR_WIDTH-1:0] address,
    input [DATA_WIDTH-1:0] write_data,
    output reg [DATA_WIDTH-1:0] read_data
);

    // Declara a memória. Esta é a linha mais importante.
    // O Quartus vai transformar isso em um bloco de RAM.
    reg [DATA_WIDTH-1:0] ram_block [0:(1<<ADDR_WIDTH)-1];

    always @(posedge clk) begin
        // Lógica de escrita síncrona
        if (MemWrite) begin
            ram_block[address] <= write_data;
        end
        
        // Lógica de leitura síncrona
        // O endereço é capturado na borda do clock, e o dado sai no próximo ciclo
        if (MemRead) begin
            read_data <= ram_block[address];
        end
    end

endmodule
