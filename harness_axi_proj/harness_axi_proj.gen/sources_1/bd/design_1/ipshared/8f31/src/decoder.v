module decoder(input clk,
		input [31:0] idata,
	 output reg [4:0] rs1,
	 output reg [4:0] rs2,
	 output reg [4:0] rd,
	 output reg [4:0] shamt,
	 output reg signed [31:0] immediate,
	 output reg [6:0] opcode,		
    	 output reg [2:0] funct3,
    	 output reg [6:0] funct7
);


parameter ALR =7'b0110011, ALI = 7'b0010011, LOAD = 7'b11, STORE=7'b0100011, LUI = 7'b0110111, AUIPC = 7'b0010111, BC =  7'b1100011, JAL = 7'b1101111, JALR = 7'b1100111;
    			
always @(*)
begin
	immediate = 0;
	funct7 = 0;
	rs1 = 0;
	rs2 = 0;
	rd = 0;
	funct3 = 0;
	opcode = idata[6:0];
	shamt = 0;

	case(opcode)
	ALR:				//R-Type Arithmetic and Logical instructions
    	begin
    		rd = idata[11:7];
    		funct3 = idata[14:12];
    		rs1 = idata[19:15];
    		rs2 = idata[24:20];
    		funct7 = idata[31:25];
	 end    	
   	 ALI:				//I-Type Arithmetic and Logical instructions
   	 begin
   		rd = idata[11:7];
    	 	funct3 = idata[14:12];
    	 	rs1 = idata[19:15];
    	 	shamt = idata[24:20];				//shift amount 
    	 	funct7 = idata[31:25];
    		immediate = {{20{idata[31]}},idata[31:20]}; 	//sign extending immediate value
   	 end	 
   	 LOAD:
   	 begin
   	 	immediate = {{20{idata[31]}},idata[31:20]};
   	 	rd = idata[11:7];
    		funct3 = idata[14:12];
    	 	rs1 = idata[19:15];
   	 end	
   	 STORE:
   	 begin
   		immediate = {{20{idata[31]}},idata[31:25],idata[11:7]};
    		funct3 = idata[14:12];
    	 	rs1 = idata[19:15];
    	 	rs2 = idata[24:20];
   	 end
   	 LUI:			//load upper immediate
   	 begin
   	 	immediate = {idata[31:12],12'b0};
   	 	rd=idata[11:7];
   	 end
   	 AUIPC:				//add upper immediate to pc
   	 begin
  		immediate = {idata[31:12],12'b0};
   	 	rd=idata[11:7];	 		 
   	 end
   	 BC:
   	 begin
   	 	immediate = {{20{idata[31]}},idata[7],idata[30:25],idata[11:8],1'b0};
   	 	funct3 = idata[14:12];
    	 	rs1 = idata[19:15];
    		rs2 = idata[24:20];
   	 end
   	 JAL:				//jump and link
   	 begin
   	 	immediate = {{13{idata[31]}},idata[19:12],idata[20],idata[30:21],1'b0};
		rd = idata[11:7];
   	 end
   	 JALR:				//jump and link register
   	 begin
   	 	immediate = {{20{idata[31]}},idata[31:20]}; 
   	 	funct3 = idata[14:12];
   	 	rs1 = idata[19:15];
   	 	rd = idata[11:7];
   	 end
   	 default:	//If invalid instruction given only makes x0 = 0
   	 begin
   	 	rd = 0;
    	 	funct3 = 0;
    	 	rs1 = 0;
    	 	rs2 = 0;
    	 	shamt = 0;
    	 	funct7 = 0;
    	 	immediate=0;
   	 end 	
    	endcase
end
endmodule
