module expAdj(expC, expDiff, uExp);
    //adds expC (from mdiv) and expDiff and produces uExp
    input [8 : 0] expC;
    input [8 : 0] expDiff;
     
    output [8 : 0] uExp;
    assign uExp = expC + expDiff;
    
endmodule