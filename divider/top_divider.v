`timescale 1ns / 1ps

module top_divider(
    input clk, reset_btn, start_btn,     
    input btnU, btnD, btnL, btnR,    
    input [15:0] sw,      
    output [7:0] an, output [6:0] seg, output done_led
);
    wire sys_reset = ~reset_btn; 
    wire [31:0] rs1_data = {{24{sw[7]}}, sw[7:0]};   
    wire [31:0] rs2_data = {{24{sw[15]}}, sw[15:8]}; 
    
    // Start button pulse generator
    reg btn_sync_0, btn_sync_1, btn_prev; 
    always @(posedge clk) begin 
        btn_sync_0 <= start_btn; btn_sync_1 <= btn_sync_0; btn_prev <= btn_sync_1; 
    end
    wire start_pulse = (btn_sync_1 == 1'b1 && btn_prev == 1'b0); 

    // FIXED: Memory Register to remember the D-Pad selection
    reg [2:0] current_funct3;
    always @(posedge clk or posedge sys_reset) begin
        if (sys_reset) current_funct3 <= 3'b100; // Reset defaults to DIV
        else if (btnU) current_funct3 <= 3'b100; // DIV (Up)
        else if (btnD) current_funct3 <= 3'b110; // REM (Down)
        else if (btnL) current_funct3 <= 3'b101; // DIVU (Left)
        else if (btnR) current_funct3 <= 3'b111; // REMU (Right)
    end

    wire [31:0] div_result; wire div_valid;
    
    divider my_div (
        .clk(clk), .rst(sys_reset), .start(start_pulse), 
        .funct3(current_funct3), .operand_a(rs1_data), .operand_b(rs2_data), 
        .result(div_result), .valid(div_valid)
    );

    assign done_led = div_valid; 

    // Display Format: [Op B][Op A][Result]
    wire [31:0] display_data = {sw[15:8], sw[7:0], div_result[15:0]};
    seven_seg_driver disp (.clk(clk), .reset(sys_reset), .data_in(display_data), .an(an), .seg(seg));
endmodule