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
	int image_width <- 640;
	int image_height <- 480;
	
	float last_action_time <- machine_time;
	string latest_action <- "";
	
	reflex detect_interaction when: stage = PLAYER_TURN and (machine_time > (last_action_time + (1000.0 * delay_between_actions))){
		string result <- string(decodeQR(image_width, image_height,webcam));
		write sample(result);
		if machine_time > (last_action_time + (1000.0 * 2 * delay_between_actions)) {
			latest_action <- "";
		}
		if result != latest_action {
			
			
	
			
			if ((result in ["Action 1", "Action 2", "Action 3","Action 4","Action 5", "Action 6", "Action 7","Action 8", "Action 9"]) and not(result in village[index_player].actions_done)) {
				latest_action <- result;
				last_action_time <- machine_time;
				village[index_player].actions_done <<result;
				switch result {
					match "Action 1" {
						ask village[index_player] {
							do drain_dredge;
						}
					} 
					match "Action 2" {
						ask village[index_player] {
							do install_facility_treatment_for_homes ;
						}
					}
					match "Action 3" {
						ask village[index_player] {
							do sensibilization ;
						}
					}
					match "Action 4" {
						ask village[index_player] {
							do trimestrial_collective_action ;
						}
					}
					match "Action 5" {
						ask village[index_player] {
							do pesticide_reducing ;
						}
					}
					match "Action 6" {
						ask village[index_player] {
							do support_manure_buying ;
						}
					}
					match "Action 7" {
						ask village[index_player] {
							do implement_fallow ;
						}
					}
					match "Action 8" {
						ask village[index_player] {
							do install_gumpholes ;
						}
					}
					
					match "Action 9" {
						ask village[index_player] {
							do end_of_turn ;
						}
					}
				}
			}
		} 
	}
}

//grid cell_image width: 640 height: 480;


experiment with_tangible_interaction type: gui parent: the_serious_game{
	/** Insert here the definition of the input and output of the model */
	output {
		
		
		/*display webcam {
			grid cell_image ;
			
		}*/
	}
}
