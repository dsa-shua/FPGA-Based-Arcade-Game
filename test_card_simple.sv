module test_card_simple #(H_RES=1280, V_RES=720) (
    input wire signed [15:0] i_x,
    input wire signed [15:0] i_y,
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_bg_hit
    );

    logic[7:0] paint_r, paint_g, paint_b;
    logic sky; // sky background 
    localparam sky_limit = 360; // 720 >> 2

    localparam trapezoid_top_left = 490; // Adjust the left coordinate of the top base of the trapezoid here
    localparam trapezoid_top_right = 790; // Adjust the right coordinate of the top base of the trapezoid here
    localparam trapezoid_bottom_left = 130; // Adjust the left coordinate of the bottom base of the trapezoid here
    localparam trapezoid_bottom_right = 1150; // Adjust the right coordinate of the bottom base of the trapezoid here
    localparam trapezoid_height = 720 - sky_limit; // Calculate the height of the trapezoid based on the screen height and sky limit

    logic road_edge; // is pixel part of edge of left (0) or right edge (1)?
    reg[15:0] road_x_diff = 16'd0;
    reg[15:0] road_y_diff = 16'd0; 
    reg on_road_edge = 0;

    reg[15:0] left_limit = 16'd0;
    reg[15:0] right_limit = 16'd0;

    localparam snow = 8'hFF; // white RGB
    // GRAY ROAD COLOR
    localparam road_r = 8'h00;
    localparam road_g = 8'hFF;
    localparam road_b = 8'hFF;

    logic[7:0] sky_r, sky_g, sky_b;
    // Check if the pixel is inside the trapezoid
    reg inside_trapezoid;
    always_comb begin
        road_y_diff = i_y - 360;
        left_limit = 490 - road_y_diff;
        right_limit = 790 + road_y_diff;

        inside_trapezoid = (i_y >= 360) && ((i_x >= 490 || i_x <= 790) && (i_x >= left_limit && i_x <= right_limit));
    end

    always_comb begin
        if(i_y <= 120) begin
            sky_r = 8'd63;
            sky_g = 8'd81;
            sky_b = 8'd181;
        end
        else if(i_y <= 240) begin
            sky_r = 8'd33;
            sky_g = 8'd149;
            sky_b = 8'd243;
        end
        else begin
            sky_r = 8'd3;
            sky_g = 8'd168;
            sky_b = 8'd244;
        end
    end

    // is this pixel part of the sky or inside the trapezoid?
    always_comb begin
        sky = (i_y <= sky_limit);
        if (inside_trapezoid) begin
            paint_r = 8'hE0;  // Green color inside the trapezoid
            paint_g = 8'hE0;
            paint_b = 8'hE0;
        end else begin
            paint_r = sky ? sky_r : 8'hFF; // Sky or background color
            paint_g = sky ? sky_g : 8'hFF;
            paint_b = sky ? sky_b : 8'hFF;
        end
    end

    // assign to output
    assign o_red = on_road_edge ? 8'h00 : paint_r;
    assign o_green = on_road_edge ? 8'h00 : paint_g;
    assign o_blue = on_road_edge ? 8'h00 : paint_b;

endmodule
