//////////////////////////////////////////////////////////////////////////////////
// Company: Fival Science & Technology Co., Ltd.
// Engineer: yang.pf@fival.cn
// 
// Create Date: 2019/07/17
// Design Name: 
// Module Name: gtx_wrapper
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
`define DLY #1
module gtx_wrapper#
(
  parameter EXAMPLE_SIM_GTRESET_SPEEDUP            = "TRUE"  ,     // Simulation setting for GT SecureIP model
  parameter STABLE_CLOCK_PERIOD                    = 10      ,    //Period of the stable clock driving this state-machine, unit is [ns]
  parameter LANE_RATE                              = "3p125G",   
  parameter CHNL_NUM                               = 8       ,
  parameter BUFG_NUM                               = "single"     
)
(
  input                       clk100,
  output                      txusrclk2,
  output     [CHNL_NUM-1:0]   rxusrclk2,
  input                       GTREFCLK_N,
  input                       GTREFCLK_P,
  input                       usrrst_n,
           
  input      [127:0]          txdata,
  input      [15:0]           txchar,
  output     [127:0]          rxdata,
  output     [15:0]           rxchar,
           
  input      [CHNL_NUM-1:0]   RXN,
  input      [CHNL_NUM-1:0]   RXP,
  output     [CHNL_NUM-1:0]   TXN,
  output     [CHNL_NUM-1:0]   TXP
);

//**************************** Wire Declarations ******************************//
  wire   [CHNL_NUM-1:0]         gt_tx_fsm_reset_done_i;
  wire   [CHNL_NUM-1:0]         gt_rx_fsm_reset_done_i;
  wire   [CHNL_NUM-1:0]         gt_data_valid_i ;
                                
  wire   [CHNL_NUM-1:0]         gt_rxoutclk_i  ;
  wire   [CHNL_NUM-1:0]         gt_txoutclk_i  ;
  
  //----------------------------- Global Signals -----------------------------¡¢
  wire                          sysclk_in_i;
  
  //--------------------------- User Clocks ---------------------------------
  wire   [CHNL_NUM-1:0]         gt_txusrclk_i ; 
  wire   [CHNL_NUM-1:0]         gt_txusrclk2_i ; 
  wire   [CHNL_NUM-1:0]         gt_rxusrclk_i ; 
  wire   [CHNL_NUM-1:0]         gt_rxusrclk2_i ; 

  wire   [CHNL_NUM-1:0]         gt_txmmcm_lock_i;
  wire   [CHNL_NUM-1:0]         gt_txmmcm_reset_i;
  wire   [CHNL_NUM-1:0]         gt_rxmmcm_lock_i; 
  wire   [CHNL_NUM-1:0]         gt_rxmmcm_reset_i; 
  
  //------------------------------- CPLL Ports -------------------------------
  wire   [CHNL_NUM-1:0]         gt_cpllfbclklost_i ;
  wire   [CHNL_NUM-1:0]         gt_cplllock_i ;
  //-------------------------- Channel - DRP Ports  --------------------------
  
  wire   [CHNL_NUM*16-1:0]      gt_drpdo_i ;
  wire   [CHNL_NUM-1:0]         gt_drprdy_i ;
  //------------------------- Digital Monitor Ports --------------------------
  wire   [CHNL_NUM*8-1:0]       gt_dmonitorout_i ;  
  //------------------------ RX Margin Analysis Ports ------------------------
  wire   [CHNL_NUM-1:0]         gt_eyescandataerror_i ; 
  //----------------- Receive Ports - Clock Correction Ports -----------------
  wire   [CHNL_NUM*2-1:0]       gt_rxclkcorcnt_i ; 
  //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
  wire   [CHNL_NUM*2-1:0]       gt_rxdisperr_i ;
  wire   [CHNL_NUM*2-1:0]       gt_rxnotintable_i ; 
  //------------------- Receive Ports - RX Equalizer Ports -------------------
  wire   [CHNL_NUM*7-1:0]       gt_rxmonitorout_i ;
  //------------- Receive Ports - RX Fabric Output Control Ports -------------
  wire   [CHNL_NUM-1:0]         gt_rxoutclkfabric_i ;
  //------------ Receive Ports -RX Initialization and Reset Ports ------------
  wire   [CHNL_NUM-1:0]         gt_rxresetdone_i ;
  //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
  wire   [CHNL_NUM-1:0]         gt_txoutclkfabric_i ;
  wire   [CHNL_NUM-1:0]         gt_txoutclkpcs_i;
  //----------- Transmit Ports - TX Initialization and Reset Ports -----------
  wire   [CHNL_NUM-1:0]         gt_txresetdone_i ;

  
  //--------------------------- Reference Clocks ----------------------------  
  wire            clk_refclk_i;

//**************************** Main Body of Code *******************************
   
 // assign gt_data_valid_i      = 8'hFF;   

  assign  sysclk_in_i = clk100;
  
  assign  soft_reset_tx_i = usrrst_n;
  assign  soft_reset_rx_i = usrrst_n; 
  assign  txusrclk2       = gt_txusrclk2_i[0];
  assign  rxusrclk2       = gt_rxusrclk2_i;  
     //IBUFDS_GTE2
  IBUFDS_GTE2 
  ibufds_instQ0_CLK0  
  (
    .O               (clk_refclk_i),
    .ODIV2           (),
    .CEB             (0),
    .I               (GTREFCLK_P),
    .IB              (GTREFCLK_N)
  ); 
          
  generate
    genvar  ch_id;
    if (LANE_RATE=="2p5G") begin
      gtx_2p5G_usrclk_source#
      (
        .CHNL_NUM            (CHNL_NUM),
        .BUFG_NUM            (BUFG_NUM)        
      ) 
      gtx_2p5G_usrclk_source_inst
      (     
        .txusrclk     (gt_txusrclk_i),
        .txusrclk2    (gt_txusrclk2_i),
        .txoutclk     (gt_txoutclk_i),
        .rxusrclk     (gt_rxusrclk_i), 
        .rxusrclk2    (gt_rxusrclk2_i),
        .rxoutclk     (gt_rxoutclk_i)
      );
      
      for (ch_id=0; ch_id<CHNL_NUM; ch_id=ch_id+1) begin: chnl_loop_2p5G     
          gtwizard_1x2p5G 
          gtx_2p5G_init0_i
          (
            .sysclk_in                      (sysclk_in_i),
            .soft_reset_tx_in               (soft_reset_tx_i),
            .soft_reset_rx_in               (soft_reset_rx_i),
            .dont_reset_on_data_error_in    (0),
            .gt0_tx_fsm_reset_done_out      (gt_tx_fsm_reset_done_i[ch_id]),
            .gt0_rx_fsm_reset_done_out      (gt_rx_fsm_reset_done_i[ch_id]),
            .gt0_data_valid_in              (gt_data_valid_i[ch_id]),       
          
            //------------------------------- CPLL Ports -------------------------------
            .gt0_cpllfbclklost_out          (gt_cpllfbclklost_i[ch_id]), // output wire gt_cpllfbclklost_i
            .gt0_cplllock_out               (gt_cplllock_i[ch_id]), // output wire gt0_cplllock_out
            .gt0_cplllockdetclk_in          (sysclk_in_i), // input wire sysclk_in_i
            .gt0_cpllreset_in               (0), // input wire 0
            //------------------------ Channel - Clocking Ports ------------------------
            .gt0_gtrefclk0_in               (clk_refclk_i), // input wire clk_refclk_i
            .gt0_gtrefclk1_in               (0), // input wire 0
            //-------------------------- Channel - DRP Ports  --------------------------
            .gt0_drpaddr_in                 (0), // input wire [8:0] gt0_drpaddr_in
            .gt0_drpclk_in                  (sysclk_in_i), // input wire sysclk_in_i
            .gt0_drpdi_in                   (0), // input wire [15:0] gt_drpdi_in
            .gt0_drpdo_out                  (gt_drpdo_i[ch_id*16+15:ch_id*16]), // output wire [15:0] gt_drpdo_i
            .gt0_drpen_in                   (0), // input wire gt_drpen_in
            .gt0_drprdy_out                 (gt_drprdy_i[ch_id]), // output wire gt_drprdy_i
            .gt0_drpwe_in                   (0), // input wire gt_drpwe_in
            //------------------------- Digital Monitor Ports --------------------------
            .gt0_dmonitorout_out            (gt_dmonitorout_i[ch_id*8+7:ch_id*8]), // output wire [7:0] gt_dmonitorout_i
            //------------------- RX Initialization and Reset Ports --------------------
            .gt0_eyescanreset_in            (0), // input wire gt_eyescanreset_in
            .gt0_rxuserrdy_in               (0), // input wire gt_rxuserrdy_in
            //------------------------ RX Margin Analysis Ports ------------------------
            .gt0_eyescandataerror_out       (gt_eyescandataerror_i[ch_id]), // output wire gt_eyescandataerror_i
            .gt0_eyescantrigger_in          (0), // input wire gt_eyescantrigger_in
            //----------------- Receive Ports - Clock Correction Ports -----------------
            .gt0_rxclkcorcnt_out            (gt_rxclkcorcnt_i[ch_id*2+1:ch_id*2]), // output wire [1:0] gt_rxclkcorcnt_i
            //---------------- Receive Ports - FPGA RX Interface Ports -----------------
            .gt0_rxusrclk_in                (gt_rxusrclk_i[ch_id]), // input wire gt_rxusrclk_i
            .gt0_rxusrclk2_in               (gt_rxusrclk2_i[ch_id]), // input wire gt_rxusrclk2_i
            //---------------- Receive Ports - FPGA RX interface Ports -----------------
            .gt0_rxdata_out                 (rxdata[ch_id*16+15:ch_id*16]), // output wire [15:0] gt_rxdata_out
            //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
            .gt0_rxdisperr_out              (gt_rxdisperr_i[ch_id*2+1:ch_id*2]), // output wire [1:0] gt_rxdisperr_out
            .gt0_rxnotintable_out           (gt_rxnotintable_i[ch_id*2+1:ch_id*2]), // output wire [1:0] gt_rxnotintable_i
            //------------------------- Receive Ports - RX AFE -------------------------
            .gt0_gtxrxp_in                  (RXP[ch_id]), // input wire gt_gtxrxp_in
            //---------------------- Receive Ports - RX AFE Ports ----------------------
            .gt0_gtxrxn_in                  (RXN[ch_id]), // input wire gt_gtxrxn_in
            //------------------- Receive Ports - RX Equalizer Ports -------------------
            .gt0_rxdfelpmreset_in           (0), // input wire gt_rxdfelpmreset_in
            .gt0_rxmonitorout_out           (gt_rxmonitorout_i[ch_id*7+6:ch_id*7]), // output wire [6:0] gt_rxmonitorout_out
            .gt0_rxmonitorsel_in            (16'h00), // input wire [1:0] gt_rxmonitorsel_in
            //------------- Receive Ports - RX Fabric Output Control Ports -------------
            .gt0_rxoutclk_out               (gt_rxoutclk_i[ch_id]), // output wire gt_rxoutclk_i
            .gt0_rxoutclkfabric_out         (gt_rxoutclkfabric_i[ch_id]), // output wire gt_rxoutclkfabric_i
            //----------- Receive Ports - RX Initialization and Reset Ports ------------
            .gt0_gtrxreset_in               (0), // input wire gt_gtrxreset_in
            .gt0_rxpmareset_in              (0), // input wire gt_rxpmareset_in
            //----------------- Receive Ports - RX8B/10B Decoder Ports -----------------
            .gt0_rxcharisk_out              (rxchar[ch_id*2+1:ch_id*2]), // output wire [1:0] rxchar
            //------------ Receive Ports -RX Initialization and Reset Ports ------------
            .gt0_rxresetdone_out            (gt_rxresetdone_i[ch_id]), // output wire gt_rxresetdone_i
            //------------------- TX Initialization and Reset Ports --------------------
            .gt0_gttxreset_in               (0), // input wire gt_gttxreset_in
            .gt0_txuserrdy_in               (0), // input wire gt_txuserrdy_in
            //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
            .gt0_txusrclk_in                (gt_txusrclk_i[ch_id]), // input wire gt_txusrclk_i
            .gt0_txusrclk2_in               (gt_txusrclk2_i[ch_id]), // input wire gt_txusrclk2_i
            //---------------- Transmit Ports - TX Data Path interface -----------------
            .gt0_txdata_in                  (txdata[ch_id*16+15:ch_id*16]), // input wire [15:0] txdata
            //-------------- Transmit Ports - TX Driver and OOB signaling --------------
            .gt0_gtxtxn_out                 (TXN[ch_id]), // output wire TXN_OUT
            .gt0_gtxtxp_out                 (TXP[ch_id]), // output wire TXP_OUT
            //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
            .gt0_txoutclk_out               (gt_txoutclk_i[ch_id]), // output wire gt_txoutclk_i
            .gt0_txoutclkfabric_out         (gt_txoutclkfabric_i[ch_id]), // output wire gt_txoutclkfabric_i
            .gt0_txoutclkpcs_out            (gt_txoutclkpcs_i[ch_id]), // output wire gt_txoutclkpcs_i
            //------------------- Transmit Ports - TX Gearbox Ports --------------------
            .gt0_txcharisk_in               (txchar[ch_id*2+1:ch_id*2]), // input wire [1:0] txchar
            //----------- Transmit Ports - TX Initialization and Reset Ports -----------
            .gt0_txresetdone_out            (gt_txresetdone_i[ch_id]), // output wire gt_txresetdone_i
               
            .gt0_qplloutclk_in              (0),//(gt_qplloutclk_i[0]),
            .gt0_qplloutrefclk_in           (0)//(gt_qplloutrefclk_i[0])
          );
          
          assign gt_data_valid_i[ch_id]      = 1'b1;                   
      end
    end
    else if (LANE_RATE == "3p125G") begin
      gtx_3p125G_usrclk_source#
      (
        .CHNL_NUM            (CHNL_NUM),
        .BUFG_NUM            (BUFG_NUM)        
      ) 
      gtx_3p125G_usrclk_source_inst
      ( 
        .txusrclk       (gt_txusrclk_i),
        .txusrclk2      (gt_txusrclk2_i),
        .txoutclk       (gt_txoutclk_i),
        .tx_mmcm_lock   (gt_txmmcm_lock_i),
        .tx_mmcm_reset  (gt_txmmcm_reset_i),
        .rxusrclk       (gt_rxusrclk_i),
        .rxusrclk2      (gt_rxusrclk2_i),
        .rxoutclk       (gt_rxoutclk_i),      
        .rx_mmcm_lock   (gt_rxmmcm_lock_i),
        .rx_mmcm_reset  (gt_rxmmcm_reset_i)
      );
      
      for (ch_id=0; ch_id<CHNL_NUM; ch_id=ch_id+1) begin: chnl_loop_3p125G      
          gtwizard_1x3p125G  
          gtx_3p125G_init0_i
          (
            .sysclk_in                      (sysclk_in_i),
            .soft_reset_tx_in               (soft_reset_tx_i),
            .soft_reset_rx_in               (soft_reset_rx_i),
            .dont_reset_on_data_error_in    (0),
            .gt0_tx_mmcm_lock_in            (gt_txmmcm_lock_i[ch_id]),
            .gt0_tx_mmcm_reset_out          (gt_txmmcm_reset_i[ch_id]),
            .gt0_rx_mmcm_lock_in            (gt_rxmmcm_lock_i[ch_id]),
            .gt0_rx_mmcm_reset_out          (gt_rxmmcm_reset_i[ch_id]),
            .gt0_tx_fsm_reset_done_out      (gt_tx_fsm_reset_done_i[ch_id]),
            .gt0_rx_fsm_reset_done_out      (gt_rx_fsm_reset_done_i[ch_id]),
            .gt0_data_valid_in              (gt_data_valid_i[ch_id]),
        
            //------------------------------- CPLL Ports -------------------------------
            .gt0_cpllfbclklost_out          (gt_cpllfbclklost_i[ch_id]), // output wire gt_cpllfbclklost_i
            .gt0_cplllock_out               (gt_cplllock_i[ch_id]), // output wire gt0_cplllock_out
            .gt0_cplllockdetclk_in          (sysclk_in_i), // input wire sysclk_in_i
            .gt0_cpllreset_in               (0), // input wire 0
            //------------------------ Channel - Clocking Ports ------------------------
            .gt0_gtrefclk0_in               (clk_refclk_i), // input wire clk_refclk_i
            .gt0_gtrefclk1_in               (0), // input wire 0
            //-------------------------- Channel - DRP Ports  --------------------------
            .gt0_drpaddr_in                 (0), // input wire [8:0] gt0_drpaddr_in
            .gt0_drpclk_in                  (sysclk_in_i), // input wire sysclk_in_i
            .gt0_drpdi_in                   (0), // input wire [15:0] gt_drpdi_in
            .gt0_drpdo_out                  (gt_drpdo_i[ch_id*16+15:ch_id*16]), // output wire [15:0] gt_drpdo_i
            .gt0_drpen_in                   (0), // input wire gt_drpen_in
            .gt0_drprdy_out                 (gt_drprdy_i[ch_id]), // output wire gt_drprdy_i
            .gt0_drpwe_in                   (0), // input wire gt_drpwe_in
            //------------------------- Digital Monitor Ports --------------------------
            .gt0_dmonitorout_out            (gt_dmonitorout_i[ch_id*8+7:ch_id*8]), // output wire [7:0] gt_dmonitorout_i
            //------------------- RX Initialization and Reset Ports --------------------
            .gt0_eyescanreset_in            (0), // input wire gt_eyescanreset_in
            .gt0_rxuserrdy_in               (0), // input wire gt_rxuserrdy_in
            //------------------------ RX Margin Analysis Ports ------------------------
            .gt0_eyescandataerror_out       (gt_eyescandataerror_i[ch_id]), // output wire gt_eyescandataerror_i
            .gt0_eyescantrigger_in          (0), // input wire gt_eyescantrigger_in
            //----------------- Receive Ports - Clock Correction Ports -----------------
            .gt0_rxclkcorcnt_out            (gt_rxclkcorcnt_i[ch_id*2+1:ch_id*2]), // output wire [1:0] gt_rxclkcorcnt_i
            //---------------- Receive Ports - FPGA RX Interface Ports -----------------
            .gt0_rxusrclk_in                (gt_rxusrclk_i[ch_id]), // input wire gt_rxusrclk_i
            .gt0_rxusrclk2_in               (gt_rxusrclk2_i[ch_id]), // input wire gt_rxusrclk2_i
            //---------------- Receive Ports - FPGA RX interface Ports -----------------
            .gt0_rxdata_out                 (rxdata[ch_id*16+15:ch_id*16]), // output wire [15:0] gt_rxdata_out
            //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
            .gt0_rxdisperr_out              (gt_rxdisperr_i[ch_id*2+1:ch_id*2]), // output wire [1:0] gt_rxdisperr_out
            .gt0_rxnotintable_out           (gt_rxnotintable_i[ch_id*2+1:ch_id*2]), // output wire [1:0] gt_rxnotintable_i
            //------------------------- Receive Ports - RX AFE -------------------------
            .gt0_gtxrxp_in                  (RXP[ch_id]), // input wire gt_gtxrxp_in
            //---------------------- Receive Ports - RX AFE Ports ----------------------
            .gt0_gtxrxn_in                  (RXN[ch_id]), // input wire gt_gtxrxn_in
            //------------------- Receive Ports - RX Equalizer Ports -------------------
            .gt0_rxdfelpmreset_in           (0), // input wire gt_rxdfelpmreset_in
            .gt0_rxmonitorout_out           (gt_rxmonitorout_i[ch_id*7+6:ch_id*7]), // output wire [6:0] gt_rxmonitorout_out
            .gt0_rxmonitorsel_in            (16'h00), // input wire [1:0] gt_rxmonitorsel_in
            //------------- Receive Ports - RX Fabric Output Control Ports -------------
            .gt0_rxoutclk_out               (gt_rxoutclk_i[ch_id]), // output wire gt_rxoutclk_i
            .gt0_rxoutclkfabric_out         (gt_rxoutclkfabric_i[ch_id]), // output wire gt_rxoutclkfabric_i
            //----------- Receive Ports - RX Initialization and Reset Ports ------------
            .gt0_gtrxreset_in               (0), // input wire gt_gtrxreset_in
            .gt0_rxpmareset_in              (0), // input wire gt_rxpmareset_in
            //----------------- Receive Ports - RX8B/10B Decoder Ports -----------------
            .gt0_rxcharisk_out              (rxchar[ch_id*2+1:ch_id*2]), // output wire [1:0] rxchar
            //------------ Receive Ports -RX Initialization and Reset Ports ------------
            .gt0_rxresetdone_out            (gt_rxresetdone_i[ch_id]), // output wire gt_rxresetdone_i
            //------------------- TX Initialization and Reset Ports --------------------
            .gt0_gttxreset_in               (0), // input wire gt_gttxreset_in
            .gt0_txuserrdy_in               (0), // input wire gt_txuserrdy_in
            //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
            .gt0_txusrclk_in                (gt_txusrclk_i[ch_id]), // input wire gt_txusrclk_i
            .gt0_txusrclk2_in               (gt_txusrclk2_i[ch_id]), // input wire gt_txusrclk2_i
            //---------------- Transmit Ports - TX Data Path interface -----------------
            .gt0_txdata_in                  (txdata[ch_id*16+15:ch_id*16]), // input wire [15:0] txdata
            //-------------- Transmit Ports - TX Driver and OOB signaling --------------
            .gt0_gtxtxn_out                 (TXN[ch_id]), // output wire TXN_OUT
            .gt0_gtxtxp_out                 (TXP[ch_id]), // output wire TXP_OUT
            //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
            .gt0_txoutclk_out               (gt_txoutclk_i[ch_id]), // output wire gt_txoutclk_i
            .gt0_txoutclkfabric_out         (gt_txoutclkfabric_i[ch_id]), // output wire gt_txoutclkfabric_i
            .gt0_txoutclkpcs_out            (gt_txoutclkpcs_i[ch_id]), // output wire gt_txoutclkpcs_i
            //------------------- Transmit Ports - TX Gearbox Ports --------------------
            .gt0_txcharisk_in               (txchar[ch_id*2+1:ch_id*2]), // input wire [1:0] txchar
            //----------- Transmit Ports - TX Initialization and Reset Ports -----------
            .gt0_txresetdone_out            (gt_txresetdone_i[ch_id]), // output wire gt_txresetdone_i
               
            .gt0_qplloutclk_in              (0),//(gt_qplloutclk_i[0]),  
            .gt0_qplloutrefclk_in           (0) //(gt_qplloutrefclk_i[0]) 
                        
          ); 
          
          assign gt_data_valid_i[ch_id]    = 1'b1;  
      end
    end
  endgenerate
  ila_0 
  ila_0_inst 
  (
    .clk(gt_txusrclk2_i[0]), // input wire clk
    .probe0({txdata[15 :0  ],txchar[1 :0 ],rxdata[15 : 0 ], rxchar[1 :0 ]}), // input wire [35:0]  probe0  
    .probe1({txdata[31 :16 ],txchar[3 :2 ],rxdata[31 :16 ], rxchar[3 :2 ]}), // input wire [35:0]  probe1 
    .probe2({txdata[47 :32 ],txchar[5 :4 ],rxdata[47 :32 ], rxchar[5 :4 ]}), // input wire [35:0]  probe2 
    .probe3({txdata[63 :48 ],txchar[7 :6 ],rxdata[63 :48 ], rxchar[7 :6 ]}), // input wire [35:0]  probe3 
    .probe4({txdata[79 :64 ],txchar[9 :8 ],rxdata[79 :64 ], rxchar[9 :8 ]}), // input wire [35:0]  probe4 
    .probe5({txdata[95 :80 ],txchar[11:10],rxdata[95 :80 ], rxchar[11:10]}), // input wire [35:0]  probe5 
    .probe6({txdata[111:96 ],txchar[13:12],rxdata[111:96 ], rxchar[13:12]}), // input wire [35:0]  probe6 
    .probe7({txdata[127:112],txchar[15:14],rxdata[127:112], rxchar[15:14]}) // input wire [35:0]  probe7
  );
endmodule
    


