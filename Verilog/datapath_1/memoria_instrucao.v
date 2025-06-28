module memoria_instrucao (
    input wire [31:0] pc,                 // Endereço da instrução
    output wire [31:0] instruction,       // Instrução completa (32 bits)
    output wire [5:0]  op,                // Opcode
    output wire [4:0]  rs,                // Registrador fonte
    output wire [4:0]  rt,                // Registrador destino
	 output wire [4:0]  rd,
	 output wire [5:0] funct,
	
    output wire [15:0] immediate          // Imediato (caso instrução tipo I)
);

    reg [31:0] memory [0:255];            // Memória de instruções

    initial begin
 
		  memory[0] = 32'h24210005; // Endereço 0x00: addiu $1, $1, 5
        memory[1] = 32'h2442000A; // Endereço 0x04: addiu $2, $2, 10
        memory[2] = 32'h00221821; // Endereço 0x08: addu  $3, $1, $2
        memory[3] = 32'h00412023; // Endereço 0x0c: subu  $4, $2, $1
        memory[4] = 32'h00000000; // Endereço 0x10: sll   $0, $0, 0 (nop)
		 

    end

    // Lê a instrução da memória (endereçada por palavra)
    assign instruction = memory[pc[9:2]];

    // Decodifica campos da instrução
    assign op        = instruction[31:26];
    assign rs        = instruction[25:21];
    assign rt        = instruction[20:16];
	 assign rd        = instruction[15:11];
	 assign funct     = instruction[5:0];
    assign immediate = instruction[15:0];

endmodule
