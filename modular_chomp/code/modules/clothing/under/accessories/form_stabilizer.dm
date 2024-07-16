/*
 * The below code is intended to allow players to have a simplemob "true self" that they will change to upon unequip of the item.
*/
/datum/component/form_stabilizer
	var/mob/living/carbon/human/M

	var/assigned = FALSE // Is a player registered to this item? Starts FALSE, becomes TRUE when interacted with or spawned + equipped.
	var/selected_form = null
	var/true_form = null
	var/shapeshift_form = null
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
		/mob/living/simple_mob/animal/wolf/direwolf,
		/mob/living/simple_mob/otie/friendly,
		/mob/living/simple_mob/vore/alienanimals/catslug,
		/mob/living/simple_mob/vore/alienanimals/teppi,
		/mob/living/simple_mob/vore/fennec,
		/mob/living/simple_mob/vore/xeno_defanged,
		/mob/living/simple_mob/vore/redpanda/fae,
		/mob/living/simple_mob/vore/aggressive/rat,
		/mob/living/simple_mob/vore/aggressive/panther,
		/mob/living/simple_mob/vore/aggressive/frog
	)

/datum/component/form_stabilizer/Initialize(...)
	. = ..()
	RegisterSignal(FORM_STAB_EQUIP, TYPE_PROC_REF(FORM_STAB_EQUIPPED))

/obj/item/clothing/form_stabilizer
	name = "form stabilization gear"
	desc = "A surprisingly compact device that seems to offer the wearer the capability to retain an anthro - or tauric - form."
	icon = 'icons/inventory/accessory/item_ch.dmi'
	icon_state = 'bs_ring'
	w_class = ITEMSIZE_TINY
	glove_level = 1



// Initialize. Here, we'll setup the item's selected form, flag our original mob, and spawn our mob
/obj/item/clothing/form_stabilizer/Initialize(var/mob/M = src, var/mob/living/simple_mob/form = selected_form)
	. = ..()
	if(. && ishuman(M))
		shapeshift_form = M

	// Define our new mob here, create it at nullspace.
	var/form_to_spawn =
	var/mob/living/simple_mob/new_mob = new form(0,0)

// What happens when we remove the ring
/obj/item/clothing/form_stabilizer/mob_can_unequip(mob/M, gloves, disable_warning = 0)
	. = ..()


/obj/item/clothing/form_stabilizer/proc/first_spawn(var/mob/M)
	if(. && ishuman(M) && !disable_warning) // If we're in our carbonmob form
		var/mob/living/carbon/human/H = M

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
			if(ishuman(M)) // Check if we're human so that we know these vars exist and set our gender + pronouns
				var/mob/living/carbon/human/H = M
				if(ishuman(new_mob))
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

			for(var/obj/belly/B as anything in M.vore_organs) // Anything in our bellies is now forcemoved into the new mob.
				B.loc = new_mob
				B.forceMove(new_mob)
				B.owner = new_mob
				M.vore_organs -= B
				new_mob.vore_organs += B

			new_mob.ckey = M.ckey // Finally, transfer our ckey over
			if(M.ai_holder && new_mob.ai_holder)
				var/datum/ai_holder/old_AI = M.ai_holder
				old_AI.set_stance(STANCE_SLEEP)
				var/datum/ai_holder/new_AI = new_mob.ai_holder
				new_AI.hostile = old_AI.hostile
				new_AI.retaliate = old_AI.retaliate
			M.loc = new_mob // Put our old mob inside the new one
			M.forceMove(new_mob) // Ditto
			new_mob.tf_mob_holder = M
			///End of mobcode.
