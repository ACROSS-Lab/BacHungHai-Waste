/**
* Name: Charts
* Some chart species 
* Author: drogoul
* Tags: 
*/


model Charts

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
			start_angle <- (cur_value*360/sum) - 90;
			float arc_angle <- (p.value.value * 360/sum);
			draw arc(radius, start_angle + arc_angle/2, arc_angle) color: p.value.key  /*border: #white width: 5*/;
			cur_value <- cur_value + p.value.value;
		}
		
	}
	

	
}


species stacked_chart {
	point location <- {world.shape.width/2 ,world.shape.height/2};
	map<string, map<rgb,float>> data <- [];
	map<string, image_file> icons <- [];
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
 	
}

