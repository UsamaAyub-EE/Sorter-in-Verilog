`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2021 08:30:47 PM
// Design Name: 
// Module Name: Lab2_Sequential
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Lab2_Sequential(

input [3:0] num,input sort,clock,output reg [6:0] seg,input [1:0] sel,input write,
output reg [3:0] anodes
    );
    reg [3:0] numbers[0:3];
    reg [3:0] sorted[0:3];
    reg [3:0] display[0:3];
    reg [2:0]state; 
    reg [3:0] out;
    reg [1:0] index;
    reg reg_write,reg_sort,reg_sorted;
    parameter INPUT=0, SORTED =1, UNSORTED=2,SORT=3,INCREMENT=4,COMPARE=5;
    integer i;
    initial begin
        for(i=0;i<4;i=i+1)
            numbers[i]=0;
    end
    always @(*) begin
            case(out)
            4'b0000: seg = 7'b0000001; // "0"     
            4'b0001: seg = 7'b1001111; // "1" 
            4'b0010: seg = 7'b0010010; // "2" 
            4'b0011: seg = 7'b0000110; // "3" 
            4'b0100: seg = 7'b1001100; // "4" 
            4'b0101: seg = 7'b0100100; // "5" 
            4'b0110: seg = 7'b0100000; // "6" 
            4'b0111: seg = 7'b0001111; // "7" 
            4'b1000: seg = 7'b0000000; // "8"     
            4'b1001: seg = 7'b0000100; // "9"
            4'b1010: seg = 7'b0001000; // "A"     
            4'b1011: seg = 7'b1100000; // "b"     
            4'b1100: seg = 7'b0110001; // "C"     
            4'b1101: seg = 7'b1000010; // "d"     
            4'b1110: seg = 7'b0110000; // "E"     
            4'b1111: seg = 7'b0111000; // "F"     
            default: seg = 7'b0000001; // "0"
            endcase
        end

    initial begin
        state = UNSORTED;
    end
    always @(posedge clock)
    begin
        reg_write <= write;
        reg_sort <= sort;
        case (state)
        SORT:
        begin
            for(i=0;i<4;i=i+1)
            begin
                sorted[i]=numbers[i];
            end
            reg_sorted<=1;
            index<=0;
            state <= COMPARE;
        end
        INCREMENT:
        begin
            if(index==2 && reg_sorted ==1)
                state <= SORTED;
            else if(index==2)
            begin
                index <= 0;
                reg_sorted <= 1;
                state <= COMPARE;
            end
            else
            begin
                index <= index + 1;
                state <= COMPARE;
            end
        end
		COMPARE:
        begin
            if(sorted[index] > sorted[index+1])
            begin
                sorted[index] <= sorted[index+1];
                sorted[index+1] <= sorted[index];
                reg_sorted <= 0;
                index <= 0;
                state <= COMPARE;
            end
            else
                state <= INCREMENT;
        end
        SORTED:
        begin
            for(i=0;i<4;i=i+1)
            begin
                display[i]=sorted[i];
            end
            if(reg_write)
                state<=INPUT;
            else if(reg_sort && reg_sorted)
                state<=SORTED;
            else if(reg_sort && !reg_sorted)
                state <= SORT;
            else
                state<=UNSORTED;
        end
        UNSORTED:
        begin
            for(i=0;i<4;i=i+1)
            begin
               display[i]=numbers[i];
            end
            if(reg_write)
                state<=INPUT;
            else if(reg_sort && reg_sorted)
                state<=SORTED;
            else if(reg_sort && !reg_sorted)
                state <= SORT;
            else
                state<=UNSORTED;
        end
        INPUT:
        begin
            numbers[sel]=num;
            reg_sorted <= 0;
			for(i=0;i<4;i=i+1)
            begin
               display[i]=numbers[i];
            end
            if(reg_write)
                state<=INPUT;
            else if(reg_sort && reg_sorted)
                state<=SORTED;
            else if(reg_sort && !reg_sorted)
                state <= SORT;
            else
                state<=UNSORTED;
        end
        
		default:
			state <=UNSORTED;
        endcase
    end
	reg [22:0] count_50Hz;
	reg clock_50Hz;
	initial begin
		count_50Hz=0;
		clock_50Hz=0;
	end
	always @(posedge clock)
	begin
		count_50Hz <= count_50Hz + 1;
		if(count_50Hz == 2000000)
		begin
			count_50Hz <= 0;
			clock_50Hz <= !clock_50Hz;
		end
	end
	reg clock_25Hz;
	initial begin
		clock_25Hz=0;
	end
    always @(posedge clock_50Hz)
		clock_25Hz <= !clock_25Hz;
	always @(clock_25Hz or clock_50Hz or display[0] or display[1] or display[2] or display[3])
	begin
		if(clock_25Hz && clock_50Hz)
		begin
			out = display[0];
			anodes=4'b0111;
		end
		else if(clock_25Hz && !clock_50Hz)
		begin
			out = display[1];
			anodes=4'b1011;
		end
		else if(!clock_25Hz && clock_50Hz)
		begin
			out = display[2];
			anodes=4'b1101;
		end
		else
		begin
			out = display[3];
			anodes=4'b1110;
		end
	end
	
endmodule
