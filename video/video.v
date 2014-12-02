
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module video(

	//////////// CLOCK //////////
	CLOCK_125_p,
	CLOCK_50_B5B,
	CLOCK_50_B6A,
	CLOCK_50_B7A,
	CLOCK_50_B8A,

	//////////// LED //////////
	LEDG,
	LEDR,

	//////////// KEY //////////
	CPU_RESET_n,
	KEY,

	//////////// SW //////////
	SW,

	//////////// SEG7 //////////
	HEX0,
	HEX1,
	HEX2,
	HEX3,

	//////////// HDMI-TX //////////
	HDMI_TX_CLK,
	HDMI_TX_D,
	HDMI_TX_DE,
	HDMI_TX_HS,
	HDMI_TX_INT,
	HDMI_TX_VS,

	//////////// I2C for Audio/HDMI-TX/Si5338/HSMC //////////
	I2C_SCL,
	I2C_SDA 
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

	//////////// CLOCK //////////
	input CLOCK_125_p;
	input CLOCK_50_B5B;
	input CLOCK_50_B6A;
	input CLOCK_50_B7A;
	input CLOCK_50_B8A;

	//////////// LED //////////
	output [7:0] LEDG;
	output [9:0] LEDR;

	//////////// KEY //////////
	input CPU_RESET_n;
	input [3:0] KEY;

	//////////// SW //////////
	input [9:0] SW;

	//////////// SEG7 //////////
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;

	//////////// HDMI-TX //////////
	output HDMI_TX_CLK;
	output [23:0] HDMI_TX_D;
	output HDMI_TX_DE;
	output HDMI_TX_HS;
	input HDMI_TX_INT;
	output HDMI_TX_VS;

	//////////// I2C for Audio/HDMI-TX/Si5338/HSMC //////////
	output I2C_SCL;
	inout I2C_SDA;

//=======================================================
//  REG/WIRE declarations
//=======================================================

	reg clk25;

	wire [11:0] x;
	wire [11:0] y;

	reg [7:0] r;
	reg [7:0] g;
	reg [7:0] b;

//=======================================================
//  Structural coding
//=======================================================

	// clock divider
	always @(posedge CLOCK_50_B5B) begin
		clk25 <= !clk25;
	end

	// hdmi
	hdmi hdmiout(clk25, CPU_RESET_n, x, y, r, g, b, HDMI_TX_CLK, HDMI_TX_D, HDMI_TX_DE, HDMI_TX_HS, HDMI_TX_INT, HDMI_TX_VS);

endmodule
