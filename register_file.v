`timescale 1ns / 1ps

module register_file(
    input clk,
    input rst,
    input [4:0] read_reg_num1,          // Address for reading from register 1
    input [4:0] read_reg_num2,          // Address for reading from register 2
    input [4:0] write_reg_num1,         // Address for writing into register
    input [31:0] write_data_dm,         // Data from data memory 
    input lb,
    input lui_control,
    input [31:0] lui_imm_val,
    input [31:0] return_address,
    input jump,
    output [31:0] read_data1,           // Read data output 1
    output [31:0] read_data2,           // Read data output 2 
    output [4:0] read_data_addr_dm,     // Read address for fetching data from data memory
    output reg [31:0] data_out_2_dm,
    input sw
);

    reg [31:0] reg_mem [31:0];
    wire [31:0] write_reg_dm;           // Address for load type instructions
        
    assign read_data_addr_dm = write_reg_num1;
    assign write_reg_dm = write_reg_num1;
        
    integer i;
        
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                reg_mem[i] <= i;
            data_out_2_dm = 0;
        end
        else begin
            if (lb)
                reg_mem[write_reg_num1] = write_data_dm;
            else if (sw)
                data_out_2_dm = reg_mem[read_reg_num1];
            else if (lui_control)
                reg_mem[write_reg_num1] = lui_imm_val;
            else if (jump)
                reg_mem[write_reg_num1] = return_address;
        end
    end
         
    assign read_data1 = reg_mem[read_reg_num1];
    assign read_data2 = reg_mem[read_reg_num2];
         
endmodule
