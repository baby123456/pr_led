module top(
   input        clk,				// 100MHz input clock
   input        rst_n,				// Reset mapped to center push button
   output [3:0] shift_high_out,		// mapped to general purpose LEDs[4-7]
   output [3:0] shift_low_out		// mapped to general purpose LEDs[0-3]
);

   reg  [34:0] count;
   
   // instantiate module shift for low bits
   shift inst_shift_low (
      .en       (rst_n),
      .clk      (clk),
      .addr     (count[34:23]),
      .data_out (shift_low_out) 
   );
 
   // instantiate module shift for high bits
   shift inst_shift_high (
      .en       (rst_n),
      .clk      (clk),
      .addr     (count[34:23]),
      .data_out (shift_high_out) 
   );

   always @(posedge clk or negedge rst_n)
     if (!rst_n)
       begin
         count <= 0;
       end
     else
       begin
         count <= count + 1;
       end

endmodule
//black box definition for shift module
module shift (
	input	en,
    input	clk,
    input	[11:0] addr,
    output	[3:0] data_out);
endmodule


