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

/area/submap/jobship/medsci/meridian_dawn/class_b/bridge
	name = "Bridge"

/area/submap/jobship/medsci/meridian_dawn/class_b/engineering
	name = "Engineering"

/area/submap/jobship/medsci/meridian_dawn/class_b/engineering/reactor_core
	name = "Reactor Core"

/area/submap/jobship/medsci/meridian_dawn/class_b/medical
	name = "Medical"

/area/submap/jobship/medsci/meridian_dawn/class_b/medical/main
	name = "Shipmed Main Scanner Room"

/area/submap/jobship/medsci/meridian_dawn/class_b/medical/surgery_one
	name = "Shipmed Surgery Room One"

/area/submap/jobship/medsci/meridian_dawn/class_b/medical/surgery_two
	name = "Shipmed Surgery Room Two"

/area/submap/jobship/medsci/meridian_dawn/class_b/medical/surgery_three
	name = "Shipmed Surgery Room Three"

/area/submap/jobship/medsci/meridian_dawn/class_b/medical/surgery_four
	name = "Shipmed Surgery Room Four"

/area/submap/jobship/medsci/meridian_dawn/class_b/medical/coldstorage
	name = "Shipmed Cold Storage"

/area/submap/jobship/medsci/meridian_dawn/class_b/medical/recovery_wing
	name = "Shipmed Recovery Wing"

/area/submap/jobship/medsci/meridian_dawn/class_b/medical/masscasualtyone
	name = "Mass Casualty Wing 1"

/area/submap/jobship/medsci/meridian_dawn/class_b/medical/masscasualtytwo
	name = "Mass Casualty Wing 2"

/area/submap/jobship/medsci/meridian_dawn/class_b/civ
	name = "Civilian Bar/Rec Area"

/area/submap/jobship/medsci/meridian_dawn/class_b/civ/crew_quarters_one
	name = "Crew Quarters 1"

/area/submap/jobship/medsci/meridian_dawn/class_b/civ/crew_quarters_two
	name = "Crew Quarters 2"

/area/submap/jobship/medsci/meridian_dawn/class_c
	name = "Meridian Dawn Class C Heavy Convoy Medical Flagcruiser"

/area/submap/jobship/medsci/meridian_dawn/class_d
	name = "Meridian Dawn Class D Superheavy Fleet Medical Carrier"
