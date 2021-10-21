module mdiv(a, b, enable, clk, mantissa, exponent, done); 
// a is 24 bit integer number
// b is 24 bit integer number
// mantissa is 26

    input [23 : 0] a, b;
    output [23 : 0] mantissa;
    input clk;
    input enable;
    output [8 : 0] exponent;
    output done;

    integer i;
    integer ilen = 0;
    reg started = 0;
    reg[24 : 0] accum = 0;
    reg[25 : 0] answer = 0;

    integer bits = 0;
    assign mantissa = answer;
    reg exponent;
    reg done = 0;
    integer k;
    integer digit = 0;
    integer dot;
    integer first;
    integer lmno = 0;

    always@(posedge enable) begin
        k = 1;
        answer = 0;
        accum = a[23 : 1];
        ilen = 0;
        started = 0;
        digit = 0;
        done = 0;
    end
    
    always @(negedge enable) begin
        done = 0;
    end
    always @(posedge clk) begin
        if(enable && ~done) begin
                //$display("Hello");
            // while(ilen <= 23) begin

                // if(24 - k < 0) 
                //     $display(" Dot = %d", k);
                accum = 2 * accum;
                //$display("a = %24b, b = %24b, accum = %25b", a, b, accum);

                if(accum >= b) begin
                    // $display("Subtracted !!! new accum = %25b", accum);
                    accum = accum - b;
                    answer = 2 * answer + 1;
                    if(!started) begin
                        first = k;
                        // $display("First %d", k);
                        started = 1;
                    end
                end

                else begin
                    answer = 2 * answer;
                end

                if(started) begin
                    ilen = ilen + 1;
                end

                k = k + 1;
            // end
                if(ilen > 23) begin
                    done = 1;
                    exponent = 1 - first;
                    lmno = 1 - first;
                end

        // $display(" EXP +  + ++ + + %d", lmno);
        end
    end
endmodule

// module test();
//     reg [23 : 0] a, b;
//     wire [23 : 0] mantissa;
//     wire[8 : 0] exponent;
//     reg clk;
//     wire done;
//     reg enable;

//     mdiv_norm md(a, b, enable, clk, mantissa, exponent, done);
//     integer i = 0;
//     initial begin
//         $monitor($time, " a = %23b, b = %23b, mantissa = %24b, exponent = %6b ", a, b, mantissa, exponent);
//         #1 a = 24'b110010101010101010101010; b = 24'b100010101000010010000111; enable = 1;
//         while(~done) begin
//             #1 clk = 0;
//             #1 clk = 1;
//             //$display("%24b ", mantissa);
//             i = i + 1;
//         end
//         enable = 0;

//         $display("number of cycles = %d", i);
//         i = 0;
//         #1 a = 24'b101111000000000000000000; b = 24'b101000000000000000000000; enable = 1; 
//         while(~done) begin
//             #1 clk = 0;
//             #1 clk = 1;
//             // $display("%24b ", mantissa);
//             i = i + 1;
//         end
//         enable = 0;

//         $display("number of cycles = %d", i);
//         i = 0;

//         #1 a = 24'b000010101000101000010010; b = 24'b001010101010101001110101; enable = 1;
//         while(~done) begin
//             #1 clk = 0;
//             #1 clk = 1;
//             // $display("%24b ", mantissa);
//             i = i + 1;
//         end
//         enable = 0;

//         $display("number of cycles = %d", i);
//         i = 0;

//         //test cases
//     end
// endmodule