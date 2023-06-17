module coin_generator(
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    
    output wire [11:0] score_value,
    input wire[1:0] current_lane,   // from FSM, check current penguin lane
    output wire penguin_hit,        // tell score to add 1
    input wire[2:0] active,         // 00: no coin, 01: left, 10: mid: 11: right       
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_sprite_hit,
    output wire in_position         // This coin is now in position to be hit by sprite
);
    logic MID_COIN_ACTIVATE;         // show mid coin on screen
    logic LEFT_COIN_ACTIVATE;        // show left coin
    logic RIGHT_COIN_ACTIVATE;       // show right coin
    logic COIN_M_IN_POSITION;        // coin on mid now ready to be hit
    logic COIN_L_IN_POSITION;        // coin on left now ready to be hit
    logic COIN_R_IN_POSITION;        // coin on right now ready to be hit

    logic[7:0] LEFT_R, LEFT_G, LEFT_B;
    logic[7:0] MID_R, MID_G, MID_B;
    logic[7:0] RIGHT_R, RIGHT_G, RIGHT_B;
    logic LEFT_S_HIT, MID_S_HIT, RIGHT_S_HIT;
    
    reg[4:0] score = 5'b00000;
    reg[7:0] PAINT_R, PAINT_G, PAINT_B;
    reg SPRITE_HIT;
    reg SPRITE_IN_POS;
    

    coin_left LCOIN (
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .active         (LEFT_COIN_ACTIVATE),
        .o_red          (LEFT_R),
        .o_green        (LEFT_G),
        .o_blue         (LEFT_B),
        .o_sprite_hit   (LEFT_S_HIT),
        .in_position    (COIN_L_IN_POSITION)
    );
    
    coin_mid MCOIN (
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .active         (MID_COIN_ACTIVATE),
        .o_red          (MID_R),
        .o_green        (MID_G),
        .o_blue         (MID_B),
        .o_sprite_hit   (MID_S_HIT),
        .in_position    (COIN_M_IN_POSITION)
    );

    coin_right RCOIN (
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .active         (RIGHT_COIN_ACTIVATE),
        .o_red          (RIGHT_R),
        .o_green        (RIGHT_G),
        .o_blue         (RIGHT_B),
        .o_sprite_hit   (RIGHT_S_HIT),
        .in_position    (COIN_R_IN_POSITION)
    );

    reg temp_hit = 0;
    always_latch begin 
        if(active == 2'b00) begin
            MID_COIN_ACTIVATE = 1'b0;
            LEFT_COIN_ACTIVATE =1'b0;
            RIGHT_COIN_ACTIVATE = 1'b0;
            SPRITE_HIT = 1'b0;
            SPRITE_IN_POS = 1'b0;
        end
        else if (active == 2'b01 && temp_hit == 0) begin
            MID_COIN_ACTIVATE = 1'b0;
            LEFT_COIN_ACTIVATE =1'b1;
            RIGHT_COIN_ACTIVATE = 1'b0;
            SPRITE_HIT = LEFT_S_HIT;
            SPRITE_IN_POS = COIN_L_IN_POSITION;
            PAINT_R = LEFT_R;
            PAINT_G = LEFT_G;
            PAINT_B = LEFT_B;
        end
        else if (active == 2'b10 && temp_hit == 0) begin
            MID_COIN_ACTIVATE = 1'b1;
            LEFT_COIN_ACTIVATE =1'b0;
            RIGHT_COIN_ACTIVATE = 1'b0;
            SPRITE_HIT = MID_S_HIT;
            SPRITE_IN_POS = COIN_M_IN_POSITION;
            PAINT_R = MID_R;
            PAINT_G = MID_G;
            PAINT_B = MID_B;
        end
        else if (active == 2'b11 && temp_hit == 0) begin
            MID_COIN_ACTIVATE = 1'b0;
            LEFT_COIN_ACTIVATE =1'b0;
            RIGHT_COIN_ACTIVATE = 1'b1;
            SPRITE_HIT = RIGHT_S_HIT;
            SPRITE_IN_POS = COIN_R_IN_POSITION;
            PAINT_R = RIGHT_R;
            PAINT_G = RIGHT_G;
            PAINT_B = RIGHT_B;
        end
    end
    

        // check if we are hit
    always@(posedge i_v_sync) begin
        if(COIN_L_IN_POSITION && current_lane == 2'b01) begin // left
            score <= score + 1'b1;
            temp_hit <= 1;
        end
        
        else if(COIN_M_IN_POSITION && current_lane == 2'b10) begin // mid
                score <= score + 1'b1;
            temp_hit <= 1;
        end
        
        else if(COIN_R_IN_POSITION && current_lane == 2'b11) begin
                score <= score + 1'b1;
            temp_hit <= 1;
        end 
        else if (active == 2'b00) begin // set to low only when no barrier is active
            temp_hit <= 0;
        end
    end
   
    
    assign penguin_hit = temp_hit;
    assign score_value = score[4:1];
    assign o_red = PAINT_R;
    assign o_green = PAINT_G;
    assign o_blue = PAINT_B;
    assign o_sprite_hit = SPRITE_HIT;
    assign in_position = SPRITE_IN_POS;

endmodule