/*
 * The below code is intended to allow players to have a simplemob "true self" that they will change to upon unequip of the item.
 * The process is simple;
 * On unequip: 1: Check if assigned. 2: Swap player into mob 3: qualize health + location. 4: Transfer all items in bellies. 5: Strip all gear onto the floor. 6: Start cooldown.
 * On equip: 1: Ask if they are sure they wish to do this, and that they WILL appear devoid of gear. 2: Repeat the above.
*/
/datum/component/form_stabilizer
	// var/mob/living/carbon/human/M

	var/assigned = FALSE // Is a player registered to this item? Starts FALSE, becomes TRUE when interacted with or spawned + equipped.
	var/owner_ckey = null // Who owns us?
	var/true_form = null // Linked simple/feral mob
	var/shapeshift_form = null // Linked carbon mob
	var/last_activated = null // When were we last used?
	var/cooldown_time = 60 SECONDS // By default, the ring can only change forms once every minute. Done this way bc swapping forms is server-intensive, I think?
	var/emp_disrupted = FALSE // If set to anything above 0, then the item cannot be used until repaired (bonked with wires and a multitool, for funsies. Give more reasons to oops into foxform /s)
	var/burnt_out = FALSE // If TRUE, then we need to replace the wires.
	// For the forms, we'll just use the vore replicator list to start. Admin list will have fullsize drgn and other dangerous mobs. :eyes:
	var/usable_forms = list(
		/mob/living/simple_mob/animal/passive/fox,
		/mob/living/simple_mob/animal/passive/cow,
		/mob/living/simple_mob/animal/passive/chicken,
		/mob/living/simple_mob/animal/passive/opossum,
		/mob/living/simple_mob/animal/passive/mouse,
		/mob/living/simple_mob/vore/rabbit,
		/mob/living/simple_mob/animal/goat,
		/mob/living/simple_mob/animal/sif/tymisian,
		/mob/living/simple_mob/vore/wolf/direwolf,
		/mob/living/simple_mob/vore/otie/friendly,
		/mob/living/simple_mob/vore/alienanimals/catslug,
		/mob/living/simple_mob/vore/alienanimals/teppi,
		/mob/living/simple_mob/vore/fennec,
		/mob/living/simple_mob/vore/xeno_defanged,
		/mob/living/simple_mob/vore/redpanda/fae,
		/mob/living/simple_mob/vore/aggressive/rat,
		/mob/living/simple_mob/vore/aggressive/panther,
		/mob/living/simple_mob/vore/aggressive/frog
	)

// Initialize. Here, we'll register our incoming signal (basically, when it's equipped), setup the item's selected form.
// Then flag our original mob, and spawn our mob, then leave it in nullspace until we're ready to swap forms.
/datum/component/form_stabilizer/Initialize()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped)) // Go through equipped first, which then calls swap form
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(swap_form))
	RegisterSignal(parent, COMSIG_MOB_ITEM_ATTACK, PROC_REF(attackby)) // Mobs can't put this item on themselves, by design. Plus it's cute to need help.
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(binding_check)) // Choose our form.
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(emp_act)) // EMP!
	RegisterSignal(parent, COMSIG_MOB_EXAMINATE, PROC_REF(examine)) // Examine!

