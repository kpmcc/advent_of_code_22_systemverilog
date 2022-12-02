module game_score
  (
   input logic clk,
   input logic rst,

   input logic vld,
   input logic[1:0] a,
   input logic[1:0] b,

   output logic score_vld,
   output logic[3:0] a_score,
   output logic[3:0] b_score
   );

   localparam ROCK = 1;
   localparam PAPER = 2;
   localparam SCISSORS = 3;

   localparam DRAW = 3;
   localparam LOSS = 0;
   localparam WIN = 6;

   initial begin
      score_vld = 0;
      a_score = 0;
      b_score = 0;
   end

   always_ff @ (posedge clk) begin
      if (rst) begin
         a_score <= 0;
         b_score <= 0;
      end else begin
         if (vld) begin
            case (a)
              0: begin
                 a_score <= 0;
                 b_score <= 0;
              end
              ROCK: begin
                 case (b)
                   0:    begin a_score <= 0; b_score <= 0; end
                   ROCK: begin a_score <= DRAW; b_score <= DRAW; end
                   PAPER: begin a_score <= LOSS; b_score <= WIN; end
                   SCISSORS: begin a_score <= WIN; b_score <= LOSS; end
                 endcase
              end
              PAPER: begin
                case (b)
                  0: begin a_score <= 0; b_score <= 0; end
                  ROCK: begin a_score <= WIN; b_score <= LOSS; end
                  PAPER: begin a_score <= DRAW; b_score <= DRAW; end
                  SCISSORS: begin a_score <= LOSS; b_score <= WIN; end
                endcase
              end
              SCISSORS: begin
                case (b)
                    0: begin a_score <= 0; b_score <= 0; end
                    ROCK: begin a_score <= LOSS; b_score <= WIN; end
                    PAPER: begin a_score <= WIN; b_score <= LOSS; end
                    SCISSORS: begin a_score <= DRAW; b_score <= DRAW; end
                endcase
              end
            endcase
         end else begin // if (vld)
            a_score <= 0;
            b_score <= 0;
        end
      end
    end

   always_ff @ (posedge clk) begin
      if (rst) begin
         score_vld <= 0;
      end else begin
         score_vld <= vld & !(a == 0 || b == 0);
      end
    end

   endmodule
