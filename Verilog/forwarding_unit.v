module forwarding_unit(
    
    input [4:0]     rs_ex,  // Endereço do registrador fonte 1
    input [4:0]     rt_ex,  // Endereço do registrador fonte 2
    input [4:0]     write_reg_addr_mem, // Endereço do registrador de destino
    input           reg_write_mem,      // Sinal de controle de escrita
    input [4:0]     write_reg_addr_wb,  // Endereço do registrador de destino
    input           reg_write_wb,       // Sinal de controle de escrita

    output reg [1:0] forward_a, // Controle para a entrada A da ALU
    output reg [1:0] forward_b  // Controle para a entrada B da ALU
);


    always @(*) begin
   
        forward_a = 2'b00;

        if (reg_write_mem && (write_reg_addr_mem != 5'b0) && (write_reg_addr_mem == rs_ex)) begin
            forward_a = 2'b10; // Forward do estágio MEM
        end

        else if (reg_write_wb && (write_reg_addr_wb != 5'b0) && (write_reg_addr_wb == rs_ex)) begin
            forward_a = 2'b01; // Forward do estágio WB
        end

        forward_b = 2'b00;
		  
        if (reg_write_mem && (write_reg_addr_mem != 5'b0) && (write_reg_addr_mem == rt_ex)) begin
            forward_b = 2'b10; // Forward do estágio MEM
        end
        else if (reg_write_wb && (write_reg_addr_wb != 5'b0) && (write_reg_addr_wb == rt_ex)) begin
            forward_b = 2'b01; // Forward do estágio WB
        end
    end

endmodule
