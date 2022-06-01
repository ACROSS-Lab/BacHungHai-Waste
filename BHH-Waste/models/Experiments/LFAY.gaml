/**
* Name: LFAY
* The model used for the LFAY 2-days demonstrations  
* Author: A. Drogoul
* Tags: 
*/

@no_warning
model LFAY

import "../Global.gaml"
import "../Charts.gaml"

global {
	
	pie_chart turn_timer;
	pie_chart days_timer;
	
	
	init {
		create pie_chart {
			radius <- 5000;
			do add("Turns", 0.0, #black);
			do add("Total", 8.0 * 365, rgb(50,50,50));
			location <- {-world.shape.width ,world.shape.height/2};
		}
		turn_timer <- pie_chart[0];
		create pie_chart {
			radius <- 5000;
			do add("Days", 80.0, #green);
			do add("Total", 285, rgb(50,50,50));
			location <- {2* world.shape.width ,world.shape.height/2};
		}
		days_timer <- pie_chart[1];
		
	}
	
	reflex when: stage = COMPUTE_INDICATORS{
		ask turn_timer {
			do increment("Turns", 1);
			do increment("Total", -1);
		}
	}

}




experiment Open {
	
	
	init {
		gama.pref_display_slice_number <- 128;
	}
	
	/********************** PROPORTION OF THE DISPLAYS ****************************/
	
	int small_prop <- 1500;
	int large_prop <- 3500;
	
	/********************** ICONS *************************************************/
	
	image_file soil_icon <- image_file("../../includes/icons/soil.png");
	image_file water_icon <- image_file("../../includes/icons/water.png");
	image_file plant_icon <- image_file("../../includes/icons/plant.png");
	list<image_file> smileys <- [image_file("../../includes/icons/0.png"), image_file("../../includes/icons/1.png"), image_file("../../includes/icons/2.png"), image_file("../../includes/icons/3.png"), image_file("../../includes/icons/4.png")];
 	list<image_file> arrows <- [image_file("../../includes/icons/up.png"), image_file("../../includes/icons/down.png"), image_file("../../includes/icons/equal.png")];

	/********************** COLORS ************************************************/
	
	rgb map_background <- #black;
	rgb player_background <- #white;
	rgb timer_background <- #gray;
	
	/********************** ICONS' POSITIONS AND SIZES ****************************/
	
	float y_icons -> simulation.shape.height - icon_size;
	float x_margin -> simulation.shape.width / 20;
	float icon_size -> simulation.shape.width / 8;
	point symbol_icon_size -> {icon_size,icon_size};
	point arrow_icon_size -> {icon_size/2,icon_size/2};
	point smiley_icon_size -> {2*icon_size/3,2*icon_size/3};
	
	
	output {
		
		/********************** LAYOUT ***********************************************************/
		
		layout
		horizontal(
			[
				vertical([0::small_prop, 1::large_prop, 2::small_prop])::small_prop, 
				vertical([3::small_prop, 4::large_prop, 5::small_prop])::large_prop, 
				vertical([6::small_prop, 7::large_prop, 8::small_prop])::small_prop
				
			]
			)
		toolbars: false tabs: false parameters: false consoles: false navigator: false controls: true tray: false background: #black;
		
		/********************** PLAYER 1 DISPLAY *************************************************/

		display "PLAYER 1" type: java2D background: player_background refresh: stage = COMPUTE_INDICATORS {
						
			graphics "Behind" {
				draw shape color: #white;
			}
			
			species commune position: {shape.width*0.15, 0} size: {0.7,0.7}{
				draw shape color:rgb(220,220,220);
			}


			agents "Village" value: ([village[0]]) transparency: 0.5  position: {shape.width*0.15, 0} size: {0.7,0.7}{
				draw shape color:  village_color[0] border: #black;
			}
			
			graphics "Frame" transparency: 0.5 {
				//draw rectangle(shape.width, shape.height) - rectangle(shape.width-x_margin, shape.height-x_margin) color: village_color[3];
				//draw rectangle(shape.width, icon_size*2) at: {shape.width/2,y_icons} color: #darkgray;
			}
			
			graphics "Text" {
				draw "Player 1" color: #black font: font("Impact", 30, #bold) anchor: #center at: {shape.width/2, shape.height/3};
			}
			
			graphics "Icons" {
				draw soil_icon at: {x_margin + 1*icon_size / 2, y_icons} size: symbol_icon_size;
				draw one_of(smileys) at: {x_margin +3*icon_size/2, y_icons - icon_size/4} size: smiley_icon_size;
				draw one_of(arrows) at: {x_margin +3*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw water_icon at: {x_margin +6*icon_size/2,  y_icons} size: symbol_icon_size;
				draw one_of(smileys) at: {x_margin +8*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw one_of(arrows) at: {x_margin +8*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw plant_icon at: {x_margin +11*icon_size/2, y_icons} size: symbol_icon_size;
				draw one_of(smileys) at: {x_margin +13*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw one_of(arrows) at: {x_margin +13*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
			}

		}
		
		/********************** LEGEND DISPLAY *************************************************/

		display "LEGEND" type: opengl axes: false background: map_background refresh: stage = COMPUTE_INDICATORS {
		}
		
				
		/********************** PLAYER 4 DISPLAY ***************************************************/
		
		display "Player 4" type: java2D axes: false background: player_background refresh: stage = COMPUTE_INDICATORS {
						
			graphics "Behind" {
				draw shape color: #white;
			}
			
			species commune position: {shape.width*0.15, 0} size: {0.7,0.7}{
				draw shape color:rgb(220,220,220);
			}


			agents "Village" value: ([village[3]]) transparency: 0.5  position: {shape.width*0.15, 0} size: {0.7,0.7}{
				draw shape color:  village_color[3] border: #black;
			}
			
			graphics "Frame" transparency: 0.5 {
				//draw rectangle(shape.width, shape.height) - rectangle(shape.width-x_margin, shape.height-x_margin) color: village_color[3];
				//draw rectangle(shape.width, icon_size*2) at: {shape.width/2,y_icons} color: #darkgray;
			}
			
			graphics "Text" {
				draw "Player 4" color: #black font: font("Impact", 30, #bold) anchor: #center at: {shape.width/2, shape.height/3};
			}
			
			graphics "Icons" {
				draw soil_icon at: {x_margin + 1*icon_size / 2, y_icons} size: symbol_icon_size;
				draw one_of(smileys) at: {x_margin +3*icon_size/2, y_icons - icon_size/4} size: smiley_icon_size;
				draw one_of(arrows) at: {x_margin +3*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw water_icon at: {x_margin +6*icon_size/2,  y_icons} size: symbol_icon_size;
				draw one_of(smileys) at: {x_margin +8*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw one_of(arrows) at: {x_margin +8*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw plant_icon at: {x_margin +11*icon_size/2, y_icons} size: symbol_icon_size;
				draw one_of(smileys) at: {x_margin +13*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw one_of(arrows) at: {x_margin +13*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
			}

		}


		
		
		/********************** CENTER TOP DISPLAY *************************************************/
		
		display "CENTER TOP" type: opengl axes: false background: timer_background  {
			agents "Turn" value: [turn_timer, days_timer];
			graphics "Turn#" {
				draw ""+turn  color: #yellow font: font("Impact", 80, #bold) anchor: #center at: {-world.shape.width ,world.shape.height/2, 20} border: #black;
				draw ""+int(days_timer.slices["Days"].value)  color: #yellow font: font("Impact", 80, #bold) anchor: #center at: {2*world.shape.width ,world.shape.height/2, 20} border: #black;
			}
			
		}

		/********************** MAIN MAP DISPLAY ***************************************************/
		
		display "MAIN MAP" type: opengl background: map_background axes: false refresh: stage = COMPUTE_INDICATORS {
			species house {
				draw shape color: rgb(50,50,50);
			}
			species plot {
				draw shape color: rgb(0,rnd(255),0)  border: false;
			}
			species canal {
				draw shape+10 color: one_of(brewer_colors("Blues"));
			}
			species local_landfill;
			species communal_landfill;
		}

		/********************** TIMER DISPLAY ***************************************************/
	
		display "TIMER" type: opengl axes: false background: timer_background refresh: stage = COMPUTE_INDICATORS {
		}

		/********************** PLAYER 2 DISPLAY *************************************************/
		
		display "Player 2" type: java2D axes: false background: player_background refresh: stage = COMPUTE_INDICATORS {
						
			graphics "Behind" {
				draw shape color: #white;
			}
			
			species commune position: {shape.width*0.15, 0} size: {0.7,0.7}{
				draw shape color:rgb(220,220,220);
			}


			agents "Village" value: ([village[1]]) transparency: 0.5  position: {shape.width*0.15, 0} size: {0.7,0.7}{
				draw shape color:  village_color[1] border: #black;
			}
			
			graphics "Frame" transparency: 0.5 {
				//draw rectangle(shape.width, shape.height) - rectangle(shape.width-x_margin, shape.height-x_margin) color: village_color[3];
				//draw rectangle(shape.width, icon_size*2) at: {shape.width/2,y_icons} color: #darkgray;
			}
			
			graphics "Text" {
				draw "Player 2" color: #black font: font("Impact", 30, #bold) anchor: #center at: {shape.width/2, shape.height/3};
			}
			
			graphics "Icons" {
				draw soil_icon at: {x_margin + 1*icon_size / 2, y_icons} size: symbol_icon_size;
				draw one_of(smileys) at: {x_margin +3*icon_size/2, y_icons - icon_size/4} size: smiley_icon_size;
				draw one_of(arrows) at: {x_margin +3*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw water_icon at: {x_margin +6*icon_size/2,  y_icons} size: symbol_icon_size;
				draw one_of(smileys) at: {x_margin +8*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw one_of(arrows) at: {x_margin +8*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw plant_icon at: {x_margin +11*icon_size/2, y_icons} size: symbol_icon_size;
				draw one_of(smileys) at: {x_margin +13*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw one_of(arrows) at: {x_margin +13*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
			}

		}

		/********************** CHARTS DISPLAY ***************************************************/
		
		display "Chart 4" type: opengl axes: false background: map_background refresh: stage = COMPUTE_INDICATORS {
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[2].canals sum_of each.water_waste_level + village[2].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[2].canals sum_of each.solid_waste_level + village[2].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		
				
		/********************** PLAYER 3 DISPLAY ***************************************************/

		display "Player 3" type: java2D refresh: stage = COMPUTE_INDICATORS background: player_background {
						
			graphics "Behind" {
				draw shape color: #white;
			}
			
			species commune position: {shape.width*0.15, 0} size: {0.7,0.7}{
				draw shape color:rgb(220,220,220);
			}


			agents "Village" value: ([village[2]]) transparency: 0.5  position: {shape.width*0.15, 0} size: {0.7,0.7}{
				draw shape color:  village_color[2] border: #black;
			}
			
			graphics "Frame" transparency: 0.5 {
				//draw rectangle(shape.width, shape.height) - rectangle(shape.width-x_margin, shape.height-x_margin) color: village_color[3];
				//draw rectangle(shape.width, icon_size*2) at: {shape.width/2,y_icons} color: #darkgray;
			}
			
			graphics "Text" {
				draw "Player 3" color: #black font: font("Impact", 30, #bold) anchor: #center at: {shape.width/2, shape.height/3};
			}
			
			graphics "Icons" {
				draw soil_icon at: {x_margin + 1*icon_size / 2, y_icons} size: symbol_icon_size;
				draw one_of(smileys) at: {x_margin +3*icon_size/2, y_icons - icon_size/4} size: smiley_icon_size;
				draw one_of(arrows) at: {x_margin +3*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw water_icon at: {x_margin +6*icon_size/2,  y_icons} size: symbol_icon_size;
				draw one_of(smileys) at: {x_margin +8*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw one_of(arrows) at: {x_margin +8*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw plant_icon at: {x_margin +11*icon_size/2, y_icons} size: symbol_icon_size;
				draw one_of(smileys) at: {x_margin +13*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw one_of(arrows) at: {x_margin +13*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
			}

		}


	}

	
}