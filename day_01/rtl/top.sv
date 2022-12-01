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
   output logic [31:0] max_calories_sum,
   output logic [31:0] max_calories_top_three_sum
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


   localparam NUM_MAXES = 3;

   logic [31:0] calories_max [NUM_MAXES-1:0];

   integer      i;

   initial begin
      for (i=0;i<NUM_MAXES;i=i+1) begin
         calories_max[i] = 0;
         end
      end

   logic sum_gt_cal_max[NUM_MAXES-1:0];

   genvar g;
   generate
      for (g=0; g<NUM_MAXES; g=g+1) begin: gt_cal_gen
         always_comb begin
            sum_gt_cal_max[g] = calories_sum > calories_max[g];
            end
         end
      endgenerate

   // $clog2(NUM_MAXES)-1 gives the proper binary encoded
   // bus width for NUM_MAXES signals

   // priority encoding of greater than signals
   logic[$clog2(NUM_MAXES)-1:0] cal_sum_gt_priority;


   always_ff @ (posedge clk) begin
      cal_sum_gt_priority = 0;
      for (i=0;i<NUM_MAXES;i=i+1) begin
         if (sum_gt_cal_max[i]) begin
            cal_sum_gt_priority = i+1;
         end
      end
   end


   // TODO This isn't yet generalized to be parameterizable with NUM_MAXES
   always_ff @ (posedge clk) begin
      if (rst) begin
         calories_max[0] <= 0;
         calories_max[1] <= 0;
         calories_max[2] <= 0;
      end else begin
         if (store_sum) begin
            case (cal_sum_gt_priority)
              0: begin end // sum is less than all three maxes, do nothing
              1: begin
                 calories_max[0] <= calories_sum;
                 end
              2: begin
                 calories_max[0] <= calories_max[1];
                 calories_max[1] <= calories_sum;
                 end
              3: begin
                 calories_max[0] <= calories_max[1];
                 calories_max[1] <= calories_max[2];
                 calories_max[2] <= calories_sum;
                 end
              endcase
         end
      end
    end

   always_ff @ (posedge clk) begin
      if (rst || food_vld) begin
         max_vld <= 0;
         max_calories_sum <= 0;
         max_calories_top_three_sum <= 0;
      end else if (read_max) begin
            max_vld <= 1;
            max_calories_sum <= calories_max[2];
            max_calories_top_three_sum <= calories_max[2] + calories_max[1] + calories_max[0];
      end
    end

   initial begin
      $dumpfile("dump.vcd");
      $dumpvars(1, top);
      for (i = 0; i < NUM_MAXES; i=i+1) begin
         $dumpvars(1, calories_max[i]);
         end
      end

  endmodule
