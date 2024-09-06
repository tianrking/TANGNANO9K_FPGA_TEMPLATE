// UART Loopback Module
// module uart_loop_back (
// File: top.v
// Updated top module with revised time sender

module top (
    input clk,
    input uart_rx,
    output uart_tx,
    output reg [5:0] led,
    output [3:0] pwm_out,
    output time_tx  // UART TX for time sending
);
    wire [7:0] rxData;
    wire rxDataValid;
    reg [7:0] txData;
    reg txDataValid;
    wire txBusy;

    wire current_bit;  // Current bit being sent by time sender

    // Existing UART instances
    uart_rx #(.DELAY_FRAMES(69)) uart_rx_inst (
        .clk(clk), .uart_rx(uart_rx), .rxData(rxData), .rxDataValid(rxDataValid)
    );

    uart_tx #(.DELAY_FRAMES(69)) uart_tx_inst (
        .clk(clk), .txData(txData), .txDataValid(txDataValid),
        .txBusy(txBusy), .uart_tx(uart_tx)
    );

    // PWM generator instance
    pwm_generator #(.CLOCK_FREQ(8_000_000)) pwm_gen (
        .clk(clk),
        .pwm_out(pwm_out)
    );

    // Revised time sender instance
    time_sender #(.CLOCK_FREQ(8_000_000)) time_sender_inst (
        .clk(clk),
        .uart_tx(time_tx),
        .current_bit(current_bit)
    );

    // Existing UART loopback logic
    reg [7:0] loopback_buffer;
    reg loopback_ready = 0;

    always @(posedge clk) begin
        // Existing UART loopback logic
        if (rxDataValid) begin
            loopback_buffer <= rxData;
            loopback_ready <= 1;
        end

        if (loopback_ready && !txBusy) begin
            txData <= loopback_buffer;
            txDataValid <= 1;
            loopback_ready <= 0;
        end else if (!loopback_ready) begin
            txDataValid <= 0;
        end

        // Update LED display
        led[3:0] <= pwm_out;  // Show PWM outputs on LEDs
        led[5] <= current_bit;  // Show current bit being sent on LED[5]
    end

endmodule