module alu(
    input clk, 
    input signed [31:0] rv1,
    input signed [31:0] rv2,
    input [6:0] opcode,		
    input [2:0] funct3,
    input [6:0] funct7,
    input signed [31:0] immediate,
    input [4:0] shamt,
    input [31:0] iaddr,
    output reg signed [31:0] daddr,
    output reg signed [31:0] dwdata,	
    output reg [3:0] dwe,	
    output reg signed [31:0] jmp,
    output reg signed [31:0] tmp,
    output reg rwrite,
    output reg load_inst
);


 parameter ALR =7'b0110011, ALI = 7'b0010011, LOAD = 7'b11, STORE=7'b0100011, LUI = 7'b0110111, AUIPC = 7'b0010111, BC =  7'b1100011, JAL = 7'b1101111, JALR = 7'b1100111,
    			ADD_SUB = 3'b000, SLL = 3'b001, SLT = 3'b010, SLTU = 3'b011, XOR = 3'b100, SRL_A  = 3'b101 , OR = 3'b110 , AND = 3'b111, 
      			  ADDI = 3'b0, SLTI = 3'b010, SLTIU = 3'b011, XORI = 3'b100, ORI =3'b110, ANDI = 3'b111, SLLI = 3'b001,SRLI_A = 3'b101,
      			  LB = 3'b0, LH = 3'b001, LW = 3'b010, LBU = 3'b100, LHU = 3'b101, 
      			  SB = 3'b000, SH =3'b001, SW = 3'b010,
      			  BEQ =3'b000, BNE=3'b001, BLT =3'b100, BGE =3'b101,BLTU =3'b110, BGEU =3'b111;
      			  
 always @(*)
    begin
   
    	jmp=32'b100;		//default increment pc by 4	
    	tmp=0;
    	daddr=0;
    	dwdata=0;
    	dwe=0;
    	load_inst=0;
    	rwrite=0;
    	case(opcode)
    		ALR:
    		begin
    		rwrite=1;
    			case(funct3)
    				ADD_SUB:
    				begin
    					if(funct7==7'b0)	//ADD instruction
    					begin
    						tmp = rv1 + rv2;
    						
    					end
    					else			//SUB instruction
    					begin
    						tmp = rv1 - rv2;
    					end
    				end
    				
    				SLL:
    				begin		//SLL (shift left logical) instruction
    					tmp = rv1 << rv2;
    				end
    				SLT:			//SLT (set less than) instruction
    				begin
    					tmp = (rv1<rv2)? 1:0;
    				end
 				SLTU:			//SLTU (set less than unsigned) instruction
    				begin
					tmp = ($unsigned(rv1)<$unsigned(rv2))?1:0;
    				end
    				XOR:			//XOR instruction
    				begin
    					tmp = rv1^rv2;
    				end
    				SRL_A:
    				begin
    					if(funct7 == 7'b0)		//logicl shift right
    					begin
    						tmp = rv1 >> rv2;
    					end
    					else 				//arithmetic shift rihgt
    					begin
    						tmp = rv1 >>> rv2;
    					end
    				end	
    				OR:
    				begin
    					tmp = rv1 | rv2;
    				end
    				AND:
    				begin
    					tmp = rv1 & rv2;
    				end
    			endcase
   	 	end
   	 ALI:				//I-Type Arithmetic and Logical instructions
   	 begin
   	 rwrite=1;
    	 case(funct3)
   		SRLI_A:
   		begin
   	 		if(funct7 == 7'b0)	//SRLI
   			begin 
   	 			tmp = rv1 >> shamt;			
   	 		end	
   	 		else 			//SRAI
   	 		begin
	 			tmp = rv1 >>> shamt;
   			end
   	 	end
   	 	SLLI:
   	 	begin
   	 		tmp = rv1 << shamt;
   	 	end
   	 	ADDI:
   	 	begin
   	 		tmp = rv1 + immediate;
   	 	end
   	 	SLTI:
   	 	begin
   	 		tmp = (rv1<immediate[11:0])? 1 : 0;
   	 	end
   	 	SLTIU:
   	 	begin
   	 		tmp = (rv1<$unsigned(immediate[11:0]))? 1 : 0; 	 		
   	 	end
   	 	XORI:
   	 	begin
   	 		tmp = rv1^immediate[11:0];
   	 	end
   	 	ORI:
   	 	begin
   	 		tmp = rv1 | immediate[11:0];
   	 	end
   	 	ANDI:
   	 	begin
   	 		tmp = rv1 & immediate[11:0];
   	 	end
   	 endcase	
   	 end	 
   	 LOAD:
   	 begin
   	 rwrite=1;
   	 load_inst=1;
   	 	case(funct3)
    	 	LB:			//Load Byte
    	 	begin
    	 		daddr = rv1 + $signed(immediate[11:0]);
    	 	end
    	 	LH:			//Load Half word
    	 	begin	
    	 		daddr = rv1 + $signed(immediate[11:0]);
    	 	end
    	 	LW:			//Load Word
    	 	begin
    	 		daddr = rv1+$signed(immediate[11:0]);
    	 	end
    	 	LBU:			//Load Byte Unsigned
    	 	begin
    	 		daddr = rv1+$signed(immediate[11:0]);
    	 		end
    	 	LHU:			//Load HalfWord
    	 	begin
    	 		daddr = rv1+$signed(immediate[11:0]);
    	 	end
    	 	endcase	
   	 end	
   	 STORE:
   	 begin
   	 rwrite=0;
   	 	case(funct3)
   	 	SB:				//Selecting Byte
   	 	begin
   	 		daddr = rv1 + $signed(immediate[11:0]);
   	 		if(daddr[1:0]==2'b0)
	   	 		dwe=4'b0001;
   	 		else if(daddr[1:0]==2'b01)
	   	 		dwe=4'b0010;
	   	 	else if(daddr[2:0]==2'b10)
	   	 		dwe=4'b0100;
	   	 	else dwe=4'b1000;
   	 		dwdata = {24'b0,rv2[7:0]};
   	 	end
   	 	SH:				//Selecting HalfWord
   	 	begin
   	 	 	daddr = rv1 + $signed(immediate[11:0]);
   	 		if(daddr[1:0]==2'b0)
   	 		dwe=4'b0011;
   	 		else
   	 		dwe=4'b1100;
   	 		dwdata = rv2[15:0];
   	 	end
   	 	SW:				//Selecting Word
   	 	begin
   	 		dwe=4'b1111;
   	 		daddr = rv1 + $signed(immediate[11:0]);
   	 		dwdata = rv2[31:0];

   	 	end
		endcase   	 
   	 end
   	 LUI:			//load upper immediate
   	 begin
   	 	tmp = {immediate[31:12],12'b0};	//Stored in upper 20bits, rest 0s
   	 end
   	 AUIPC:				//add upper immediate to pc
   	 begin
   	 	tmp = iaddr + {immediate[31:12],12'b0};   	 		 
   	 end
   	 BC:
   	 begin
   	 	rwrite=0;
    	 	case(funct3)
    	 	BEQ:			//Break if EQual
    	 	begin
    	 		if(rv1 == rv2)
    	 		jmp = immediate;
    	 		else
    	 		jmp = 32'b100;
    	 	end 
    	 	BNE:			//Break if Not Equal
    	 	begin
    	 		if(rv1 != rv2)
    	 		jmp = immediate;
    	 		else
    	 		jmp = 32'b100;
    	 	end 
    	 	BLT:			//Break if Less Than
    	 	begin
    	 		if(rv1 < rv2)
    	 		jmp = immediate;
    	 		else
    	 		jmp = 32'b100;
    	 	
    	 	end 
    	 	BGE:			//Break if Greater or Equal
    	 	begin
    	 		if(rv1 >= rv2)
    	 		jmp = immediate;
    	 		else
    	 		jmp = 32'b100;
    	 	end 
    	 	BLTU:			//Break if Less Than Unsigned
    	 	begin
    	 		if($unsigned(rv1) < $unsigned(rv2))
    	 		jmp = immediate;
    	 		else
    	 		jmp = 32'b100;
    	 	end 
    	 	BGEU:			//Break if Greater Or Equal Unsigned
    	 	begin
    	 		if($unsigned(rv1) >= $unsigned(rv2))
    	 		jmp = immediate;
    	 		else
    	 		jmp = 32'b100;
    	 	end 
    	 	endcase
   	 end
   	 JAL:				//jump and link
   	 begin
   	 	rwrite=1;
   	 	tmp = iaddr + 32'b100;	//return address stored in rd
   	 	jmp = immediate;
   	 end
   	 JALR:				//jump and link register
   	 begin
   	 	rwrite=1;
   	 	tmp = iaddr + 32'b100;	//return address stored in rd
   	 	jmp = rv1 + immediate -iaddr;	//pc = pc + (x1 +immediate - pc) same as pc = x1 + immediate
   	 	jmp[0]=0;
   	 	
   	 end
   	 default:	//If invalid instruction given only makes x0 = 0
   	 begin
		daddr=0;
    	 	tmp=0;
    	 	jmp=32'b100;
    	 	dwdata = 0;
    	 	dwe = 0;
    	 	rwrite =0;
   	 end 	
    	endcase
    end
endmodule
