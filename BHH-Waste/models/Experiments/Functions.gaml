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
		int w <- soil_pollution_value_last_year(v);
		switch(w) {
			match_between [] {return 0;}
			match_between [] {return 1;}
			match_between [] {return 2;}
			match_between [] {return 3;}
			default {return 4;}
		}
	}
	
	// Class supposed to be between 0 (low) to 4 (high) for the villages
	
	
	int production_class_last_year (village v) {
		int w <- production_value_last_year(v);
		switch(w) {
			match_between [] {return 0;}
			match_between [] {return 1;}
			match_between [] {return 2;}
			match_between [] {return 3;}
			default {return 4;}
		}
	}
	
	// Class supposed to be between 0 (low) to 4 (high) for the villages
	
	int water_pollution_class_last_year (village v) {
		int w <- water_pollution_value_last_year(v);
		switch(w) {
			match_between [] {return 0;}
			match_between [] {return 1;}
			match_between [] {return 2;}
			match_between [] {return 3;}
			default {return 4;}
		}
	}
	
	

	int soil_pollution_value_last_year(village v) {
		return 0;
	}
	
	int water_pollution_value_last_year(village v) {
		return 0;
	}
	
	int production_value_last_year(village v) {
		return 0;
	}
	
	// Indicators for the map
	
	// Class supposed to be between 0 (low) to 4 (high) for the plots
	
	int production_class_current(plot p) {
		float w <- p.current_production; // TODO this is an example
		switch(w) {
			match_between [] {return 0;}
			match_between [] {return 1;}
			match_between [] {return 2;}
			match_between [] {return 3;}
			default {return 4;}
		}
	}
	
	// Class supposed to be between 0 (low) to 4 (high) for the plots
	
	int soil_pollution_class_current(plot p) {
		float w <- p; // TODO this is an example
		switch(w) {
			match_between [] {return 0;}
			match_between [] {return 1;}
			match_between [] {return 2;}
			match_between [] {return 3;}
			default {return 4;}
		}
	}
	
	// Class supposed to be between 0 (low) to 4 (high) for the canals
	
	int water_pollution_class_current(canal p) {
		float w <- p.pollution_density; // TODO this is an example
		switch(w) {
			match_between [] {return 0;}
			match_between [] {return 1;}
			match_between [] {return 2;}
			match_between [] {return 3;}
			default {return 4;}
		}
	}
	
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