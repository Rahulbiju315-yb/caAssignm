module expAdj(expC, expDiff, uExp);
    //adds expC (from mdiv) and expDiff and produces uExp
    input [8 : 0] expC;
    input [8 : 0] expDiff;
     
    output [8 : 0] uExp;
    assign uExp = expC + expDiff;
    
endmodule

module expDiff(expA, expB, eDiff);
// calculates exponent difference for division
    input [7 : 0] expA, expB;
    output [8 : 0] eDiff; // expA - expB may exceed 8 bits (not overflow since exp from mdiv needs to be accounted)

    assign eDiff = expA - expB;
endmodule

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

module normalizer(nMantissa, uExp, done, significand, nExp, underflow, overflow);
    //nManitssa - Normalized mantissa
    //uExp - Unnormalised exp
    //nManitssa - Normalized mantissa
    //nExp - Normalized exponent
    //underflow - underflow has occured (nExp < -127)
    //overflow - overflow has occured (nExp >= 128, i.e result is +- inf or NaN)

    input [23 : 0] nMantissa;
    input [8 : 0] uExp;
    input done;
    output [22 : 0] significand;
    output [7 : 0] nExp;
    output underflow, overflow;
    reg underflow_reg,overflow_reg;
    reg [22 : 0] significand_reg;
    reg [7 : 0] nExp_reg;

    always @(posedge done) begin 
        if($signed(uExp) > $signed(9'b110000001) && $signed(uExp) < $signed(9'b010000000)) begin // normal 
           // assign significand = nMantissa[22 : 0]; 
            //assign nExp = uExp + 127;

            //assign overflow = 0;
            //assign underflow = 0;
            significand_reg = nMantissa[22 : 0]; 
            nExp_reg = uExp + 9'b001111111;
            $display("A!! nExp = %8b, UEXP = %9b", nExp, uExp);
            overflow_reg = 0;
            underflow_reg = 0;
            
        end
        else if($signed(uExp) == $signed(9'b110000001)) begin // denormalised
            significand_reg[21 : 0] = nMantissa[22 : 1];
            significand_reg[22] = 1;
            nExp_reg = 8'b00000000;

            overflow_reg = 0;
            underflow_reg = 0;
        end
        else if($signed(uExp) >= $signed(9'b010000000)) begin // overflow
            significand_reg = 0;
            nExp_reg = 8'b11111111;

            overflow_reg = 1;
            underflow_reg = 0;
        end
        else begin // underflow
            significand_reg = 0;
            nExp_reg = 0;

            overflow_reg = 0;
            underflow_reg = 1;
        end
    end
    assign significand = significand_reg;
    assign nExp = nExp_reg;
    assign overflow = overflow_reg;
    assign underflow = underflow_reg;
endmodule

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

module fpdiv(AbyB,DONE,EXCEPTION,InputA,InputB,CLOCK,RESET); 
    input CLOCK,RESET ; // Active High Synchronous Reset 
    input [31:0] InputA,InputB; 
    output [31:0]AbyB;  
    output DONE ; // ‘0’ while calculating, ‘1’ when the result is ready 
    output [1:0]EXCEPTION; // Used to output exceptions 

    reg [31 : 0] AbyB;
    reg DONE;
    reg [1 : 0] EXCEPTION;

    wire sign;
    assign sign = InputA[31] ^ InputB[31];

    // Parse Inputs into significand, exponent and sign
    wire[22 : 0] significandA;
    assign significandA = InputA[22 : 0];

    wire[7 : 0] expA;
    assign expA = InputA[30 : 23];

    wire[22 : 0] significandB;
    assign significandB = InputB[22 : 0];

    wire[7 : 0] expB;
    assign expB = InputB[30 : 23];

    // Calculates exp of A - exp of B
    wire[8 : 0] expDiff;
    expDiff ediff(expA, expB, expDiff);
    
    // Converts the mantissa to integral form for division [ 1.m1 / 1.m2 = 1m1 / 1m2 ] 
    wire[23 : 0] intA;
    toint atoint(significandA, expA, intA);

    wire[23 : 0] intB;
    toint btoint(significandB, expB, intB);

    // Calculates intA / intB in the form of intC, expC which represents a number 1.m3 * 2^(expC)
    reg enable = 0;
    wire divDone;

    wire [23 : 0] mantissa;
    wire [8 : 0] exponent;
    mdiv intDiv(intA, intB, enable, CLOCK, mantissa, exponent, divDone);

    // Adds expC to expDiff
    wire[8 : 0] uExp;
    expAdj adjuster(exponent, expDiff, uExp);
    
    // Normailizes result if required and produces necessary signals (underflow / overflow)
    wire[22 : 0] ansSignificand;
    wire[7 : 0] nExp;
    wire underflow, overflow;

    normalizer norm(mantissa, uExp, divDone, ansSignificand, nExp, underflow, overflow);

    //Special Case signals
    wire isZeroA, isZeroB;
    assign isZeroA = (InputA[30 : 0] == 0);
    assign isZeroB = (InputB[30 : 0] == 0);

    wire isInfA, isInfB;
    assign isInfA = (InputA[30 : 23] == 8'b11111111 && InputA[22 : 0] == 0);
    assign isInfB = (InputB[30 : 23] == 8'b11111111 && InputB[22 : 0] == 0);
    
    wire isNaNA, isNaNB;
    assign isNaNA = (InputA[30 : 23] == 8'b11111111 && InputA[22 : 0] != 0);
    assign isNaNB = (InputB[30 : 23] == 8'b11111111 && InputB[22 : 0] != 0);

    wire zeroByZero;
    assign zeroByZero = isZeroA && isZeroB;

    wire infByInf;
    assign infByInf = isInfA && isInfB;

    wire xByZero;
    assign xByZero = !isZeroA && isZeroB;

    wire zeroByX;
    assign zeroByX = isZeroA && !isZeroB;

    wire isNaN = zeroByZero | infByInf | isNaNA | isNaNB;

    // RESET starts the calculation on a positive edge.
    always @(posedge RESET) begin
        //Special Cases ...
        // 0 / 0 => NaN
        // Inf / Inf => NaN
        // X / 0 => +- Inf
        // 0 / X => 0
        // NaN / X or X / NaN => NaN
        if(isNaN) begin
            AbyB = 32'b01111111111111111111111111111111;
            EXCEPTION = 2'b11;
            DONE = 1;
        end
        else if(xByZero) begin
            AbyB = 32'b01111111100000000000000000000000;
            EXCEPTION = 2'b00;
            DONE = 1;
        end
        else if(zeroByX) begin
            AbyB = 32'b00000000000000000000000000000000;
            DONE = 1;
        end
        else begin
            DONE = 1;
            enable = 1;
        end
    end

    // When divDone signal is asserted, disable the mdiv module
    always @(posedge divDone) begin
        #10
        AbyB[31] = sign;
        AbyB[30 : 23] = nExp[7 : 0];
        AbyB[22 : 0] = ansSignificand[22 : 0];
        enable = 0;
        $display("intA = %24b, intB = %24b,mantissa from mdiv = %23b, exp from mdiv = %0b, expDifference = %9b, uExp = %9b, nExp = %8b, AbyB = %32b", 
        intA, intB, mantissa, exponent, expDiff, uExp, nExp, AbyB);
        if(underflow) begin
            EXCEPTION = 2'b01;
        end
        else if(overflow) begin
            EXCEPTION = 2'b10;
        end
        DONE = 1;
    end
    
    

endmodule

module testbench1();
    reg signed [31 : 0] InputA, InputB;
    reg CLOCK = 0;
    reg RESET;
    
    wire [31 : 0] AbyB;
    wire [1 : 0] EXCEPTION;
    wire DONE;

    fpdiv div(AbyB, DONE, EXCEPTION, InputA, InputB, CLOCK, RESET);
    initial begin
        forever begin
            #10 CLOCK = !CLOCK;
        end
    end

    initial begin
        $monitor("A = %32b, B = %32b, AbyB = %32b, exception = %2b", InputA, InputB, AbyB, EXCEPTION);

        #6 InputA = 32'b00111111101111000000000000000000; InputB = 32'b00111111101000000000000000000000;
        #1 RESET = 0;
        #1 RESET = 1;

        #1000 $finish();
    end
endmodule