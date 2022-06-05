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
	
	action tell (string msg, bool add_name <- false) {
		 if (confirmation_popup) {
		 	invoke tell(msg, add_name);
		 }
	}
	
	/********************** PROPORTION OF THE DISPLAYS ****************************/
	
	int small_prop <- 1500;
	int large_prop <- 3500;

	
	/********************** POSITIONS AND SIZES ****************************/
	
	float y_icons -> shape.height - icon_size;
	float x_margin -> - shape.width / 20; 
	float icon_size -> shape.width / 8;
	point symbol_icon_size -> {icon_size,icon_size};
	point arrow_icon_size -> {icon_size/2,icon_size/2};
	point smiley_icon_size -> {2*icon_size/3,2*icon_size/3};
	int player_text_size -> #fullscreen ? 120 : 24;
	bool active_button;
	int line_width <- 5;
	float chart_line_width <- 8.0;
	
	/********************** FONTS ************************************************/
	font player_font_bold -> font("Impact", player_text_size, #bold);
	font player_font_regu -> font("Impact", player_text_size, #none);
	
	/******************* GENERAL PARAMETERS *************************************/
	
	bool confirmation_popup <- false;
	bool no_starting_actions <- false;
	
	/******************* USE TIMERS *************************************/
	bool use_timer_player_turn <- false;	
	bool use_timer_for_discussion <- true;
	
	bool timer_just_for_warning <- false; //if true, if the timer is finished, just a warning message is displayed; if false, the turn passes to the next player - for the moment, some issue with the automatic change of step
	float time_for_discussion <- 3 #mn; // time before the player turns
	
	
	/********************* SPECIAL FOR LEGENDS AND THE MAP ****************************/
	geometry show_soil;
	geometry show_canal;
	geometry show_production;
	geometry show_player;
	bool over_canal;
	bool over_soil;
	bool over_production;
	bool over_player;
	bool canal_on <- true;
	bool soil_on <- false;
	bool production_on <- true;
	bool player_on <- false;

	/********************** COLORS ************************************************/
	
	list<rgb> greens <- palette(rgb(237, 248, 233), rgb(186, 228, 179), rgb(116, 196, 118), rgb(49, 163, 84), rgb(0, 109, 44));
	list<rgb> blues <- palette(rgb(239, 243, 255), rgb(189, 215, 231), rgb(107, 174, 214), rgb(49, 130, 189), rgb(8, 81, 156));
	list<rgb> reds <- palette(rgb(254, 229, 217), rgb(252, 174, 145), rgb(251, 106, 74), rgb(222, 45, 38), rgb(165, 15, 21));
	rgb map_background <- #black;
	rgb player_background <- #white;
	rgb timer_background <- #gray;
	rgb legend_background <- #gray;
	rgb text_color <- rgb(228, 233, 190);
	rgb pie_background <- rgb(162, 179, 139);
	int ambient_intensity <- 100;
	rgb not_selected_color <- text_color;
	rgb selected_color <- pie_background.darker;
	rgb button_color <- not_selected_color;
	rgb landfill_color <- rgb(123,50,148).brighter;
	rgb city_color <- #gray;
	list<rgb> village_color <- [rgb(153, 187, 173), rgb(235, 216, 183), rgb(198, 169, 163), rgb(154, 129, 148)]; // color for the 4 villages
	
	/********************** ICONS *************************************************/
	
	image_file label_icon <- image_file("../../includes/icons/eco.png");
	image_file soil_icon <- image_file("../../includes/icons/soil.png");
	image_file tokens_icon <- image_file("../../includes/icons/tokens.png");
	image_file water_icon <- image_file("../../includes/icons/water.png");
	image_file plant_icon <- image_file("../../includes/icons/plant.png");
	list<image_file> smileys <- [image_file("../../includes/icons/0.png"), image_file("../../includes/icons/1.png"), image_file("../../includes/icons/2.png"), image_file("../../includes/icons/3.png"), image_file("../../includes/icons/4.png")];
 	list<image_file> arrows <- [image_file("../../includes/icons/up.png"), image_file("../../includes/icons/down.png"), image_file("../../includes/icons/equal.png")];
	list<image_file> faces <- [image_file("../../includes/icons/people-0.png"),image_file("../../includes/icons/people-1.png"),image_file("../../includes/icons/people-2.png"),image_file("../../includes/icons/people-3.png"),image_file("../../includes/icons/people-4.png"),image_file("../../includes/icons/people-5.png"),image_file("../../includes/icons/people-6.png"),image_file("../../includes/icons/people-7.png")];
	image_file calendar_icon <- image_file("../../includes/icons/upcoming.png");
	image_file discussion_icon <- image_file("../../includes/icons/conversation.png");
	image_file sandclock_icon <- image_file("../../includes/icons/hourglass.png");
	image_file computer_icon <- image_file("../../includes/icons/simulation.png");
	image_file next_icon <- image_file("../../includes/icons/fast-forward.png");
	image_file garbage_icon <- image_file("../../includes/icons/garbage.png");
	image_file city_icon <- image_file("../../includes/icons/office.png");
	
	list<image_file> village_icon <- 4 among faces; 
	
	stacked_chart global_chart;
	int cycle_count;
	
	
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
				do update_all(village_color[i], ["Water"::rnd(1000)+100, "Soil"::rnd(500)+100, "Production"::rnd(500)+100 ]);
			}
		}
		global_chart <- stacked_chart[0];
	}
	
	reflex when: stage = COMPUTE_INDICATORS{
		cycle_count <- cycle_count + 1;
	}

}




