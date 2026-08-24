`timescale 1ns / 1ns
module top_system_tb;

  reg clk, rst_n;
  initial clk = 0;
  always #5 clk = ~clk;

  top_system u_top (
      .clk  (clk),
      .rst_n(rst_n)
  );

  initial begin
    $dumpfile("top_system.vcd");
    $dumpvars(0, top_system_tb);
    #0 rst_n = 0;
    #20 rst_n = 1;

    $monitor("Time=%0t Addr=%h WData=%h RData=%h Ready=%b ReadValid=%b WriteDone=%b", $time,
             u_top.u_cpu.address, u_top.u_cpu.wdata, u_top.u_cpu.rdata, u_top.u_cpu.ready,
             u_top.u_cpu.read_valid, u_top.u_cpu.write_done);

    {u_top.u_cpu.write_enable, u_top.u_cpu.read_enable} = 2'b00;

    // multiple addresses
    repeat (2) begin
      #10 u_top.u_cpu.address = 16'h0010;
      #10 u_top.u_cpu.wdata = 16'hAAAA;

      repeat (4) begin
        #10
        {u_top.u_cpu.write_enable, u_top.u_cpu.read_enable} =
                {u_top.u_cpu.write_enable, u_top.u_cpu.read_enable} + 2'b01;
      end

      #10 u_top.u_cpu.address = 16'h0020;
      #10 u_top.u_cpu.wdata = 16'h5555;

      repeat (4) begin
        #10
        {u_top.u_cpu.write_enable, u_top.u_cpu.read_enable} =
                {u_top.u_cpu.write_enable, u_top.u_cpu.read_enable} + 2'b01;
      end
    end

    #50 $finish;
  end

endmodule