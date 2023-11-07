/*
 *
 * ==== TRACKING CODE ====
 *
*/

/*
 * For convenience, all code related to landmarks + spawning exists here.
 * Then, we'll define the code that actually tracks the status of our current event.
 * This allows it to exist independently of the consoles.
*/

// LANDMARKS
/* // We're not using spawn landmarks - it's easier to have the spawner compile a list of mobs inside the /area/ on template spawn, then assign tracking to them from there.
/obj/effect/landmark/distress_npc_spawn_marker
	name = "CHANGEME" 				// Set this name to whichever NPC you intend to spawn, or use the subtype.

/obj/effect/landmark/distress_npc_spawn_marker/New()
	// . = ..() // We won't call parent, as we're overriding everything manually for now.

	invisibility = 101
	tag = text("landmark*[]", name)



	// End of New()
	landmarks_list += src
	return 1
*/
