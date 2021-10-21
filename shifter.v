module shifter(a, out, done, clk);
    input [23 : 0] a;
    input clk;
    output out;
    output done;
    integer nums = 23;

    reg out;
    reg done;
    always@(negedge clk) begin
        if(nums >= 0) begin
            out = a[nums];
            nums = nums - 1;
            done = 0;
        end       
        else begin
            out = 0;
            done = 1;
        end
    end
endmodule

// module testbench1();
//     reg[23 : 0] a;
//     reg clk;
//     wire out;

//     shifter shf(a, out, clk);
//     integer i;
//     initial begin
//         //$monitor($time, " a = %24b, out = %b", a, out);
//         #1 a = 24'b00101010111110001111111;

//         for(i = 0; i < 30; i = i + 1) begin
//             #1clk = 1;
//             #1clk = 0;
//             $display("a = %24b, out = %b", a, out);
//         end
//     end
// endmodule