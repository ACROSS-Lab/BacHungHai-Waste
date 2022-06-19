/**
* Name: UrbanArea
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/


model UrbanSpace

import "../Global.gaml"



species urban_area { 
	int population;  
	list<geometry> geometry_history;
	list<village> my_villages;
	list<house> houses;
	list<cell> my_cells; 
	
	aspect default {
		int nb <- length(geometry_history) - 1;
		loop i from: 0 to: nb {
			float val <- 75 + (i/end_of_game) * 150; 
			geometry g <- geometry_history[i];
//			geometry g2 <- g - 20;
			draw g  color: rgb(val,val,val) at: g.location + {0,0,i*0.1};
//			draw (g - g2) color: #black;
	}
}}
species house {
	bool inhabitant_to_create <- false;
	int create_inhabitant_day <- -1;
	rgb color<-#darkslategray;
	village my_village;
	
	reflex new_inhabitants when: inhabitant_to_create and create_inhabitant_day = current_day{
		if (my_village.population < my_village.target_population) {
			do create_inhabitants;
			inhabitant_to_create <- false;
		}
		
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
			environmental_sensibility <- 0.0;//first(my_village.inhabitants).environmental_sensibility;
			
			my_village.diff_urban_inhabitants <- my_village.diff_urban_inhabitants + 1;
		}
	}
	aspect default {
		draw shape color: color border: #black;
	}
}