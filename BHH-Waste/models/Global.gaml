/**
* Name: WasteManagement
* Based on the internal skeleton template. 
* Author: Patrick Taillandier
* Tags: 
*/
@no_experiment
model WasteManagement

import "Constants.gaml"

import "Entities/Commune.gaml"
 
import "Entities/Pollution Cell.gaml"

import "Entities/Collection Team.gaml" 

import "Entities/Landfill.gaml"

import "Entities/Hydrology.gaml"

import "Entities/People.gaml"

import "Entities/Agricultural Space.gaml"

import "Entities/Urban Space.gaml" 

import "Entities/Village.gaml" 

import "Parameters.gaml"
 

global {
	
	
	/********************** INTERNAL VARIABLES ****************************/
	list<village> villages_order;
	bool without_player <- false; //for testing
	bool without_actions <- false;
	file players_actions_to_load <- nil;
	list<list<map<string,map>>> players_actions <- nil;
	list<list<int>> players_collect_policy <- nil;
	list<list<bool>> players_traitement_facility_maintenance <- nil;
	list<village> village_ordered_by_production;
	list<village> village_ordered_by_pollution;
	
	bool create_facility_treatment <- false;
	
	bool display_productivity_waste <- false parameter:"Display field productivity" category: "Display" ;
	
	bool display_solid_waste <- false parameter:"Display solid waste" category: "Display" ;
	bool display_water_waste <- false parameter:"Display water waste" category: "Display" ;
	bool display_total_waste <- false parameter:"Display total waste" category: "Display" ;
	bool display_water_flow <- true;
	bool draw_territory <- false;
	bool extra_turn <- false;
	
//	map<string,string> to_english;
//	map<string,string> from_english;
	
	
	//string type_of_map_display <- MAP_SOLID_WASTE;// category: "Display" among: ["Map of solid waste", "Map of waster waste", "Map of total pollution", "Map of agricultural productivity"] parameter: "Type of map display" ;//on_change: update_display;
	string stage <-COMPUTE_INDICATORS;
	int commune_money <- 0;
	int index_player <- 0;
	int action_type <- -1;	
	
	bool commune_budget_dispatch <- false;
	bool to_refresh <- false update: false;
	int remaining_time min: 0;
	float start_discussion_turn_time;
	
	communal_landfill the_communal_landfill;
	
	string text_action <- "";
	map<string,string> actions_name ;
	
	
	int turn <- 0;
	int current_day <- 0;
	int days_with_ecolabel <- 0;
	list<int> days_with_ecolabel_year <- [0];
	
	
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
	
	 
	float village1_production update: village[0].plots sum_of each.current_production ;	
	float village2_production update: village[1].plots sum_of each.current_production ;
	float village3_production update: village[2].plots sum_of each.current_production ;
	float village4_production update: village[3].plots sum_of each.current_production ;
	float total_production update: (village1_production + village2_production + village3_production + village4_production) ;
	
	list<float> village_solid_pollution <- [0.0, 0.0,0.0,0.0] update:[village1_solid_pollution,village2_solid_pollution,village3_solid_pollution,village4_solid_pollution] ;
	list<float> village_water_pollution <- [0.0, 0.0,0.0,0.0] update:[village1_water_pollution,village2_water_pollution,village3_water_pollution,village4_water_pollution] ;
	list<float> village_production <- [0.0, 0.0,0.0,0.0] update:[village1_production,village2_production,village3_production,village4_production] ;
	
	list<int> time_step;
	list<float> village1_solid_pollution_values;
	list<float> village2_solid_pollution_values;
	list<float> village3_solid_pollution_values;
	list<float> village4_solid_pollution_values;
	list<float> village1_water_pollution_values;
	list<float> village2_water_pollution_values;
	list<float> village3_water_pollution_values;
	list<float> village4_water_pollution_values;
	list<float> village1_production_values;
	list<float> village2_production_values;
	list<float> village3_production_values;
	list<float> village4_production_values;
	list<float> total_solid_pollution_values;
	list<float> total_water_pollution_values;
	list<float> total_pollution_values;
	list<float> total_production_values;
	list<float> ecolabel_max_pollution_values;
	list<float> ecolabel_min_production_values;
	
	bool is_production_ok <- true;
	bool is_pollution_ok <- true;
	/********************** INITIALIZATION OF THE GAME ****************************/

	init {
		if not without_player or (players_actions_to_load != nil){do load_language;}
		do generate_info_action;
		name <- GAME_NAME;
		create village from: villages_shape_file sort_by (location.x + location.y * 2);
		//if without_player and  (players_actions_to_load != nil) {do load_actions_file;}
		
		do create_canals;
		create commune from: Limites_commune_shape_file;
		do create_urban_area;
		do create_plots;
		do init_villages;	
		
		do create_landfill;
		do add_data;
		loop k over: actions_name.keys {
			text_action <- text_action + k +":" + actions_name[k] + "\n"; 
		}
		
		if save_log {
			save "turn,player,productivity,solid_pollution,water_pollution,days_with_ecolabel"  to: systeme_evolution_log_path format: text rewrite: true;
			save "turn,player,budget,exra_turn,action" to: village_action_log_path format: text rewrite: true;
		}
	}
	action generate_info_action {
		actions_name <- [
		"q"::ACT_DRAIN_DREDGE,
		"w"::ACT_FACILITY_TREATMENT,
		"e"::ACT_SENSIBILIZATION,
		"r"::ACT_COLLECTIVE_ACTION,
		"t"::ACT_PESTICIDE_REDUCTION,
		"y"::ACT_SUPPORT_MANURE,
		"u"::ACT_IMPLEMENT_FALLOW,
		"i"::ACT_INSTALL_DUMPHOLES,
		"o"::ACT_END_OF_TURN
	]; 
	
//	actions_name_short<- [A_DUMPHOLES::ACT_INSTALL_DUMPHOLES, A_PESTICIDES::ACT_PESTICIDE_REDUCTION, A_SENSIBILIZATION::ACT_SENSIBILIZATION, A_FILTERS::ACT_FACILITY_TREATMENT, A_COLLECTIVE_HIGH::ACTION_COLLECTIVE_ACTION, A_COLLECTIVE_LOW::ACTION_COLLECTIVE_ACTION, 
// 		A_DRAIN_DREDGES_HIGH::ACT_DRAIN_DREDGE, A_DRAIN_DREDGES_LOW::ACT_DRAIN_DREDGE, A_FALLOW::ACT_IMPLEMENT_FALLOW, A_MATURES_HIGH::ACT_SUPPORT_MANURE, A_MATURES_LOW::ACT_SUPPORT_MANURE, A_FILTER_MAINTENANCE::ACT_FACILITY_TREATMENT_MAINTENANCE, A_COLLECTION_LOW::ACT_COLLECT, A_COLLECTION_HIGH::ACT_COLLECT, A_END_TURN::ACT_END_OF_TURN
// 	];
	}
	
	action before_start_turn{}
	
	action load_language {
		matrix mat <- matrix(translation_game_csv_file);
		int index_english <- max(1, (mat row_at 0) index_of ("English"));
		int index_col <- max(1, (mat row_at 0) index_of (langage));
		
		loop i from: 1 to: mat.rows -1 {
			string word_tlan <- mat[index_col,i];
			string word_eng <- mat[index_english,i];
			shape.attributes[mat[0,i]] <- mat[index_col,i];
		//	to_english[word_tlan] <-word_eng; 
		//	from_english[word_eng] <-word_tlan; 
		}
	}
	
	/*action load_actions_file {
		matrix mat <- matrix(players_actions_to_load);
		end_of_game <- 0;
		loop j from: 0 to: mat.rows - 1 {
			int t <- int(mat[0,j]) - 1;
			end_of_game <- max(end_of_game, t+1);
			int player_index <- int(mat[1,j]) - 1;
			ask village[player_index] {
				if length(player_actions) <= t {
					if player_actions = nil or empty(player_actions) {
						player_actions <- [];
						//player_traitement_facility_maintenance <- [];
					}
					
					loop times: t - length(player_actions) +1  {
						player_actions << [];
						//player_traitement_facility_maintenance << true;
					}
				}
				loop i from: 3 to: mat.columns -1 {
					string act_str <- mat[i,j];
					
					if act_str != nil and (":" in act_str) {
						list<string> a_s <- act_str split_with ":";
						string act_name <- a_s[0];
						string param <- a_s[1];
						if act_name = ACT_FACILITY_TREATMENT_MAINTENANCE {
							//player_traitement_facility_maintenance[t] <- bool(param);
						} else {
							act_name <- from_id[act_name];
							if act_name != ACT_FACILITY_TREATMENT {
								player_actions[t][act_name] <- [LEVEL::param];
							} else {
								map<string,int> val_p <- [];
								list<string> p_v <- param split_with ";";
								loop v over: p_v {
									if not empty(v) and ("%" in v) {
										list<string> vv <- v split_with "%";
										
										val_p[vv[0]] <- int(vv[1]);
									}
								}
								player_actions[t][act_name] <- val_p;
							}
						}
					} else {
						player_actions[t][from_id[act_str]] <- nil;
					}
				}
			}
				
		}
		
		
	}*/
	
	action update_display {
		if (stage = PLAYER_ACTION_TURN) {
				ask experiment {
				do update_outputs(true);
				to_refresh <- true;
			}
		}
	}
	
	action before_discussion_phase{} //Can be implemented in children
		
	
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
			geometry_history << shape;
			my_cells <- cell overlapping self;
			list<geometry> geoms <- to_squares (shape,house_size);
			int nb <- 0;
			village v <- first(village overlapping location);
			if v = nil{
				v <- village closest_to location;
			}
				
			v.urban_areas << self;
				
			create house from: geoms {
				myself.houses << self;
				my_village <- v;
				create inhabitant {
					location <- myself.location;
					my_house <- cell(location);
					my_cells <- cell overlapping myself;
					closest_canal <- canal closest_to self;
					nb <- nb + 1;
					my_village <- v;
				}
			}
			population <- nb;
		
		} 
		
	}
	
	action manage_landfill_geom(geometry geom_landfill) {
		ask plot overlapping geom_landfill {
			geometry geom <- clean(shape - (geom_landfill + 5.0));
			if geom = nil or geom.area = 0 {
				ask the_farmer {
					my_village.farmers >> self;
					do die;
				}
				do die;
			} else {
				shape <- geom;
				
				the_farmer.location <- (shape.geometries with_max_of each.area).location;
				
				
			}
		}
	}
	action create_landfill {
		loop s over: Dumpyards_shape_file.contents {
			string type <- s get ("TYPE");
			if type = "Commune" {
				create communal_landfill with: (shape: s){
					the_communal_landfill <- self;
					ask world {do manage_landfill_geom(s);}
				}
			} else {
				create local_landfill with:(shape:s){
					my_village <- first(village overlapping self);
					my_village.my_local_landfill <- self;
					ask world {do manage_landfill_geom(s);}
				}
			}
			
		}
		ask village {
			plots <- plots where not dead(each);
		}
		using topology(world) {
			ask plot {
				the_communal_landfill <- (communal_landfill at_distance distance_to_communal_landfill_for_pollution_impact) closest_to self;
				the_local_landfill <-   (local_landfill at_distance distance_to_local_landfill_for_pollution_impact) closest_to self;
				the_communal_landfill_dist <-the_communal_landfill != nil ? location distance_to the_communal_landfill : 1.0;
				the_local_landfill_dist <-the_local_landfill != nil ? location distance_to the_local_landfill : 1.0;
			}
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
			impacted_by_canal <- (self distance_to closest_canal) <= distance_to_canal_for_pollution_impact;
		}
		
	}
	
	action init_villages {
		ask village {
			name <- VILLAGE + " " + (int(self) + 1);
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
			budget <- world.compute_budget(length(inhabitants), length(farmers), production_level, days_with_ecolabel);
			if without_player and not without_actions and players_actions_to_load = nil{
				int id <- int(self);
				player_actions <- list<map<string, map>>(players_actions = nil ? nil : players_actions[id]);
			//	player_traitement_facility_maintenance <- players_traitement_facility_maintenance = nil ? nil : players_traitement_facility_maintenance[id];
			} 
		} 
		village1_production <-  (village[0].plots sum_of each.current_production);	
		village2_production <-  village[1].plots sum_of each.current_production ;	
		village3_production <-  village[2].plots sum_of each.current_production ;	
		village4_production <-  village[3].plots sum_of each.current_production ;	
		total_production <- (village1_production + village2_production + village3_production + village4_production) ;	
	
	}

	
	
	action action_executed(string action_name) {
		// To be redefined for updates, etc. 
	}
	
	
	action execute_action(string action_name) {
		if ((action_name in actions_name_short)){// and not(actions_name_short[action_name] in village[index_player].actions_done_this_year) and not(actions_name_short[action_name] in village[index_player].actions_done_total)) {
			bool is_ok <- false;
			switch action_name {
				match A_7a{
					ask villages_order[index_player] {
						is_ok <- drain_dredge(false, false);
					}
				} 
				match A_7b{
					ask villages_order[index_player] {
						is_ok <-  drain_dredge(true, false);
					}
				} 
				match A_2a { 
					ask villages_order[index_player] {
						is_ok <-  install_facility_treatment_for_homes() ;
					}
				}
				match A_6 {
					ask villages_order[index_player] {
						is_ok <-  sensibilization() ;
					}
				}
				match A_5b {
					ask villages_order[index_player] {
						is_ok <-  trimestrial_collective_action(true, false) ;
					}
				}
				match A_5a {
					ask villages_order[index_player] {
						is_ok <-  trimestrial_collective_action(false, false) ;
					}
				}
				match A_1 {
					ask villages_order[index_player] {
						is_ok <-  increase_collection_team_frequency_action() ;
					}
				}
			
				match A_4 {
					ask villages_order[index_player] {
						is_ok <-  pesticide_reducing() ;
					}
				}
				match A_8b {
					ask villages_order[index_player] {
						is_ok <-  support_manure_buying(true, false) ;
					}
				}
				match A_8a {
					ask villages_order[index_player] {
						is_ok <-  support_manure_buying(false, false) ;
					}
				}
				match A_9 {
					ask villages_order[index_player] {
						is_ok <-  implement_fallow();
					}
				}
				match A_3 {
					ask villages_order[index_player] {
						is_ok <-  install_dumpholes() ;
					}
				}
				match A_2b {
					ask villages_order[index_player] {
						is_ok <-  install_fiter_maintenance() ;
					}
				}
				match A_END_TURN {
					ask villages_order[index_player] {
						do end_of_turn ;
					}
				}
			}
			if is_ok {
				do action_executed(action_name);
			}
		}
		
	}
	
	// Old
	action activate_act1 {
		if stage = PLAYER_ACTION_TURN {
			ask villages_order[index_player] {do drain_dredge;}
			
		}
	}
	// Old
	action activate_act2 {
		if stage = PLAYER_ACTION_TURN {
			ask villages_order[index_player] {do install_facility_treatment_for_homes;}
		}
	}
	// Old
	action activate_act3 {
		if stage = PLAYER_ACTION_TURN {
			ask villages_order[index_player] {do sensibilization;}
		}
	}
	// Old
	action activate_act4 {
		if stage = PLAYER_ACTION_TURN {
			ask villages_order[index_player] {do trimestrial_collective_action;}
		}
	}
	// Old
	action activate_act5 {
		if stage = PLAYER_ACTION_TURN {
			ask villages_order[index_player] {do pesticide_reducing;}
		} 
	}
	// Old
	action activate_act6 {
		if stage = PLAYER_ACTION_TURN {
			ask villages_order[index_player] {do support_manure_buying;}
		}
			
	}
	// Old
	action activate_act7 {
		if stage = PLAYER_ACTION_TURN {
			ask villages_order[index_player] {do implement_fallow;}
		}
	}
	// Old
	action activate_act8 {
		if stage = PLAYER_ACTION_TURN {
			ask villages_order[index_player] {do install_dumpholes;}
		}
	}
	// Old
	action activate_act9 {
		if stage = PLAYER_ACTION_TURN {
			ask villages_order[index_player] {do end_of_turn;}
		}if stage = PLAYER_DISCUSSION_TURN {
			stage <- PLAYER_ACTION_TURN;
		 	ask villages_order[0] {do start_turn;}
		}
	}
	
	// Old
	action act_management {
		switch action_type {
			match 2 {ask villages_order[index_player] {do end_of_turn;}}
		}
	}
	
	action manage_flow_canal {
		ask canal parallel: parallel_computation{
			do init_flow;
		}
		ask canal parallel: parallel_computation{
			do flow;
		}
		ask canal parallel: parallel_computation{
			do update_waste;
		}	
	}
	
	action manage_individual_pollution {
		ask village parallel: parallel_computation{
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
		ask plot parallel: parallel_computation{
			do pollution_due_to_practice;
		}
	}
	
	action manage_daily_indicator {
		ask plot parallel: parallel_computation{
			do compute_production;
		}
		
		ask village parallel: parallel_computation{do compute_indicators;}
		village_ordered_by_production <- village sort_by (-1 * each.production_level);
		village_ordered_by_pollution <- village sort_by (each.solid_pollution_level + each.water_pollution_level * convertion_from_l_water_waste_to_kg_solid_waste );
	
	}
	
	action manage_landfill {
		ask local_landfill {
			do transfert_waste_to_communal_level;
		}
		ask communal_landfill {
			do manage_waste;
		}
	}
	
	action end_of_discussion_phase {
		stage <- PLAYER_ACTION_TURN;
		ask villages_order[0] {do start_turn;}
	}
	
	action manage_end_of_indicator_computation {
		if (current_day = 365) {
			extra_turn <- false;
			commune_budget_dispatch <- false;
			ask village {
				treatment_facility_is_activated <- false;
			}
			if create_facility_treatment {
				ask village {
					treatment_facility_year <- 1;
				}
			}
			create_facility_treatment <- false;
			stage <- without_player ? PLAYER_ACTION_TURN : PLAYER_DISCUSSION_TURN;
			index_player <- 0;
			step <- 0.000000000001;
			ask village {
				do compute_new_budget;
			}
			ask village {
				actions_done_this_year <- [];
				is_drained_strong <- false;
				is_drained_weak <- false; 
			}
			villages_order <-  random_turn ? shuffle(village): list(village);
			
			turn <- turn + 1;
			do update_display;
			if turn > end_of_game {
				do pause;
			}
			else if not without_player {
				
				string mess <- PLAYER_TURN +"\n" +((is_production_ok and is_pollution_ok)? COMMUNE_STANDARD_ECOLABEL : COMMUNE_NOT_STANDARD_ECOLABEL + ":" );
				if (not is_production_ok) {
					mess <- mess +"\n\t- " + AGRICULTURAL_PROD_LOW;
				}
				if (not is_pollution_ok) {
					mess <- mess +"\n\t- " + POLLUTION_TOO_HIGH;
				}
				loop i from: 0 to: 3 {
					mess <- mess + "\n" + message_village(i) ;	
				}
				do tell(mess);
				do tell(DISCUSSION_PHASE);
				start_discussion_turn_time <- machine_time;
				ask world {
					do update_display;
					do resume;
					do before_discussion_phase;
				}
		
			}
			
			if save_log {
				save ("" + turn  + ",0," + total_production + ","+ total_solid_pollution + "," + total_water_pollution + "," + days_with_ecolabel)  to: systeme_evolution_log_path format: text rewrite: false;
				save ("" + turn  + ",1," + village1_production + ","+ village1_solid_pollution + "," + village1_water_pollution + "," + days_with_ecolabel)  to: systeme_evolution_log_path format: text rewrite: false;
				save ("" + turn  + ",2," + village2_production + ","+ village2_solid_pollution + "," + village2_water_pollution+ "," + days_with_ecolabel)  to: systeme_evolution_log_path format: text rewrite: false;
				save ("" + turn  + ",3," + village3_production + ","+ village3_solid_pollution + "," + village3_water_pollution+ "," + days_with_ecolabel)  to: systeme_evolution_log_path format: text rewrite: false;
				save ("" + turn  + ",4," + village4_production + ","+ village4_solid_pollution + "," + village4_water_pollution+ "," + days_with_ecolabel)  to: systeme_evolution_log_path format: text rewrite: false;
			}
		}
	}
	
	string message_village(int id) {
		string gain_lost <- "";
		if (village[id].diff_farmers < 0) {gain_lost <- (VILLAGE + " " + (id+1) +" "+ LOST+" " + abs(village[id].diff_farmers) + " " + FARMS);}
		if (village[id].diff_urban_inhabitants > 0) {
			if gain_lost = "" {
				gain_lost <- (VILLAGE+ " " + (id+1) +"  " + GAINED + " " + abs(village[id].diff_urban_inhabitants) + " " + URBAN_HOUSEHOLDS);
			} else {
				gain_lost <- gain_lost + (" " + AND + " " + GAINED + " " + abs(village[id].diff_urban_inhabitants) + " " + URBAN_HOUSEHOLDS);
			}
		}
		if village[id].diff_budget  =0 {
			if gain_lost = "" {
				gain_lost <- (BUDGET_VILLAGE + " " + (id+1) +" " + NOT_EVOLVED);
			} else {
				gain_lost <- gain_lost + ("; " + THE_BUDGET + " " + NOT_EVOLVED);		
			}
		} else {
			string incdec <- ((village[id].diff_budget  >0) ? INCREASED_BY :DECREASED_BY) + " ";
			if gain_lost = "" {
				gain_lost <- (BUDGET_VILLAGE + " " + (id+1) +" " + incdec + abs(village[id].diff_budget) + " " + TOKENS);
			} else {
				gain_lost <- gain_lost +("; " + THE_BUDGET + " "+ incdec + abs(village[id].diff_budget) + " " + TOKENS);
			}
		}
		
		return gain_lost;
	}
	 
	action manage_pollution_decrease {
		ask cell {
			do natural_pollution_reduction;
		}
		
		ask village {
			int d <- (current_day mod 7) + 1;
			list<cell> cells_to_clean;
			if collect_only_urban_area {
				cells_to_clean <- remove_duplicates(urban_areas accumulate each.my_cells);  
			} else {
				cells_to_clean <-  cells;
			}
			cells_to_clean <-  cells where (each.solid_waste_level > 0);
			ask collection_teams {
				if (d in collection_days) {
					do collect_waste(cells_to_clean);
				}
			}
		}
	}
	
	action increase_urban_area {
		ask village {
			float increase_urban_area_population_year <- increase_urban_area_population_year_per_village[int(self)];
			target_population <- round(population *(1 + increase_urban_area_population_year));
			using topology(world) {
				ask urban_areas {
					geometry prev_geom <- copy(shape);
					ask (houses where each.inhabitant_to_create) {
						create_inhabitant_day <- rnd(2,363);	
					}
					list<plot> neighbors_plot <- (myself.plots at_distance 0.1) sort_by each.shape.area;
					
					if not empty(neighbors_plot) {
						int target_pop <- round(population *(1 + increase_urban_area_population_year)) -  (houses count each.inhabitant_to_create);
						//write sample(population) + " " + sample(target_pop);
						loop while: not empty(neighbors_plot) and population <target_pop {
							plot p <- first(neighbors_plot);
							neighbors_plot >> p;
							if (dead(p)) {break;}
							geometry shape_plot <- copy(p.shape);
							ask my_villages {farmers >> p.the_farmer; plots >> p;}
							shape <- shape + shape_plot;
							ask p.the_farmer {do die;}
							ask p {do die;}
							list<geometry> geoms <- to_squares (shape_plot,house_size);
							create house from: geoms {
								target_pop <- target_pop - 1;
								inhabitant_to_create <- true;
								create_inhabitant_day <- rnd(2,363);
								my_village <- first(village overlapping location);
								myself.houses << self;
								if my_village = nil{
									my_village <- village closest_to location;
								}
							}
							population <- population - 1 ;
							myself.diff_farmers<- myself.diff_farmers - 1;
						}
					}
					my_cells <- cell overlapping self;
					if prev_geom.area < shape.area {
						geometry_history << (shape - prev_geom);
					}
			
				}
			}
		}
		ask village {
			plots <- plots where not dead(each);
		}
	}
	
	action compute_indicators {
		
	 	is_pollution_ok <- (total_solid_pollution + total_water_pollution) <= max_pollution_ecolabel ;
	 	is_production_ok <- total_production >= min_production_ecolabel;
	 	
	 	if is_pollution_ok and is_production_ok{
	 		days_with_ecolabel <- days_with_ecolabel + 1;
	 		days_with_ecolabel_year[length(days_with_ecolabel_year) - 1] <- days_with_ecolabel_year[length(days_with_ecolabel_year) - 1]  + 1;
	 	}
	}
	action add_data {
		int time_s <- turn * 365 + current_day;
		time_step << time_s;
		village1_solid_pollution_values << village1_solid_pollution;
	 	village2_solid_pollution_values << village2_solid_pollution;
	 	village3_solid_pollution_values<< village3_solid_pollution;
	 	village4_solid_pollution_values<< village4_solid_pollution;
	 	village1_water_pollution_values<< village1_water_pollution;
	 	village2_water_pollution_values<< village2_water_pollution;
	 	village3_water_pollution_values<< village3_water_pollution;
	 	village4_water_pollution_values<< village4_water_pollution;
	 	village1_production_values << village1_production;
	 	village2_production_values<< village2_production;
	 	village3_production_values<< village3_production;
	 	village4_production_values<< village4_production;
	 	total_solid_pollution_values << total_solid_pollution;
	 	total_water_pollution_values << total_water_pollution;
	 	total_pollution_values << (total_solid_pollution + total_water_pollution);
	 	total_production_values << total_production;
	 	ecolabel_min_production_values << min_production_ecolabel;
	 	ecolabel_max_pollution_values << max_pollution_ecolabel;
	 	
	 }
	
	
	
	reflex indicators_computation when: stage = COMPUTE_INDICATORS {
		do compute_indicators;
		if (current_day mod data_frequency) = 0 {
			do add_data;
		}
		do manage_individual_pollution;
		do manage_flow_canal;
		do manage_pollution_decrease;
		do manage_landfill;
		do manage_daily_indicator;
		do manage_end_of_indicator_computation;
		current_day <- current_day + 1;
	}
	
	action choose_village_for_pool {
			commune_money <- 0;
			ask village {
				commune_money <- commune_money + budget;
				budget <- 0;
			}

			map result <- user_input_dialog(SELECT_A_VILLAGE_TO_RECEIVE_COMMUNE_BUDGET, [choose(PLAYER_SELECTED, string, one_of(players_names), players_names)]);
			int index <- index_of(players_names, result[PLAYER_SELECTED]);
			villages_order << village[index];
			ask village[index] {
				budget <- commune_money;
			}

			do before_start_turn();
			commune_money <- 0;
			to_refresh <- true;
	}
	
	reflex playerturn when: stage = PLAYER_ACTION_TURN{
		if without_player or (index_player >= length(villages_order)) {
			if not without_player and  use_money_pool and not commune_budget_dispatch {
				do choose_village_for_pool();
			} else {
				if (turn >= end_of_game) {
					do pause;
				} else {
					if without_player and not without_actions {
						loop i from: 0 to: length(village) - 1 {
							ask village[i] {
								do start_turn;
								do play_predefined_actions;
								do ending_turn;
							}
						}
					}
					stage <- COMPUTE_INDICATORS;
					days_with_ecolabel_year << 0;
					current_day <- 0;
					step <- #day;
						
					if not without_player {do tell(INDICATOR_COMPUTATION);}
					do increase_urban_area;
					
				}
			
			}
			
			
		}
	}
	
	reflex end_of_discussion_turn when: use_timer_for_discussion and stage = PLAYER_DISCUSSION_TURN {
		remaining_time <- int(time_for_discussion - machine_time/1000.0  +start_discussion_turn_time/1000.0); 
		if remaining_time <= 0 {
			do tell(TIME_DISCUSSION_FINISHED);
			do pause;
		}
	}
	reflex end_of_player_turn when: not without_player and  use_timer_player_turn and stage = PLAYER_ACTION_TURN {
		remaining_time <- int(time_for_player_turn - machine_time/1000.0  + villages_order[index_player].start_turn_time/1000.0);
 
		if remaining_time <= 0 {
			do tell(TIME_PLAYER + " " + (int(villages_order[index_player]) + 1) +" " + FINISHED);
			do pause;
		}
	}

}

