//-----------------------------------------------------------------------------
// Block: reset_cdc
// Description:
//   rst_out asserts asynchronously, de-asserts synchronously
//-----------------------------------------------------------------------------

module reset_cdc #(
  parameter POLARITY_IN  = 1, // 1 = active high rst, 0 = active low
  parameter POLARITY_OUT = 1, // 1 = active high rst, 0 = active low
  parameter CDC_LEN      = 3  // 2 is good enough
) (
  input  clk,
  input  rst_in,
  output rst_out
);

  wire rst_n = POLARITY_IN==1 ? !rst_in : rst_in;
  reg [CDC_LEN-1:0] rst_n_cdc;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rst_n_cdc <= 0;
    end else begin
      rst_n_cdc <= {1'b1, rst_n_cdc[CDC_LEN-1:1]};
    end
  end

  assign rst_out = POLARITY_OUT==1 ? !rst_n_cdc[0] : rst_n_cdc[0];

endmodule

