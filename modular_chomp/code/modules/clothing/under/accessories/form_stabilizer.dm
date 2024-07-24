/*
 * The below code is intended to allow players to have a simplemob "true self" that they will change to upon unequip of the item.
 * The process is simple;
 * On unequip: 1: Check if assigned. 2: Swap player into mob 3: qualize health + location. 4: Transfer all items in bellies. 5: Strip all gear onto the floor. 6: Start cooldown.
 * On equip: 1: Ask if they are sure they wish to do this, and that they WILL appear devoid of gear. 2: Repeat the above.
*/
/datum/component/form_stabilizer
	var/mob/living/carbon/human/M

	var/assigned = FALSE // Is a player registered to this item? Starts FALSE, becomes TRUE when interacted with or spawned + equipped.
	var/owner_ckey = null // Who owns us?
	var/true_form = null // Linked simple/feral mob
	var/shapeshift_form = null // Linked carbon mob
	var/last_activated = null // When were we last used?
	var/cooldown_time = 60 SECONDS // By default, the ring can only change forms once every minute. Done this way bc swapping forms is server-intensive, I think?
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
	RegisterSignal(parent, COMSIG_MOB_ITEM_ATTACK, PROC_REF(binding_check)) // Mobs can't put this item on themselves, by design. Plus it's cute to need help.
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(binding_check)) // Choose our form.

/datum/component/form_stabilizer/proc/form_spawn(user, var/mob/living/M, var/mob/form_to_spawn, var/carbon = FALSE) // This should be called either by loadout on equip or on first use if we're not being spawned via loadout equip.
	// Define our new mob here, create it at nullspace.
	if(carbon) // Are we spawning a carbon?
		var/mob/living/carbon/human/new_human = new /mob/living/carbon/human()
		M.client.prefs.copy_to(new_human) // This should work, I think?
		shapeshift_form = new_human // Link our carbon to this ring
		swap_form(M)
	else // Else, we're spawning simplemob
		var/mob/living/simple_mob/new_mob = new form_to_spawn()
		new_mob = true_form // Link our simplemob to the ring

		// New mob info checks
		//Start of mob code shamelessly ripped from mouseray (and now replicator :3)
		new_mob.faction = M.faction // We're going to inherit our faction to prevent issues like station turrets shooting us.

		if(new_mob && isliving(new_mob)) // Sanity check in case the new mob suddenly dies for w/e reason
			for(var/obj/belly/B as anything in new_mob.vore_organs)
				new_mob.vore_organs -= B
				qdel(B)
			new_mob.vore_organs = list()
			new_mob.name = M.name
			new_mob.real_name = M.real_name
			for(var/lang in M.languages)
				new_mob.languages |= lang
			M.copy_vore_prefs_to_mob(new_mob)
			new_mob.vore_selected = M.vore_selected
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
		log_runtime(EXCEPTION("Our ckey doesn't match or is null!"))
		return

	if(!true_form || !shapeshift_form)
		log_runtime(EXCEPTION("Swap form was called without proper forms! True form is [true_form] and carbon form is [shapeshift_form]."))
		return

	// TODO: Select form based on what our current form is.
	var/mob/living/swap_form = null
	if(ishuman(M)) // This should handle it. Are we currently carbon?
		swap_form = true_form
	else // Else, we're not carbon, but someone bonked us with the collar, so we want to become carbon.
		swap_form = shapeshift_form

	// Grab our loc, health, and current time for further use.
	//var/orig_health = M.health
	var/moveloc = M.loc

	/* // WIP
	// Health calculations
	var/hper = (M.getMaxHealth - M.getOxyLoss() - M.getToxLoss() - M.getFireLoss() - M.getBruteLoss() - M.getCloneLoss() - M.halloss / M.getMaxHealth)
	// Our h var above now has our max health - damage, divided by max health, for our percent.
	if(hper <= 0) // Are we dead?
		return // Stop.
	if(ishuman(swap_form)) // Are we going simple -> carbon?
		swap_form.setOxyLoss(M.getOxyLoss)
		swap_form.setToxLoss(M.getToxLoss)
		swap_form.setFireLoss(M.getFireLoss)
		swap_form.setBruteLoss(M.getBruteLoss)
		swap_form.setCloneLoss(M.getCloneLoss)
	else // We don't want to manually copy over the oxy/etc losses.
		swap_form.health = getMaxHealth * hper

	// Time to drop stuff! (Stolen from prommies)
	if(ishuman(M))
		var/list/things_to_drop = M.contents.Copy()
		var/list/things_to_not_drop = list(w_uniform,nif,l_store,r_store,wear_id,l_ear,r_ear) //And whatever else we decide for balancing.
		things_to_drop -= things_to_not_drop //Crunch the lists
		things_to_drop -= organs //Mah armbs
		things_to_drop -= internal_organs //Mah sqeedily spooch

		for(var/obj/item/I in things_to_drop) // hehehe items go clonk
			drop_from_inventory(I)

		if(w_uniform && istype(w_uniform,/obj/item/clothing)) //No webbings tho. We do this after in case a suit was in the way
			var/obj/item/clothing/uniform = w_uniform
			if(LAZYLEN(uniform.accessories))
				for(var/obj/item/clothing/accessory/A in uniform.accessories)
					if(is_type_in_list(A, disallowed_protean_accessories))
						uniform.remove_accessory(null,A) //First param is user, but adds fingerprints and messages

		if(l_hand) drop_from_inventory(l_hand)
		if(r_hand) drop_from_inventory(r_hand)
	*/

	// Time to swap into new mob. Code stolen from replicator.
	for(var/obj/belly/B as anything in M.vore_organs) // Anything in our bellies is now forcemoved into the new mob.
		B.loc = swap_form // Belly is now told it is in swap form.
		B.forceMove(swap_form) // Forcibly move it.
		B.owner = swap_form // Register the new owner.
		M.vore_organs -= B // Remove vorgan from old mob list to prevent recursive loop.
		swap_form.vore_organs += B // Transferring vorgans over to new list.

	swap_form.ckey = M.ckey // Finally, transfer our ckey over
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

	M.visible_message("<span class='warning>[M] distorts as their form changes!</span>","<span class='notice'>You feel your body change!</span>")
	log_admin("Admin [key_name(M)]'s form swapped via form stabilizer gear.")
	to_chat(M, "<span class='warning'>\The [src] pulses. Its circuits have begun to pool energy again and the capacitor will be charged in 60 seconds from now.</span>")

