/*
 * This file contains the code for the NPCs themselves, and their AI, as indicated by code comment blocks.
 * Do NOT add your own custom NPCs here! Use custom_distress_npcs.dm to add in your own custom mobs by template.
 * Spawning and tracking of the NPCs is handled in ship_spawning.dm.
 * Use this file solely to dictate how NPCs will respond to players.
*/
/mob/living/carbon/human/npc 		// This is our base subtype. Most of the following code comes from ai_controlled
	name = null 					// We're going to randomly generate a name on spawn.
	ai_holder_type = /datum/ai_holder/simple_mob/npc

	var/generate_specific_species = null // If true (not null), generate this. Otherwise, we randomly choose based on a list.
	// Pickweight list, to ensure some variation for nonhuman crews.
	var/species_list = list(
		SPECIES_VULPKANIN = 120,
		SPECIES_TAJARAN = 20,
		SPECIES_SERGAL = 20,
		SPECIES_AKULA = 40, // Sharks based
		SPECIES_ZORREN_HIGH = 10,
		SPECIES_HUMAN = 5 // Low chance.
		)
	var/generate_dead = FALSE

	var/generate_weighted_gender = TRUE // Do we generate a gender based on weights, rather than true random?
	var/weighted_gender_list = list(
		MALE = 40,
		FEMALE = 120,
		PLURAL = 20,
		NEUTER = 10
		)
	var/generate_specific_gender = null // If set, we override the random gender selection.
	var/generate_specific_id_gender = null // Same as above comment.

	// Pickweight list, to ensure variation.
	// Converted to h_style on init.
	var/hairstyle = list(
		"Bald" = 0,
		"Overeye Long" = 20,
		"Overeye Short" = 30
	)

	var/starting_helmet = /obj/item/clothing/head/welding
	var/starting_glasses = /obj/item/clothing/glasses/threedglasses
	var/starting_mask = /obj/item/clothing/mask/gas
	var/starting_l_radio = /obj/item/device/radio/headset
	var/starting_r_radio = null
	var/starting_uniform = /obj/item/clothing/under/color/grey
	var/starting_suit = /obj/item/clothing/suit/armor/material/makeshift/glass
	var/starting_gloves = /obj/item/clothing/gloves/ring/material/platinum
	var/starting_shoes = /obj/item/clothing/shoes/galoshes
	var/starting_belt = /obj/item/weapon/storage/belt/utility/full
	var/starting_l_pocket = /obj/item/weapon/soap
	var/starting_r_pocket = /obj/item/device/pda
	var/starting_back = /obj/item/weapon/storage/backpack
	var/id_type = /obj/item/weapon/card/id
	var/id_job = "Assistant" // Whatever you set this to, ensure it is a string ("words")
	var/npc_access = list() // Empty by default.

	var/starting_l_hand = null
	var/starting_r_hand = null

/mob/living/carbon/human/npc/Initialize()
	if(generate_weighted_gender)
		var/g = pickweight(weighted_gender_list)
		gender = g
		switch(g)
			if(g == MALE)
				identifying_gender = pickweight(list(MALE = 120, FEMALE = 40, PLURAL = 20, NEUTER = 20))
			if(g == FEMALE)
				identifying_gender = pickweight(list(FEMALE = 120, MALE = 40, PLURAL = 20, NEUTER = 20))
			if(g == PLURAL)
				identifying_gender = pickweight(list(PLURAL = 120, MALE = 20, FEMALE = 20, NEUTER = 20))
			if(g == NEUTER)
				identifying_gender = pickweight(list(NEUTER = 120, MALE = 20, FEMALE = 20, PLURAL = 20))

	if(generate_specific_gender)
		gender = generate_specific_gender
	else // If we don't override one specific, and we don't use a weighted list, randomize.
		gender = pick(list(MALE, FEMALE, PLURAL, NEUTER))

	if(generate_specific_id_gender)
		identifying_gender = generate_specific_id_gender
	else // If we don't override one specific, and we don't use a weighted list, randomize.
		identifying_gender = pick(list(MALE, FEMALE, PLURAL, NEUTER))

	var/species_choice
	if(generate_specific_species)
		species_choice = generate_specific_species
	else
		species_choice = pickweight(species_list)
	..(loc, species_choice)

	h_style = hairstyle

	if(starting_uniform)
		equip_to_slot_or_del(new starting_uniform(src), slot_w_uniform)

	if(starting_suit)
		equip_to_slot_or_del(new starting_suit(src), slot_wear_suit)

	if(starting_shoes)
		equip_to_slot_or_del(new starting_shoes(src), slot_shoes)

	if(starting_gloves)
		equip_to_slot_or_del(new starting_gloves(src), slot_gloves)

	if(starting_l_radio)
		equip_to_slot_or_del(new starting_l_radio(src), slot_l_ear)

	if(starting_r_radio)
		equip_to_slot_or_del(new starting_r_radio(src), slot_r_ear)

	if(starting_glasses)
		equip_to_slot_or_del(new starting_glasses(src), slot_glasses)

	if(starting_mask)
		equip_to_slot_or_del(new starting_mask(src), slot_wear_mask)

	if(starting_helmet)
		equip_to_slot_or_del(new starting_helmet(src), slot_head)

	if(starting_belt)
		equip_to_slot_or_del(new starting_belt(src), slot_belt)

	if(starting_r_pocket)
		equip_to_slot_or_del(new starting_r_pocket(src), slot_r_store)

	if(starting_l_pocket)
		equip_to_slot_or_del(new starting_l_pocket(src), slot_l_store)

	if(starting_back)
		equip_to_slot_or_del(new starting_back(src), slot_back)

	if(starting_l_hand)
		equip_to_slot_or_del(new starting_l_hand(src), slot_l_hand)

	if(starting_r_hand)
		equip_to_slot_or_del(new starting_r_hand(src), slot_r_hand)

	if(id_type)
		var/obj/item/weapon/card/id/W = new id_type(src)
		W.name = "[real_name]'s ID Card"
		/*
		var/datum/job/jobdatum
		for(var/jobtype in typesof(/datum/job))
			var/datum/job/J = new jobtype
			if(J.title == id_job)
				jobdatum = J
				break
		if(jobdatum)
			W.access = jobdatum.get_access()
		else
			W.access = list()
		*/
		W.access = npc_access
		if(id_job)
			W.assignment = id_job
		W.registered_name = real_name
		equip_to_slot_or_del(W, slot_wear_id)

	if(generate_dead)
		death()

/*
 * AI Code
 * Holder - Pathfinding - Dialogue - Panic Reactions
 * More TBD
*/

/datum/ai_holder/simple_mob/npc
	hostile = FALSE
	retaliate = TRUE // They will smack your ass for hitting them.
	can_flee = TRUE // They're supposed to be smart
	wander = TRUE	// They will wander *when not patrolling a set path*.
