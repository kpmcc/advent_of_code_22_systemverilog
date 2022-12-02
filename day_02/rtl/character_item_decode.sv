module character_item_decode
(
 input logic        clk,
 input logic        rst,
 input logic        char_vld,

 input logic [7:0]  item_character,
 output logic [1:0] item_decoded,
 output logic       decode_vld
 );

   localparam ROCK = 1;
   localparam PAPER = 2;
   localparam SCISSORS = 3;

   initial begin
      item_decoded = 0;
      decode_vld = 0;
    end


   always_ff @ (posedge clk) begin
      if (char_vld) begin
         case (item_character)
           65: begin // A
              item_decoded <= ROCK;
              decode_vld <= 1;
           end
           66: begin // B
              item_decoded <= PAPER;
              decode_vld <= 1;
           end
           67: begin // C
              item_decoded <= SCISSORS;
              decode_vld <= 1;
           end
           88: begin // X
              item_decoded <= ROCK;
              decode_vld <= 1;
           end
           89: begin // Y
              item_decoded <= PAPER;
              decode_vld <= 1;
           end
           90: begin // Z
              item_decoded <= SCISSORS;
              decode_vld <= 1;
           end
           default: begin
              item_decoded <= 0;
              decode_vld <= 0;
           end
         endcase
      end else begin // if (char_vld)
         decode_vld <= 0;
      end
    end

   endmodule