/datum/component/form_stabilizer/proc/equipped(user, var/mob/M)
	// First things first, our signal is received, we need to assign ourselves to the component.
	if(!assigned) // If we're not assigned to anyone, lets go ahead and assign ourselves.
		assigned = TRUE
		owner_ckey = M.ckey

	if(owner_ckey != M.ckey)
		return // Don't do anything if we're not the owner.
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
		to_chat(M, "<span class='warning'>\The [src] pulses. It appears to still be recharging.</span>")
		return

	last_activated = world.time
	swap_form(M)

/datum/component/form_stabilizer/proc/binding_check(user, var/mob/M)
	if(!assigned)
		var/answer = tgui_alert(M, "Do you want to bind this to yourself? This cannot be undone. If you are a simplemob, you will spawn your loaded saveslot, and your current form will be the form you revert to. If you are carbon, you will select a mob and revert to that when removing this item.", "Assign To FSG", list("Yes","No"))
		if(answer == "No")
			return

		assigned = TRUE
		owner_ckey = M.ckey

	if(M.ckey == owner_ckey && ishuman(M)) // Safety
		if(!true_form)
			select_form(M) // Spawn simple
	else if(M.ckey == owner_ckey)
		true_form = M
		to_chat(M, "<span class='notice'>Your current save slot will now be spawned. You will be linked, and then transferred into it.</span>")
		if(!shapeshift_form)
			form_spawn(M, TRUE) // Spawn carbon

/datum/component/form_stabilizer/proc/select_form(user, var/mob/M) // Choose our form, and then immediately spawn it. ONLY called by carbons.
	if(!true_form) // Does a simplemob not exist?
		var/selected_form = tgui_input_list(M, "Mob Type?", "Mob Selection", usable_forms)
		if(selected_form)
			form_spawn(M, form_to_spawn = selected_form) // Spawn our form in nullspace and set it up.
		else
			to_chat(M, "<span class='notice'>Selection failed. Try again.</span>")
	else // Shouldn't happen
		log_runtime(EXCEPTION("Select form was called with an already-existing simplemob!"))
		to_chat(M, "<span class='notice'>[src] has already had a form type chosen! Ahelp if you need this changed.</span>")

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

/obj/item/clothing/gloves/ring/form_stabilizer/attackby(mob/M)
	. = ..() // Now we do the equip/etc

	SEND_SIGNAL(src,COMSIG_MOB_ITEM_ATTACK, M)

/obj/item/clothing/gloves/ring/form_stabilizer/equipped(mob/user, slot)
	. = ..()

	SEND_SIGNAL(src,COMSIG_ITEM_EQUIPPED, user)

/obj/item/clothing/gloves/ring/form_stabilizer/attack_self(mob/user)
	. = ..()

	SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user)
