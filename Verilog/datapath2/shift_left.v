module shift_left_2 (
    input wire [31:0] in,     // Entrada de 32 bits
    output wire [31:0] out    // Saída deslocada
);

    // Desloca os bits da entrada 2 posições para a esquerdam
    assign out = in << 2;

endmodule