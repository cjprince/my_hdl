//~ `New testbench
`timescale  1ns / 1ps

module tb_async_fifo;

// async_fifo Parameters
parameter PERIOD       = 1.25  ;
parameter PERIODR      = 10    ;
parameter DSIZE        = 32    ;
parameter ASIZE        = 12    ;//2^12
parameter FALLTHROUGH  = "TRUE";

// async_fifo Inputs
reg   wclk                             = 0 ;
reg   rst_n                            = 0 ;
reg   winc                             = 0 ;
wire  [DSIZE-1:0]  wdata                   ;
reg   rclk                             = 0 ;
reg   rinc                             = 0 ;

// async_fifo Outputs
wire  wfull                                ;
wire  awfull                               ;
wire  [DSIZE-1:0]  rdata                   ;
wire  rempty                               ;
wire  arempty                              ;


initial
begin
    forever #(PERIOD/2)  wclk=~wclk;
end

initial
begin
    forever #(PERIODR/2)  rclk=~rclk;
end

initial
begin
    #(PERIOD*20) rst_n  =  1;
end

async_fifo #(
    .DSIZE       ( DSIZE       ),
    .ASIZE       ( ASIZE       ),
    .FALLTHROUGH ( FALLTHROUGH ))
 u_async_fifo (
    .wclk       ( wclk                 ),
    .wrst_n     ( rst_n                ),
    .winc       ( winc                 ),
    .wdata      ( wdata    [DSIZE-1:0] ),
    .wfull      ( wfull                ),
    .awfull     ( awfull               ),
    
    //
    .rclk       ( rclk                 ),
    .rrst_n     ( rst_n                ),
    .rinc       ( rinc                 ),
    .rdata      ( rdata    [DSIZE-1:0] ),
    .rempty     ( rempty               ),
    .arempty    ( arempty              )
);


reg         wd_rst_n = 1'b0;
reg [11:0]  wd_cnt   =  'd0;
reg         rd_flag  = 1'b0;
reg         rd_flag_r= 1'b0;

always @(posedge wclk) begin
    rd_flag_r <= rd_flag;
end

always @(posedge wclk) begin
    // if (wd_rst_n==1'b0|rdata[11:0]==12'HA48) begin
    if (wd_rst_n==1'b0) begin
        wd_cnt <= 12'd0;
        rd_flag <= 1'b0;
    end
    else if (wd_cnt==12'HFFF) begin
        wd_cnt <= wd_cnt;
        rd_flag <= 1'b1;
    end
    else if((awfull==1'b0) && (wfull==1'b0))begin
        wd_cnt <= wd_cnt + 1'b1;
    end
    else begin
        wd_cnt <= wd_cnt;
    end
end

always @(posedge wclk) begin
    if(wd_rst_n == 1'b0)begin
        winc <= 1'b0;
    end
    else if(((awfull==1'b0)&&(wfull==1'b0))&&(wd_cnt<12'HFFF)&&(rd_flag==1'b0))begin
        winc <= 1'b1;
    end
    else begin
        winc <= 1'b0;
    end
end
assign wdata={20'd0,wd_cnt};



reg axi_rdy     = 1'b0;
reg axi_vld     = 1'b0;
reg asfifo_end  = 1'b0;
always @(posedge rclk) begin
    if((rempty==1'b1)&&(asfifo_end==1'b1))begin
        asfifo_end <= 1'b0;
    end
    else if((rempty==1'b0)&&(arempty==1'b1)&&(asfifo_end==1'b0))begin
        asfifo_end <= 1'b1;
    end
    else if((asfifo_end==1'b1)&&(rinc==1'b1))begin
        asfifo_end <= 1'b0;
    end
    else begin
        asfifo_end <= asfifo_end;
    end
end

always @(*) begin
    if ((axi_vld==1'b1)&&(axi_rdy==1'b1)) begin
        rinc <= 1'b1;
    end
    else begin
        rinc <= 1'b0; 
    end
end

always @(posedge rclk) begin
    if ((rempty==1'b0)&&((arempty==1'b0)||((asfifo_end==1'b1)&&(rinc==1'b0)))) begin
        axi_vld <= 1'b1;
    end
    else begin
        axi_vld <= 1'b0; 
    end
end

always @(*) begin
    if (axi_vld==1'b1) begin
        axi_rdy <= 1'b1;
    end
    else begin
        axi_rdy <= 1'b0;
    end
end

initial
begin
    @(posedge rst_n);
    #100;
    @(posedge wclk);
    wd_rst_n = 1'b1;

    // $stop;
end

endmodule