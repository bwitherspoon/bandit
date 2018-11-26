// Copyright 2018 Brett Witherspoon

// Lattice Semiconductor iCEstick Evaluation Kit (iCE40-HX1K-TQ144)
module icestick (
  /* Discera 12 MHz oscilator */
  input  clk,
  /* FTDI FT2232H USB */
  input  rs232_rxd,
  input  rs232_rts,
  input  rs232_dtr,
  output rs232_txd,
  output rs232_cts,
  output rs232_dcd,
  output rs232_dsr,
  /* Vishay TFDU4101 IrDA */
  input  irda_rxd,
  output irda_txd,
  output irda_sd,
  /* LEDs */
  output [4:0] led,
  /* Diligent Pmod connector (2 x 6) */
  inout [7:0] pmod,
  /* Expansion I/O (3.3 V) */
  inout [15:0] gpio
);
  localparam FREQ = 12000000;
  localparam BAUD = 9600;

  wire reward_valid;
  wire [7:0] reward_data;
  wire reward_ready;

  wire action_valid;
  wire [7:0] action_data;
  wire action_ready;

  wire serial_error;

  action_value agent (
    .clock(clk),
    .reset(1'b0),
    .reward_valid(reward_valid),
    .reward_data(reward_data),
    .reward_ready(reward_ready),
    .action_valid(action_valid),
    .action_data(action_data),
    .action_ready(action_ready),
    .action_gready(1'b0)
  );

  receive #(BAUD, FREQ) receiver (
    .clk(clk),
    .rst(1'b0),
    .rxd(rs232_rxd),
    .rdy(reward_ready),
    .stb(reward_valid),
    .dat(reward_data),
    .err(serial_error)
  );

  transmit #(BAUD, FREQ) transmitter (
    .clk(clk),
    .rst(1'b0),
    .stb(action_valid),
    .dat(action_data),
    .rdy(action_ready),
    .txd(rs232_txd)
  );

  assign led = {reward_ready, 4'b0000};

  assign rs232_cts = 0;
  assign rs232_dcd = 0;
  assign rs232_dsr = 0;

  assign irda_txd = 0;
  assign irda_sd = 1;

  wire nc = &{1'b0,
              rs232_rts,
              rs232_dtr,
              irda_rxd,
              pmod,
              gpio,
              1'b0};
endmodule
