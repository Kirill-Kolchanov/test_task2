`timescale 1ns / 1ps

module stream_upsize_tb;

    parameter T_DATA_WIDTH = 4;
    parameter T_DATA_RATIO = 2;

    // Signals
    reg clk;
    reg rst_n;
    reg [T_DATA_WIDTH-1:0] s_data_i;
    reg s_last_i;
    reg s_valid_i;
    wire s_ready_o;
    wire [T_DATA_WIDTH-1:0] m_data_o [T_DATA_RATIO-1:0];
    wire [T_DATA_RATIO-1:0] m_keep_o;
    wire m_last_o;
    wire m_valid_o;
    reg m_ready_i;

    // Instantiate the Unit Under Test (UUT)
    stream_upsize #(
        .T_DATA_WIDTH(T_DATA_WIDTH),
        .T_DATA_RATIO(T_DATA_RATIO)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .s_data_i(s_data_i),
        .s_last_i(s_last_i),
        .s_valid_i(s_valid_i),
        .s_ready_o(s_ready_o),
        .m_data_o(m_data_o),
        .m_keep_o(m_keep_o),
        .m_last_o(m_last_o),
        .m_valid_o(m_valid_o),
        .m_ready_i(m_ready_i)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Monitoring internal and I/O signals
    always_comb begin
        $display("Time: %t, rst_n: %b, s_data_i: %h, s_last_i: %b, s_valid_i: %b, s_ready_o: %b, m_data_o: {%h, %h}, m_keep_o: {%b, %b}, m_last_o: %b, m_valid_o: %b, m_ready_i: %b, count: %d",
                 $time, rst_n, s_data_i, s_last_i, s_valid_i, s_ready_o, m_data_o[0], m_data_o[1], m_keep_o[0], m_keep_o[1], m_last_o, m_valid_o, m_ready_i, uut.count);
    end

    // Initial Setup and Input Stimulus
    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 1;
        s_data_i = 0;
        s_last_i = 0;
        s_valid_i = 0;
        m_ready_i = 1;

        // Reset the module
        rst_n = 0;
        #10;
        rst_n = 1;
        #10;

        // Test input sequence
        // Cycle 1
        s_data_i = 4'b0000; s_valid_i = 1; s_last_i = 0; #10;
        // Cycle 2
        s_data_i = 4'b0001; s_valid_i = 0; s_last_i = 0; #10;
        // Cycle 3
        s_data_i = 4'b0010; s_valid_i = 1; s_last_i = 1; #10;
        // Cycle 4
        s_data_i = 4'b1010; s_valid_i = 1; s_last_i = 0; #10;
        // Cycle 5
        s_data_i = 4'b1011; s_valid_i = 1; s_last_i = 1; #10;
        s_valid_i = 0; #20;  // Turn off s_valid_i to emulate end of input
        
        s_data_i = 4'b0100; s_valid_i = 1; s_last_i = 1; #10;
        // Cycle 2
        s_data_i = 4'b0000; s_valid_i = 1; s_last_i = 1; #10;
        // Cycle 3
        s_data_i = 4'b0011; s_valid_i = 1; s_last_i = 0; #10;
        // Cycle 4
        s_data_i = 4'b1110; s_valid_i = 1; s_last_i = 0; #10;
        // Cycle 5
        s_data_i = 4'b1011; s_valid_i = 1; s_last_i = 1; #10;
        s_valid_i = 0; #10;  // Turn off s_valid_i to emulate end of input
        // Wait for output processing
        #100;

        // Finish the simulation
        $finish;
    end

endmodule
