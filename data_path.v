`timescale 1ns / 1ps

module data_path(
    input clk,
    input rst,
    input [4:0] read_reg_num1,
    input [4:0] read_reg_num2,
    input [4:0] write_reg_num1,
    input [5:0] alu_control,
    input jump, beq_control, zero_flag, reg_dst, mem_to_reg, bne_control,
    input [31:0] imm_val,
    input [3:0] shamt,
    input lb,
    input sw,
    input bgeq_control,
    input blt_control,
    input lui_control,
    input [31:0] imm_val_lui,
    input [31:0] imm_val_jump,
    input [31:0] return_address,
    output [4:0] read_data_addr_dm,
    output beq, bneq, bge, blt
);

    reg [31:0] pc_current;
    reg [31:0] pc_next, pc_2;

    wire [31:0] instr;
    wire [31:0] ext_imm;
    wire [31:0] read_reg_data_2;
    wire [31:0] read_reg_data_1;
    wire [31:0] reg_write_dest;

    wire [31:0] reg_read_data_2;       // Data from register file
    wire [31:0] pc_j, pc_beq, pc_bneq;
    wire bneq_control;
    wire [31:0] pc_2beq;
    wire [31:0] pc_2bneq;
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [4:0]  read_data_addr_dm_2;
    wire [31:0] write_data_alu;
    wire [31:0] write_data_dm;
    wire [4:0]  rd_addr;
    wire [31:0] data_out;
    wire [31:0] data_out_2_dm;

    // Register file
    register_file rfu (
        .clk(clk),
        .rst(rst),
        .read_reg_num1(read_reg_num1),
        .read_reg_num2(read_reg_num2),
        .write_reg_num1(write_reg_num1),
        .write_data_dm(data_out),
        .lb(lb),
        .lui_control(lui_control),
        .lui_imm_val(imm_val_lui),
        .return_address(return_address),
        .jump(jump),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .read_data_addr_dm(read_data_addr_dm_2),
        .data_out_2_dm(data_out_2_dm),
        .sw(sw)
    );

    // ALU
    alu alu_unit (
        .src1(read_data1),
        .src2(read_data2),
        .alu_control(alu_control),
        .imm_val_r(imm_val),
        .shamt(shamt[3:0]),
        .result(write_data_alu)
    );

    // Data memory
    data_memory dmu (
        .clk(clk),
        .rst(rst),
        .read_addr(imm_val[4:0]),
        .write_data(data_out_2_dm),
        .write_enable(sw),
        .write_addr(imm_val[4:0]),
        .read_data(data_out)
    );

    // Program counter initialization
    initial begin
        pc_current <= 32'd0;
    end

    // Program counter update
    always @(posedge clk) begin
        pc_current <= pc_next;
    end

    // PC increment and branch/jump logic
    assign pc2         = pc_current + 4;
    assign jump_shift  = {instr[11:0], 1'b0};
    assign reg_read_addr_1 = instr[13:10];
    assign reg_read_addr_2 = instr[9:6];
    assign read_data_addr_dm = read_data_addr_dm_2;

    // Branch conditions
    assign beq  = (write_data_alu == 1 && beq_control  == 1) ? 1 : 0;
    assign bneq = (write_data_alu == 1 && bneq_control == 1) ? 1 : 0;
    assign bge  = (write_data_alu == 1 && bgeq_control == 1) ? 1 : 0;
    assign blt  = (write_data_alu == 1 && blt_control  == 1) ? 1 : 0;

    // Immediate extension
    assign ext_imm = {{10{instr[31]}}, instr[31:21]};

    // Branch PC calculation
    assign pc_beq  = pc2 + {ext_imm[31:21], 1'b0};
    assign pc_bneq = pc2 + {ext_imm[31:21], 1'b0};

    // Destination register selection
    assign reg_write_dest = (reg_dst == 1'b1) ? instr[24:20] : instr[19:15];

endmodule