/datum/component/form_stabilizer/proc/form_spawn(user, var/mob/living/M, var/mob/form_to_spawn, var/carbon = FALSE) // This should be called either by loadout on equip or on first use if we're not being spawned via loadout equip.
	// Define our new mob here, create it at nullspace.
	if(carbon) // Are we spawning a carbon?
		var/mob/living/carbon/human/new_human = new /mob/living/carbon/human()
		M.client.prefs.copy_to(new_human) // This should work, I think?
		shapeshift_form = new_human // Link our carbon to this ring
		if(emp_disrupted || burnt_out) // Don't do anything else if we're still disrupted.
			to_chat(M, "<span class='danger'>The circuits require repair! Examine for more details!</span>")
			return
		swap_form(M) // Immediately put us into the carbon form.
	else // Else, we're spawning simplemob
		var/mob/living/simple_mob/new_mob = new form_to_spawn()
		new_mob = true_form // Link our simplemob to the ring
		to_world("Form-to-spawn is [form_to_spawn], new_mob is [new_mob], and M is [M]!")

		// New mob info checks
		//Start of mob code shamelessly ripped from mouseray (and now replicator :3)
		new_mob.faction = M.faction // We're going to inherit our faction to prevent issues like station turrets shooting us.

		if(new_mob && isliving(new_mob)) // Sanity check in case the new mob suddenly dies for w/e reason
			// Gonna break this up into blocks for readability.
			// Starting with vorgans here. We cut out the defaults from the simplemob and copy over our intended ones.
			for(var/obj/belly/B as anything in new_mob.vore_organs)
				new_mob.vore_organs -= B
				qdel(B)
			new_mob.vore_organs = list() // Empty!
			M.copy_vore_prefs_to_mob(new_mob) // Now copy over from our loaded saveslot's bellies.
			new_mob.vore_selected = M.vore_selected // Select our default vorgan based on what was already chosen.

			// Now we copy over our name + languages
			new_mob.name = M.name
			new_mob.real_name = M.real_name
			new_mob.languages = M.languages.Copy()

			// Now we handle gender + pronouns
			if(. && ishuman(M)) // If we're in our carbonmob form
				var/mob/living/carbon/human/H = M
				if(ishuman(new_mob)) // Safety, even though we know it's not likely human
					var/mob/living/carbon/human/N = new_mob
					N.gender = H.gender
					N.identifying_gender = H.identifying_gender
				else
					new_mob.gender = H.identifying_gender
			else // Otherwise, set our gender, we're just assuming pronouns match because code sucks
				new_mob.gender = M.gender
				if(ishuman(new_mob))
					var/mob/living/carbon/human/N = new_mob
					N.identifying_gender = M.gender


