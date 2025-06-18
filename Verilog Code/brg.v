module baud_gen (
    input clk,
    input reset,
    input [10:0] dvsr,
    output tick
);

    // Internal signal declarations
    reg [10:0] r_reg;
    wire [10:0] r_next;

    // Register (sequential logic)
    always @(posedge clk or posedge reset) begin
        if (reset)
            r_reg <= 11'd0;
        else
            r_reg <= r_next;
    end

    // Next-state logic
    assign r_next = (r_reg == dvsr) ? 11'd0 : r_reg + 11'd1;

    // Output logic
    assign tick = (r_reg == 11'd1);

endmodule
