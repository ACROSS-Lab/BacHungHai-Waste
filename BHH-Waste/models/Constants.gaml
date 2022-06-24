/**
* Name: Constants
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/


model Constants

/********************** CONSTANTS ****************************/
global {
	string VILLAGE <- "village";
	string DISCUSSION_PHASE <- "DISCUSSION PHASE"; // Used in messages
	string PLAYER_TURN <- "PLAYER TURN";
	string INDICATOR_COMPUTATION <- "INDICATOR COMPUTATION";
	string TIME_DISCUSSION_FINISHED <- "Time for discussion finished!";
	string TIME_PLAYER <- "Time for Player";
	string FINISHED <- "finished!";
	string LOST <- "lost";
	string GAINED <- "gained";
	string FARMS <- "farms";
	string URBAN_HOUSEHOLDS<- "urban households";
	string AND <- "and"; 
	string BUDGET_VILLAGE <-"the budget of village";
	string THE_BUDGET <-"the budget";
	string INCREASED_BY <- "increased by";
	string DECREASED_BY <- "decreased by";
	string NOT_EVOLVED <- "has not evolved";
	string TOKENS <- "tokens";
	string AGRICULTURAL_PROD_LOW <- "The agricultural production is too low";
	string POLLUTION_TOO_HIGH <- "The pollution is too high";
	string PLAYER <- "Player";
	string CHOOSE_WASTE_COLLECTION_FREQ <- "Choose a waste collection frenquency";
	string PER_WEEK <- "per week";
	string WISH_PAY_TREATMENT_FACILITY_MAINTENANCE <- "Do you wish to pay for the home treatment facility maintenance?";
	string PAY_TRAETMENT_FACILITY_MAINTENANCE <- "Pay for treatment facility maintenance";
	string TURN<- "turn"; 
	string TURN_OF <- "Turn of";
	string WASTE_MANAGEMENT_POLCITY <- "Waste management policy";
	string END_OF_TURN <- "End of turn";
	string CONFIRM_END_OF_TURN <- "do you confirm that you want to end the turn?";
	string NOT_ENOUGH_BUDGET <- "Not enough budget for";
	
	string SELECT_A_VILLAGE_TO_RECEIVE_COMMUNE_BUDGET <- "Choose a village to receive the remaining budget";
	string PLAYER_SELECTED <- "Village selected";
	string A_END_TURN <- "End of turn";
	
	string A_1 <- "1";
	string A_2a <- "2a";
	string A_2b <- "2b";
	string A_3 <- "3";
	string A_4 <- "4";
	string A_5a <- "5a";
	string A_5b <- "5b";
	string A_6 <- "6";
	string A_7a <- "7a";
	string A_7b <- "7b";
	string A_8a <- "8a";
	string A_8b <- "8b";
	string A_9 <- "9";
	
	list<string> actions_name_without_end<- [A_1, A_2a, A_2b, A_3, A_4, A_5a, 
 		A_5b, A_6, A_7a, A_7b, A_8a, A_8b, A_9];
	
	
	list<string> actions_name_short<- actions_name_without_end + [A_END_TURN];
	
	/*string A_DUMPHOLES <- "Dumpholes";
	string A_PESTICIDES <- "Pesticides";
	string A_SENSIBILIZATION <- "Sensibilization";
	string A_FILTERS <- "Filters for every home";
	string A_COLLECTIVE_LOW <- "Trimestrial collective action low";
	string A_COLLECTIVE_HIGH <- "Trimestrial collective action high";
	string A_DRAIN_DREDGES_HIGH <- "Drain and dredge high";
	string A_DRAIN_DREDGES_LOW <- "Drain and dredge low";
	string A_FALLOW <- "Fallow";
	string A_MATURES_LOW <- "Support manure low";
	string A_MATURES_HIGH <- "Support manure high";
	string A_FILTER_MAINTENANCE <- "Maintenance for filters";
	
	string A_COLLECTION_HIGH <- "Collection teams high";
	*/
	
	
 	/*list<string> actions_name_short<- [A_DUMPHOLES, A_PESTICIDES, A_SENSIBILIZATION, A_FILTERS, A_COLLECTIVE_HIGH, A_COLLECTIVE_LOW, 
 		A_DRAIN_DREDGES_HIGH, A_DRAIN_DREDGES_LOW, A_FALLOW, A_MATURES_HIGH, A_MATURES_LOW, A_FILTER_MAINTENANCE, A_COLLECTION_HIGH, A_END_TURN
 	];*/
 	
 	
 	// ==============	MOBILE 
 	
	string IMAGE_DRAIN_DREDGE 		<- "drain-dredge.png";
	string IMAGE_DUMPHOLES 			<- "build-collection-pits.png";
	string IMAGE_FALLOW				<- "fallow.png";
	string IMAGE_FERTILIZERS		<- "purchase-fertilizers.png";
	string IMAGE_RAISE_AWAReNESS	<- "raise-awareness.png";
	string IMAGE_REDUCE_PESTICIDES	<- "reduce-pesticide-use.png";
	string IMAGE_COLLECTIVE_ACTION	<- "wastewater-treatment.png";
	string IMAGE_WASTE_COLLECTION	<- "trimestriel-waste-collection.png";
	string IMAGE_END_TURN			<- "";
	string IMAGE_COLLECT_WASTE_WEEK	<- "waste-collection.png";
	// missing endturn + Collecte des déchets ou Collecte trimestriel
	
	list<string> players_names <- 
	[
		"Village 1",
		"Village 2",
		"Village 3",
		"Village 4"
	];
	
 	list<map<string,unknown>>	mobile_actions <- 
	[
		
		[	
			'id'::A_1,
			'name'::'Công tác thu gom rác thải',
		   	'cost'::40,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name':: IMAGE_COLLECT_WASTE_WEEK,
			'description'::"↓Chất thải rắn từ khu đô thị"
		],
		[
			'id'::A_3,
			'name'::'Xây dựng các bể thu gom vỏ và bao bì thuốc sâu',
			'cost'::40,
			'once_per_game'::true,
			'mandatory'::false,
			'asset_name'::IMAGE_DUMPHOLES,
			'description'::"↓Chất thải rắn từ ruộng\n"
		],
		[
			'id'::A_4,
			'cost'::40,
			'name'::'Hỗ trợ nông dân để giảm thiểu sự dụng thuốc trừ sâu',
			'once_per_game'::true,
			'mandatory'::false,
			'asset_name':: IMAGE_REDUCE_PESTICIDES,
			'description'::"↓Nước thải từ ruộng\n↓Sản lượng nông nghiệp "
		],
		[
			'id'::A_3,
			'name'::'Tổ chức sự kiện hưởng ứng phân loại rác',
			'cost'::20,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_RAISE_AWAReNESS,
			'description'::"↓Chất thải rắn trên mặt đất\n"
		],
		[
			'id'::A_7a,
			'name'::'Nạo vét',
			'cost'::25,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_DRAIN_DREDGE,
			"description"::"↓Nước thải trong các kênh\n"
		],
		[	
			'id'::A_7b,
			'name'::'Nạo vét',
			'cost'::50,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_DRAIN_DREDGE,
			'description'::"↓Nước thải trong các kênh\n"
		],
		[
			'id'::A_8a,
			'name'::'Hỗ trợ mua phân bón',
			'cost'::20,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_FERTILIZERS,
			'description'::"↑Sản lượng nông nghiệp\n↑Nước thải"
		],
		[
			'id'::A_8b,
			'name'::'Hỗ trợ mua phân bón',
			'cost'::40,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_FERTILIZERS,
			'description'::"↑Sản lượng nông nghiệp\n↑Nước thải"
		],
		[
			'id'::A_9,
			'name'::'Dừng canh tác 1/3 đất nông nghiệp',
			'cost'::40,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_FALLOW,
			'description'::"↓Ô nhiễm dất\n↓Sản lượng nông nghiệp\n↑Trong vòng một năm"
		],
		[
			'id'::A_5a,
			'name'::'Huy động vớt rác ở các kênh theo kỳ',
			'cost'::20,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_WASTE_COLLECTION,
			'description'::"↓Chất thải rắn trong các kênh\n"
		],
		[
			'id'::A_5b,
			'name'::'Huy động vớt rác ở các kênh theo kỳ',
			'cost'::35,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_WASTE_COLLECTION,
			'description'::"↓Chất thải rắn trong các kênh\n"
		],
		[
			'id'::A_2a,
			'name'::'Hệ thống xử lý nước thải cho các hộ',
   			'cost'::0,
			'once_per_game'::true,
			'mandatory'::false,
			'asset_name':: IMAGE_COLLECTIVE_ACTION,
			'description'::"↓Nước thải từ các hộ\n"
		],
		[
			'id'::A_2b,
			'name'::'Bảo trì hệ thống xử lý nước thải',
			'cost'::10,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_COLLECTIVE_ACTION,
			'description'::"↓Nước thải từ các hộ\n"
		]
	];
 	
 		// Old
	
	string ACT_DRAIN_DREDGE <- "Drain and dredge";
	string ACT_FACILITY_TREATMENT <- "Install water treatment facilities for every home";
	string ACT_SENSIBILIZATION <- "Organise sensibilization about waste sorting workshops in schools";
	string ACT_COLLECTIVE_ACTION <- "Trimestrial collective action";
	string ACT_PESTICIDE_REDUCTION <- "Help farmers to reduce pesticides use";
	string ACT_SUPPORT_MANURE <- "Help farmer buy manure";
	string ACT_IMPLEMENT_FALLOW <- "Put part of the fields in fallow ";
	string ACT_INSTALL_DUMPHOLES <- "Making farmers participate in the installation of dumpholes for agricultural products";
	string ACT_END_OF_TURN <- "end of turn";
	string ACT_COLLECT <- "Increase solid waste collect frequency";
	
	
	// 
	
	string CONFIRM_ACTION <- "do you confirm that you want to";
	string COST <- "Cost";
	string CANNOT_BE_DONE_TWICE <- "cannot be done twice";
	string LOW_FOR <- "Low for";
	string HIGH_FOR <- "High for";
	string LEVEL <- "Level";
	string MAX_BUDGET <- "max budget";
	string ACTION <- "Action";
	string NUMBER_TOKENS_PLAYER <- "Number of tokens payed by each player";
	string WASTE_POLLUTION <- "Waste pollution";
	string VILLAGE_NAME <- "Village name";
	string TIME <- "time";
	string ENVIRONMENT <- "ENVIRONMENT";
	string HOUSE <- "house";
	string FIELD <- "field";
	string CANAL <- "canal";
	string PEOPLE <- "PEOPLE";
	string URBAN_CITIZEN <- "Urban citizen";
	string FARMER <- "farmer";
	string LANDFILL <- "LANDFILL";
	string LOCAL_LANDFILL <- "local landfill";
	string COMMUNAL_LANDFILL <- "Communal  landfill";
	string TIMER <- "timer";
	string REMAINING_TIME_PLAYER <- "Remaining time for the Player";
	string REMAINING_TIME_DISCUSSION <- "Remaining time for the discussion";
	string INFO_ECOLABEL <- "Info Ecolabel";
	string INFO_DATE <- "Info date";
	string INFO_PLAYERS <- "Info players";
	string INFO_BUDGET <- "Info budget"; 
	string INFO_ACTION <- "Info actions";
	string ACTIONS <- "Actions";
	string STANDARD_ECOLABEL <- "Meets the standards of the ecolabel";
	string NOT_STANDARD_ECOLABEL <- "Does not meet the standards of the ecolabel!";
	string COMMUNE_STANDARD_ECOLABEL <- "The commune meets the standards of the ecolabel";
	string COMMUNE_NOT_STANDARD_ECOLABEL <- "The commune does not meet the standards of the ecolabel!";
	string NUMBER_DAY_ECOLABEL <- "Total number of days with ecolabel";
	
	string YEAR <- "year";
	string DAY <- "day";
	string TURN_OF_PLAYER <- "Turn of player";
	string DISCUSSION_STAGE <- "Discussion phase"; // In Debug UI
	string SIMULATION_STAGE <- "Simulation phase";
	string NUM_FARMERS <- "Num farmer households";
	string NUM_URBANS <- "Num urban households";
	string SOLID_WASTE_POLLUTION <- "Solid waste pollution";
	string WATER_WASTE_POLLUTION <- "Water waste pollution";
	string TOTAL_POLLUTION <- "Total pollution";
	string ECOLABEL_MAX_POLLUTION <- "Ecol labal max pollution";
	string PRODUCTION <- "production";
	string TOTAL_PRODUCTION <- "Total production";
	string ECOLABEL_MIN_PRODUCTION <- "Ecol labal min production";
	string LEGEND <- "legend";
	string RANKING <- "ranking";
	
	string PLAYER_ACTION_TURN <- "player action turn";
	string PLAYER_DISCUSSION_TURN <- "player discussion turn";
	string COMPUTE_INDICATORS <-  "compute indicators";
	string ACT_FACILITY_TREATMENT_MAINTENANCE <- "Maintenance of water treatment facilities";
		
	string MAP_SOLID_WASTE <- "Map of solid waste";
	string MAP_WATER_WASTE <- "Map of waster waste";
	string MAP_TOTAL_WASTE <- "Map of total pollution";
	string MAP_PRODUCTIVITY <- "Map of agricultural productivity";
}