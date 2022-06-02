/**
* Name: Hydrology
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/


model Hydrology

import "../Global.gaml"


species canal {
	float width;
	float solid_waste_level min: 0.0;
	float water_waste_level min: 0.0;
	float solid_waste_level_tmp;
	float water_waste_level_tmp;
	list<canal> downtream_canals;
	float pollution_density;
	
	
	action init_flow {
		solid_waste_level_tmp <- 0.0;
		water_waste_level_tmp <- 0.0;
	}
	action flow {
		
		float to_diffuse_solid <-  solid_waste_level / shape.perimeter  * rate_diffusion_solid_waste  ; 
		float to_diffuse_water <-  water_waste_level / shape.perimeter  * rate_diffusion_liquid_waste ; 
		
		int nb <- length(downtream_canals);
		if nb > 0 {
			ask downtream_canals {
				solid_waste_level_tmp <- solid_waste_level_tmp + to_diffuse_solid/ nb;
				water_waste_level_tmp <- water_waste_level_tmp +to_diffuse_water  / nb;
			}
		}
		solid_waste_level_tmp <- solid_waste_level_tmp - to_diffuse_solid ;
		water_waste_level_tmp <-  water_waste_level_tmp - to_diffuse_water;
	}
	action update_waste {
		solid_waste_level <- solid_waste_level + solid_waste_level_tmp;
		water_waste_level <- water_waste_level + water_waste_level_tmp ;
		pollution_density <- (solid_waste_level  + solid_waste_level * convertion_from_l_water_waste_to_kg_solid_waste) / shape.perimeter ;
	}
	aspect default {
		if display_water_flow {
			draw shape  + (width +3) color: #blue end_arrow: 40 ;
		} else if display_total_waste {
			draw shape  + (width +3) color: blend(#red,#blue,(solid_waste_level + convertion_from_l_water_waste_to_kg_solid_waste *water_waste_level)/shape.perimeter / coeff_visu_canal);
		} else if display_solid_waste {
			draw shape  + (width +3) color: blend(#red,#blue,(solid_waste_level)/shape.perimeter / coeff_visu_canal);
		} else if display_solid_waste {
			draw shape  + (width +3) color: blend(#red,#blue,(water_waste_level * convertion_from_l_water_waste_to_kg_solid_waste)/shape.perimeter / coeff_visu_canal);
		} else {
			draw shape  + (width +3) color: #blue;
		}
	}
}
