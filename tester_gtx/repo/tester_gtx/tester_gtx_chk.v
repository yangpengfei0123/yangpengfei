//////////////////////////////////////////////////////////////////////////////////
// Company: Fival Science & Technology Co., Ltd.
// Engineer: yang.pf@fival.cn
// 
// Create Date: 2019/07/17
// Design Name: 
// Module Name: tester_gtx_chk
// Project Name: tester_gtx
// Target Devices: k7 serials 
// Tool Versions: vivado 2016.4
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module tester_gtx_chk#
(
  parameter  IDLE      = 16'h02bc    
)
(
  input     [15:0]     rx_data,
  input     [ 1:0]     rx_char,
  input                usrclk ,
  input                usrrst_n,
  output               err_flag,  //data error flag   
  output    [15:0]     der        //data error rate   
);
  reg  [15:0]     rx_data_r;
  reg             data_err_flag ;        
  reg  [15:0]     data_err_rate ;  
  reg  [15:0]     err_cnt  ;
  reg  [15:0]     cnt_10000;
    
  always @ (posedge usrclk or negedge usrrst_n) begin
    if (~usrrst_n) begin
      rx_data_r  <= 16'b0;
    end 
    else begin
	    if (rx_char == 2'b0) begin    
	    	rx_data_r  <= rx_data;
	    end
	  end
  end    
    
  always @ (posedge usrclk or negedge usrrst_n) begin
    if (~usrrst_n) begin      
      data_err_flag <= 1'b0;
    end
    else begin
    	//receive data check
	    if (rx_char == 2'b00 && rx_data == rx_data_r+1'b1) begin    
	    	data_err_flag <= 1'b0;
	    end
	    //K character (IDLE) check
	    else if (rx_char == 2'b01 && rx_data == IDLE) begin   
	    	data_err_flag <= 1'b0;
	    end    
	    else begin
	    	data_err_flag <= 1'b1;
	    end 
	  end
  end  

  always @ (posedge usrclk or negedge usrrst_n) begin
  	if (~usrrst_n) begin
  		cnt_10000 <= 16'd0;
  	end
  	else begin
  		if (cnt_10000 == 16'd9_999 && rx_char == 1'b0) begin
  			cnt_10000 <= 16'd0;
  		end
  		else if (rx_char == 1'b0) begin
  			cnt_10000 <= cnt_10000 + 1'b1;
  		end
  	end
  end
    
  always @ (posedge usrclk or negedge usrrst_n) begin
  	if (~usrrst_n) begin
  		err_cnt <= 16'b0;
  	end
  	else begin
  		if (cnt_10000 == 16'd9_999 && rx_char == 1'b0) begin
  			err_cnt <= 16'b0;
  		end
  		//count error number
  		else if (data_err_flag == 1'b1) begin
  			err_cnt <= err_cnt + 1'b1;
  		end
  	end
  end
  
  always @ (posedge usrclk or negedge usrrst_n) begin
  	if (~usrrst_n) begin
  		data_err_rate <= 16'b0;
    end
    else begin
    	//number of error per 10000 data
    	if (cnt_10000 == 16'd9_999&&rx_char == 1'b0) begin
    		data_err_rate <= err_cnt;            
    	end
    end
  end
  
  assign err_flag     = data_err_flag;
  assign der          = data_err_rate;
endmodule
