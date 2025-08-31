module alu(
    input  [31:0] src1,
    input  [31:0] src2,
    input  [5:0]  alu_control,
    input  [31:0] imm_val_r,
    input  [3:0]  shamt,           // shift amount
    output reg [31:0] result
);

    always @(*) begin
        case (alu_control)
            6'b000001: // addition
                result = src1 + src2;

            6'b000010: // subtraction
                result = src1 - src2;

            6'b000011: // shift left logical
                result = src1 << src2;

            6'b000100: // set less than
                result = (src1 < src2) ? 1 : 0;

            6'b000110: // xor operation
                result = src1 ^ src2;

            6'b000111: // shift right logical
                result = src1 >> src2;

            6'b001000: // shift right arithmetic
                result = src1 >>> src2;

            6'b001001: // or operation
                result = src1 | src2;

            6'b001010: // and operation
                result = src1 & src2;

            6'b001011: // add immediate
                result = src1 + imm_val_r;

            6'b001100: // shift left logical immediate
                result = imm_val_r << shamt;

            6'b001101: // set less than immediate
                result = (imm_val_r < src1) ? 1 : 0;

            6'b001110: // and
                result = src1 & src2;

            6'b001111: // xor immediate
                result = src1 ^ imm_val_r;

            6'b010000: // shift right logical immediate
                result = src1 >> imm_val_r;

            6'b001001: // set less than
                result = (src1 < src2) ? 1 : 0;

            6'b001011: // set less than unsigned (check needed)
                result = src1 + imm_val_r;

            6'b001110: // and immediate
                result = src1 & imm_val_r;

            6'b001111: // shift right logical immediate
                result = src1 >> imm_val_r;

            6'b010000: // shift left logical immediate
                result = src1 << imm_val_r;

            6'b010001: // or immediate
                result = src1 | imm_val_r;

            6'b010010: // and immediate
                result = src1 & imm_val_r;

            6'b011011: // equality check
                result = (src1 == src2) ? 1 : 0;
                // if the two registers contain the same values, result = 1
                // else result = 0

            6'b011100: // inequality check
                result = (src1 != src2) ? 1 : 0;
                // if the two registers contain different values, result = 1
                // else result = 0

            6'b011111: // branch greater or equal
                result = (src2 >= src1) ? 1 : 0;

            6'b100000: // branch less than
                result = (src1 < src2) ? 1 : 0;
        endcase
    end

endmodule
