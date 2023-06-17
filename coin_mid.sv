module coin_mid (
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input wire active,                // on pos edge, this coin appears on screen
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_sprite_hit,
    output wire in_position         // This coin is now in position to be hit by sprite
    );
    
    reg [15:0] sprite_x  = 16'd640-16'd64;
    reg [15:0] sprite_y  = 16'd360-16'd50;
    wire sprite_hit_x, sprite_hit_y;
    wire [3:0] sprite_render_x;
    wire [4:0] sprite_render_y;           
    reg IN_PLACE = 0;               // 0 if coin is still travelling. 1 if coin is now ready to be hit

// transparent, yellow, orange, dark orange
    localparam /* verilator lint_off LITENDIAN */[0:3][2:0][7:0] palette_colors =  { /* verilator lint_off LITENDIAN */
        8'h00, 8'h00, 8'h00,
        8'hff, 8'heb, 8'h3b,
        8'hff, 8'hc1, 8'h07,
        8'hff, 8'h99, 8'h00
    };
   
    localparam [0:15][0:15][3:0] sprite_data = {/* verilator lint_off LITENDIAN */
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd3,4'd3,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd3,4'd2,4'd2,4'd3,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd3,4'd2,4'd1,4'd1,4'd2,4'd3,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd0,4'd3,4'd2,4'd1,4'd1,4'd1,4'd1,4'd2,4'd3,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd3,4'd2,4'd1,4'd1,4'd2,4'd2,4'd1,4'd1,4'd2,4'd3,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd3,4'd2,4'd1,4'd1,4'd2,4'd1,4'd1,4'd2,4'd1,4'd1,4'd2,4'd3,4'd0,4'd0,
    4'd0,4'd3,4'd2,4'd1,4'd1,4'd2,4'd1,4'd1,4'd1,4'd1,4'd2,4'd1,4'd1,4'd2,4'd3,4'd0,
    4'd0,4'd3,4'd2,4'd1,4'd1,4'd2,4'd1,4'd1,4'd1,4'd1,4'd2,4'd1,4'd1,4'd2,4'd3,4'd0,
    4'd0,4'd0,4'd3,4'd2,4'd1,4'd1,4'd2,4'd1,4'd1,4'd2,4'd1,4'd1,4'd2,4'd3,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd3,4'd2,4'd1,4'd1,4'd2,4'd2,4'd1,4'd1,4'd2,4'd3,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd0,4'd3,4'd2,4'd1,4'd1,4'd1,4'd1,4'd2,4'd3,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd3,4'd2,4'd1,4'd1,4'd2,4'd3,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd3,4'd2,4'd2,4'd3,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd3,4'd3,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0
    };

    logic[15:0] stretch;
    logic [3:0] stretch_factor;

    always_latch begin

    end

    assign sprite_hit_x = (i_x >= sprite_x) && (i_x < sprite_x + stretch);
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + stretch);
    assign sprite_render_x = (i_x - sprite_x)>>stretch_factor;
    assign sprite_render_y = (i_y - sprite_y)>>stretch_factor;

    reg [1:0] selected_palette;
    assign selected_palette = sprite_data[sprite_render_y][sprite_render_x];
    assign o_red    = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][2] : 8'hXX;
    assign o_green  = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][1] : 8'hXX;
    assign o_blue   = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][0] : 8'hXX;
    assign o_sprite_hit = active ? (sprite_hit_y & sprite_hit_x) && (selected_palette != 2'd0): 1'b0;

    
    always@(posedge i_v_sync) begin
        if (active == 1) begin
            sprite_y <= sprite_y + 10;
            if(sprite_y > 720) begin
                sprite_y <= 720;    // when over the screen, stay hidden
                IN_PLACE <= 0;
            end

            if(sprite_y >= 360-50 && sprite_y < 440-50) begin
                stretch <= 32;
                stretch_factor <= 1; 
                sprite_x <= 16'd680 - 16'd64;
            end
    
            else if(sprite_y >= 480-50 && sprite_y < 600-50) begin
                stretch <= 64;
                stretch_factor <= 2;
                sprite_x <= 16'd680 - 16'd64;
            end
    
            else if (sprite_y >= 600-50) begin
                stretch <= 128;
                stretch_factor <= 3;
                sprite_x <= 16'd680 - 16'd100;
                IN_PLACE <= 1;   // this coin is now ready to be hit
            end           
        end
        else if (active == 0) begin
            sprite_y <= 360-50;
            IN_PLACE <= 0;
        end
    end
    assign in_position = IN_PLACE;
endmodule