/datum/component/form_stabilizer/proc/swap_form(user, var/mob/living/M)
	// First things first: Sanity check.
	if(owner_ckey != M.ckey || M.ckey == null || !M)
		log_runtime(EXCEPTION("Our ckey doesn't match or is null! This shouldn't happen!"))
		return

	if(!true_form || !shapeshift_form)
		log_runtime(EXCEPTION("Swap form was called without proper forms! True form is [true_form] and carbon form is [shapeshift_form]."))
		return

	if(emp_disrupted || burnt_out) // Don't do anything if we're still disrupted.
		to_chat(M, "<span class='danger'>The circuits require repair! Examine for more details!</span>")
		return

	// TODO: Select form based on what our current form is.
	var/mob/living/swap_form = null
	if(ishuman(M)) // This should handle it. Are we currently carbon?
		swap_form = true_form
	else // Else, we're not carbon, but someone bonked us with the collar, so we want to become carbon.
		swap_form = shapeshift_form

	// Grab our loc, health, and current time for further use.
	//var/orig_health = M.health
	var/moveloc = get_turf(M)

	// Health calculations. Technically this means that the simplemob could get an inflated amount of health and vice versa.
	// Realistically, it means that both will share whichever is higher. If carbon has 200, and simple has 300, then at some point the actual will become 300 max.
	if(swap_form == true_form) // Are we changing to our true form? (We need to get our health from carbon, so our simple is updated, then)
		swap_form.maxHealth = M.getMaxHealth()*2 //HUMANS, and their 'double health', bleh.
	else
		swap_form.maxHealth = M.getMaxHealth()
	swap_form.health = swap_form.maxHealth - M.getOxyLoss() - M.getToxLoss() - M.getCloneLoss() - M.getBruteLoss() - M.getFireLoss() // We're going to use the current damage our originating form has.

	//Alive, becoming dead
	if((M.stat < DEAD) && (M.health <= 0))
		swap_form.death()

	swap_form.nutrition = M.nutrition // Equalize the two.

	//Overhealth
	if(swap_form.health > swap_form.getMaxHealth())
		swap_form.health = swap_form.getMaxHealth()
	// Time to drop stuff! (Stolen from prommies)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M // Temporary

		var/list/things_to_drop = H.contents.Copy()
		var/list/things_to_not_drop = list(H.w_uniform,H.nif,H.l_store,H.r_store,H.wear_id,H.l_ear,H.r_ear) //And whatever else we decide for balancing.
		things_to_drop -= things_to_not_drop //Crunch the lists
		things_to_drop -= H.organs //Mah armbs
		things_to_drop -= H.internal_organs //Mah sqeedily spooch

		for(var/obj/item/I in things_to_drop) // hehehe items go clonk
			H.drop_from_inventory(I)

		if(H.w_uniform && istype(H.w_uniform,/obj/item/clothing)) //No webbings tho. We do this after in case a suit was in the way
			var/obj/item/clothing/uniform = H.w_uniform
			if(LAZYLEN(uniform.accessories))
				for(var/obj/item/clothing/accessory/A in uniform.accessories)
					if(is_type_in_list(A, list(
						/obj/item/clothing/accessory/holster,
						/obj/item/clothing/accessory/storage,
						/obj/item/clothing/accessory/armor
						)))
						uniform.remove_accessory(null,A) //First param is user, but adds fingerprints and messages

		if(H.l_hand) H.drop_from_inventory(H.l_hand)
		if(H.r_hand) H.drop_from_inventory(H.r_hand)

	// Time to swap into new mob. Code stolen from replicator.
	/*
	for(var/obj/belly/B as anything in M.vore_organs) // Anything in our bellies is now forcemoved into the new mob.
		B.loc = swap_form // Belly is now told it is in swap form.
		B.forceMove(swap_form) // Forcibly move it.
		B.owner = swap_form // Register the new owner.
		M.vore_organs -= B // Remove vorgan from old mob list to prevent recursive loop.
		swap_form.vore_organs += B // Transferring vorgans over to new list.
	*/
	// Testing variation on code, does basically the same as above but simpler.
	//Transfer vore organs
	swap_form.vore_organs = M.vore_organs.Copy()
	swap_form.vore_selected = M.vore_selected
	for(var/obj/belly/B as anything in M.vore_organs)
		B.forceMove(swap_form)
		B.owner = swap_form
	M.vore_organs.Cut()

	M.mind.transfer_to(swap_form) // Finally, transfer our mind over
	if(M.ai_holder && swap_form.ai_holder) // Not sure if we need this, but leaving it in.
		var/datum/ai_holder/old_AI = M.ai_holder
		old_AI.set_stance(STANCE_SLEEP)
		var/datum/ai_holder/new_AI = swap_form.ai_holder
		new_AI.hostile = old_AI.hostile
		new_AI.retaliate = old_AI.retaliate
	M.moveToNullspace() // To the void u go
	swap_form.forceMove(moveloc) // bring out our lil fren
	// M.forceMove(swap_form) // time to bring out our lil fren
	swap_form.tf_mob_holder = M

	M.visible_message("<span class='danger>[M] distorts as their form changes!</span>","<span class='notice'>You feel your body change!</span>")
	log_admin("Admin [key_name(M)]'s form swapped via form stabilizer gear.")
	to_chat(M, "<span class='notice'>\The [src] pulses. Its circuits have begun to pool energy again and the capacitor will be charged in [(world.time - last_activated)/60] seconds from now.</span>")

/datum/component/form_stabilizer/proc/equipped(user, var/mob/M, var/slot)
	if(slot == slot_r_hand || slot_l_hand) // We don't want to do anything if it was just picked up.
		return

	if(!assigned) // If we're not assigned to anyone, lets go ahead and assign ourselves.
		assigned = TRUE
		owner_ckey = M.ckey

	if(owner_ckey != M.ckey)
		to_chat(M, "<span class='warning'>You are not the owner of this item, and therefore, nothing happens.</span>")
		return // Don't do anything if we're not the owner.

	if(emp_disrupted || burnt_out) // Are we nonfunctional?
		to_chat(M, "<span class='warning'>This is currently nonfunctional and needs repairs.</span>")
		return
	// Now we go ahead and register what our current form is for other code
	// Essentially, if our first equip comes from a human/carbon mob, we're going to register that.
	// If this item was initialized/created outside of loadout (and therefore not immediately equipped), then the simplemob form will be set by the mob attack.
	if(!last_activated) // Do we not have a last activated/is it set null? This is our first use.
		if(ishuman(M))
			shapeshift_form = M // Link our Carbon Mob
		else // Safety, but this shouldn't happen this way.
			true_form = M

		last_activated = world.time // Setting this now so the check doesn't repeat.
		return // We don't want to do anything else here. Swapping form would be useless because we're equipped by loadout.


	if((world.time - last_activated < cooldown_time) && M == true_form) // if 2300 - 2250 (50) < 60, for example. We should only cooldown if we're trying to go from simple -> carbon, not the other way around?
		to_chat(M, "<span class='notice'>\The [src] pulses. It appears to still be recharging.</span>")
		return

	last_activated = world.time
	swap_form(M)

