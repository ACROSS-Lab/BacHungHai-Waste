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
		create simulation with:(without_player:true, without_actions:true);
	}
}

experiment the_serious_game parent: base_display_layout_test type: gui {
	action _init_ {
		create simulation with:(without_player:false);
	}
}
