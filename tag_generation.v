module tag_generation #(parameter DATA_SIZE = 32, parameter TAG_SIZE = 8) (
    input clk,
    input reset,
    input [DATA_SIZE-1:0] data,
    input [15:0] secret_key,
    output reg [TAG_SIZE-1:0] tag
);
    
    localparam NUM_BLOCKS = DATA_SIZE / 8;
    localparam BLOCK_SIZE = DATA_SIZE / 4;

    wire [TAG_SIZE-1:0] bf_block[NUM_BLOCKS-1:0];
    wire [TAG_SIZE-1:0] rls_block[NUM_BLOCKS-1:0];
    wire [TAG_SIZE-1:0] tag_next;

    // Block Flip (BF) and Rotating Left Shift (RLS) for each block
    assign bf_block[0] = (secret_key[0] == 1'b1) ? ~data[BLOCK_SIZE-1:0] : data[BLOCK_SIZE-1:0];
    assign bf_block[1] = (secret_key[1] == 1'b1) ? ~data[2*BLOCK_SIZE-1:BLOCK_SIZE] : data[2*BLOCK_SIZE-1:BLOCK_SIZE];
    assign bf_block[2] = (secret_key[2] == 1'b1) ? ~data[3*BLOCK_SIZE-1:BLOCK_SIZE*2] : data[2*BLOCK_SIZE-1:BLOCK_SIZE];
    assign bf_block[3] = (secret_key[3] == 1'b1) ? ~data[4*BLOCK_SIZE-1:BLOCK_SIZE*3] : data[4*BLOCK_SIZE-1:BLOCK_SIZE*3];

    wire [2:0] shift_amount_0 = secret_key[3:0];
    wire [2:0] shift_amount_1 = secret_key[7:4];
    wire [2:0] shift_amount_2 = secret_key[11:8];
    wire [2:0] shift_amount_3 = secret_key[15:12];

    assign rls_block[0] = (bf_block[0] << shift_amount_0) | (bf_block[0] >> (BLOCK_SIZE - shift_amount_0));
    assign rls_block[1] = (bf_block[1] << shift_amount_1) | (bf_block[1] >> (BLOCK_SIZE - shift_amount_1));
    assign rls_block[2] = (bf_block[2] << shift_amount_2) | (bf_block[2] >> (BLOCK_SIZE - shift_amount_2));
    assign rls_block[3] = (bf_block[3] << shift_amount_3) | (bf_block[3] >> (BLOCK_SIZE - shift_amount_3));
    
    assign tag_next = rls_block[0] ^ rls_block[1] ^ rls_block[2] ^ rls_block[3];
    
    always @(*) begin
        if (reset) begin
            tag <= 0;
        end else begin    
            tag <= tag_next;
        end
    end     
        
endmodule
