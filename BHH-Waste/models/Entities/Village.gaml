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
	bool weak_collection_policy <- false;
	bool strong_collection_policy <- false;
	bool ultimate_collection_policy <- false;
	int treatment_facility_year <- 0 max: length(treatment_facility_decrease);
	bool treatment_facility_is_activated <- false;
	float start_turn_time;
	int diff_farmers;
	int diff_urban_inhabitants;
	int diff_budget;
	int prev_budget <- -1;
	
	list<map<string,map>> player_actions <- nil;
	
	list<int> player_collect_policy<- nil;
	list<bool> player_traitement_facility_maintenance<- nil;
	
	
	action compute_new_budget {
		budget <- world.compute_budget(length(inhabitants), length(farmers), production_level, days_with_ecolabel);
		diff_budget <- prev_budget = -1 ? 0 : (budget - prev_budget);
		prev_budget  <- copy(budget);
	}
	action compute_indicators {
		solid_pollution_level <- ((cells sum_of each.solid_waste_level) + (canals sum_of (each.solid_waste_level))) / 10000.0;
		water_pollution_level <- ((cells sum_of each.water_waste_level) + (canals sum_of (each.water_waste_level)))/ 10000.0;
		plots <- plots where not dead(each);
		production_level <- (plots sum_of each.current_production);
	}
	
	action tell_not_twice(string act_name) {
		do tell(ACTION + " " +ACT_INSTALL_DUMPHOLES + " " + CANNOT_BE_DONE_TWICE);
	}
	
	bool confirm_action(string act_name, int act_cost) {
		if confirmation_popup {
			return user_confirm(ACTION + " " + act_name, PLAYER + " " + (int(self) + 1) +",  " + CONFIRM_ACTION + " "+ act_name + " (" + COST+ ": " +  act_cost +" " + TOKENS + ")?");
		}
		return true;
	}
	
	
	//1:ACT_DRAIN_DREDGE
	action drain_dredge(bool is_strong <- true, bool selection_possible <- true) {
		if (ACT_DRAIN_DREDGE in actions_done_this_year) {
			if not without_player {do tell_not_twice(ACT_DRAIN_DREDGE);}
		} else {
			string weak_str <- LOW_FOR+ " " + token_drain_dredge_weak + " " + TOKENS;
			string strong_str <- HIGH_FOR + " " + token_drain_dredge_strong + " " + TOKENS;
			list<string> possibilities <- [weak_str];
			if (budget >= token_drain_dredge_strong) {
				possibilities << strong_str;
			}
			bool strong;
		
			if not selection_possible or without_player {
				strong <- is_strong;
			} else {
				map result <- user_input_dialog(PLAYER + " " + (int(self) + 1)+" - " + ACT_DRAIN_DREDGE  ,[choose(LEVEL,string,weak_str, possibilities)]);
				strong <- result[LEVEL] = strong_str;
			}
			int token_drain_dredge <- strong ? token_drain_dredge_strong : token_drain_dredge_weak;
			if budget >= token_drain_dredge {
				bool  is_ok <-without_player or confirm_action(ACT_DRAIN_DREDGE, token_drain_dredge);
				if is_ok {
					
					actions_done_total << ACT_DRAIN_DREDGE;
					actions_done_this_year << ACT_DRAIN_DREDGE;
					if not without_player {
						player_actions[turn -1][ACT_DRAIN_DREDGE] <- map([LEVEL::(strong ? "high":"low")]);
						if display_info_action_console{write "ACTION : " +ACT_DRAIN_DREDGE + " " +  (strong ? "high":"low");}
					}
					is_drained_strong <- strong;
					is_drained_weak <- not strong;
					float impact_drain_dredge_waste <- strong ? impact_drain_dredge_waste_strong : impact_drain_dredge_waste_weak;
					ask canals {
						//solid_waste_level <- solid_waste_level * (1 - impact_drain_dredge_waste);
						water_waste_level <- water_waste_level * (1 - impact_drain_dredge_waste);
					}
					budget <- budget - token_drain_dredge;
				}
			} else {
				if not without_player {do tell(NOT_ENOUGH_BUDGET + " " +ACT_DRAIN_DREDGE );}
			}
			
		}
	}
	
	//2:ACT_FACILITY_TREATMENT
	action install_facility_treatment_for_homes(map money_paid <- nil) {
		if (ACT_FACILITY_TREATMENT in actions_done_total) {
			if not without_player {do tell_not_twice(ACT_FACILITY_TREATMENT);}
		} else {
				int max_budget_p1 <- village[0].budget - (not no_starting_actions and ((index_player < (villages_order index_of village[0]))) ? token_weak_waste_collection : 0);
				int max_budget_p2 <- village[1].budget - (not no_starting_actions and ((index_player < (villages_order index_of village[1])))  ? token_weak_waste_collection : 0);
				int max_budget_p3 <- village[2].budget - (not no_starting_actions and ((index_player < (villages_order index_of village[2]))) ? token_weak_waste_collection : 0);
				int max_budget_p4 <- village[3].budget - (not no_starting_actions and ((index_player < (villages_order index_of village[3]))) ? token_weak_waste_collection : 0);
				int p1; int p2; int p3; int p4;
				if without_player {
					p1 <- min(max_budget_p1,int(money_paid["P1"]));
					p2 <- min(max_budget_p2,int(money_paid["P2"]));
					p3 <- min(max_budget_p3,int(money_paid["P3"]));
					p4 <- min(max_budget_p4,int(money_paid["P4"]));
				} else {
					string p1_str <- PLAYER + " 1 (" + MAX_BUDGET + ": " + max_budget_p1 + ")";
					string p2_str <- PLAYER + " 2 (" + MAX_BUDGET + ": " + max_budget_p2 + ")";
					string p3_str <- PLAYER + " 3 (" + MAX_BUDGET + ": " + max_budget_p3 + ")";
					string p4_str <- PLAYER + " 4 (" + MAX_BUDGET + ": " + max_budget_p4 + ")";
					
					map results <- user_input_dialog(ACT_FACILITY_TREATMENT + ". " + COST + ": " +token_install_filter_for_homes_construction +" " + TOKENS + ". " + NUMBER_TOKENS_PLAYER,[enter(p1_str,int,0),enter(p2_str,int,0),enter(p3_str,int,0),enter(p4_str,int,0)]);
					p1 <- min(int(results[p1_str]), max_budget_p1);
					p2 <- min(int(results[p2_str]), max_budget_p2);
					p3 <- min(int(results[p3_str]), max_budget_p3);
					p4 <- min(int(results[p4_str]), max_budget_p4);
				
				}
				if p1 + p2 + p3 + p4 >= token_install_filter_for_homes_construction {
					string cost_str <- "(" + COST + ": "; 
					bool add_ok <- false;
					if p1 > 0 {
						cost_str <- cost_str + PLAYER + " 1:" + p1 + " " + TOKENS;
						add_ok <- true;
					}
					if p2 > 0 {
						cost_str <- cost_str + (add_ok ? ", " : "")+  PLAYER + "  2:" + p2 +  " " + TOKENS;
						add_ok <- true;
					}
					if p3 > 0 {
						cost_str <- cost_str  + (add_ok ? ", " : "")+ PLAYER + " 3:" + p3 +  " " + TOKENS;
						add_ok <- true;
					}
					if p4 > 0 {
						cost_str <- cost_str  + (add_ok ? ", " : "")+ PLAYER + " 4:" + p4 +  " " + TOKENS;
					}
					bool  is_ok <- (not confirmation_popup) or without_player or user_confirm(ACTION +" " + ACT_FACILITY_TREATMENT, PLAYER +" " + (int(self) + 1) +",  " + CONFIRM_ACTION + " " + ACT_FACILITY_TREATMENT + " " + cost_str +"?");
					if is_ok {
						if not without_player {
							if (empty(player_actions)) {
								player_actions << [];
							}
							player_actions[turn -1][ACT_FACILITY_TREATMENT] <- map(["P1"::p1, "P2"::p2, "P3"::p3, "P4"::p4]);
							
							if display_info_action_console{write "ACTION : " +ACT_FACILITY_TREATMENT ;}
						}
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
					
					if not without_player {do tell(NOT_ENOUGH_BUDGET + " " +ACT_FACILITY_TREATMENT );}
			
				}
			
		}
	}
	
	//3:ACT_SENSIBILIZATION
	action sensibilization {
		if (ACT_SENSIBILIZATION in actions_done_this_year) {
			if not without_player {do tell_not_twice(ACT_SENSIBILIZATION);}
		} else {
			if budget >= token_sensibilization {
				bool  is_ok <-without_player or confirm_action(ACT_SENSIBILIZATION, token_sensibilization);
			
				if is_ok {
					if not without_player {
						player_actions[turn -1][ACT_SENSIBILIZATION] <-nil;
						if display_info_action_console{write "ACTION : " +ACT_SENSIBILIZATION ;}
					}
					actions_done_total << ACT_SENSIBILIZATION;
					actions_done_this_year << ACT_SENSIBILIZATION;
					budget <- budget - token_sensibilization;
					
					ask inhabitants + farmers {
						environmental_sensibility <- environmental_sensibility+ impact_sensibilization;
					}
				}
			}else {
				
				if not without_player {do tell(NOT_ENOUGH_BUDGET + " " +ACT_SENSIBILIZATION );}
			}
		}
	}
	
	//4:ACTION_COLLECTIVE_ACTION
	action trimestrial_collective_action (bool is_strong <- true, bool selection_possible <- true){
		if (ACTION_COLLECTIVE_ACTION in actions_done_this_year) {
			if not without_player {do tell_not_twice(ACTION_COLLECTIVE_ACTION);}
		} else {
			string weak_str <- LOW_FOR + " " + token_trimestrial_collective_action_weak + " " + TOKENS;
			string strong_str <- HIGH_FOR + " " + token_trimestrial_collective_action_strong + " " + TOKENS;
			list<string> possibilities <- [weak_str];
			if (budget >= token_trimestrial_collective_action_strong) {
				possibilities << strong_str;
			} 
			
			bool strong <- is_strong;
			if selection_possible and not without_player {
				map result <- user_input_dialog(PLAYER +" " + (int(self) + 1)+" - " + ACTION_COLLECTIVE_ACTION  ,[choose(LEVEL,string,weak_str, possibilities)]);
				strong <- result[LEVEL] = strong_str;
			}
			
			int token_trimestrial_collective_action <- token_trimestrial_collective_action_strong;
			if not strong {
				token_trimestrial_collective_action <- token_trimestrial_collective_action_weak;
			}
			if budget >= token_trimestrial_collective_action {
				bool  is_ok <-without_player or confirm_action(ACTION_COLLECTIVE_ACTION, token_trimestrial_collective_action);
				if is_ok {
					if not without_player {
						player_actions[turn -1][ACTION_COLLECTIVE_ACTION] <- map([LEVEL::(strong ? "high":"low")]);
						if display_info_action_console{write "ACTION : " +ACTION_COLLECTIVE_ACTION + " " + (strong ? "high":"low");}
					}
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
				
				if not without_player {do tell(NOT_ENOUGH_BUDGET + " " +ACTION_COLLECTIVE_ACTION );}
			}
		}
		
	}
	
	//5:ACT_PESTICIDE_REDUCTION
	action pesticide_reducing {
		if (ACT_PESTICIDE_REDUCTION in actions_done_total) {
			if not without_player {do tell_not_twice(ACT_PESTICIDE_REDUCTION);}
		} else {
			if budget >= token_pesticide_reducing {
				bool  is_ok <-without_player or confirm_action(ACT_PESTICIDE_REDUCTION, token_pesticide_reducing);
			
				if is_ok {
					if not without_player {
						player_actions[turn -1][ACT_PESTICIDE_REDUCTION] <- nil;
						if display_info_action_console{write "ACTION : " +ACT_PESTICIDE_REDUCTION;}
					}
					actions_done_total << ACT_PESTICIDE_REDUCTION;
					actions_done_this_year << ACT_PESTICIDE_REDUCTION;
					budget <- budget - token_pesticide_reducing;
					ask plots {
						does_reduce_pesticide <- true;
					}
				}
			}else {
				if not without_player {do tell(NOT_ENOUGH_BUDGET + " " +ACT_PESTICIDE_REDUCTION );}
			}
		}
	}
	
	//6:ACT_SUPPORT_MANURE
	action support_manure_buying(bool is_strong <- true, bool selection_possible <- true) {
		if (ACT_SUPPORT_MANURE in actions_done_this_year) {
			if not without_player {do tell_not_twice(ACT_SUPPORT_MANURE);}
		} else {
			
			string weak_str <- LOW_FOR + " " + token_support_manure_buying_weak + " " + TOKENS;
			string strong_str <- HIGH_FOR + " " + token_support_manure_buying_strong + " " + TOKENS;
			list<string> possibilities <- [weak_str];
			if (budget >= token_support_manure_buying_strong) {
				possibilities << strong_str;
			} 
			bool strong <- is_strong;
			if selection_possible and  not without_player {
				map result <- user_input_dialog(PLAYER +" " + (int(self) + 1)+" - " + ACT_SUPPORT_MANURE  ,[choose(LEVEL,string,weak_str, possibilities)]);
				strong <- result[LEVEL] = strong_str;
			}
			
			int token_support_manure_buying <- strong ? token_support_manure_buying_strong : token_support_manure_buying_weak;
			if budget >= token_support_manure_buying {
				bool  is_ok <-without_player or confirm_action(ACT_SUPPORT_MANURE, token_support_manure_buying);
				if is_ok {
					if not without_player {
						player_actions[turn -1][ACT_SUPPORT_MANURE] <- map([LEVEL::(strong ? "high":"low")]);
						if display_info_action_console{write "ACTION : " +ACT_SUPPORT_MANURE + " " + (strong ? "high":"low");}
				
					}
					actions_done_total << ACT_SUPPORT_MANURE;
					actions_done_this_year << ACT_SUPPORT_MANURE;
					budget <- budget - token_support_manure_buying;
					ask plots {
						use_more_manure_strong <- strong;
						use_more_manure_weak <- not strong;
					}
				}
			}else {
				if not without_player {do tell(NOT_ENOUGH_BUDGET + " " +ACT_SUPPORT_MANURE );}
			}
		}
	}
	
	
	
	//7:ACT_IMPLEMENT_FALLOW
	action implement_fallow {
		if (ACT_IMPLEMENT_FALLOW in actions_done_this_year) {
			if not without_player {do tell_not_twice(ACT_IMPLEMENT_FALLOW);}
		} else {
			if budget >= token_implement_fallow {
			bool  is_ok <-without_player or confirm_action(ACT_IMPLEMENT_FALLOW, token_implement_fallow);
			if is_ok {
				if not without_player {
					player_actions[turn -1][ACT_IMPLEMENT_FALLOW] <- nil;
					if display_info_action_console{write "ACTION : " +ACT_IMPLEMENT_FALLOW;}
				
				}
				
				ask plots {
					does_implement_fallow <- true;
				}
				budget <- budget - token_implement_fallow;
				list<plot> plot_s <- plots sort_by (-1 * each.water_waste_pollution);
				float area_t <- (plot_s sum_of each.shape.area) * part_of_plots_in_fallow;
				/*float pp <- 0.0;
				loop p over: plot_s {
					loop ppp over: p.my_cells {
						pp <- pp + ppp.water_waste_level;
					}
				}
				write "pollution avant: " + pp;*/
				loop p over: plot_s {
					ask p.my_cells {
						water_waste_level <- 0.0;
					}
					area_t <- area_t - p.shape.area;
					if area_t < 0 {
						break;
					}
				}
				/* pp <- 0.0;
				loop p over: plot_s {
					loop ppp over: p.my_cells {
						pp <- pp + ppp.water_waste_level;
					}
				}
				write "pollution apres: " + pp;*/
				actions_done_total << ACT_IMPLEMENT_FALLOW;
				actions_done_this_year << ACT_IMPLEMENT_FALLOW;
				
		
				}
			}else {
				if not without_player {do tell(NOT_ENOUGH_BUDGET + " " +ACT_IMPLEMENT_FALLOW );}
			}
		
		}
	}
	
	
	//8:ACT_INSTALL_DUMPHOLES,
	action install_dumpholes {
		if (ACT_INSTALL_DUMPHOLES in actions_done_total) {
			if not without_player {do tell_not_twice(ACT_INSTALL_DUMPHOLES);}
		} else {
			
			if budget >= token_installation_dumpholes {
				bool  is_ok <- without_player or confirm_action(ACT_INSTALL_DUMPHOLES, token_installation_dumpholes);
				if is_ok {
					if not without_player {
						player_actions[turn -1][ACT_INSTALL_DUMPHOLES] <- nil;
						
						if display_info_action_console{write "ACTION : " +ACT_INSTALL_DUMPHOLES;}
					}
					actions_done_total << ACT_INSTALL_DUMPHOLES;
					actions_done_this_year<< ACT_INSTALL_DUMPHOLES; 
					budget <- budget - token_installation_dumpholes;
					ask plots {
						has_dumphole <- true;
					}
				
				}
				
			}else {
				if not without_player {do tell(NOT_ENOUGH_BUDGET + " " +ACT_INSTALL_DUMPHOLES );}
			}
		}
	}
	
	action play_predefined_actions {
		map<string,map> player_actions_turn <- player_actions[turn - 1];
		loop act over: player_actions_turn.keys {
			switch act {
				match ACT_DRAIN_DREDGE {
					do drain_dredge(player_actions_turn[act][LEVEL] = "high");
				}
				match ACT_FACILITY_TREATMENT {
					do install_facility_treatment_for_homes(player_actions_turn[act]);
				}
				match ACT_IMPLEMENT_FALLOW {
					do implement_fallow;
				}
				match ACT_INSTALL_DUMPHOLES {
					do install_dumpholes;
				}
				match ACT_PESTICIDE_REDUCTION {
					do pesticide_reducing;
				}
				match ACT_SENSIBILIZATION {
					do sensibilization;
				}
				match ACT_SUPPORT_MANURE {
					do support_manure_buying(player_actions_turn[act][LEVEL] = "high");
				}
				match ACTION_COLLECTIVE_ACTION {
					do trimestrial_collective_action(player_actions_turn[act][LEVEL] = "high");
				}
				
			}
		}
	}
	
	action ending_turn {
		if save_log {
			string to_save <- "" + turn + "," + (int(self) +1) + "," + budget +",";
			/*loop act over: actions_done_this_year  {
				to_save <- to_save+"," + act;
			}*/
			to_save <-to_save + ACT_COLLECT + ":" + last(player_collect_policy) + ",";
			to_save <- to_save + ACT_FACILITY_TREATMENT_MAINTENANCE + ":" + last(player_traitement_facility_maintenance);
			map<string, map> this_turn <- last(player_actions);
			loop act over: this_turn.keys{
				map param <- this_turn[act];
				act <- to_english[act];
				if (param = nil or empty(param)) {
					to_save <- to_save+"," + act;
				} else {
					if LEVEL in param.keys {
						to_save <- to_save+"," + act + ":" + param[LEVEL];
					} else {
						string param_str <- "(";
						loop k over: param.keys {
							param_str <- param_str + k + "%" + param[k] + ";";
						}
						param_str <- param_str + ")";
						to_save <- to_save+"," + act + ":" + param_str;
					}
					
				}
			}
			
			save to_save to: village_action_log_path type: text rewrite: false;
		}
		index_player <- index_player + 1;
		if not without_player {
			if index_player < length(village) {
				ask villages_order[index_player] {
					do start_turn;
				}
			} 
		}
	}
	//9:ACT_END_TURN,
	action end_of_turn {
		bool  is_ok <- (not confirmation_popup) or user_confirm(END_OF_TURN,PLAYER + " " + (int(self) + 1) +", " + CONFIRM_END_OF_TURN);
		if is_ok {
			do ending_turn;
		}
	}
	
	action install_fiter_maintenance {
		if (treatment_facility_year > 0) {
			if (budget >= token_install_filter_for_homes_maintenance ) {
				treatment_facility_is_activated <- (treatment_facility_year > 0) ;
				if treatment_facility_year > 0 and treatment_facility_is_activated {
					budget <- budget - token_install_filter_for_homes_maintenance;
					actions_done_this_year << PAY_TRAETMENT_FACILITY_MAINTENANCE;
					player_traitement_facility_maintenance << treatment_facility_is_activated;
					
				}
				if display_info_action_console{write "ACTION : " +PAY_TRAETMENT_FACILITY_MAINTENANCE;}
					
				if treatment_facility_is_activated {
					treatment_facility_year <- treatment_facility_year + 1;
				}
			} else {
				if not without_player {do tell(NOT_ENOUGH_BUDGET + " " +PAY_TRAETMENT_FACILITY_MAINTENANCE );}
			}
		}
		
	}
	
	action collection_team_action(bool is_strong) {
		if (not weak_collection_policy and not strong_collection_policy) {
			weak_collection_policy <- not is_strong;
			strong_collection_policy <-  is_strong;
			ultimate_collection_policy <- false;
			int collect_per_week_weak <- length(days_collects_weak);
			int collect_per_week_strong <- length(days_collects_strong);
			int cost <-  (weak_collection_policy ? token_weak_waste_collection :token_strong_waste_collection);
			if (budget >= cost ) {
				actions_done_this_year << ACT_COLLECT; 
				player_collect_policy << weak_collection_policy ? collect_per_week_weak : collect_per_week_strong  ;
				budget <- budget - cost;
				if display_info_action_console{write "ACTION : " + ACT_COLLECT + " " +(is_strong ? collect_per_week_strong : collect_per_week_weak);}
				ask collection_teams {collection_days <- myself.weak_collection_policy ? days_collects_weak : (myself.strong_collection_policy ? days_collects_strong : days_collects_ultimate);}
			}
		}
	}
	
	action start_turn {
		start_turn_time <- machine_time;
		if no_starting_actions {
			ask collection_teams {
				collection_days <- [];
			}
			treatment_facility_is_activated <- false;
			weak_collection_policy <- false;
			strong_collection_policy <- false;
			ultimate_collection_policy <- false;
		}
		if not without_player{
			player_actions << [];
			player_collect_policy << []; 
			player_traitement_facility_maintenance << [];
			ask world {do update_display;do resume;}
		}
		
		ask plots {
			use_more_manure_strong <- false;
			use_more_manure_weak <- false;
			does_implement_fallow <- false; 
		}
		if no_starting_actions {
			if not without_player{
				do tell(TURN_OF + " " + PLAYER + " " + (int(self) + 1));
			}
		} else {
			string chosen_waste_collection_freq <- "";
			int collect_per_week_weak <- length(days_collects_weak);
			int collect_per_week_strong <- length(days_collects_strong);
			int collect_per_week_ultimate <- length(days_collects_ultimate);
			if not without_player{
				do tell(TURN_OF + " " + PLAYER + " " + (int(self) + 1));
				string current_val <- "" +(weak_collection_policy ? collect_per_week_weak : (strong_collection_policy ? collect_per_week_strong : collect_per_week_ultimate)) + " " + PER_WEEK;
				map result;
				
				list<string> possibilities <- (proposed_ultimate and (budget >=  token_ultimate_waste_collection)) ? [""+collect_per_week_weak +" " + PER_WEEK,""+collect_per_week_strong +" " + PER_WEEK, ""+collect_per_week_ultimate +" " + PER_WEEK] : (budget >=  token_strong_waste_collection ? [""+collect_per_week_weak +" " + PER_WEEK,""+collect_per_week_strong +" " + PER_WEEK] : [""+collect_per_week_weak +" " + PER_WEEK]);
				if not(current_val in possibilities) {
					current_val <- first(possibilities);
				}
				if treatment_facility_year = 0 {
					result <- user_input_dialog(PLAYER +" " + (int(self) + 1)+" - " + WASTE_MANAGEMENT_POLCITY,[choose(CHOOSE_WASTE_COLLECTION_FREQ,string,current_val, possibilities)]);
				
				} else {
					result <- user_input_dialog(PLAYER +" " + (int(self) + 1)+" - " + WASTE_MANAGEMENT_POLCITY,[
						choose(CHOOSE_WASTE_COLLECTION_FREQ,string,current_val,possibilities),
						choose(WISH_PAY_TREATMENT_FACILITY_MAINTENANCE,bool,true, [true,false]) 
					]);
					treatment_facility_is_activated <- bool(result[WISH_PAY_TREATMENT_FACILITY_MAINTENANCE]);
					
				}
				chosen_waste_collection_freq <- result[CHOOSE_WASTE_COLLECTION_FREQ];
			} else {
				chosen_waste_collection_freq <- (""+ player_collect_policy[turn -1] +" " + PER_WEEK);
				treatment_facility_is_activated <- (treatment_facility_year > 0) and player_traitement_facility_maintenance[turn - 1];
			}
			if treatment_facility_year > 0 and treatment_facility_is_activated {actions_done_this_year << PAY_TRAETMENT_FACILITY_MAINTENANCE;}
			if treatment_facility_year > 0 and treatment_facility_is_activated {budget <- budget - token_install_filter_for_homes_maintenance;}
			
			if not without_player {
				player_traitement_facility_maintenance << treatment_facility_is_activated;
			}
				
			actions_done_this_year << ACT_COLLECT; 
			weak_collection_policy <- chosen_waste_collection_freq = (""+collect_per_week_weak +" " + PER_WEEK);
			strong_collection_policy <-chosen_waste_collection_freq= (""+collect_per_week_strong +" " + PER_WEEK);
			ultimate_collection_policy <- not weak_collection_policy  and not strong_collection_policy;
			if not without_player {
				player_collect_policy << weak_collection_policy ? collect_per_week_weak : (strong_collection_policy ?collect_per_week_strong : collect_per_week_ultimate ) ;
			}
			budget <- budget - (weak_collection_policy ? token_weak_waste_collection :(strong_collection_policy ? token_strong_waste_collection : token_ultimate_waste_collection));
			ask collection_teams {collection_days <- myself.weak_collection_policy ? days_collects_weak : (myself.strong_collection_policy ? days_collects_strong : days_collects_ultimate);}
			if treatment_facility_is_activated {
				treatment_facility_year <- treatment_facility_year + 1;
			}
		}
		to_refresh <- true;
		
	}
	aspect default {
		if (stage = PLAYER_ACTION_TURN) {
			if (villages_order[index_player] = self) {
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
			draw PLAYER + " " + (int(self) + 1) at: location + {0,0,10} color: #white anchor: #center font: font("Helvetica", 50, #bold);
			draw shape.contour + 20.0 color: color;
		}
	}
}