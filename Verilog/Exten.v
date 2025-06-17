module sign_extender (
    input wire [15:0] in,           // Imediato de 16 bits (entrada)
    output wire [31:0] out          // Saída estendida para 32 bits
);

    // Estende o sinal: se o bit 15 for 1, completa com 1s; senão, com 0s
    assign out = {{16{in[15]}}, in};

endmodule