/datum/component/form_stabilizer/proc/binding_check(user, var/mob/M)
	if(!assigned)
		var/answer = tgui_alert(M, "Do you want to bind this to yourself? If you are a simplemob, you will spawn your loaded saveslot, and your current form will be the form you revert to. If you are carbon, you will select a mob and revert to that when removing this item.", "Assign To FSG", list("Yes","No"))
		if(answer == "No")
			return

		assigned = TRUE
		owner_ckey = M.ckey

	if(!(M.ckey == owner_ckey))
		to_chat(M, "<span class='warning'>You are not the owner of this item, and therefore, nothing happens.</span>")
		return // Don't do anything.

	if(ishuman(M)) // Safety
		if(!true_form)
			select_form(M) // Spawn simple
	else if(!true_form) // Are we not linked yet?
		true_form = M
		to_chat(M, "<span class='notice'>Your current save slot will now be spawned. You will be linked, and then transferred into it.</span>")
		if(!shapeshift_form)
			form_spawn(M, TRUE) // Spawn carbon

	else // Else, we are linked with a true form and we just got bonked with the item, now we need to put ourselves into carbon
		if(emp_disrupted || burnt_out) // Don't do anything if we're still disrupted.
			to_chat(M, "<span class='danger'>The circuits require repair! Examine for more details!</span>")
			return

		swap_form(M)

/datum/component/form_stabilizer/proc/select_form(user, var/mob/M) // Choose our form, and then immediately spawn it. ONLY called by carbons.
	if(!true_form) // Does a simplemob not exist?
		var/selected_form = tgui_input_list(M, "Mob Type?", "Mob Selection", usable_forms)
		if(selected_form)
			form_spawn(M, form_to_spawn = selected_form) // Spawn our form in nullspace and set it up.
		else
			to_chat(M, "<span class='notice'>Selection failed. Try again.</span>")
	else // Shouldn't happen
		log_runtime(EXCEPTION("Select form was called with an already-existing simplemob!"))
		to_chat(M, "<span class='danger'>[src] has already had a form type chosen! Ahelp if you need this changed!</span>")

/datum/component/form_stabilizer/proc/emp_act(user, var/severity, var/mob/M)
	if(severity > 3 || !severity) // Don't act on sev4 or 0 sev
		return

	if(!true_form)
		log_runtime(EXCEPTION("emp_act happened without a true form to failsafe/fall back to!"))
		return

	// Require multitool resets based on severity of EMP
	var/sevstr = null
	switch(severity)
		if(1)
			sevstr = 3
		if(2)
			sevstr = 2
		if(3)
			sevstr = 1
	emp_disrupted = sevstr + rand(0,2)

	if(severity == 1) // Direct EMP
		burnt_out = TRUE // Burn this item out, requiring wiring replacement.

	if(ishuman(M)) // Safety
		if(M.get_equipped_item(slot_l_hand || slot_r_hand) == src) // We don't want to do anything if it was just picked up.
			return
		swap_form(M)

