module expDiff(expA, expB, eDiff);
// calculates exponent difference for division
    input [7 : 0] expA, expB;
    output [8 : 0] eDiff; // expA - expB may exceed 8 bits (not overflow since exp from mdiv needs to be accounted)

    assign eDiff = expA - expB;
endmodule