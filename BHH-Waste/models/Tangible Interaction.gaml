/**
* Name: TangibleInteraction
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/


model TangibleInteraction

import "Waste Management.gaml"


global {
	int webcam <- 0;
	bool show_camera <- false parameter: true;
	float delay_between_actions<- 2#s;
	int image_width <- 320;
	int image_height <- 240;
	
	float last_action_time <- machine_time;
	string latest_action <- "";
	
	reflex detect_interaction when: stage = PLAYER_TURN and (machine_time > (last_action_time + (1000.0 * delay_between_actions))){
		string result <- string(decodeQR(image_width, image_height,webcam));
		if machine_time > (last_action_time + (1000.0 * 2 * delay_between_actions)) {
			latest_action <- "";
		}
		if result != latest_action {
			//write sample(result);
			if ((result in ["Action 1", "Action 2", "Action 9"]) and not(result in village[index_player].actions_done)) {
				latest_action <- result;
				last_action_time <- machine_time;
				village[index_player].actions_done <<result;
				if result = "Action 1" {
					ask village[index_player] {
						do bonus_agricultural_production;
					}
	
				} else if result = "Action 2" {
					ask village[index_player] {
						do compute_indicators;
					}
	
				} else if result = "Action 9" {
					ask village[index_player] {
						do collection_teams;
					}
	
				} 
					
			}
	
		} 
	}
}

//grid cell_image width: 640 height: 480;


experiment with_tangible_interaction type: gui parent: WasteManagement{
	/** Insert here the definition of the input and output of the model */
	output {
		
		
		/*display webcam {
			grid cell_image ;
			
		}*/
	}
}
