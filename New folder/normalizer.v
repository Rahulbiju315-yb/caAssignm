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

// module testme();
//     reg [23: 0] nMantissa;
//     reg signed [8 : 0] uExp;

//     wire [22 : 0] significand;
//     wire [7 : 0] nExp;
    
//     wire overflow;
//     wire underflow;

//     normalizer norm(nMantissa, uExp, significand, nExp, underflow, overflow);

//     reg boolTest;

    
//     initial begin
//         $monitor("nMantissa = %24b , uExp = %9b (%d) , significand = %23b, nExp = %8b(%d), overflow = %b, underflow = %b", nMantissa, uExp, uExp, significand, nExp,
//         nExp, overflow, underflow);

//         #1 nMantissa = 24'b100011010010100100101000; uExp = 9'b000001111;
//         boolTest = ($signed(uExp) > $signed(9'b110000001) && $signed(uExp) <  $signed(9'b010000000)) ? 1 : 0;
//         $display("boolTEst = %b ", boolTest);
//         #1 nMantissa = 24'b100011010010100100101000; uExp = 9'b110000001;
//         #1 nMantissa = 24'b100011010010100100101000; uExp = 9'b010000000;
//         #1 nMantissa = 24'b100011010010100100101000; uExp = 9'b110000000;


//     end

// endmodule
