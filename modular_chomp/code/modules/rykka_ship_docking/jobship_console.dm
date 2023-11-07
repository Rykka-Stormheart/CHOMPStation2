/*
 * This file hosts the code for the console that can access + request/dismiss ships, as well as display player stats.
*/

#define MED 1
#define ENG 2
#define SEC 3
// #define SERVICE 4 // Maybe someday chefs will be able to order a ship full of people to feed. /s

#define TUTORIAL 0
#define BEGINNER 1
#define STANDARD 2
#define DIFFICULT 3
#define VETERAN 4

/*
 * Console ideally will hold all the code to run the entire 'event' inside itself.
 * Event will be: 1: ID Swipe. 2: Start countdown for ship once minimum # of IDs for size swiped (option to disable this). 3: Send signal to spawn ship. 4: Once ship signals its been despawned successfully and event succeeds, track stat info. 5: Reset console.
 * Console should allow for early termination/ending the event early if players need the docking space.
 * Ship department/difficulty/announcement for spawn will be handled by the console.
 * distress_beacon_spawning.dm will handle spawning. distress_beacon_tracking.dm will handle tracking the mob tracking. distress_beacon_stats.dm will handle the stat tracking system.
 *
 *
*/

/*
 * Distress Beacon/Request Console Code
*/
/obj/machinery/computer/jobship_console
	name = "ship request console"
	// icon = '' // TBD
	// icon_state = "srconsole_off"
	anchored = TRUE
	density = TRUE

	// Internal Working Vars - do not modify these.
	// var/swipes = 0 				// Number of swipes we've currently registered. Reset to 0 at the end of the event.
	var/list/tracked_ids = list()	// Who's swiped on us?
	var/threshold = 3				// How many valid IDs do we need swiped in order to start the event?
	var/linked_ship = null			// What ship do we have spawned currently? This is linked to us by create_child in ship_spawning.
	var/difficulty = STANDARD		// Our difficulty. This is updated dynamically by register_swipe and can be overriden in TGUI to force a harder event, but will require a Command ID swipe.


	// Customization Vars - change as needed to customize to fit.
	var/department = MED // Set this to either MED/ENG/SEC. If it's set outside this, it will runtime.

/obj/machinery/computer/jobship_console/Initialize()
	. = ..()

	if(!(department == (MED || ENG || SEC)))
		log_runtime(EXCEPTION("Department variable set to [department], outside of the expected range!"))

/obj/machinery/computer/jobship_console/attackby(obj/item/weapon/W as obj, mob/user as mob)
	. = ..()
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(istype(W, /obj/item/weapon/card/id/))
		if(allowed(user))
			register_swipe(W) // Do this separately in case it needs overriding, or you want to do fancy stuff later.
		else
			to_chat(user, "<span class='warning'>Access Denied.</span>")

/obj/machinery/computer/jobship_console/attack_hand(mob/user)
	. = ..()

	tgui_interact(user) // Interact with our UI!

/obj/machinery/computer/jobship_console/proc/register_swipe(var/obj/item/weapon/card/id/I)
	for(I in tracked_ids) // Allow our users to remove ourselves via swipe as well as UI
		tracked_ids.Remove(I)
		calculate_difficulty() // Calculate difficulty each time we register a swipe.
		return // Stop here.
		// swipes--
	// swipes++ // Increment our swipes counter by one.
	tracked_ids.Add(I)

	calculate_difficulty() // Calculate difficulty each time we register a swipe.

/* Calculate our difficulty based on;
 * Tracked # of IDs (Who's involved)
 * Rank (IE someone signed on as a full doctor vs nurse vs intern).
 * Total Completions.
 * On-time Completions. (Someone with 100 completions, but only 2 on time will score less 'skilled'.)
 * Completion Percentage. (For Medical, the % of patients returned healthy. For Security, was the ship properly cleared/hostage situation resolved? For Engineering, was the ship repaired properly?)
 * Additional TBD. Work them into the calculation below.
*/
/obj/machinery/computer/jobship_console/proc/calculate_difficulty(var/override = FALSE, var/chosen_difficulty)
	if(override) // Are we manually overriding the difficulty? If yes, set it here.
		difficulty = chosen_difficulty
	// We're doing nothing else for now
	/*
	else // Difficulty is on a scale of 1 -> 100, rounded.
		var/dynamic_difficulty = difficulty
		if(!dynamic_difficulty) // Safety
			dynamic_difficulty = 50

		for(var/obj/item/weapon/card/id/I in tracked_ids) // Grab each one and the rank from it each time we calculate difficulty.
			if(department == MED) // Medical ID rankings




		// Final calculation after everything is said and done.
		switch(dynamic_difficulty)
			if(-INFINITY to 20)
				difficulty = TUTORIAL
			if(21 to 40)
				difficulty = BEGINNER
			if(41 to 60)
				difficulty = STANDARD
			if(61 to 80)
				difficulty = DIFFICULT
			if(81 to INFINITY)
				difficulty = VETERAN
	*/


/obj/machinery/computer/jobship_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "JobShipConsole", "Available Ship Requests") // 800, 380
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/computer/jobship_console/tgui_data(mob/user)
	. = ..()

	var/list/data = list()
	data["tracked_ids"] = tracked_ids
	data["threshold"] = threshold
	data["department"] = department
	data["difficulty"] = difficulty
	data["linked_ship"] = linked_ship

	return data

/obj/machinery/computer/jobship_console/tgui_act(action, params)
	. = ..()

	var/obj/effect/overmap/visitable/dynamic_ship/ship_controller = ship_z_controller
	if(.)
		return
	if(action == "spawn_ship")
		if(tracked_ids.len >= threshold) // Check if we're over threshold.
			ship_controller.create_child(department, difficulty, TRUE, src)


#undef MED
#undef ENG
#undef SEC
// #undef SERV
#undef TUTORIAL
#undef BEGINNER
#undef STANDARD
#undef DIFFICULT
#undef VETERAN
// End of file.
