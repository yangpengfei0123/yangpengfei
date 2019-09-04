//////////////////////////////////////////////////////////////////////////////////
// Company: Fival Science & Technology Co., Ltd.
// Engineer: yang.pf@fival.cn
// 
// Create Date: 2019/07/17
// Design Name: 
// Module Name: gtx_3p125G_usrclk_source
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
module gtx_3p125G_usrclk_source 
#(
  parameter         CHNL_NUM  = 8,
  parameter         BUFG_NUM  = "single"
)
(
 
  output    [CHNL_NUM-1:0]      txusrclk,
  output    [CHNL_NUM-1:0]      txusrclk2,
  input     [CHNL_NUM-1:0]      txoutclk,
  output    [CHNL_NUM-1:0]      tx_mmcm_lock,
  input     [CHNL_NUM-1:0]      tx_mmcm_reset,
  output    [CHNL_NUM-1:0]      rxusrclk,
  output    [CHNL_NUM-1:0]      rxusrclk2,
  input     [CHNL_NUM-1:0]      rxoutclk,
  output    [CHNL_NUM-1:0]      rx_mmcm_lock,
  input     [CHNL_NUM-1:0]      rx_mmcm_reset

);

//*********************************Wire Declarations**********************************
 
  wire    [CHNL_NUM-1:0]         gt_txoutclk_i; 
  wire    [CHNL_NUM-1:0]         gt_rxoutclk_i;

  wire                          gt_txusrclk_i;
  wire    [CHNL_NUM-1:0]        gt_rxusrclk_i;
  wire                          txoutclk_mmcm0_locked_i;
  wire    [CHNL_NUM-1:0]        txoutclk_mmcm0_reset_i;
  wire    [CHNL_NUM-1:0]        rxoutclk_mmcm1_locked_i;
  wire    [CHNL_NUM-1:0]        rxoutclk_mmcm1_reset_i;

//********************************* Beginning of Code *******************************

  //  Static signal Assigments    
  assign gt_txoutclk_i = txoutclk;
  assign gt_rxoutclk_i = rxoutclk;

  // Instantiate a MMCM module to divide the reference clock. Uses internal feedback
  // for improved jitter performance, and to avoid consuming an additional BUFG

  assign  txoutclk_mmcm0_reset_i               =  tx_mmcm_reset;
  gtx_3p125G_CLOCK_MODULE #
  (
    .MULT                           (5.0),
    .DIVIDE                         (1),
    .CLK_PERIOD                     (8.0),
    .OUT0_DIVIDE                    (4.0),
    .OUT1_DIVIDE                    (1),
    .OUT2_DIVIDE                    (1),
    .OUT3_DIVIDE                    (1)
  )
  txoutclk_mmcm
  (
    .clk_out0                       (gt_txusrclk_i),
    .clk_out1                       (),
    .clk_out2                       (),
    .clk_out3                       (),
    .clk_in1                        (gt_txoutclk_i[0]),
    .mmcm_lock                      (txoutclk_mmcm0_locked_i),
    .mmcm_reset                     (txoutclk_mmcm0_reset_i[0])
  );

  assign  rxoutclk_mmcm1_reset_i               =  rx_mmcm_reset;

  generate
  genvar ch_id;  
    if (BUFG_NUM == "single") begin    
          gtx_3p125G_CLOCK_MODULE #
      (
        .MULT                           (5.0),
        .DIVIDE                         (1),
        .CLK_PERIOD                     (8.0),
        .OUT0_DIVIDE                    (4.0),
        .OUT1_DIVIDE                    (1),
        .OUT2_DIVIDE                    (1),
        .OUT3_DIVIDE                    (1)
      )
      rxoutclk_mmcm
      (
        .clk_out0                       (gt_rxusrclk_i[0]),
        .clk_out1                       (),
        .clk_out2                       (),
        .clk_out3                       (),
        .clk_in1                        (gt_rxoutclk_i[0]),
        .mmcm_lock                      (rxoutclk_mmcm1_locked_i[0]),
        .mmcm_reset                     (rxoutclk_mmcm1_reset_i[0])
      ); 	
      for (ch_id=0; ch_id<CHNL_NUM; ch_id=ch_id+1) begin: rxusrclk_bufg
        assign txusrclk[ch_id]     = gt_txusrclk_i;
        assign txusrclk2[ch_id]    = gt_txusrclk_i;
        assign tx_mmcm_lock[ch_id] = txoutclk_mmcm0_locked_i;
        assign rxusrclk[ch_id]     = gt_rxusrclk_i[0];
        assign rxusrclk2[ch_id]    = gt_rxusrclk_i[0];
        assign rx_mmcm_lock[ch_id] = rxoutclk_mmcm1_locked_i[0];  
      end
    end     	
    
    else if (BUFG_NUM == "multi") begin              	
      for (ch_id=0; ch_id<CHNL_NUM; ch_id=ch_id+1) begin: rxusrclk_loop_3p125G
        gtx_3p125G_CLOCK_MODULE #
        (
          .MULT                           (5.0),
          .DIVIDE                         (1),
          .CLK_PERIOD                     (8.0),
          .OUT0_DIVIDE                    (4.0),
          .OUT1_DIVIDE                    (1),
          .OUT2_DIVIDE                    (1),
          .OUT3_DIVIDE                    (1)
        )
        rxoutclk_mmcm
        (
          .clk_out0                       (gt_rxusrclk_i[ch_id]),
          .clk_out1                       (),
          .clk_out2                       (),
          .clk_out3                       (),
          .clk_in1                        (gt_rxoutclk_i[ch_id]),
          .mmcm_lock                      (rxoutclk_mmcm1_locked_i[ch_id]),
          .mmcm_reset                     (rxoutclk_mmcm1_reset_i[ch_id])
        ); 
           
        assign txusrclk[ch_id]     = gt_txusrclk_i;
        assign txusrclk2[ch_id]    = gt_txusrclk_i;
        assign tx_mmcm_lock[ch_id] = txoutclk_mmcm0_locked_i;
        assign rxusrclk[ch_id]     = gt_rxusrclk_i[ch_id];
        assign rxusrclk2[ch_id]    = gt_rxusrclk_i[ch_id];
        assign rx_mmcm_lock[ch_id] = rxoutclk_mmcm1_locked_i[ch_id];    
      end
    end
  endgenerate
 
endmodule
