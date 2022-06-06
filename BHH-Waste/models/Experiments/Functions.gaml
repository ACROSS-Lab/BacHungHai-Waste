/**
* Name: Functions
* Based on the internal empty template. 
* Author: drogoul
* Tags: 
*/




model Functions

import "../Global.gaml"

global {
	
	
	
	// Indicators for players display + stacked chart
	
	// Class supposed to be between 0 (low) to 4 (high) for the villages
	
	int soil_pollution_class_last_year (village v) {
		float w <- village_solid_pollution[int(v)];
		switch(w) {
			match_between [0, 24999] {return 0;}
			match_between [25000, 39999] {return 1;}
		match_between [40000, 64999] {return 2;}
			match_between [65000, 90000] {return 3;}
			default {return 4;}
		}
	}
	
	// Class supposed to be between 0 (low) to 4 (high) for the villages
	
	
//	int production_class_last_year (village v) {
//		float w <- village_production[int(v)];
//		if (int(v) = 0) {
//			switch(w) {
//				match_between [0, 349] {return 0;}
//				match_between [350, 699] {return 1;}
//				match_between [700, 899] {return 2;}
//				match_between [900, 1149] {return 3;}
//				default {return 4;}
//			}
//		} else {
//			switch(w) {
//				match_between [0, 499] {return 0;}
//				match_between [500, 799] {return 1;}
//				match_between [800, 1099] {return 2;}
//				match_between [1100, 1499] {return 3;}
//				default {return 4;}
//			}
//		}
//		
//	}
	
	// Class supposed to be between 0 (low) to 4 (high) for the villages
	
	int water_pollution_class_last_year (village v) {
		
		float w <- village_water_pollution[int(v)];
		switch(w) {
			match_between [0, 9999] {return 0;}
			match_between [10000, 19999] {return 1;}
			match_between [20000, 29999] {return 2;}
			match_between [30000, 44999] {return 3;}
			default {return 4;}
		}
	}
	
	

	float soil_pollution_value_last_year(village v) {
		return village_solid_pollution[int(v)];
	}
	
	float water_pollution_value_last_year(village v) {
		return village_water_pollution[int(v)];
	}
	
	float production_value_last_year(village v) {
		return village_production[int(v)];
	}
	
	// Indicators for the map
	
	// Class supposed to be between 0 (low) to 4 (high) for the plots
	
	int production_class_current(plot p) {
		float w <- field_initial_productivity; // TODO this is an example
		switch(w) {
			match_between [0, 0.000079] {return 0;}
			match_between [0.00008, 0.000012] {return 1;}
			match_between [0.00013, 0.00019] {return 2;}
			match_between [0.0002, 0.00029] {return 3;}
			default {return 4;}	
		}
	}
	
	// Class supposed to be between 0 (low) to 4 (high) for the plots
	
	/*int soil_pollution_class_current(plot p) {
		float w <- p; // TODO this is an example
		switch(w) {
			match_between [] {return 0;}
			match_between [] {return 1;}
			match_between [] {return 2;}
			match_between [] {return 3;}
			default {return 4;}
		}
	}*/
	
	// Class supposed to be between 0 (low) to 4 (high) for the canals

	
	// Indicator for the global icon
	
	bool ecolabel_obtained_last_year {
		return true;
	}
	
	
	
	int number_of_days_with_ecolabel_last_year {
		return 0;
	}
	
	int total_score_since_beginning {
		return 0;
	}
	
	
} 