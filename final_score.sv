module final_score (
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_sprite_hit,

    input wire IS_END,                  // sent from FSM, tell to display on screen
    input wire [11:0] score_value       // sent by score_compositor
    );


    wire[7:0] label_red, label_green, label_blue;
    wire[7:0] score_red, score_green, score_blue;
    wire label_hit, score_hit;

    finish_label label_module(
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .o_red          (label_red),
        .o_green        (label_green),
        .o_blue         (label_blue),
        .o_sprite_hit   (label_hit)
    );

    digit_big final_score_display(
        .i_x            (i_x),
        .i_y            (i_y),
        .i_v_sync       (i_v_sync),
        .value          (score_value),
        .o_red          (score_red),
        .o_green        (score_green),
        .o_blue         (score_blue),
        .o_sprite_hit   (score_hit)
    );

    assign o_red   = (label_hit) ? label_red : ((score_hit) ? score_red : 8'hXX);
    assign o_green = (label_hit) ? label_green : ((score_hit) ? score_green : 8'hXX);
    assign o_blue  = (label_hit) ? label_blue : ((score_hit) ? score_blue : 8'hXX);
    assign o_sprite_hit =  IS_END && (label_hit || score_hit);

    // assign o_red = label_red;
    // assign o_green = label_green;
    // assign o_blue = label_blue;
    // assign o_sprite_hit = label_hit;

endmodule