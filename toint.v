module toint(a, exp, out);
    input [22 : 0] a;
    input [7 : 0] exp;
    output [23 : 0] out;

    reg [23 : 0] out;
    always@(a or exp) begin
        if(exp == 0) begin
            out[23] = 0;
            out[22 : 0] = a;
        end
        else begin
            out[23] = 1;
            out[22 : 0] = a;
        end
    end
endmodule

// module test();
//     reg [22 : 0] a;
//     reg [7 : 0] exp;

//     wire [23 : 0] out;
//     toint to(a, exp, out);
//     initial begin
//         $monitor(" a = %23b exp = %8b out = %24b ", a, exp, out);

//         #1 a = 23'b00100101001010001110101; exp = 8'b00000000;
//         #1 a = 23'b00100101001010001110101; exp = 8'b00101011;
//     end
// endmodule