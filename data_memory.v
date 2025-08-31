`timescale 1ns / 1ps

module data_memory(
    input clk,
    input rst,
    input [4:0] read_addr,
    input [31:0] write_data,
    input write_enable,
    input [4:0] write_addr,
    output reg [31:0] read_data
);

    reg [31:0] memory [31:0]; // 32 words of 32-bit memory
    integer i;
    
    // Initialize memory
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                memory[i] <= i * 4; // Initialize with some test data
            end
        end
        else if (write_enable) begin
            memory[write_addr] <= write_data;
        end
    end
    
    // Read operation (combinational)
    always @(*) begin
        read_data = memory[read_addr];
    end

endmodule
