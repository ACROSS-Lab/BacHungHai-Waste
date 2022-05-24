/**
* Name: WasteManagement
* Based on the internal skeleton template. 
* Author: Patrick Taillandier
* Tags: 
*/
@no_experiment
model WasteManagement

import "../Global.gaml"



species village { 
	rgb color <- village_color[int(self)];
	list<string> actions_done_this_year;
	list<string> actions_done_total;
	list<cell> cells;
	list<canal> canals;
	list<inhabitant> inhabitants;
	list<farmer> farmers;
	list<urban_area> urban_areas;
	local_landfill my_local_landfill;
	int budget;
	float solid_pollution_level ;
	float water_pollution_level;
	float production_level min: 0.0;
	list<collection_team> collection_teams;
	float bonus_agricultural_production;
	list<plot> plots;
	int population;
	int target_population;
	bool is_drained_strong <- false;
	bool is_drained_weak <- false;
	bool weak_collection_policy <- true;
	bool strong_collection_policy <- true;
	int treatment_facility_year <- 0 max: 3;
	bool treatment_facility_is_activated <- false;
	float start_turn_time;
	int diff_farmers;
	int diff_urban_inhabitants;
	int diff_budget;
	int prev_budget <- -1;
	
	
	action compute_new_budget {
		budget <- world.compute_budget(length(inhabitants), length(farmers), days_with_ecolabel);
		diff_budget <- prev_budget = -1 ? 0 : (budget - prev_budget);
		prev_budget  <- copy(budget);
	}
	action compute_indicators {
		solid_pollution_level <- ((cells sum_of each.solid_waste_level) + (canals sum_of (each.solid_waste_level))) / 10000.0;
		water_pollution_level <- ((cells sum_of each.water_waste_level) + (canals sum_of (each.water_waste_level)))/ 10000.0;
		plots <- plots where not dead(each);
		production_level <- (plots sum_of each.current_production);
	}

	
	
	//1:ACT_DRAIN_DREDGE
	action drain_dredge {
		if (ACT_DRAIN_DREDGE in actions_done_this_year) {
			do tell("Action " +ACT_DRAIN_DREDGE + " cannot be done twice" );
		} else {
			string weak_str <- "Low for " + token_drain_dredge_weak + " tokens";
			string strong_str <- "High for " + token_drain_dredge_strong + " tokens";
			list<string> possibilities <- [weak_str];
			if (budget >= token_drain_dredge_strong) {
				possibilities << strong_str;
			}
			map result <- user_input_dialog("PLAYER " + (index_player + 1)+" - " + ACT_DRAIN_DREDGE  ,[choose("Level",string,weak_str, possibilities)]);
			bool strong <- result["Level"] = strong_str;
			int token_drain_dredge <- strong ? token_drain_dredge_strong : token_drain_dredge_weak;
			if budget >= token_drain_dredge {
				bool  is_ok <- user_confirm("Action Drain & Dredge","PLAYER " + (index_player + 1) +", do you confirm that you want to " + ACT_DRAIN_DREDGE +  " (Cost: " +  impact_trimestrial_collective_action_weak +" tokens)?");
				if is_ok {
					actions_done_total << ACT_DRAIN_DREDGE;
					actions_done_this_year << ACT_DRAIN_DREDGE;
					is_drained_strong <- strong;
					is_drained_weak <- not strong;
					float impact_drain_dredge_waste <- strong ? impact_drain_dredge_waste_strong : impact_drain_dredge_waste_weak;
					ask canals {
						solid_waste_level <- solid_waste_level * (1 - impact_drain_dredge_waste);
						water_waste_level <- water_waste_level * (1 - impact_drain_dredge_waste);
					}
					budget <- budget - token_drain_dredge;
				}
			} else {
				do tell("Not enough budget for " +ACT_DRAIN_DREDGE );
			}
			
		}
	}
	
	//2:ACT_FACILITY_TREATMENT
	action install_facility_treatment_for_homes {
		if (ACT_FACILITY_TREATMENT in actions_done_total) {
			do tell("Action " +ACT_FACILITY_TREATMENT + " cannot be done twice" );
		} else {
				int max_budget_p1 <- village[0].budget;
				int max_budget_p2 <- village[1].budget -  (index_player < 1 ? token_weak_waste_collection : 0);
				int max_budget_p3 <- village[2].budget -  (index_player < 2 ? token_weak_waste_collection : 0);
				int max_budget_p4 <- village[3].budget -  (index_player < 3 ? token_weak_waste_collection : 0);
				string p1_str <- "Player 1 (max budget: " + max_budget_p1 + ")";
				string p2_str <- "Player 2 (max budget: " + max_budget_p2 + ")";
				string p3_str <- "Player 3 (max budget: " + max_budget_p3 + ")";
				string p4_str <- "Player 4 (max budget: " + max_budget_p4 + ")";
				map results <- user_input_dialog("Install falicity treatment for urban areas. Cost: " +token_install_filter_for_homes_construction +" tokens. Number of tokens payed by each player",[enter(p1_str,int,0),enter(p2_str,int,0),enter(p3_str,int,0),enter(p4_str,int,0)]);
				int p1 <- min(int(results[p1_str]), max_budget_p1);
				int p2 <- min(int(results[p2_str]), max_budget_p2);
				int p3 <- min(int(results[p3_str]), max_budget_p3);
				int p4 <- min(int(results[p4_str]), max_budget_p4);
				if p1 + p2 + p3 + p4 >= token_install_filter_for_homes_construction {
					string cost_str <- "(Cost: "; 
					bool add_ok <- false;
					if p1 > 0 {
						cost_str <- cost_str + "Player 1:" + p1 + " tokens";
						add_ok <- true;
					}
					if p2 > 0 {
						cost_str <- cost_str + (add_ok ? ", " : "")+  "Player 2:" + p2 + " tokens";
						add_ok <- true;
					}
					if p3 > 0 {
						cost_str <- cost_str  + (add_ok ? ", " : "")+ "Player 3:" + p3 + " tokens";
						add_ok <- true;
					}
					if p4 > 0 {
						cost_str <- cost_str  + (add_ok ? ", " : "")+ "Player 4:" + p4 + " tokens";
					}
					bool  is_ok <- user_confirm("Action Facility treatment","PLAYER " + (index_player + 1) +", do you confirm that you want to " + ACT_FACILITY_TREATMENT +  cost_str +"?");
					if is_ok {
						
						ask village {
							actions_done_total << ACT_FACILITY_TREATMENT;
							actions_done_this_year << ACT_FACILITY_TREATMENT;
							treatment_facility_is_activated <- true;
							treatment_facility_year <- 0;
						
						}
						treatment_facility_year <- 1;
						
						list<int> ps <- [p1,p2,p3,p4];	
						if (p1 + p2 + p3 + p4) > token_install_filter_for_homes_construction {
							int to_remove <- token_install_filter_for_homes_construction - (p1 + p2 + p3 + p4) ;
							loop while: to_remove > 0 and (p1 + p2 + p3 + p4) > 0{
								int i <- rnd(3);
								int c <- min(1, to_remove, ps[i] );
								to_remove <- to_remove - c;
								ps[i] <- ps[i] - c;
							}
						}
						loop i from: 0 to: 3 {
							village[i].budget <- village[i].budget - ps[i];
						}
					}
				} else {
						do tell("Not enough budget for " +ACT_FACILITY_TREATMENT );
			
				}
			
		}
	}
	
	//3:ACT_SENSIBILIZATION
	action sensibilization {
		if (ACT_SENSIBILIZATION in actions_done_this_year) {
			do tell("Action " +ACT_SENSIBILIZATION + " cannot be done twice" );
		} else {
			if budget >= token_sensibilization {
				bool  is_ok <- user_confirm("Action Sensibilization","PLAYER " + (index_player + 1) +", do you confirm that you want to " + ACT_SENSIBILIZATION + " (Cost: " +  token_sensibilization +" tokens)?");
				if is_ok {
					actions_done_total << ACT_SENSIBILIZATION;
					actions_done_this_year << ACT_SENSIBILIZATION;
					budget <- budget - token_sensibilization;
					
					ask inhabitants + farmers {
						environmental_sensibility <- environmental_sensibility+ impact_sensibilization;
					}
				}
			}else {
				do tell("Not enough budget for " +ACT_SENSIBILIZATION );
			}
		}
	}
	
	//4:ACTION_COLLECTIVE_ACTION
	action trimestrial_collective_action (bool strong){
		if (ACTION_COLLECTIVE_ACTION in actions_done_this_year) {
			do tell("Action " +ACTION_COLLECTIVE_ACTION + " cannot be done twice" );
		} else {
			int token_trimestrial_collective_action <- token_trimestrial_collective_action_strong;
			if not strong {
				token_trimestrial_collective_action <- token_trimestrial_collective_action_weak;
			}
			if budget >= token_trimestrial_collective_action {
				bool  is_ok <- user_confirm("Action trimestrial action","PLAYER " + (index_player + 1) +", do you confirm that you want to " + ACTION_COLLECTIVE_ACTION + " (Cost: " +  token_trimestrial_collective_action +" tokens)?");
				if is_ok {
					actions_done_total << ACTION_COLLECTIVE_ACTION;
					actions_done_this_year << ACTION_COLLECTIVE_ACTION;
					float impact_trimestrial_collective_action <- impact_trimestrial_collective_action_strong;
					if not strong {
						impact_trimestrial_collective_action <- impact_trimestrial_collective_action_weak;
					} 
					ask canals {
						solid_waste_level <- solid_waste_level * (1 - impact_trimestrial_collective_action);
					}
					budget <- budget - token_trimestrial_collective_action;
				}
			} else {
				do tell("Not enough budget for " +ACTION_COLLECTIVE_ACTION );
			}
		}
		
	}
	
	//5:ACT_PESTICIDE_REDUCTION
	action pesticide_reducing {
		if (ACT_PESTICIDE_REDUCTION in actions_done_total) {
			do tell("Action " +ACT_PESTICIDE_REDUCTION + " cannot be done twice" );
		} else {
			if budget >= token_pesticide_reducing {
				bool  is_ok <- user_confirm("Action Pesticide reducing","PLAYER " + (index_player + 1) +", do you confirm that you want to " + ACT_PESTICIDE_REDUCTION + " (Cost: " +  token_pesticide_reducing +" tokens)?");
				if is_ok {
					actions_done_total << ACT_PESTICIDE_REDUCTION;
					actions_done_this_year << ACT_PESTICIDE_REDUCTION;
					budget <- budget - token_pesticide_reducing;
					ask plots {
						does_reduce_pesticide <- true;
					}
				}
			}else {
				do tell("Not enough budget for " +ACT_PESTICIDE_REDUCTION );
			}
		}
	}
	
	//6:ACT_SUPPORT_MANURE
	action support_manure_buying(bool strong) {
		if (ACT_SUPPORT_MANURE in actions_done_this_year) {
			do tell("Action " +ACT_SUPPORT_MANURE + " cannot be done twice" );
		} else {
			int token_support_manure_buying <- strong ? token_support_manure_buying_strong : token_support_manure_buying_weak;
			if budget >= token_support_manure_buying {
				bool  is_ok <- user_confirm("Action Support Mature","PLAYER " + (index_player + 1) +", do you confirm that you want to " + ACT_SUPPORT_MANURE + " (Cost: " +  token_support_manure_buying +" tokens)?");
				if is_ok {
					actions_done_total << ACT_SUPPORT_MANURE;
					actions_done_this_year << ACT_SUPPORT_MANURE;
					budget <- budget - token_support_manure_buying;
					ask plots {
						use_more_manure_strong <- strong;
						use_more_manure_weak <- not strong;
					}
				}
			}else {
				do tell("Not enough budget for " +ACT_SUPPORT_MANURE );
			}
		}
	}
	
	
	//7:ACT_IMPLEMENT_FALLOW
	action implement_fallow {
		if (ACT_IMPLEMENT_FALLOW in actions_done_this_year) {
			do tell("Action " +ACT_IMPLEMENT_FALLOW + " cannot be done twice" );
		} else {
			if budget >= token_implement_fallow {
			
			bool  is_ok <- user_confirm("Action Implementation Follow","PLAYER " + (index_player + 1) +", do you confirm that you want to " + ACT_IMPLEMENT_FALLOW + " (Cost: " +  token_implement_fallow +" tokens)?");
			if is_ok {
				ask plots {
					does_implement_fallow <- true;
				}
				budget <- budget - token_implement_fallow;
				ask cells {
					water_waste_level <- water_waste_level - impact_implement_fallow_waste;
				}
				actions_done_total << ACT_IMPLEMENT_FALLOW;
				actions_done_this_year << ACT_IMPLEMENT_FALLOW;
				
		
				}
			}else {
				do tell("Not enough budget for " +ACT_IMPLEMENT_FALLOW );
			}
		
		}
	}
	
	
	//8:ACT_INSTALL_DUMPHOLES,
	action install_gumpholes {
		if (ACT_INSTALL_DUMPHOLES in actions_done_total) {
			do tell("Action " +ACT_INSTALL_DUMPHOLES + " cannot be done twice" );
		} else {
			
			if budget >= token_installation_dumpholes {
				bool  is_ok <- user_confirm("Action Installation Dumpholes","PLAYER " + (index_player + 1) +", do you confirm that you want to " + ACT_INSTALL_DUMPHOLES + " (Cost: " +  token_installation_dumpholes +" tokens)?");
				if is_ok {
					actions_done_total << ACT_PESTICIDE_REDUCTION;
					actions_done_this_year<< ACT_PESTICIDE_REDUCTION;
					budget <- budget - token_installation_dumpholes;
					ask plots {
						has_dumphole <- true;
					}
				}
				
			}else {
				do tell("Not enough budget for " +ACT_INSTALL_DUMPHOLES );
			}
		}
	}
	
	action ending_turn {
		if save_log {
			string to_save <- "" + turn + "," + (index_player +1) + "," + budget;
			loop act over: actions_done_this_year  {
				to_save <- to_save+"," + act;
			}
			save to_save to: village_action_log_path type: text rewrite: false;
		}
		index_player <- index_player + 1;
		if index_player < length(village) {
			ask village[index_player] {
				do start_turn;
			}
		} 
	}
	//9:ACT_END_TURN,
	action end_of_turn {
		bool  is_ok <- user_confirm("End of turn","PLAYER " + (index_player + 1) +", do you confirm that you want to end the turn?");
		if is_ok {
			do ending_turn;
		}
	}
	
	action start_turn {
		start_turn_time <- machine_time;
		 
		ask world {do update_display;do resume;}
		
		ask plots {
			use_more_manure_strong <- false;
			use_more_manure_weak <- false;
			does_implement_fallow <- false;
		}
		do tell("PLAYER " + (index_player + 1) + " TURN");
		int collect_per_week_weak <- length(days_collects_weak);
		int collect_per_week_strong <- length(days_collects_strong);
		int collect_per_week_ultimate <- length(days_collects_ultimate);
		string current_val <- "" +(weak_collection_policy ? collect_per_week_weak : (strong_collection_policy ? collect_per_week_strong : collect_per_week_ultimate)) + " per week";
		map result;
		
		list<string> possibilities <- budget >=  token_ultimate_waste_collection ? [""+collect_per_week_weak +" per week",""+collect_per_week_strong +" per week", ""+collect_per_week_ultimate +" per week"] : (budget >=  token_strong_waste_collection ? [""+collect_per_week_weak +" per week",""+collect_per_week_strong +" per week"] : [""+collect_per_week_weak +" per week"]);
		if not(current_val in possibilities) {
			current_val <- first(possibilities);
		}
		if treatment_facility_year = 0 {
			result <- user_input_dialog("PLAYER " + (index_player + 1)+" - Waste management policy",[choose("Choose a waste collection frenquency",string,current_val, possibilities)]);
		
		} else {
			result <- user_input_dialog("PLAYER " + (index_player + 1)+" - Waste management policy",[
				choose("Choose a waste collection frenquency",string,current_val,possibilities),
				choose("Do you wish to pay for the home treatment facility?",bool,true, [true,false])
			]);
			treatment_facility_is_activated <- bool(result["Do you wish to pay for the home treatment facility?"]);
			if true {actions_done_this_year <<  "Pay for treatment facility maintenance";}
		
			if treatment_facility_is_activated {budget <- budget - token_install_filter_for_homes_maintenance;}
		
		}
		actions_done_this_year << result["Choose a waste collection frenquency"] ;
		weak_collection_policy <- result["Choose a waste collection frenquency"] = ""+collect_per_week_weak +" per week";
		strong_collection_policy <- result["Choose a waste collection frenquency"] = ""+collect_per_week_strong +" per week";
		
		budget <- budget - (weak_collection_policy ? token_weak_waste_collection :(strong_collection_policy ? token_strong_waste_collection : token_ultimate_waste_collection));
		ask collection_teams {collection_days <- myself.weak_collection_policy ? days_collects_weak : (myself.strong_collection_policy ? days_collects_strong : days_collects_ultimate);}
		if treatment_facility_is_activated {
			treatment_facility_year <- treatment_facility_year + 1;
		}
		to_refresh <- true;
		
	}
	aspect default {
		if (stage = PLAYER_ACTION_TURN) {
			if (index_player = int(self)) {
				draw shape color: color;
			}
		} else {
			if (draw_territory) {
				draw shape.contour + 20.0 color: #black;
			}
		}
	}
	
	aspect demo {
		if draw_territory {
			
			draw shape color: color;
		}
			
	}
	
	aspect border_geom {
		draw shape.contour buffer (20,20,0, true) depth: 1.0 color: color;
	}
	
	aspect demo_with_name {
		if draw_territory {
			draw "Player " + (int(self) + 1) at: location + {0,0,10} color: #white anchor: #center font: font("Helvetica", 50, #bold);
			draw shape.contour + 20.0 color: color;
		}
	}
}