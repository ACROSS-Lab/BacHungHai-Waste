/**
* Name: Shortversion
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/


model Shortversion

import "LFAY.gaml"


global {
	string langage <- "Français";
	int end_of_game <- 6; // Number of turns of the game (1 turn = 1 year)

/*************** PARAMETERS ON ECO-LABEL ****************************/
	
	float convertion_from_l_water_waste_to_kg_solid_waste <- 1.0;
	float min_production_ecolabel <- 2200.0;// minimum threshold of production to get EcoLabel, unities are tons of rice produced
	float max_pollution_ecolabel <- 300000.0;// maximum threshold of production to get ecolabel, unities are converted in 
	

/******* PARAMETERS RELATED TO THE IMPACT OF POLLUTION ON FIELD YIELD *************/
	
	float factor_productivity <- 1000000.0;
	
	float field_initial_productivity <- 300/factor_productivity; // initial productivity of fields;
	float distance_to_canal_for_pollution_impact <- 50 #m; //all the fields at this distance are impacted by the canal pollution
	float canal_solid_waste_pollution_impact_rate <- 0.035/ factor_productivity; //production (yield) = production  - (pollution of the surrounding canal * pollution_impact_rate)
	float canal_water_waste_pollution_impact_rate <- 0.045/ factor_productivity; //production (yield) = production  - (pollution of the surrounding canal * pollution_impact_rate)
	float ground_solid_waste_pollution_impact_rate <- 0.4/ factor_productivity; //production (yield) = production  - (sum solid pollution on cell * pollution_impact_rate)
	float ground_water_waste_pollution_impact_rate <- 0.4/ factor_productivity; //production (yield) = production  - (sum water pollution on cell * pollution_impact_rate)
	
	float quantity_from_local_to_communal_landfill <- 50.0; //quantity of solid waste transfert to communal landfill every day for each local landfill 
	float quantity_communal_landfill_to_treatment <- 170.0; //quantity of solid waste "treated" (that disapears) every day from the communal landfill
	
	float local_landfill_waste_pollution_impact_rate <- 0.060 * 30/ factor_productivity; //impact of the pollution generated by the local landfill on productivity of fields: production (yield) = production  - (pollution of the surrounding local landfill * local_landfill_waste_pollution_impact_rate)
	float communal_landfill_waste_pollution_impact_rate <- 0.0800 * 30/ factor_productivity;  //impact of pollution generated by the communal landfill on productivity of fields: production (yield) = production  - (pollution of the surrounding communal landfill * communal_landfill_waste_pollution_impact_rate)
	float distance_to_local_landfill_for_pollution_impact <- 100#m;//2 #km; //distance of impact considered for the local landfills
	float distance_to_communal_landfill_for_pollution_impact <- 200 #m;//5 #km; //distance of impact considered for the communal landfill
	
/************* PARAMETERS RELATED TO DEMOGRAPHIC AND ECONOMIC ASPECT  ***************/
	
	int base_budget_year_per_village <- 90; // total buget per year for a village (in token):
	float min_increase_urban_area_population_year <- 0.70 ; //min increase of urban area per year (in terms of number of people)
	
	int compute_budget(int urban_pop, int agricultural_pop, float production_level, int day_ecolabel) {
		//return  base_budget_year_per_village + round((urban_pop + agricultural_pop) / 30) ;
		int v <-  base_budget_year_per_village + round((production_level)/35); 
		write sample(v);
		int r <- v - (int(v/5) * 5);
	 	if r = 0 {return v;}
	 	if r > 5 -r {return (int(v/5) * 5);}
	 	else {return ((int(v/5) + 1) * 5);}
	}

