/**
* Name: NetworkManager
* Based on the internal skeleton template. 
* Author: Baptiste
* Tags: 
*/

model NetworkManager

global {
	init {
	//	create fake_simulation number:1;
	}
}

//species fake_simulation {
//	
//	NetworkManager networkManager;
//	
//	
//	list<string> villages_names <- [
//		"Village 1" 
//		//"Village fictif numéro 2"
//	];
//	
//	list<list<int>>	init_budgets	<- [	
//		[128], 
//		[130],
//		[132],
//		[134],
//		[136] //player 1's budget for the game
//	];
//	
//	list<map<string,unknown>>	init_actions <- [
//		['id'::1,'name'::'Drain and dredge', 'cost'::20,'once_per_game'::false,'mandatory'::false, 'asset_name'::'drain-dredge.png', 'description'::"↓Solid waste\n↓Waste water"],
//		['id'::2,'name'::'Drain and dredge', 'cost'::50,'once_per_game'::false,'mandatory'::false, 'asset_name'::'drain-dredge.png'],
//		['id'::3,'name'::'Sensibilization',  'cost'::25,'once_per_game'::false,'mandatory'::false, 'asset_name'::'nexistepas'],
//		['id'::4,'name'::'Collect waste',    'cost'::25,'once_per_game'::false,'mandatory'::true, 'asset_name'::'drain-dredge.png'],
//		['id'::5,'name'::'Collect waste',    'cost'::50,'once_per_game'::false,'mandatory'::true, 'asset_name'::'drain-dredge.png'],
//		['id'::7,'name'::'Install facility treatments', 'cost'::50,'once_per_game'::true,'mandatory'::false, 'asset_name'::'build-collection-pits.png'],
//		['id'::8,'name'::'a', 'cost'::50,'once_per_game'::true,'mandatory'::false, 'asset_name'::'fallow.png'],
//		['id'::9,'name'::'b', 'cost'::50,'once_per_game'::true,'mandatory'::false, 'asset_name'::'purchase-fertilizers.png', "description"::"↑Waste water\n↑Productivity"],
//		['id'::10,'name'::'c', 'cost'::50,'once_per_game'::true,'mandatory'::false, 'asset_name'::'raise-awareness.png'],
//		['id'::11,'name'::'d', 'cost'::50,'once_per_game'::true,'mandatory'::false, 'asset_name'::'reduce-pesticide-use.png'],
//		['id'::11,'name'::'e', 'cost'::50,'once_per_game'::true,'mandatory'::false, 'asset_name'::'trimestriel-waste-collection.png'],
//		['id'::12,'name'::'f', 'cost'::50,'once_per_game'::true,'mandatory'::false, 'asset_name'::'wastewater-treatment.png'],
//		['id'::13,'name'::'Action collective', 'cost'::0,'once_per_game'::true,'mandatory'::false, 'asset_name'::'collective-action.png']
//];
//	
//	init {
//		
//		
//		create NetworkManager number:1 {
//			myself.networkManager <- self;
//			
//			do init_game(8989,
//						myself.villages_names,
//						myself.init_budgets,
//						myself.init_actions												
//						);
//		}
//		
//		
//		
//	}
//	
//<
//	reflex server_loop {
//		ask networkManager {
//			loop while:has_more_message() {
//				
//				message mess <- fetch_message();
//				write "message received " + mess;
//				string content <- mess.contents;
//				
//				if content contains kw_ask_for_connection and length(players) < length(player_names) {
//					do add_player(mess.sender);
//				}
//				else if content contains kw_player_actions {
//					do add_player_action(mess.sender, content);
//				}
//			}				
//		}
//	}
//	
//	reflex send_players_pollution_levels when:cycle mod 1000 = 0 {
//		ask networkManager {
//			loop player over:players {
//				
//				list<float> water_pollution 	<- [];
//				list<float> solid_pollution 	<- [];
//				list<float> productivity_level 	<- [];
//				
//				loop times:100 {
//					water_pollution 	<- water_pollution 		+ rnd(10000,30000);
//					solid_pollution 	<- solid_pollution 		+ rnd(10000,15000);
//					productivity_level 	<- productivity_level 	+ rnd(80,130);	
//				}
//				
//				do send_data(player, kw_water_pollution, water_pollution);
//				do send_data(player, kw_solid_pollution, solid_pollution);
//				do send_data(player, kw_productivity, productivity_level);	
//			}
//		}
//	}
//	
//	reflex collect_players_actions {
//		ask networkManager {
//			if length(players_actions.keys) = length(player_names) {
//				write "end of the turn " + turn;
//				loop player over:players {
//					write "player " + player + " plays:" + players_actions[player];
//				}
//				do new_turn;
//			}
//		}
//	}
//	
//	
//	
//	
//	
//}


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
	//list<list<int>>				player_budgets;
	map<unknown,list<string>> 	players_actions;
	list<map<string,unknown>>	available_actions;
	
	int turn <- 0;
	
	init {
		players_actions	<- [];
		player_names 	<- [];
		players 		<- [];
		
		do connect protocol:"tcp_server" port:port raw:true size_packet:100000;
		
	}
	
	action send_data_before_turn(unknown player, int turn_budget, int turn_number) {
		let mess <- kw_start_turn +':{"' +kw_budget +'":' + turn_budget + ',"' + kw_turn_number+ '":' + turn_number +"}";
		write "sending: " + mess + " to: " + player;
		do send to:player contents:mess;
	}
	
	action send_your_turn(unknown player){
		write "giving turn to: " + player;
		loop _p over:players{
			if _p = player {
				do send to:_p contents:kw_your_turn;				
			}
			else {
				do send to:_p contents:kw_not_your_turn;
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
			players <- [nil];
		}
		
	}
	

	action send_data(unknown player,string flag, list<float> data) {
		do send to:player contents:flag + ":" + data;
	}
	

	action set_player(unknown sender, int player_number, int budget) {
		write "set player " + player_number + " as " + sender + " with " + budget;
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

//	
//	action add_player(unknown sender, int budget) {
//		
//		write "new player: " + sender;
//		do send to:sender contents:kw_initial_data + ":{"  
//				+ '"' + kw_player_name 	+ '":"' + player_names[length(players)] 	+ '",' 
//				+ '"' + kw_budget 		+ '":' 	+ budget 	+ ","
//				+ '"' + kw_actions		+ '":' 	+ list_of_map_to_json(available_actions) 
//				+ '}';
//				
//		players <- players + sender;
//		
//		if  length(players) = length(player_names) {
//			write "all players joined";
//		}
//		
//	}
//	
//	action reset_player(unknown player, string player_name){
//		let idx <- player_names index_of player_name;
//		players[idx] <- player;
//		do send to:player contents:kw_initial_data + ":{"  
//		+ '"' + kw_player_name 	+ '":"' + player_name 	+ '",' 
//	//	+ '"' + kw_budget 		+ '":' 	+ budgets[idx] 	+ "," //TODO
//		+ '"' + kw_actions		+ '":' 	+ list_of_map_to_json(available_actions) 
//		+ '}';
//	}
	
	
	action new_turn(list<int> budgets)  {
		turn <- turn + 1;
		players_actions <- [];
		int i <- 0;
		loop player over:players {
			do send_data_before_turn(player, budgets[i], turn + 1);
			i <- i + 1;
		}
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


