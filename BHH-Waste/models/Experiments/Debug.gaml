/**
* Name: Debug
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/

 
model Debug

import "Abstract experiments.gaml"

experiment abstract_debug virtual: true {
		output {
			display map_abstract type: opengl  background: #black virtual: true axes: false refresh: stage = COMPUTE_INDICATORS{
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
	                draw "inhabitants" at: { 40#px, y + 4#px } color: # white font: font("Helvetica", 18, #bold);
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
	                
	                if not(without_player) {
	                	draw "Actions: \n" +text_action at: { 40#px, y+ 30#px } color: # white font: font("Helvetica", 24, #bold);
	            
	                }
					
	
	            } 
			}
		
	}
}
experiment base_debug parent: abstract_debug virtual: true {
	output{
		display map type: opengl parent: map_abstract  background: #black axes: false refresh: stage = COMPUTE_INDICATORS or to_refresh {
			event "q" action: activate_act1;
			event "w" action: activate_act2;
			event "e" action: activate_act3;
			event "r" action: activate_act4;
			event "t" action: activate_act5;
			event "y" action: activate_act6;
			event "u" action: activate_act7;
			event "i" action: activate_act8;
			event "o" action: activate_act9;
		
		}
		
		display "global indicators" background: #black refresh: stage = COMPUTE_INDICATORS and every(5#cycle){
			chart "Waste pollution "  size:{1.0, 0.5} background: #black color: #white{
				data "Solid waste pollution" value: total_solid_pollution color: #gray marker: false;
				data "Water waste pollution" value: total_water_pollution color: #orange marker: false;
		 		data "Total pollution" value:total_water_pollution +  total_solid_pollution color: #red marker: false;
		 		data "Ecol labal max pollution" value:max_pollution_ecolabel color: #white marker: false;
			}
			chart "Productivity " position:{0.0, 0.5}  size:{1.0, 0.5} background: #black color: #white{
				data "Productivity" value: total_productivity color: #blue marker: false; 
				data "Ecol labal min productivity" value: min_production_ecolabel color: #white marker: false; 
			}			
		}
		display "Player 1"  background: #black refresh: stage = COMPUTE_INDICATORS and every(5#cycle){ 
			chart "Waste pollution "  size:{1.0, 0.5} background: #black color: #white{
				data "Solid waste pollution" value: village1_solid_pollution  color: #gray marker: false;
				data "Water waste pollution" value: village1_water_pollution  color: #red marker: false;
		 
			} 
			chart "Productivity " position:{0.0, 0.5} size:{1.0, 0.5} background: #black color: #white{
				data "Productivity" value: village1_productivity color: #blue marker: false; 
			}
		}
		
		display "Player 2"  background: #black refresh: stage = COMPUTE_INDICATORS and every(5#cycle){ 
			chart "Waste pollution " size:{1.0, 0.5} background: #black color: #white{
				data "Solid waste pollution" value: village2_solid_pollution  color: #gray marker: false;
				data "Water waste pollution" value: village2_water_pollution  color: #red marker: false;
		 
			}
			chart "Productivity " position:{0.0, 0.5} size:{1.0, 0.5} background: #black color: #white{
				data "Productivity" value:village2_productivity color: #blue marker: false; 
			}
		}
		
		display "Player 3"  axes: false background: #black refresh: stage = COMPUTE_INDICATORS and every(5#cycle){ 
			chart "Waste pollution "  size:{1.0, 0.5} background: #black color: #white{
				data "Solid waste pollution" value: village3_solid_pollution  color: #gray marker: false;
				data "Water waste pollution" value: village3_water_pollution  color: #red marker: false;
			}
			chart "Productivity " position:{0.0, 0.5}  size:{1.0, 0.5} background: #black color: #white{
				data "Productivity" value:village3_productivity color: #blue marker: false; 
			}
		}
		display "Player 4" axes: false background: #black refresh: stage = COMPUTE_INDICATORS and every(5#cycle){ 
			chart "Waste pollution "  size:{1.0, 0.5} background: #black color: #white{
				data "Solid waste pollution" value: village4_solid_pollution  color: #gray marker: false;
				data "Water waste pollution" value: village4_water_pollution  color: #red marker: false;
			}
			chart "Productivity " position:{0.0, 0.5}  size:{1.0, 0.5} background: #black color: #white{
				data "Productivity" value: village4_productivity color: #blue marker: false; 
			}
		}
		
	}
}


experiment simulation_without_players parent: base_debug type: gui {
	action _init_ {
		create simulation with:(without_player:true);
	}
}

experiment simulation_graphic parent: abstract_debug type: gui {
	action _init_ {
		create simulation with:(without_player:true);
	}
	output{
		display map type: opengl parent: map_abstract  background: #black axes: false refresh: stage = COMPUTE_INDICATORS or to_refresh {}
	
	}
		
}


experiment the_serious_game parent: base_debug type: gui {
	action _init_ {
		create simulation with:(without_player:false);
	}
}
