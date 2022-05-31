/**
* Name: TangibleInteraction
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/


model TangibleInteraction

import "Debug.gaml"



global {
	
	bool confirmation_popup <- false;
	bool no_starting_actions <- true;
	
	
	string A_DUMPHOLES <- "Dumpholes";
	string A_PESTICIDES <- "Pesticides";
	string A_END_TURN <- "End of turn";
	string A_SENSIBILIZATION <- "Sensibilization";
	string A_FILTERS <- "Filters for every home";
	string A_COLLECTIVE_LOW <- "Trimestrial collective action low";
	string A_COLLECTIVE_HIGH <- "Trimestrial collective action high";
	string A_DRAIN_DREDGES_HIGH <- "Drain and dredge high";
	string A_DRAIN_DREDGES_LOW <- "Drain and dredge low";
	string A_FALLOW <- "Fallow";
	string A_MATURES_LOW <- "Support manure low";
	string A_MATURES_HIGH <- "Support manure high";
	string A_FILTER_MAINTENANCE <- "Maintenance for filters";
	
	string A_COLLECTION_LOW <- "Collection teams low";
	string A_COLLECTION_HIGH <- "Collection teams high";
	
 	list<string> actions_name_short <- [A_DUMPHOLES, A_PESTICIDES, A_SENSIBILIZATION, A_FILTERS, A_COLLECTIVE_HIGH, A_COLLECTIVE_LOW, 
 		A_DRAIN_DREDGES_HIGH, A_DRAIN_DREDGES_LOW, A_FALLOW, A_MATURES_HIGH, A_MATURES_LOW, A_FILTER_MAINTENANCE, A_COLLECTION_LOW, A_COLLECTION_HIGH, A_END_TURN
 	];
	
	int webcam <- 1;
	float delay_between_actions<- 1#s;
	int image_width <- 640;
	int image_height <- 480;
	bool ready_action <- true;
	float last_action_time <- machine_time;
	string latest_action <- "";
	
	reflex detect_interaction_discussion_phase when: stage = PLAYER_DISCUSSION_TURN {
		string result <- string(decodeQR(image_width, image_height,webcam));
		if result = nil { 
			ready_action <- true;
		}
		if ready_action and machine_time > (last_action_time + (1000.0 * 2 * delay_between_actions)) {
			latest_action <- "";
		}
		if result != latest_action and result = A_END_TURN {
			ready_action <- false;
			latest_action <- result;
			last_action_time <- machine_time;
			do end_of_discussion_phase;	
		}
	}
	
	reflex detect_interaction when: stage = PLAYER_ACTION_TURN and (machine_time > (last_action_time + (1000.0 * delay_between_actions))){
		string result <- string(decodeQR(image_width, image_height,webcam));
		if result = nil {
			ready_action <- true;
		}
		if ready_action and machine_time > (last_action_time + (1000.0 * 2 * delay_between_actions)) {
			latest_action <- "";
		}
		if result != latest_action {
			if ((result in actions_name_short) and not(result in village[index_player].actions_done_this_year) and not(result in village[index_player].actions_done_total)) {
				ready_action <- false;
				latest_action <- result;
				last_action_time <- machine_time;
				//village[index_player].actions_done_this_year <<result;
				switch result {
					match A_DRAIN_DREDGES_LOW{
						ask villages_order[index_player] {
							do drain_dredge(false, false);
						}
					} 
					match A_DRAIN_DREDGES_HIGH{
						ask villages_order[index_player] {
							do drain_dredge(true, false);
						}
					} 
					match A_FILTERS {
						ask villages_order[index_player] {
							do install_facility_treatment_for_homes ;
						}
					}
					match A_SENSIBILIZATION {
						ask villages_order[index_player] {
							do sensibilization ;
						}
					}
					match A_COLLECTIVE_HIGH {
						ask villages_order[index_player] {
							do trimestrial_collective_action(true, false) ;
						}
					}
					match A_COLLECTIVE_LOW {
						ask villages_order[index_player] {
							do trimestrial_collective_action(false, false) ;
						}
					}
					match A_COLLECTION_HIGH {
						ask villages_order[index_player] {
							do collection_team_action(true) ;
						}
					}
					match A_COLLECTION_LOW {
						ask villages_order[index_player] {
							do collection_team_action(false) ;
						}
					}
					match A_PESTICIDES {
						ask villages_order[index_player] {
							do pesticide_reducing ;
						}
					}
					match A_MATURES_HIGH {
						ask villages_order[index_player] {
							do support_manure_buying(true, false) ;
						}
					}
					match A_MATURES_LOW {
						ask villages_order[index_player] {
							do support_manure_buying(false, false) ;
						}
					}
					match A_FALLOW {
						ask villages_order[index_player] {
							do implement_fallow ;
						}
					}
					match A_DUMPHOLES {
						ask villages_order[index_player] {
							do install_dumpholes ;
						}
					}
					
					match A_FILTER_MAINTENANCE {
						ask villages_order[index_player] {
							do install_fiter_maintenance ;
						}
					}
					
					match A_END_TURN {
						ask villages_order[index_player] {
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
