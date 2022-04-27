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

	shape_file Routes_shape_file <- shape_file("../includes/Shp_fictifs/Routes.shp");

	shape_file Hydrologie_shape_file <- shape_file("../includes/Shp_fictifs/Hydrologie.shp");

	geometry shape <- envelope(Limites_commune_shape_file);
	
	float step <- 1#day;
	int num_collection_team <- 1;
	float treatment_factory_capacity <- 2.0;
	
	float house_size <- 100.0 #m;
	float plot_size <- 300.0 #m;
	float min_display_waste_value <- 0.2;
	
	float factor_time_collect_cell <- 3.0;
	
	float distance_max_bin <- 50 #m;
	init {
		create road from: split_lines(Routes_shape_file);
		create canal from: split_lines(Hydrologie_shape_file);
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
			}
		}
		
		list<geometry> ps <- to_squares (free_space,plot_size);
		

		create plot from: ps {
			create farmer {
				location <- myself.location;
				my_house <- cell(location);
			}
		}
		
		
		list<road> roads_outside <- road where not(first(district) covers each);
		create dumpyard {
			shape <- square(200) ;
			location <- any_location_in(one_of(roads_outside).shape - first(district).shape);
		}
		
		create treatment_factory with:( capacity_per_day: treatment_factory_capacity) {
			location <- any_location_in(one_of(roads_outside).shape - first(district).shape);
	
		}
		
		
		create collection_team number: num_collection_team;
		ask cell {do update_color;}
	}
	
	action create_bin {
		create bin with: (location: #user_location);
	}
}


grid cell height: 50 width: 50 {
	float waste_level <- 0.0 min: 0.0 max: 1.0;
	
	action update_color {
		color <- rgb(255 * waste_level, 255 * (1.0 - waste_level),  0);
	} 
	
	reflex updating_color {
		do update_color;
	}
	
	aspect default {
		if waste_level > min_display_waste_value {
			draw shape color: color;
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
	aspect default {
		draw shape + 10.0 color: #blue;
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
	
	reflex treatment {
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
	float max_agricultural_waste_production <- rnd(0.01, 0.05);
	
	action agricultrual_waste_production {
		ask (my_house.neighbors + my_house) {
			waste_level <- waste_level + rnd(myself.max_agricultural_waste_production);
		}
	}
	
	reflex produce_waste {
		do domestic_waste_production;
		do agricultrual_waste_production;
		
	}
}
species inhabitant {
	rgb color <- #red;
	cell my_house;
	float max_waste_production <- rnd(0.01, 0.2);
	
	aspect default {
		draw circle(10.0) color: color;
	}
	
	action domestic_waste_production {
		list<bin> close_bins <- (bin at_distance distance_max_bin) where (each.waste_level < each.capacity) ;
		float waste_produced <- rnd(max_waste_production);
		loop b over: close_bins {
			if waste_produced > 0 {
				float qw <-  min(waste_produced, b.capacity - b.waste_level);
				b.waste_level <- b.waste_level + qw;
				waste_produced <- waste_produced - qw;
			}
		}
		if waste_produced > 0 {
			ask one_of(my_house.neighbors + my_house) {
				waste_level <- waste_level + waste_produced;
			}
		}
		
	}
	
	reflex produce_waste {
		do domestic_waste_production;
	}
}

species factory {
	
}
species bin {
	float capacity <- 5.0;
	float waste_level;
	aspect default {
		draw triangle(50.0) color: #magenta border: #black;
	}
	
}

species collection_team skills: [moving]{
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
	
	reflex collect_waste {
		bin_cleaned <- [];
		cell_cleaned <- [];
		float waste_collected <- 0.0;
		float remaining_time;
		loop while: waste_collected < collection_capacity  and remaining_time > 0 {
			list<bin> bins_to_collect <- bin where (each.waste_level > 0);
			if not empty(bins_to_collect) {
				bin the_bin <-bins_to_collect with_max_of (each.waste_level);
					ask the_bin{
						float time_used <- min(waste_level, remaining_time);
						float ratio <- waste_level / remaining_time;
						remaining_time <- remaining_time - time_used;
						waste_collected <- waste_collected + (ratio * waste_level);
						waste_level <- waste_level * (1 - ratio);
						myself.bin_cleaned << self;
					}
			} else {
				list<cell> cells_to_clean <-  cell where (each.waste_level > 0);
				if  empty(cells_to_clean) {
					break;
				}
				else {
					cell the_cell <- cells_to_clean with_max_of (each.waste_level);
					ask the_cell{
						float time_used <- min(factor_time_collect_cell * waste_level, remaining_time);
						float ratio <- factor_time_collect_cell * waste_level / remaining_time;
						remaining_time <- remaining_time - time_used;
						waste_collected <- waste_collected + (ratio * waste_level);
						waste_level <- waste_level * (1 - ratio);
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
			waste_level <- waste_level + waste_collected - waste_to_dumpyard;
		}
		
		
		
	}
	
}

experiment WasteManagement type: gui {
	
	init {
		//create simulation with: (num_collection_team: 3,treatment_factory_capacity: 10.0);
	}
	output {
		display map type: opengl{
			species district;
			species urban_area;
			species plot;
			species canal;
			species road;
			species cell transparency: 0.5 ;
			species inhabitant;
			species farmer;
			species bin;
			species collection_team;
			species dumpyard;
			species treatment_factory;
			event mouse_down action: create_bin; 
		}
	}
}
