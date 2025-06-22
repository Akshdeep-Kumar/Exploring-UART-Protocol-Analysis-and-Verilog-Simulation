module fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input clk,
    input reset,
    input rd,           // Read enable
    input wr,           // Write enable
    input [DATA_WIDTH-1:0] w_data,  // Data to write
    output full,
    output empty,
    output [DATA_WIDTH-1:0] r_data  // Data read
);

    // Local parameters
    localparam DEPTH = 1 << ADDR_WIDTH;

    // Internal signals
    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] w_ptr_reg, w_ptr_next;
    reg [ADDR_WIDTH-1:0] r_ptr_reg, r_ptr_next;
    reg [ADDR_WIDTH:0]   count_reg, count_next;  // one extra bit for full detection
    reg [DATA_WIDTH-1:0] r_data_reg;

    // Write and read pointers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            count_reg <= 0;
            r_data_reg <= 0;
        end else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            count_reg <= count_next;

            if (rd && ~empty)
                r_data_reg <= fifo_mem[r_ptr_reg];
        end
    end

    // Write logic
    always @(posedge clk) begin
        if (wr && ~full)
            fifo_mem[w_ptr_reg] <= w_data;
    end

    // Next pointer and count logic
    always @(*) begin
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        count_next = count_reg;

        if (wr && ~full)
            w_ptr_next = w_ptr_reg + 1;

        if (rd && ~empty)
            r_ptr_next = r_ptr_reg + 1;

        case ({wr && ~full, rd && ~empty})
            2'b10: count_next = count_reg + 1; // write only
            2'b01: count_next = count_reg - 1; // read only
            default: count_next = count_reg;   // no change or simultaneous read/write
        endcase
    end

    // Output signals
    assign full  = (count_reg == DEPTH);
    assign empty = (count_reg == 0);
    assign r_data = r_data_reg;

endmodule
