/**
* Name: NetworkManager
* Based on the internal skeleton template. 
* Author: Baptiste
* Tags: 
*/

model NetworkManager


species NetworkManager skills:[network]{



	int port	<- 8989; //Default to 8989

	//Keywords for communication
	string kw_ask_for_connection 	<- "_AFC_";
	string kw_initial_data			<- "_INIT_DATA_";
	string kw_water_pollution		<- "_WATER_";
	string kw_solid_pollution		<- "_SOLID_";
	string kw_productivity			<- "_PRODUCTIVITY_";
	string kw_send_action			<- "_ACTIONS_";
	string kw_player_name			<- "player_name";
	string kw_budget				<- "budget";
	string kw_actions				<- "actions";
	string kw_player_actions		<- "_AFEOT_";
	string kw_start_turn			<- "_START_TURN_";
	string kw_turn_number			<- "turn";
	string kw_your_turn				<- "_YT_";
	string kw_not_your_turn			<- "_NYT_";
	
	
	list<string> 				player_names;
	list<unknown> 				players;
	map<unknown,list<string>> 	players_actions;
	list<map<string,unknown>>	available_actions;
	
	
	init {
		players_actions	<- [];
		player_names 	<- [];
		players 		<- [];
		
		do connect protocol:"tcp_server" port:port raw:true size_packet:100000;
		
	}
	
	action send_data_before_turn(unknown player, int turn_budget, int turn_number) {
		let mess <- kw_start_turn +':{"' +kw_budget +'":' + turn_budget + ',"' + kw_turn_number+ '":' + turn_number +"}";
		do send to:player contents:mess;
	}
	
	action send_your_turn(unknown player){
		loop _p over:players{
			if _p != nil {
				write _p;
				if _p = player {
					do send to:_p contents:kw_your_turn;				
				}
				else {
					do send to:_p contents:kw_not_your_turn;
				}				
			}
		}
	}
	
	action add_player_action(unknown player, string action_list_message) {
		let action_list <- (action_list_message split_with(kw_player_actions + ":", true))[1];
		
		write "player " + player_names[players index_of player] + " plays: " + action_list;
		players_actions[player] <- (action_list replace("[", "") replace("]","")) split_with(", ", true);
	}
	
	
	action init_game(int _port, list<string> _player_names, list<map<string,unknown>> actions){
		port				<- _port;
		player_names 		<- _player_names;
		available_actions 	<- actions;
		loop times:length(_player_names){
			players <+ nil;
		}
	}
	

	action send_data(unknown player,string flag, list<float> data) {
		do send to:player contents:flag + ":" + data;
	}
	

	action set_player(unknown sender, int player_number, int budget, int turn) {
		write "set player " + (player_number+1) + " as " + sender + " with " + budget;
		do send to:sender contents:kw_initial_data + ":{"  
				+ '"' + kw_player_name 	+ '":"' + player_names[player_number] 	+ '",' 
				+ '"' + kw_budget 		+ '":' 	+ budget 	+ ","
				+ '"' + kw_actions		+ '":' 	+ list_of_map_to_json(available_actions) 
				+ '}';
				
		// We remove the traces of the old connection
		if (players[player_number] != nil){
			write "removing old player";
			write players_actions;
			unknown old_player <- players[player_number];
			players_actions <- players_actions - [old_player::players_actions[old_player]];
			write players_actions;
			
		}
		players[player_number] <- sender;
		
		
		do send_data_before_turn(sender, budget, turn);
	}	
	
	
	action kick_player_out(unknown player) {
		players <- players - player;
		//TODO: check ?
	}




	//Tools
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
	
	
}


