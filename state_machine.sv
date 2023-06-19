module state_machine(
    input wire GAME_SWITCH,
    input wire i_v_sync,
//    input wire MV_LEFT,
//    input wire MV_RIGHT,
//    input wire MV_JUMP,
    
    output wire [2:0]   ACTIVE_LED,             // tell if barrier or coin active
    input wire          PENGUIN_HIT,
    input wire          COIN_HIT,
    output wire [11:0]  DISTANCE_TO_GO,
    output wire [7:0]   O_CURRENT_STATE,
    output wire [1:0]   RELEASE_COIN,
    output wire [1:0]   RELEASE_BARRIER,
    output wire         SPRITE_REFRESHER,
    input wire          ZERO_LIVES              // received from life compositor, set game to FINISH
);

    // wait: waiting for switch to turn up
    enum logic [3:0] {START, COIN1, BARRIER1, COIN2, COIN3, BARRIER2, COIN4, BARRIER3, COIN5, BARRIER4, FINISH} STATE;
    reg [3:0] /* verilator lint_off UNOPTFLAT */ current_state = START;
    logic [6:0] counter; // take top 4 bits for 1
    reg REFRESHER = 1'b0;
    logic [3:0] timer;
    reg [11:0] remaining_distance = 11'd200; // start at 200 meters
    logic game_start = 1'b0;

    reg [1:0] active_barrier = 2'b00;
    reg [1:0] active_coin = 2'b00;
    
    localparam [1:0] RELEASE_NULL           = 2'b00;
    localparam [1:0] ON_LEFT                = 2'b01;
    localparam [1:0] ON_MID                 = 2'b10;
    localparam [1:0] ON_RIGHT               = 2'b11;

    // CLOCK GENERATOR? 
    localparam[7:0] MAX_CLK = 5'b1_0000;
    
     // Timer.. do something only if not wait or finish.
    always@(posedge i_v_sync) begin
        if(current_state != FINISH && GAME_SWITCH != 0) begin
            counter <= counter + 1'b1;      
            if(counter == 7'b111_1111) begin
                remaining_distance = remaining_distance - 1; // slowly reduce the distance
            end
            if(counter[3:0] == 4'b1111) begin
                REFRESHER = ~REFRESHER;
            end
        end
    end

    always@(negedge i_v_sync) begin
        if (ZERO_LIVES == 1) begin
            current_state <= FINISH;
            active_barrier <= RELEASE_NULL;
            active_coin <= RELEASE_NULL;
        end
    
        // Progression
        if(current_state == START && ZERO_LIVES == 0) begin                                        // 0
            if (remaining_distance == 12'd180) begin
                active_barrier <= RELEASE_NULL; 
                active_coin <= ON_MID;
                current_state <= COIN1; // move to the next state
            end 
        end
        
        else if (current_state == COIN1 && ZERO_LIVES == 0) begin                                  // 1
            if(remaining_distance == 12'd160) begin
                active_coin <= RELEASE_NULL;
                active_barrier <= ON_MID;
                current_state <= BARRIER1;
            end
        end

        else if (current_state == BARRIER1 && ZERO_LIVES == 0) begin                               //2
            if(remaining_distance == 12'd140) begin
                active_barrier <= RELEASE_NULL;
                active_coin = ON_RIGHT;
                current_state = COIN2;
            end
        end

        else if(current_state == COIN2 && ZERO_LIVES == 0) begin                                   //3
            if(remaining_distance == 12'd120) begin
                active_barrier <= RELEASE_NULL;
                active_coin <= ON_LEFT;
                current_state <= COIN3;
            end
        end

        else if(current_state == COIN3 && ZERO_LIVES == 0) begin                                  //4
            if(remaining_distance == 12'd100) begin
                active_coin <= RELEASE_NULL;
                active_barrier <= ON_LEFT;
                current_state <= BARRIER2;
            end
        end

        else if(current_state == BARRIER2 && ZERO_LIVES == 0) begin                                //5
            if(remaining_distance == 12'd80) begin
                active_barrier <= RELEASE_NULL;
                active_coin <= ON_RIGHT;
                current_state <= COIN4;
            end
        end

        else if(current_state == COIN4 && ZERO_LIVES == 0) begin                                   //6
            if(remaining_distance == 12'd60) begin
                active_barrier <= ON_RIGHT;
                active_coin <= RELEASE_NULL;
                current_state <= BARRIER3;
            end
        end 

        else if(current_state == BARRIER3 && ZERO_LIVES == 0) begin                                //7
            if(remaining_distance == 12'd40) begin
                active_barrier <= RELEASE_NULL;
                active_coin <= ON_RIGHT;
                current_state <= COIN5;
            end
        end

        else if (current_state == COIN5 && ZERO_LIVES == 0) begin                                  //8
            if(remaining_distance == 12'd20) begin
                active_coin <= RELEASE_NULL;
                active_barrier <= ON_RIGHT;
                current_state <= BARRIER4;
            end
        end

        else if (current_state == BARRIER4 && ZERO_LIVES == 0) begin                               //9
            if(remaining_distance == 12'd0) begin
                active_coin <= RELEASE_NULL;
                active_barrier <= RELEASE_NULL;
                current_state <= FINISH;
            end
        end
        
        else if (current_state == FINISH) begin                                 // 10
            active_barrier <= RELEASE_NULL;
            active_coin <= RELEASE_NULL;
        end
        
        
        // deactivate barrier or coin if hit
        if(PENGUIN_HIT) begin
            active_barrier <= RELEASE_NULL;
        end
        
        if(COIN_HIT) begin
            active_coin <= RELEASE_NULL;
        end
    end
    
    assign ACTIVE_LED = (active_barrier != RELEASE_NULL) ? 3'b100 : (active_coin != RELEASE_NULL ? 3'b110 : 3'b010);
    assign DISTANCE_TO_GO = remaining_distance;
    assign O_CURRENT_STATE = current_state;
    assign RELEASE_COIN = active_coin;
    assign RELEASE_BARRIER  = (PENGUIN_HIT) ? RELEASE_NULL : active_barrier;
    assign SPRITE_REFRESHER = REFRESHER;

endmodule