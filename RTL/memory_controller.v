module memory_controller (
    clk,
    rst_n,
    address,
    wdata,
    rdata,
    read_enable,
    write_enable,
    ready,
    read_valid,
    write_done,
    memory_address,
    write_data,
    read_data,
    r_e,
    w_e
);
  input clk, rst_n;

  // CPU interface
  input [15:0] address, wdata;
  input read_enable, write_enable;
  output reg [15:0] rdata;
  output reg ready, read_valid, write_done;

  // Memory interface
  input [15:0] read_data;
  output reg [15:0] memory_address, write_data;
  output reg r_e, w_e;

  // state machine encoding
  reg [1:0] state, next_state;
  parameter S_IDLE = 2'b00, S_READ = 2'b01, S_WRITE = 2'b10;

  reg pending_read;  // flag in case user did read and write together
  reg [15:0] pending_read_address;
  reg [1:0] read_cycle_cnt;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin  // reset zero everything
      state <= S_IDLE;
      ready <= 1'b1;
      read_valid <= 1'b0;
      write_done <= 1'b0;
      r_e <= 1'b0;
      w_e <= 1'b0;
      pending_read <= 1'b0;
      read_cycle_cnt <= 2'b00;
      memory_address <= 16'b0;
      write_data <= 16'b0;
      rdata <= 16'b0;
    end else begin
      state <= next_state;
      read_valid <= 1'b0;
      write_done <= 1'b0;

      case (state)
        S_IDLE: begin
          r_e <= 1'b0;
          w_e <= 1'b0;
          ready <= 1'b1;
          read_cycle_cnt <= 2'b00;
          if (write_enable) begin
            memory_address <= address;
            write_data <= wdata;
          end else if (read_enable) begin
            memory_address <= address;
          end
        end
        S_WRITE: begin
          w_e <= 1'b1;
          r_e <= 1'b0;
          ready <= 1'b0;
          write_done <= 1'b1;
        end
        S_READ: begin
          r_e <= 1'b1;
          w_e <= 1'b0;
          ready <= 1'b0;
          read_cycle_cnt <= read_cycle_cnt + 1'b1;
          if (read_cycle_cnt == 2'b10) begin
            rdata <= read_data;
            read_valid <= 1'b1;
          end
        end
      endcase
    end
  end

  always @(*) begin
    next_state = state;
    case (state)
      S_IDLE: begin
        if (write_enable) next_state = S_WRITE;
        else if (read_enable) next_state = S_READ;
      end
      S_WRITE: begin
        if (pending_read) next_state = S_READ;
        else next_state = S_IDLE;
      end
      S_READ: begin
        if (read_cycle_cnt == 2'b10) next_state = S_IDLE;
        else next_state = S_READ;
      end
    endcase
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pending_read <= 1'b0;
      pending_read_address <= 16'b0;
    end else begin
      if (state == S_IDLE) begin
        if (write_enable && read_enable) begin
          pending_read <= 1'b1;
          pending_read_address <= address;
        end
      end else if (state == S_WRITE) begin
        if (pending_read && (next_state == S_READ)) begin
          pending_read   <= 1'b0;
          memory_address <= pending_read_address;
        end
      end
    end
  end
endmodule
