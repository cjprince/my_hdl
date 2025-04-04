//~ `New testbench
`timescale  1ns / 1ps    

module tb_axi_async_fifo;

// axi_async_fifo Parameters
parameter PERIODW       = 8.0   ;
parameter PERIODR       = 6.66  ;
parameter DSIZE         = 16    ;
parameter ASIZE         = 12    ;
parameter FALLTHROUGH   = "TRUE";

reg   rst                                  = 1 ;

// axi_async_fifo Inputs
reg   aw_clk                           = 0 ;
reg   i_aw_vld                         = 0 ;
reg   [DSIZE-1:0]  i_aw_data           = 0 ;
reg   ar_clk                           = 0 ;
reg   i_ar_rdy                         = 0 ;

// axi_async_fifo Outputs
wire  o_aw_rdy                             ;
wire  o_ar_vld                             ;
wire  [DSIZE-1:0]  o_ar_data               ;

initial begin
    forever #(PERIODW/2)  aw_clk=~aw_clk;
end

initial begin
    forever #(PERIODR/2)  ar_clk=~ar_clk;
end

initial begin
    #(PERIODW*200) rst  =  0;
end


axi_async_fifo #(
    .DSIZE       ( DSIZE       ),
    .ASIZE       ( ASIZE       ),
    .FALLTHROUGH ( FALLTHROUGH ))
 u_axi_async_fifo (
    .aw_clk       ( aw_clk                 ),
    .aw_rst       ( rst                    ),
    .i_aw_vld     ( i_aw_vld               ),
    .i_aw_data    ( i_aw_data  [DSIZE-1:0] ),
    .o_aw_rdy     ( o_aw_rdy               ),

    .ar_clk       ( ar_clk                 ),
    .ar_rst       ( rst                    ),
    .i_ar_rdy     ( i_ar_rdy               ),
    .o_ar_vld     ( o_ar_vld               ),
    .o_ar_data    ( o_ar_data  [DSIZE-1:0] )
);

reg     [15:0]  w_data_cnt = 'd0;

always @(posedge aw_clk) begin
    if(rst == 1'b1)begin
        w_data_cnt <= 'd0;
    end
    else if((i_aw_vld == 1'b1)&&(o_aw_rdy==1'b1)&&(w_data_cnt =='d4096-1))begin
        w_data_cnt <= w_data_cnt;
    end
    else if((i_aw_vld == 1'b1)&&(o_aw_rdy==1'b1))begin
        w_data_cnt <= w_data_cnt + 1'b1;
    end
    else begin
        w_data_cnt <= w_data_cnt;
    end
end

always @(posedge aw_clk) begin
    if(rst == 1'b1)begin
        i_aw_vld <= 1'b0;
    end
    else if(w_data_cnt =='d4096-1)begin
        i_aw_vld <= 1'b0;
    end
    else begin
        i_aw_vld <= 1'b1;
    end
end

always @(*) begin
    i_aw_data <= w_data_cnt;
end

//read
reg [15:0]  recv_cnt = 16'd0;
always @(posedge ar_clk) begin
    if(o_ar_vld == 1'b1)begin
        i_ar_rdy <= 1'b1;
    end
    else begin
        i_ar_rdy <= 1'b0;
    end
end

always @(posedge ar_clk) begin
    if(rst == 1'b1)begin
        recv_cnt <= 'd0;
    end
    else if((i_ar_rdy == 1'b1)&&(o_ar_vld == 1'b1))begin
        recv_cnt <= recv_cnt + 1'b1;
    end
    else begin
        recv_cnt <= recv_cnt;
    end
end


initial
begin

    wait(recv_cnt == 'd1024-1);
    #1000;
    #1000;
    
    // $stop;

end

endmodule