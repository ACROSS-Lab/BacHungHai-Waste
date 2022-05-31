/**
* Name: NetworkManager
* Based on the internal skeleton template. 
* Author: Baptiste
* Tags: 
*/

model NetworkManager

global {
	init {
		create NetworkManager number:1;
	}
}



species NetworkManager skills:[network]{

	int port <- 8989;

	//States
	int st_none <- -1;
	int st_wait_players_connect <- 1;
	int st_wait_players_moves	<- 2;
	int st_send_players_data	<- 3;
	
	//Keywords for communication
	string kw_ask_for_connection 	<- "_AFC_";
	string kw_initial_data			<- "_INIT_DATA_";
	string kw_water_pollution		<- "_WATER_";
	string kw_solid_pollution		<- "_SOLID_";
	string kw_send_action			<- "_ACTIONS_";
	string kw_player_name			<- "player_name";
	string kw_budget				<- "budget";
	string kw_actions				<- "actions";
	
	int state; 
	
	list<string> 		player_names;
	list<unknown> 		players;
	list<int>			player_budgets;
	map<string,string> 	players_actions;
	list<map<string,unknown>>	available_actions;
	
	
	action map_to_json(map<string,unknown> m) {
		string ret <- '';
		loop key_val over:m.pairs {
			if ret != '' {
				ret <- ret + ',';
			}
			ret <- ret + '"' + key_val.key + '":"' + key_val.value + '"';
		}
		return '{' + ret + '}';
	}
	
	action list_of_map_to_json(list<map<string,unknown>> l) {
		string ret <- '';
		loop m over:l {
			if ret != '' {
				ret <- ret + ',';
			}
			ret <- ret + map_to_json(m);
		}
		return '[' + ret + ']';
	}
	
	init {
		
		state 			<- st_none;
		player_names 	<- [];
		players 		<- [];
		
		do connect protocol:"tcp_server" port:port raw:true;
		
		
		
		do start_waiting_for_players_to_connect([	
													"Village fictif numéro 1" 
													//"Village fictif numéro 2"
												],
												[	
													128
												//	132
												],
												[
													['id'::1,'name'::'Drain and dredge', 'cost'::20,'once_per_game'::false,'grouped'::true,'mandatory'::false],
													['id'::2,'name'::'Drain and dredge', 'cost'::50,'once_per_game'::false,'grouped'::true,'mandatory'::false],
													['id'::3,'name'::'Sensibilization',  'cost'::25,'once_per_game'::false,'grouped'::false,'mandatory'::false],
													['id'::4,'name'::'Collect_waste',    'cost'::25,'once_per_game'::false,'grouped'::true,'mandatory'::true],
													['id'::5,'name'::'Collect_waste',    'cost'::50,'once_per_game'::false,'grouped'::true,'mandatory'::true],
													['id'::6,'name'::'Install facility treatments', 'cost'::50,'once_per_game'::true,'grouped'::false,'mandatory'::false]
													
												]
		);
	}
	
	
	action start_waiting_for_players_to_connect(list<string> _player_names, list<int> _player_budgets, list<map> actions){
		
		player_names 	<- _player_names;
		player_budgets 	<- _player_budgets;
		state 			<- st_wait_players_connect;
		available_actions <- actions;
		
	}
	
	reflex wait_for_players_to_connect when:state=st_wait_players_connect{
		loop while:has_more_message() and length(players) < length(player_names) {
			message mess <- fetch_message();
			write "message received " + mess;
			string content <- mess.contents;
			if content contains kw_ask_for_connection {
				string ip <- (content split_with ':')[1];
				write "new player: " + ip;
				do send to:mess.sender contents:kw_initial_data + ":{"  
						+ '"' + kw_player_name 	+ '":"' + player_names[length(players)] + '",' 
						+ '"' + kw_budget 		+ '":' 	+ player_budgets[length(players)] +","
						+ '"' + kw_actions		+ '":' 	+ list_of_map_to_json(available_actions) 
						+ '}';
				players <- players + mess.sender;
			}
			
		}
		
		if  length(players) = length(player_names) {
			write "all players joined";
			state <- st_send_players_data;
		}
	}
	
	
	reflex send_data_to_players when:state=st_send_players_data{
		let fake_data 	<- [2,3,4,5,6,7,8];
		let fake_data2 	<- [200,300,400,500,600,700,800];
		
		do send contents:kw_water_pollution + ":" + fake_data;
		do send contents:kw_solid_pollution + ":" + fake_data2;
		
		do start_waiting_for_players_to_play();
		
	}
	
	
	action start_waiting_for_players_to_play {
		state <- st_wait_players_moves;
		players_actions <- [];
		
	}
	

	reflex wait_for_players_to_play when:state=st_wait_players_moves {
		loop while:has_more_message() and length(players_actions) < length(player_names) {
			message mess <- fetch_message();
			write "message received " + mess;
			string content <- mess.contents;
			
		}	
	}	


	
}

experiment test {
	
}