experiment Open {
	
	
	init {
		gama.pref_display_slice_number <- 128;
		gama.pref_display_show_rotation <- false;
		gama.pref_display_show_errors <- false;
	}
	
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
		toolbars: false tabs: false parameters: false consoles: false navigator: false controls: true tray: false background: #gray;
		
		/********************** PLAYER 1 DISPLAY *************************************************/

		display "PLAYER 1" type: opengl axes: false background: village_color[0] refresh: stage = COMPUTE_INDICATORS antialias: true{
			
			light #ambient intensity: ambient_intensity;
			camera 'default' location: {3213.0194,2461.0968,7088.535} target: {3213.0194,2460.973,0.0} locked: true;
			
			species commune position: {shape.width*0.15, 0.05} size: {0.7,0.7}{
				draw shape wireframe: true border: #black;
			}

			agents "Village" value: ([village[0]]) position: {shape.width*0.15,  0.05} size: {0.7,0.7}{
				draw shape color: village_color[0] ;
				draw shape wireframe: true border: #black width: line_width;
				
			}
			
			graphics "Text" {
				draw village_icon[0] at: {10#px,shape.width/5} size: shape.width/3;
				draw "1" color: #black font: player_font_bold anchor: #center at: {10#px,shape.width/5};
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
				draw ""+village[0].budget at: {x_margin + 16*icon_size / 2, y_icons - icon_size*2/3} color: #black font: player_font_regu anchor: #center;
			}

		}
		
		/********************** LEGEND DISPLAY *************************************************/

		display "LEGEND" type: opengl axes: false background: legend_background refresh: stage = COMPUTE_INDICATORS {
			
			light #ambient intensity: ambient_intensity;
			species commune visible: false;
			
			graphics "Legend" {
				float y_gap <- 0.2;
				float y <- 0.0;
				float x <- 0.1;
				draw plant_icon at: {x* shape.width,y*shape.height} size: symbol_icon_size;
				x <- x + 0.2;
				loop c over: greens {
					draw square(0.1*shape.width) border: #black width: line_width color: c at: {x* shape.width,y*shape.height};
					x <- x + 0.1;
				}
				show_production <- square(0.05*shape.width) at_location {x* shape.width,y*shape.height};
				draw show_production wireframe: !over_production and !production_on color: production_on ? #black: #white width: line_width;
				y <- y + y_gap;
				x <- 0.1;
				draw water_icon at: {x* shape.width,y*shape.height} size: symbol_icon_size;
				x <- x + 0.2;
				loop c over: blues {
					draw square(0.1*shape.width) color: c border: #black width: line_width at: {x* shape.width,y*shape.height};
					x <- x + 0.1;
				}
				show_canal <- square(0.05*shape.width) at_location {x* shape.width,y*shape.height};
				draw show_canal wireframe: !over_canal and !canal_on color: canal_on ? #black: #white width: line_width;
				y <- y + y_gap;
				x <- 0.1;
				draw soil_icon at: {x* shape.width,y*shape.height} size: symbol_icon_size;
				x <- x + 0.2;
				loop c over: reds {
					draw square(0.1*shape.width) color: c border: #black width: line_width at: {x* shape.width,y*shape.height};
					x <- x + 0.1;
				}
				show_soil <- square(0.05*shape.width) at_location {x* shape.width,y*shape.height};
				draw show_soil wireframe: !over_soil and !soil_on color: soil_on ? #black: #white width: line_width;
								
				/*****/
				y <- y + y_gap;
				x <- 0.1;
				draw faces[0] at: {x* shape.width,y*shape.height} size: symbol_icon_size;
				x <- x + 0.2;
				loop c over: village_color {
					draw square(0.1*shape.width) color: c border: #black width: line_width at: {x* shape.width,y*shape.height};
					x <- x + 0.1;
				}
				x <- x + 0.1;
				show_player <- square(0.05*shape.width) at_location {x* shape.width,y*shape.height};
				draw show_player wireframe: !over_player and !player_on color: player_on ? #black: #white width: line_width;
				
				/*****/				
				y <- y + y_gap;
				x <- 0.1;
				draw garbage_icon at: {x* shape.width,y*shape.height} size: symbol_icon_size;
				x <- x + 0.2;
				draw square(0.1*shape.width) color: landfill_color border: #black width: line_width at: {x* shape.width,y*shape.height};
				x <- 0.5;
				draw city_icon at: {x* shape.width,y*shape.height} size: symbol_icon_size;
				x <- x + 0.2;
				draw square(0.1*shape.width) color: city_color border: #black width: line_width at: {x* shape.width,y*shape.height};


			}
			
			event #mouse_move {
				over_canal <- (show_canal * 3) intersects #user_location;
				over_soil <- (show_soil * 3) intersects #user_location;
				over_production <- (show_production * 3) intersects #user_location;
				over_player <- (show_player * 3) intersects #user_location;
			}
			
			event #mouse_down {
				if (show_canal * 3) intersects #user_location {canal_on <- !canal_on;}
				if (show_soil * 3) intersects #user_location {soil_on <- !soil_on;}
				if (show_production * 3) intersects #user_location {production_on <- !production_on;}
				if (show_player * 3) intersects #user_location {player_on <- !player_on;}
			}
			
			
		}
		
		/********************** PLAYER 4 DISPLAY ***************************************************/
		
		display "Player 4" type: opengl axes: false background: village_color[3] refresh: stage = COMPUTE_INDICATORS antialias: true{
			
			light #ambient intensity: ambient_intensity;
			camera 'default' location: {3213.0194,2461.0968,7088.535} target: {3213.0194,2460.973,0.0} locked: true;
			
			species commune position: {shape.width*0.15, 0.05} size: {0.7,0.7}{
				draw shape wireframe: true border: #black;
			}

			agents "Village" value: ([village[3]]) position: {shape.width*0.15,  0.05} size: {0.7,0.7}{
				draw shape color:  village_color[3] ;
				draw shape wireframe: true border: #black width: line_width;
			}
			
			
			graphics "Text" {
				draw village_icon[3] at: {10#px,shape.width/5} size: shape.width/3;
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
				draw ""+village[1].budget at: {x_margin + 16*icon_size / 2, y_icons - icon_size*2/3} color: #black font: player_font_regu anchor: #center;
			}

		}

		/********************** CENTER TOP DISPLAY *************************************************/
		
		display "CENTER TOP" type: opengl axes: false background: timer_background /*refresh: stage = COMPUTE_INDICATORS*/ {
			light #ambient intensity: ambient_intensity;
			
			graphics "Jauge for the turns" {
				float y <- 0.0;
				draw ""+turn  color: #white font: font("Impact", 50, #bold) anchor: #left_center at: {2*shape.width + 500,y};
				draw line({-shape.width, y}, {2*shape.width, y}) buffer (200, 200) color: #white;
				float width <- cycle_count * 2 * shape.width / (8 * 365);
				draw line({-shape.width, y}, {width - shape.width, y}) buffer (200, 200) color: #darkred;
				draw calendar_icon at: {width - shape.width,y} size: shape.height/3;
			}
			graphics "Label" size: {0.7, 0.7} position: {0.15, 0.2} transparency: flip(0.5) ? 0.1 : 0.8 {
				draw label_icon;
			}
		}

		/********************** MAIN MAP DISPLAY ***************************************************/
		
		display "MAIN MAP" type: opengl background: map_background axes: false refresh: stage = COMPUTE_INDICATORS {
			light #ambient intensity: 100;
			
			camera 'default' location: {3213.0194,2444.8489,6883.1631} target: {3213.0194,2444.7288,0.0};
			species house {
				draw shape color: city_color;
			}
			species plot {
				draw shape color: soil_on ? one_of(reds) : (production_on ? one_of(greens) : map_background) border: false;
			}
			species canal visible: canal_on {
				draw shape buffer (soil_on or production_on ? 10 : 20,10) color: one_of(blues) border: #black width: soil_on or production_on ? 2.0 : 0;
			}
			species local_landfill {
				draw  shape depth: waste_quantity / 100.0 color: landfill_color;
			}
			species communal_landfill {
				draw  shape depth: waste_quantity / 100.0 color: landfill_color;
			}
			agents "Current village" value: village transparency: 0.2 position: {0,0,0.01} visible: player_on {
				draw shape color: color border: color;
			}
		}

		/********************** TIMER DISPLAY ***************************************************/
	
		display "TIMER" type: opengl axes: false background: timer_background  {
			light #ambient intensity: ambient_intensity;
			
			graphics "Stage" position: {0,-500}{
				image_file icon <- (stage = PLAYER_DISCUSSION_TURN) ? discussion_icon : ((stage = PLAYER_ACTION_TURN) ? village_icon[int(villages_order[index_player])] : computer_icon);
				draw icon size: {2*shape.width/3, 2*shape.width/3};
				if (stage = PLAYER_ACTION_TURN) {
					draw ""+(int(villages_order[index_player])+1) color: #black font: font("Impact", 50, #bold) anchor: #center ;
				}
			}
			graphics "Next" transparency: active_button ? 0.33 : 0.7 visible: stage = PLAYER_DISCUSSION_TURN or stage = PLAYER_ACTION_TURN {
				draw next_icon at: {shape.width + shape.width/3, shape.height/2} size: shape.width / 3;
			}
			
			event #mouse_move {
				using topology(simulation) {
					active_button <-  ({world.shape.width + world.shape.width/3, world.shape.height/2} distance_to #user_location) < world.shape.width/3;
				}
			}
			
			event #mouse_down {
				using topology(simulation) {
					if ({world.shape.width + world.shape.width/3, world.shape.height/2} distance_to #user_location) < world.shape.width/2 {
						if (stage = PLAYER_DISCUSSION_TURN) {
							ask simulation {do end_of_discussion_phase;}
						} else {
							ask simulation {
								ask villages_order[index_player] {
									do end_of_turn;
								}
							}
						}
					}
				}
			}
			
			graphics "Jauge for the discussion" visible: stage = PLAYER_DISCUSSION_TURN {
				float y <- shape.height - 500;
				draw ""+int(remaining_time)+"s"  color: #white font: font("Impact", 50, #bold) anchor: #left_center at: {2*shape.width + 500,y};
				draw line({-shape.width, y}, {2*shape.width, y}) buffer (200, 200) color: #white;
				float width <-( 180 -remaining_time)* 2 * shape.width / (180);
				draw line({-shape.width, y}, {width - shape.width, y}) buffer (200, 200) color: #darkgreen;
				draw sandclock_icon rotate: (180 - remaining_time)*3 at: {width - shape.width,y} size: shape.height/3;
			}
		}

		/********************** PLAYER 2 DISPLAY *************************************************/
		
		display "Player 2" type: opengl axes: false background: village_color[1] refresh: stage = COMPUTE_INDICATORS antialias: true{
			
			light #ambient intensity: ambient_intensity;
			camera 'default' location: {3213.0194,2461.0968,7088.535} target: {3213.0194,2460.973,0.0} locked: true;

			species commune position: {shape.width*0.15, 0.05} size: {0.7,0.7}{
				draw shape wireframe: true border: #black;
			}

			agents "Village" value: ([village[1]]) position: {shape.width*0.15,  0.05} size: {0.7,0.7}{
				draw shape color:  village_color[1] ;
				draw shape wireframe: true border: #black width: line_width;
			}
			
			graphics "Text" {
				draw village_icon[1] at: {10#px,shape.width/5} size: shape.width/3;
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
				draw ""+village[1].budget at: {x_margin + 16*icon_size / 2, y_icons - icon_size*2/3} color: #black font: player_font_regu anchor: #center;
			}
		}

		/********************** CHARTS DISPLAY ***************************************************/
		
		display "Chart 4" type: opengl axes: false background: #fullscreen ? #black: legend_background refresh: stage = COMPUTE_INDICATORS and every(data_frequency#cycle) {
						light #ambient intensity: ambient_intensity;
			camera 'default' location: #from_up_front locked: false;						
			
			agents "Global" value: [global_chart] aspect: 'horizontal' size: {0.7, 0.7} position: {0.15,0.15} visible: !#fullscreen;
			
			chart WASTE_POLLUTION  size:{1, 0.5} type: xy background: #black color: #white visible: #fullscreen label_font: player_font_bold {
				data SOLID_WASTE_POLLUTION value:rows_list(matrix([time_step,total_solid_pollution_values])) color: #gray marker: false thickness: chart_line_width ;
				data WATER_WASTE_POLLUTION value: rows_list(matrix([time_step,total_water_pollution_values])) color: #orange marker: false thickness: chart_line_width;
		 		data TOTAL_POLLUTION value:rows_list(matrix([time_step,total_pollution_values])) color:is_pollution_ok ? #green: #red marker: false thickness: chart_line_width;
		 		data ECOLABEL_MAX_POLLUTION value:rows_list(matrix([time_step,ecolabel_max_pollution_values])) color: #white marker: false thickness: chart_line_width;
			}
			
			chart PRODUCTION type: xy position:{0, 0.5}  size:{1, 0.5} background: #black color: #white y_range:[0,6000] visible: #fullscreen {
				data TOTAL_PRODUCTION value: rows_list(matrix([time_step,total_production_values])) color: is_production_ok ? #green : #red thickness: chart_line_width marker: false; 
				data ECOLABEL_MIN_PRODUCTION value: rows_list(matrix([time_step,ecolabel_min_production_values])) thickness: chart_line_width color: #white marker: false; 
			}		
		}
		
		
				
		/********************** PLAYER 3 DISPLAY ***************************************************/

		display "Player 3" type: opengl axes: false refresh: stage = COMPUTE_INDICATORS background: village_color[2] antialias: true {
			
			light #ambient intensity: ambient_intensity;
			camera 'default' location: {3213.0194,2461.0968,7088.535} target: {3213.0194,2460.973,0.0} locked: true;
									
			species commune position: {shape.width*0.15, 0.05} size: {0.7,0.7}{
				draw shape wireframe: true border: #black;
			}


			agents "Village" value: ([village[2]]) position: {shape.width*0.15,  0.05} size: {0.7,0.7}{
				draw shape color:  village_color[2] ;
				draw shape wireframe: true border: #black width: line_width;
			}
			
			graphics "Text" {
				draw village_icon[2] at: {10#px,shape.width/5} size: shape.width/3;
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
				draw ""+village[2].budget at: {x_margin + 16*icon_size / 2, y_icons - icon_size*2/3} color: #black font: font("Impact", player_text_size, #bold) anchor: #center;
			}

		}


	}

	
}