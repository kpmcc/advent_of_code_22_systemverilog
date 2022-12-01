module top
  (
   input logic         clk,
   input logic         rst,

   input logic [31:0]  food_calories,
   input logic         food_vld,

   input logic         store_sum,
   input logic         read_max,

   output logic        acc_err,
   output logic        max_vld,
   output logic [31:0] max_calories_sum
   );

   logic [31:0]        calories_sum = 0;


   always_ff @ (posedge clk) begin
      if (rst) begin
         calories_sum <= 0;
      end else begin
         case ({store_sum, food_vld})
           0: calories_sum <= calories_sum;
           1: calories_sum <= calories_sum + food_calories;
           2: calories_sum <= 0;
           3: calories_sum <= 0;  // Requested both accumulate and clear, error
           endcase
      end
   end

   always_ff @ (posedge clk) begin
      if (rst) begin
         acc_err <= 0;
      end else if (store_sum & food_vld) begin
         acc_err <= 1;
      end
    end

   logic [31:0] calories_max = 0;

   always_ff @ (posedge clk) begin
      if (rst) begin
         calories_max <= 0;
      end else begin
         if (store_sum) begin
            calories_max <= (calories_max > calories_sum) ? calories_max : calories_sum;
         end
      end
    end

   always_ff @ (posedge clk) begin
      if (rst || food_vld) begin
         max_vld <= 0;
         max_calories_sum <= 0;
      end else if (read_max) begin
            max_vld <= 1;
            max_calories_sum <= calories_max;
      end
    end

   initial begin
      $dumpfile("dump.vcd");
      $dumpvars(1, top);
      end

  endmodule
