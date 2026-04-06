/**
* Name: graphiqueExplo
* Based on the internal skeleton template. 
* Author: patricktaillandier
* Tags: 
*/

model chartExplo

global {
	csv_file exploration_result_csv_file <- csv_file("exploration_result.csv", ",");
	list<map<int,float>> solid_waste;
	list<map<int,float>> water_waste;
	list<map<int,float>> production;
	
	float min_production_ecolabel <- 3000.0;// minimum threshold of production to get EcoLabel, unities are tons of rice produced
	float max_pollution_ecolabel <- 300000.0;// maximum threshold of production to get ecolabel, unities are converted in 
	
	
	init {
		matrix mat <- matrix(exploration_result_csv_file);
		int index_ <- -1;
		int day;
		loop i from: 0 to: mat.rows -1 {
			
			int c <- int(mat[1,i]);
			if c = 0 {
				index_ <- index_ + 1;
				solid_waste << [];
				production << [];
				water_waste << [];
				day <- 0;
			}
			solid_waste[index_][day] <- float(mat[2,i]);
			water_waste[index_][day] <- float(mat[3,i]);
			production[index_][day] <- float(mat[4,i]);
			day <- day +1;
		}
	}
	
	reflex end_sim when: cycle >= length(solid_waste) {
		do pause;
	}
	
}

experiment chartExplo type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display chart_solid_waste_pollution type:2d {
			chart "Solid Waste" {
				loop i from:0 to: length(solid_waste) - 1 {
					data "" + i value: solid_waste[i][cycle] color: #gray;
				}
			}
		}
		display chart_water_waste_pollution type:2d{
			chart "Water Waste" {
				loop i from:0 to: length(water_waste) - 1 {
					data "" + i value: water_waste[i][cycle] color: #gray;
				}
			}
		}
		display chart_production type:2d{
			chart "Agricultural Production" {
				loop i from:0 to: length(production) - 1 {
					data "" + i value: production[i][cycle] color: #green;
				}
				data "Min production" value: min_production_ecolabel color: #black;
			}
		}
		
		display chart_pollution type:2d{
			chart "Total pollution" {
				loop i from:0 to: length(water_waste) - 1 {
					data "" + i value: water_waste[i][cycle] + solid_waste[i][cycle] color: #gray;
				}
				data "Max pollution" value: max_pollution_ecolabel color: #black;
			}
		}
	}
}
