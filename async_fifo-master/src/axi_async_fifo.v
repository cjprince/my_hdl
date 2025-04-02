// ---------------------------------------------------------------------------------------------------------------
//  Copyright(c) 2023-2025 ALL rights reserved                                                         
// ---------------------------------------------------------------------------------------------------------------
//  File     : axi_async_fifo.v                                                                                       
//  
//  Author   : CJLee
//  
//  Create   : 2025-04-02 13:12:09
//                                                                                                                
//  Function :     
// 
// 
// 
// 
// ---------------------------------------------------------------------------------------------------------------
 module axi_async_fifo 

    #(
        parameter DSIZE = 8     ,
        parameter ASIZE = 10    ,      //deep : 2^ASIZE
        parameter FALLTHROUGH = "TRUE" // First word fall-through without latency
    )(
    
    //write
    input  wire             aw_clk    ,
    input  wire             aw_rst    ,
    input  wire             i_aw_vld  ,
    input  wire [DSIZE-1:0] i_aw_data ,
    output wire             o_aw_rdy  ,

    //read
    input  wire             ar_clk    ,
    input  wire             ar_rst    ,
    input  wire             i_ar_rdy  ,
    output wire             o_ar_vld  ,
    output wire [DSIZE-1:0] o_ar_data   

 );

    //fifo
    reg     winc = 1'b0;
    wire    wfull      ;
    wire    awfull     ;

    reg     rinc = 1'b0;
    wire    rempty     ;
    wire    arempty    ;

    async_fifo #(
        .DSIZE       ( DSIZE       ),
        .ASIZE       ( ASIZE       ),
        .FALLTHROUGH ( FALLTHROUGH ))
     u_async_fifo (
        .wclk       ( aw_clk               ),
        .wrst_n     ( (~aw_rst)            ),
        .winc       ( winc                 ),
        .wdata      ( i_aw_data [DSIZE-1:0]),
        .wfull      ( wfull                ),
        .awfull     ( awfull               ),

        .rclk       ( ar_clk               ),
        .rrst_n     ( (~ar_rst)            ),
        .rinc       ( rinc                 ),
        .rdata      ( o_ar_data [DSIZE-1:0]),
        .rempty     ( rempty               ),
        .arempty    ( arempty              )
    );


//---------------------------------------------------------------------------//
reg winc_r  = 1'b0;
always @(posedge aw_clk) begin
    if((awfull==1'b0)&&(wfull==1'b0)&&(i_aw_vld==1'b1))begin
        winc_r <= 1'b1;
    end
    else begin
        winc_r <= 1'b0;
    end
end

always @( *) begin
    if((winc_r==1'b1)&&(i_aw_vld==1'b1))begin
        winc <= 1'b1;
    end
    else begin
        winc <= 1'b0;        
    end
end
assign o_aw_rdy = winc;


//---------------------------------------------------------------------------//
reg ar_vld_r    = 1'b0;
reg asfifo_end  = 1'b0;

always @(posedge aw_clk) begin
    if(ar_rst == 1'b1)begin
        asfifo_end <= 1'b0;
    end
    else if((asfifo_end==1'b1)&&((rempty==1'b1)||(rinc==1'b1)))begin
        asfifo_end <= 1'b0;
    end
    else if((rempty==1'b0)&&(arempty==1'b1)&&(asfifo_end==1'b0))begin
        asfifo_end <= 1'b1;
    end
    else begin
        asfifo_end <= asfifo_end;
    end
end

always @(posedge ar_clk) begin
    if ((rempty==1'b0) && ((arempty==1'b0)||((asfifo_end==1'b1)&&(rinc==1'b0)))) begin
        ar_vld_r <= 1'b1;
    end
    else begin
        ar_vld_r <= 1'b0; 
    end
end

always @(*) begin
    if ((ar_vld_r==1'b1)&&(i_ar_rdy==1'b1)) begin
        rinc <= 1'b1;
    end
    else begin
        rinc <= 1'b0; 
    end
end

assign o_ar_vld = ar_vld_r;

endmodule //axi_async_fifo

