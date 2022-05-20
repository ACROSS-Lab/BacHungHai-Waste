/**
* Name: WasteManagement
* Based on the internal skeleton template. 
* Author: Patrick Taillandier
* Tags: 
*/
@no_experiment
model WasteManagement

import "Parameters.gaml"
 

global {
	
	/********************** CONSTANTS ****************************/
		
	string PLAYER_TURN <- "player turn";
	string COMPUTE_INDICATORS <-  "compute indicators";
	
	string ACT_DRAIN_DREDGE <- "Drain and dredge";
	string ACT_FACILITY_TREATMENT <- "Install water treatment facilities for every home";
	string ACT_SENSIBILIZATION <- "Organise sensibilization about waste sorting workshops in schools";
	string ACTION_COLLECTIVE_ACTION <- "Trimestrial collective action";
	string ACT_PESTICIDE_REDUCTION <- "Help farmers to reduce pesticides use";
	string ACT_SUPPORT_MANURE <- "Help farmer buy manure";
	string ACT_IMPLEMENT_FALLOW <- "Put part of the fields in fallow ";
	string ACT_INSTALL_DUMPHOLES <- "Making farmers participate in the installation of dumpholes for agricultural products";
	string ACT_END_OF_TURN <- "end of turn";
	
	string MAP_SOLID_WASTE <- "Map of solid waste";
	string MAP_WATER_WASTE <- "Map of waster waste";
	string MAP_TOTAL_WASTE <- "Map of total pollution";
	string MAP_PRODUCTIVITY <- "Map of agricultural productivity";
	
	/********************** INTERNAL VARIABLES ****************************/
	
	bool without_player <- false; //for testing
	bool display_productivity_waste <- false parameter:"Display field productivity" category: "Display" on_change: update_display;
	
	bool display_solid_waste <- false parameter:"Display solid waste" category: "Display" on_change: update_display;
	bool display_water_waste <- false parameter:"Display water waste" category: "Display" on_change: update_display;
	bool display_total_waste <- false parameter:"Display total waste" category: "Display" on_change: update_display;
	//string type_of_map_display <- MAP_SOLID_WASTE;// category: "Display" among: ["Map of solid waste", "Map of waster waste", "Map of total pollution", "Map of agricultural productivity"] parameter: "Type of map display" ;//on_change: update_display;
	string stage <-COMPUTE_INDICATORS;
	
	int index_player <- 0;
	int action_type <- -1;	
	
	bool to_refresh <- false update: false;
	
	bool pause_for_player_turn <- true;
	
	communal_landfill the_communal_landfill;
	
	string text_action <- "";
	map<string,string> actions_name <- [
		"q"::ACT_DRAIN_DREDGE,
		"w"::ACT_FACILITY_TREATMENT,
		"e"::ACT_SENSIBILIZATION,
		"r"::ACTION_COLLECTIVE_ACTION,
		"t"::ACT_PESTICIDE_REDUCTION,
		"y"::ACT_SUPPORT_MANURE,
		"u"::ACT_IMPLEMENT_FALLOW,
		"i"::ACT_INSTALL_DUMPHOLES,
		"o"::ACT_END_OF_TURN
	]; 
	
	
	int turn <- 0;
	int current_day <- 0;
	
	float village1_solid_pollution update: village[0].canals sum_of each.solid_waste_level + village[0].cells sum_of each.solid_waste_level ;
	float village1_water_pollution update: convertion_from_l_water_waste_to_kg_solid_waste * (village[0].canals sum_of each.water_waste_level + village[0].cells  sum_of each.water_waste_level)  ;
	float village2_solid_pollution update: village[1].canals sum_of each.solid_waste_level + village[1].cells sum_of each.solid_waste_level ;
	float village2_water_pollution update: convertion_from_l_water_waste_to_kg_solid_waste * (village[1].canals sum_of each.water_waste_level + village[1].cells  sum_of each.water_waste_level)  ;
	float village3_solid_pollution update: village[2].canals sum_of each.solid_waste_level + village[2].cells sum_of each.solid_waste_level ;
	float village3_water_pollution update: convertion_from_l_water_waste_to_kg_solid_waste * (village[2].canals sum_of each.water_waste_level + village[2].cells  sum_of each.water_waste_level)  ;
	float village4_solid_pollution update: village[3].canals sum_of each.solid_waste_level + village[3].cells sum_of each.solid_waste_level ;
	float village4_water_pollution update: convertion_from_l_water_waste_to_kg_solid_waste * (village[3].canals sum_of each.water_waste_level + village[3].cells  sum_of each.water_waste_level)  ;
	
	float total_solid_pollution update: village1_solid_pollution + village2_solid_pollution + village3_solid_pollution + village4_solid_pollution  ;
	float total_water_pollution update:  village1_water_pollution + village2_water_pollution + village3_water_pollution + village4_water_pollution   ;
	 
	float village1_productivity update: village[0].plots sum_of each.current_productivity / length(village[0].plots);	
	float village2_productivity update: village[1].plots sum_of each.current_productivity / length(village[1].plots);
	float village3_productivity update: village[2].plots sum_of each.current_productivity / length(village[2].plots);
	float village4_productivity update: village[3].plots sum_of each.current_productivity / length(village[3].plots);
	float total_productivity update: (village1_productivity + village2_productivity + village3_productivity + village4_productivity) / 4;
			
	
	/********************** INITIALIZATION OF THE GAME ****************************/

	init {
		create village from: villages_shape_file sort_by (location.x + location.y * 2);
		do create_canals;
		create commune from: Limites_commune_shape_file;
		do create_urban_area;
		do create_plots;
		do init_villages;	
		do create_landfill;
		loop k over: actions_name.keys {
			text_action <- text_action + k +":" + actions_name[k] + "\n"; 
		}
		
		if save_log {
			save "turn,player,productivity,solid_pollution,water_pollution"  to: systeme_evolution_log_path type: text rewrite: true;
			save "turn,player,budget,action1,action2,action3,action4,action5,action6" to: village_action_log_path type: text rewrite: true;
		}
	}
	
	
	action update_display {
		if (stage != PLAYER_TURN) {
				ask experiment {
				do update_outputs(true);
				to_refresh <- true;
			}
		}
	}
		
	
	action create_canals {
		create canal from: Hydrologie_shape_file with: (width:float(get("WIDTH")));	 
		
		graph canal_network <- directed(as_edge_graph(canal));
		ask canal {
			downtream_canals<- list<canal>(canal_network out_edges_of (canal_network target_of self));	
		}
		
		ask cell {
			using topology (world) {
				closest_canal <- canal closest_to location;
			}
		}
	}
	
	action create_urban_area {
		create urban_area from: Limites_urban_areas_shape_file;
		ask urban_area {
			list<geometry> geoms <- to_squares (shape,house_size);
			float nb <- 0.0;
			create house from: geoms {
				my_village <- first(village overlapping self);
				if my_village = nil{
					my_village <- village closest_to self;
				}
				create inhabitant {
					location <- myself.location;
					my_house <- cell(location);
					my_cells <- cell overlapping myself;
					closest_canal <- canal closest_to self;
					nb <- nb + 1;
					my_village <- myself.my_village;
				}
			}
			population <- nb;
		
		} 
		
	}
	
	action create_landfill {
		loop s over: Dumpyards_shape_file.contents {
			string type <- s get ("TYPE");
			if type = "Commune" {
				create communal_landfill with: (shape: s){
					the_communal_landfill <- self;
					ask plot overlapping self {
						ask the_farmer {
							my_village.farmers >> self;
							
							do die;
						}
						do die;
					}
				}
			} else {
				create local_landfill with:(shape:s){
					my_village <- first(village overlapping self);
					my_village.my_local_landfill <- self;
					ask plot overlapping self {
						ask the_farmer {
							my_village.farmers >> self;
							do die;
						}
						do die;
					}
				}
			}
		}
		ask village {
			plots <- plots where not dead(each);
		}
	}
	
	action create_plots {
		create plot from: Fields_shape_file {
			geometry g <- shape + tolerance_dist;
			list<canal> canals <- canal overlapping g;
			if empty(canals) {
				closest_canal <- canal closest_to self;
			} else {
				if length(canals) = 1 {closest_canal <- first(canals);}
				else {
					closest_canal <- canals with_max_of (g inter each).perimeter;
				}
				perimeter_canal_nearby <- (g inter closest_canal).perimeter;
			}
			my_cells <- cell overlapping self;
			
			the_village <- village closest_to self;
			create farmer {
				my_village <- myself.the_village;
				myself.the_farmer <- self;
				my_plot <- myself;
				closest_canal <- myself.closest_canal;
				location <- myself.location;
				my_house <- cell(location);
				my_cells <- myself.my_cells;	
			}
			the_communal_landfill <- first(communal_landfill at_distance distance_to_communal_landfill_for_pollution_impact);
			the_local_landfill <- first(local_landfill at_distance distance_to_local_landfill_for_pollution_impact);
		 	impacted_by_canal <- (self distance_to closest_canal) <= distance_to_canal_for_pollution_impact;
		}
		
	}
	
	action init_villages {
		ask village {
			plots <- plot overlapping self;
			cells <- cell overlapping self;
			canals <- canal at_distance 1.0;
			inhabitants <- (inhabitant overlapping self) ;
			farmers <- (farmer overlapping self);
			population <- length(inhabitants)  + length(farmers) ;
			
			ask urban_area overlapping self {
				my_villages << myself;
			}
			create collection_team with:(my_village:self) {
				myself.collection_teams << self;
			}
			
		} 
		village1_productivity <-  (village[0].plots sum_of each.current_productivity) / length(village[0].plots);	
		village2_productivity <-  village[1].plots sum_of each.current_productivity / length(village[1].plots);	
		village3_productivity <-  village[2].plots sum_of each.current_productivity / length(village[2].plots);	
		village4_productivity <-  village[3].plots sum_of each.current_productivity / length(village[3].plots);	
		total_productivity <- (village1_productivity + village2_productivity + village3_productivity + village4_productivity) / 4.0;	
	
	}
	action activate_act1 {
		if stage = PLAYER_TURN {
			ask village[index_player] {do drain_dredge;}
		}
	}
	action activate_act2 {
		if stage = PLAYER_TURN {
			ask village[index_player] {do install_facility_treatment_for_homes;}
		}
	}
	action activate_act3 {
		if stage = PLAYER_TURN {
			ask village[index_player] {do sensibilization;}
		}
	}
	action activate_act4 {
		if stage = PLAYER_TURN {
			ask village[index_player] {do trimestrial_collective_action;}
		}
	}
	action activate_act5 {
		if stage = PLAYER_TURN {
			ask village[index_player] {do pesticide_reducing;}
		}
	}
	action activate_act6 {
		if stage = PLAYER_TURN {
			ask village[index_player] {do support_manure_buying;}
		}
			
	}
	action activate_act7 {
		if stage = PLAYER_TURN {
			ask village[index_player] {do implement_fallow;}
		}
	}
	action activate_act8 {
		if stage = PLAYER_TURN {
			ask village[index_player] {do install_gumpholes;}
		}
	}
	action activate_act9 {
		if stage = PLAYER_TURN {
			ask village[index_player] {do end_of_turn;}
		}
	}
	
	
	action act_management {
		switch action_type {
			match 2 {ask village[index_player] {do end_of_turn;}}
		}
	}
	
	action manage_flow_canal {
		ask canal {
			do init_flow;
		}
		ask canal {
			do flow;
		}
		ask canal {
			do update_waste;
		}	
	}
	
	action manage_individual_pollution {
		ask village {
			list<float> typical_values_inhabitants <- first(inhabitants).typical_values_computation();
			list<float> typical_values_farmers <- first(farmers).typical_values_computation();
			float s_to_c <- typical_values_inhabitants[0];
			float s_to_g <- typical_values_inhabitants[1];
			float w_to_c <- typical_values_inhabitants[2];
			float w_to_g <- typical_values_inhabitants[3];
			ask inhabitants{
				do domestic_waste_production(s_to_c,s_to_g,w_to_c,w_to_g);
			}
			s_to_c <- typical_values_farmers[0];
			s_to_g <- typical_values_farmers[1];
			w_to_c <- typical_values_farmers[2];
			w_to_g <- typical_values_farmers[3];
			
			ask farmers{
				do domestic_waste_production(s_to_c,s_to_g,w_to_c,w_to_g);
			}
		}
		ask plot {
			do pollution_due_to_practice;
		}
	}
	
	action manage_daily_indicator {
		ask plot {
			do compute_productivity;
		}
		
		ask village {do compute_indicators;}
	}
	
	action manage_landfill {
		ask local_landfill {
			do transfert_waste_to_communal_level;
		}
		ask communal_landfill {
			do manage_waste;
		}
	}
	
	action manage_end_of_indicator_computation {
		if (current_day = 365) {
			stage <- PLAYER_TURN;
			index_player <- 0;
			step <- 0.000000000001;
			ask village {
				budget <- budget_year_per_village;
			}
			ask village {
				actions_done_this_year <- [];
				is_drained <- false;
			}
			turn <- turn + 1;
			if turn > end_of_game {
				do pause;
			}
			else if not without_player {
				if pause_for_player_turn{do pause;}
			
				do tell("PLAYER TURN");
				ask village[0] {do start_turn;}
			}
			if save_log {
				save ("" + turn  + ",0," + total_productivity + ","+ total_solid_pollution + "," + total_water_pollution)  to: systeme_evolution_log_path type: text rewrite: false;
				save ("" + turn  + ",1," + village1_productivity + ","+ village1_solid_pollution + "," + village1_water_pollution)  to: systeme_evolution_log_path type: text rewrite: false;
				save ("" + turn  + ",2," + village2_productivity + ","+ village2_solid_pollution + "," + village2_water_pollution)  to: systeme_evolution_log_path type: text rewrite: false;
				save ("" + turn  + ",3," + village3_productivity + ","+ village3_solid_pollution + "," + village3_water_pollution)  to: systeme_evolution_log_path type: text rewrite: false;
				save ("" + turn  + ",4," + village4_productivity + ","+ village4_solid_pollution + "," + village4_water_pollution)  to: systeme_evolution_log_path type: text rewrite: false;
				
				
			}
		
			
		}
	}
	
	action manage_pollution_decrease {
		ask cell {
			do natural_pollution_reduction;
		}
		
		ask village {
			int d <- (current_day mod 7) + 1;
			ask collection_teams {
				if (d in collection_days) {
					list<cell> cells_to_clean <-  myself.cells where (each.solid_waste_level > 0);
					do collect_waste(cells_to_clean);
				}
			}
		}
	}
	
	action increase_urban_area {
		using topology(world) {
			ask urban_area {
				list<plot> neighbors_plot <- plot at_distance 0.1;
				if not empty(neighbors_plot) {
					float target_pop <- population *(1 + min_increase_urban_area_population_year);
					loop while: not empty(neighbors_plot) and population <target_pop {
						plot p <- one_of(neighbors_plot);
						p >> neighbors_plot;
						if (dead(p)) {break;}
						geometry shape_plot <- copy(p.shape);
						ask my_villages {farmers >> p.the_farmer; plots >> p;}
						shape <- shape + shape_plot;
						ask p.the_farmer {do die;}
						ask p {do die;}
						list<geometry> geoms <- to_squares (p,house_size);
						create house from: geoms {
							inhabitant_to_create <- true;
							create_inhabitant_day <- rnd(2,363);
							my_village <- first(village overlapping self);
							if my_village = nil{
								my_village <- village closest_to self;
							}
						}
						population <- population - 1 ;
						
					}
				}
			}
			
		}
		ask village {
			plots <- plots where not dead(each);
		}
	}
	
	reflex indicators_computation when: stage = COMPUTE_INDICATORS {
		do manage_individual_pollution;
		do manage_flow_canal;
		do manage_pollution_decrease;
		do manage_landfill;
		do manage_daily_indicator;
		do manage_end_of_indicator_computation;
		current_day <- current_day + 1;
		
		
	}
	
	reflex playerturn when: stage = PLAYER_TURN{
		if without_player or index_player >= length(village) {
			stage <- COMPUTE_INDICATORS;
			current_day <- 0;
			step <- #day;
			
			if not without_player {do tell("INDICATOR COMPUTATION");}
			do increase_urban_area;
		}
	}
	

}


