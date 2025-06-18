`timescale 1ns/1ps

module tb_uart;

    // Parameters
    localparam DBIT = 8;
    localparam SB_TICK = 16;
    localparam FIFO_W = 2;

    // Signals
    reg clk;
    reg reset;
    reg rd_uart, wr_uart;
    reg [7:0] w_data;
    reg [10:0] dvsr;
    wire tx_full, rx_empty;
    wire tx;
    wire [7:0] r_data;
    wire rx;

    // UART Loopback: tx connected to rx
    assign rx = tx;

    // Instantiate UART module directly
    UART #(.DBIT(DBIT), .SB_TICK(SB_TICK), .FIFO_W(FIFO_W)) uut (
        .clk(clk),
        .reset(reset),
        .rd_uart(rd_uart),
        .wr_uart(wr_uart),
        .rx(rx),
        .w_data(w_data),
        .dvsr(dvsr),
        .tx_full(tx_full),
        .rx_empty(rx_empty),
        .tx(tx),
        .r_data(r_data)
    );

    // Clock generation: 50 MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 20ns period
    end

    // Test sequence
    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, tb_uart);

        // Init
        reset = 1;
        rd_uart = 0;
        wr_uart = 0;
        w_data = 8'd0;
        dvsr = 11'd4; // Fast simulation (very high baud rate)
        #100;

        reset = 0;
        #100;

        send_byte(8'h41); // A
        send_byte(8'h42); // B
        send_byte(8'h43); // C

        #5000;
        $display("Simulation finished.");
        $finish;
    end

    // Task to send a byte over UART
    task send_byte(input [7:0] byte);
        begin
            // Wait until TX not full
            wait (!tx_full);
            @(posedge clk);
            wr_uart = 1;
            w_data = byte;
            @(posedge clk);
            wr_uart = 0;
            w_data = 8'd0;

            // Wait until RX is not empty
            wait (!rx_empty);
            @(posedge clk);
            rd_uart = 1;
            @(posedge clk);
            rd_uart = 0;

            @(posedge clk);
            @(posedge clk);

            if (r_data >= 32 && r_data <= 126)
                $display("Time %0t: Received byte: 0x%0h ('%c')", $time, r_data, r_data);
            else
                $display("Time %0t: Received byte: 0x%0h ('?')", $time, r_data);

            #1000;
        end
    endtask

endmodule
