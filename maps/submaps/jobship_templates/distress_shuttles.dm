/*
 * This file exists to host the shuttle code, and any specific items needed for each template.
 * Keep your additions/changes separated by code comments at the start/end of each section.
 * Each ship (shuttle) datum must be a subtype of "jobship" for ease of identification if there's issues.
*/
// == Do not touch starts here. ==
/datum/shuttle/autodock/ferry/jobship
	defer_initialisation = TRUE // We do not want to automatically build these at start, because they're not loaded in until the dynamic spawner loads us in.

/obj/effect/shuttle_landmark/jobship
	landmark_tag = "shipspawn_ident" // Change _ident to _yourshipname

/*
 * Distress Shuttle Automation Code Lives Here
 * Do NOT touch this automated code. Only define a new console SUBTYPE specifically for your ship.
 * See the example or ask if you need help.
*/

/obj/machinery/computer/shuttle_control/jobship
	name = "shuttle control console"
	req_access = list(access_cent_general)
	shuttle_tag = "Arrivals"

// Unlike most shuttles, our jobship shuttle is completely automated (or driven by NPCs that cannot issue commands themselves, at least currently), so we need to put some additional code here.
// Process the shuttle even when idle.
/obj/machinery/computer/shuttle_control/jobship/process()
	var/datum/shuttle/autodock/ferry/jobship/shuttle = SSshuttles.shuttles[shuttle_tag]
	if(shuttle && shuttle.process_state == IDLE_STATE)
		shuttle.process()
	..()

// This proc checks if anyone is on the shuttle.
/datum/shuttle/autodock/ferry/jobship/proc/check_for_passengers()
	for(var/area/A in shuttle_area)
		for(var/mob/living/carbon/L in A) // We don't care about ghosts, or simplemobs. If you're a mouse, oops.
			if(L.client) // Do they have a client? If yes, true.
				return TRUE
	return FALSE

// This is to stop the shuttle if someone tries to stow away when its leaving.
/datum/shuttle/autodock/ferry/jobship/post_warmup_checks()
	if(!location) // If we're at station.
		if(check_for_passengers())
			return FALSE
	return TRUE

/*
// Yes, this is commented out because this is purely an example of how to build your shuttle properly to work with the auto-dock system.
/datum/shuttle/autodock/ferry/jobship/example
	name = "Damaged Transport"
	warmup_time = 14 // This is in seconds, because the timer multiplies it by 10. So 14 becomes 1400 deciseconds (14 seconds).
	location = FERRY_LOCATION_OFFSITE 			// Do not change this - your ships spawn offstation.
	shuttle_area = /area/submap/jobship/depthere/yourareahere // Your ships "master" area. The one that covers the entire thing.
	landmark_offsite = "example_spawn" 			// Place a landmark on your ship, defined with a landmark_tag. That landmark_tag is what you put here.
	// Do not use landmark_transition. The ships should never jump with clients onboard, and we don't care about being "pretty" for ghosts.
	landmark_station = "wheredowewanttodock" 	// This is our docking berth on station. Pick ONE berth. You cannot have multiple with an autodock, without some fiddling when the datum is created.
												// IE, choose one for new, choose to pick from a list if you're experienced and know where you can fit.
	docking_controller_tag = "our_controller"	// Set this tag to the docking controller ID_TAG **ON** your airlock.
*/

/*
// Additionally, you will need a shuttle control computer with a specific shuttle_tag for your ship. Define that here, reload SDMM (or DreamMaker), and then place the console in place of a standard console.
/obj/machinery/computer/shuttle_control/jobship/example
	// Do not change the name of it without good reason.
	// Likewise, do not change the access, as it is intended for only admins to be able to touch it.
	shuttle_tag = "yourtaghere" // Change this tag to match your ship name. For example, Meridian Dawn Class B would be "Meridian Dawn Class B Medium Medical Transport"
*/

// ==== Do not touch ends. ====
// ==== You may touch below. ====
//
/datum/shuttle/autodock/ferry/jobship/meridian_dawn/class_b
	name = "Meridian Dawn Class B Transport"
	docking_controller_tag = "merid_b"
	landmark_offsite = "shipspawn_meridian_b"
	landmark_station = "d1_aux_b" // Deck 1, left-bottom airlock facing south.
	shuttle_area = /area/submap/jobship/medsci/meridian_dawn/class_b


/obj/effect/shuttle_landmark/jobship/meridian_dawn/class_b
	name = "Meridian Dawn Class B Deepspace"
	landmark_tag = "shipspawn_meridian_b"

/obj/machinery/computer/shuttle_control/jobship/meridian_dawn/class_b
	name = "flight control computer"
	shuttle_tag = "Meridian Dawn Class B Medium Medical Transport"
