/********************************************************************************************
*	Modulo main: administracion modulos del sistema de control de transito.					*			.  																	*											
*				Entradas: enable y reset.													*
* 				Salidas: senales de semaforos.												* 
********************************************************************************************/


module main
(   
input wire gpio_2, 	//enable
input wire gpio_28, 	//reset 

//sensores 

input wire gpio_3, 		//Sensor TH
input wire gpio_4,		//Sensor NN
input wire gpio_48,		//Sensor NS	 

//semaforos vehiculares	

output wire gpio_26, 	//green STH
output wire gpio_25, 	//yellow STH
output wire gpio_23,  	//red STH   
output wire gpio_35, 	//green SNN
output wire gpio_32, 	//yellow SNN
output wire gpio_27,  	//red SNN  
output wire gpio_34, 	//green SNS
output wire gpio_37, 	//yellow SNS
output wire gpio_31,  	//red SNS  

//semaforos de giro	

output wire gpio_36, 	//green GTH
output wire gpio_43,  	//red GTH  
output wire gpio_38, 	//green GNN Left
output wire gpio_42,  	//red GNN Left       
output wire gpio_44, 	//green GNN Right
output wire gpio_6,		//red GNN Right     

//semaforos peatonales	

output wire gpio_11, 	//green peatonal TH1
output wire gpio_9,  	//red peatonal TH1  
output wire gpio_19, 	//green peatonal TH2
output wire gpio_18,  	//red peatonal TH2       
output wire gpio_21, 	//green peatonal N
output wire gpio_13		//red peatonal N 	
); 

//Clock interno 10kHz
SB_LFOSC OSCInst0(.CLKLFEN(1'b1), .CLKLFPU(1'b1), .CLKLF(CLK_10k)); 	

wire [15:0] seconds;
wire finished;	  

time_fsm timer(.enable(gpio_2), .reset(gpio_28), .secondsToCount (seconds), .CLK(CLK_10k), .finished(finished));  

//variables de actualizacion de semaforos

wire [1:0] lightTH;
wire [1:0] lightNN;
wire [1:0] lightNS;
wire [1:0] lightGTH;
wire [1:0] lightGNN_R;
wire [1:0] lightGNN_L;
wire [1:0] lightPN;
wire [1:0] lightPTH1;
wire [1:0] lightPTH2;

fsm fsmGeneral(.enable(gpio_2),
	.clk(CLK_10k),
	.SNN(gpio_4), 
    .SNS(gpio_48),
    .STH(gpio_3),
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
	.reset(gpio_28),
	.finished(finished));  
	
/*instanciacion semaforos vehiculares*/

semaforo3 semaforo_thevenin(.light(lightTH), .clk(CLK_10k), .green(gpio_26), .yellow(gpio_25), .red(gpio_23)); //thevenin
semaforo3 semaforo_nortonN(.light(lightNN), .clk(CLK_10k), .green(gpio_35), .yellow(gpio_32), .red(gpio_27)); //norton norte 
semaforo3 semaforo_nortonS(.light(lightNS), .clk(CLK_10k), .green(gpio_34), .yellow(gpio_37), .red(gpio_31)); //norton sur 

/*instanciacion semaforos de giro*/
																		   														 
semaforo2 giro_thevenin(.light(lightGTH), .clk(CLK_10k), .green(gpio_36), .red(gpio_43)); //G TH
semaforo2 giro_NN_L(.light(lightGNN_L), .clk(CLK_10k), .green(gpio_38), .red(gpio_42)); //G NN L
semaforo2 giro_NN_R(.light(lightGNN_R), .clk(CLK_10k), .green(gpio_44), .red(gpio_6)); //G NN R		 

/*instanciacion semaforos peatonales*/

semaforo2 Semaforo_peaton_N(.light(lightPN), .clk(CLK_10k), .red(gpio_13), .green(gpio_21)); //G TH
semaforo2 Semaforo_peaton_TH1(.light(lightPTH1), .clk(CLK_10k), .red(gpio_9), .green(gpio_11)); //G NN L
semaforo2 Semaforo_peaton_TH2(.light(lightPTH2), .clk(CLK_10k), .red(gpio_18), .green(gpio_19)); //G NN R

endmodule
