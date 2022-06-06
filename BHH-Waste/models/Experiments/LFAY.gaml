/**
* Name: LFAY
* The model used for the LFAY 2-days demonstrations  
* Author: A. Drogoul
* 
* This model has been designed using resources (icons) from Flaticon.com
* 
* Tags: 
*/

model LFAY

import "../Global.gaml"
 
global {
	
	image_file soil_pollution_class (float v) {
		switch(v) {
			match_between [0, 24999] {return smileys[0];}
			match_between [25000, 39999] {return smileys[1];}
			match_between [40000, 64999] {return smileys[2];}
			match_between [65000, 90000] {return smileys[3];}
			default {return smileys[4];}
		}
	}
	
	int production_class_current(plot p) {
		float w <- p.current_productivity; 
		switch(w) {
			match_between [0, 0.000079] {return 0;}
			match_between [0.00008, 0.000012] {return 1;}
			match_between [0.00013, 0.00019] {return 2;}
			match_between [0.0002, 0.00029] {return 3;}
			default {return 4;}	
		}
	}
	
	// Returns 0 (down), 1 (equal), 2 (up) 
	image_file tendency_on(list<float> data) {
		int length <- length(data);
		switch (length) {
			match 0 {return arrows[1];}
			match 1 {return arrows[2];} 
			default {
				float last <- data[length-1];
				float before <- data[length-2];
//				write ("before: " + string(before) + " last :" + last);
				return arrows[last > before ? 2 : (before > last ? 0 : 1)];
			}
		}
		
	}
	
	image_file water_pollution_class(float w) {
		switch(w) {
			match_between [0, 9999] {return smileys[0];}
			match_between [10000, 19999] {return smileys[1];}
			match_between [20000, 29999] {return smileys[2];}
			match_between [30000, 44999] {return smileys[3];}
			default {return smileys[4];}
		}
	}
	
	image_file production_class (village v) {
		float w <- village_production[int(v)];
		if (int(v) = 0) {
			switch(w) {
				match_between [0, 349] {return smileys[4];}
				match_between [350, 699] {return smileys[3];}
				match_between [700, 899] {return smileys[2];}
				match_between [900, 1149] {return smileys[1];}
				default {return smileys[0];}
			}
		} else {
			switch(w) {
				match_between [0, 499] {return smileys[4];}
				match_between [500, 799] {return smileys[3];}
				match_between [800, 1099] {return smileys[2];}
				match_between [1100, 1499] {return smileys[1];}
				default {return smileys[0];}
			}
		}
		
	}
	
	
	int water_pollution_class_current(canal p) {
		float w <- p.pollution_density; 
		switch(w) {
			match_between [0, 0.9] {return 0;}
			match_between [1, 9] {return 1;}
			match_between [10, 19] {return 2;}
			match_between [20, 39] {return 3;}
			default {return 4;}
		}
	}
	
	map<village,list<string>> village_actions <- nil;
	action action_executed(string action_name) {
//		write sample(index_player);
//		write sample(villages_order[index_player]);
//		write sample(action_numbers[action_name]);
//		write sample(village_actions);
		if village_actions = nil or empty(village_actions) {
			loop v over: village {
				village_actions[v]<-[];
			}
			//village_actions <- village as_map (each::copy([]));
		}
		list the_list <- village_actions[villages_order[index_player]];
		if the_list != nil {
					the_list <+ action_numbers[action_name];
		}

	} 
		
	
	action tell (string msg, bool add_name <- false) {
		 if (confirmation_popup) {
		 	invoke tell(msg, add_name);
		 }
	}
	
	
	action pause {
		about_to_pause <- true;
		ask experiment {do update_outputs;}
		invoke pause;
	}
	
	action resume {
		about_to_pause <- false;
		invoke resume;
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
	int line_width <- 4;
	float chart_line_width <- 8.0;
	
	/********************** FONTS ************************************************/
	font player_font_bold -> font("Impact", player_text_size, #bold);
	font player_font_regu -> font("Impact", player_text_size, #none);
	font base_font <- font("Impact", 30, #none);
	
	/******************* GENERAL PARAMETERS *************************************/
	
	bool confirmation_popup <- false;
	bool no_starting_actions <- true;
	bool about_to_pause <- false;
	float pause_started_time <- 0.0;
	
	/******************* USE TIMERS *************************************/
	bool use_timer_player_turn <- false;	
	bool use_timer_for_discussion <- true;
	
	bool timer_just_for_warning <- false; //if true, if the timer is finished, just a warning message is displayed; if false, the turn passes to the next player - for the moment, some issue with the automatic change of step
	float initial_time_for_discussion <- 2 #mn const: true; // time before the player turns
	//float time_for_discussion <- initial_time_for_discussion;
	
	
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
	list<rgb> blues <- reverse(palette(rgb(239, 243, 255), rgb(189, 215, 231), rgb(107, 174, 214), rgb(49, 130, 189), rgb(8, 81, 156)));
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
	rgb landfill_color <- #chocolate;
	rgb city_color <- #gray;
	list<rgb> village_color <- [rgb(153, 187, 173), rgb(235, 216, 183), rgb(198, 169, 163), rgb(154, 129, 148)]; // color for the 4 villages
	
	/********************** ICONS *************************************************/
	
	image_file label_icon <- image_file("../../includes/icons/eco.png");
	image_file soil_icon <- image_file("../../includes/icons/soil.png");
	image_file tokens_icon <- image_file("../../includes/icons/tokens.png");
	image_file water_icon <- image_file("../../includes/icons/water.png");
	image_file plant_icon <- image_file("../../includes/icons/plant.png");
	list<image_file> smileys <- [image_file("../../includes/icons/0.png"), image_file("../../includes/icons/1.png"), image_file("../../includes/icons/2.png"), image_file("../../includes/icons/3.png"), image_file("../../includes/icons/4.png")];
 	list<image_file> arrows <- [image_file("../../includes/icons/down.png"), image_file("../../includes/icons/equal.png"), image_file("../../includes/icons/up.png")];
	list<image_file> faces <- [image_file("../../includes/icons/people-0.png"),image_file("../../includes/icons/people-1.png"),image_file("../../includes/icons/people-2.png"),image_file("../../includes/icons/people-3.png"),image_file("../../includes/icons/people-4.png"),image_file("../../includes/icons/people-5.png"),image_file("../../includes/icons/people-6.png"),image_file("../../includes/icons/people-7.png")];
	image_file calendar_icon <- image_file("../../includes/icons/upcoming.png");
	image_file discussion_icon <- image_file("../../includes/icons/conversation.png");
	image_file sandclock_icon <- image_file("../../includes/icons/hourglass.png");
	image_file computer_icon <- image_file("../../includes/icons/simulation.png");
	image_file next_icon <- image_file("../../includes/icons/fast-forward.png");
	image_file play_icon <- image_file("../../includes/icons/play.png");
	image_file pause_icon <- image_file("../../includes/icons/pause.png");
	image_file actions_icon <- image_file("../../includes/icons/actions.png");
	image_file garbage_icon <- image_file("../../includes/icons/garbage.png");
	image_file city_icon <- image_file("../../includes/icons/office.png");
	image_file score_icon <- image_file("../../includes/icons/trophy.png");
	image_file schedule_icon <- image_file("../../includes/icons/schedule.png");


	map<string, string> action_numbers;
	
	
	list<image_file> village_icon <- 4 among faces; 
	pie_chart day_timer;
	pie_chart score_timer;
	stacked_chart global_chart;
	int cycle_count;
	
	
	init {
		create pie_chart {
			radius <- world.shape.width / 2;
			do add("Days", 0.0, #green);
			do add("Total", 365.0, #darkred);
		}
		day_timer <- pie_chart[0];
		create pie_chart {
			radius <- world.shape.width / 2;
			do add("Days", 0.0, #green);
			do add("Total", 8*365.0, #darkred);
		}
		score_timer <- pie_chart[1];
		create stacked_chart {
			size <- world.shape.height;
			desired_value <- 1.0;
			max_value <- 2.0;
			ratio <- size / max_value;
			desired_icon <- label_icon;
			do add_column("Water");
			do add_column("Soil");
			do add_column("Production");
			icons <- ["Water"::water_icon, "Soil"::soil_icon, "Production"::plant_icon];
		 inf_or_sup <- ["Water"::true, "Soil"::true, "Production"::false];
			
			loop i from: 0 to: 3 {
				do add_element(village_color[i]);
			}
		}
		global_chart <- stacked_chart[0];
			action_numbers <- [
				A_DUMPHOLES::"3",
				A_PESTICIDES::"4",
				A_END_TURN::"",
				A_SENSIBILIZATION::"6",
				A_FILTERS::"2A",
				A_COLLECTIVE_LOW::"5A",
				A_COLLECTIVE_HIGH::"5B",
				A_DRAIN_DREDGES_HIGH::"7B",
				A_DRAIN_DREDGES_LOW::"7A",
				A_FALLOW::"9",
				A_MATURES_LOW::"8A",
				A_MATURES_HIGH::"8B",
				A_FILTER_MAINTENANCE::"2B",
				A_COLLECTION_LOW::"1A",
				A_COLLECTION_HIGH::"1B"
		];

	}
	
	reflex update_charts when: stage = COMPUTE_INDICATORS{
		village_actions <- nil;
		cycle_count <- cycle_count + 1;
		ask day_timer {
			do set_value("Days", last(days_with_ecolabel_year));
			do set_value("Total", 365.0-last(days_with_ecolabel_year));
		}
		ask score_timer {
			do set_value("Days", days_with_ecolabel);
			do set_value("Total",8*365 - days_with_ecolabel);
		}
		
		ask global_chart{
			loop i from: 0 to: 3 {
				do update_all(village_color[i], ["Water"::village_water_pollution[i]/max_pollution_ecolabel, "Soil"::village_solid_pollution[i]/max_pollution_ecolabel, "Production"::village_production[i]/min_production_ecolabel ]);
			}
		}	
		// TODO remove this at some point ! 
	time_for_discussion <- initial_time_for_discussion;			
		pause_started_time <- 0.0;
	}
	
	reflex end_of_discussion_turn when:  stage = PLAYER_DISCUSSION_TURN {
		remaining_time <- int(time_for_discussion - machine_time/1000.0  +start_discussion_turn_time/1000.0); 
		if remaining_time <= 0 {
			do end_of_discussion_phase;		
		}

	}
	

}




experiment Open {
	
	
	init {
		gama.pref_display_slice_number <- 128;
		gama.pref_display_show_rotation <- false;
		gama.pref_display_show_errors <- false;
		gama.pref_errors_display <- false;
		gama.pref_errors_stop <- false;
		gama.pref_errors_in_editor <- false;
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
		toolbars: false tabs: false parameters: false consoles: false navigator: false controls: false tray: false background: #gray;
		
		/********************** PLAYER 1 DISPLAY *************************************************/

		display "PLAYER 1" type: opengl axes: false background: village_color[0].darker  antialias: true{
			
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
				draw simulation.soil_pollution_class(village1_solid_pollution) at: {x_margin +3*icon_size/2, y_icons - icon_size/4} size: smiley_icon_size;
				draw simulation.tendency_on(village1_solid_pollution_values) at: {x_margin +3*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw water_icon at: {x_margin +6*icon_size/2,  y_icons} size: symbol_icon_size;
				draw simulation.water_pollution_class(village1_water_pollution) at: {x_margin +8*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw simulation.tendency_on(village1_water_pollution_values) at: {x_margin +8*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw plant_icon at: {x_margin +11*icon_size/2, y_icons} size: symbol_icon_size;
				draw simulation.production_class(village[0]) at: {x_margin +13*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw simulation.tendency_on(village1_production_values) at: {x_margin +13*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw tokens_icon at: {x_margin + 16*icon_size / 2, y_icons} size: symbol_icon_size;
				draw ""+village[0].budget at: {x_margin + 16*icon_size / 2, y_icons - icon_size*2/3} color: #black font: font("Impact", player_text_size, #bold) anchor: #center;
			}

		}
		
		/********************** LEGEND DISPLAY *************************************************/

		display "LEGEND" type: opengl axes: false background: legend_background  {
			
			light #ambient intensity: ambient_intensity;
			species commune visible: false;
			
			graphics "Legend" {
				float y_gap <- 0.3;
				float x_gap <- 0.1;
				float y <- 0.0;
				float x <- 0.1;
				

				x <- x + 2 * x_gap;
				draw smileys[0] size:(0.05*shape.width)  at: {x* shape.width,y*shape.height,0.05};
				x <- 0.5;
				x <- x + 2*x_gap;
				draw smileys[4] size:(0.05*shape.width)  at: {x* shape.width,y*shape.height,0.05};
				
				
				//y <- y + y_gap;
				x <- x_gap;
				draw plant_icon at: {x* shape.width,y*shape.height} size: symbol_icon_size;
				x <- x + 2* x_gap;
				loop c over: reverse(greens) {
					draw square(x_gap*shape.width) border: #black width: line_width color: c at: {x* shape.width,y*shape.height};
					x <- x + x_gap;
				}
				show_production <- square((x_gap/2)*shape.width) at_location {x* shape.width,y*shape.height};
				draw show_production wireframe: !over_production and !production_on color: production_on ? #black: #white width: line_width;
				// SMILEYS
				x <- x_gap;
				x <- x + 2 * x_gap;
				draw smileys[0] size:(0.05*shape.width)  at: {x* shape.width,y*shape.height,0.05};
				x <- 0.5;
				x <- x + 2*x_gap;
				draw smileys[4] size:(0.05*shape.width)  at: {x* shape.width,y*shape.height,0.05};
				//
				y <- y + y_gap;
				x <- x_gap;
				draw water_icon at: {x* shape.width,y*shape.height} size: symbol_icon_size;
				x <- x + 2* x_gap;
				loop c over: blues {
					draw square(x_gap*shape.width) color: c border: #black width: line_width at: {x* shape.width,y*shape.height};
					x <- x + x_gap;
				}
				show_canal <- square((x_gap/2)*shape.width) at_location {x* shape.width,y*shape.height};
				draw show_canal wireframe: !over_canal and !canal_on color: canal_on ? #black: #white width: line_width;
				// SMILEYS
				x <- x_gap;
				x <- x + 2 * x_gap;
				draw smileys[0] size:(0.05*shape.width)  at: {x* shape.width,y*shape.height,0.05};
				x <- 0.5;
				x <- x + 2*x_gap;
				draw smileys[4] size:(0.05*shape.width)  at: {x* shape.width,y*shape.height,0.05};
				//
//				y <- y + y_gap;
//				x <-x_gap;
//				draw soil_icon at: {x* shape.width,y*shape.height} size: symbol_icon_size;
//				x <- x + 2* x_gap;
//				loop c over: reds {
//					draw square(x_gap*shape.width) color: c border: #black width: line_width at: {x* shape.width,y*shape.height};
//					x <- x +x_gap;
//				}
//				show_soil <- square((x_gap/2)*shape.width) at_location {x* shape.width,y*shape.height};
//				draw show_soil wireframe: !over_soil and !soil_on color: soil_on ? #black: #white width: line_width;
								
				/*****/
				y <- y + y_gap;
				x <- x_gap;
				draw faces[0] at: {x* shape.width,y*shape.height} size: symbol_icon_size;
				x <- x + 2 * x_gap;
				loop c over: village_color {
					draw square(x_gap*shape.width) color: c border: #black width: line_width at: {x* shape.width,y*shape.height};
					x <- x + x_gap;
				}
				x <- x + x_gap;
				show_player <- square((x_gap/2)*shape.width) at_location {x* shape.width,y*shape.height};
				draw show_player wireframe: !over_player and !player_on color: player_on ? #black: #white width: line_width;
				
				/*****/				
				y <- y + y_gap;
				x <- x_gap;
				draw garbage_icon at: {x* shape.width,y*shape.height} size: symbol_icon_size;
				x <- x + 2 * x_gap;
				draw square(0.1*shape.width) color: landfill_color border: #black width: line_width at: {x* shape.width,y*shape.height};
				x <- 0.5;
				draw city_icon at: {x* shape.width,y*shape.height} size: symbol_icon_size;
				x <- x + 2*x_gap;
				draw square(0.1*shape.width) color: city_color border: #black width: line_width at: {x* shape.width,y*shape.height};


			}
			
			event #mouse_move {
				over_canal <- show_canal != nil and (show_canal * 3) intersects #user_location;
				over_soil <- show_soil != nil 	and (show_soil * 3) intersects #user_location;
				over_production <- show_production != nil and (show_production * 3) intersects #user_location;
				over_player <- show_player != nil and (show_player * 3) intersects #user_location;
			}
			
			event #mouse_down {
				if (show_canal != nil) and (show_canal * 3) intersects #user_location {canal_on <- !canal_on;}
				if (show_soil != nil) and (show_soil * 3) intersects #user_location {soil_on <- !soil_on;}
				if (show_production != nil) and (show_production * 3) intersects #user_location {production_on <- !production_on;}
				if (show_player != nil) and (show_player * 3) intersects #user_location {player_on <- !player_on;}
			}
			
			
		}
		
		/********************** PLAYER 4 DISPLAY ***************************************************/
		
		display "Player 4" type: opengl axes: false background: village_color[3].darker antialias: true{
			
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
				draw simulation.soil_pollution_class(village4_solid_pollution) at: {x_margin +3*icon_size/2, y_icons - icon_size/4} size: smiley_icon_size;
				draw simulation.tendency_on(village4_solid_pollution_values) at: {x_margin +3*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw water_icon at: {x_margin +6*icon_size/2,  y_icons} size: symbol_icon_size;
				draw simulation.water_pollution_class(village4_water_pollution) at: {x_margin +8*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw simulation.tendency_on(village4_water_pollution_values) at: {x_margin +8*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw plant_icon at: {x_margin +11*icon_size/2, y_icons} size: symbol_icon_size;
				draw simulation.production_class(village[3]) at: {x_margin +13*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw simulation.tendency_on(village4_production_values) at: {x_margin +13*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw tokens_icon at: {x_margin + 16*icon_size / 2, y_icons} size: symbol_icon_size;
				draw ""+village[3].budget at: {x_margin + 16*icon_size / 2, y_icons - icon_size*2/3} color: #black font: font("Impact", player_text_size, #bold) anchor: #center;
			}

		}

		/********************** CENTER TOP DISPLAY *************************************************/
		
		display "CENTER TOP" type: opengl axes: false background: timer_background /*refresh: stage = COMPUTE_INDICATORS*/ {
			light #ambient intensity: ambient_intensity;
			
			species commune visible: false;
			agents "Turn" value: [day_timer] position: {-world.shape.width , 0.05};
			graphics "Turn#" position: {-world.shape.width , 0.1, 0.01} {
				draw ""+(min(last(days_with_ecolabel_year),365)) at: {shape.width/2, shape.height/2 + shape.height/10} color: #white font: base_font anchor: #center;
				draw schedule_icon size: symbol_icon_size*2 at: {shape.width/2, 500};
			}
			graphics "Label" size: {1,1} position: {0,0} transparency: last(days_with_ecolabel_year) >= 183 ? 0 : 0.8 {
				draw label_icon;
			}
			agents "Score" value: [score_timer] position: {world.shape.width , 0.05};
			graphics "Scope#" position: {world.shape.width , 0.1, 0.01} {
				draw ""+(days_with_ecolabel)  at: {shape.width/2, shape.height/2 + shape.height/10}  color: #gold font: base_font anchor: #center;
				draw score_icon size: symbol_icon_size*2 at: {shape.width/2, 500};
			}
			
		}

		/********************** MAIN MAP DISPLAY ***************************************************/
		
		display "MAIN MAP" type: opengl background: map_background axes: false refresh: stage = COMPUTE_INDICATORS {
			light #ambient intensity: 100;
			
			camera 'default' location: {3213.0194,2444.8489,6883.1631} target: {3213.0194,2444.7288,0.0};
			species urban_area ;
			species plot {
				draw shape color: soil_on ? one_of(reds) : (production_on ? greens[world.production_class_current(self)] : map_background) border: false;
			}
			species canal visible: canal_on {
				draw shape buffer (soil_on or production_on ? 10 : 20,10) color: blues[world.water_pollution_class_current(self)] border: #black width: soil_on or production_on ? 2.0 : 0;
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
			graphics "Pause" transparency: 0.7 position: {0,0,0.01} visible: paused or about_to_pause{
				draw simulation.shape color: #black;
//				draw "Paused" color: #white font: font("Impact", 150, #bold) anchor:#center;
			}
		}

		/********************** TIMER DISPLAY ***************************************************/
	
		display "TIMER" type: opengl axes: false background: timer_background  {
			light #ambient intensity: ambient_intensity;
			
			graphics "Jauge for the turns" {
				float y <- shape.height - 500;
				draw ""+turn  color: #white font: base_font anchor: #left_center at: {2*shape.width + 500,y};
				draw line({-shape.width, y}, {2*shape.width, y}) buffer (200, 200) color: #white;
				float width <- cycle_count * 2 * shape.width / (8 * 365);
				draw line({-shape.width, y}, {width - shape.width, y}) buffer (200, 200) color: #darkred;
				draw calendar_icon at: {width - shape.width,y} size: shape.height/3;
			}
			
			graphics "Jauge for the discussion" visible: stage = PLAYER_DISCUSSION_TURN {
				float y <- 0.0;
				draw ""+int(remaining_time)+"s"  color: #white font: base_font anchor: #left_center at: {2*shape.width + 500,y};
				draw line({-shape.width, y}, {2*shape.width, y}) buffer (200, 200) color: #white;
				float width <-( initial_time_for_discussion -remaining_time)* 2 * shape.width / (initial_time_for_discussion);
				draw line({-shape.width, y}, {width - shape.width, y}) buffer (200, 200) color: #darkgreen;
				draw sandclock_icon rotate: (180 - remaining_time)*3 at: {width - shape.width,y} size: shape.height/3;
			}
			
			
			graphics "Stage" position: {0,-500}{
				image_file icon <- (stage = PLAYER_DISCUSSION_TURN) ? discussion_icon : ((stage = PLAYER_ACTION_TURN) ? village_icon[int(villages_order[index_player])] : computer_icon);
				draw icon size: {3*shape.width/5, 3*shape.width/5};
				if (stage = PLAYER_ACTION_TURN) {
					draw ""+(int(villages_order[index_player])+1) color: #black font: base_font anchor: #center ;
				}
			}
			
			graphics "Actions" position: {-shape.width, 0} visible: stage=PLAYER_ACTION_TURN{
				draw actions_icon size: {shape.width/3,shape.height/3};
				draw string(village_actions[villages_order[index_player]]) at: {location.x + shape.width/4, location.y} color: #white font: base_font anchor: #left_center;
			}
			graphics "Next"  visible: stage = PLAYER_DISCUSSION_TURN or stage = PLAYER_ACTION_TURN {
				draw next_icon at: {shape.width + 3*shape.width/3, shape.height/2} size: shape.width / 4;
			}
			
			graphics "Play Pause"  {
				draw simulation.paused or about_to_pause? play_icon : pause_icon at: {shape.width + shape.width/3, shape.height/2} size: shape.width / 4;
			}
			
//		event #mouse_move {
//				using topology(simulation) {
//					active_button <-  ({world.shape.width + 3*world.shape.width/3, world.shape.height/2} distance_to #user_location) < world.shape.width/3;
//				}
//			}
			
			event #mouse_down {
				using topology(simulation) {
					if ({world.shape.width + 3*world.shape.width/3, world.shape.height/2} distance_to #user_location) < world.shape.width/3 {
						//write "Fast forward with distance to button = " + {world.shape.width + 3*world.shape.width/3, world.shape.height/2} distance_to #user_location;
						if (stage = PLAYER_DISCUSSION_TURN) {
							ask simulation {do end_of_discussion_phase;}
						} else if (stage !=COMPUTE_INDICATORS) {
							ask simulation {
								ask villages_order[index_player] {
									do end_of_turn;
								}
							}
						}
					} else if ({world.shape.width + world.shape.width/3, world.shape.height/2} distance_to #user_location) < world.shape.width/3 {
						//write "Pause with distance to button = " + {world.shape.width + world.shape.width/3, world.shape.height/2} distance_to #user_location;
						
						ask simulation {
							if paused or about_to_pause {
								if (pause_started_time > 0) {
								time_for_discussion <- time_for_discussion + int((gama.machine_time - pause_started_time)/1000);}
								pause_started_time <- 0.0;
								do resume;
							} 
							else {
								pause_started_time <- gama.machine_time;
								do pause;
							}
						}
					}
				}
			}
		}

		/********************** PLAYER 2 DISPLAY *************************************************/
		
		display "Player 2" type: opengl axes: false background: village_color[1].darker  antialias: true{
			
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
				draw simulation.soil_pollution_class(village2_solid_pollution) at: {x_margin +3*icon_size/2, y_icons - icon_size/4} size: smiley_icon_size;
				draw simulation.tendency_on(village2_solid_pollution_values) at: {x_margin +3*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw water_icon at: {x_margin +6*icon_size/2,  y_icons} size: symbol_icon_size;
				draw simulation.water_pollution_class(village2_water_pollution) at: {x_margin +8*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw simulation.tendency_on(village2_water_pollution_values) at: {x_margin +8*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw plant_icon at: {x_margin +11*icon_size/2, y_icons} size: symbol_icon_size;
				draw simulation.production_class(village[1]) at: {x_margin +13*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw simulation.tendency_on(village2_production_values) at: {x_margin +13*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw tokens_icon at: {x_margin + 16*icon_size / 2, y_icons} size: symbol_icon_size;
				draw ""+village[1].budget at: {x_margin + 16*icon_size / 2, y_icons - icon_size*2/3} color: #black font: font("Impact", player_text_size, #bold) anchor: #center;
			}
		}

		/********************** CHARTS DISPLAY ***************************************************/
		
		display "Chart 4" type: opengl axes: false background: #fullscreen ? #black: legend_background refresh: stage = COMPUTE_INDICATORS and every(data_frequency#cycle) {
						light #ambient intensity: ambient_intensity;
			camera 'default' location: {3213.0194,2461.1095,7816.3615} target: {3213.0194,2460.973,0.0};						
			
			agents "Global" value: [global_chart] aspect: vertical size: {0.8, 0.8} position: {0.1,0.1} visible: !#fullscreen;
			
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

		display "Player 3" type: opengl axes: false  background: village_color[2].darker antialias: true {
			
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
				draw simulation.soil_pollution_class(village3_solid_pollution) at: {x_margin +3*icon_size/2, y_icons - icon_size/4} size: smiley_icon_size;
				draw simulation.tendency_on(village3_solid_pollution_values) at: {x_margin +3*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw water_icon at: {x_margin +6*icon_size/2,  y_icons} size: symbol_icon_size;
				draw simulation.water_pollution_class(village3_water_pollution) at: {x_margin +8*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw simulation.tendency_on(village3_water_pollution_values) at: {x_margin +8*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw plant_icon at: {x_margin +11*icon_size/2, y_icons} size: symbol_icon_size;
				draw simulation.production_class(village[2]) at: {x_margin +13*icon_size/2, y_icons- icon_size/4} size: smiley_icon_size;
				draw simulation.tendency_on(village3_production_values) at: {x_margin +13*icon_size/2, y_icons+icon_size/2} size: arrow_icon_size;
				draw tokens_icon at: {x_margin + 16*icon_size / 2, y_icons} size: symbol_icon_size;
				draw ""+village[2].budget at: {x_margin + 16*icon_size / 2, y_icons - icon_size*2/3} color: #black font: font("Impact", player_text_size, #bold) anchor: #center;
			}

		}


	}

	
}

species pie_chart {
	point location <- {world.shape.width/2 ,world.shape.height/2};
	float radius <- world.shape.height;
	
	map<string, pair<rgb, float>> slices <- [];
	
	action add(string title, float value, rgb col) {
			slices[title] <- pair(col, value);
	}
	
	action increment(string title, float value) {
		if (slices.keys contains(title)) {
			slices[title] <- pair(slices[title].key, slices[title].value + value);
		} 
	}
	
	action set_value(string title, float value) {
		if (slices.keys contains(title)) {
			slices[title] <- pair(slices[title].key, value);
		} 
	}
	
	
	aspect default {
		float start_angle <- 0.0;
		float cur_value <- 0.0;
		float sum <- sum(slices.values collect each.value);
		loop p over: slices.pairs {
			start_angle <- (cur_value*180/sum) - 180;
			float arc_angle <- (p.value.value * 180/sum);
			draw arc(radius, start_angle + arc_angle/2, arc_angle) color: p.value.key  border: #black width: 5;
			cur_value <- cur_value + p.value.value;
		}
		
	}
	

	
}


species stacked_chart {
	point location <- {world.shape.width/2 ,world.shape.height/2};
	map<string, map<rgb,float>> data <- [];
	map<string, image_file> icons <- [];
	map<string, bool> inf_or_sup ;
	image_file desired_icon;
	float size;
	float max_value;
	float desired_value;
	float ratio;
	
	
	action add_column(string column) {
		if (!(column in data.keys)) {
			data[column] <- [];
		}
	}
	
	action add_element(rgb element) {
		loop c over: data.keys {
			data[c][element] <- 0.0;
		}
 	}
 	
 	action update(string column, rgb element, float value) {
 		data[column][element] <- value;
 	}
 	
 	action update_all(rgb element, map<string, float> values) {
 		loop col over: data.keys {
 			data[col][element] <- values[col];
 		}
 	}
 	
 	aspect horizontal {
 		float x_margin <- (world.shape.width - size)/2 + size/6; 
 		//draw square(size) wireframe: true border: #white width: 2; 
 		
 		float col_width <- size / length(data);
 		int col_index <- 0;
 		loop col over: data.keys {
 			float current_y <- 0.0;
 			loop c over: data[col].keys {
 				float v <- data[col][c];
 				float height <- v * ratio;
 				//draw  ""+v at:{col_index * col_width + x_margin,location.y + size/2 - height/2} font: font('Helvetica',32,#bold) color: c anchor: #center;
 				draw rectangle(col_width,height) color: c at: {col_index * col_width + x_margin,current_y + location.y + size/2 - height/2};
 				draw rectangle(col_width,height) wireframe: true border: #black width: 5 at: {col_index * col_width + x_margin,current_y + location.y + size/2 - height/2};
 				current_y <- current_y + - height;
 			}
 			if (icons[col] != nil) {
 				draw icons[col] at: {col_index * col_width + x_margin, size-size/10} size: {col_width/2, col_width/2};
 			}
 			col_index <- col_index + 1;
 		}
 		draw line({location.x - 2*size/3, location.y + size/2 - desired_value*ratio},{location.x + 2*size/3, location.y + size/2 - desired_value*ratio}) color: #white width: 5;
 		if (desired_icon != nil) {
 			draw desired_icon at: {location.x - 2*size/3, location.y + size/2 - desired_value*ratio} size: 2*col_width/3;
 		}
 	}
 	
 	 	aspect vertical {
 		float y_margin <- (world.shape.height - size)/2 + size/6; 
 		//draw square(size) wireframe: true border: #white width: 2; 
 		
 		float col_height <- size / length(data);
 		float col_index <- 0.0;
 		loop col over: data.keys {
 			if (!inf_or_sup[col]) {col_index <- col_index+0.5;}
 			float current_x <- 0.0;
 			float total <- 0.0;
 			loop c over: data[col].keys {
 				float v <- data[col][c];
 				total <- total+v;
 				float width <- v * ratio;
 				draw rectangle(width,col_height) color: c at: {current_x + location.x + - size/3 + width/2, col_index * col_height + y_margin};
 				draw rectangle(width,col_height) wireframe: true border: #black width: 5 at: {current_x + location.x -size/3 + width/2, col_index * col_height + y_margin};
 				current_x <- current_x + width;
 			}
 			if (icons[col] != nil) {
 				draw icons[col] at: {size/10, col_index * col_height  + y_margin} size: {col_height/2, col_height/2};
 				if (total <= 1 and inf_or_sup[col] or total > 1 and !inf_or_sup[col]) {
 					draw smileys[0]  at: {size/10 + col_height/4, col_index * col_height  + y_margin+ col_height/4} size: {col_height/4, col_height/4};
 				} else {draw smileys[4]  at: {size/10+ col_height/4, col_index * col_height  + y_margin+ col_height/4} size: {col_height/4, col_height/4};}
 			}
 			col_index <- col_index + 1;
 		}
 		draw line({location.x -size/3 + desired_value*ratio, location.y - 2*size/3},{location.x -size/3 + desired_value*ratio, location.y + 2*size/3}) color: #white width: 5;
 		if (desired_icon != nil) {
 			draw desired_icon at: {location.x -size/3 + desired_value*ratio, location.y - 2*size/3} size: 2*col_height/3;
		}
 	}
 	
}
