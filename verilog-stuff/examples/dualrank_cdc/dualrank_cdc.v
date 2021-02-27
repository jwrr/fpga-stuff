//-----------------------------------------------------------------------------
// Block: dualrank_cdc
// Description:
//
//-----------------------------------------------------------------------------

module dualrank_cdc #(
  parameter CDC_LEN = 2
) (
  input  clk, // receiving domain's clk
  input  rst, // receiving domain's rst
  input  d,   // sending domain's signal
  output q    // receiving domain's synchronized signal
);

  reg [CDC_LEN-1:0] q_cdc;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      q_cdc <= 0;
    end else begin
      q_cdc <= {d, q_cdc[CDC_LEN-1:1]};
    end
  end
  assign q = q_cdc[0];

endmodule

