module sinal_ex (
    input wire [15:0] a,           // Imediato de 16 bits (entrada)
    output wire [31:0] b          // Saída estendida para 32 bits
);

    // Estende o sinal: se o bit 15 for 1, completa com 1s; senão, com 0s
    assign b = {{16{a[15]}}, a};

endmodule