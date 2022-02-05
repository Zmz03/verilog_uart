//Version: 1.0 tob（板上调试）
//Date: 12/9/2021
//Description: version 1.0
//小梅哥教程串口的实现（需求定义感觉不是很明朗）。每一个package为10位，
//包括起始位和停止位。需求不明朗的关键点有：
//      1、Sent_en为0时串口输出什么信号？本设计输出0；
//      2、Sent_en为1但数据没有刷新时，串口输出什么信号？本设计重复输出
//      上一个pakage；
//      3、一个package没有发送完毕，但Sent_en中断为0，串口输出什么信号？
//      本设计中断输出，且Sent_en由0变1时继续输出未完成的package，
//      且重新计时1bit时长；

module uart_byte_tx_tob(
    Clk,
    Reset_n,
    Sent_en,
    Data_byte,
    //Baud_set,
    Uart_tx,
    Tx_done,
    Uart_state
    );
    //system clock, reset signal
    input Clk;
    input Reset_n;
    //sent enable
    input Sent_en;
    //data to be sent
    input [7:0]Data_byte;
    //baud setting
    //input [2:0]Baud_set = 3'b111;
    //test
    reg [2:0]Baud_set = 3'b111;
    //transmiting data
    output reg Uart_tx;
    //finish flag
    output reg Tx_done;
    //state signal, 1 means sending
    output reg Uart_state;
    
    reg [16:0]baud;
    //reg [16:0]CNT;
    //test CNT
    reg [25:0]CNT;
    reg [9:0]uart_package;
   
    //reg [16:0]counter = 17'b0;
    
    //test baud counter bit
    reg [25:0]counter = 26'b0;
    reg [3:0]counter_bit = 4'b0;
    
    //baud set
    always@(*)begin
        case(Baud_set)
            3'b000: begin baud = 17'd9_600;   CNT = 17'd5_208;  end
            3'b001: begin baud = 17'd19_200;  CNT = 17'd2_604;  end
            3'b010: begin baud = 17'd38_400;  CNT = 17'd1_302;  end
            3'b011: begin baud = 17'd57_600;  CNT = 17'd868;    end
            3'b100: begin baud = 17'd115_200; CNT = 17'd434;    end
            //test baud setting
            3'b111: begin baud = 17'd1; CNT = 26'd50_000_000;   end            
        endcase
    end
    
    //UART    
    always@(posedge Clk or negedge Reset_n)begin
        if(!Reset_n)begin
            counter <= 0;
            counter_bit <= 4'b0;
            Tx_done <= 0;
            //buffer data when reset
            uart_package <= {1'b1,Data_byte,1'b0};
        end
        //sending
        else if(Sent_en == !1)begin
            Uart_state <= 1'b1;
            if(counter_bit ==  4'd10)begin
                //buffer data after finished last package
                uart_package <= {1'b1,Data_byte,1'b0};
                counter_bit <= 4'b0;
                Tx_done <= 0;
            end
            else begin
                Uart_tx <= uart_package[counter_bit];
            end
            //package finished flag
            if(counter_bit == 4'd9)begin
               Tx_done <= 1; 
            end           
            //counting for bit change
            if(counter == CNT - 1)begin                          
                counter_bit <= counter_bit + 1;
                counter <= 17'd0;
            end
            else
                counter <= counter + 1;
        end
        //unsending
        else if(Sent_en == 1)begin
            Uart_state <= 1'b0;
            Uart_tx <= 1'b0;
            counter <= 17'd0;
        end   
    end
    


endmodule