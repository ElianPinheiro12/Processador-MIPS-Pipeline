module instruction_register (
    input wire clk,
    input wire reset,
    input wire load,
    input wire [31:0] instruction_in,
    output reg [31:0] instruction_out
);

    always @(posedge clk) begin
        if (reset)
            instruction_out <= 32'b0;
        else if (load)
            instruction_out <= instruction_in;
    end

endmodule
