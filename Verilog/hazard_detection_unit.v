module hazard_detection_unit(
    input [4:0] if_id_rs,           
    input [4:0] if_id_rt,         
    input [4:0] id_ex_rt,           
    input       id_ex_mem_read,     
    output reg  pc_write,           
    output reg  if_id_write,        
    output reg  id_ex_flush         
);

    
    always @(*) begin
        if (id_ex_mem_read &&
           ((id_ex_rt == if_id_rs) || (id_ex_rt == if_id_rt)))
        begin
            
            pc_write    = 1'b0; // Para o PC
            if_id_write = 1'b0; // Para o registrador IF/ID
            id_ex_flush = 1'b1; // Insere uma bolha no pipeline
        end
        else begin
            
            pc_write    = 1'b1;
            if_id_write = 1'b1;
            id_ex_flush = 1'b0;
        end
    end

endmodule
