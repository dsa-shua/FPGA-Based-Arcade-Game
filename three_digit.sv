module three_digit(    
    input wire [15:0]   i_x,
    input wire [15:0]   i_y,
    input wire          i_v_sync,
    input wire  [11:0]  value,              // receive distance information
    output wire [7:0]   o_digit0_r,
    output wire [7:0]   o_digit0_g,
    output wire [7:0]   o_digit0_b,
    output wire         o_digit0_hit,
    output wire [7:0]   o_digit1_r,
    output wire [7:0]   o_digit1_g,
    output wire [7:0]   o_digit1_b,
    output wire         o_digit1_hit,
    output wire [7:0]   o_digit2_r,
    output wire [7:0]   o_digit2_g,
    output wire [7:0]   o_digit2_b,
    output wire         o_digit2_hit,
    output wire [7:0]   o_meter_r,
    output wire [7:0]   o_meter_g,
    output wire [7:0]   o_meter_b,
    output wire         o_meter_hit
    );

    reg[11:0] HUNDREDS;
    reg[11:0] TENS;
    reg[11:0] ONES;

    reg[11:0] DISTANCE_HUNDRED;              // hundredth's digit of distance
    reg[11:0] DISTANCE_TEN;                  // tenth's digit of distance
    reg[11:0] DISTANCE_ONE;                  // one's digit of distance

    always_latch begin
        if (value >= 300 && value < 400) begin
            DISTANCE_HUNDRED = 4'd3;
            TENS = value - 300;
        end
        else if(value >= 200) begin
            DISTANCE_HUNDRED = 4'd2;
            TENS = value - 200;
        end
        else if(value >= 100) begin
            DISTANCE_HUNDRED = 4'd1;
            TENS = value - 100;
        end
        else if(value < 100) begin
            DISTANCE_HUNDRED = 4'd0;
            HUNDREDS = 12'd000;
            TENS = value;
        end
        
        
        if (TENS >= 90) begin
            DISTANCE_TEN = 4'd9;
            ONES = TENS - 90;
        end
        else if (TENS >= 80) begin
            DISTANCE_TEN = 4'd8;
            ONES = TENS - 80;
        end
        else if (TENS >= 70) begin
            DISTANCE_TEN = 4'd7;
            ONES = TENS - 70;
        end
        else if (TENS >= 60) begin
            DISTANCE_TEN = 4'd6;
            ONES = TENS - 60;
        end
        else if (TENS >= 50) begin
            DISTANCE_TEN = 4'd5;
            ONES = TENS - 50;
        end
        else if (TENS >= 40) begin
            DISTANCE_TEN = 4'd4;
            ONES = TENS - 40;
        end
        else if (TENS >= 30) begin
            DISTANCE_TEN = 4'd3;
            ONES = TENS - 30;
        end
        else if (TENS >= 20) begin
            DISTANCE_TEN = 4'd2;
            ONES = TENS - 20;
        end
        else if (TENS >= 10) begin
            DISTANCE_TEN = 4'd1;
            ONES = TENS - 10;
        end
        else if (TENS < 10) begin
            DISTANCE_TEN = 4'd0;
            ONES = TENS;
        end

        if(ONES == 9) begin
            DISTANCE_ONE = 4'd9;
        end   
        else if(ONES == 8) begin
            DISTANCE_ONE = 4'd8;
        end
        else if(ONES == 7) begin
            DISTANCE_ONE = 4'd7;
        end
        else if(ONES == 6) begin
            DISTANCE_ONE = 4'd6;
        end
        else if(ONES == 5) begin
            DISTANCE_ONE = 4'd5;
        end
        else if(ONES == 4) begin
            DISTANCE_ONE = 4'd4;
        end
        else if(ONES == 3) begin
            DISTANCE_ONE = 4'd3;
        end
        else if(ONES == 2) begin
            DISTANCE_ONE = 4'd2;
        end
        else if(ONES == 1) begin
            DISTANCE_ONE = 4'd1;
        end
        else if(ONES == 0) begin
            DISTANCE_ONE = 4'd0;
        end
    end

    digit0 digit_hundreds(
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .sprite_x       (16'd350),                  // const
        .sprite_y       (16'd64),                   // const
        .value          (DISTANCE_HUNDRED),
        .o_red          (o_digit0_r),
        .o_green        (o_digit0_g),
        .o_blue         (o_digit0_b),
        .o_sprite_hit   (o_digit0_hit)
    );

    digit0 digit_tens(
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .sprite_x       (16'd382),                  // const
        .sprite_y       (16'd64),                   // const
        .value          (DISTANCE_TEN),
        .o_red          (o_digit1_r),
        .o_green        (o_digit1_g),
        .o_blue         (o_digit1_b),
        .o_sprite_hit   (o_digit1_hit)
    );  

    digit0 digit_ones(
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .sprite_x       (16'd414),                  // const
        .sprite_y       (16'd64),                   // const
        .value          (DISTANCE_ONE),
        .o_red          (o_digit2_r),
        .o_green        (o_digit2_g),
        .o_blue         (o_digit2_b),
        .o_sprite_hit   (o_digit2_hit)
    ); 

    meter_compositor meter_c(
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .o_red          (o_meter_r),
        .o_green        (o_meter_g),
        .o_blue         (o_meter_b),
        .o_sprite_hit   (o_meter_hit)
    ); 

    
endmodule