module cpu (
    clk,
    rst_n,
    address,
    wdata,
    rdata,
    read_enable,
    write_enable,
    ready,
    read_valid,
    write_done
);
  input clk, rst_n;
  output reg [15:0] address, wdata;
  input [15:0] rdata;
  output reg read_enable, write_enable;
  input ready, read_valid, write_done;


  reg [7:0] step;


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      step <= 0;
      address <= 0;
      wdata <= 0;
      read_enable <= 0;
      write_enable <= 0;
    end else begin
      read_enable  <= 0;
      write_enable <= 0;
      case (step)
        0:
        if (ready) begin
          address <= 16'h0010;
          wdata <= 16'hAAAA;
          write_enable <= 1;
          step <= 1;
        end
        1: if (write_done) step <= 2;
        2:
        if (ready) begin
          address <= 16'h0010;
          read_enable <= 1;
          step <= 3;
        end
        3: if (read_valid) step <= 4;
        4:
        if (ready) begin
          address <= 16'h0020;
          wdata <= 16'h5555;
          write_enable <= 1;
          read_enable <= 1;
          step <= 5;
        end
        5: if (write_done) step <= 6;
      endcase
    end
  end
endmodule
