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
	float practice_water_pollution_level;
	float practice_solid_pollution_level;
	canal closest_canal;
	farmer the_farmer;
	list<cell> my_cells;
	communal_landfill the_communal_landfill;
	local_landfill the_local_landfill;	
	float the_communal_landfill_dist min: 1.0;
	float the_local_landfill_dist min: 1.0;
	bool impacted_by_canal <- false;
	float perimeter_canal_nearby; 
	rgb color<-#darkgreen-25;
	bool use_more_manure_strong <- false;
	bool use_more_manure_weak <- false;
	bool does_implement_fallow <- false;
	float solid_waste_day <-  solid_waste_year_farmers / 365;
	float water_waste_day <-  water_waste_year_farmers / 365;
	float part_solid_waste_canal <- part_solid_waste_canal_farmers;
	float part_water_waste_canal <- part_water_waste_canal_farmers;
	bool has_dumphole <- false;
	float water_waste_pollution;
	list<float> productitivy_improvement;
	
	action pollution_due_to_practice { 
		if does_implement_fallow {
			practice_solid_pollution_level <- 0.0;
			practice_water_pollution_level <- 0.0;
			water_waste_pollution <- my_cells sum_of each.water_waste_level;
		} else {
			practice_solid_pollution_level <- has_dumphole ? (solid_waste_day * (1 - impact_installation_dumpholes)): solid_waste_day;
			/*if does_reduce_pesticide {
				practice_solid_pollution_level <- practice_solid_pollution_level * (1 - impact_pesticide_reducing_waste);
			}*/
			
			if practice_solid_pollution_level > 0 {
				float to_the_canal <- practice_solid_pollution_level * part_solid_waste_canal;
				float to_the_ground <- practice_solid_pollution_level - to_the_canal;
				if to_the_canal > 0 {
					closest_canal.solid_waste_level <- closest_canal.solid_waste_level + to_the_canal;
				}
				if to_the_ground > 0 {
					ask one_of(my_cells) {
						solid_waste_level <- solid_waste_level + to_the_ground ;
					}
				}
			}
			
			practice_water_pollution_level <- water_waste_day;
			
		
			if use_more_manure_weak {
				practice_water_pollution_level <- practice_water_pollution_level * (2 + impact_support_manure_buying_waste_weak);}
			if use_more_manure_strong {
				practice_water_pollution_level <- practice_water_pollution_level * (2 + impact_support_manure_buying_waste_strong);
			}
			if does_reduce_pesticide {
				practice_water_pollution_level <- practice_water_pollution_level * (1 - impact_pesticide_reducing_waste);
			}
			if practice_water_pollution_level > 0 {
				float to_the_canal <- practice_water_pollution_level * part_water_waste_canal;
				float to_the_ground <- practice_water_pollution_level - to_the_canal;
				if to_the_canal > 0 {
					closest_canal.water_waste_level <- closest_canal.water_waste_level + to_the_canal;
				}
				if to_the_ground > 0 {
					int nb <- length(my_cells);
					ask one_of(my_cells) {
						water_waste_level <- water_waste_level + to_the_ground  ;
					}
				}
			}
			water_waste_pollution <- my_cells sum_of each.water_waste_level;
		}
	}
	
	float impact_lf;
	float impact_cl;
	
	float impact_sg;
	float impact_wg;
	
	float impact_cs;
	float impact_cw;

	action compute_production {
		if does_implement_fallow {
			current_productivity <- 0.0;
			current_production <- 0.0;
	//		write name + " does_implement_fallow";
		} else {
			current_productivity <- base_productivity;
			if not empty(productitivy_improvement) {
				current_productivity <- current_productivity * (1 + first(productitivy_improvement));
				
		//		write name + " current_productivity improved";
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
				impact_lf <- ((the_local_landfill.waste_quantity) * (local_landfill_waste_pollution_impact_rate) / the_local_landfill_dist);
				current_productivity <- current_productivity - ((the_local_landfill.waste_quantity) / the_local_landfill_dist * (local_landfill_waste_pollution_impact_rate));
			}
			if (the_communal_landfill != nil) {
				impact_lf <- 100/ base_productivity * the_communal_landfill.waste_quantity  / the_communal_landfill_dist * communal_landfill_waste_pollution_impact_rate;
				current_productivity <- current_productivity - the_communal_landfill.waste_quantity / the_communal_landfill_dist * communal_landfill_waste_pollution_impact_rate;
			}
			float solid_ground_pollution <- my_cells sum_of each.solid_waste_level;
			if (solid_ground_pollution > 0) {
				impact_sg <-  100/ base_productivity * solid_ground_pollution * ground_solid_waste_pollution_impact_rate;
				
				current_productivity <- current_productivity - solid_ground_pollution * ground_solid_waste_pollution_impact_rate;
			}
			float water_ground_pollution <- my_cells sum_of each.water_waste_level;
			if (water_ground_pollution > 0) {
				impact_wg <-  100/ base_productivity * water_ground_pollution * ground_water_waste_pollution_impact_rate;
				current_productivity <- current_productivity - water_ground_pollution * ground_water_waste_pollution_impact_rate;
			}
			if impacted_by_canal {
				 impact_cs <- 100/ base_productivity * closest_canal.solid_waste_level * canal_solid_waste_pollution_impact_rate;
				 impact_cw <- 100/ base_productivity * closest_canal.water_waste_level * canal_water_waste_pollution_impact_rate;
				
				current_productivity <- current_productivity - closest_canal.solid_waste_level * canal_solid_waste_pollution_impact_rate; 
				current_productivity <- current_productivity - closest_canal.water_waste_level * canal_water_waste_pollution_impact_rate; 
			}
			current_production <- current_productivity * shape.area;
		//	write "" + cycle + " " + name + " " + sample(current_productivity) + " " + sample(current_production);
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
