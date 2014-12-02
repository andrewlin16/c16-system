
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

	// HDMI module in/out
	reg clk25;

	wire [11:0] x;
	wire [11:0] y;

	reg [7:0] r;
	reg [7:0] g;
	reg [7:0] b;

	// internal picture regs
	reg [11:0] paldef[0:15];
	reg [3:0] tiledef[0:16383];
	reg [5:0] tile[0:299];

	integer ty, tx, t;
	integer py, px, p;
	integer c;

	integer i;

//=======================================================
//  Structural coding
//=======================================================

	// clock divider
	always @(posedge CLOCK_50_B5B) begin
		clk25 <= !clk25;
	end

	// picture output
	initial begin
		for (i = 0; i < 16; i = i + 1) begin
			paldef[i] <= 0;
		end

		for (i = 0; i < 4096; i = i + 1) begin
			tiledef[i] <= 0;
			tiledef[i+4096] <= 0;
			tiledef[i+8192] <= 0;
			tiledef[i+12288] <= 0;
		end

		for (i = 0; i < 300; i = i + 1) begin
			tile[i] <= 0;
		end
	end

	always @(*) begin
		ty = y >> 4;
		tx = x >> 4;
		t = tile[ty*20+tx];

		py = y & 11'b00000001111;
		px = x & 11'b00000001111;
		p = tiledef[t << 8 | y << 4 | x];

		c = paldef[p];
		r = {c[11:8], 4'b0000};
		g = {c[7:4], 4'b0000};
		b = {c[3:0], 4'b0000};
	end

	// hdmi
	hdmi hdmiout(clk25, CPU_RESET_n, x, y, r, g, b, HDMI_TX_CLK, HDMI_TX_D, HDMI_TX_DE, HDMI_TX_HS, HDMI_TX_INT, HDMI_TX_VS);
endmodule
