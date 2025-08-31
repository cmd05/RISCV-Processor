`timescale 1ns / 1ps

module control_unit(
    input reset,                     // Reset signal 
    input [6:0] funct7,              // funct7 field 
    input [2:0] funct3,              // funct3 field
    input [6:0] opcode,              // opcode field         
    output reg [5:0] alu_control,    // alu_control for controlling the alu module
    output reg lb,                   // control signal for enabling load operation
    output reg mem_to_reg,           // control signal for enabling data flow from memory to register
    output reg bneq_control,         // control signal for enabling bneq operation
    output reg beq_control,          // control signal for enabling beq operation
    output reg bgeq_control,         // control signal for enabling bgeq operation
    output reg blt_control,          // control signal for enabling blt operation
    output reg jump,                 // control signal for enabling jump operation
    output reg sw,                   // control signal for enabling sw operation
    output reg lui_control           // control signal for enabling lui operation
);

    always @(reset) begin
        if (reset)
            alu_control = 0;
    end

    always @(funct7 or funct3 or opcode) begin
        if (opcode == 7'b0110011) begin
            // R-type instructions
            mem_to_reg   = 0;
            beq_control  = 0;
            bneq_control = 0;
            bgeq_control = 0;
            blt_control  = 0;
            jump         = 0;
            lui_control  = 0;

            case (funct3)
                3'b000: begin
                    // addition / subtraction
                    if (funct7 == 0)
                        alu_control = 6'b000001;  // addition
                    else if (funct7 == 64)
                        alu_control = 6'b000010;  // subtraction
                end

                3'b001: begin
                    // shift left logical
                    if (funct7 == 0)
                        alu_control = 6'b000011;
                end

                3'b010: begin
                    // set less than
                    if (funct7 == 0)
                        alu_control = 6'b000100;
                end

                3'b011: begin
                    // set less than unsigned
                    if (funct7 == 0)
                        alu_control = 6'b000101;
                end

                3'b100: begin
                    // xor
                    if (funct7 == 0)
                        alu_control = 6'b000110;
                end

                3'b101: begin
                    // shift right logical / arithmetic
                    if (funct7 == 0)
                        alu_control = 6'b000111;  // srl
                    else if (funct7 == 64)
                        alu_control = 6'b001000;  // sra
                end

                3'b110: begin
                    // or
                    if (funct7 == 0)
                        alu_control = 6'b001001;
                end

                3'b111: begin
                    // and
                    if (funct7 == 0)
                        alu_control = 6'b001010;
                end
            endcase
        end

        else if (opcode == 7'b001_0011) begin
            // I-type (immediate arithmetic)
            mem_to_reg   = 0;
            beq_control  = 0;
            bneq_control = 0;
            jump         = 0;
            lb           = 0;
            sw           = 0;

            case (funct3)
                3'b000: alu_control = 6'b001011; // add immediate
                3'b001: alu_control = 6'b001100; // shift left logical immediate
                3'b010: alu_control = 6'b001101; // set less than immediate
                3'b011: alu_control = 6'b001110; // and immediate
                3'b100: alu_control = 6'b001111; // xor immediate
                3'b101: alu_control = 6'b010000; // shift right logical immediate
                3'b110: alu_control = 6'b010001; // or immediate
                3'b111: alu_control = 6'b010010; // and immediate
            endcase
        end

        else if (opcode == 7'b000_0011) begin
            // I-type (load instructions)
            case (funct3)
                3'b000: begin
                    alu_control  = 6'b010011; // load byte
                    mem_to_reg   = 1;
                    beq_control  = 0;
                    bneq_control = 0;
                    jump         = 0;
                    lb           = 1;
                end

                3'b001: begin
                    alu_control  = 6'b010100; // load half
                    mem_to_reg   = 1;
                    beq_control  = 0;
                    bneq_control = 0;
                    jump         = 0;
                end

                3'b010: begin
                    alu_control  = 6'b010101; // load word
                    mem_to_reg   = 1;
                    beq_control  = 0;
                    bneq_control = 0;
                    jump         = 0;
                end

                3'b011: begin
                    alu_control  = 6'b010110; // load byte unsigned
                    mem_to_reg   = 1;
                    beq_control  = 0;
                    bneq_control = 0;
                    jump         = 0;
                end

                3'b100: begin
                    alu_control  = 6'b010111; // load half unsigned
                    mem_to_reg   = 1;
                    beq_control  = 0;
                    bneq_control = 0;
                    jump         = 0;
                end
            endcase
        end

        else if (opcode == 7'b0100_011) begin
            // S-type (store instructions)
            case (funct3)
                3'b010: begin
                    alu_control  = 6'b011000; // store byte
                    mem_to_reg   = 1;
                    beq_control  = 0;
                    bneq_control = 0;
                    jump         = 0;
                    sw           = 1;
                end

                3'b110: begin
                    alu_control  = 6'b011001; // store half word
                    mem_to_reg   = 1;
                    beq_control  = 0;
                    bneq_control = 0;
                    jump         = 0;
                end

                3'b111: begin
                    alu_control  = 6'b011010; // store word
                    mem_to_reg   = 1;
                    beq_control  = 0;
                    bneq_control = 0;
                    jump         = 0;
                    sw           = 1;
                end
            endcase
        end

        else if (opcode == 7'b110_0011) begin
            // B-type (branch instructions)
            case (funct3)
                3'b000: begin
                    alu_control  = 6'b011011; // branch equal
                    beq_control  = 1;
                    bneq_control = 0;
                    blt_control  = 0;
                    bgeq_control = 0;
                end

                3'b001: begin
                    alu_control  = 6'b011100; // branch not equal
                    bneq_control = 1;
                    beq_control  = 0;
                    blt_control  = 0;
                    bgeq_control = 0;
                end

                3'b010: alu_control = 6'b011101; // branch less than

                3'b100: begin
                    alu_control  = 6'b100000; // branch less than instruction
                    blt_control  = 1;
                    beq_control  = 0;
                    bneq_control = 0;
                    bgeq_control = 0;
                end

                3'b101: begin
                    alu_control  = 6'b011111; // branch greater or equal
                    bgeq_control = 1;
                    blt_control  = 0;
                    beq_control  = 0;
                    bneq_control = 0;
                end

                3'b110: alu_control = 6'b100000; // branch greater or equal unsigned
            endcase
        end

        else if (opcode == 7'b011_0111) begin
            // LUI instruction
            alu_control  = 6'b100001;
            lui_control  = 1;
            sw           = 0;
            lb           = 0;
            beq_control  = 0;
            blt_control  = 0;
            bneq_control = 0;
            bgeq_control = 0;
        end

        else if (opcode == 7'b110_1111) begin
            // JAL instruction
            alu_control  = 6'b100010;
            jump         = 1;
            lui_control  = 0;
            sw           = 0;
            lb           = 0;
            beq_control  = 0;
            blt_control  = 0;
            bneq_control = 0;
            bgeq_control = 0;
        end
    end
endmodule
