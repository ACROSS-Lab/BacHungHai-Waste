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
//import "Short version.gaml"
 
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
	list<image_file> smileys <- [image_file("../../includes/icons/smiley0.png"), image_file("../../includes/icons/smiley1.png"), image_file("../../includes/icons/smiley2.png"), image_file("../../includes/icons/smiley3.png"), image_file("../../includes/icons/smiley4.png")];
 	list<image_file> arrows <- [image_file("../../includes/icons/down.png"), image_file("../../includes/icons/equal.png"), image_file("../../includes/icons/up.png")];
	list<image_file> faces <- [image_file("../../includes/icons/people-0.png"),image_file("../../includes/icons/people-1.png"),image_file("../../includes/icons/people-2.png"),image_file("../../includes/icons/people-3.png"),image_file("../../includes/icons/people-4.png"),image_file("../../includes/icons/people-5.png"),image_file("../../includes/icons/people-6.png"),image_file("../../includes/icons/people-7.png")];
	list<image_file> numbers <- [image_file("../../includes/icons/1.png"), image_file("../../includes/icons/2.png"), image_file("../../includes/icons/3.png"),image_file("../../includes/icons/4.png")];
	
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
	image_file danger_icon <- image_file("../../includes/icons/danger.png");


	map<string, string> action_numbers;
	map<string, string> numbers_actions;
	
	
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
			do add_column("Production");
			do add_column("Total");
			do add_column("Water");
			do add_column("Soil");

			icons <- ["Total"::danger_icon, "Water"::water_icon, "Soil"::soil_icon, "Production"::plant_icon];
		 	inf_or_sup <- ["Total"::true,"Water"::true, "Soil"::true, "Production"::false];
		 	draw_smiley <- ["Total"::true,"Water"::false, "Soil"::false, "Production"::true];
			
			loop i from: 0 to: 3 {
				do add_element(village_color[i]);
			}
		}
		global_chart <- stacked_chart[0];
		
		numbers_actions <- reverse(action_numbers);

	}
	
	reflex update_charts when: stage = COMPUTE_INDICATORS{
		village_actions <- nil;
		cycle_count <- cycle_count + 1;
		ask day_timer {
			do set_value("Days", float(last(days_with_ecolabel_year)));
			do set_value("Total", 365.0-last(days_with_ecolabel_year));
		}
		ask score_timer {
			do set_value("Days",float(days_with_ecolabel));
			do set_value("Total",8.0*365 - days_with_ecolabel);
		}
		
		ask global_chart{
			loop i from: 0 to: 3 {
				do update_all(village_color[i], ["Total"::(village_water_pollution[i] + village_solid_pollution[i])/max_pollution_ecolabel, "Water"::village_water_pollution[i]/max_pollution_ecolabel, "Soil"::village_solid_pollution[i]/max_pollution_ecolabel, "Production"::village_production[i]/min_production_ecolabel ]);
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
	
	map<string, point> action_locations <- [];
	point next_location <- {0,0};
	point pause_location <- {0,0};
	string over_action;
	
	
	init {
		gama.pref_display_slice_number <- 128;
		gama.pref_display_show_rotation <- false;
		gama.pref_display_show_errors <- false;
		gama.pref_errors_display <- false;
		gama.pref_errors_stop <- false;
		gama.pref_errors_in_editor <- false;
		gama.pref_display_numkeyscam <- false;
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
				//show_production <- square((x_gap/2)*shape.width) at_location {x* shape.width,y*shape.height};
				//draw show_production wireframe: !over_production and !production_on color: production_on ? #black: #white width: line_width;
				// SMILEYS
//				x <- x_gap;
//				x <- x + 2 * x_gap;
//				draw smileys[0] size:(0.05*shape.width)  at: {x* shape.width,y*shape.height,0.05};
//				x <- 0.5;
//				x <- x + 2*x_gap;
//				draw smileys[4] size:(0.05*shape.width)  at: {x* shape.width,y*shape.height,0.05};
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
//				x <- x_gap;
//				x <- x + 2 * x_gap;
//				draw smileys[0] size:(0.05*shape.width)  at: {x* shape.width,y*shape.height,0.05};
//				x <- 0.5;
//				x <- x + 2*x_gap;
//				draw smileys[4] size:(0.05*shape.width)  at: {x* shape.width,y*shape.height,0.05};
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
			agents "Turn" value: [day_timer] position: {-world.shape.width , 0.2};
			graphics "Turn#" position: {-world.shape.width , 0, 0.01} {
				draw schedule_icon size: symbol_icon_size*2 at: {shape.width/2, shape.height/2};
				draw ""+(min(last(days_with_ecolabel_year),365)) at: {shape.width/2, shape.height/4} color: #white font: base_font anchor: #center;

			}
			graphics "Label" size: {0.7,0.7} position: {0.15,0} transparency: last(days_with_ecolabel_year) >= 183 ? 0 : 0.8 {
				draw label_icon;
			}
			agents "Score" value: [score_timer] position: {world.shape.width , 0.2};
			graphics "Scope#" position: {world.shape.width , 0, 0.01} {
				draw score_icon size: symbol_icon_size*2 at: {shape.width/2, shape.height/2};
				draw ""+(days_with_ecolabel)  at: {shape.width/2, shape.height/4}  color: #gold font: base_font anchor: #center;
			}
			
			graphics "Jauge for the turns" {
				float y <- shape.height - 500;
				draw ""+turn  color: #white font: base_font anchor: #left_center at: {2*shape.width + 500,y};
				draw line({-shape.width, y}, {2*shape.width, y}) buffer (200, 200) color: #white;
				float width <- cycle_count * 2 * shape.width / (simulation.end_of_game * 365);
				draw line({-shape.width, y}, {width - shape.width, y}) buffer (200, 200) color: #darkred;
				draw calendar_icon at: {width - shape.width,y} size: shape.height/3;
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
			graphics "Jauge for the discussion" visible: stage = PLAYER_DISCUSSION_TURN and turn <= end_of_game {
				float y <- location.y + shape.height / 2;
				float left <- location.x - shape.width;
				float right <- location.x + shape.width;
				draw "" + int(remaining_time) + "s" color: #white font: base_font anchor: #left_center at: {right + 500, y};
				draw line({left, y}, {right, y}) buffer (200, 200) color: #white;
				float width <- (initial_time_for_discussion - remaining_time) * (right - left) / (initial_time_for_discussion);
				draw line({left, y}, {left + width, y}) buffer (200, 200) color: #darkgreen;
				draw sandclock_icon /*rotate: (180 - remaining_time)*3*/ at: {left + width, y} size: shape.height / 3;
			}

			graphics "Actions of players" visible: stage = PLAYER_ACTION_TURN {
				float y <- location.y + shape.height / 2;
				float left <- location.x - 7 * shape.width / 5;
				float right <- location.x + 7 * shape.width / 5;
				float gap <- (right - left) / length(simulation.numbers_actions);
				float index <- 0.5;
				loop s over: (sort(simulation.numbers_actions.keys, each)) {
					village v <- villages_order[index_player];
					bool selected <- village_actions[v] != nil and village_actions[v] contains s;
					draw s color: selected or over_action = s ? #white : rgb(255, 255, 255, 130) font: font("Impact", 36, #bold) anchor: #center at: {left + gap * index, y};
					if (selected) {
						draw circle(shape.width / 10) wireframe: true width: line_width color: #white at: {left + gap * index, y};
					}

					action_locations[s] <- {left + gap * index, y};
					index <- index + 1;
				}

			}

			graphics "Stage" position: {0, -500} {
				image_file icon <- (stage = PLAYER_DISCUSSION_TURN) ? discussion_icon : ((stage = PLAYER_ACTION_TURN) ? village_icon[int(villages_order[index_player])] : computer_icon);
				draw icon size: {3 * shape.width / 5, 3 * shape.width / 5};
				if (stage = PLAYER_ACTION_TURN) {
					draw "" + (int(villages_order[index_player]) + 1) color: #black font: base_font anchor: #center;
				}

			}

			graphics "Next" transparency: ((stage = PLAYER_DISCUSSION_TURN or stage = PLAYER_ACTION_TURN) and turn <= end_of_game) ? 0 : 0.6 {
				next_location <- {location.x + shape.width / 2, location.y};
				draw next_icon at: next_location size: shape.width / 4;
			}

			graphics "Play Pause" visible: turn <= end_of_game {
				pause_location <- {location.x - shape.width / 2, location.y};
				draw simulation.paused or about_to_pause ? play_icon : pause_icon at: pause_location size: shape.width / 4;
			}

//			event "1" {
//				ask simulation {
//					do execute_action(A_COLLECTION_LOW);
//				}
//
//			}

			event "a" {
				ask simulation {
					do execute_action(A_1);
				}

			}

			event "2" {
				ask simulation {
					do execute_action(A_2a);
				}

			}

			event "b" {
				ask simulation {
					do execute_action(A_2b);
				}

			}

			event "3" {
				ask simulation {
					do execute_action(A_3);
				}

			}

			event "c" {
				ask simulation {
					do execute_action(A_3);
				}

			}

			event "4" {
				ask simulation {
					do execute_action(A_4);
				}

			}

			event "d" {
				ask simulation {
					do execute_action(A_4);
				}

			}

			event "5" {
				ask simulation {
					do execute_action(A_5a);
				}

			}

			event "e" {
				ask simulation {
					do execute_action(A_5b);
				}

			}

			event "6" {
				ask simulation {
					do execute_action(A_6);
				}

			}

			event "f" {
				ask simulation {
					do execute_action(A_6);
				}

			}

			event "7" {
				ask simulation {
					do execute_action(A_7a);
				}

			}

			event "g" {
				ask simulation {
					do execute_action(A_7b);
				}

			}

			event "8" {
				ask simulation {
					do execute_action(A_8a);
				}

			}

			event "h" {
				ask simulation {
					do execute_action(A_8b);
				}

			}

			event "9" {
				ask simulation {
					do execute_action(A_9);
				}

			}

			event "i" {
				ask simulation {
					do execute_action(A_9);
				}

			}

			event "0" {
				ask simulation {
					do before_start_turn;
				}

			}

			event #mouse_move {
				using topology(simulation) {
					if (stage = PLAYER_ACTION_TURN) {
						loop s over: action_locations.keys {
							if (action_locations[s] distance_to #user_location < world.shape.width / 10) {
								over_action <- s;
								return;
							}

						}

					}

					over_action <- "";
				}

			}

			event #mouse_down {
				using topology(simulation) {
					if (next_location distance_to #user_location) < world.shape.width / 3 {
						if (turn > end_of_game) {
							return;
						}
						//write "Fast forward with distance to button = " + {world.shape.width + 3*world.shape.width/3, world.shape.height/2} distance_to #user_location;
						if (stage = PLAYER_DISCUSSION_TURN) {
							ask simulation {
								do end_of_discussion_phase;
							}

						} else if (stage != COMPUTE_INDICATORS) {
							ask simulation {
								ask villages_order[index_player] {
									do end_of_turn;
								}

							}

						}

					}

					if (pause_location distance_to #user_location) < world.shape.width / 3 {
					//write "Pause with distance to button = " + {world.shape.width + world.shape.width/3, world.shape.height/2} distance_to #user_location;
						ask simulation {
							if paused or about_to_pause {
								if (pause_started_time > 0) {
									time_for_discussion <- time_for_discussion + int((gama.machine_time - pause_started_time) / 1000);
								}

								pause_started_time <- 0.0;
								do resume;
							} else {
								pause_started_time <- gama.machine_time;
								do pause;
							}

						}

					}

					if (stage = PLAYER_ACTION_TURN and over_action != nil) {
						ask simulation {
							write "execute " + myself.over_action;
							do execute_action(numbers_actions[myself.over_action]);
						}

						over_action <- nil;
						return;
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
			slices[title] <- pair<rgb, float>(pair(col, value));
	}
	
	action increment(string title, float value) {
		if (slices.keys contains(title)) {
			slices[title] <-  pair<rgb, float>(pair(slices[title].key, slices[title].value + value));
		} 
	}
	
	action set_value(string title, float value) {
		if (slices.keys contains(title)) {
			slices[title] <-  pair<rgb, float>(pair(slices[title].key, value));
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
	map<string, bool> draw_smiley;
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
 		float xx_margin <- (world.shape.width - size)/2 + size/6; 
 		//draw square(size) wireframe: true border: #white width: 2; 
 		
 		float col_width <- size / length(data);
 		int col_index <- 0;
 		loop col over: data.keys {
 			float current_y <- 0.0;
 			loop c over: data[col].keys {
 				float v <- data[col][c];
 				float height <- v * ratio;
 				//draw  ""+v at:{col_index * col_width + xx_margin,location.y + size/2 - height/2} font: font('Helvetica',32,#bold) color: c anchor: #center;
 				draw rectangle(col_width,height) color: c at: {col_index * col_width + xx_margin,current_y + location.y + size/2 - height/2};
 				draw rectangle(col_width,height) wireframe: true border: #black width: 5 at: {col_index * col_width + xx_margin,current_y + location.y + size/2 - height/2};
 				current_y <- current_y + - height;
 			}
 			if (icons[col] != nil) {
 				draw icons[col] at: {col_index * col_width + xx_margin, size-size/10} size: {col_width/2, col_width/2};
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
 			if (col = "Water") {col_index <- col_index+0.5;}
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
 				if draw_smiley[col] {
 				if (total <= 1 and inf_or_sup[col] or total > 1 and !inf_or_sup[col]) {
 					draw smileys[0]  at: {size/10 + col_height/4, col_index * col_height  + y_margin+ col_height/4} size: {col_height/4, col_height/4};
 				} else {draw smileys[4]  at: {size/10+ col_height/4, col_index * col_height  + y_margin+ col_height/4} size: {col_height/4, col_height/4};}}
 			}
 			col_index <- col_index + 1;
 		}
 		draw line({location.x -size/3 + desired_value*ratio, location.y - 2*size/3},{location.x -size/3 + desired_value*ratio, location.y + size/8}) color: #white width: 5;
 		if (desired_icon != nil) {
 			draw desired_icon at: {location.x -size/3 + desired_value*ratio, location.y - 2*size/3} size: 2*col_height/3;
		}
 	}
 	
}
