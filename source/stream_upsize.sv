module stream_upsize #(
    parameter T_DATA_WIDTH = 4,
    parameter T_DATA_RATIO = 2
)(
    input logic clk,                     
    input logic rst_n,                   
    input logic [T_DATA_WIDTH-1:0] s_data_i,  
    input logic s_last_i,                
    input logic s_valid_i,               
    output logic s_ready_o,              
    output logic [T_DATA_WIDTH-1:0] m_data_o [T_DATA_RATIO-1:0],  
    output logic [T_DATA_RATIO-1:0] m_keep_o, 
    output logic m_last_o,            
    output logic m_valid_o,              
    input logic m_ready_i                 
);

    logic [$clog2(T_DATA_RATIO):0] count; // Counter to keep track of number of data elements in the buffer
    
    logic buffer_full;                    // Flag indicating if the buffer is full

    wire wr = s_valid_i & s_ready_o;      
    wire rd = m_valid_o & m_ready_i;      
    assign buffer_full = (count == T_DATA_RATIO - 1); // Determine if the buffer is full
    
    logic m_keep_o_rst;                    // Internal signal for resetting the keep signals

    always @(posedge clk or negedge rst_n) begin // Clocked always block for synchronous logic and reset handling
        
        if(!rst_n) begin            // Reset condition
            m_valid_o = 0;          
            m_keep_o = 0;           
            s_ready_o = 1;          
            count = 0;              
        end

        if (m_keep_o_rst) begin     // Handle the keep signals reset condition
            m_keep_o = 0;           // Reset the keep signals
        end

        if (wr) begin               
            
            if (m_valid_o) begin     // If output stream is valid
                m_valid_o = 0;       
                m_last_o = 0;        
                m_keep_o = 0;        
            end
            
            m_data_o[count] = s_data_i;  // Write input data to the appropriate output stream element
            m_keep_o[count] = 1'b1;       // Set the keep signal for the written data
            count = count + 1;            // Increment the counter
            
            if (buffer_full || s_last_i) begin  // If the buffer is full or input stream indicates last word
                if (s_last_i) begin             
                    m_keep_o_rst = 1;           // Set the reset signal for keep signals
                    count = 0;                  // Reset the counter
                end
                m_valid_o = 1;                  
                count = 0;                      // Reset the counter
                m_last_o = s_last_i;            
            end else begin
                m_valid_o = 0;                  
            end
        end else begin
            m_valid_o = 0;                      
        end
    end

endmodule