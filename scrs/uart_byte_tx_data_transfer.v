module uart_byte_tx_data_transfer(
    Clk,
    Reset_n,
    //Sent_en,
    //Data_byte,
    //Baud_set,
    //Tx_done,
    Uart_tx
    );

    input Clk;
    input Reset_n;
    //input Tx_done;			//finished signal

    output Uart_tx;

    reg Sent_en;
    reg [7:0]Data_byte;
    //output reg [2:0]Baud_set = 3'b100;
    
    
    reg [18:0]counter;
    
    reg tx_done_flag;

    wire Tx_done;
    wire Uart_state;

    uart_byte_tx UART_BYTE_TX_0(
        .Clk(Clk),
        .Reset_n(Reset_n),
        .Sent_en(Sent_en),
        .Data_byte(Data_byte),
        .Baud_set(3'b100),
        .Uart_tx(Uart_tx),
        .Tx_done(Tx_done),
        .Uart_state(Uart_state)
        );
    //设置波特率


    //对使能信号的控制 
    always@(posedge Clk or negedge Reset_n)begin 
        if(!Reset_n)begin
            counter <= 0;
            Sent_en <= 1;
            tx_done_flag <= 0;
        end
        else if(counter == 4340)begin
            Sent_en <= 0;
            counter <= counter + 1;
        end
        else if(counter == 500000 - 1)begin
           counter <= 0;
           Sent_en <= 1;
        end
        else begin
            counter <= counter + 1;
        end

        // if(counter == 4340)begin
        //     Sent_en <= 0;
        // end
        

        // else if(!tx_done_flag)begin    
        //     if(Tx_done)begin
        //         tx_done_flag <= 1;
        //         Sent_en <= 0;
        //     end
        // end

        // else if(counter == 434 - 1)begin
        //     tx_done_flag <= 0;
        //     counter <= counter + 1;
        // end

        // else 
        //     counter <= counter + 1;
    end
    

    //待发送数据的更改（递增）
    always@(posedge Clk or negedge Reset_n)begin 
	if(!Reset_n)
	    Data_byte <= 0;
	else if(counter == 500000 - 1)
	    Data_byte <= Data_byte + 1;
    end

endmodule