/********************** PARAMETERS RELATED ACTIONS ****************************/
	
	bool collect_only_urban_area <- true;
	bool proposed_ultimate <- false;
	int token_weak_waste_collection <- 30; //tokens/year - cost of "weak collection"
	int token_strong_waste_collection <- 50; //tokens/year - cost of "strong collection"
	int token_ultimate_waste_collection <- 90; //tokens/year - cost of "ultimate collection"
	float collection_team_collection_capacity_day <- 215.0; //quantity of solid waste remove during 1 day of work
	
	list<int> days_collects_weak <- [2,5] ; //day of collects - 1 = monday, 7 = sunday
	list<int> days_collects_strong <- [1, 3, 5,  7] ; //day of collects - 1 = monday, 7 = sunday
	list<int> days_collects_ultimate <- [1, 2, 3, 4, 5, 6, 7]; //
	
	int token_trimestrial_collective_action_strong <- 35; //per year
	int token_trimestrial_collective_action_weak <- round(token_trimestrial_collective_action_strong / 2.0); //per year
	
	float impact_trimestrial_collective_action_strong <- 0.42  min: 0.0 max: 1.0; //part of the solid and water waste remove from the canal
	float impact_trimestrial_collective_action_weak <- impact_trimestrial_collective_action_strong / 2.0  min: 0.0 max: 1.0; //part of the solid and water waste remove from the canal
	
	int token_drain_dredge_strong <- 50; //per action
	float impact_drain_dredge_waste_strong <- 0.50 min: 0.0 max: 1.0; //part of the solid waste remove from the canal
	float impact_drain_dredge_agriculture_strong <- 0.0 min: 0.0 max: 1.0; //improvment of the agricultural production
	int token_drain_dredge_weak <- round(token_drain_dredge_strong/2.0) ; //per action
	float impact_drain_dredge_waste_weak <- impact_drain_dredge_waste_strong/2.0 min: 0.0 max: 1.0; //part of the solid waste remove from the canal
	float impact_drain_dredge_agriculture_weak <- impact_drain_dredge_agriculture_strong/2.0 min: 0.0 max: 1.0; //improvment of the agricultural production
	
	int token_install_filter_for_homes_construction <- 240 ; //construction
	int token_install_filter_for_homes_maintenance <- 10; //per year	
	list<float> treatment_facility_decrease <- [0.40,0.80] ; // impact of treatement facility for year 1, year 2, and after. Comprised between 0 and 1
	
	int token_sensibilization <- 20; //each time
	float impact_sensibilization <- 1.0 min: 0.0 max: 1.0; //add this value to the environmental sensibility of people leaving in urban areas
	
	float sensibilisation_function(float x) { //function that returns the coefficient of solid production according to the environmental_sensibility of inahbitants 'x'
		return (1 - 2/(1 +exp(x/1)));
	}
	int token_pesticide_reducing <- 40; // 
	float impact_pesticide_reducing_production  <- 0.1 min: 0.0 max: 1.0; //decrease of the agricultural production
	float impact_pesticide_reducing_waste  <- 0.60 min: 0.0 max: 1.0; //decrease waste production from farmers
	
	int token_implement_fallow <- 40; //per year
	float part_of_plots_in_fallow  <- 0.30 min: 0.0 max: 1.0; //decrease the agricultural production
	list<float> improve_of_fallow_on_productivity <- [0.50, 0.25]; //at T+1 -> Improve the productivity of 50 % at T+1, then of 25 % at T+2, and 0% after
	
	int token_support_manure_buying_strong <- 40; //per year
	float impact_support_manure_buying_production_strong  <- 0.35 min: 0.0 max: 1.0; //improvment of the agricultural production
	float impact_support_manure_buying_waste_strong  <- 0.2 min: 0.0 max: 1.0; //increase wastewater production
	int token_support_manure_buying_weak <- round(token_support_manure_buying_strong/2); //per year
	float impact_support_manure_buying_production_weak  <- impact_support_manure_buying_production_strong/2.0 min: 0.0 max: 1.0; //improvment of the agricultural production
	float impact_support_manure_buying_waste_weak  <- impact_support_manure_buying_waste_strong/2.0 min: 0.0 max: 1.0; //increase wastewater production
	
	
	int token_installation_dumpholes <- 40; //
	float impact_installation_dumpholes  <- 0.70 min: 0.0 max: 1.0; //decreasse the quantity of solid waste produced by people outside of urban areas (farmers)
	
}


