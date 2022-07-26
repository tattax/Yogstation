///////////////||\\\\\\\\\\\\\\\
////						\\\\
////	STARTING ABILITIES	\\\\
////						\\\\
////\\\\\\\\\\\||///////////\\\\

/datum/action/innate/zombie/default/bolt
	name = "Bolt"
	desc = "Sex"
	button_icon_state = "bolt"
	ability_type = ZOMBIE_TOGGLEABLE
	cost = 5
	constant_cost = 2.5

/datum/action/innate/zombie/default/bolt/Activate()
	. = ..()
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, ZOMBIE_TRAIT)
	ADD_TRAIT(owner, TRAIT_PACIFISM, ZOMBIE_TRAIT)
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(locate("better_reflexes") in zombie_owner.zombie_mutations)
		ADD_TRAIT(owner, TRAIT_DODGE, ZOMBIE_TRAIT)

/datum/action/innate/zombie/default/bolt/Deactivate()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, ZOMBIE_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, ZOMBIE_TRAIT)
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(locate("better_reflexes") in zombie_owner.zombie_mutations)
		REMOVE_TRAIT(owner, TRAIT_DODGE, ZOMBIE_TRAIT)

/datum/action/innate/zombie/parkour
	name = "Parkour"
	desc = "kill"
	button_icon_state = "parkour"
	ability_type = ZOMBIE_TOGGLEABLE
	cooldown = 15 SECONDS
	///Jumping over 5 obstacles will automatically disable Parkour.
	var/obstacles_jumped = 0

/datum/action/innate/zombie/parkour/Activate()
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_BUMP, .proc/Parkour)

/datum/action/innate/zombie/parkour/process()
	var/max_obstacles = 5
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(locate("leg_response") in zombie_owner.zombie_mutations)
		max_obstacles = 10
	if(obstacles_jumped == max_obstacles)
		Deactivate()

/datum/action/innate/zombie/parkour/proc/Parkour(mob/user, atom/affected)
	var/list/bumpable_atoms = list(/obj/structure/table, /obj/structure/barricade, /obj/structure/destructible/cult, /obj/structure/altar_of_gods)
	if(is_type_in_list(affected, bumpable_atoms))
		user.emote("flip")
		user.forceMove(get_turf(affected))
		obstacles_jumped++

/datum/action/innate/zombie/parkour/Deactivate()
	. = ..()
	obstacles_jumped = 0
	UnregisterSignal(owner, COMSIG_MOVABLE_BUMP)

/////////////////||\\\\\\\\\\\\\\\\\
////							\\\\
////	PURCHASABLE ABILITIES	\\\\
////							\\\\
////\\\\\\\\\\\\\||/////////////\\\\

/datum/action/innate/zombie/pickpocket
	name = "Parkour"
	desc = "kill"
	button_icon_state = "parkour"
	ability_type = ZOMBIE_TOGGLEABLE
	cooldown = 20 SECONDS
	var/pocketed = 0

/datum/action/innate/zombie/pickpocket/process()
	if(pocketed == 5)
		pocketed = 0
		Deactivate()
	for(var/mob/living/carbon/C in view(1, owner))
		C.dropItemToGround(C.get_active_held_item())
		pocketed++
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(!do_after(owner, 2.5 SECONDS, H))
				continue
			var/obj/item/pocket_item = H.r_store || H.l_store
			H.dropItemToGround(pocket_item)