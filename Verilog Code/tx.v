module uart_tx #(
    parameter DBIT = 8,
    parameter SB_TICK = 16
)(
    input clk,
    input reset,
    input tx_start,
    input s_tick,
    input [7:0] din,
    output reg tx_done_tick,
    output tx
);

    // FSM state encoding
    localparam [1:0] IDLE  = 2'b00,
                     START = 2'b01,
                     DATA  = 2'b10,
                     STOP  = 2'b11;

    // Internal signals
    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;
    reg [2:0] n_reg, n_next;
    reg [7:0] b_reg, b_next;
    reg tx_reg, tx_next;

    // State and data registers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            s_reg <= 4'd0;
            n_reg <= 3'd0;
            b_reg <= 8'd0;
            tx_reg <= 1'b1;
        end else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
        end
    end

    // Next-state logic
    always @(*) begin
        // Default assignments
        state_next = state_reg;
        tx_done_tick = 1'b0;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        tx_next = tx_reg;

        case (state_reg)
            IDLE: begin
                tx_next = 1'b1;
                if (tx_start) begin
                    state_next = START;
                    s_next = 4'd0;
                    b_next = din;
                end
            end

            START: begin
                tx_next = 1'b0;
                if (s_tick) begin
                    if (s_reg == 4'd15) begin
                        state_next = DATA;
                        s_next = 4'd0;
                        n_next = 3'd0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            DATA: begin
                tx_next = b_reg[0];
                if (s_tick) begin
                    if (s_reg == 4'd15) begin
                        s_next = 4'd0;
                        b_next = b_reg >> 1;
                        if (n_reg == (DBIT - 1)) begin
                            state_next = STOP;
                        end else begin
                            n_next = n_reg + 1;
                        end
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1;
                if (s_tick) begin
                    if (s_reg == (SB_TICK - 1)) begin
                        state_next = IDLE;
                        tx_done_tick = 1'b1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
        endcase
    end

    // Output assignment
    assign tx = tx_reg;

endmodule
