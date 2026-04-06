/**
* Name: ExplorationModel
* Based on the internal empty template. 
* Author: patricktaillandier
* Tags: 
*/


model ExplorationModel

import "Abstract experiments.gaml" 

/* Insert your model definition here */



experiment simulation_without_players  type: gui {
	action _init_ {
		create simulation with:(without_player:true, without_actions:true);
	}
}


experiment test_batch type: batch until: current_date.year > 2 repeat: 10{
	
}