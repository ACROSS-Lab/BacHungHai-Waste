/**
* Name: Debug
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/


model Debug

import "Abstract experiments.gaml"

experiment base_debug virtual: true {
	output{
		display "Player 1"  type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[0].canals sum_of each.water_waste_level + village[0].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[0].canals sum_of each.solid_waste_level + village[0].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		
		display "Player 2"  type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[1].canals sum_of each.water_waste_level + village[1].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[1].canals sum_of each.solid_waste_level + village[1].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		display map type: opengl  background: #black axes: false refresh: stage = COMPUTE_INDICATORS{
			species commune;
			species house;
			species plot;
			species canal;
			species cell transparency: 0.5 ;
			species inhabitant;
			species farmer;
			species collection_team;
			species local_landfill;
			species communal_landfill;
			species village transparency: 0.5 ; 
		}
		display "Player 3"  type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[2].canals sum_of each.water_waste_level + village[2].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[2].canals sum_of each.solid_waste_level + village[2].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		display "Player 4" type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[3].canals sum_of each.water_waste_level + village[3].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[3].canals sum_of each.solid_waste_level + village[3].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		display "global indicators" background: #black refresh: stage = COMPUTE_INDICATORS{
			chart "Waste pollution " size:{1.0, 0.3} background: #black color: #white{
				data "Water waste pollution" value: canal sum_of each.water_waste_level + cell sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0, 1/3} size:{1.0, 1/3} background: #black color: #white{
				data "Solid waste pollution" value: canal sum_of each.solid_waste_level + cell sum_of each.solid_waste_level  color: #red marker: false;
			}			
		}
	}
}


experiment simulation_without_players parent: base_debug type: gui {
	action _init_ {
		create simulation with:(without_player:true);
	}
}


experiment the_serious_game parent: base_debug type: gui {
	float minimum_cycle_duration <- 0.01;
	output {
		display action_buton background:#black name:"Tools panel"  	{
			
			species button aspect:normal ;
			event mouse_down action:activate_act;   
			event "1" action: activate_act1;
			event "2" action: activate_act2;
			event "3" action: activate_act3;
			event "4" action: activate_act4;
			event "5" action: activate_act5;
			event "6" action: activate_act6;
			event "7" action: activate_act7;
			event "8" action: activate_act8;
			event "9" action: activate_act9;
	
		}
		
	}
}
