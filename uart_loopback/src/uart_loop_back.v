// UART Loopback Module
// module uart_loop_back (

module top (
    input clk,
    input uart_rx,
    output uart_tx,
    output reg [5:0] led,
    output [3:0] pwm_out
);
    wire [7:0] rxData;
    wire rxDataValid;
    reg [7:0] txData;
    reg txDataValid;
    wire txBusy;

    // UART instances
    uart_rx #(.DELAY_FRAMES(69)) uart_rx_inst (
        .clk(clk), .uart_rx(uart_rx), .rxData(rxData), .rxDataValid(rxDataValid)
    );

    uart_tx #(.DELAY_FRAMES(69)) uart_tx_inst (
        .clk(clk), .txData(txData), .txDataValid(txDataValid),
        .txBusy(txBusy), .uart_tx(uart_tx)
    );

    // PWM generator instance (remains unchanged)
    pwm_generator #(.CLOCK_FREQ(8_000_000)) pwm_gen (
        .clk(clk),
        .pwm_out(pwm_out)
    );

    // Improved UART loopback
    reg [7:0] loopback_buffer;
    reg loopback_ready = 0;

    always @(posedge clk) begin
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
    end

    // LED control - shows all PWM outputs (remains unchanged)
    always @(posedge clk) begin
        led[3:0] <= pwm_out;  // Show all PWM outputs on LEDs
        led[5:4] <= 2'b00;    // Turn off unused LEDs
    end

endmodule