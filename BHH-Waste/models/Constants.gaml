/**
* Name: Constants
* Based on the internal empty template. 
* Author: Patrick Taillandier
* Tags: 
*/


model Constants

/********************** CONSTANTS ****************************/
global {
	string PLAYER_ACTION_TURN <- "player action turn";
	string PLAYER_DISCUSSION_TURN <- "player discussion turn";
	string COMPUTE_INDICATORS <-  "compute indicators";
	
	string ACT_DRAIN_DREDGE <- "Drain and dredge";
	string ACT_FACILITY_TREATMENT <- "Install water treatment facilities for every home";
	string ACT_SENSIBILIZATION <- "Organise sensibilization about waste sorting workshops in schools";
	string ACTION_COLLECTIVE_ACTION <- "Trimestrial collective action";
	string ACT_PESTICIDE_REDUCTION <- "Help farmers to reduce pesticides use";
	string ACT_SUPPORT_MANURE <- "Help farmer buy manure";
	string ACT_IMPLEMENT_FALLOW <- "Put part of the fields in fallow ";
	string ACT_INSTALL_DUMPHOLES <- "Making farmers participate in the installation of dumpholes for agricultural products";
	string ACT_END_OF_TURN <- "end of turn";
	
	string MAP_SOLID_WASTE <- "Map of solid waste";
	string MAP_WATER_WASTE <- "Map of waster waste";
	string MAP_TOTAL_WASTE <- "Map of total pollution";
	string MAP_PRODUCTIVITY <- "Map of agricultural productivity";
}