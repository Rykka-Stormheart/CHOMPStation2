/*
 * This file hosts the code for opt-in job ship docking.
 *	It will be separated into appropriate files once necessary.
 *	For now, it stays here to enable all the code to be in one place and diagnosed easily/allow enable/disable as needed.
*/

#define MED 1
#define ENG 2
#define SEC 3
// #define SERVICE 4 // Maybe someday chefs will be able to order a ship full of people to feed. /s

/*
 * Console ideally will hold all the code to run the entire 'event' inside itself.
 * Event will be: 1: ID Swipe. 2: Start countdown for ship once minimum # of IDs for size swiped (option to disable this). 3: Send signal to spawn ship. 4: Once ship signals its been despawned successfully and event succeeds, track stat info. 5: Reset console.
 * Console should allow for early termination/ending the event early if players need the docking space.
 * Ship size/difficulty/announcement for spawn + stat tracking will be handled by the console.
 * Ship code for spawn/despawn/tracking what was on it and what condition it's in can be inside an invisible shiptracker object placed on the ship templates, maybe?
 * Can also insert the shiptracker when the ship is spawned and take a 'snapshot' of the ship on setup? Saves mappers from having to remember to place the shiptracker.
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
	var/ship_templates = list() 	// Empty list should be fine to start?
	var/swipes = 0 					// Number of swipes we've currently registered. Reset to 0 at the end of the event.
	var/tracked_ids = list()		// Who's swiped on us?
	var/threshold = 3				// How many valid IDs do we need swiped in order to start the event?


	// Customization Vars - change as needed to customize to fit.
	var/department = MED // Set this to either MED/ENG/SEC. If it's set outside this, it will runtime.

/obj/machinery/computer/jobship_console/Initialize()
	. = ..()

	if(!LAZYLEN(ship_templates)) // Runtime for if there's no templates generated
		log_runtime(EXCEPTION("No ship templates were setup for the console at [x], [y], [z], in ([get_area(src)])"))

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

/obj/machinery/computer/jobship_console/register_swipe(var/obj/item/weapon/card/id/I)
	swipes++ // Increment our swipes counter by one.
	tracked_ids += I

/obj/machinery/computer/jobship_console/tgui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "JobshipConsole", "Available Ship Requests") // 800, 380
		ui.open()
		ui.set_autoupdate(FALSE)

#undef MED
#undef ENG
#undef SEC
// #undef SERV
