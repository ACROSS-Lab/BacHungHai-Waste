
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
			display map_abstract type: opengl  background: #black virtual: true axes: false {//refresh: stage = COMPUTE_INDICATORS{
				species commune;
				species house;
				species plot;
				species canal;
				species cell transparency: 0.5;
				species inhabitant;
				species farmer;
				species collection_team;
				species local_landfill;
				species communal_landfill;
				species village aspect: border_geom ;
				
				species village transparency: 0.5 ;
				graphics "Village name" {
					  draw "Village 1" at: { world.location.x, -500 } color: village[0].color anchor: #center font: font("Impact", 30, #bold);
					  draw "Village 2" at: { world.location.x * 2 +1000, world.location.y + 500} anchor: #center color: village[1].color font: font("Impact", 30, #bold);
					  draw "Village 3" at: { world.location.x, world.location.y * 2} anchor: #center color: village[2].color font: font("Impact", 30, #bold);
					  draw "Village 4" at: {-1000, world.location.y } color:village[3].color anchor: #center font: font("Impact", 30, #bold);
	              
				}
				//define a new overlay layer positioned at the coordinate 5,5, with a constant size of 180 pixels per 100 pixels.
	            overlay position: { 5, 5 } size: { 180 #px, 100 #px } background: #black transparency: 0.0 border: #black rounded: true
	            {
	            	
	                float y <- 30#px;
	       
	                draw "TIME" at: { 40#px, y + 4#px } color: # white font: font("Helvetica", 24, #bold);
	                y <- y + 25#px;
	                draw "Year: " + turn + " - Day: " + current_day at: { 40#px, y } color: #white font: font("Helvetica", 18, #bold);
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
	                
	               
	
	            } 
			}
		
	}
}
experiment base_debug parent: abstract_debug virtual: true {
	output{
		 layout horizontal([vertical([1::5000,2::5000])::4541,vertical([horizontal([3::5000,4::5000])::5000,horizontal([5::5000,6::5000])::5000])::5459]) tabs:true editors: false;
		display time_info background: #black type: opengl axes: false toolbar: false{
			
			graphics "TIMER" {
				if use_timer_player_turn and stage = PLAYER_ACTION_TURN {
					draw "Remaining time for the Player " + (index_player + 1) + ":" at: world.location  anchor: #center color: #white font: font("Helvetica", 100, #bold);
				
					draw "" + remaining_time +" s" at: world.location + {0,200#px} anchor: #center color: #white font: font("Impact", 200, #bold);
				}
				if use_timer_for_discussion and stage = PLAYER_DISCUSSION_TURN {
					draw "Remaining time for the discussion: "  at: world.location  anchor: #center color: #white font: font("Helvetica", 100, #bold);
				
					draw "" + remaining_time +" s" at: world.location + {0,200#px} anchor: #center color: #white font: font("Impact", 200, #bold);
				}
				
			}
			
		}
		display info_display background: (is_production_ok and is_pollution_ok) ? #darkgreen : #darkred type: opengl axes: false toolbar: false {
			graphics "info Ecolabel" {
				draw  (is_production_ok and is_pollution_ok)  ? "Meets the standards of the ecolabel" : "Do not meet the standards of the ecolabel!"  at: { 0, -600 } color: #white font: font("Helvetica", 40, #bold);
			}
		
			graphics "info day" {
				draw "Year: " + turn + " - Day: " + current_day  at: { 40#px, 0#px } color: #white font: font("Helvetica", 40, #bold);
			}
			graphics "info Player" {
				if (stage = PLAYER_ACTION_TURN) {
					draw "Turn of player: " + (index_player + 1)  at: { 40#px, 50#px } color: #white font: font("Helvetica", 36, #bold);
				}  else if (stage = PLAYER_DISCUSSION_TURN) {
					draw "Discussion phase"  at: { 40#px, 50#px } color: #white font: font("Helvetica", 36, #bold);
			
				}else if (stage = COMPUTE_INDICATORS) {
					draw "Simulation phase"  at: { 40#px, 50#px } color: #white font: font("Helvetica", 36, #bold);
			
				}
			}
			graphics "Money Player" {
				draw "Player 1: " + village[0].budget + " tokens - Num farmer households:" + length(village[0].farmers) +" Num urban households: " + length(village[0].inhabitants)    at: { 40#px, 100#px } color: #white font: font("Helvetica", 24, #bold);
				draw "Player 2: " + village[1].budget + " tokens - Num farmer households:" + length(village[1].farmers) +" Num urban households: " + length(village[1].inhabitants)   at: { 40#px, 150#px } color: #white font: font("Helvetica", 24, #bold);
				draw "Player 3: " + village[2].budget + " tokens - Num farmer households:" + length(village[2].farmers) +" Num urban households: " + length(village[2].inhabitants)   at: { 40#px, 200#px } color: #white font: font("Helvetica", 24, #bold);
				draw "Player 4: " + village[3].budget + " tokens - Num farmer households:" + length(village[3].farmers) +" Num urban households: " + length(village[3].inhabitants)   at: { 40#px, 250#px } color: #white font: font("Helvetica", 24, #bold);
			}
			graphics "info action"{
			 if not(without_player) {
			 	draw "Actions:" at: { 40#px, 310#px } color: #white font: font("Helvetica", 24, #bold);
	                draw text_action at: { 40#px,  340#px } color: #white font: font("Helvetica", 20, #plain);
	          }
	          
			}
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
		display map type: opengl parent: map_abstract  background: #black axes: false{//} refresh: stage = COMPUTE_INDICATORS or to_refresh {
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
		
		display "global indicators" background: #black refresh: stage = COMPUTE_INDICATORS and every(data_frequency#cycle){
			chart "Waste pollution "  size:{1.0, 0.5} type: xy background: #black color: #white{
				data "Solid waste pollution" value:rows_list(matrix([time_step,total_solid_pollution_values])) color: #gray marker: false thickness: 2.0 ;
				data "Water waste pollution" value: rows_list(matrix([time_step,total_water_pollution_values])) color: #orange marker: false thickness: 2.0 ;
		 		data "Total pollution " value:rows_list(matrix([time_step,total_pollution_values])) color:is_pollution_ok ? #green: #red marker: false thickness: 2.0;
		 		data "Ecol labal max pollution" value:rows_list(matrix([time_step,ecolabel_max_pollution_values])) color: #white marker: false thickness: 2.0 ;
			}
			chart "Production" type: xy position:{0.0, 0.5}  size:{1.0, 0.5} background: #black color: #white y_range:[1300,2200]{
				data "Production" value: rows_list(matrix([time_step,total_production_values])) color: is_production_ok ? #green : #red thickness: 2.0 marker: false; 
				data "Ecol labal min production" value: rows_list(matrix([time_step,ecolabel_min_production_values])) thickness: 2.0 color: #white marker: false; 
			}
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
		display "Player 1"  background: #black refresh: stage = COMPUTE_INDICATORS and every(data_frequency#cycle){ 
			
			chart "Waste pollution "  size:{1.0, 0.5} type: xy background: #black color: #white {
				data "Solid waste pollution" value:rows_list(matrix([time_step,village1_solid_pollution_values])) color: #gray marker: false thickness: 2.0 ;
				data "Water waste pollution" value:rows_list(matrix([time_step,village1_water_pollution_values])) color: #orange marker: false thickness: 2.0 ;
		 
			} 
			chart "Production" type: xy position:{0.0, 0.5} size:{1.0, 0.5} background: #black color: #white  y_range:[0,1000]{
				data "Production" value:rows_list(matrix([time_step,village1_production_values])) color: #blue marker: false thickness: 2.0 ; 
			}
			graphics "Lengend" {	
				draw "Player 1" at: {20, world.location.y - 500} color: #white rotate: -90 font: font("Impact", 16, #bold) ;
			}
		}
		
		display "Player 2"  background: #black refresh: stage = COMPUTE_INDICATORS and every(data_frequency#cycle){ 
			chart "Waste pollution" type: xy size:{1.0, 0.5} background: #black color: #white {
				data "Solid waste pollution" value:rows_list(matrix([time_step,village2_solid_pollution_values]))  color: #gray marker: false thickness: 2.0 ;
				data "Water waste pollution" value:rows_list(matrix([time_step,village2_water_pollution_values]))   color: #orange marker: false thickness: 2.0 ;
		 
			}
			chart "Production"  type: xy position:{0.0, 0.5} size:{1.0, 0.5} background: #black color: #white  y_range:[0,1000]{
				data "Production" value:rows_list(matrix([time_step,village2_production_values]))  color: #blue marker: false thickness: 2.0 ; 
			}
			graphics "Lengend" {	
				draw "Player 2" at: {20, world.location.y - 500}  color: #white rotate: -90 font: font("Impact", 16, #bold) ;
			}
		}
		
		display "Player 3"  axes: false background: #black refresh: stage = COMPUTE_INDICATORS and every(data_frequency#cycle){ 
			chart "Waste pollution " type: xy  size:{1.0, 0.5} background: #black color: #white  {
				data "Solid waste pollution" value:rows_list(matrix([time_step,village3_solid_pollution_values]))  color: #gray marker: false thickness: 2.0 ;
				data "Water waste pollution" value:rows_list(matrix([time_step,village3_water_pollution_values]))   color: #orange marker: false thickness: 2.0 ;
			}
			chart "Production" type: xy position:{0.0, 0.5}  size:{1.0, 0.5} background: #black color: #white  y_range:[0,1000]{
				data "Production" value:rows_list(matrix([time_step,village3_production_values]))  color: #blue marker: false thickness: 2.0 ; 
			}
			graphics "Lengend" {	
				draw "Player 3" at: {20, world.location.y - 500} color: #white rotate: -90 font: font("Impact", 16, #bold) ;
			}
		}
		display "Player 4" axes: false background: #black refresh: stage = COMPUTE_INDICATORS and every(data_frequency#cycle){ 
			chart "Waste pollution"  type: xy size:{1.0, 0.5} background: #black color: #white  {
				data "Solid waste pollution" value:rows_list(matrix([time_step,village4_solid_pollution_values]))  color: #gray marker: false thickness: 2.0 ;
				data "Water waste pollution" value:rows_list(matrix([time_step,village4_water_pollution_values]))   color: #orange marker: false thickness: 2.0 ;
			}
			chart "Production"type: xy  position:{0.0, 0.5}  size:{1.0, 0.5} background: #black color: #white y_range:[0,1000]{
				data "Production" value:rows_list(matrix([time_step,village4_production_values]))  color: #blue marker: false thickness: 2.0 ; 
			}
			graphics "Lengend" {	
				draw "Player 4" at: {20, world.location.y - 500} color: #white rotate: -90 font: font("Impact", 16, #bold) ;
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
