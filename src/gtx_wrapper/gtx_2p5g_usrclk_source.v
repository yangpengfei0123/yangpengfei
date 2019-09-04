//////////////////////////////////////////////////////////////////////////////////
// Company: Fival Science & Technology Co., Ltd.
// Engineer: yang.pf@fival.cn
// 
// Create Date: 2019/07/17
// Design Name: 
// Module Name: gtx_2p5G_usrclk_source
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
//***********************************Entity Declaration*******************************
`timescale 1ns / 1ps
`define DLY #1
module gtx_2p5G_usrclk_source 
#(
  parameter         CHNL_NUM  = 8,
  parameter         BUFG_NUM  = "single"  
)
(
  output       [CHNL_NUM-1:0]   txusrclk ,
  output       [CHNL_NUM-1:0]   txusrclk2,
  input        [CHNL_NUM-1:0]   txoutclk ,
  output       [CHNL_NUM-1:0]   rxusrclk ,
  output       [CHNL_NUM-1:0]   rxusrclk2,
  input        [CHNL_NUM-1:0]   rxoutclk
);

//*********************************Wire Declarations**********************************
 
  wire      [CHNL_NUM-1:0]      gt_txoutclk_i; 
  wire      [CHNL_NUM-1:0]      gt_rxoutclk_i;

  wire                          gt_txusrclk_i;
  wire      [CHNL_NUM-1:0]      gt_rxusrclk_i;

//*********************************** Beginning of Code *******************************

  assign gt_txoutclk_i = txoutclk;
  assign gt_rxoutclk_i = rxoutclk;

  BUFG 
  txoutclk_bufg0_i
  (
    .I   (gt_txoutclk_i[0]),
    .O   (gt_txusrclk_i)
  );
    
  generate
  genvar ch_id;
    if (BUFG_NUM == "single") begin    	
      BUFG 
      rxoutclk_bufg1_i
      (
        .I  (gt_rxoutclk_i[0]),
        .O  (gt_rxusrclk_i[0])
      );
      
      for (ch_id=0; ch_id<CHNL_NUM; ch_id=ch_id+1) begin: rxusrclk_bufg
        assign txusrclk[ch_id]  = gt_txusrclk_i;
        assign txusrclk2[ch_id] = gt_txusrclk_i;
        assign rxusrclk[ch_id]  = gt_rxusrclk_i[0];
        assign rxusrclk2[ch_id] = gt_rxusrclk_i[0];   	
      end
    end  
    
    else if (BUFG_NUM == "multi") begin
      for (ch_id=0; ch_id<CHNL_NUM; ch_id=ch_id+1) begin: rxusrclk_loop_2p5G
         BUFG 
         rxoutclk_bufg1_i
         (
           .I  (gt_rxoutclk_i[ch_id]),
           .O  (gt_rxusrclk_i[ch_id])
         );
         
        assign txusrclk[ch_id]  = gt_txusrclk_i;
        assign txusrclk2[ch_id] = gt_txusrclk_i;
        assign rxusrclk[ch_id]  = gt_rxusrclk_i[ch_id];
        assign rxusrclk2[ch_id] = gt_rxusrclk_i[ch_id];   
      end
    end
  endgenerate
 
endmodule
