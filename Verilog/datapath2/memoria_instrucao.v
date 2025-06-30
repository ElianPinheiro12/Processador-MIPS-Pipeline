
module memoria_instrucao #(
    parameter DATA_WIDTH = 32,
    parameter ROM_ADDR_BITS = 8 // 
)(
    
    input [DATA_WIDTH-1:0] pc,
    output [DATA_WIDTH-1:0] instruction
);
    
    reg [DATA_WIDTH-1:0] rom_block [0:(1<<ROM_ADDR_BITS)-1];

   
    initial begin
        $readmemh("mem/instructions.mem", rom_block);
    end

    wire [ROM_ADDR_BITS-1:0] rom_address = pc[ROM_ADDR_BITS+1:2];

    assign instruction = rom_block[rom_address];

endmodule