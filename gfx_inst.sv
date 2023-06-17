module gfx_inst(
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input wire SPRITE_REFRESHER,
    input wire MV_LEFT,
    input wire MV_RIGHT,
    input wire MV_JUMP,
    output reg [7:0] o_red,
    output reg [7:0] o_green,
    output reg [7:0] o_blue,
    
    output wire out_coin_hit,                       // tell FSM to deactivate coin
    output wire out_barrier_hit,                    // tell FSM to deactivate barrier
    output wire OUT_AIRBORNE,                       // check if airborne
    input wire [11:0]   REMAINING_DISTANCE,         // distance value received from FSM
    input wire [7:0]    I_CURRENT_STATE,            // current state received from FSM
    input wire [1:0]    I_ACTIVE_COIN,              // received from FSM
    input wire [1:0]    I_ACTIVE_BARRIER,           // received from FSM
    output wire         ZERO_LIVES                  // send to FSM to set game to FINISH
    );

    wire ACTIVATE_COIN_LEFT;            // show coin on left
    wire ACTIVATE_COIN_MID;             // show coin on mid
    wire ACTIVATE_COIN_RIGHT;           // show coin on right
    wire OUT_OF_LIVES;                  // no more lives, proceed to FINISH state
    wire BARRIER_HIT;                   // barrier was hit by sprite
    wire COIN_HIT;                      // coin is hit by sprite, sent by penguin
    wire COIN_IN_POSITION;              // coin on mid now ready to be hit
    wire BARRIER_IN_POSITION;           // barrier on mid ready
    wire BARRIER_L_IN_POSITION;         // barrier on left ready
    wire BARRIER_R_IN_POSITION;         // barrier on right ready
    wire AIRBORNE;
    
    // wire REMAINING_DISTANCE;            // remaining distance, sent by state machine
    wire CURRENT_POINTS;                // # of coins collected, sent by penguin
    
    wire bg_hit, sprite_hit;
    wire [7:0] bg_red;
    wire [7:0] bg_green;
    wire [7:0] bg_blue;
    wire [7:0] sprite_red;
    wire [7:0] sprite_green;
    wire [7:0] sprite_blue;

    wire[7:0] ID1_red;
    wire[7:0] ID1_green;
    wire[7:0] ID1_blue;
    wire ID1_hit;

    wire[7:0] life_red;
    wire[7:0] life_green;
    wire[7:0] life_blue;
    wire life_hit;

    wire[7:0] cloud1_red;
    wire[7:0] cloud1_green;
    wire[7:0] cloud1_blue;
    wire cloud1_hit;

    wire[7:0] cloud2_red;
    wire[7:0] cloud2_green;
    wire[7:0] cloud2_blue;
    wire cloud2_hit;

    wire[7:0] coin_red;
    wire[7:0] coin_green;
    wire[7:0] coin_blue;
    wire coin_hit;
   
    wire[7:0] score_h_red;
    wire[7:0] score_h_green;
    wire[7:0] score_h_blue;
    wire score_h_hit;

    wire[7:0] score0_red;
    wire[7:0] score0_green;
    wire[7:0] score0_blue;
    wire score0_hit;
    
    wire[7:0] score1_red;
    wire[7:0] score1_green;
    wire[7:0] score1_blue;
    wire score1_hit;    
    
    wire[7:0] score2_red;
    wire[7:0] score2_green;
    wire[7:0] score2_blue;
    wire score2_hit;    

    wire[7:0] meter_red;
    wire[7:0] meter_green;
    wire[7:0] meter_blue;
    wire meter_hit;

    wire[7:0] barrier_red;
    wire[7:0] barrier_green;
    wire[7:0] barrier_blue;
    wire barrier_hit;
    
    wire[7:0] dist_red;
    wire[7:0] dist_green;
    wire[7:0] dist_blue;
    wire dist_hit;

    wire[7:0] point_red;
    wire[7:0] point_green;
    wire[7:0] point_blue;
    wire point_hit;
    
    wire PENGUIN_ON_AIR;                    // penguin airborne ? 1 : 0
    wire [1:0] PENGUIN_LANE;                // penguin active lane || 00: Left, 10 mid, 11, right
    wire [3:0] score_value;                 // sent by coin generator to score_counter module
   assign OUT_AIRBORNE = PENGUIN_ON_AIR;
   // background
   test_card_simple test_card_simple_1(
            .i_x (i_x),
            .i_y (i_y),
            .o_red      (bg_red),
            .o_green    (bg_green),
            .o_blue     (bg_blue),
            .o_bg_hit   (bg_hit)
    );
    
