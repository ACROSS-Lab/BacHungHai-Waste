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

species Sender skills:[network] {
	
}

species Receiver skills:[network] {
	
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
	
	int state; 
	
	list<string> 		player_names;
	list<string> 		players;
	list<int>			player_budgets;
	map<string,string> 	players_actions;
	
	
	
	init {
		
		state <- st_none;
		player_names <- [];
		players <- [];
		
		do connect protocol:"tcp_server" port:port raw:true;
		
		do start_waiting_for_players_to_connect(["Village fictif numéro 1"],[128]);
	}
	
	
	action start_waiting_for_players_to_connect(list<string> _player_names, list<int> _player_budgets){
		
		player_names 	<- _player_names;
		player_budgets 	<- _player_budgets;
		state 			<- st_wait_players_connect;
		
	}
	
	reflex wait_for_players_to_connect when:state=st_wait_players_connect{
		loop while:has_more_message() and length(players) < length(player_names) {
			message mess <- fetch_message();
			write "message received " + mess;
			string content <- mess.contents;
			if content contains kw_ask_for_connection {
				string ip <- (content split_with ':')[1];
				write "new player: " + ip;
				do send to:ip contents:kw_initial_data + ":{"  
						+ '"' + kw_player_name 	+ '":"' + player_names[length(players)] + '",' 
						+ '"' + kw_budget 		+ '":' + player_budgets[length(players)]
						+ '}';
				players <- players + ip;//TODO: sender quand ça marchera
			}
			
		}
		
		if  length(players) = length(player_names) {
			write "all players joined";
			state <- st_send_players_data;
		}
	}
	
	
	reflex send_data_to_players when:state=st_send_players_data{
		let fake_data <- [2,3,4,5,6,7,8];
		let fake_data2 <- [200,300,400,500,600,700,800];
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
