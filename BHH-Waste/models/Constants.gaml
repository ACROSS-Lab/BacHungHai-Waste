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
	
	
	string A_DUMPHOLES <- "Dumpholes";
	string A_PESTICIDES <- "Pesticides";
	string A_END_TURN <- "End of turn";
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
	
	string A_COLLECTION_LOW <- "Collection teams low";
	string A_COLLECTION_HIGH <- "Collection teams high";
	
	
	
 	list<string> actions_name_short <- [A_DUMPHOLES, A_PESTICIDES, A_SENSIBILIZATION, A_FILTERS, A_COLLECTIVE_HIGH, A_COLLECTIVE_LOW, 
 		A_DRAIN_DREDGES_HIGH, A_DRAIN_DREDGES_LOW, A_FALLOW, A_MATURES_HIGH, A_MATURES_LOW, A_FILTER_MAINTENANCE, A_COLLECTION_LOW, A_COLLECTION_HIGH, A_END_TURN
 	];
 	
 	
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
	string IMAGE_COLLECT_WASTE_WEEK	<- "";
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
			'id'::A_COLLECTION_LOW,
			'name'::'Collecte trimestriel de déchets dans les canaux',
			'cost'::18,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_WASTE_COLLECTION,
			'description'::"↓Déchets solides dans les canaux\n"
		],
		[
			'id'::A_COLLECTION_HIGH,
			'name'::'Collecte trimestriel de déchets dans les canaux',
			'cost'::35,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_WASTE_COLLECTION,
			'description'::"↓Déchets solides dans les canaux\n"
		],
		[
			'id'::A_FILTERS,
			'name'::'Système de traitement de eaux usées',
   			'cost'::0,
			'once_per_game'::true,
			'mandatory'::false,
			'asset_name':: IMAGE_COLLECTIVE_ACTION,
			'description'::"↓Eaux usées des habitants\n"
		],
		[
			'id'::A_DUMPHOLES,
			'name'::'Construction de puits de collecte',
			'cost'::40,
			'once_per_game'::true,
			'mandatory'::false,
			'asset_name'::IMAGE_DUMPHOLES,
			'description'::"↓Déchets solides dans les champs\n"
		],
		[
			'id'::A_PESTICIDES,
			'name'::'Réduire le recours aux pesticides',
			'cost'::40,
			'once_per_game'::true,
			'mandatory'::false,
			'asset_name':: IMAGE_REDUCE_PESTICIDES,
			'description'::"↓Déchets solides dans les champs\n↓Productivité"
		],
		[	
			'id'::A_COLLECTIVE_HIGH,
			'name'::'Collecte de déchets',
		   	'cost'::50,
			'once_per_game'::false,
			'mandatory'::true,
			'asset_name':: IMAGE_COLLECT_WASTE_WEEK,
			'description'::"↓Déchets solides dans les zones urbaines\n"
		],
		[	
			'id'::A_COLLECTIVE_LOW,
			'name'::'Collecte de déchets',
			'cost'::30,
			'once_per_game'::false,
			'mandatory'::true,
			'asset_name'::IMAGE_COLLECT_WASTE_WEEK,
			'description'::"↓Déchets solides dans les zones urbaines\n"
		],
		[
			'id'::A_SENSIBILIZATION,
			'name'::'Sensibilisation au tri des déchets',
			'cost'::20,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_RAISE_AWAReNESS,
			'description'::"↓Déchets solides dans le village\n"
		],
		[	
			'id'::A_DRAIN_DREDGES_HIGH,
			'name'::'Drainer et draguer',
			'cost'::50,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_DRAIN_DREDGE,
			'description'::"↓Eaux usées dans les canaux\n"
		],
		[
			'id'::A_DRAIN_DREDGES_LOW,
			'name'::'Drainer et draguer',
			'cost'::25,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_DRAIN_DREDGE,
			"description"::"↓Eaux usées dans les canaux\n"
		],
		[
			'id'::A_MATURES_HIGH,
			'name'::'Aides pour l\'achat des engrais',
			'cost'::40,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_FERTILIZERS,
			'description'::"↑Productivité\n ↑Eaux usées"
		],
		[
			'id'::A_MATURES_LOW,
			'name'::'Aides pour l\'achat des engrais',
			'cost'::20,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_FERTILIZERS,
			'description'::"↑Productivité\n ↑Eaux usées"
		],
		[
			'id'::A_FILTER_MAINTENANCE,
			'name'::'Entretien du système de traitement',
			'cost'::10,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_COLLECTIVE_ACTION,
			'description'::"↓Eaux usées des habitants\n"
			],
			[
			'id'::A_FALLOW,
			'name'::'Jachère',
			'cost'::40,
			'once_per_game'::false,
			'mandatory'::false,
			'asset_name'::IMAGE_FALLOW,
			'description'::"↓Pollutions des terres\n ↓Productivité ce tour-ci\n ↑Production le prochain tour"
			]
		];
 	
 	
	// Old
	
	string ACT_DRAIN_DREDGE <- "Drain and dredge";
	string ACT_FACILITY_TREATMENT <- "Install water treatment facilities for every home";
	string ACT_SENSIBILIZATION <- "Organise sensibilization about waste sorting workshops in schools";
	string ACTION_COLLECTIVE_ACTION <- "Trimestrial collective action";
	string ACT_PESTICIDE_REDUCTION <- "Help farmers to reduce pesticides use";
	string ACT_SUPPORT_MANURE <- "Help farmer buy manure";
	string ACT_IMPLEMENT_FALLOW <- "Put part of the fields in fallow ";
	string ACT_INSTALL_DUMPHOLES <- "Making farmers participate in the installation of dumpholes for agricultural products";
	string ACT_END_OF_TURN <- "end of turn";
	
	
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
	string ACT_COLLECT <- "Collect frequency";
		
	string MAP_SOLID_WASTE <- "Map of solid waste";
	string MAP_WATER_WASTE <- "Map of waster waste";
	string MAP_TOTAL_WASTE <- "Map of total pollution";
	string MAP_PRODUCTIVITY <- "Map of agricultural productivity";
	
	
	
}