/**
* Name: GamePresentation
* Based on the internal skeleton template. 
* Author: Patrick Taillandier
* Tags: 
*/

model GamePresentation

import "../models/Global.gaml"  

global {
	bool display_water_flow <- false  parameter:"Display water flow" category: "Display" ;
	bool draw_territory <- false  parameter:"Display village" category: "Display" ;
	
	graph canal_network_<- nil;
	int number_to_add <- 10;
	reflex indicators_computation {}
	map<point, list<point>> possible_targets;
	reflex add_waste when: display_water_flow and every(20 #cycle){
		if canal_network_ = nil {
			canal_network_ <- directed(as_edge_graph(canal));
			list<point> sources <- canal_network_.vertices where (empty(canal_network_ in_edges_of each));
			list<point> targets <- canal_network_.vertices where (empty(canal_network_ out_edges_of each));
			loop s over: sources {
				list<point> ts <- [];
				loop t over: targets {
					if (canal_network_ path_between(s,t)) != nil {
						ts << t;
					}
				}
				
				possible_targets[s] <- ts;
			}
		}
		
		
		create waste_on_canal number: number_to_add {
			location <- one_of(possible_targets.keys);
			target <- one_of (possible_targets[location]);
		}
	}
}


species waste_on_canal skills: [moving]{
	float speed <- 20 / step;
	point target;
	aspect default {
		if display_water_flow {
			draw circle(30) color: #brown;
		} 
	}
	
	reflex move {
		point prev_loc <- copy(location);
		do goto target: target on:canal_network_ ;
		if location = target or location = prev_loc{
			do die;
		}
	}
}

experiment GamePresentation type: gui autorun: true {
	float minimum_cycle_duration <- 0.03;
	output synchronized: true {
			display map_abstract type: opengl  background: #black  axes: false  {
				species commune;
				species house;
				species plot;
				species canal;
				species inhabitant;
				species farmer;
				species local_landfill;
				species communal_landfill;
				species waste_on_canal;
				species village aspect: demo transparency: 0.5 ;
				species village aspect: demo_with_name;
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
