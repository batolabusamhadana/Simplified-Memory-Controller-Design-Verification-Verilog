`timescale 1ns / 1ns
module memory_controller_tb;

  reg clk, rst_n;
  reg [15:0] address, wdata;
  reg read_enable, write_enable;
  wire [15:0] rdata, memory_address, write_data;
  wire ready, read_valid, write_done;
  wire r_e, w_e;

  // Clock
  initial clk = 0;
  always #5 clk = ~clk;

  // Instantiate memory controller
  memory_controller u_controller (
      .clk(clk),
      .rst_n(rst_n),
      .address(address),
      .wdata(wdata),
      .rdata(rdata),
      .read_enable(read_enable),
      .write_enable(write_enable),
      .ready(ready),
      .read_valid(read_valid),
      .write_done(write_done),
      .memory_address(memory_address),
      .write_data(write_data),
      .read_data(16'h1234),  // dummy memory input
      .r_e(r_e),
      .w_e(w_e)
  );

  initial begin
    $dumpfile("memory_controller_tb.vcd");  // name of the waveform file
    $dumpvars(0, memory_controller_tb);  // dump all signals in this module

    #0 rst_n = 0;
    #20 rst_n = 1;

    $monitor("Time=%0t Addr=%h WData=%h RData=%h Ready=%b ReadValid=%b WriteDone=%b", $time,
             address, wdata, rdata, ready, read_valid, write_done);

    wdata = 16'h0000;
    address = 16'h0000;
    {write_enable, read_enable} = 2'b00;

    // Test multiple addresses
    repeat (2) begin
      #10 address = 16'h0010;
      #10 wdata = 16'hAAAA;

      repeat (4) begin
        #10{write_enable, read_enable} = {write_enable, read_enable} + 2'b01;
      end

      #10 address = 16'h0020;
      #10 wdata = 16'h5555;

      repeat (4) begin
        #10{write_enable, read_enable} = {write_enable, read_enable} + 2'b01;
      end
    end

    #50 $finish;
  end

endmodule
