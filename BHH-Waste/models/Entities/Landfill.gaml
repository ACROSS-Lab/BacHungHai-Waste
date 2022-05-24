/**
* Name: Landfill
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/


model Landfill

import "../Global.gaml"

species local_landfill {
	village my_village;
	float waste_quantity;
	
	aspect default {
		draw shape depth: waste_quantity / 100.0 border: #blue color: #red;
	}
		
	action transfert_waste_to_communal_level {
		if waste_quantity > 0 {
			float to_transfert <- min(quantity_from_local_to_communal_landfill, waste_quantity);
			the_communal_landfill.waste_quantity <- the_communal_landfill.waste_quantity + to_transfert;
			waste_quantity <- waste_quantity - to_transfert;
		}
		
	}
}

species communal_landfill {
	float waste_quantity min: 0.0;
	
	aspect default {
		draw  shape depth: waste_quantity / 100.0 border: #blue color: #red;
	}
	
	action manage_waste {
		if waste_quantity > 0 {
			waste_quantity <- waste_quantity - quantity_communal_landfill_to_treatment;
		}
		
	}
}
