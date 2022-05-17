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
		display "Player 1"  background: #black refresh: stage = COMPUTE_INDICATORS{ 
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[0].canals sum_of each.water_waste_level + village[0].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[0].canals sum_of each.solid_waste_level + village[0].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		
		display "Player 2"  background: #black refresh: stage = COMPUTE_INDICATORS{ 
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[1].canals sum_of each.water_waste_level + village[1].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[1].canals sum_of each.solid_waste_level + village[1].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		display map type: opengl  background: #black axes: false refresh: stage = COMPUTE_INDICATORS  {
			event "1" action: activate_act1;
			event "2" action: activate_act2;
			event "3" action: activate_act3;
			event "4" action: activate_act4;
			event "5" action: activate_act5;
			event "6" action: activate_act6;
			event "7" action: activate_act7;
			event "8" action: activate_act8;
			event "9" action: activate_act9;
	
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
		display "Player 3"  axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[2].canals sum_of each.water_waste_level + village[2].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[2].canals sum_of each.solid_waste_level + village[2].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		display "Player 4" axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
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

experiment base_debug_graphic virtual: true {
	output{

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
			//define a new overlay layer positioned at the coordinate 5,5, with a constant size of 180 pixels per 100 pixels.
            overlay position: { 5, 5 } size: { 180 #px, 100 #px } background: #black transparency: 0.0 border: #black rounded: true
            {
            	
                float y <- 30#px;
       
                draw "TIME" at: { 40#px, y + 4#px } color: # white font: font("Helvetica", 24, #bold);
                y <- y + 25#px;
                draw "Day : " + cycle at: { 40#px, y } color: #white font: font("Helvetica", 18, #bold);
                y <- y + 100#px;
                      
                draw "ENVIRONMENT" at: { 40#px, y + 4#px } color: # white font: font("Helvetica", 24, #bold);
                y <- y + 25#px;
                draw square(10#px) at: { 20#px, y } color: first(house).color border: #white;
                draw "house" at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 18, #bold);
                y <- y + 25#px;
                draw square(10#px) at: { 20#px, y } color: first(plot).color border: #white;
                draw "plot" at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 18, #bold);
                y <- y + 25#px;
                draw square(10#px) at: { 20#px, y } color: #blue border: #white;
                draw "canal" at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 18, #bold);
                y <- y + 50#px;
                 
				y <- y + 100#px;
				draw "PEOPLE" at: { 40#px, y + 4#px } color: # white font: font("Helvetica", 24, #bold);
                y <- y + 25#px;
                draw circle(10#px) at: { 20#px, y } color: first(inhabitant).color ;
                draw "inhabitans" at: { 40#px, y + 4#px } color: # white font: font("Helvetica", 18, #bold);
                y <- y + 25#px;
                draw circle(10#px) at: { 20#px, y } color: first(farmer).color;
                draw "farmer" at: { 40#px, y + 4#px } color: # white font: font("Helvetica", 18, #bold);
                y <- y + 25#px;
                
                
                y <- y + 100#px;
                draw "LANDFILL" at: { 40#px, y + 4#px } color: # white font: font("Helvetica", 24, #bold);
                y <- y + 25#px;
                draw circle(10#px) at: { 20#px, y } color: #red border: #white;
                draw "local landfill" at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 18, #bold);
                y <- y + 50#px;
                draw circle(18#px) at: { 20#px, y } color: #red border: #white;
                draw "Communal  landfill" at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 18, #bold);
                y <- y + 25#px;
                
                if (without_player) {
                	draw "Actions: \n" +text_action at: { 40#px, y+ 30#px } color: # white font: font("Helvetica", 24, #bold);
            
                }
				

            } 
		}
	}
}


experiment simulation_without_players parent: base_debug type: gui {
	action _init_ {
		create simulation with:(without_player:true);
	}
}

experiment simulation_graphic parent: base_debug_graphic type: gui {
	action _init_ {
		create simulation with:(without_player:true);
	}
}


experiment the_serious_game parent: base_debug type: gui {
		action _init_ {
		create simulation with:(without_player:false);
	}
}
