module top (
    input clk,
    input uart_rx,
    output uart_tx,
    output reg [5:0] led,
    output [3:0] pwm_out,
    output time_tx
);
    wire [7:0] rxData;
    wire rxDataValid;
    reg [7:0] txData;
    reg txDataValid;
    wire txBusy;

    wire current_bit;

    uart_rx #(.DELAY_FRAMES(69)) uart_rx_inst (
        .clk(clk), .uart_rx(uart_rx), .rxData(rxData), .rxDataValid(rxDataValid)
    );

    uart_tx #(.DELAY_FRAMES(69)) uart_tx_inst (
        .clk(clk), .txData(txData), .txDataValid(txDataValid),
        .txBusy(txBusy), .uart_tx(uart_tx)
    );

    pwm_generator pwm_gen (
        .clk(clk),
        .pwm_out(pwm_out)
    );
    
    time_sender #(.CLOCK_FREQ(8_000_000)) time_sender_inst (
        .clk(clk),
        .uart_tx(time_tx),
        .current_bit(current_bit)
    );

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

        led[3:0] <= pwm_out;
        led[5] <= current_bit;
    end

endmodule