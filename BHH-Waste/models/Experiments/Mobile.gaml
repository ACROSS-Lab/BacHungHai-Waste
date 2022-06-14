/**
* Name: Mobile
* Based on the internal empty template. 
* Author: Baptiste Lesquoy
* Tags: 
*/


model Mobile

/* Insert your model definition here */


import "LFAY.gaml"
import "../NetworkManager.gaml"
 


global skills: [music] {
	
	
	NetworkManager networkManager;
	
	//TODO: is it used anywhere ?
	list<string> actions_to_process <- []; // actions of a player to process by the model
	
	init {
	
		create NetworkManager number:1 {
			networkManager <- self;
			do init_game(self.port, players_names, mobile_actions);
		}
		
	}
	
	
	reflex server_loop {
		ask networkManager {
			loop while:has_more_message() {
				
				message mess <- fetch_message();
				write "message received " + mess;
				string content <- mess.contents;
				
				if content contains kw_ask_for_connection { 
					int idx <- int(content replace(kw_ask_for_connection + ':', ''));
					int idx_player <- int(villages_order[index_player]);
					write "connection of player: " + idx + ", current player: " + (idx_player + 1);
					do set_player(mess.sender, idx-1, village[idx-1].budget);
					if (idx-1 = idx_player) {
						do send_your_turn(players[idx-1]);
					}
				}
				else if content contains kw_player_actions {
					do add_player_action(mess.sender, content);
					write "playing " + players_actions[mess.sender];
					loop act over:players_actions[mess.sender] {						
						ask myself{
							write act;
							write A_COLLECTIVE_HIGH;
							do execute_action(act);							
						}
					}
					ask myself{
						do execute_action(A_END_TURN);							
					}
				}
			}				
		}
	}
	
	
	bool confirmation_popup		<- false;
	bool no_starting_actions 	<- true;
	
	
	action before_start_turn{
		do	send_players_pollution_levels;
		ask networkManager{
			int i <- 0;
			int idx_player <- int(villages_order[index_player]);
			loop player over:players{
				if player != nil {
					do send_data_before_turn(players[i], village[i].budget, turn);							
					if (i = idx_player) {
						do send_your_turn(player);
					}					
				}
				i <- i + 1;
			}
		}
	}
	

	
	action send_players_pollution_levels {
		ask networkManager {
			int i <- 0;
			loop player over:players {
				
				list<int> water;
				list<int> solid;
				list<int> prod;
				
				if (i = 0){
					water 	<- village1_water_pollution_values;
					solid 	<- village1_solid_pollution_values;
					prod 	<- village1_production_values;
				}
				else if (i = 1){
					water 	<- village2_water_pollution_values;
					solid 	<- village2_solid_pollution_values;
					prod 	<- village2_production_values;
				}
				else if (i = 2){
					water 	<- village3_water_pollution_values;
					solid 	<- village3_solid_pollution_values;
					prod 	<- village3_production_values;
				}
				else if (i = 3){
					water 	<- village4_water_pollution_values;
					solid 	<- village4_solid_pollution_values;
					prod 	<- village4_production_values;
				}
				
				do send_data(player, kw_water_pollution, water);
				do send_data(player, kw_solid_pollution, solid);
				do send_data(player, kw_productivity, prod);	
				i <- i + 1;
			}
		}
	}
	
}

