module memory (
    clk,
    rst_n,
    address,
    write_data,
    read_data,
    r_e,
    w_e
);
  input clk, rst_n;
  input [15:0] address, write_data;
  input r_e, w_e;
  output reg [15:0] read_data;

  reg [15:0] mem[0:65535];

  always @(*) begin
    if (r_e) read_data = mem[address];
    else read_data = 16'b0;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      integer i;
      for (i = 0; i < 65536; i = i + 1) mem[i] <= 16'b0;
    end else begin
      if (w_e) mem[address] <= write_data;
    end
  end
endmodule
