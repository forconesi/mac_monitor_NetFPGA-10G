`timescale 1ns / 1ps
//`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:44:18 05/28/2013 
// Design Name: 
// Module Name:    my_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module my_top(
	input	USR_100MHZ,
	output reg	LED01,
	output reg	LED02,
	output reg	LED03,
	input	refclk_D_p,
	input	refclk_D_n,
	output	xaui_tx_l0_p,
	output	xaui_tx_l0_n,
	output	xaui_tx_l1_p,
	output	xaui_tx_l1_n,
	output	xaui_tx_l2_p,
	output	xaui_tx_l2_n,
	output	xaui_tx_l3_p,
	output	xaui_tx_l3_n,
	input	xaui_rx_l0_p,
	input	xaui_rx_l0_n,
	input	xaui_rx_l1_p,
	input	xaui_rx_l1_n,
	input	xaui_rx_l2_p,
	input	xaui_rx_l2_n,
	input	xaui_rx_l3_p,
	input	xaui_rx_l3_n
    );
	 
	//MAC CORE
	wire [63:0] rx_data;
	wire [7:0] rx_data_valid;
	(* keep = "true" *) reg	[63 : 0] rx_data_mon;
   (* keep = "true" *) reg	[7 : 0] rx_data_valid_mon;
   wire rx_good_frame;
   wire rx_bad_frame;
   wire [28 : 0]rx_statistics_vector;
   wire rx_statistics_valid;
   wire [68 : 0] configuration_vector_mac;
   wire [1 : 0] status_vector_mac;
   wire rx_clk0;
   wire rx_dcm_locked;
	
	//XAUI CORE
	wire dclk_50MHZ;	//
	wire reset;
	wire clk156_out;
//   (* keep = "true" *) wire	[63 : 0] xgmii_txd;
//   (* keep = "true" *) wire	[7 : 0]  xgmii_txc;
   (* keep = "true" *) reg	[63 : 0] xgmii_txd;
   (* keep = "true" *) reg	[7 : 0] xgmii_txc;
   wire [63 : 0] xgmii_rxd;
   wire [7 : 0] xgmii_rxc;
   wire [3 : 0] signal_detect;
   wire align_status;
   wire [3 : 0] sync_status;
   wire mgt_tx_ready;
   wire [6 : 0] configuration_vector;
   (* keep = "true" *) wire [7 : 0]  status_vector;

	//DCM
	wire	LOCKED_OUT;	//dmc
	wire	RST_IN;	//dmc input

	ten_gig_eth_mac_v10_3 my_mac (
		.reset(reset),	//in
		.rx_data(rx_data),	//out
		.rx_data_valid(rx_data_valid),	//out
		.rx_good_frame(rx_good_frame),	//out
		.rx_bad_frame(rx_bad_frame),	//out
		.rx_statistics_vector(rx_statistics_vector),	//out
		.rx_statistics_valid(rx_statistics_valid),	//out
		.configuration_vector(configuration_vector_mac),	//in
		.status_vector(status_vector_mac),	//out
		.rx_clk0(clk156_out),	//in
		.rx_dcm_lock(mgt_tx_ready),	//in
		.xgmii_rxd(xgmii_rxd),	//in
		.xgmii_rxc(xgmii_rxc)	//in
	);
	
	xaui_v10_4_example_design my_xaui (
		.dclk(dclk_50MHZ),	//in
		.reset(reset),	//in
		.clk156_out(clk156_out),	//out
		.xgmii_txd(xgmii_txd),	//usr in
		.xgmii_txc(xgmii_txc),	//usr in
		.xgmii_rxd(xgmii_rxd),	//usr out
		.xgmii_rxc(xgmii_rxc),	//usr out
		.refclk_p(refclk_D_p),	//from board in
		.refclk_n(refclk_D_n),	//from board in
		.xaui_tx_l0_p(xaui_tx_l0_p),
		.xaui_tx_l0_n(xaui_tx_l0_n),
		.xaui_tx_l1_p(xaui_tx_l1_p),
		.xaui_tx_l1_n(xaui_tx_l1_n),
		.xaui_tx_l2_p(xaui_tx_l2_p),
		.xaui_tx_l2_n(xaui_tx_l2_n),
		.xaui_tx_l3_p(xaui_tx_l3_p),
		.xaui_tx_l3_n(xaui_tx_l3_n),
		.xaui_rx_l0_p(xaui_rx_l0_p),
		.xaui_rx_l0_n(xaui_rx_l0_n),
		.xaui_rx_l1_p(xaui_rx_l1_p),
		.xaui_rx_l1_n(xaui_rx_l1_n),
		.xaui_rx_l2_p(xaui_rx_l2_p),
		.xaui_rx_l2_n(xaui_rx_l2_n),
		.xaui_rx_l3_p(xaui_rx_l3_p),
		.xaui_rx_l3_n(xaui_rx_l3_n),
		.signal_detect(signal_detect),
		.align_status(align_status),
		.sync_status(sync_status),
		.mgt_tx_ready(mgt_tx_ready),
		.configuration_vector(configuration_vector),
		.status_vector(status_vector));
		
	dcm1 instance_name (
		 .CLKIN_IN(USR_100MHZ), 
		 .RST_IN(RST_IN), 
		 .CLKIN_IBUFG_OUT(), 
		 .CLK0_OUT(dclk_50MHZ), 
		 .LOCKED_OUT(LOCKED_OUT)
		 );
		
	assign	reset = ~LOCKED_OUT;
	assign	RST_IN = 1'b0;

