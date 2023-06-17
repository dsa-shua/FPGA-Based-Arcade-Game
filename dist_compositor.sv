module dist_compositor (
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_sprite_hit
    );
    
    reg [15:0] sprite_x     = 16'd350;
    reg [15:0] sprite_y     = 16'd16; // somewhere at the bottom of the screen 
    reg sprite_x_direction  = 1;
    reg sprite_y_direction  = 1;
    reg sprite_x_flip       = 0;
    reg sprite_y_flip       = 0;
    wire sprite_hit_x, sprite_hit_y;
    wire [4:0] sprite_render_x;
    wire [3:0] sprite_render_y;
    

// transparent, black?, gray, yellow
    localparam /* verilator lint_off LITENDIAN */[0:3][2:0][7:0] palette_colors =  { /* verilator lint_off LITENDIAN */
        8'h00, 8'h00, 8'h00,
        8'h20, 8'h20, 8'h20,
        8'hFF, 8'h00, 8'h00,
        8'hFF, 8'hFF, 8'h00
    };
   
    localparam [0:7][0:31][3:0] sprite_data = {/* verilator lint_off LITENDIAN */    
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,4'd1,4'd0,4'd1,4'd1,4'd1,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd1,4'd0,4'd1,4'd0,4'd1,4'd0,4'd1,4'd0,4'd0,4'd0,4'd0,4'd1,4'd0,4'd0,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd1,4'd0,4'd1,4'd0,4'd1,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd1,4'd0,4'd1,4'd0,4'd1,4'd0,4'd0,4'd0,4'd1,4'd0,4'd0,4'd1,4'd0,4'd0,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,4'd1,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
    4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0
    };



    assign sprite_hit_x = (i_x >= sprite_x) && (i_x < sprite_x + 256);
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + 64);
    assign sprite_render_x = (i_x - sprite_x)>>3;
    assign sprite_render_y = (i_y - sprite_y)>>3;
    

    wire [1:0] selected_palette;

    assign selected_palette = sprite_x_flip ? (sprite_y_flip ? sprite_data[15-sprite_render_y][15-sprite_render_x]: sprite_data[sprite_render_y][15-sprite_render_x])
                                            : (sprite_y_flip ? sprite_data[15-sprite_render_y][sprite_render_x]   : sprite_data[sprite_render_y][sprite_render_x]);
                                                                         
    assign o_red    = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][2] : 8'hXX;
    assign o_green  = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][1] : 8'hXX;
    assign o_blue   = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][0] : 8'hXX;
    assign o_sprite_hit = (sprite_hit_y & sprite_hit_x) && (selected_palette != 2'd0);
endmodule