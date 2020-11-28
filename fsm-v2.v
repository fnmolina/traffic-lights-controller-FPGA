/********************************************************************************************
*	Modulo fsm: administracion de luces y asignacion de tiempos de semaforo.				*
*				Se activa con enable en uno.  	*											*
*				Entradas: clock10k; senal de finalizacion de contador; sensores de trafico.	*
* 				Salida: Senales de semaforo.												* 
*
*
**********************************************************************************/



module fsm 
  ( input wire reset,  //Reset ==> estado 1 Tabla A
  	input wire enable,	//habilitacion/deshabilitacion de sistema
  	input wire finished,  //Flag de habilitacion/deshabilitacion de clock
    input wire clk, //Clock general 10kHz
    input wire SNN, //Sensor Norton Norte
    input wire SNS,	//Sensor Norton Sur
    input wire STH,	//Sensor Thevenin
    output reg [1:0] Semaforo_NN, //Senal de estado de semaforo calle Norton Norte
    output reg [1:0] Semaforo_NS, //Senal de estado de semaforo	calle Norton Norte
    output reg [1:0] Semaforo_TH, //Senal de estado de semaforo	calle Norton Norte
    output reg [1:0] Giro_NN_izq, //Senal de estado de semaforo	Giro calle Norton izquierda
    output reg [1:0] Giro_NN_der, //Senal de estado de semaforo	Giro calle Norton derecha
    output reg [1:0] Giro_TH_izq, //Senal de estado de semaforo	Giro calle Thevenin izquierda
    output reg [1:0] Semaforo_peaton_N, //Senal de estado de semaforo peatonal Norton
    output reg [1:0] Semaforo_peaton_TH1, //Senal de estado de semaforo peatonal Thevenin 1
    output reg [1:0] Semaforo_peaton_TH2, //Senal de estado de semaforo peatonal Thevenin 1
	output reg [15:0] secondsToCount); //Tiempo de estado

	
	/*Definicion de tablas de tiempos*/

    parameter [2:1] A = 2'b00;
    parameter [2:1] B = 2'b01;
    parameter [2:1] C = 2'b10;
    parameter [2:1] D = 2'b11;	    
	
	/*Definicion de estados de semaforos*/
	parameter RED = 2'b00;
	parameter YELLOW = 2'b01;
	parameter GREEN = 2'b10;
	parameter OFF = 2'b11; 
	
	/*Declaracion de variables internas para tablas y estados*/

   	reg[3:1] tabla;
    reg[7:0] estado; 
	
	/*Ciclo de estados y actualizacion de tiempos: administracion de estados y
								tiempos de semaforos vehiculares y peatonales*/

	always @ (posedge clk)	
		begin	
		if(enable == 0)	 //Sistema deshabilitado ==> semaforos en cero
			begin	
				Semaforo_NN	<= OFF;
				Semaforo_NS <= OFF;
				Semaforo_TH	<= OFF;
				Giro_NN_izq	<= OFF;
				Giro_NN_der <= OFF;
				Giro_TH_izq <= OFF;
				Semaforo_peaton_N <= OFF;
				Semaforo_peaton_TH1 <= OFF;
				Semaforo_peaton_TH2 <= OFF;
			end	
		else	//Sistema habilitado ==> ciclos de estados
			begin
				if(reset == 1) //Reset ==> inicializo en estado 1 tabla A por default 
				begin 	   //dado que es igual para todas las tablas.
					tabla <= A;	
			        estado <= 1;
					secondsToCount <= 17;
				end			
				
				/*Asignacion de los tiempos segun estado de los sensores (acceso a tablas)*/
				
				else if(!SNS & !SNN & STH)			
				begin
					tabla <= B;	
				end
				
				else if ( !SNS & SNN &  !STH & (estado != 10))
				begin
					tabla <= C;
				end

				else if (SNS & !SNN & !STH & (estado != 7))
				begin
					tabla <= B;      
				end

				else
				begin
					tabla <= A;		
				end	 
				
				/*Loop de estados: Accede cuando recibe okay desde modulo time_fsm.
				En cada estado se actualizan los semaforos y se pasa el tiempo a contar 
				al clock. Al entrar al clock, se deshabilita el loop de estados hasta que 
				se cumpla el tiempo*/
				
				if((finished == 1) && (reset == 0)) begin		
					
					case(estado)
						1: 
						begin
							$display("ESTADO %d", estado);	  //Aviso en display para testbench
							$display("TIEMPO %d", secondsToCount);
							secondsToCount <= 17;
							Semaforo_NN	<= RED;
							Semaforo_NS <= RED;
							Semaforo_TH	<= RED;
							Giro_NN_izq	<= RED;
							Giro_NN_der <= GREEN;
							Giro_TH_izq <= GREEN;
							Semaforo_peaton_N <= RED;
							Semaforo_peaton_TH1 <= GREEN;
							Semaforo_peaton_TH2 <= RED;
							estado <= estado + 1;	 //Pasa a siguiente estado
						end		  		
						2:
						begin  
							$display("ESTADO %d", estado);	   //Aviso en display para testbench
							$display("TIEMPO %d", secondsToCount);     
							secondsToCount <= 3;
						    Semaforo_NN <= RED;
							Semaforo_NS <= RED ;
							Semaforo_TH	<= RED;
							Giro_NN_izq	<= RED;
							Giro_NN_der <= RED;
							Giro_TH_izq <= GREEN;
							Semaforo_peaton_N <= RED;
							Semaforo_peaton_TH1 <= GREEN;
							Semaforo_peaton_TH2 <= GREEN; 
		                    estado <= estado + 1;	//Pasa a siguiente estado
						end	
						3:
						begin 
							$display("ESTADO %d", estado);
							$display("TIEMPO %d", secondsToCount);
							secondsToCount <= 1;
							Semaforo_NN	<= RED;
							Semaforo_NS <= RED ;
							Semaforo_TH	<= YELLOW;
							Giro_NN_izq	<= RED;
							Giro_NN_der <= RED;
							Giro_TH_izq <= RED;
							Semaforo_peaton_N <= RED;
							Semaforo_peaton_TH1 <= GREEN;
							Semaforo_peaton_TH2 <= GREEN; 
							estado <= estado + 1;	//Pasa a siguiente estado
						end
						4:	 
						begin 
							$display("ESTADO %d", estado);
							$display("TIEMPO %d", secondsToCount);
							case(tabla)
								A: secondsToCount <= 6;
								B: secondsToCount <= 5;
								C: secondsToCount <= 27;
								D: secondsToCount <= 27;
							endcase		
							Semaforo_NN	<= RED;
							Semaforo_NS <= RED ;
							Semaforo_TH	<= GREEN;
							Giro_NN_izq	<= RED;
							Giro_NN_der <= RED;
							Giro_TH_izq <= RED;
							estado <= estado + 1;	//Pasa a siguiente estado
							Semaforo_peaton_N <= RED;
							Semaforo_peaton_TH1 <= GREEN;
							Semaforo_peaton_TH2 <= GREEN; 
						end	 
						5: 
						begin 		
							$display("ESTADO %d", estado);
							$display("TIEMPO %d", secondsToCount);
							secondsToCount <= 3;	
							Semaforo_NN	<= RED;
							Semaforo_NS <= RED ;
							Semaforo_TH	<= YELLOW;
							Giro_NN_izq	<= RED;
							Giro_NN_der <= RED;
							Giro_TH_izq <= RED;
							estado <= estado + 1;	//Pasa a siguiente estado
							Semaforo_peaton_N <= RED;
							Semaforo_peaton_TH1 <= GREEN;
							Semaforo_peaton_TH2 <= GREEN; 
						end
						6:
						begin  	  
							$display("ESTADO %d", estado);
							$display("TIEMPO %d", secondsToCount);
							secondsToCount <= 1;	
							Semaforo_NN	<= RED;
							Semaforo_NS <= YELLOW ;
							Semaforo_TH	<= RED;
							Giro_NN_izq	<= RED;
							Giro_NN_der <= RED;
							Giro_TH_izq <= RED;
							Semaforo_peaton_N <= GREEN;
							Semaforo_peaton_TH1 <= RED;
							Semaforo_peaton_TH2 <= RED; 
							estado <= estado + 1;	//Pasa a siguiente estado  
						end
						7: 
						begin 	
							$display("ESTADO %d", estado);
							$display("TIEMPO %d", secondsToCount);
							case(tabla)
								A: secondsToCount <= 27;
								B: secondsToCount <= 14;
								C: secondsToCount <= 14;
								D: secondsToCount <= 54;
							endcase		
							Semaforo_NN	<= RED;
							Semaforo_NS <= GREEN ;
							Semaforo_TH	<= RED;
							Giro_NN_izq	<= RED;
							Giro_NN_der <= RED;
							Giro_TH_izq <= RED;
							Semaforo_peaton_N <= GREEN;
							Semaforo_peaton_TH1 <= RED;
							Semaforo_peaton_TH2 <= RED; 
							estado <= estado + 1;	 
						end
						8:
						begin 
							$display("ESTADO %d", estado);
							$display("TIEMPO %d", secondsToCount);
							secondsToCount <= 3;
							Semaforo_NN	<= RED;
							Semaforo_NS <= YELLOW ;
							Semaforo_TH	<= RED;
							Giro_NN_izq	<= RED;
							Giro_NN_der <= RED;
							Giro_TH_izq <= RED;
							Semaforo_peaton_N <= GREEN;
							Semaforo_peaton_TH1 <= RED;
							Semaforo_peaton_TH2 <= RED;
							estado <= estado + 1;
						end
						9:
						begin 
							$display("ESTADO %d", estado);
							$display("TIEMPO %d", secondsToCount);
							secondsToCount <= 1;
							Semaforo_NN	<= YELLOW;
							Semaforo_NS <= RED ;
							Semaforo_TH	<= RED;
							Giro_NN_izq	<= RED;
							Giro_NN_der <= RED;
							Giro_TH_izq <= RED;
							Semaforo_peaton_N <= GREEN;
							Semaforo_peaton_TH1 <= RED;
							Semaforo_peaton_TH2 <= RED;
							estado <= estado + 1;
						end
						10:
						begin  
							$display("ESTADO %d", estado);
							$display("TIEMPO %d", secondsToCount);
							case(tabla)
								A: secondsToCount <= 24;
								B: secondsToCount <= 12;
								C: secondsToCount <= 48;
								D: secondsToCount <= 12;
							endcase		
							Semaforo_NN	<= GREEN;
							Semaforo_NS <= RED ;
							Semaforo_TH	<= RED;
							Giro_NN_izq	<= GREEN;
							Giro_NN_der <= GREEN;
							Giro_TH_izq <= RED;
							Semaforo_peaton_N <= GREEN;
							Semaforo_peaton_TH1 <= RED;
							Semaforo_peaton_TH2 <= RED; 
							estado <= estado + 1;	
						end
						11:
						begin  
							$display("ESTADO %d", estado);
							$display("TIEMPO %d", secondsToCount);
							secondsToCount <= 3;	
							Semaforo_NN	<= YELLOW;
							Semaforo_NS <= RED;
							Semaforo_TH	<= RED;
							Giro_NN_izq	<= RED;
							Giro_NN_der <= GREEN;
							Giro_TH_izq <= RED;
							Semaforo_peaton_N <= GREEN;
							Semaforo_peaton_TH1 <= GREEN;
							Semaforo_peaton_TH2 <= RED; 
							estado <= 1;
						end	 
					endcase
				end	
			end
		end
