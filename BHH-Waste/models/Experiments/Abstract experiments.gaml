/**
* Name: Abstractexperiments
* Based on the internal skeleton template. 
* Author: Patrick Taillandier
* Tags: 
*/

@no_experiment
model Abstractexperiments 


import "../Global.gaml"







experiment base_display virtual: true {
	
	action activate_act1 {ask world {do activate_act1;}}
	action activate_act2 {ask world {do activate_act2;}}
	
	action activate_act3 {ask world {do activate_act3;}}
	action activate_act4 {ask world {do activate_act4;}}
	action activate_act5 {ask world {do activate_act5;}}
	action activate_act6 {ask world {do activate_act6;}}
	action activate_act7 {ask world {do activate_act7;}}
	action activate_act8 {ask world {do activate_act8;}}
	action activate_act9 {ask world {do activate_act9;}}
	
	output {
		
		display "Player 1"  type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS { 
			rotation "rotation" angle: -180;
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[0].canals sum_of each.water_waste_level + village[0].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[0].canals sum_of each.solid_waste_level + village[0].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		display "Player 2"  type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS  { 
			rotation "rotation" angle: -90;
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[1].canals sum_of each.water_waste_level + village[1].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[1].canals sum_of each.solid_waste_level + village[1].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		display "Player 3"  type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS  { 
			rotation "rotation" angle: 0;
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[2].canals sum_of each.water_waste_level + village[2].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[2].canals sum_of each.solid_waste_level + village[2].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		display "Player 4" type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS  { 
			rotation "rotation" angle: 90;
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[3].canals sum_of each.water_waste_level + village[3].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[3].canals sum_of each.solid_waste_level + village[3].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		display map type: opengl  background: #black axes: false refresh: stage = COMPUTE_INDICATORS  {
			
			
			event "1" action: activate_act1;
			event "2" action: activate_act2;
			event "3" action: activate_act3;
			event "4" action: activate_act4;
			event "5" action: activate_act5;
			event "6" action: activate_act6;
			event "7" action: activate_act7;
			event "8" action: activate_act8;
			event "9" action: activate_act9;
	
			species commune;
			species house;
			species plot;
			species canal;
			species cell transparency: 0.5 ;
			species inhabitant;
			species farmer;
			species collection_team;
			species local_landfill;
			species communal_landfill;
			species village transparency: 0.5 ; 
			
			
		}
		display "global indicators" background: #black refresh: stage = COMPUTE_INDICATORS  {
			chart "Waste pollution " size:{1.0, 0.3} background: #black color: #white{
				data "Water waste pollution" value: canal sum_of each.water_waste_level + cell sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0, 1/3} size:{1.0, 1/3} background: #black color: #white{
				data "Solid waste pollution" value: canal sum_of each.solid_waste_level + cell sum_of each.solid_waste_level  color: #red marker: false;
			}
			
			
		}
	}
}

experiment abstract_display virtual: true {
	
}

experiment base_display_layout_test virtual: true {
	output {
		
		layout horizontal([vertical([0::1000,1::5000,2::1000])::1000,vertical([3::1000,4::5000,5::1000])::5000,vertical([6::1000,7::5000,8::1000])::1000])
		toolbars: false tabs:false parameters:true consoles:true navigator:true controls:true tray:true;
		display "Fake 1"  type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
			
		}
		
		display "Player 1"  type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
			
		}
		
		display "Fake 2"  type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
			
		}
		display "Player 2"  type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
			rotation "rotation" angle: 180;
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[1].canals sum_of each.water_waste_level + village[1].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[1].canals sum_of each.solid_waste_level + village[1].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		display map type: opengl  background: #black axes: false refresh: stage = COMPUTE_INDICATORS{
			species commune;
			species house;
			species plot;
			species canal;
			species cell transparency: 0.5 ; 
			species inhabitant;
			species farmer;
			species collection_team;
			species local_landfill;
			species communal_landfill;
			species village transparency: 0.5 ; 

		}
		display "Player 3"  type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
			rotation "rotation" angle: 0;
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[2].canals sum_of each.water_waste_level + village[2].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[2].canals sum_of each.solid_waste_level + village[2].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		display "Fake 3"  type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
			
		}
		display "Player 4" type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
			rotation "rotation" angle: 90;
			chart "Waste pollution " size:{0.5, 1.0} background: #black color: #white{
				data "Water waste pollution" value: village[3].canals sum_of each.water_waste_level + village[3].cells sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0.5, 0.0} size:{0.5,1.0} background: #black color: #white{
				data "Solid waste pollution" value: village[3].canals sum_of each.solid_waste_level + village[3].cells  sum_of each.solid_waste_level  color: #red marker: false;
			}
		}
		display "Fake 4"  type:opengl axes: false background: #black refresh: stage = COMPUTE_INDICATORS{ 
			
		}
		/*display "global indicators" background: #black refresh: stage = COMPUTE_INDICATORS{
			chart "Waste pollution " size:{1.0, 0.3} background: #black color: #white{
				data "Water waste pollution" value: canal sum_of each.water_waste_level + cell sum_of each.water_waste_level  color: #red marker: false;
			}
			chart "Waste pollution " position:{0, 1/3} size:{1.0, 1/3} background: #black color: #white{
				data "Solid waste pollution" value: canal sum_of each.solid_waste_level + cell sum_of each.solid_waste_level  color: #red marker: false;
			}
			
			
		}*/
	}
}