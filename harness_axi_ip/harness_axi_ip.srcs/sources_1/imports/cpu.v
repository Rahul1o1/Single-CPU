module cpu (
    input clk, 
    input reset,
    output reg [31:0] iaddr,	//Program counter
    input [31:0] idata,		//output of imem
    output [31:0] daddr,	//adress to write/read/
    input [31:0] drdata,	//data read from dmem
    output [31:0] dwdata,	//data to write
    output wire [3:0] dwe,		//data write enable
    output [32*32-1:0] registers
);
    

    wire signed [31:0] tmp;
    wire [31:0] rv1,rv2;
    wire signed [31:0] jmp;
    wire [4:0] rs1,rs2,rd,shamt;
    wire signed [31:0] immediate;
    wire [6:0] opcode,funct7;
    wire [2:0] funct3;
    wire load_inst, rwrite;
    wire [32*32-1:0] rgs;
		


always @(posedge clk)
   begin
   	if(reset)
   	begin
   		iaddr<=0;
   	end
   	else
   	begin
   	//value of jmp is determined by alu for branching, default is 4
   		iaddr<=iaddr+jmp;
   	end
   end 

//Instruction Decode
decoder dc(.clk(clk), .idata(idata), .rs1(rs1), .rs2(rs2), .rd(rd), .opcode(opcode),.funct3(funct3), .funct7(funct7), .shamt(shamt), .immediate(immediate)); 

//Register read
regfile rg(.clk(clk), .rs1(rs1), .rs2(rs2), .rd(rd), .rwrite(rwrite), .load_inst(load_inst), .drdata(drdata), .funct3(funct3), .tmp(tmp), .rv1(rv1), .rv2(rv2),.registers(rgs));  
assign registers = rgs;

//Execute
alu al(.clk(clk), .rv1(rv1), .rv2(rv2), .opcode(opcode), .funct3(funct3), .funct7(funct7), .shamt(shamt), .immediate(immediate), .iaddr(iaddr), .daddr(daddr), .dwdata(dwdata), .dwe(dwe), .tmp(tmp), .jmp(jmp), .rwrite(rwrite), .load_inst(load_inst));

//Write Back
//regfile rgf(.clk(clk), .rs1(rs1), .rs2(rs2), .rd(rd), .rwrite(rwrite), .load_inst(load_inst), .drdata(drdata), .funct3(funct3), .tmp(tmp), .rv1(rv1), .rv2(rv2),.registers(rgs));  

endmodule
