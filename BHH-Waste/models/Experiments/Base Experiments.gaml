/**
* Name: BaseExperiments
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/


model BaseExperiments 

import "Abstract experiments.gaml"


experiment simulation_without_players parent: base_display_layout_test type: gui {
	action _init_ {
		create simulation with:(without_player:true);
	}
}

experiment the_serious_game parent: base_display_layout_test type: gui {
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
