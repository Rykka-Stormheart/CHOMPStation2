/*
 * Code for ship areas goes here.
 * ONLY put the areas here.
 * Special code for ambience also lives here.
*/

#define AMBIENCE_MEDSCISHIP list(\
	'modular_chomp/sound/ambience/ships/medsci/medsci_amb01.ogg',\
	'modular_chomp/sound/ambience/ships/medsci/medsci_amb02.ogg',\
	'modular_chomp/sound/ambience/ships/medsci/medsci_amb03.ogg',\
	'modular_chomp/sound/ambience/ships/medsci/medsci_amb04.ogg'\
)

#define AMBIENCE_ENGSHIP list(\
	'modular_chomp/sound/ambience/ships/eng/eng_amb01.ogg',\
	'modular_chomp/sound/ambience/ships/eng/eng_amb02.ogg',\
	'modular_chomp/sound/ambience/ships/eng/eng_amb03.ogg',\
	'modular_chomp/sound/ambience/ships/eng/eng_amb04.ogg'\
)

/*
 * Ship areas defined here. Do not add your areas here.
*/

/area/submap/jobship
	name = "Ship Areas"
	icon_state = "submap"
	flags = RAD_SHIELDED
	ambience = AMBIENCE_MEDSCISHIP
	secret_name = TRUE
	forbid_events = TRUE
	flags = AREA_FLAG_IS_NOT_PERSISTENT

/area/submap/jobship/medsci
	name = "MedSci Ship POI"

/area/submap/jobship/eng
	name = "Engineering Ship POI"
	ambience = AMBIENCE_ENGSHIP

/area/submap/jobship/sec
	name = "Security Ship POI"
	ambience = AMBIENCE_HIGHSEC

// Add your ship areas below here.
/area/submap/jobship/medsci/meridian_dawn/class_a
	name = "Meridian Dawn Class A Light Medical Transport"

/area/submap/jobship/medsci/meridian_dawn/class_b
	name = "Meridian Dawn Class B Medium Convoy Medical Transport"

/area/submap/jobship/medsci/meridian_dawn/class_c
	name = "Meridian Dawn Class C Heavy Convoy Medical Flagcruiser"

/area/submap/jobship/medsci/meridian_dawn/class_d
	name = "Meridian Dawn Class D Superheavy Fleet Medical Carrier"
