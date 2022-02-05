//Name: uart_byte_tx.v
//Author: Melvin
//Revision: 1.1
//Date: 12/9/2021
//Description: version 1.0
//С÷��̴̳��ڵ�ʵ�֣�������о����Ǻ����ʣ���ÿһ��packageΪ10λ��
//������ʼλ��ֹͣλ���������ʵĹؼ����У�
//      1��Sent_enΪ0ʱ�������ʲô�źţ���������0��
//      2��Sent_enΪ1������û��ˢ��ʱ���������ʲô�źţ�������ظ����
//      ��һ��pakage��
//      3��һ��packageû�з�����ϣ���Sent_en�ж�Ϊ0���������ʲô�źţ�
//      ������ж��������Sent_en��0��1ʱ�������δ��ɵ�package��
//      �����¼�ʱ1bitʱ����
//Description: version 1.1
//С÷��̴̳��ڵ�ʵ�֣�������о����Ǻ����ʣ���ÿһ��packageΪ10λ��
//������ʼλ��ֹͣλ���������ʵĹؼ����У�
//      1��Sent_enΪ0ʱ�������ʲô�źţ���������1��(��Ϊ1Ϊֹͣ�źţ�0Ϊ��ʼ�źţ�
//      2��Sent_enΪ1������û��ˢ��ʱ���������ʲô�źţ�������ظ����
//      ��һ��pakage��
//      3��һ��packageû�з�����ϣ���Sent_en�ж�Ϊ0���������ʲô�źţ�
//      �����Sent_enΪ0ʱ�����������Ϊ1����Sent_en��0��1ʱ���¿�ʼ���δ��ɵ�package��

module uart_byte_tx(
    Clk,
    Reset_n,
    Sent_en,
    Data_byte,
    Baud_set,
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
    input [2:0]Baud_set;
    //test
    //reg [2:0]Baud_set = 3'b111;
    //transmiting data
    output reg Uart_tx;
    //finish flag
    output reg Tx_done;
    //state signal, 1 means sending
    output reg Uart_state;

    reg [16:0]baud;
    reg [16:0]CNT;
    //test CNT
    //reg [25:0]CNT;
    reg [9:0]uart_package;
   
    //reg [16:0]counter = 17'b0;
    
    //test baud counter bit
    reg [25:0]counter = 26'b0;
    reg [3:0]counter_bit = 4'b0;
    
    //baud set
    always@(*)begin
        case(Baud_set)
            3'b000: begin baud = 17'd9_600;   CNT = 17'd5_208;      end
            3'b001: begin baud = 17'd19_200;  CNT = 17'd2_604;      end
            3'b010: begin baud = 17'd38_400;  CNT = 17'd1_302;      end
            3'b011: begin baud = 17'd57_600;  CNT = 17'd868;        end
            3'b100: begin baud = 17'd115_200; CNT = 17'd434;        end
            default: begin baud = 17'd115_200; CNT = 17'd434;       end
            //test baud setting
            //3'b111: begin baud = 17'd1; CNT = 26'd50_000_000;   end            
        endcase
    end
    
    //===========================<�ֿ�����>=================================
    //==============================UART==================================== 
    //======================================================================
    //counting and counting for bit change
    always@(posedge Clk or negedge Reset_n)begin
        if(!Reset_n)begin
            counter <= 26'b0;
            counter_bit <= 4'b0;
        end
        else if(Sent_en)begin
            if(counter == CNT - 1)begin                          
                counter <= 17'd0;
                if(counter_bit ==  4'd10)
                    counter_bit <= 0;
                else
                    counter_bit <= counter_bit + 1;
            end
            else
                counter <= counter + 1;
        end
        else begin
            counter <= 0;
            counter_bit <= 0;
        end
    end
    //======================================================================
    //data tx
    always@(posedge Clk or negedge Reset_n)begin
        if(!Reset_n)begin
            Uart_state <= 1'b0;
            Uart_tx <= 1'b0;
            uart_package <= {1'b1, Data_byte, 1'b0};
        end
        else if(Sent_en)begin
            Uart_state <= 1'b1;
            if(counter_bit ==  4'd10)begin
                //buffer data after finished last package
                uart_package <= {1'b1,Data_byte,1'b0};
            end
            else begin
                Uart_tx <= uart_package[counter_bit];
            end
        end
        else if(!Sent_en)begin
            Uart_state <= 1'b0;
            Uart_tx <= 1'b1;
        end   
    end
    //======================================================================  
    //package finished flag
    reg reset_flag;
    always@(posedge Clk or negedge Reset_n)begin
        if(!Reset_n)begin
            Tx_done <= 1'b0;
            reset_flag <= 1'b1;
        end
        else if(reset_flag)begin
            reset_flag <= 1'b0;
        end
        else if(counter_bit == 4'd10)begin
            Tx_done <= 1'b1;
        end
        else if((counter_bit == 4'd1) || (!Sent_en))begin
            Tx_done <= 1'b0;
        end
    end
      
//    //UART    
//    always@(posedge Clk or negedge Reset_n)begin
//        if(!Reset_n)begin
//            counter <= 0;
//            counter_bit <= 4'b0;
//            Tx_done <= 0;
//            //buffer data when reset
//            uart_package <= {1'b1,Data_byte,1'b0};
//        end
//        //sending
//        else if(Sent_en == 1)begin
//            Uart_state <= 1'b1;
//            if(counter_bit ==  4'd10)begin
//                //buffer data after finished last package
//                uart_package <= {1'b1,Data_byte,1'b0};
//                counter_bit <= 4'b0;
//                Tx_done <= 0;
//            end
//            else begin
//                Uart_tx <= uart_package[counter_bit];
//            end
//            //flag for package finished 
//            if(counter_bit == 4'd9)begin
//               Tx_done <= 1; 
//            end           
//            //counting for bit change
//            if(counter == CNT - 1)begin                          
//                counter_bit <= counter_bit + 1;
//                counter <= 17'd0;
//            end
//            else
//                counter <= counter + 1;
//        end
//        //unsending
//        else if(Sent_en != 1)begin
//            Uart_state <= 1'b0;
//            Uart_tx <= 1'b1;
//            counter <= 17'd0;
//            counter_bit <= 4'b0;
//        end   
//    end 

endmodule