/**
* Name: Pollutioncell
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/


model Pollutioncell

import "../Global.gaml" 


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

