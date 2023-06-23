#define MED 1
#define ENG 2
#define SEC 3
// #define SERV 4 // Maybe someday chefs will be able to order a ship full of people to feed. /s

#define TUTORIAL 0
#define EASY 1
#define MEDIUM 2
#define HARD 3
#define VETERAN 4

// This causes PoI maps to get 'checked' and compiled, when undergoing a unit test.
// This is so CI can validate PoIs, and ensure future changes don't break PoIs, as PoIs are loaded at runtime and the compiler can't catch errors.
// When adding a new PoI, please add it to this list.
#if MAP_TEST
#endif

/datum/map_template/ship_poi
	name = "Ship POIs for Job Ships"
	desc = "Define your ship here."
	// fixed_orientation = TRUE 					// uncomment this if you want your ships to not be rotated when they're spawned on their own Z's.
	var/scanner_desc = "Unable to resolve bluespace fluctuations."
	var/poi_icon = "distress"
	var/active_icon = "distress" 					// Icon to use when the POI is loaded. Set to null to disable behavior.
	var/poi_color = null
	var/block_size = 60 							// The size of the map's largest dimension. If the map is 66x49, this var should be 66. Essential for laoding/unloading system.
	var/department = MED
	var/difficulty = TUTORIAL						// How hard your ship's template is.
	var/expected_completion_time = 10 MINUTES 		// How long it should take for a skilled team to complete the ship.

// Stolen from map_template/shelter
/datum/map_template/ship_poi/proc/update_lighting(turf/deploy_location)
	var/affected = get_affected_turfs(deploy_location, centered=TRUE)
	for(var/turf/T in affected)
		T.lighting_build_overlay()
// END DO NOT TOUCH

// ==== MAPPERS DO NOT TOUCH ABOVE ====
/*
MAPPER QUICK GUDE
Looking to add new job ship POI's with as little code knowledge as possible? Here's the vital stuff:
-Maps are stored in /datum/map_template/ship_poi templates, you will need to make one template per POI (ship). Code automagically handles adding templates to the overmap + consoles.
-The "name" variable must be unique.
-The "mappath" variable must be the file path of your map file. Store maps in "modular_chomp/maps/jobship_templates" and then the subfolder that closest matches the department (or mix. For example, MEDENGSEC is MED + ENG + SEC. MEDSEC is just Medical + Security).
-The "block_size" variable is the tile size of your map's LARGEST dimension. Code may break horribly if you do not set this correctly.
	-If your map is 60 tiles by 45 tiles, the block_size should be 60.
- The "department" variable indicates which department is supposed to handle the ship.
- The "difficulty" variable indicates how hard your ship is for a department to do.
- The "expected completion time" variable is how fast a skilled team should complete the ship. This should directly feed into difficulty, along with # of mobs, so on.
-ADD YOUR MAP(s) TO THE #include LIST BELOW. This lets github catch POI's breaking in the future.
-Keep templates alphebetical.
-Include the map dimensions in the map file name.

Less important
-"scanner_desc" is the information presented to players upon scanning the POI. You should probably fill this out but it's not necessary for POI spawning.
-"poi_icon" is the icon_state used when the POI is first scanned.
-"active_icon" is the icon_state used when the POI is loaded into the game.
-POI icons use "icons/obj/overmap.dmi" by default. Using other .dmi files is not currently supported but would be easy to code if desired.
-"poi_color" colors the overmap object when set, does nothing when null. Uses hexadecimal color codes.
-Most POI spawning code is in ship_spawning.dm, if you're looking for it.
*/

/*
 * List of ship templates available for use by random events/spawners/etc
 * Define new ships here, and make sure they're valid, or it'll runtime!
 * Every template MUST have a unique name both because of the mapping subsystem and the overmap system.
 * Code credit for a good chunk of this goes to Nadyr/Darlantanis for making me not have to reinvent the wheel.
*/
// Place your templates inside here.
/datum/map_template/ship_poi/meridian_dawn/class_a
	name = "Meridian Dawn Class A Light Medical Transport"
	desc = "A long-hulled Medical Transport used for shuttling injured patients from a backwater station to a better-equipped medical facility."
	block_size = 136 // Longest size is 136.
	fixed_orientation = TRUE
	department = MED
	difficulty = TUTORIAL
	expected_completion_time = 15 MINUTES // 15 minutes is "par" time.


// End templates.
// DO NOT TOUCH.
#undef MED
#undef ENG
#undef SEC
#undef TUTORIAL
#undef EASY
#undef MEDIUM
#undef HARD
#undef VETERAN
// #undef SERV
// End of file.
