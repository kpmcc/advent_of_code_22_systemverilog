module top
(
 input logic clk,
 input logic rst,

 input logic       entry_vld,
 input logic [7:0] opponent_item_char,
 input logic [7:0] player_action_char,

 output logic       eg_score_vld,
 output logic [7:0] eg_score
 );

   initial begin
      eg_score_vld = 0;
      eg_score = 0;
      end

   localparam ROCK = 1;
   localparam PAPER = 2;
   localparam SCISSORS = 3;

   logic[1:0] opponent_item_decoded;
   logic opponent_item_vld;

   logic[1:0] player_item_decoded;
   logic player_item_vld;

   character_item_decode
     opponent_item_decode
       (
        .clk(clk),
        .rst(rst),
        .char_vld(entry_vld),
        .item_character(opponent_item_char),
        .item_decoded(opponent_item_decoded),
        .decode_vld(opponent_item_vld)
        );

   character_item_decode
     player_item_decode
       (
        .clk(clk),
        .rst(rst),
        .char_vld(entry_vld),
        .item_character(player_action_char),
        .item_decoded(player_item_decoded),
        .decode_vld(player_item_vld)
        );


   logic [3:0] player_score;
   logic       score_vld;

   logic [1:0] player_item_delayed;
   logic       player_item_delayed_vld;

   always_ff @ (posedge clk) begin
      player_item_delayed <= player_item_decoded;
      player_item_delayed_vld <= player_item_vld;
      end

   logic       items_vld;

   always_comb  begin
      items_vld = player_item_vld & opponent_item_vld;
   end

   game_score
     game_score
       (
        .clk(clk),
        .rst(rst),
        .vld(items_vld),
        .a(opponent_item_decoded),
        .b(player_item_decoded),
        .score_vld(score_vld),
        .a_score(),
        .b_score(player_score)
        );

   logic [31:0] player_score_sum = 0;

   always_ff @ (posedge clk) begin
      if (rst) begin
         player_score_sum <= 0;
      end else begin
        if (player_item_delayed_vld && score_vld) begin
          player_score_sum <= player_score_sum + player_score + player_item_delayed;
        end
      end
    end

   logic player_score_sum_vld = 0;
   always_ff @ (posedge clk) begin
      if (rst) begin
         player_score_sum_vld <= 0;
      end else begin
         player_score_sum_vld <= !(score_vld | player_item_vld | opponent_item_vld | entry_vld);
      end
   end

   initial begin
      eg_score_vld = 0;
      eg_score = 0;
      end

   always_ff @ (posedge clk) begin
      eg_score_vld <= player_score_sum_vld;
      eg_score <= player_score_sum;
    end

   initial begin
      $dumpfile("dump.vcd");
      $dumpvars(1, top);
      end

  endmodule