endmodule 


/*
module testfsm();
	
   	reg CLK_10k;
	reg [15:0] seconds;
	reg reset;  
	reg finished;	  
	time_fsm C1(.reset(reset), .secondsToCount (seconds), .CLK(CLK_10k), .finished(finished)); 	  
	
	
	reg SNN_test;
	reg STH_test;
	reg SNS_test;	
	wire NN_red, NN_yellow, NN_green; //semáforo Norton al Norte
	wire NS_red, NS_yellow, NS_green; //semáforo Norton al Sur
	wire TH_red, TH_yellow, TH_green; //semáforo Thevenin
	
	wire GNNL_red, GNNL_green; //semáforo Norton al Norte
	wire GNNR_red, GNNR_green; //semáforo Norton al Sur
	wire GTH_red, GTH_green; //semáforo Thevenin	
	
	wire [1:0] lightTH;
	wire [1:0] lightNN;
	wire [1:0] lightNS;
	wire [1:0] lightGTH;
	wire [1:0] lightGNN_R;
	wire [1:0] lightGNN_L;
	
	fsm fsmGeneral(
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
		.timer(seconds), 
		.reset(reset),
		.finished(finished));	


	initial begin
		CLK_10k=0;
		forever #100000ns CLK_10k = ~ CLK_10k;
	end											 


	initial begin
		reset = 1; 
		#1s
		STH_test =1;
		SNN_test =0;
		SNS_test =0;
		
		#100s
		/*
		STH_test =0;
		SNN_test =1;
		SNS_test =0;
		#100s  
		$finish;
	end
		
endmodule  */