`timescale 1ns / 1ps

module top_riscv(
    input clk,
    input reset
);

    wire [31:0] imm_val_top;              // Extracted immediate value (sign extended)
    wire [31:0] pc;                       // Programme counter
    wire [31:0] instruction_out;          // Output of instruction memory
    wire [5:0] alu_control;               // Control signal for determining ALU operation
    wire mem_to_reg;                      // Control signal for enabling memory-to-register operation           
    wire bneq_control;                    // Control signal for enabling BNE instruction                  
    wire beq_control;                     // Control signal for BEQ instruction     
    wire jump;                            // Control signal for jump instruction
    wire [4:0] read_data_addr_dm;         // Address for reading data from data memory
    wire [31:0] imm_val;                  // Extracted immediate value (sign extended)
    wire lb;                              // Signal for enabling load operation
    wire sw;                              // Signal for enabling store operation
    wire [31:0] imm_val_branch_top;       // Extracted immediate value for branch (sign extended)
    wire beq, bneq;                       // Control signals for BEQ and BNE
    wire bgeq_control;                    // Control signal for BGE instruction
    wire blt_control;                     // Control signal for BLT instruction
    wire bge;                             // Control signal for BGE
    wire blt;                             // Control signal for BLT
    wire lui_control;                     // Control signal for LUI
    wire [31:0] imm_val_lui;              // Extracted immediate value for LUI (sign extended)
    wire [31:0] imm_val_jump;             // Extracted immediate value for JUMP (sign extended)
    wire [31:0] current_pc;               // Register for storing return PC
    wire [31:0] immediate_value_store_temp;
    wire [31:0] immediate_value_store;
    wire [4:0] base_addr;
    wire [4:0] base_address;
    wire zero_flag;
    wire reg_dst;
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] data_out_2_dm;
    wire [31:0] write_data_dm;
    wire [31:0] data_out;
    wire [31:0] return_address;

    // Instruction Fetch Unit
    // Fetches instructions stored in instruction memory
    instruction_fetch_unit ifu(
        clk,
        reset,
        imm_val_branch_top,
        imm_val_jump,
        beq,
        bneq,
        bge,
        blt,
        jump,
        pc,
        current_pc
    );

    // Instruction Memory Unit
    // Used as ROM, all instructions are stored here
    instruction_memory imu(
        .clk(clk),
        .pc(pc),
        .reset(reset),
        .instruction_code(instruction_out)
    );

    // Control Unit
    // Acts as the brain of the processor and controls all operations
    control_unit cu(
        reset,
        instruction_out[31:25],
        instruction_out[14:12],
        instruction_out[6:0],
        alu_control,
        lb,
        mem_to_reg,
        bneq_control,
        beq_control,
        bgeq_control,
        blt_control,
        jump,
        sw,
        lui_control
    );

    // Data Path Unit
    // Routes data between modules
    data_path dpu(
        .clk(clk),
        .rst(reset),
        .read_reg_num1(instruction_out[19:15]),
        .read_reg_num2(instruction_out[24:20]),
        .write_reg_num1(instruction_out[11:7]),
        .alu_control(alu_control),
        .jump(jump),
        .beq_control(beq_control),
        .zero_flag(zero_flag),
        .reg_dst(reg_dst),
        .mem_to_reg(mem_to_reg),
        .bne_control(bneq_control),
        .imm_val(immediate_value_store),
        .shamt(instruction_out[23:20]),
        .lb(lb),
        .sw(sw),
        .bgeq_control(bgeq_control),
        .blt_control(blt_control),
        .lui_control(lui_control),
        .imm_val_lui(imm_val_lui),
        .imm_val_jump(imm_val_jump),
        .return_address(current_pc),
        .read_data_addr_dm(read_data_addr_dm),
        .beq(beq),
        .bneq(bneq),
        .bge(bge),
        .blt(blt)
    );

    // Immediate value extraction
    assign imm_val_top         = {{20{instruction_out[31]}}, instruction_out[31:21]};
    assign imm_val_branch_top  = {{20{instruction_out[31]}}, instruction_out[30:25], instruction_out[11:8], instruction_out[7]};
    assign imm_val_lui         = {10'b0, instruction_out[31:12]};
    assign imm_val_jump        = {{10{instruction_out[31]}}, instruction_out[31:12]};
    assign imm_val             = imm_val_top;
    assign immediate_value_store_temp = {{20{instruction_out[31]}}, instruction_out[31:12]};
    assign base_address        = instruction_out[19:15];

    // Default assignments
    assign zero_flag           = 1'b0;
    assign reg_dst             = 1'b0;
    assign return_address      = current_pc;
    assign immediate_value_store = immediate_value_store_temp + base_address; 
	
endmodule
