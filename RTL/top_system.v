module top_system (
    clk,
    rst_n
);
  input clk, rst_n;

  // CPU to controller signals
  wire [15:0] cpu_address, cpu_wdata, cpu_rdata;
  wire cpu_read_enable, cpu_write_enable;
  wire cpu_ready, cpu_read_valid, cpu_write_done;

  // controller to memory signals
  wire [15:0] mem_address, mem_write_data, mem_read_data;
  wire mem_r_e, mem_w_e;

  // instantiate CPU
  cpu u_cpu (
      .clk(clk),
      .rst_n(rst_n),
      .address(cpu_address),
      .wdata(cpu_wdata),
      .rdata(cpu_rdata),
      .read_enable(cpu_read_enable),
      .write_enable(cpu_write_enable),
      .ready(cpu_ready),
      .read_valid(cpu_read_valid),
      .write_done(cpu_write_done)
  );

  // instantiate memory
  memory u_memory (
      .clk(clk),
      .rst_n(rst_n),
      .address(mem_address),
      .write_data(mem_write_data),
      .read_data(mem_read_data),
      .r_e(mem_r_e),
      .w_e(mem_w_e)
  );

  // instantiate memory controller
  memory_controller u_controller (
      .clk(clk),
      .rst_n(rst_n),
      .address(cpu_address),
      .wdata(cpu_wdata),
      .rdata(cpu_rdata),
      .read_enable(cpu_read_enable),
      .write_enable(cpu_write_enable),
      .ready(cpu_ready),
      .read_valid(cpu_read_valid),
      .write_done(cpu_write_done),
      .memory_address(mem_address),
      .write_data(mem_write_data),
      .read_data(mem_read_data),
      .r_e(mem_r_e),
      .w_e(mem_w_e)
  );

endmodule
