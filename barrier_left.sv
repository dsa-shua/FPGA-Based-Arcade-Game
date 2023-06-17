module barrier_left (
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input wire active,                          // on HIGH, show barrier on screen
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_sprite_hit,
    output wire in_position                     // barrier can now be hit
    );

    reg [15:0] sprite_x     = 16'd490-16'd32;
    reg [15:0] sprite_y     = 16'd360;          // somewhere at the bottom of the screen 
    wire sprite_hit_x, sprite_hit_y;
    wire [3:0] sprite_render_x;
    wire [3:0] sprite_render_y;
    reg IN_PLACE = 0;                           // barrier in place

    localparam /* verilator lint_off LITENDIAN */[0:3][2:0][7:0] palette_colors =  { /* verilator lint_off LITENDIAN */
        8'h00, 8'h00, 8'h00,
        8'hFF, 8'h00, 8'h00,
        8'h8e, 8'hd8, 8'hed,
        8'hFF, 8'hFF, 8'hFF
    };
   
    localparam [0:7][0:15][3:0] sprite_data = {/* verilator lint_off LITENDIAN */
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
    4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
    4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
    4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0
    };

    reg[15:0] stretch_x;
    reg[3:0] stretch_factor;



    assign sprite_hit_x = (i_x >= sprite_x) && (i_x < sprite_x + stretch_x);
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + 32);
    assign sprite_render_x = (i_x - sprite_x)>>stretch_factor;
    assign sprite_render_y = (i_y - sprite_y)>>2;
    

    wire [1:0] selected_palette;

    assign selected_palette = sprite_data[sprite_render_y][sprite_render_x];
                                                                         
    assign o_red    = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][2] : 8'hXX;
    assign o_green  = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][1] : 8'hXX;
    assign o_blue   = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][0] : 8'hXX;
    assign o_sprite_hit = active ? (sprite_hit_y & sprite_hit_x) && (selected_palette != 2'd0): 1'b0;



    always@(posedge i_v_sync) begin
        if (active == 1) begin
            sprite_y = sprite_y + 10;
            sprite_x = sprite_x - 10;
            if (sprite_y >= 16'd720) begin
                sprite_y = 16'd720; // hide 
                sprite_x = 16'd490-16'd32;
                IN_PLACE = 0;
            end
            
            if(sprite_y >= 360) begin
                stretch_x = 64;
                stretch_factor = 2;
            end
            if (sprite_y >= 440) begin
                stretch_x = 128;
                stretch_factor = 3;
            end
            if (sprite_y >= 550) begin
                stretch_x = 256;
                stretch_factor = 4;
                IN_PLACE = 1;               // READY TO BE HIT
            end
        end
        else if (active == 0) begin
                sprite_y = 16'd360;
                sprite_x = 16'd490-16'd32;
                IN_PLACE = 0;
        end
    end 
    assign in_position = IN_PLACE;
endmodule