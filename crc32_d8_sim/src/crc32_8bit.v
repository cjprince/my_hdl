module crc32_8bit (
    input         clk,        // 时钟
    input         rst,        // 异步复位（低有效）
    input         data_valid, // 输入数据有效信号
    input  [7:0]  data_in,    // 8-bit 输入数据
    output [31:0] crc_out     // 32-bit CRC 校验结果（取反后）
);

// CRC寄存器和多项式定义
reg [31:0] crc_reg;
localparam POLYNOMIAL = 32'h82608EDB; // 固定多项式

// 复位和更新逻辑
always @(posedge clk ) begin
    if (rst == 1'b1) begin
        crc_reg <= 32'hFFFFFFFF;      // 初始化为全1
    end else if (data_valid) begin
        crc_reg <= next_crc(crc_reg, data_in); // 更新CRC
    end
end

// 组合逻辑：计算下一个CRC状态（处理8位输入）
function [31:0] next_crc;
    input [31:0] crc;
    input [7:0]  data;
    reg [31:0] temp;
    integer i;
    begin
        temp = crc ^ {24'b0, data};   // 输入数据异或到低8位
        for (i = 0; i < 8; i = i + 1) begin
            // LSB-First处理：检查最低位，右移并异或多项式
            if (temp[0]) begin
                temp = {1'b0, temp[31:1]} ^ POLYNOMIAL; // 右移后异或
            end else begin
                temp = {1'b0, temp[31:1]};              // 仅右移
            end
        end
        next_crc = temp;
    end
endfunction

// 输出取反（与C代码的 ~crc 对应）
assign crc_out = ~crc_reg;

endmodule