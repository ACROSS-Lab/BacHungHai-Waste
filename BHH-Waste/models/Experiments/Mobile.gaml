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
	
	list<list<int>> fake_players_budgets <-
	[
		//TODO: changer
		[128, 130, 132, 128], //Tour 1
		[128, 130, 132, 128], //Tour 2
		[128, 130, 132, 128], //Tour 3
		[128, 130, 132, 128], //Tour 4
		[128, 130, 132, 128], //Tour 5
		[128, 130, 132, 128], //Tour 6
		[128, 130, 132, 128], //Tour 7
		[128, 130, 132, 128]  //Tour 8
	];
	
	list<string> actions_to_process <- []; // actions of a player to process by the model
	
	init {
	
		create NetworkManager number:1 {
			networkManager <- self;
			write self.port;
			write players_names;
			write myself.fake_players_budgets;
			write mobile_actions;
			do init_game(self.port, players_names, myself.fake_players_budgets,mobile_actions);
		}
		
	}
	
	
	reflex server_loop {
		ask networkManager {
			loop while:has_more_message() {
				
				message mess <- fetch_message();
				write "message received " + mess;
				string content <- mess.contents;
				
				if content contains kw_ask_for_connection and length(players) < length(player_names) {
					do add_player(mess.sender);
				}
				else if content contains kw_player_actions {
					do add_player_action(mess.sender, content);
				}
			}				
		}
	}
	
	
	bool confirmation_popup		<- false;
	bool no_starting_actions 	<- true;
	
	
	action before_start_turn{
//		do	send_players_pollution_levels;
//		ask networkManager{
//			do send_start_turn(players[index_player], village[index_player].budget, turn);			
//		}
	}
	
	
	
	
	reflex detect_interaction when: stage = PLAYER_ACTION_TURN {
		
		ask networkManager {
			let idx_player <- length(players_actions.keys - 1);
			let player <- players[idx_player];
			list<string> actions <- players_actions[player] split_with ",";
			write "end of the turn " + turn + " for player " + players_names[idx_player];
			loop act over:actions {
				write "execute action " + act;
				ask myself {
					do execute_action(act);
				}
			}	
		}
	} 
	
	
	//TODO: appeler avant de donner la main pour jouer
	action send_players_pollution_levels {
		ask networkManager {
			int i <- 0;
			loop player over:players {
				
				list<float> water;
				list<float> solid;
				list<float> prod;
				
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

