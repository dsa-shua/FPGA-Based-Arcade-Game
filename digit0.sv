module digit0 (
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,   
    input reg[15:0] sprite_x,
    input reg[15:0] sprite_y,
    input wire[11:0] value,           // plug what you want to put in here (0->9 : 0000 -> 1001)
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_sprite_hit
    );
    
    wire sprite_hit_x, sprite_hit_y;
    wire [3:0] sprite_render_x;
    wire [3:0] sprite_render_y;

// transparent, black?, gray, yellow
    localparam /* verilator lint_off LITENDIAN */[0:3][2:0][7:0] palette_colors =  { /* verilator lint_off LITENDIAN */
        8'h00, 8'h00, 8'h00,
        8'h20, 8'h20, 8'h20,
        8'h60, 8'h60, 8'h60,
        8'hFF, 8'hFF, 8'h00
    };
   
    localparam [0:7][0:3][3:0] sprite_data0 = {/* verilator lint_off LITENDIAN */
        4'd0,4'd0,4'd0,4'd0,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd1,4'd0,4'd1,
        4'd0,4'd1,4'd0,4'd1,
        4'd0,4'd1,4'd0,4'd1,
        4'd0,4'd1,4'd0,4'd1,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd0
    };
    localparam [0:7][0:3][3:0] sprite_data1 = {/* verilator lint_off LITENDIAN */
        4'd0,4'd0,4'd0,4'd0,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd0
    };
    localparam [0:7][0:3][3:0] sprite_data2 = {/* verilator lint_off LITENDIAN */
        4'd0,4'd0,4'd0,4'd0,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd1,4'd0,4'd0,
        4'd0,4'd1,4'd0,4'd0,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd0
    };
        localparam [0:7][0:3][3:0] sprite_data3 = {/* verilator lint_off LITENDIAN */
        4'd0,4'd0,4'd0,4'd0,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd0
    };
        localparam [0:7][0:3][3:0] sprite_data4 = {/* verilator lint_off LITENDIAN */
        4'd0,4'd0,4'd0,4'd0,
        4'd0,4'd1,4'd0,4'd1,
        4'd0,4'd1,4'd0,4'd1,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd0
    };
        localparam [0:7][0:3][3:0] sprite_data5 = {/* verilator lint_off LITENDIAN */
        4'd0,4'd0,4'd0,4'd0,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd1,4'd0,4'd0,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd0
    };
        localparam [0:7][0:3][3:0] sprite_data6 = {/* verilator lint_off LITENDIAN */
        4'd0,4'd0,4'd0,4'd0,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd1,4'd0,4'd0,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd1,4'd0,4'd1,
        4'd0,4'd1,4'd0,4'd1,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd0
    };
        localparam [0:7][0:3][3:0] sprite_data7 = {/* verilator lint_off LITENDIAN */
        4'd0,4'd0,4'd0,4'd0,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd0
    };
        localparam [0:7][0:3][3:0] sprite_data8 = {/* verilator lint_off LITENDIAN */
        4'd0,4'd0,4'd0,4'd0,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd1,4'd0,4'd1,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd1,4'd0,4'd1,
        4'd0,4'd1,4'd0,4'd1,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd0
    };
        localparam [0:7][0:3][3:0] sprite_data9 = {/* verilator lint_off LITENDIAN */
        4'd0,4'd0,4'd0,4'd0,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd1,4'd0,4'd1,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd0,4'd0,4'd1,
        4'd0,4'd1,4'd1,4'd1,
        4'd0,4'd0,4'd0,4'd0
    };

    assign sprite_hit_x = (i_x >= sprite_x) && (i_x < sprite_x + 32);
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + 64);
    assign sprite_render_x = (i_x - sprite_x)>>3;
    assign sprite_render_y = (i_y - sprite_y)>>3;

    
    // assign selected_palette = sprite_data1[sprite_render_y][sprite_render_x];
    
    logic [1:0] selected_palette;
    always_comb begin
        if (value == 12'd0) begin
            selected_palette = sprite_data0[sprite_render_y][sprite_render_x];
        end
        
        else if (value == 12'd1) begin
            selected_palette = sprite_data1[sprite_render_y][sprite_render_x];
        end

        else if (value == 12'd2) begin
            selected_palette = sprite_data2[sprite_render_y][sprite_render_x];
        end

        else if (value == 12'd3) begin
            selected_palette = sprite_data3[sprite_render_y][sprite_render_x];
        end

        else if (value == 12'd4) begin
            selected_palette = sprite_data4[sprite_render_y][sprite_render_x];
        end

        else if (value == 12'd5) begin
            selected_palette = sprite_data5[sprite_render_y][sprite_render_x];
        end

        else if (value == 12'd6) begin
            selected_palette = sprite_data6[sprite_render_y][sprite_render_x];
        end

        else if (value == 12'd7) begin
            selected_palette = sprite_data7[sprite_render_y][sprite_render_x];
        end

        else if (value == 12'd8) begin
            selected_palette = sprite_data8[sprite_render_y][sprite_render_x];
        end

        else begin
            selected_palette = sprite_data9[sprite_render_y][sprite_render_x];
        end
    end
                                                                         
    assign o_red    = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][2] : 8'hXX;
    assign o_green  = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][1] : 8'hXX;
    assign o_blue   = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][0] : 8'hXX;
    assign o_sprite_hit = (sprite_hit_y & sprite_hit_x) && (selected_palette != 2'd0);

endmodule