/********************************************************************************************
*			Modulo semaforo2luces: Actualizacion de semaforo peatonal y de giro. 			*
*			 	                 Entrada: senal de estado desde fsm							*
*								 Salida: senales de estado de semaforo a gpio				*
********************************************************************************************/	  
module semaforo2     
	(	input wire [1:0] light,
		input wire clk, 
		output reg green,   
		output reg red
	);

	parameter RED = 2'b00;
	parameter GREEN = 2'b10;
	parameter OFF = 2'b11;
	
	always @ (posedge clk) //Administracion de estados
	begin 
		case(light )	 
			RED: 
			begin
				red <= 1;
				green <= 0;
			end
			GREEN:
			begin
				red <= 0;
				green <= 1;
			end
			OFF:
			begin
				red <= 0;
				green <= 0;
			end
		endcase	
	end		
endmodule
