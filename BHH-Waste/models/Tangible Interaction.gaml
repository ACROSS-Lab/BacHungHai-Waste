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
	float delay_between_actions<- 10#s;
	float last_action_time <- machine_time;
	image_file f;
	
	reflex detect_interaction when: stage = PLAYER_TURN and ((machine_time - last_action_time)/1000.0 > delay_between_actions) {
		string result <- string(decodeQR(webcam));
		//write sample(result_tmp);
		if ((result in ["Action 1", "Action 2", "Action 9"]) and not(result in territory[index_player].actions_done)) {
			if result = "Action 1" {
				ask territory[index_player] {
					do build_bins;
				}

			} else if result = "Action 2" {
				ask territory[index_player] {
					do build_treatment_factory;
				}

			} else if result = "Action 9" {
				ask territory[index_player] {
					do end_of_turn;
				}

			} 
			last_action_time <- machine_time;
			territory[index_player].actions_done <<result;
				
		}

		if show_camera {
			f <- image_file(cam_shot("toto.gif", webcam));
			matrix mat <- matrix(f);
			ask cell {
				color <- rgb(mat[grid_x, grid_y]);
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
