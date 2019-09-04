//////////////////////////////////////////////////////////////////////////////////
// Company: Fival Science & Technology Co., Ltd.
// Engineer: yang.pf@fival.cn
// 
// Create Date: 2019/07/17
// Design Name: 
// Module Name: tester_gtx_top
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
`include "gtx_par.vh"
module truck_tester_gtx_top 
(
  input                      DRP_CLK,
  input                      GTREFCLK_N,
  input                      GTREFCLK_P,
  input     [CHNL_NUM-1:0]   RXN,
  input     [CHNL_NUM-1:0]   RXP,
  output    [CHNL_NUM-1:0]   TXN,
  output    [CHNL_NUM-1:0]   TXP
);

  wire clk100;
  
  clk_100m_modu 
  clk_100m_modu_inst
  (
    .clk_out1(clk100),  // output clk_out1
    .clk_in1 (DRP_CLK)  // input clk_in1
  );     
  
  wire                    usrrst_n;
  wire                    txusrclk2;
  wire [CHNL_NUM-1:0]     rxusrclk2;
  wire [15:0]             txdata;
  wire [1:0]              txchar;
  wire [7:0]              err_flag;
  wire [127:0]            rxdata;
  wire [15:0]             rxchar; 
  wire [127:0]            der;
  
  gtx_wrapper
  #(
    .LANE_RATE (LANE_RATE),  //"2p5G" or "3p125G"
    .CHNL_NUM  (CHNL_NUM),   //1~8
    .BUFG_NUM  (BUFG_NUM)    //"single" or "multi"   
  )
  gtx_wrapper_inst 
  (
    .clk100                    (clk100),
    .txusrclk2                 (txusrclk2),  
    .usrrst_n                  (usrrst_n),
    .txdata                    ({CHNL_NUM{txdata}}),
    .txchar                    ({CHNL_NUM{txchar}}),
    .rxdata                    (rxdata),
    .rxchar                    (rxchar),
    .rxusrclk2                 (rxusrclk2),   
    .GTREFCLK_N                (GTREFCLK_N),
    .GTREFCLK_P                (GTREFCLK_P),
    .RXN                       (RXN),
    .RXP                       (RXP),
    .TXN                       (TXN),
    .TXP                       (TXP)
  );
  
  wire [7:0] test_len_ctrl;
  wire       test_run_ctrl;
  
  tester_gtx_gen   
  #(
    .IDLE        (IDLE)  
  )                    
  tester_gtx_gen_inst 
  (
    .usrclk        (txusrclk2),
    .usrrst_n      (usrrst_n),
    .test_len_ctrl (test_len_ctrl),
    .test_run_ctrl (test_run_ctrl),
    .txdata        (txdata),
    .txchar        (txchar)
  );
  generate
  genvar ch_id;
    for (ch_id=0; ch_id<CHNL_NUM; ch_id=ch_id+1) begin: gtx_test_check_loop
      tester_gtx_chk
      #(
        .IDLE          (IDLE)  
      )
      tester_gtx_chk_inst
      (
        .rx_data         (rxdata[ch_id*16+15:ch_id*16]),
        .rx_char         (rxchar[ch_id*2+1:ch_id*2]   ),
        .usrclk          (rxusrclk2[ch_id]            ),
        .usrrst_n        (usrrst_n                    ),
        
        .err_flag        (err_flag[ch_id]             ),     
        .der             (der[ch_id*16+15:ch_id*16]   )  //data error rate
      );
    end
  endgenerate
  
  vio_0 
  vio_0_inst 
  (
    .clk        (txusrclk2  ),
    .probe_out0 (test_len_ctrl),
    .probe_out1 (test_run_ctrl),
    .probe_out2 (usrrst_n  )
  );
  
  ila_1
  ila_1_inst 
  (
	  .clk(rxusrclk2[0]), // input wire clk    
    .probe0({rxdata[15 :0  ],rxchar[1 :0 ],err_flag[0], der[15 :0  ]}), // input wire [34:0]  probe0  
    .probe1({rxdata[31 :16 ],rxchar[3 :2 ],err_flag[1], der[31 :16 ]}), // input wire [34:0]  probe1 
    .probe2({rxdata[47 :32 ],rxchar[5 :4 ],err_flag[2], der[47 :32 ]}), // input wire [34:0]  probe2 
    .probe3({rxdata[63 :48 ],rxchar[7 :6 ],err_flag[3], der[63 :48 ]}), // input wire [34:0]  probe3 
    .probe4({rxdata[79 :64 ],rxchar[9 :8 ],err_flag[4], der[79 :64 ]}), // input wire [34:0]  probe4 
    .probe5({rxdata[95 :80 ],rxchar[11:10],err_flag[5], der[95 :80 ]}), // input wire [34:0]  probe5 
    .probe6({rxdata[111:96 ],rxchar[13:12],err_flag[6], der[111:96 ]}), // input wire [34:0]  probe6 
    .probe7({rxdata[127:112],rxchar[15:14],err_flag[7], der[127:112]}) // input wire [34:0]  probe7
  );
    
endmodule
    

