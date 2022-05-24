/**
* Name: UrbanArea
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/


model UrbanSpace



species urban_area { 
	int population;
	list<village> my_villages;
	list<house> houses;
}
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
			
			my_village.diff_urban_inhabitants <- my_village.diff_urban_inhabitants + 1;
		}
	}
	aspect default {
		draw shape color: color border: #black;
	}
}