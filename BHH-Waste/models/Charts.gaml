/**
* Name: Charts
* Some chart species 
* Author: drogoul
* Tags: 
*/


model Charts

species pie_chart {
	float radius;
	map<string, pair<rgb, float>> slices <- [];
	
	action add(string title, float value, rgb col) {
		if (slices.keys contains(title)) {
			slices[title] <- pair(slices[title].key, slices[title].value + value);
		} else {
			slices[title] <- pair(col, value);
		}
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
			draw arc(radius, start_angle + arc_angle/2, arc_angle) color: p.value.key  width: 5  ;
			cur_value <- cur_value + p.value.value;
		}
		
	}
	

	
}


species stacked_chart {
	
}

