/**
* Name: WasteManagement
* Based on the internal skeleton template. 
* Author: Patrick Taillandier
* Tags: 
*/

model WasteManagement

global {
	
	shape_file Limites_commune_shape_file <- shape_file("../includes/Shp_fictifs/Limites_commune.shp");

	shape_file Limites_villages_shape_file <- shape_file("../includes/Shp_fictifs/Limites_villages.shp");

	//shape_file Routes_shape_file <- shape_file("../includes/Shp_fictifs/Routes.shp");

	shape_file Hydrologie_shape_file <- shape_file("../includes/Shp_fictifs/Hydrologie.shp");

	geometry shape <- envelope(Limites_commune_shape_file);
	
	shape_file Territoires_villages_shape_file <- shape_file("../includes/Shp_fictifs/Territoires_villages.shp");

	float step <- 1#day;
	int num_collection_team <- 1;
	float treatment_factory_capacity <- 2.0;
	
	float house_size <- 200.0 #m;
	float plot_size <- 500.0 #m;
	float min_display_waste_value <- 0.2;
	
	float factor_time_collect_cell <- 3.0;
	float coeff_visu_canal <- 3.0;
	float distance_max_bin <- 50 #m;
	
	string PLAYER_TURN <- "player turn";
	string COMPUTE_INDICATORS <-  "compute indicators";
	string ACT_BUILD_BINS <- "build bins";
	string ACT_BUILD_TREATMENT_FACTORY <- "build treatment factory";
	string ACT_END_OF_TURN <- "end of turn";
	
	string stage <-COMPUTE_INDICATORS;
	
	float distance_bins <- 300.0 #m;
	
	float rate_diffusion_liquid_waste <- 10.0; //rate of liquid waste per perimeter of canals passing to the the downstream canal
	float rate_diffusion_solid_waste <- 1.0;//rate of solid waste per perimeter of canals passing to the the downstream canal
	
	int index_player <- 0;
	date computation_end;
	
	//current action type
	int action_type <- -1;	
	
	//float budget_per_year <- 100.0;
	float bin_price_unity <- 10.0; 
	float treatment_factory_price <- 20.0;
	
	//images used for the buttons
	list<string> actions_name <- [
		ACT_BUILD_BINS,
		ACT_BUILD_TREATMENT_FACTORY,
		ACT_END_OF_TURN		
	]; 
	
	
	list<rgb> territory_color <- [#magenta, #gold, #violet,#orange];
	
	init {
		create territory from: Territoires_villages_shape_file sort_by (location.x + location.y * 2);
		//create road from: split_lines(Routes_shape_file);
		create canal from: split_lines(Hydrologie_shape_file) {
			if (first(shape.points).x + (2 * first(shape.points).y)) > (last(shape.points).x + 2 * last(shape.points).y){
				shape <- line(reverse(shape.points));
			} 
		}
	
		graph canal_network <- directed(as_edge_graph(canal));
		ask canal {
			downtream_canals<- list<canal>(canal_network out_edges_of (canal_network target_of self));	
		}
		
		geometry free_space <- copy(shape);
		
		create district from: Limites_commune_shape_file {
			free_space <- copy(shape);
		}
		list<geometry> uas;
		loop ua over:list(Limites_villages_shape_file) {
			uas <- uas + to_squares (ua,house_size);
			free_space <- free_space - ua;
		
		} 
		create urban_area from: uas {
			create inhabitant {
				location <- myself.location;
				my_house <- cell(location);
				closest_canal <- canal closest_to self;
			}
		}
		
		list<geometry> ps <- to_squares (free_space,plot_size);
		

		create plot from: ps {
			create farmer {
				location <- myself.location;
				my_house <- cell(location);
				closest_canal <- canal closest_to self;
			}
		}
		
		
		
		list<road> roads_outside <- road where not(first(district) covers each);
		create dumpyard {
			shape <- square(200) ;
			location <- any_location_in(first(district).shape.contour);
		}
		
		/*create treatment_factory with:( capacity_per_day: treatment_factory_capacity) {
			location <- any_location_in(one_of(roads_outside).shape - first(district).shape);
	
		}*/
		
	
		
		create collection_team number: num_collection_team;
		ask cell {do update_color;}
		ask territory {
			cells <- cell at_distance 1.0;
			canals <- canal at_distance 1.0;
			inhabitants <- inhabitant at_distance 1.0 + farmer at_distance 1.0;
		}
		computation_end <- current_date add_years 1;
	}
	
	action activate_act {
		if stage = PLAYER_TURN {
			button selected_but <- first(button overlapping (circle(1) at_location #user_location));
			if(selected_but != nil) {
				ask selected_but {
					ask button {bord_col<-#black;}
					if (action_type != id) {
						action_type<-id;
						bord_col<-#red;
						ask myself {do act_management();}
					} else {
						action_type<- -1;
					}
					
				}
			}
		}
	}
	
	action act_management {
		switch action_type {
			match 0 {ask territory[index_player] {do build_bins;}}
			match 1 {ask territory[index_player] {do build_treatment_factory;}}
			match 2 {ask territory[index_player] {do end_of_turn;}}
		}
	}
	
	reflex indicators_computation when: stage = COMPUTE_INDICATORS {
		ask canal {
			do init_flow;
		}
		ask canal {
			do flow;
		}
		ask canal {
			do update_waste;
		}
		ask territory {do compute_indicators;}
		if (current_date >= computation_end) {
			stage <- PLAYER_TURN;
			index_player <- 0;
			step <- 0.0001;
			ask territory {
				budget <- (population_level - pollution_level / 2.0)* 100.0;
			}
			//global_budget <- global_budget + budget_per_year;
			ask territory {
				actions_done <- [];
			}
			do tell("PLAYER TURN");
			do tell("PLAYER 1 TURN");
		}
	}
	
	reflex playerturn when: stage = PLAYER_TURN{
		if index_player >= length(territory) {
			stage <- COMPUTE_INDICATORS;
			current_date <- computation_end;
			computation_end <- computation_end add_years 1;
			step <- #day;
			
			do tell("INDICATOR COMPUTATION");
		}
	}
	
}


grid button width:3 height:3 
{
	int id <- int(self);
	rgb bord_col<-#black;
	aspect normal {
		draw rectangle(shape.width * 0.8,shape.height * 0.8).contour + (shape.height * 0.01) color: bord_col;
		draw actions_name[id] font: font("Helvetica", 20 , #bold) color: #white;
	}
}



grid cell height: 50 width: 50 {
	float solid_waste_level <- 0.0 min: 0.0;
	
	action update_color {
		color <- rgb(255 * solid_waste_level, 255 * (1.0 - solid_waste_level),  0);
	} 
	
	aspect default {
		if solid_waste_level > min_display_waste_value {
			do update_color;
			draw shape color: color;
		}
	}
	
}

species territory {
	rgb color <- territory_color[int(self)];
	list<string> actions_done;
	list<cell> cells;
	list<canal> canals;
	list<inhabitant> inhabitants;
	float budget;
	float pollution_level ;
	float population_level;
	float economical_level min: 0.0;
	action compute_indicators {
		pollution_level <- (cells sum_of each.solid_waste_level) + (canals sum_of (each.solid_waste_level + each.liquid_waste_level));
		pollution_level <- pollution_level / 50000;
		population_level <- length(inhabitants) / 100.0;
		economical_level <- population_level - pollution_level/2.0;
	}
	action end_of_turn {
		bool  is_ok <- user_confirm("End of turn","PLAYER " + (index_player + 1) +", do you confirm that you want to end the turn?");
		if is_ok {
			
			index_player <- index_player + 1;
			if index_player < length(territory) {
				
				do tell("PLAYER " + (index_player + 1) + " TURN");
			}
		}
	}
	action build_bins {
		
		list<point> bin_locations <- (shape to_squares(distance_bins)) collect each.location;
		bool  is_ok <- user_confirm("Action Build Bins","PLAYER " + (index_player + 1) +", do you confirm that you want to build bins for " + (length(bin_locations) * bin_price_unity)+ "$?");
		int cpt <- 0;
		if is_ok {
			loop pt over: shuffle(bin_locations) {
				 if budget >= bin_price_unity {
				 	create bin with: (location: pt);
				 	budget <- budget -bin_price_unity;
				 	cpt <- cpt + 1;
				 }
			}
		}
		if cpt < length(bin_locations) {
			do tell("Due to financial constraint, only " + cpt + " bins were build whereas " + length(bin_locations) + " were planned");
		}
	}
	
	action build_treatment_factory {
		 	bool  is_ok <- user_confirm("Action Build Treatùent factory","PLAYER " + (index_player + 1) +", do you confirm that you want to a treatment factory for " + treatment_factory_price+ "$?");
			if is_ok {
				if budget >= treatment_factory_price {
				  	create treatment_factory with:( capacity_per_day: treatment_factory_capacity) {
						location <- myself.location;
					}
					budget <- budget -treatment_factory_price;
				} else {
					do tell("Not enough money for that");
				}
		}
	}
	aspect default {
		if (stage = PLAYER_TURN) {
			if (index_player = int(self)) {
				draw shape color: color;
			}
		} else {
			
			draw shape.contour + 20.0 color: color;
		}
	}
}

species plot {
	aspect default {
		draw shape color: #green border: #black;
	}
}

species urban_area {
	aspect default {
		draw shape color: #gray border: #black;
	}
}
species canal {
	float solid_waste_level min: 0.0;
	float liquid_waste_level min: 0.0;
	float solid_waste_level_tmp;
	float liquid_waste_level_tmp;
	list<canal> downtream_canals;
	
	action init_flow {
		solid_waste_level_tmp <- 0.0;
		liquid_waste_level_tmp <- 0.0;
	}
	action flow {
		
		float to_diffuse_solid <-  solid_waste_level / shape.perimeter  * rate_diffusion_solid_waste  ; 
		float to_diffuse_liquid <-  liquid_waste_level / shape.perimeter  * rate_diffusion_liquid_waste ; 
		
		int nb <- length(downtream_canals);
		if nb > 0 {
			ask downtream_canals {
				solid_waste_level_tmp <- solid_waste_level_tmp + to_diffuse_solid/ nb;
				liquid_waste_level_tmp <- liquid_waste_level_tmp +to_diffuse_liquid  / nb;
			}
		}
		solid_waste_level_tmp <- solid_waste_level_tmp - to_diffuse_solid ;
		liquid_waste_level_tmp <-  liquid_waste_level_tmp - to_diffuse_liquid;
	}
	action update_waste {
		solid_waste_level <- solid_waste_level + solid_waste_level_tmp;
		liquid_waste_level <- liquid_waste_level + liquid_waste_level_tmp ;
	}
	aspect default {
		draw shape + 10.0 color: blend(#red,#blue,(solid_waste_level+liquid_waste_level)/shape.perimeter / coeff_visu_canal);
		draw "" + int(self) + " -> " + (downtream_canals collect int(each)) color: #black;
	}
}


species road {
	aspect default {
		draw shape + 5.0 color: #black;
	}
}

species district {
	rgb color <- #pink;
	aspect default {
		draw shape color: color;
	}
}

species treatment_factory {
	float capacity_per_day;
	
	reflex treatment when: stage = COMPUTE_INDICATORS {
		float treated <- 0.0;
		ask dumpyard {
			float max_treated <- min(waste_quantity, myself.capacity_per_day);
			waste_quantity <- waste_quantity - max_treated;
		}
	}
	aspect default {
		draw circle(capacity_per_day * 50.0) border: #black color: #gold;
	}
}

species dumpyard {
	float waste_quantity;
	aspect default {
		draw shape depth: waste_quantity / 10.0 border: #blue color: #red;
	}
}

species farmer parent: inhabitant {
	rgb color <- #yellow;
	float max_agricultural_waste_production <- rnd(1.0, 3.0);
	
	action agricultrual_waste_production {
		ask closest_canal {
			liquid_waste_level <- liquid_waste_level + rnd(myself.max_agricultural_waste_production);
		}
	}
	
	reflex produce_waste when: stage = COMPUTE_INDICATORS{
		do domestic_waste_production;
		do agricultrual_waste_production;
		
	}
}
species inhabitant {
	rgb color <- #red;
	cell my_house;
	float max_solid_waste_production <- rnd(0.3, 0.8);
	float max_liquid_waste_production <- rnd(0.1, 0.1);
	float rate_to_canal <- 0.4;
	canal closest_canal;
	aspect default {
		draw circle(10.0) color: color;
	}
	
	action domestic_waste_production {
		list<bin> close_bins <- (bin at_distance distance_max_bin) where (each.solid_waste_level < each.capacity) ;
		float solid_waste_produced <- rnd(max_solid_waste_production);
		loop b over: close_bins {
			if solid_waste_produced > 0 {
				float qw <-  min(solid_waste_produced, b.capacity - b.solid_waste_level);
				b.solid_waste_level <- b.solid_waste_level + qw;
				solid_waste_produced <- solid_waste_produced - qw;
			}
		}
		if solid_waste_produced > 0 {
			float to_the_ground <- rate_to_canal * solid_waste_produced;
			ask one_of(my_house.neighbors + my_house) {
				solid_waste_level <- solid_waste_level + to_the_ground;
			}
			closest_canal.solid_waste_level <- closest_canal.solid_waste_level + solid_waste_produced - to_the_ground;
			
		}
		float liquid_waste_produced <- rnd(max_solid_waste_production);
		if liquid_waste_produced > 0 {
			closest_canal.solid_waste_level <- closest_canal.liquid_waste_level + liquid_waste_produced;
		}	
	}
	
	reflex produce_waste when: stage = COMPUTE_INDICATORS{
		do domestic_waste_production;
	}
}

species factory {
	
}
species bin {
	float capacity <- 5.0;
	float solid_waste_level;
	aspect default {
		draw triangle(50.0) color: #magenta border: #black;
	}
	
}

species collection_team {
	rgb color <- #gold;
	int nb_collection_week <- 2;
	float collection_capacity <- 10.0;
	float time_capacity <- 30.0;
	float part_to_dumpyard <- 1.0;//rnd(0.2, 1.0);
	list<cell> cell_cleaned;
	list<bin> bin_cleaned;
	
	aspect default {
		loop cl over: cell_cleaned {
			draw cl.shape.contour + 0.01 color: color;
		}
	}
	
	reflex collect_waste when: stage = COMPUTE_INDICATORS {
		bin_cleaned <- [];
		cell_cleaned <- [];
		float waste_collected <- 0.0;
		float remaining_time;
		loop while: waste_collected < collection_capacity  and remaining_time > 0 {
			list<bin> bins_to_collect <- bin where (each.solid_waste_level > 0);
			if not empty(bins_to_collect) {
				bin the_bin <-bins_to_collect with_max_of (each.solid_waste_level);
					ask the_bin{
						float time_used <- min(solid_waste_level, remaining_time);
						float ratio <- solid_waste_level / remaining_time;
						remaining_time <- remaining_time - time_used;
						waste_collected <- waste_collected + (ratio * solid_waste_level);
						solid_waste_level <- solid_waste_level * (1 - ratio);
						myself.bin_cleaned << self;
					}
			} else {
				list<cell> cells_to_clean <-  cell where (each.solid_waste_level > 0);
				if  empty(cells_to_clean) {
					break;
				}
				else {
					cell the_cell <- cells_to_clean with_max_of (each.solid_waste_level);
					ask the_cell{
						float time_used <- min(factor_time_collect_cell * solid_waste_level, remaining_time);
						float ratio <- factor_time_collect_cell * solid_waste_level / remaining_time;
						remaining_time <- remaining_time - time_used;
						waste_collected <- waste_collected + (ratio * solid_waste_level);
						solid_waste_level <- solid_waste_level * (1 - ratio);
						myself.cell_cleaned << self;
			
					}
				}
		
			}
		}
		
		float waste_to_dumpyard <- part_to_dumpyard * waste_collected;
		ask one_of(dumpyard) {
			waste_quantity <- waste_quantity + waste_to_dumpyard;
		}
		ask one_of (cell) {
			solid_waste_level <- solid_waste_level + waste_collected - waste_to_dumpyard;
		}
		
		
		
	}
	
}

experiment WasteManagement type: gui {
	
	init {
		//create simulation with: (num_collection_team: 3,treatment_factory_capacity: 10.0);
	}
	output {
		display map type: opengl  background: #black axes: false refresh: stage = COMPUTE_INDICATORS{
		/*	graphics "legend" {
				draw (stage +" " + (stage = PLAYER_TURN ? ("Player " + (index_player + 1) + " - Global budget: " + global_budget) : ""))  font: font("Helvetica", 50 , #bold) at: {world.location.x, 10} anchor:#center color: #white;
			} */
			chart "Indicators Territory 1" type: radar background: #black size: {0.4, 0.4} position: {-0.3, 0.0}  x_serie_labels: ["pollution", "economy", "population"] color: #white series_label_position: xaxis{
				data "Pollution level" value: [territory[0].pollution_level,territory[0].economical_level,territory[0].population_level] color:territory[0].color;
				
			}
			
			chart "Indicators Territory 2" type: radar background: #black size: {0.4, 0.4} position: {-0.3, 0.7} x_serie_labels: ["pollution", "economy", "population"] color: #white series_label_position: xaxis{
				data "Pollution level" value: [territory[1].pollution_level,territory[1].economical_level,territory[1].population_level] color: territory[1].color;
				
			}
			chart "Indicators Territory 3" type: radar background: #black size: {0.4, 0.4} position: {1.0, 0.0} x_serie_labels: ["pollution", "economy", "population"] color: #white series_label_position: xaxis{
				data "Pollution level" value: [territory[2].pollution_level,territory[2].economical_level,territory[2].population_level] color: territory[2].color;
				
			}
			chart "Indicators Territory 4" type: radar background: #black size: {0.4, 0.4} position: {1.0, 0.7} x_serie_labels: ["pollution", "economy", "population"] color: #white series_label_position: xaxis{
				data "Pollution level" value: [territory[3].pollution_level,territory[3].economical_level,territory[3].population_level] color: territory[3].color;
				
			}
			
			species district;
			species urban_area;
			species plot;
			species canal;
			//species road;
			species cell transparency: 0.5 ;
			species inhabitant;
			species farmer;
			species bin;
			species collection_team;
			species dumpyard;
			species treatment_factory;
			species territory transparency: 0.5 ;
			
		
			
			//event mouse_down action: create_bin; 
		}
		display action_buton background:#black name:"Tools panel"  	{
			
			species button aspect:normal ;
			event mouse_down action:activate_act;    
		}
	}
}
