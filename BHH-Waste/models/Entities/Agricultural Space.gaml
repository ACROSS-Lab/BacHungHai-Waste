/**
* Name: AgriculturalSpace
* Based on the internal empty template. 
* Author: Patrck Taillandier
* Tags: 
*/


model AgriculturalSpace

import "../Global.gaml"

 
species plot {
	village the_village;
	float base_productivity <- field_initial_productivity min: 0.0;
	bool does_reduce_pesticide <- false;
	float current_productivity <- field_initial_productivity min: 0.0;
	float current_production <- current_productivity * shape.area min: 0.0;
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
	bool use_more_manure_strong <- false;
	bool use_more_manure_weak <- false;
	bool does_implement_fallow <- false;
	
	action pollution_due_to_practice { 
		//pratice_water_pollution_level <- 
		if use_more_manure_strong {
			pratice_water_pollution_level <- pratice_water_pollution_level * (1 + impact_support_manure_buying_waste_strong);
		}
		if use_more_manure_weak {
			pratice_water_pollution_level <- pratice_water_pollution_level * (1 + impact_support_manure_buying_waste_weak);
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
	

	action compute_production {
		current_productivity <- base_productivity;
		if does_implement_fallow {
			current_productivity <- current_productivity * (1 - impact_implement_fallow_production);
		}
		if use_more_manure_strong {
			current_productivity <- current_productivity * (1 + impact_support_manure_buying_production_strong);
		}
		if use_more_manure_weak {
			current_productivity <- current_productivity * (1 + impact_support_manure_buying_production_weak);
		}
		if does_reduce_pesticide {current_productivity <- current_productivity* (1 - impact_pesticide_reducing_production);}
		if the_village.is_drained_strong {
			current_productivity <- current_productivity * (1 + impact_drain_dredge_agriculture_strong);
		}
		if the_village.is_drained_weak {
			current_productivity <- current_productivity * (1 + impact_drain_dredge_agriculture_weak);
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
		current_production <- current_productivity * shape.area;
	//	write "" + cycle + " " + name + " " + sample(current_productivity) + " " + sample(current_production);
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