/datum/component/form_stabilizer/proc/attackby(user, var/obj/item/I, var/mob/M)
	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = I
		if(CC.get_amount() >= 2) // Minimum of 2
			CC.use(rand(0,2)) // Use up to 2 lengths of cable
			burnt_out = FALSE
			to_chat(M, "<span class='notice'>You replace the wiring inside [src]. Reset the item using a multitool [emp_disrupted] times.</span>")
			return
		else
			to_chat(M, "<span class='notice'>Not enough cable to repair this. Get at least 2 segments.</span>")
			return
	else if(istype(I, /obj/item/device/multitool))
		if(emp_disrupted)
			var/rdelay = (rand(0,3) SECONDS) + (emp_disrupted SECONDS) // Increase the delay by a random amount
			to_chat(M, "<span class='notice'>You start to reset one of the circuits. This will take [rdelay] seconds...</span>")
			if(do_after(user, delay = rdelay))
				emp_disrupted-- // Remove one counter.
				to_chat(M, "<span class='notice'>You successfully reset the circuit. [emp_disrupted] circuits remain to be reset.</span>")
				return
		// TODO: Allow resetting the stabilizer later.
		/*
		else
			var/answer = tgui_alert(M, "Do you wish to reset this item entirely?", "Reset FSG", list("Yes","No"))
			if(answer == "No")
				return
			to_chat(M, "<span class='danger'>You start to reset [src]'s circuits. This will take some time...</span>")
			var/regret_time = rand(30,60) SECONDS
			if(!true_form) // We can't force someone into simplemob form if it doesn't exist, so this entire chain shouldn't happen.
				to_chat(M, "<span class='danger'>No true form exists or is setup! Something went wrong!</span>")
				log_runtime(EXCEPTION("Someone tried to reset us without a true form to failsafe/fall back to!"))
				return
			var/mob/living/L = true_form // Assuming our true form exists here.
			to_chat(L.client, "<span class='danger'>Someone is resetting your [src]! You have [regret_time] seconds to stop them if you want to interrupt this process!</span>")
			if(do_after(M, delay = regret_time)) // Really make sure you want to reset this.
				reset_stabilizer(L)
		*/

	else // Else, we go ahead and do the check
		if(emp_disrupted || burnt_out) // Don't do anything if we're still disrupted.
			to_chat(M, "<span class='danger'>The circuits require repair! Examine for more details!</span>")
			return

		binding_check(M)

/datum/component/form_stabilizer/proc/examine(user, var/mob/M)
	if(world.time - last_activated < cooldown_time)
		. += "The circuit is still recharging. Item will be ready in [(world.time - last_activated < cooldown_time) SECONDS]."
	else
		. += "The circuits hum with stored power."

	if(emp_disrupted)
		. += "The circuits are disrupted, and require resetting with a multitool. Reset the item [emp_disrupted] times."

	if(burnt_out)
		. += "The circuits have burnt out entirely. Get a cable coil with two wires and replace the wiring in the item."

	if(!assigned)
		. += "This is not yet linked with anyone. Click on a mob to link it to them."
	else
		var/mob/living/simple_mob/T = true_form
		. += "This is linked to someone. Look for a mob of type [T.tt_desc]."

	. += "This item is designed to stabilize a mob's form, allowing them to use a different form unless this is EMP'd. Click on a mob to link it to them."

// TODO: Allow resetting the stabilizer later.
/*
/datum/component/form_stabilizer/proc/reset_stabilizer(user, var/mob/M)
	// First things first, we need to get rid of our carbon form, but make sure there's a true form to put them into.
	if(true_form) // Shouldn't need this since it's called with an existing mob, but, safety.
*/

/obj/item/clothing/gloves/ring/form_stabilizer
	name = "form stabilization gear"
	desc = "A surprisingly compact device that seems to offer the wearer the capability to retain an anthro - or tauric - form."
	// icon = 'icons/inventory/accessory/item_ch.dmi'
	// icon_state = 'bs_ring'
	w_class = ITEMSIZE_TINY
	glove_level = 1

/obj/item/clothing/gloves/ring/form_stabilizer/Initialize()
	. = ..()

	LoadComponent(/datum/component/form_stabilizer)

// What happens when we remove the ring
/obj/item/clothing/gloves/ring/form_stabilizer/dropped(mob/user, gloves)
	. = ..()

	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED, user)

/obj/item/clothing/gloves/ring/form_stabilizer/attackby(obj/item/I, mob/user) // mob clicked on by item
	. = ..() // Now we do the equip/etc

	SEND_SIGNAL(src,COMSIG_MOB_ITEM_ATTACK, user, I)

/obj/item/clothing/gloves/ring/form_stabilizer/equipped(mob/user, slot) // Putting this in an item slot that is NOT hands
	. = ..()

	SEND_SIGNAL(src,COMSIG_ITEM_EQUIPPED, user, slot)

/obj/item/clothing/gloves/ring/form_stabilizer/attack_self(mob/user) // Clicking on ourselves
	. = ..()

	SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user)

/obj/item/clothing/gloves/ring/form_stabilizer/emp_act(mob/user, severity)
	. = ..()

	SEND_SIGNAL(src, COMSIG_ATOM_EMP_ACT, user, severity)

/obj/item/clothing/gloves/ring/form_stabilizer/examine(mob/user)
	. = ..()

	SEND_SIGNAL(src, COMSIG_MOB_EXAMINATE, user)