//     sprite 1
      sprite_compositor sprite_compositor_1 (
         .i_x               (i_x),
         .i_y               (i_y),
         .i_v_sync          (i_v_sync),
         .o_red             (sprite_red),
         .o_green           (sprite_green),
         .o_blue            (sprite_blue),
         .o_sprite_hit      (sprite_hit),
         .mv_left           (MV_LEFT),
         .mv_right          (MV_RIGHT),
         .mv_jump           (MV_JUMP),
         .SPRITE_REFRESHER  (SPRITE_REFRESHER),
         .ACTIVE_LANE       (PENGUIN_LANE),
         .AIRBORNE          (PENGUIN_ON_AIR),
         .SPRITE_STATE      (I_CURRENT_STATE),
         .barrier_hit       (BARRIER_HIT)               // red sprite if barrier hit
     );

    // id compositor
    ID1_compositor ID1 (
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .o_red          (ID1_red),
        .o_green        (ID1_green),
        .o_blue         (ID1_blue),
        .o_sprite_hit   (ID1_hit)
    );

    // life compositor
    life_compositor life (
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .o_red          (life_red),
        .o_green        (life_green),
        .o_blue         (life_blue),
        .o_sprite_hit   (life_hit),
        .barrier_hit    (BARRIER_HIT),          // receive from penguin compositor
        .out_of_lives   (OUT_OF_LIVES)          // send to FSM  
    );

     //cloud1 compositor
    cloud1_compositor cloud1 (
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .o_red          (cloud1_red),
        .o_green        (cloud1_green),
        .o_blue         (cloud1_blue),
        .o_sprite_hit   (cloud1_hit)
    );
    
    cloud2_compositor cloud2 (
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .o_red          (cloud2_red),
        .o_green        (cloud2_green),
        .o_blue         (cloud2_blue),
        .o_sprite_hit   (cloud2_hit)
    );

    
    coin_generator coin_generator_module(
        .i_x                (i_x),
        .i_y                (i_y),
        .i_v_sync           (SPRITE_REFRESHER),
        .active             (I_ACTIVE_COIN),
        .o_red              (coin_red),
        .o_green            (coin_green),
        .o_blue             (coin_blue),
        .o_sprite_hit       (coin_hit),
        .in_position        (COIN_IN_POSITION),
        .penguin_hit        (COIN_HIT),
        .current_lane       (PENGUIN_LANE),             // sent from sprite compositor
        .score_value        (score_value)               // send to score_counter
    );

    score_header_compositor score_header(
        .i_x        (i_x),
        .i_y        (i_y),
        .i_v_sync   (i_v_sync),
        .o_red      (score_h_red),
        .o_green    (score_h_green),
        .o_blue     (score_h_blue),
        .o_sprite_hit   (score_h_hit)
    );
    
    three_digit distance_display(
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .value          (REMAINING_DISTANCE),   // remaining distance value to be shown (receive from FSM)
        .o_digit0_r     (score0_red),
        .o_digit0_g     (score0_green),
        .o_digit0_b     (score0_blue),
        .o_digit0_hit   (score0_hit),
        .o_digit1_r     (score1_red),
        .o_digit1_g     (score1_green),
        .o_digit1_b     (score1_blue),
        .o_digit1_hit   (score1_hit),
        .o_digit2_r     (score2_red),
        .o_digit2_g     (score2_green),
        .o_digit2_b     (score2_blue),
        .o_digit2_hit   (score2_hit),
        .o_meter_r      (meter_red),
        .o_meter_g      (meter_green),
        .o_meter_b      (meter_blue),
        .o_meter_hit    (meter_hit)
    );

    barrier_generator barrier(
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (SPRITE_REFRESHER),
        .active         (I_ACTIVE_BARRIER),                    // what barrier to be shown (receive from FSM)
        .o_red          (barrier_red),
        .o_green        (barrier_green),
        .o_blue         (barrier_blue),
        .o_sprite_hit   (barrier_hit),
        .current_lane   (PENGUIN_LANE),                         // let barrier_generator know what lane we are at
        .in_air         (PENGUIN_ON_AIR),                       // let this know that penguin is on air and avoids barrier
        .penguin_hit    (BARRIER_HIT)                           // send to life compositor for evaluation
    );   

    dist_compositor distance_header(
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .o_red          (dist_red),
        .o_green        (dist_green),
        .o_blue         (dist_blue),
        .o_sprite_hit   (dist_hit)
    );   

    digit0 score_counter(
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .sprite_x       (16'd750),              // const
        .sprite_y       (16'd64),               // const
        .value          (score_value),          // receive score from coin generator
        .o_red          (point_red),
        .o_green        (point_green),
        .o_blue         (point_blue),
        .o_sprite_hit   (point_hit)
    );

    always@(*) begin        
        if (sprite_hit == 1) begin
            o_red=sprite_red;
            o_green=sprite_green;
            o_blue=sprite_blue;
        end
        else if (ID1_hit == 1) begin
            o_red=ID1_red;
            o_green=ID1_green;
            o_blue=ID1_blue;
        end
        
        else if(life_hit == 1) begin
            o_red=life_red;
            o_green=life_green;
            o_blue=life_blue;
        end

        else if(cloud1_hit) begin
            o_red=cloud1_red;
            o_green=cloud1_green;
            o_blue=cloud1_blue;
        end

        else if(cloud2_hit) begin
            o_red=cloud2_red;
            o_green=cloud2_green;
            o_blue=cloud2_blue;
        end
        
        else if(coin_hit) begin
            o_red=coin_red;
            o_green=coin_green;
            o_blue=coin_blue;
        end

        else if(score_h_hit) begin
            o_red=score_h_red;
            o_green=score_h_green;
            o_blue=score_h_blue;
        end
        
        else if(score0_hit) begin
            o_red=score0_red;
            o_green=score0_green;
            o_blue=score0_blue;
        end

        else if(score1_hit) begin
            o_red=score1_red;
            o_green=score1_green;
            o_blue=score1_blue;
        end

        else if(score2_hit) begin
            o_red=score2_red;
            o_green=score2_green;
            o_blue=score2_blue;
        end

        else if(meter_hit) begin
            o_red=meter_red;
            o_green=meter_green;
            o_blue=meter_blue;
        end

        else if(barrier_hit) begin
            o_red=barrier_red;
            o_green=barrier_green;
            o_blue=barrier_blue;
        end
        
        else if(dist_hit) begin
            o_red=dist_red;
            o_green=dist_green;
            o_blue=dist_blue;
        end

        else if(point_hit) begin
            o_red=point_red;
            o_green=point_green;
            o_blue=point_blue; 
        end
    
        else begin
            o_red=bg_red;
            o_green=bg_green;
            o_blue=bg_blue;
        end
    end
    
    assign ZERO_LIVES = OUT_OF_LIVES;
    assign out_barrier_hit = BARRIER_HIT;
    assign out_coin_hit = COIN_HIT;
endmodule