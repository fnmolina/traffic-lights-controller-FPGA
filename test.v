/****************************************************************************************************
*		Testbench: implementacion (sencilla) del sistema de control de transito para simulacion 	*
*																									*
*****************************************************************************************************/

module test();
	
	reg CLK_10k;
	reg [15:0] seconds;
	reg reset;
	reg enable;
	reg finished;	
	
	time_fsm timer(.enable(enable), .reset(reset), .secondsToCount (seconds), .CLK(CLK_10k), .finished(finished)); 	  
	
	reg SNN_test;
	reg STH_test;	//sensores
	reg SNS_test;	
	wire NN_red; 
	wire NN_yellow;	//semaforo Norton al Norte
	wire NN_green; 
	wire NS_red; 
	wire NS_yellow;	//semaforo Norton al Sur
	wire NS_green; 
	wire TH_red; 
	wire TH_yellow;	//semaforo Thevenin
	wire TH_green; 
	
	wire GNNL_red;
	wire GNNL_green; //semaforo giro izquierda Norton al Norte 
	wire GNNR_red; 
	wire GNNR_green; //semaforo giro derecha Norton al Norte
	wire GTH_red; 
	wire GTH_green; //semaforo giro Thevenin
	wire PTH1_red; 
	wire PTH1_green; //semaforo peatonal Thevenin Este1 y Oeste1
	wire PTH2_red; 
	wire PTH2_green; //semaforo peatonal Thevenin Este2 y Oeste2
	wire PN_red; 
	wire PN_green; //semaforo peatonal Norton
	
	wire [1:0] lightTH;	 //Senal estado semaforo output-fsm/input-semaforo Thevenin
	wire [1:0] lightNN;
	wire [1:0] lightNS;
	wire [1:0] lightGTH; //Senal estado semaforo output-fsm/input-semaforo giro Thevenin
	wire [1:0] lightGNN_R; 
	wire [1:0] lightGNN_L;
	wire [1:0] lightPN;	//Senal estado semaforo output-fsm/input-semaforo peatonal Norton
	wire [1:0] lightPTH1;
	wire [1:0] lightPTH2;
	
	fsm fsmGeneral(.enable(enable),
		.clk(CLK_10k),
		.SNN(SNN_test), 
	    .SNS(SNS_test),
	    .STH(STH_test),
	    .Semaforo_NN(lightNN), 
	    .Semaforo_NS(lightNS),
	    .Semaforo_TH(lightTH),
	    .Giro_NN_izq(lightGNN_L),
	    .Giro_NN_der(lightGNN_R),
	    .Giro_TH_izq(lightGTH),
		.Semaforo_peaton_N(lightPN),
		.Semaforo_peaton_TH1(lightPTH1),
		.Semaforo_peaton_TH2(lightPTH2),
		.secondsToCount(seconds), 
		.reset(reset),
		.finished(finished));	
		
	semaforo semaforo_thevenin(.light(lightTH), .clk(CLK_10k), .green(TH_green), .yellow(TH_yellow), .red(TH_red)); //thevenin
	semaforo semaforo_nortonN(.light(lightNN), .clk(CLK_10k), .green(NN_green), .yellow(NN_yellow), .red(NN_red)); //norton norte 
	semaforo semaforo_nortonS(.light(lightNS), .clk(CLK_10k), .green(NS_green), .yellow(NS_yellow), .red(NS_red)); //norton sur
	
	semaforo2 giro_thevenin(.light(lightGTH), .clk(CLK_10k), .green(GTH_green), .red(GTH_red)); //G TH
	semaforo2 giro_NN_L(.light(lightGNN_L), .clk(CLK_10k), .green(GNNL_green), .red(GNNL_red)); //G NN L
	semaforo2 giro_NN_R(.light(lightGNN_R), .clk(CLK_10k), .green(GNNR_green), .red(GNNR_red)); //G NN R	
	
	semaforo2 Semaforo_peaton_N(.light(lightPN), .clk(CLK_10k), .red(PN_red), .green(PN_green)); //P NN
	semaforo2 Semaforo_peaton_TH1(.light(lightPTH1), .clk(CLK_10k), .red(PTH1_red), .green(PTH1_green)); //P TH1 
	semaforo2 Semaforo_peaton_TH2(.light(lightPTH2), .clk(CLK_10k), .red(PTH2_red), .green(PTH2_green)); //P TH2
	
	
	
/*****************************************************************************************
*										Simulacion 									     *
******************************************************************************************/	


	initial //Simulacion clock 10kHz
	begin	  
		CLK_10k = 0;
		forever #100000ns CLK_10k = ~CLK_10k;
	end											 


	initial begin
		
		enable = 1;
		reset = 1;
		#1ms		 //1ms simula pulsador
		reset = 0;
		
		STH_test =1;
		SNN_test =0;
		SNS_test =0; 
		#100s	  
		
		STH_test =0;
		SNN_test =1;
		SNS_test =0;
		#100s 	
		
		enable = 0;
		#1s
		reset = 1; 
		#1ms
		reset = 0;
		
		STH_test =1;
		SNN_test =1;
		SNS_test =1;
		#100s 	
		
		$finish;
	end
	
endmodule				