/********************************************************************************************
*			Modulo semaforo3: Actualizacion de semaforo vehicular (3 luces)					*
*			 	                 Entrada: senal de estado desde fsm							*
*								 Salida: senales de estado de semaforo a gpio				*
********************************************************************************************/	  


module semaforo3
	(input wire [1:0] light,		
		input wire clk, 
		output reg green,  
		output reg yellow, 
		output reg red); 

	parameter RED = 2'b00;
	parameter YELLOW = 2'b01;
	parameter GREEN = 2'b10;
	parameter OFF = 2'b11;
	
	always @ (posedge clk) //Administracion de estados
		begin 
			case(light)	 
				RED: 
				begin
					red <= 1;
					yellow <= 0;
					green <= 0;
				end
				YELLOW:
				begin
					red <= 0;
					yellow <= 1;
					green <= 0;	
				end
				GREEN:
				begin
					red <= 0;
					yellow <= 0;
					green <= 1;
				end
				OFF:  
				begin
					red <= 0;
					yellow <= 0;
					green <= 0;	
				end
			endcase
				
		end
endmodule
										  
