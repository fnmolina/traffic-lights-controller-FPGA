/********************************************************************************************
*			Modulo time_fsm: Manejo de tiempo de estados. 									*
*			 	             Entrada: enable, reset, clock10kHZ, tiempo de estado. 			*
*							 Salidas: señal de cambio de proximo de estado					*
********************************************************************************************/	


module time_fsm
(
input wire enable,
input wire reset,
input wire CLK, //10kHz  
input wire [15:0] secondsToCount, 
output reg finished
);      
      
reg [15:0] count;
reg [15:0] seconds;
reg [7:0] countSeconds;
parameter MAX = 10000;   


/*Contador de tiempo: habilita y deshabilita el paso al siguiente estado una vez que termina o inicia la cuenta*/

always @ (posedge CLK) 
	begin	
			if(reset == 1 && enable == 1)		//Reset devuelve parametros a condicion inicial
			begin  
				$display("RESET");
				seconds <= 0;  
				count <= 0;
				finished <= 1;
			end
		
			else if(enable == 1)	
				begin
			finished <= 0;    //flag de habilitacion/deshabilitacion de cambio al proximo estado
			count <= count + 1;	  
		
			if (count == MAX) 
			begin 
				seconds <= seconds + 1;	//contador de segundos 
				count <= 0; 
				$display("Segundo %d", seconds); //display para control de simulacion
			end		 
			else if (seconds == secondsToCount) //una vez que cumplio el tiempo, habilita paso a siguiente estado
			begin 
				count <= 0; //parametros a condicion inicial
				seconds <= 0;
				finished <= 1;
				$display("Finalizo estado %d", finished); //display para control de simulacion
			end	
		end
	end
endmodule      