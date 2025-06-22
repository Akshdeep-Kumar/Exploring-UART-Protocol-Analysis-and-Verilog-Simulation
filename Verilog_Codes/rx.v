module uart_rx #(
    parameter DBIT = 8,
    parameter SB_TICK = 16
)(
    input clk,
    input reset,
    input rx,
    input s_tick,
    output reg rx_done_tick,
    output [7:0] dout
);

    // State declarations
    localparam [1:0] IDLE  = 2'b00,
                     START = 2'b01,
                     DATA  = 2'b10,
                     STOP  = 2'b11;

    // Signal declarations
    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;
    reg [2:0] n_reg, n_next;
    reg [7:0] b_reg, b_next;

    // FSMD state & data registers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            s_reg <= 4'd0;
            n_reg <= 3'd0;
            b_reg <= 8'd0;
        end else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
        end
    end

    // FSMD next-state logic
    always @(*) begin
        // Default assignments
        state_next = state_reg;
        rx_done_tick = 1'b0;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;

        case (state_reg)
            IDLE: begin
                if (~rx) begin  // Start bit is LOW
                    state_next = START;
                    s_next = 4'd0;
                end
            end

            START: begin
                if (s_tick) begin
                    if (s_reg == 4'd7) begin
                        state_next = DATA;
                        s_next = 4'd0;
                        n_next = 3'd0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            DATA: begin
                if (s_tick) begin
                    if (s_reg == 4'd15) begin
                        s_next = 4'd0;
                        b_next = {rx, b_reg[7:1]};  // shift right
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
                if (s_tick) begin
                    if (s_reg == (SB_TICK - 1)) begin
                        state_next = IDLE;
                        rx_done_tick = 1'b1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
        endcase
    end

    // Output assignment
    assign dout = b_reg;

endmodule
