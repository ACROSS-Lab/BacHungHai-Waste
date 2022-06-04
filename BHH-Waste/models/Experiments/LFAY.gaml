/**
* Name: LFAY
* The model used for the LFAY 2-days demonstrations  
* Author: A. Drogoul
* Tags: 
*/

model LFAY

import "../Global.gaml"
import "../Charts.gaml"
 
global {
	
	

	/********************** COLORS ************************************************/
	
	rgb map_background <- #black;
	rgb player_background <- #white;
	rgb timer_background <- #gray;
	rgb text_color <- rgb(228, 233, 190);
	rgb pie_background <- rgb(162, 179, 139);
	int ambient_intensity <- 100;
	rgb not_selected_color <- text_color;
	rgb selected_color <- pie_background.darker;
	rgb button_color <- not_selected_color;
	
	/********************** ICONS *************************************************/
	
	image_file player_icon <- image_file("../../includes/icons/man.png");
	image_file label_icon <- image_file("../../includes/icons/ecolabel.png");
	image_file soil_icon <- image_file("../../includes/icons/soil.png");
	image_file tokens_icon <- image_file("../../includes/icons/tokens.png");
	image_file water_icon <- image_file("../../includes/icons/water.png");
	image_file plant_icon <- image_file("../../includes/icons/plant.png");
	list<image_file> smileys <- [image_file("../../includes/icons/0.png"), image_file("../../includes/icons/1.png"), image_file("../../includes/icons/2.png"), image_file("../../includes/icons/3.png"), image_file("../../includes/icons/4.png")];
 	list<image_file> arrows <- [image_file("../../includes/icons/up.png"), image_file("../../includes/icons/down.png"), image_file("../../includes/icons/equal.png")];
	image_file calendar_icon <- image_file("../../includes/icons/calendar.png");
	image_file discussion_icon <- image_file("../../includes/icons/conversation.png");
	image_file sandclock_icon <- image_file("../../includes/icons/hourglass.png");
	image_file computer_icon <- image_file("../../includes/icons/simulation.png");
	image_file next_icon <- image_file("../../includes/icons/next.png");

	
	
	list<rgb> village_color <- [rgb(153, 187, 173), rgb(235, 216, 183), rgb(198, 169, 163), rgb(154, 129, 148)]; // color for the 4 villages
	
	pie_chart turn_timer;
	pie_chart days_timer;
	pie_chart discussion_timer;
	stacked_chart global_chart;
	
	
	init {
		write world.shape.width;
		write world.shape.height;		
		create stacked_chart {
			size <- world.shape.height;
			desired_value <- 2000.0;
			max_value <- 3000.0;
			ratio <- size / max_value;
			desired_icon <- label_icon;
			do add_column("Water");
			do add_column("Soil");
			do add_column("Production");
			icons <- ["Water"::water_icon, "Soil"::soil_icon, "Production"::plant_icon];
			loop i from: 0 to: 3 {
				do add_element(village_color[i]);
				do update_all(village_color[i], ["Water"::rnd(1000), "Soil"::rnd(500), "Production"::rnd(500) ]);
			}
		}
		global_chart <- stacked_chart[0];
		create pie_chart {
			do add("Turns", 0.0, #black);
			do add("Total", 8.0 * 365, pie_background);
		}
		turn_timer <- pie_chart[0];
		create pie_chart {
			do add("Days", 80.0, #green);
			do add("Total", 285.0, pie_background);
		}
		days_timer <- pie_chart[1];
		create pie_chart {
			do add("Seconds", 0.0, #black);
			do add("Total", 180.0, pie_background);
		}
		discussion_timer <- pie_chart[2];
		
	}
	
	reflex when: stage = COMPUTE_INDICATORS{
		ask turn_timer {
			do increment("Turns", 1);
			do increment("Total", -1);
		}
	}
	
	bool discussion_started <-false;
	float starting_time <- -1;
	float previous_time <- -1;

	reflex when: stage = PLAYER_DISCUSSION_TURN and !discussion_started {
		discussion_started <- true;
		previous_time <- gama.machine_time;
		starting_time <- gama.machine_time;
	}
	
	reflex when: stage = PLAYER_DISCUSSION_TURN and discussion_started {
		float current_time <- gama.machine_time;
		ask discussion_timer {
			do increment("Seconds", (current_time - previous_time) / 1000);
			do increment("Total", -(current_time - previous_time) / 1000);
			previous_time <- current_time;
		}
		if (current_time - starting_time >= 180000) { discussion_started <- false;}
	}
	


}




experiment Open {
	
	
	init {
		gama.pref_display_slice_number <- 128;
		gama.pref_display_show_rotation <- false;
	}
	
	/********************** PROPORTION OF THE DISPLAYS ****************************/
	
	int small_prop <- 1500;
	int large_prop <- 3500;

	
	/********************** ICONS' POSITIONS AND SIZES ****************************/
	
	float y_icons -> simulation.shape.height - icon_size;
	float x_margin -> - simulation.shape.width / 20; //simulation.shape.width / 20;
	float icon_size -> simulation.shape.width / 8;
	point symbol_icon_size -> {icon_size,icon_size};
	point arrow_icon_size -> {icon_size/2,icon_size/2};
	point smiley_icon_size -> {2*icon_size/3,2*icon_size/3};
	int player_text_size -> #fullscreen ? 200 : 30;
	bool active_button;

	/********************** FONTS ************************************************/
	font player_font_bold -> font("Impact", player_text_size, #bold);
	font player_font_regu -> font("Impact", player_text_size, #none);
	
	
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

		display "PLAYER 1" type: opengl axes: false background: village_color[0] refresh: stage = COMPUTE_INDICATORS antialias: false{
			
			light #ambient intensity: ambient_intensity;
			camera 'default' location: {3213.0194,2461.0968,7088.535} target: {3213.0194,2460.973,0.0} locked: true;
						
			//graphics "Behind" {
			//	draw shape color: rgb(255,255,255);
			//}
			
			species commune position: {shape.width*0.15, 0.05} size: {0.7,0.7}{
				draw shape color:rgb(170,170,170);
			}


			agents "Village" value: ([village[0]]) transparency: 0  position: {shape.width*0.15,  0.05} size: {0.7,0.7}{
				draw shape color:  village_color[0] border: #black width: 2;
			}
			
//			graphics "Frame" transparency: 0.5 {
//				//draw rectangle(shape.width, shape.height) - rectangle(shape.width-x_margin, shape.height-x_margin) color: village_color[3];
//				//draw rectangle(shape.width, icon_size*2) at: {shape.width/2,y_icons} color: #darkgray;
//			}
			
			graphics "Text" {
				draw player_icon at: {10#px,shape.width/5} size: shape.width/3;
				
				//draw square(shape.width/3) texture: player_icon color: village_color[0]  at: {10#px,shape.width/5};
				//draw "Player 1" color: #black font: font("Impact", player_text_size, #bold) anchor: #center at: {shape.width/2, shape.height/3, 1};
				draw "1" color: #black font: font("Impact", player_text_size, #bold) anchor: #center at: {10#px,shape.width/5};
				
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
				draw tokens_icon at: {x_margin + 16*icon_size / 2, y_icons} size: symbol_icon_size;
				draw ""+rnd(120) at: {x_margin + 16*icon_size / 2, y_icons - icon_size*2/3} color: #black font: player_font_regu anchor: #center;
			}

		}
		
		/********************** LEGEND DISPLAY *************************************************/

		display "LEGEND" type: opengl axes: false background: map_background refresh: stage = COMPUTE_INDICATORS {
			
		}
		
				
		/********************** PLAYER 4 DISPLAY ***************************************************/
		
		display "Player 4" type: opengl axes: false background: village_color[3] refresh: stage = COMPUTE_INDICATORS antialias: false{
			
			light #ambient intensity: ambient_intensity;
			camera 'default' location: {3213.0194,2461.0968,7088.535} target: {3213.0194,2460.973,0.0} locked: true;
			
						
			//graphics "Behind" {
			//	draw shape color: #white;
			//}
			
			species commune position: {shape.width*0.15, 0.05} size: {0.7,0.7}{
				draw shape color:rgb(170,170,170);
			}


			agents "Village" value: ([village[3]]) transparency: 0  position: {shape.width*0.15,  0.05} size: {0.7,0.7}{
				draw shape color:  village_color[3] border: #black width: 2;
			}
			
//			graphics "Frame" transparency: 0.5 {
//				//draw rectangle(shape.width, shape.height) - rectangle(shape.width-x_margin, shape.height-x_margin) color: village_color[3];
//				//draw rectangle(shape.width, icon_size*2) at: {shape.width/2,y_icons} color: #darkgray;
//			}
			
			graphics "Text" {
				draw player_icon at: {10#px,shape.width/5} size: shape.width/3;
				
				//draw square(shape.width/3) texture: player_icon color: village_color[0]  at: {10#px,shape.width/5};
				//draw "Player 1" color: #black font: font("Impact", player_text_size, #bold) anchor: #center at: {shape.width/2, shape.height/3, 1};
				draw "4" color: #black font: font("Impact", player_text_size, #bold) anchor: #center at: {10#px,shape.width/5};
				
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
				draw tokens_icon at: {x_margin + 16*icon_size / 2, y_icons} size: symbol_icon_size;
				draw ""+rnd(120) at: {x_margin + 16*icon_size / 2, y_icons - icon_size*2/3} color: #black font: player_font_regu anchor: #center;
			}

		}


		
		
		/********************** CENTER TOP DISPLAY *************************************************/
		
		display "CENTER TOP" type: opengl axes: false background: map_background refresh: stage = COMPUTE_INDICATORS {
//		species commune visible: #fullscreen {
//				draw shape color: #lightgray;
//			}
			light #ambient intensity: ambient_intensity;

			
			agents "Days" value: [days_timer] position: #fullscreen ? {shape.width/2  + shape.width / 4,0} : {shape.width,0}  size: #fullscreen ? {0.5, 0.5} : {1,1};
			graphics "Days#" position: #fullscreen ? {shape.width/2  + shape.width / 4,0, 0.01} : {shape.width,0, 0.01}  size: #fullscreen ? {0.5, 0.5} : {1,1} {
				draw ""+int(days_timer.slices["Days"].value)  color: text_color font: font("Impact", #fullscreen ? 200 : 80, #bold) anchor: #center border: #black;
			}
			graphics "Label" size: {0.7,0.9} position: {0.15,-0.1} transparency: flip(0.5) ? 0.1 : 0.8{
				draw label_icon; 
			}
			
		}

		/********************** MAIN MAP DISPLAY ***************************************************/
		
		display "MAIN MAP" type: opengl background: map_background axes: false refresh: stage = COMPUTE_INDICATORS {
			camera 'default' location: {3213.0194,2444.8489,6883.1631} target: {3213.0194,2444.7288,0.0};
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
	
		display "TIMER" type: opengl axes: false background: map_background  {
//			species commune {
//				draw shape color: #lime;
//			}
			light #ambient intensity: ambient_intensity;

			agents "Turn" value: [turn_timer] position: {-shape.width/2,0} size: {0.5,0.5};
			graphics "Icons" {
				draw calendar_icon at: {-shape.width/2,shape.height/4} size: shape.height/3;
				draw sandclock_icon  at: {-shape.width/2,3*shape.height/4} size: shape.height/3;
			}
			graphics "Turn#" position: {-shape.width/2,0,0.01}  size:{0.5, 0.5} {
				draw ""+turn  color: text_color font: font("Impact", 160, #bold) anchor: #center border: #black;}
			agents "Discussion" value: [discussion_timer] position: {-shape.width/2,shape.height/2} size: {0.5,0.5} transparency: stage = PLAYER_DISCUSSION_TURN ? 0 : 0.7;
			graphics "Discussion#" position: {-shape.width/2,shape.height/2,0.01} size: {0.5,0.5} visible:stage = PLAYER_DISCUSSION_TURN {
				draw ""+(180- int((gama.machine_time-starting_time) / 1000))+"s"  color: text_color font: font("Impact", 120, #bold) anchor: #center  border: #black;}
			graphics "Stage" /*size: {0.7,0.9} position: {0.15,-0.1}*/ {
				image_file icon <- (stage = PLAYER_DISCUSSION_TURN) ? discussion_icon : ((stage = PLAYER_ACTION_TURN) ? player_icon : computer_icon);
				draw icon size: {2*shape.width/3, 2*shape.width/3} ;
				//draw capitalize(stage) font: font("Impact", #fullscreen ? 200 : 100, #bold) color: #white anchor: #center; 
			}
			graphics "Next" transparency: active_button ? 0 : 0.7 visible: stage = PLAYER_DISCUSSION_TURN {
				//draw triangle(shape.width, shape.width) rotated_by 90 at: {shape.width/2 + 30, shape.height/2+30} color: #black;
				//draw (triangle(shape.width / 3, shape.width / 3) rotated_by 90) buffer (shape.width/20,50,1) at: {shape.width + shape.width/3, shape.height/2} color: button_color border: #black width: 5;
				draw next_icon at: {shape.width + shape.width/3, shape.height/2} size: shape.width / 3;
			}
			event #mouse_move {
				using topology(simulation) {
					active_button <-  ({world.shape.width + world.shape.width/3, world.shape.height/2} distance_to #user_location) < world.shape.width/3;
				}
			}
			
		}

		/********************** PLAYER 2 DISPLAY *************************************************/
		
		display "Player 2" type: opengl axes: false background: village_color[1] refresh: stage = COMPUTE_INDICATORS antialias: false{
			
			light #ambient intensity: ambient_intensity;
			camera 'default' location: {3213.0194,2461.0968,7088.535} target: {3213.0194,2460.973,0.0} locked: true;

						
//			graphics "Behind" {
//				draw shape color: #white;
//			}
			
			species commune position: {shape.width*0.15,0.05} size: {0.7,0.7}{
				draw shape color:rgb(170,170,170);
			}


			agents "Village" value: ([village[1]]) transparency: 0  position: {shape.width*0.15,  0.05} size: {0.7,0.7}{
				draw shape color:  village_color[1] border: #black width: 2;
			}
			
//			graphics "Frame" transparency: 0.5 {
//				//draw rectangle(shape.width, shape.height) - rectangle(shape.width-x_margin, shape.height-x_margin) color: village_color[3];
//				//draw rectangle(shape.width, icon_size*2) at: {shape.width/2,y_icons} color: #darkgray;
//			}
			
			graphics "Text" {
				draw player_icon at: {10#px,shape.width/5} size: shape.width/3;
				
				//draw square(shape.width/3) texture: player_icon color: village_color[0]  at: {10#px,shape.width/5};
				//draw "Player 1" color: #black font: font("Impact", player_text_size, #bold) anchor: #center at: {shape.width/2, shape.height/3, 1};
				draw "2" color: #black font: font("Impact", player_text_size, #bold) anchor: #center at: {10#px,shape.width/5};
				
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
				draw tokens_icon at: {x_margin + 16*icon_size / 2, y_icons} size: symbol_icon_size;
				draw ""+rnd(120) at: {x_margin + 16*icon_size / 2, y_icons - icon_size*2/3} color: #black font: player_font_regu anchor: #center;
			}

		}

		/********************** CHARTS DISPLAY ***************************************************/
		
		display "Chart 4" type: opengl axes: false background: map_background refresh: stage = COMPUTE_INDICATORS {
						light #ambient intensity: ambient_intensity;
			camera 'default' location: {3141.6811,2875.4272,5697.947} target: {3141.6811,2875.3277,0.0} locked: !#fullscreen;						
			
			agents "Global" value: [global_chart] aspect: 'horizontal' size: {0.7, 0.7} position: {0.15,0.15};

			
//			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
//				data "Water waste pollution" value: village[2].canals sum_of each.water_waste_level + village[2].cells sum_of each.water_waste_level  color: #red marker: false;
//			}
//			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
//				data "Solid waste pollution" value: village[2].canals sum_of each.solid_waste_level + village[2].cells  sum_of each.solid_waste_level  color: #red marker: false;
//			}
		}
		
				
		/********************** PLAYER 3 DISPLAY ***************************************************/

		display "Player 3" type: opengl axes: false refresh: stage = COMPUTE_INDICATORS background: village_color[2] {
			
			light #ambient intensity: ambient_intensity;
			camera 'default' location: {3213.0194,2461.0968,7088.535} target: {3213.0194,2460.973,0.0} locked: true;
						
						
//			graphics "Behind" {
//				draw shape color: #white;
//			}
			
			species commune position: {shape.width*0.15, 0.05} size: {0.7,0.7}{
				draw shape color:rgb(170,170,170);
			}


			agents "Village" value: ([village[2]]) transparency: 0  position: {shape.width*0.15,  0.05} size: {0.7,0.7}{
				draw shape color:  village_color[2] border: #black width: 2;
			}
			
//			graphics "Frame" transparency: 0.5 {
//				//draw rectangle(shape.width, shape.height) - rectangle(shape.width-x_margin, shape.height-x_margin) color: village_color[3];
//				//draw rectangle(shape.width, icon_size*2) at: {shape.width/2,y_icons} color: #darkgray;
//			}
			
			graphics "Text" {
				draw player_icon at: {10#px,shape.width/5} size: shape.width/3;
				
				//draw square(shape.width/3) texture: player_icon color: village_color[0]  at: {10#px,shape.width/5};
				//draw "Player 1" color: #black font: font("Impact", player_text_size, #bold) anchor: #center at: {shape.width/2, shape.height/3, 1};
				draw "3" color: #black font: font("Impact", player_text_size, #bold) anchor: #center at: {10#px,shape.width/5};
				
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
				draw tokens_icon at: {x_margin + 16*icon_size / 2, y_icons} size: symbol_icon_size;
				draw ""+rnd(120) at: {x_margin + 16*icon_size / 2, y_icons - icon_size*2/3} color: #black font: font("Impact", player_text_size, #bold) anchor: #center;
			}

		}


	}

	
}