// UART Receiver Module
module uart_rx #(
    parameter DELAY_FRAMES = 234 // 27,000,000 (27Mhz) / 115200 Baud rate  
) (
    input clk,
    input uart_rx,
    output reg [7:0] rxData,
    output reg rxDataValid
);
    localparam HALF_DELAY_WAIT = (DELAY_FRAMES / 2);
    reg [3:0] rxState = 0;
    reg [12:0] rxCounter = 0; 
    reg [2:0] rxBitNumber = 0;
    localparam RX_STATE_IDLE = 0;
    localparam RX_STATE_START_BIT = 1;
    localparam RX_STATE_READ_WAIT = 2;  
    localparam RX_STATE_READ = 3;
    localparam RX_STATE_STOP_BIT = 5;

    always @(posedge clk) begin
        case (rxState)
            RX_STATE_IDLE: begin
                rxDataValid <= 0;
                if (uart_rx == 0) begin
                    rxState <= RX_STATE_START_BIT;
                    rxCounter <= 1;
                    rxBitNumber <= 0;
                end
            end 
            RX_STATE_START_BIT: begin
                if (rxCounter == HALF_DELAY_WAIT) begin
                    rxState <= RX_STATE_READ_WAIT;
                    rxCounter <= 1;
                end else 
                    rxCounter <= rxCounter + 1;
            end
            RX_STATE_READ_WAIT: begin
                rxCounter <= rxCounter + 1;
                if (rxCounter == DELAY_FRAMES - 2) begin
                    rxState <= RX_STATE_READ;
                end
            end
            RX_STATE_READ: begin
                rxCounter <= 1;
                rxData <= {uart_rx, rxData[7:1]};
                rxBitNumber <= rxBitNumber + 1;
                if (rxBitNumber == 3'b111)
                    rxState <= RX_STATE_STOP_BIT;
                else
                    rxState <= RX_STATE_READ_WAIT;
            end
            RX_STATE_STOP_BIT: begin
                rxCounter <= rxCounter + 1;
                if (rxCounter == DELAY_FRAMES - 1) begin
                    rxState <= RX_STATE_IDLE;
                    rxDataValid <= 1;
                end
            end
        endcase
    end
endmodule