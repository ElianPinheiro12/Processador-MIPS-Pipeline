module register_file(
    input clk,
    input rst,
    input en,

    input [4:0] rA,
    input [4:0] rB,

    input [4:0] rW,
    input [31:0] Wd,

    output [31:0] rD1,
    output [31:0] rD2
);
    reg [31:0] registers [31:0];

    integer i;

    always @(posedge clk or posedge rst)begin 
        if(rst)begin 
            for(i = 0; i <32; i = i+1)begin 
                registers[i]<= 32'b0;
            end
        end else if(en)begin 
            if(rW != 5'b0)begin 
                registers[rW] <= Wd;
            end
        end
    end

    assign rD1 = (rA == 5'b0)? 32'b0 : registers[rA];
    assign rD2 = (rB == 5'b0)? 32'b0 : registers[rB];

endmodule
