//////////////////////////////////////////////////////////////////////////////////
// Company: Fival Science & Technology Co., Ltd.
// Engineer: yang.pf@fival.cn
// 
// Create Date: 2019/07/17
// Design Name: 
// Module Name: tester_gtx_gen
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
module tester_gtx_gen#
(
  parameter  IDLE      = 16'h02bc    
)
(
  input                       usrclk,
  input                       usrrst_n,
  input   [7:0]               test_len_ctrl,   // interval length of each set of data
  input                       test_run_ctrl,   // control signal to generate data
          
  output  [15:0]              txdata,          // generate data for gtx
  output  [1:0]               txchar           // control signal of data for gtx
          
);

  reg  [15:0]         gtx_data;
  reg  [1:0]          gtx_datk;
  reg  [8:0]          test_cnt;
  reg  [15:0]         data_cnt;
  reg                 data_flag;
  
  //period of data transmission      
  always @ (posedge usrclk or negedge usrrst_n) begin
    if (~usrrst_n) begin
    	test_cnt <= 9'd0;
    end
    else begin    	
	    if ((test_cnt == test_len_ctrl + 8'd32) && (test_run_ctrl == 1'b1)) begin
	    	test_cnt <= 9'd0;
	    end
	    else begin
	    	test_cnt <= test_cnt + 1'b1;
	    end
	  end
  end
    
  always @ (posedge usrclk or negedge usrrst_n) begin
    if (~usrrst_n) begin
    	data_flag <= 1'b0;
    end
    else begin
    	if ((test_cnt == test_len_ctrl + 8'd32) && (test_run_ctrl == 1'b1)) begin
	    	data_flag <= 1'b1;
	    end
	    else if (test_cnt == 8'd31) begin
	    	data_flag <= 1'b0;
	    end
	  end
  end      
      
  always @ (posedge usrclk or negedge usrrst_n) begin
    if (~usrrst_n) begin
    	data_cnt <= 16'd0;
    end
    else begin   	
	    if (data_flag) begin                                          
	      data_cnt <= data_cnt + 1'b1;           
	    end 
	  end   
  end     
  
  always @ (posedge usrclk or negedge usrrst_n) begin
    if (~usrrst_n) begin
    	gtx_data <= 16'd0;
    end 
    else begin
    	//transmit incremental data
	    if (data_flag) begin                                          
	      gtx_data <= data_cnt;           
	    end   
    	//transmit K character
	    else begin
	    	gtx_data <= IDLE; 
	    end   
	  end 
  end
  
  always @ (posedge usrclk or negedge usrrst_n) begin
    if (~usrrst_n) begin
    	gtx_datk <= 2'b0;
    end
    else begin
	    if (data_flag) begin                                          
	      gtx_datk <= 2'b0;           
	    end    
	    else begin
	    	gtx_datk <= 2'b01;
	    end
	  end
  end   

  assign txdata = gtx_data;
  assign txchar = gtx_datk;   
  
endmodule
