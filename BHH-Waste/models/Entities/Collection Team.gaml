/**
* Name: CollectionTeam
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/


model CollectionTeam

import "../Global.gaml" 


species collection_team {
	rgb color <- #gold;
	float collection_capacity <- collection_team_collection_capacity_day;
	list<int> collection_days <- days_collects_default;
	village my_village;
	
	
	action collect_waste(list<cell> cells_to_clean) { 
		float waste_collected <- 0.0;
		loop while: waste_collected < collection_capacity  {
			if empty(cells_to_clean) {
				break;
			}
			else { 
				cell the_cell <- one_of(cells_to_clean);
				cells_to_clean >> the_cell;
				ask the_cell{
					float w <- min(myself.collection_capacity - waste_collected, solid_waste_level);
					waste_collected <- waste_collected + w;
					solid_waste_level <- solid_waste_level  - w;
				}
			}
		}
		//write sample(waste_collected);
		ask my_village.my_local_landfill {
			waste_quantity <- waste_quantity + waste_collected;
		}
	}
}