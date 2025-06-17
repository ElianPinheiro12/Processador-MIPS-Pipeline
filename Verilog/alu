// Arquivo: alu.v
// Descrição: Unidade Lógica e Aritmética simples

module alu(
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  alu_control, // Sinal que define a operação
    output reg [31:0] result,
    output zero
);

    // Parâmetros para deixar o código mais legível
    parameter OP_ADD = 4'b0010;
    parameter OP_SUB = 4'b0110;

    // Lógica combinacional para calcular o resultado
    always @(*) begin
        case (alu_control)
            OP_ADD: result = a + b;
            OP_SUB: result = a - b;
            default: result = 32'hxxxxxxxx; // 'x' para indicar um resultado indefinido
        endcase
    end

    // O flag 'zero' é 1 se o resultado da operação for 0
    assign zero = (result == 32'b0);

endmodule
