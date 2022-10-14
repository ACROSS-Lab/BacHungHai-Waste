/**
* Name: Parameters
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/

@no_experiment
model Parameters

global {
	
	/******************* GENERAL PARAMETERS *************************************/
	bool parallel_computation <- false;
	string GAME_NAME <- "EcoGame";
	//string langage <- "English";

	string langage <- "Tiếng Việt"; 
	
	
	bool use_money_pool <- true;
	bool confirmation_popup <- true;
	bool no_starting_actions <- false;
	bool random_turn <- true;
	csv_file translation_game_csv_file <- csv_file("../includes/translation_game.csv", ",", false);
	bool display_info_action_console <- false;
	
	/******************* USE TIMERS *************************************/
	bool use_timer_player_turn <- false;	
	bool use_timer_for_discussion <- false;
	
	float time_for_player_turn <- 20#s;//2 #mn;
	float time_for_discussion <- 20 #s;//3 #mn; // time before the player turns
	 
	
	/******************* LOG RESULTS *************************************/
	
	bool save_log <- true;
	string id_game <- ""+ (#now).year + "_" + (#now).month + "_" + (#now).day+"-" + (#now).hour + "_" + (#now).minute;
	string village_action_log_path <- "../../results/" + id_game+"/village_action.csv";
	string systeme_evolution_log_path <- "../../results/" + id_game+"/system_evolution.csv";
	
	/******************* GEOGRAPHICAL DATA USED *************************************/
	shape_file Limites_commune_shape_file <- shape_file("../includes/Definitive_versions/Limites_communesV2.shp");

	shape_file Limites_urban_areas_shape_file <- shape_file("../includes/Definitive_versions/Limites_villagesV2.shp");

	shape_file Hydrologie_shape_file <- shape_file("../includes/Definitive_versions/Hydrology_clean2_2.shp");
	
	geometry shape <- envelope(Limites_commune_shape_file);
	
	shape_file villages_shape_file <- shape_file("../includes/Definitive_versions/Territoires_villagesV2.shp");

	shape_file Fields_shape_file <- shape_file("../includes/Definitive_versions/FieldsV1.shp");

	shape_file Dumpyards_shape_file <- shape_file("../includes/Definitive_versions/Dumpyards.shp");

	/*************** GENERAL PARAMETERS ON TIME AND SPACE ****************************/
	
	float step <- 1#day;// one simulation step = 1 day 
	float house_size <- 50.0 #m; // size of a house plot
	
	int end_of_game <- 11; // Number of turns of the game (1 turn = 1 year)
	float tolerance_dist <- 1#m;
	
	/*************** PARAMETERS ON ECO-LABEL ****************************/
	
	float convertion_from_l_water_waste_to_kg_solid_waste <- 1.0;
	float min_production_ecolabel <- 3000.0;// minimum threshold of production to get EcoLabel, unities are tons of rice produced
	float max_pollution_ecolabel <- 300000.0;// maximum threshold of production to get ecolabel, unities are converted in 
	
	/************* PARAMETERS RELATED TO DEMOGRAPHIC AND ECONOMIC ASPECT  ***************/
	
	int base_budget_year_per_village <- 65; // total buget per year for a village (in token):
	list<float> increase_urban_area_population_year_per_village <- [0.05,0.8,0.25,0.25] ; // increase of urban area per year per village (in terms of number of people)
	
	int compute_budget(int urban_pop, int agricultural_pop, float production_level, int day_ecolabel) {
		//return  base_budget_year_per_village + round((urban_pop + agricultural_pop) / 30) ;
		int v <-  base_budget_year_per_village + round((production_level)/46);
		write sample(v);
		int r <- v - (int(v/5) * 5);
	 	if r = 0 {return v;}
	 	if r > 5 -r {return (int(v/5) * 5);}
	 	else {return ((int(v/5) + 1) * 5);}
	}
	
	/*************** PARAMETERS RELATED TO VISUALIZATION ****************************/
	
	int data_frequency <- 5;
	list<rgb> village_color <- [#magenta, #gold, #violet,#orange]; // color for the 4 villages
	float min_display_waste_value <- 0.2; //just use for display all the pollution cell 
	float coeff_cell_pollution_display <- 10.0;  //coeff used to define the color of the cell according to the pollution
	float coeff_visu_canal <- 3.0;  //coeff used to define the color of the canal according to the pollution
	float coeff_visu_productivity <- 150 /factor_productivity;
	
	/********* PARAMETERS RELATED TO WATER FLOW (WASTE DIFFUSION) IN THE CANAL *******/
	
	float rate_diffusion_liquid_waste <- 10.0; //rate of liquid waste per perimeter of canals passing to the the downstream canal
	float rate_diffusion_solid_waste <- 2.0 ;//rate of solid waste per perimeter of canals passing to the the downstream canal
	
	
	/******* PARAMETERS RELATED TO THE IMPACT OF POLLUTION ON FIELD YIELD *************/
	
	float factor_productivity <- 1000000.0;
	
	float field_initial_productivity <- 300/factor_productivity; // initial productivity of fields;
	float distance_to_canal_for_pollution_impact <- 50 #m; //all the fields at this distance are impacted by the canal pollution
	float canal_solid_waste_pollution_impact_rate <- 0.025/ factor_productivity; //production (yield) = production  - (pollution of the surrounding canal * pollution_impact_rate)
	float canal_water_waste_pollution_impact_rate <- 0.045/ factor_productivity; //production (yield) = production  - (pollution of the surrounding canal * pollution_impact_rate)
	float ground_solid_waste_pollution_impact_rate <- 0.3/ factor_productivity; //production (yield) = production  - (sum solid pollution on cell * pollution_impact_rate)
	float ground_water_waste_pollution_impact_rate <- 0.3/ factor_productivity; //production (yield) = production  - (sum water pollution on cell * pollution_impact_rate)
	
	float quantity_from_local_to_communal_landfill <- 50.0; //quantity of solid waste transfert to communal landfill every day for each local landfill 
	float quantity_communal_landfill_to_treatment <- 170.0; //quantity of solid waste "treated" (that disapears) every day from the communal landfill
	
	float local_landfill_waste_pollution_impact_rate <- 0.020 * 30/ factor_productivity; //impact of the pollution generated by the local landfill on productivity of fields: production (yield) = production  - (pollution of the surrounding local landfill * local_landfill_waste_pollution_impact_rate)
	float communal_landfill_waste_pollution_impact_rate <- 0.015 * 30/ factor_productivity;  //impact of pollution generated by the communal landfill on productivity of fields: production (yield) = production  - (pollution of the surrounding communal landfill * communal_landfill_waste_pollution_impact_rate)
	float distance_to_local_landfill_for_pollution_impact <- 100#m;//2 #km; //distance of impact considered for the local landfills
	float distance_to_communal_landfill_for_pollution_impact <- 200 #m;//5 #km; //distance of impact considered for the communal landfill
	
	
	/*********** PARAMETERS RELATED TO WASTE PRODUCTION AND END OF LIFE *************/
	
	
	float ground_water_pollution_reducing_day <- 0.01; //quantity of the ground water pollution that disapear every day
	float ground_solid_pollution_reducing_day <- 0.001; //quantity of the solid water pollution that disapear every day
	
	float water_waste_filtering_inhabitants <- 0.2 min: 0.0 max: 1.0; // part of the water waste produced per inhabitants that are filtered
	float water_waste_year_inhabitants <- 200000.0 / 1000.0;// L/pers/year - quantity of water waste produced per people living in urban area per year 
	float solid_waste_year_inhabitants <-  63.0;//kg/pers/year - quantity of solid waste produced per people living in urban area per year  
	
	float water_waste_year_farmers <- 75000.0 / 1000.0;// L/pers/year - quantity of water waste produced per people outside  urban area (farmer) per year 
	float solid_waste_year_farmers <-  90.0;//kg/pers/year - quantity of solid waste produced per people outside  urban area (farmer) per year
	
	float part_solid_waste_canal_inhabitants <- 0.6; // proportion of solid waste throw in the canal per people living in urban area; (1 - part_solid_waste_canal_inhabitants) is throw on the ground
	float part_water_waste_canal_inhabitants <- 1.0;// proportion of water waste throw in the canal per people living in urban area; (1 - part_water_waste_canal_inhabitants) is throw on the ground
	
	float part_solid_waste_canal_farmers <- 0.2; // proportion of solid waste throw in the canal per people living outside urban area; (1 - part_solid_waste_canal_farmers) is throw on the ground
	float part_water_waste_canal_farmers <- 0.2;// proportion of water waste throw in the canal per people living outside urban area; (1 - part_water_waste_canal_farmers) is throw on the ground
	
	float part_of_water_waste_pollution_to_canal <- 0.01;// part of the water waste on ground to go the canal every day; 
	
	/********************** PARAMETERS RELATED ACTIONS ****************************/
	
	bool collect_only_urban_area <- true;
	int token_increase_collection_frequency <- 40; //tokens/year - cost of "increasing the collection frequency"
	float collection_team_collection_capacity_day <- 200.0; //quantity of solid waste remove during 1 day of work
	
	list<int> days_collects_default <- [2,5] ; //day of collects - 1 = monday, 7 = sunday
	list<int> days_collects_increased <- [1, 3, 5,  7] ; //day of collects - 1 = monday, 7 = sunday
	
	int token_trimestrial_collective_action_strong <- 35; //per year
	int token_trimestrial_collective_action_weak <- round(token_trimestrial_collective_action_strong / 1.75); //per year
	
	float impact_trimestrial_collective_action_strong <- 0.35  min: 0.0 max: 1.0; //part of the solid and water waste remove from the canal
	float impact_trimestrial_collective_action_weak <- impact_trimestrial_collective_action_strong / 2.5  min: 0.0 max: 1.0; //part of the solid and water waste remove from the canal
	
	int token_drain_dredge_strong <- 50; //per action
	float impact_drain_dredge_waste_strong <- 0.45 min: 0.0 max: 1.0; //part of the solid waste remove from the canal
	float impact_drain_dredge_agriculture_strong <- 0.0 min: 0.0 max: 1.0; //improvment of the agricultural production
	int token_drain_dredge_weak <- round(token_drain_dredge_strong/2.0) ; //per action
	float impact_drain_dredge_waste_weak <- impact_drain_dredge_waste_strong/2.5 min: 0.0 max: 1.0; //part of the solid waste remove from the canal
	float impact_drain_dredge_agriculture_weak <- impact_drain_dredge_agriculture_strong/2.0 min: 0.0 max: 1.0; //improvment of the agricultural production
	
	int token_install_filter_for_homes_construction <- 240 ; //construction
	int token_install_filter_for_homes_maintenance <- 10; //per year	
	list<float> treatment_facility_decrease <- [0.10,0.35,0.55, 0.75] ; // impact of treatement facility for year 1, year 2, and after. Comprised between 0 and 1
	
	int token_sensibilization <- 20; //each time
	float impact_sensibilization <- 1.0 min: 0.0 max: 1.0; //add this value to the environmental sensibility of people leaving in urban areas
	
	float sensibilisation_function(float x) { //function that returns the coefficient of solid production according to the environmental_sensibility of inahbitants 'x'
		return (1 - 2/(1 +exp(x/2)));
	}
	int token_pesticide_reducing <- 40; // 
	float impact_pesticide_reducing_production  <- 0.1 min: 0.0 max: 1.0; //decrease of the agricultural production
	float impact_pesticide_reducing_waste  <- 0.70 min: 0.0 max: 1.0; //decrease water waste production from farmers
	
	int token_implement_fallow <- 40; //per year
	float part_of_plots_in_fallow  <- 0.30 min: 0.0 max: 1.0; //decrease the agricultural production
	list<float> improve_of_fallow_on_productivity <- [0.40, 0.20]; //at T+1 -> Improve the productivity of 50 % at T+1, then of 25 % at T+2, and 0% after
	
	int token_support_manure_buying_strong <- 40; //per year
	float impact_support_manure_buying_production_strong  <- 0.40 min: 0.0 max: 1.0; //improvment of the agricultural production
	float impact_support_manure_buying_waste_strong  <- 0.6 min: 0.0 max: 1.0; //increase wastewater production
	int token_support_manure_buying_weak <- round(token_support_manure_buying_strong/2); //per year
	float impact_support_manure_buying_production_weak  <- impact_support_manure_buying_production_strong/2.5 min: 0.0 max: 1.0; //improvment of the agricultural production
	float impact_support_manure_buying_waste_weak  <- impact_support_manure_buying_waste_strong/2.0 min: 0.0 max: 1.0; //increase wastewater production
	
	
	int token_installation_dumpholes <- 40; //
	float impact_installation_dumpholes  <- 0.70 min: 0.0 max: 1.0; //decreasse the quantity of solid waste produced by people outside of urban areas (farmers)
	
	
	
}
