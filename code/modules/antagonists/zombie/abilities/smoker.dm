///////////////||\\\\\\\\\\\\\\\
////						\\\\
////	STARTING ABILITIES	\\\\
////						\\\\
////\\\\\\\\\\\||///////////\\\\

/datum/action/innate/zombie/default/smoke
	name = "Spew Smoke"
	desc = "Blow it out."
	button_icon_state = "smoke"
	ability_type = ZOMBIE_TOGGLEABLE
	constant_cost = 10
	cost = 10
	///Used in code\modules\mob\living\carbon\human\species_types\zombies.dm to balance out Smoker infection regeneration.
	var/last_fired

/obj/effect/particle_effect/smoke/bad/zombie/New()
	. = ..()
	add_atom_colour("#104410", FIXED_COLOUR_PRIORITY)

/datum/action/innate/zombie/default/smoke/process()
	. = ..()
	do_smoke(1, get_turf(owner), /obj/effect/particle_effect/smoke/bad/zombie) //bad smoke halves proj damage
	last_fired = world.time

/datum/action/innate/zombie/scorch
	name = "Scorch Skin"
	desc = "Blow it out."
	button_icon_state = "char"
	ability_type = ZOMBIE_FIREABLE
	cooldown = 15 SECONDS

/datum/action/innate/zombie/scorch/IsTargetable(atom/target_atom)
	return isliving(target_atom)

/datum/action/innate/zombie/scorch/UseFireableAbility(atom/target_atom)
	. = ..()
	if(iscarbon(target_atom))
		var/mob/living/carbon/C = target_atom
		var/selected_zone = owner.zone_selected
		var/list/viable_zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES)
		owner.do_attack_animation(C, ATTACK_EFFECT_PUNCH)
		playsound(usr.loc, "sound/weapons/sear.ogg", 50, TRUE)
		C.apply_damage(20, BURN, selected_zone)
		if(viable_zones.Find(selected_zone))
			C.apply_damage(30, STAMINA, selected_zone)
			if(selected_zone == BODY_ZONE_PRECISE_MOUTH)
				C.silent += 6
			if(selected_zone == BODY_ZONE_PRECISE_EYES)
				var/obj/item/organ/eyes/eyes = C.getorganslot(ORGAN_SLOT_EYES)
				eyes.applyOrganDamage(5)

/////////////////||\\\\\\\\\\\\\\\\\
////							\\\\
////	PURCHASABLE ABILITIES	\\\\
////							\\\\
////\\\\\\\\\\\\\||/////////////\\\\

/datum/action/innate/zombie/swing
	name = "Spew Smoke"
	desc = "Blow it out."
	button_icon_state = "swing"
	ability_type = ZOMBIE_FIREABLE
	cooldown = 10 SECONDS
	range = 7

/datum/action/innate/zombie/swing/IsTargetable(atom/target_atom)
	return isopenturf(target_atom) || iscarbon(target_atom)

/datum/action/innate/zombie/swing/UseFireableAbility(atom/target_atom)
	. = ..()
	owner.Beam(target, "smokertongue", time = 0.5 SECONDS, maxdistance = range)
	owner.throw_at(target_atom)