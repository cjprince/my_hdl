//~ `New testbench
`timescale  1ns / 1ns

module tb_crc32_8bit;

// crc32_8bit Parameters
parameter PERIOD  = 10;


// clk and rst
reg  clk     = 0;
reg  rst     = 1;

// crc32_8bit Inputs
reg          data_valid    = 0 ;
reg   [7:0]  data_in       = 0 ;

// crc32_8bit Outputs
wire  [31:0]  crc_out                      ;

wire [7:0]data_in_r;


// assign data_in_r = {data_in[0],data_in[1],data_in[2],data_in[3],data_in[4],data_in[5],data_in[6],data_in[7]};
initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD * 60) rst  =  0;
end

crc32_8bit  u_crc32_8bit (
    .clk                     ( clk                ),
    .rst                     ( rst                ),
    .data_valid              ( data_valid         ),
    .data_in                 ( data_in   [7:0]  ),

    .crc_out                 ( crc_out     [31:0] )
);



integer  i =0;
task send_data ;
begin
    data_valid = 0;
    data_in    = i[7:0];    

    @(posedge clk);
    for (i = 0; i < 1952*1080/2; i = i+1) begin
        data_valid = 1;
        data_in    = 'd3;
        #0.1;
        @(posedge clk);
    end
    data_valid = 0;
    data_in    = 0;    
    @(posedge clk);

end
endtask


initial begin
    @(negedge rst);
    #100;
    @(posedge clk);


    send_data();

    #1000;
    
    send_data();
    //wait( == );

    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

    #1000;
    $stop;
end

endmodule