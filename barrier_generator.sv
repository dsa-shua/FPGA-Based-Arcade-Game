module barrier_generator(
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input wire [1:0] active,            // 00: no show, 01: left, 10: mid: 11: right       
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_sprite_hit,
    input wire[1:0] current_lane,         // This is now in position to be hit by sprite
    input wire in_air,                     // is penguin on air??
    output wire penguin_hit               // raise to let life compositor know we subtract 1 life
);
    logic MID_BARRIER_ACTIVATE;         // show mid 
    logic LEFT_BARRIER_ACTIVATE;        // show left
    logic RIGHT_BARRIER_ACTIVATE;       // show right
    logic BARRIER_M_IN_POSITION;        // on mid now ready to be hit
    logic BARRIER_L_IN_POSITION;        // on left now ready to be hit
    logic BARRIER_R_IN_POSITION;        // on right now ready to be hit

    logic[7:0] LEFT_R, LEFT_G, LEFT_B;
    logic[7:0] MID_R, MID_G, MID_B;
    logic[7:0] RIGHT_R, RIGHT_G, RIGHT_B;
    logic LEFT_S_HIT, MID_S_HIT, RIGHT_S_HIT;
    
    logic[1:0] sprite_current_lane = 2'b00;
    logic[7:0] PAINT_R, PAINT_G, PAINT_B;
    logic SPRITE_HIT;
    logic SPRITE_IN_POS;
    logic temp_hit = 0;                           // collision occured, deactivate
    
    always_latch begin
        // when FSM tells no active barrier yet, deactivate everything
        if(active == 2'b00) begin
            MID_BARRIER_ACTIVATE = 1'b0;
            LEFT_BARRIER_ACTIVATE =1'b0;
            RIGHT_BARRIER_ACTIVATE = 1'b0;
            SPRITE_HIT = 1'b0;
            SPRITE_IN_POS = 1'b0;
        end
        
        // activation only if sprite is not yet hit
        else if (active == 2'b01) begin
            MID_BARRIER_ACTIVATE = 1'b0;
            LEFT_BARRIER_ACTIVATE =1'b1;
            RIGHT_BARRIER_ACTIVATE = 1'b0;
            SPRITE_HIT = LEFT_S_HIT;
            SPRITE_IN_POS = BARRIER_L_IN_POSITION;
            PAINT_R = LEFT_R;
            PAINT_G = LEFT_G;
            PAINT_B = LEFT_B;
        end
        else if (active == 2'b10) begin
            MID_BARRIER_ACTIVATE = 1'b1;
            LEFT_BARRIER_ACTIVATE =1'b0;
            RIGHT_BARRIER_ACTIVATE = 1'b0;
            SPRITE_HIT = MID_S_HIT;
            SPRITE_IN_POS = BARRIER_M_IN_POSITION;
            PAINT_R = MID_R;
            PAINT_G = MID_G;
            PAINT_B = MID_B;
        end
        else if (active == 2'b11) begin
            MID_BARRIER_ACTIVATE = 1'b0;
            LEFT_BARRIER_ACTIVATE =1'b0;
            RIGHT_BARRIER_ACTIVATE = 1'b1;
            SPRITE_HIT = RIGHT_S_HIT;
            SPRITE_IN_POS = BARRIER_R_IN_POSITION;
            PAINT_R = RIGHT_R;
            PAINT_G = RIGHT_G;
            PAINT_B = RIGHT_B;
        end
    end
    
    barrier_left LBARRIER (
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .active         (LEFT_BARRIER_ACTIVATE),
        .o_red          (LEFT_R),
        .o_green        (LEFT_G),
        .o_blue         (LEFT_B),
        .o_sprite_hit   (LEFT_S_HIT),
        .in_position    (BARRIER_L_IN_POSITION)
    );
    
    barrier_mid MBARRIER (
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .active         (MID_BARRIER_ACTIVATE),
        .o_red          (MID_R),
        .o_green        (MID_G),
        .o_blue         (MID_B),
        .o_sprite_hit   (MID_S_HIT),
        .in_position    (BARRIER_M_IN_POSITION)
    );

    barrier_right RBARRIER (
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .active         (RIGHT_BARRIER_ACTIVATE),
        .o_red          (RIGHT_R),
        .o_green        (RIGHT_G),
        .o_blue         (RIGHT_B),
        .o_sprite_hit   (RIGHT_S_HIT),
        .in_position    (BARRIER_R_IN_POSITION)
    );

    assign o_red = PAINT_R;
    assign o_green = PAINT_G;
    assign o_blue = PAINT_B;
    assign o_sprite_hit = SPRITE_HIT;
    
    
    // check if we are hit
    always@(posedge i_v_sync) begin
        sprite_current_lane = current_lane;             // save to register
        if(sprite_current_lane == 2'b00 && BARRIER_L_IN_POSITION) begin // left
            temp_hit <= 1;
        end
        
        else if(sprite_current_lane == 2'b10 && BARRIER_M_IN_POSITION) begin // mid
            temp_hit <= 1;
        end
        
        else if(sprite_current_lane == 2'b11 && BARRIER_R_IN_POSITION) begin
            temp_hit <= 1;
        end 
        else if (active == 0) begin // set to low only when no barrier is active
            temp_hit <= 0;
        end
    end
    assign penguin_hit = temp_hit;
endmodule