//XAUI conf
	assign	signal_detect = 4'b1111; //according to the pg053
	assign	configuration_vector = 7'b0;	//see pg053
	
//XAUI Loopback
	always @(posedge clk156_out)
	begin
		xgmii_txd <= xgmii_rxd;
		xgmii_txc <= xgmii_rxc;
	end
	
//MAC conf
	//rx
	assign configuration_vector_mac[47:0] = 48'b0;	//Pause frame MAC Source Address
	assign configuration_vector_mac[48] = 1'b1;	//Receive VLAN Enable
	assign configuration_vector_mac[49] = 1'b1;	//Receive Enable
	assign configuration_vector_mac[50] = 1'b1;	//Receive In-Band FCS
	assign configuration_vector_mac[51] = 1'b1;	//Receive Jumbo Frame Enable
	assign configuration_vector_mac[52] = 1'b0;	//Receiver Reset
	assign configuration_vector_mac[66] = 1'b0;	//Receiver Preserve Preamble Enable
	//tx
	assign configuration_vector_mac[65:53] = 12'b0;
	assign configuration_vector_mac[68:67] = 2'b0;

	always @(posedge clk156_out)
	begin
		rx_data_mon <= rx_data;
		rx_data_valid_mon <= rx_data_valid;
	end
	

//LEDs driver
	always @(posedge clk156_out)
	begin
		LED02 <= 1'b1;
		LED03 <= 1'b0;
		if (mgt_tx_ready == 1'b1)
			LED01 <= 1'b1;
		else
			LED01 <= 1'b0;
	end
	

(* keep = "true" *) reg [31:0] good_frame_counter_mon;
//good frame counter
	always @(posedge clk156_out)
	begin
		if (LOCKED_OUT == 1'b0)
			good_frame_counter_mon <= 32'b0;
		else
			if (rx_good_frame == 1'b1)
				good_frame_counter_mon <= good_frame_counter_mon +1;
	end

(* keep = "true" *) reg [31:0] bad_frame_counter_mon;
//bad frame counter
	always @(posedge clk156_out)
	begin
		if (LOCKED_OUT == 1'b0)
			bad_frame_counter_mon <= 32'b0;
		else
			if (rx_bad_frame == 1'b1)
				bad_frame_counter_mon <= bad_frame_counter_mon +1;
	end

endmodule
