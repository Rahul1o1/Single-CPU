module regfile(
	 input clk,
	 input [4:0] rs1,
	 input [4:0] rs2,
	 input [4:0] rd,
	 input rwrite,
	 input [2:0] funct3,
	 input [31:0] tmp,
	 input load_inst,
	 input [31:0]drdata,
	 output reg signed [31:0] rv1,
	 output reg signed[31:0] rv2,
	 output [32*32-1:0] registers
	);
	
	 reg signed [31:0] rdata;
	

	integer i;
	//32 registers of size 32-bit
	reg signed [31:0] x[31:0];
	initial begin
	for (i=0; i<32; i=i+1)
	 begin
		x[i]=0;
	 end
	end	
		assign registers = {x[31], x[30], x[29], x[28], x[27], x[26], x[25], x[24], x[23], x[22], x[21], x[20], x[19], x[18], x[17], x[16], x[15], x[14], x[13], x[12], x[11], x[10], x[9], x[8], 	x[7], x[6], x[5], x[4], x[3], x[2], x[1], x[0]};

	parameter LB = 3'b0, LH = 3'b001, LW = 3'b010, LBU = 3'b100, LHU = 3'b101;	
	
	always @(posedge clk)
	
	begin
			x[rd]<=rdata;
			x[0]<=0;
	end
	
	
	always @(*)
	begin
		
		rv1 = x[rs1];
		rv2 = x[rs2];
	
	//Write from dmem if load instruction
	if (load_inst)
		begin
		      rdata=0;
			case(funct3)
	    	 	LB:			//Load Byte
	    	 	begin
	    	 		rdata = drdata[7:0];
	    	 	end
	    	 	LH:			//Load Half word
	    	 		begin	
	    	 			rdata = drdata[15:0];
	    	 		end
	    	 	LW:			//Load Word
    	 		begin
    	 			rdata = drdata; 
    	 		end
	    	 	LBU:			//Load Byte Unsigned
    	 		begin
    	 			rdata = drdata;
    	 			rdata[31:8] = 0;	//Extending it with 0s to make it unsigned
    	 		end
	    	 	LHU:			//Load HalfWord
    	 		begin
    	 			rdata = $unsigned(drdata[15:0]);
    	 		end
    	 		endcase	
		end
	else
		begin
			rdata = tmp;
		end
	end
endmodule
