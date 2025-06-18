`timescale 1ns / 1ps

module tb_PC;

    parameter CLK_PERIOD = 10;

    reg clk, rst;
    reg [1:0] PCSrc;
    reg [31:0] branch_target_i, jump_target_i, jr_target_i;
    wire [31:0] pc_o;

    localparam S_PC_PLUS_4 = 2'b00,
               S_BRANCH    = 2'b01,
               S_JUMP      = 2'b10,
               S_JR        = 2'b11;

    PC uut (
        .clk(clk), .rst(rst), .PCSrc(PCSrc),
        .branch_target_i(branch_target_i),
        .jump_target_i(jump_target_i),
        .jr_target_i(jr_target_i),
        .pc_o(pc_o)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        $display("Iniciando Testes do PC");
        $timeformat(-9, 2, " ns", 10);

        rst = 1; PCSrc = S_PC_PLUS_4; @(posedge clk);
        rst = 0; #1;
        $display(pc_o === 32'h0 ? "RESET OK" : "RESET FALHOU: 0x%h", pc_o);

        PCSrc = S_PC_PLUS_4;
        repeat (3) @(posedge clk); #1;
        $display(pc_o === 32'hC ? "PC +4 OK" : "PC +4 FALHOU: 0x%h", pc_o);

        PCSrc = S_BRANCH; branch_target_i = 32'h00400100; @(posedge clk); #1;
        $display(pc_o === branch_target_i ? "BRANCH OK" : "BRANCH FALHOU: 0x%h", pc_o);

        PCSrc = S_JUMP; jump_target_i = 32'h08100000; @(posedge clk); #1;
        $display(pc_o === jump_target_i ? "JUMP OK" : "JUMP FALHOU: 0x%h", pc_o);

        PCSrc = S_JR; jr_target_i = 32'hBFC00000; @(posedge clk); #1;
        $display(pc_o === jr_target_i ? "JR OK" : "JR FALHOU: 0x%h", pc_o);

        $finish;
    end

endmodule
