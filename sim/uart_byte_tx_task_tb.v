`timescale 1ns/1ns

module uart_byte_tx_task_tb();
    reg Clk;
    reg Reset_n;
    reg Sent_en;
    reg [7:0]Data_byte;
    reg [2:0]Baud_set;
    
    wire Uart_tx;
    wire Tx_done;
    wire Uart_state;
    
    uart_byte_tx UART_BYTE_TX_0(
        .Clk(Clk),
        .Reset_n(Reset_n),
        .Sent_en(Sent_en),
        .Data_byte(Data_byte),
        .Baud_set(Baud_set),
        .Uart_tx(Uart_tx),
        .Tx_done(Tx_done),
        .Uart_state(Uart_state)
        );
    initial Clk = 1;
    always #10 Clk = !Clk;
    
    initial begin
        Reset_n = 0;
        Sent_en = 0;
        Baud_set = 3'b_100;
        Data_byte = 8'b0000_0000;
        #200
        Reset_n = 1;  
    end
    always #10000000 begin
        Sent_en <= 1;
        #100000
        Sent_en <= 0;
        Data_byte = Data_byte + 8'd1;

//        if(Tx_done)begin
//            Sent_en <= 0;
//        end
    end
    
    
endmodule