grid cell height: 50 width: 50 {
	float solid_waste_level <- 0.0 min: 0.0;
	float water_waste_level <- 0.0 min: 0.0;
	float pollution_level <- 0.0;
	canal closest_canal;
	
	action natural_pollution_reduction {
		if solid_waste_level > 0 {
			solid_waste_level <- solid_waste_level * (1 - ground_solid_pollution_reducing_day);
		}
		if water_waste_level > 0 {
			water_waste_level <- water_waste_level * (1 - ground_water_pollution_reducing_day);
			float to_canal <- water_waste_level * part_of_water_waste_pollution_to_canal;
			closest_canal.water_waste_level <- closest_canal.water_waste_level + to_canal;
			water_waste_level <- water_waste_level - to_canal;
		}
	}
	 
	aspect default {
	 	if (display_total_waste) {
			float pollution_level_display <- solid_waste_level + convertion_from_l_water_waste_to_kg_solid_waste / coeff_cell_pollution_display;
			if pollution_level_display >= min_display_waste_value  {
				draw shape color: blend(#red,#blue,pollution_level_display);
			}
		} else if (display_water_waste) {
			float pollution_level_display <- water_waste_level * convertion_from_l_water_waste_to_kg_solid_waste / coeff_cell_pollution_display;
			if pollution_level_display >= min_display_waste_value  {
				draw shape color: blend(#red,#blue,pollution_level_display);
			}
			
		} else if (display_solid_waste) {
			float pollution_level_display <- solid_waste_level ;
			if pollution_level_display >= min_display_waste_value  {
				draw shape color: blend(#red,#blue,pollution_level_display);
			}
		}
	}
	
}

species village {
	rgb color <- village_color[int(self)];
	list<string> actions_done_this_year;
	list<string> actions_done_total;
	list<cell> cells;
	list<canal> canals;
	list<inhabitant> inhabitants;
	list<farmer> farmers;
	local_landfill my_local_landfill;
	float budget;
	float solid_pollution_level ;
	float water_pollution_level;
	float productivity_level min: 0.0;
	list<collection_team> collection_teams;
	float bonus_agricultural_production;
	list<plot> plots;
	int population;
	bool is_drained <- false;
	bool weak_collection_policy <- true;
	int treatment_facility_year <- 0 max: 3;
	bool treatment_facility_is_activated <- false;
	action compute_indicators {
		solid_pollution_level <- ((cells sum_of each.solid_waste_level) + (canals sum_of (each.solid_waste_level))) / 10000.0;
		water_pollution_level <- ((cells sum_of each.water_waste_level) + (canals sum_of (each.water_waste_level)))/ 10000.0;
		plots <- plots where not dead(each);
		productivity_level <- (plots sum_of each.current_productivity) / length(plots) / 100.0;
	}

	
	
	//1:ACT_DRAIN_DREDGE
	action drain_dredge {
		if (ACT_DRAIN_DREDGE in actions_done_this_year) {
			do tell("Action " +ACT_DRAIN_DREDGE + " cannot be done twice" );
		} else {
			if budget >= token_drain_dredge {
				bool  is_ok <- user_confirm("Action Drain & Dredge","PLAYER " + (index_player + 1) +", do you confirm that you want to " + ACT_DRAIN_DREDGE +  " (Cost: " +  token_drain_dredge +" tokens)?");
				if is_ok {
					actions_done_total << ACT_DRAIN_DREDGE;
					actions_done_this_year << ACT_DRAIN_DREDGE;
					is_drained <- true;
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
				float max_budget_p1 <- village[0].budget;
				float max_budget_p2 <- village[1].budget -  (index_player < 1 ? token_weak_waste_collection : 0.0);
				float max_budget_p3 <- village[2].budget -  (index_player < 2 ? token_weak_waste_collection : 0.0);
				float max_budget_p4 <- village[3].budget -  (index_player < 3 ? token_weak_waste_collection : 0.0);
				string p1_str <- "Player 1 (max budget: " + max_budget_p1 + ")";
				string p2_str <- "Player 2 (max budget: " + max_budget_p2 + ")";
				string p3_str <- "Player 3 (max budget: " + max_budget_p3 + ")";
				string p4_str <- "Player 4 (max budget: " + max_budget_p4 + ")";
				map results <- user_input_dialog("Install falicity treatment for urban areas. Cost: " +token_install_filter_for_homes_construction +" tokens. Number of tokens payed by each player",[enter(p1_str,int,0),enter(p2_str,int,0),enter(p3_str,int,0),enter(p4_str,int,0)]);
				float p1 <- min(int(results[p1_str]), max_budget_p1);
				float p2 <- min(int(results[p2_str]), max_budget_p2);
				float p3 <- min(int(results[p3_str]), max_budget_p3);
				float p4 <- min(int(results[p4_str]), max_budget_p4);
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
						
						list<float> ps <- [p1,p2,p3,p4];	
						if (p1 + p2 + p3 + p4) > token_install_filter_for_homes_construction {
							float to_remove <- token_install_filter_for_homes_construction - (p1 + p2 + p3 + p4) ;
							loop while: to_remove > 0 and (p1 + p2 + p3 + p4) > 0{
								int i <- rnd(3);
								float c <- min(1.0, to_remove, ps[i] );
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
					
					ask inhabitants {
						environmental_sensibility <- environmental_sensibility+ 1;
					}
				}
			}else {
				do tell("Not enough budget for " +ACT_SENSIBILIZATION );
			}
		}
	}
	
	//4:ACTION_COLLECTIVE_ACTION
	action trimestrial_collective_action {
		if (ACTION_COLLECTIVE_ACTION in actions_done_this_year) {
			do tell("Action " +ACTION_COLLECTIVE_ACTION + " cannot be done twice" );
		} else {
			if budget >= token_trimestrial_collective_action {
				bool  is_ok <- user_confirm("Action trimestrial action","PLAYER " + (index_player + 1) +", do you confirm that you want to " + ACTION_COLLECTIVE_ACTION + " (Cost: " +  token_trimestrial_collective_action +" tokens)?");
				if is_ok {
					actions_done_total << ACTION_COLLECTIVE_ACTION;
					actions_done_this_year << ACTION_COLLECTIVE_ACTION;
			
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
	action support_manure_buying {
		if (ACT_SUPPORT_MANURE in actions_done_this_year) {
			do tell("Action " +ACT_SUPPORT_MANURE + " cannot be done twice" );
		} else {
			if budget >= token_support_manure_buying {
				bool  is_ok <- user_confirm("Action Support Mature","PLAYER " + (index_player + 1) +", do you confirm that you want to " + ACT_SUPPORT_MANURE + " (Cost: " +  token_support_manure_buying +" tokens)?");
				if is_ok {
					actions_done_total << ACT_SUPPORT_MANURE;
					actions_done_this_year << ACT_SUPPORT_MANURE;
					budget <- budget - token_support_manure_buying;
					ask plots {
						use_more_manure <- true;
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
					ask farmers {
						has_dumphole <- true;
					}
				}
				
			}else {
				do tell("Not enough budget for " +ACT_INSTALL_DUMPHOLES );
			}
		}
	}
	
	//9:ACT_END_TURN,
	action end_of_turn {
		bool  is_ok <- user_confirm("End of turn","PLAYER " + (index_player + 1) +", do you confirm that you want to end the turn?");
		if is_ok {
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
			} else if pause_for_player_turn{ask world {do resume;}}
			
			
		}
	}
	
	action start_turn {
		do tell("PLAYER " + (index_player + 1) + " TURN");
		ask plots {
			use_more_manure <- false;
			does_implement_fallow <- false;
		}
		int collect_per_week_weak <- length(days_collects_weak);
		int collect_per_week_strong <- length(days_collects_strong);
		string current_val <- "" +(weak_collection_policy ? collect_per_week_weak : collect_per_week_strong) + " per week";
		map result;
		
		list<string> possibilities <- budget >=  token_strong_waste_collection ? [""+collect_per_week_weak +" per week",""+collect_per_week_strong +" per week"] : [""+collect_per_week_weak +" per week"];
		if not(current_val in possibilities) {
			current_val <- first(possibilities);
		}
		if treatment_facility_year = 0 {
			result <- user_input_dialog("PLAYER " + (index_player + 1)+" - Waste management policy",[choose("Choose a waste collection frenquency",string,current_val, possibilities)]);
		
		} else {
			result <- user_input_dialog("PLAYER " + (index_player + 1)+" - Waste management policy",[
				choose("Choose a waste collection frenquency",string,current_val, [""+collect_per_week_weak +" per week",""+collect_per_week_strong +" per week"]),
				choose("Do you wish to pay for the home treatment facility?",bool,true, [true,false])
			]);
			treatment_facility_is_activated <- bool(result["Do you wish to pay for the home treatment facility?"]);
			if true {actions_done_this_year <<  "Pay for treatment facility maintenance";}
		
			if treatment_facility_is_activated {budget <- budget - token_install_filter_for_homes_maintenance;}
		
		}
		actions_done_this_year << result["Choose a waste collection frenquency"] ;
		weak_collection_policy <- result["Choose a waste collection frenquency"] = ""+collect_per_week_weak +" per week";
		budget <- budget - (weak_collection_policy ? token_weak_waste_collection : token_strong_waste_collection);
		ask collection_teams {collection_days <- myself.weak_collection_policy ? days_collects_weak : days_collects_strong;}
		if treatment_facility_is_activated {
			treatment_facility_year <- treatment_facility_year + 1;
		}
		to_refresh <- true;
	}
	aspect default {
		if (stage = PLAYER_TURN) {
			if (index_player = int(self)) {
				draw shape color: color;
			}
		} else {
			
			draw shape.contour + 20.0 color: #black;
		}
	}
}

species plot {
	village the_village;
	float base_productivity <- field_initial_productivity min: 0.0;
	bool does_reduce_pesticide <- false;
	float current_productivity <- field_initial_productivity min: 0.0;
	float pratice_water_pollution_level;
	float part_to_canal_of_pollution;
	canal closest_canal;
	farmer the_farmer;
	list<cell> my_cells;
	communal_landfill the_communal_landfill;
	local_landfill the_local_landfill;
	bool impacted_by_canal <- false;
	float perimeter_canal_nearby;
	rgb color<-#darkgreen-25;
	bool use_more_manure <- false;
	bool does_implement_fallow <- false;
	
	action pollution_due_to_practice { 
		
		if use_more_manure {
			pratice_water_pollution_level <- pratice_water_pollution_level * (1 + impact_support_manure_buying_waste);
		}
		if does_reduce_pesticide {
			pratice_water_pollution_level <- pratice_water_pollution_level * (1 - impact_pesticide_reducing_waste);
		}
		if pratice_water_pollution_level > 0 {
			float to_the_canal <- pratice_water_pollution_level * part_to_canal_of_pollution;
			float to_the_ground <- pratice_water_pollution_level - to_the_canal;
			if to_the_canal > 0 {
				closest_canal.water_waste_level <- closest_canal.water_waste_level + to_the_canal;
			}
			if to_the_ground > 0 {
				ask my_cells {
					water_waste_level <- water_waste_level + to_the_ground  ;
				}
			}
		}
		
	}
	

	action compute_productivity {
		current_productivity <- base_productivity;
		if does_implement_fallow {
			current_productivity <- current_productivity * (1 - impact_implement_fallow_production);
		}
		if use_more_manure {
			current_productivity <- current_productivity * (1 + impact_support_manure_buying_production);
		}
		if does_reduce_pesticide {current_productivity <- current_productivity* (1 - impact_pesticide_reducing_production);}
		if the_village.is_drained {
			current_productivity <- current_productivity * (1 + impact_drain_dredge_agriculture);
		}
		if (the_local_landfill != nil) {
			current_productivity <- current_productivity - the_local_landfill.waste_quantity * local_landfill_waste_pollution_impact_rate;
		}
		if (the_communal_landfill != nil) {
			current_productivity <- current_productivity - the_communal_landfill.waste_quantity * communal_landfill_waste_pollution_impact_rate;
		}
		float solid_ground_pollution <- my_cells sum_of each.solid_waste_level;
		if (solid_ground_pollution > 0) {
			current_productivity <- current_productivity - solid_ground_pollution * ground_solid_waste_pollution_impact_rate;
		}
		float water_ground_pollution <- my_cells sum_of each.water_waste_level;
		if (solid_ground_pollution > 0) {
			current_productivity <- current_productivity - water_ground_pollution * ground_water_waste_pollution_impact_rate;
		}
		if impacted_by_canal {
			current_productivity <- current_productivity - closest_canal.solid_waste_level * canal_solid_waste_pollution_impact_rate; 
			current_productivity <- current_productivity - closest_canal.water_waste_level * canal_water_waste_pollution_impact_rate; 
		}
	}
	
	aspect default {
		if display_productivity_waste {
			draw shape  color:  blend(#blue,#white,current_productivity / coeff_visu_productivity);
		}
		else {
			draw shape color: color border: #black;
		}
		
	}
}

species urban_area {
	float population;
	list<village> my_villages;
}
species house {
	bool inhabitant_to_create <- false;
	int create_inhabitant_day <- -1;
	rgb color<-#darkslategray;
	village my_village;
	
	reflex new_inhabitants when: inhabitant_to_create and create_inhabitant_day = current_day{
		do create_inhabitants;
		inhabitant_to_create <- false;
	}
	action create_inhabitants {
		create inhabitant {
			location <- myself.location;
			my_village <- myself.my_village;
			
			my_house <- cell(location);
			my_cells <- cell overlapping myself;
			my_village.inhabitants << self;
			closest_canal <- canal closest_to self;
			my_village.population <- my_village.population  + 1;
		}
	}
	aspect default {
		draw shape color: color border: #black;
	}
}
species canal {
	float width;
	float solid_waste_level min: 0.0;
	float water_waste_level min: 0.0;
	float solid_waste_level_tmp;
	float water_waste_level_tmp;
	list<canal> downtream_canals;
	
	
	action init_flow {
		solid_waste_level_tmp <- 0.0;
		water_waste_level_tmp <- 0.0;
	}
	action flow {
		
		float to_diffuse_solid <-  solid_waste_level / shape.perimeter  * rate_diffusion_solid_waste  ; 
		float to_diffuse_water <-  water_waste_level / shape.perimeter  * rate_diffusion_liquid_waste ; 
		
		int nb <- length(downtream_canals);
		if nb > 0 {
			ask downtream_canals {
				solid_waste_level_tmp <- solid_waste_level_tmp + to_diffuse_solid/ nb;
				water_waste_level_tmp <- water_waste_level_tmp +to_diffuse_water  / nb;
			}
		}
		solid_waste_level_tmp <- solid_waste_level_tmp - to_diffuse_solid ;
		water_waste_level_tmp <-  water_waste_level_tmp - to_diffuse_water;
	}
	action update_waste {
		solid_waste_level <- solid_waste_level + solid_waste_level_tmp;
		water_waste_level <- water_waste_level + water_waste_level_tmp ;
	}
	aspect default {
		if display_total_waste {
			draw shape  + (width +3) color: blend(#red,#blue,(solid_waste_level + convertion_from_l_water_waste_to_kg_solid_waste *water_waste_level)/shape.perimeter / coeff_visu_canal);
		} else if display_solid_waste {
			draw shape  + (width +3) color: blend(#red,#blue,(solid_waste_level)/shape.perimeter / coeff_visu_canal);
		} else if display_solid_waste {
			draw shape  + (width +3) color: blend(#red,#blue,(water_waste_level * convertion_from_l_water_waste_to_kg_solid_waste)/shape.perimeter / coeff_visu_canal);
		} else {
			draw shape  + (width +3) color: #blue;
		}
	}
}

species commune {
	rgb color <- #black;
	aspect default {
		draw shape color: color;
	}
}

species local_landfill {
	village my_village;
	float waste_quantity;
	
	aspect default {
		draw shape depth: waste_quantity / 100.0 border: #blue color: #red;
	}
		
	action transfert_waste_to_communal_level {
		if waste_quantity > 0 {
			float to_transfert <- min(quantity_from_local_to_communal_landfill, waste_quantity);
			the_communal_landfill.waste_quantity <- the_communal_landfill.waste_quantity + to_transfert;
			waste_quantity <- waste_quantity - to_transfert;
		}
		
	}
}

species communal_landfill {
	float waste_quantity min: 0.0;
	
	aspect default {
		draw  shape depth: waste_quantity / 100.0 border: #blue color: #red;
	}
	
	action manage_waste {
		if waste_quantity > 0 {
			waste_quantity <- waste_quantity - quantity_communal_landfill_to_treatment;
		}
		
	}
}

species farmer parent: inhabitant {
	rgb color <- #orange;
	float max_agricultural_waste_production <- rnd(1.0, 3.0);
	float solid_waste_day <-  solid_waste_year_farmers / 365;
	float water_waste_day <-  water_waste_year_farmers / 365;
	float part_solid_waste_canal <- part_solid_waste_canal_farmers;
	float part_water_waste_canal <- part_water_waste_canal_farmers;
	bool has_dumphole <- false;
	plot my_plot;
	float waste_for_a_day {
		return has_dumphole ? (solid_waste_day * (1 - impact_installation_dumpholes)): solid_waste_day;
	}
}
species inhabitant { 
	rgb color <- #midnightblue;
	cell my_house;
	canal closest_canal;
	float water_filtering <-water_waste_filtering_inhabitants;
	float solid_waste_day <-  solid_waste_year_inhabitants / 365;
	float water_waste_day <-  water_waste_year_inhabitants / 365;
	float part_solid_waste_canal <- part_solid_waste_canal_inhabitants;
	float part_water_waste_canal <- part_water_waste_canal_inhabitants;
	list<cell> my_cells;
	village my_village;
	float environmental_sensibility <- 0.0;
	aspect default {
		draw circle(10.0) color: color border:color-25;
	}
	
	float waste_for_a_day {
		return solid_waste_day;
	}
	action domestic_waste_production (float solid_waste_canal, float solid_waste_ground, float water_waste_canal, float water_waste_ground) {
		if solid_waste_canal > 0 {
				closest_canal.solid_waste_level <- closest_canal.solid_waste_level + solid_waste_canal;
			}
		if solid_waste_ground > 0 {
			ask one_of(my_cells) {
				solid_waste_level <- solid_waste_level + solid_waste_ground ;
			}
		}
		if water_waste_canal > 0 {
			closest_canal.water_waste_level <- closest_canal.water_waste_level + water_waste_canal;
		}
		if water_waste_ground > 0 {
			ask one_of(my_cells) {
				water_waste_level <- water_waste_level + water_waste_ground ;
			}
		}
		
	}
	list<float> typical_values_computation {
		list<float> typical_values;
	
		float solid_waste_day_tmp <- waste_for_a_day();
		
		if (environmental_sensibility > 0) {
			solid_waste_day_tmp <- solid_waste_day_tmp * ( 1 - world.sensibilisation_function(environmental_sensibility));
		}
			
		if solid_waste_day_tmp > 0 {
			float to_the_canal <- solid_waste_day_tmp * part_solid_waste_canal;
			typical_values<< to_the_canal;
			typical_values<< solid_waste_day_tmp - to_the_canal;
		}
		
		float rate_decrease_due_to_treatment <- 0.0;
		if (my_village != nil and  my_village.treatment_facility_is_activated) {
			rate_decrease_due_to_treatment <- treatment_facility_decrease[my_village.treatment_facility_year - 1];
		} 
		
		if water_waste_day > 0 {
			float w <- (1 - water_filtering) * water_waste_day;
			float to_the_canal <- w * part_water_waste_canal ;
			typical_values << to_the_canal * (1 - rate_decrease_due_to_treatment);
			typical_values << w - to_the_canal; 
			
		}
		return typical_values;
			
	}
}

species collection_team {
	rgb color <- #gold;
	float collection_capacity <- collection_team_collection_capacity_day;
	list<int> collection_days <- days_collects_weak;
	village my_village;
	
	
	action collect_waste(list<cell> cells_to_clean) {
		float waste_collected <- 0.0;
		loop while: waste_collected < collection_capacity  {
			if empty(cells_to_clean) {
				break;
			}
			else {
				cell the_cell <- first(cells_to_clean);
				cells_to_clean >> the_cell;
				ask the_cell{
					float w <- min(myself.collection_capacity - waste_collected, solid_waste_level);
					waste_collected <- waste_collected + w;
					solid_waste_level <- solid_waste_level  - w;
				}
			}
		}
		ask my_village.my_local_landfill {
			waste_quantity <- waste_quantity + waste_collected;
		}
	}
}
