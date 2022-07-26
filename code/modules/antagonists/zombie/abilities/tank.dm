///////////////||\\\\\\\\\\\\\\\
////						\\\\
////	STARTING ABILITIES	\\\\
////						\\\\
////\\\\\\\\\\\||///////////\\\\

/datum/action/innate/zombie/default/rage
	name = "Unyielding Rage"
	desc = "Destroy them for what they've done to you."
	button_icon_state = "rage"
	ability_type = ZOMBIE_TOGGLEABLE
	cost = 2
	constant_cost = 0.1

/datum/action/innate/zombie/default/rage/Activate()
	. = ..()
	var/previous_cooldown = FALSE
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	for(var/datum/action/innate/zombie/charge/C in zombie_owner.zombie_abilities)
		if(!COOLDOWN_FINISHED(C, zombie_ability_cooldown))
			previous_cooldown = TRUE
		var/datum/action/innate/zombie/default/smash/S = new
		S.Grant(owner)
		C.Remove(owner)
		if(previous_cooldown)
			S.StartCooldown()

/datum/action/innate/zombie/default/rage/Deactivate()
	. = ..()
	var/previous_cooldown = FALSE
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	for(var/datum/action/innate/zombie/default/smash/S in zombie_owner.zombie_abilities)
		var/datum/action/innate/zombie/charge/C = new
		if(!COOLDOWN_FINISHED(S, zombie_ability_cooldown))
			previous_cooldown = TRUE
		C.Grant(owner)
		S.Remove(owner)
		if(previous_cooldown)
			C.StartCooldown()

/datum/action/innate/zombie/default/smash
	name = "Destroying Smash"
	desc = "SMASH."
	button_icon_state = "smash"
	ability_type = ZOMBIE_FIREABLE
	cooldown = 10 SECONDS
	cost = 20
	range = 5

/datum/action/innate/zombie/default/smash/IsTargetable(atom/target_atom)
	return isturf(target_atom) || isliving(target_atom) || isstructure(target_atom)

/datum/action/innate/zombie/default/smash/UseFireableAbility(atom/target_atom)
	. = ..()
	var/turf/target_turf = get_turf(target_atom)
	if(!owner.throw_at(target_turf))
		owner.forceMove(target_turf)
	playsound(target_turf, 'sound/effects/bang.ogg', 30, TRUE, -1)
	for(var/atom/movable/thing in view(1, target_turf))
		if(thing == owner)
			continue
		if(isliving(thing))
			var/mob/living/L = thing
			if(get_turf(L) == get_turf(src))
				L.adjustBruteLoss(30)
				L.Knockdown(2 SECONDS)
			else
				L.adjustBruteLoss(20)
			owner.do_attack_animation(L, ATTACK_EFFECT_SMASH)
			var/send_dir = get_dir(owner, L)
			var/turf/turf_thrown_at = get_ranged_target_turf(L, send_dir, 5)
			L.throw_at(turf_thrown_at, 5, TRUE, owner)
		if(isstructure(thing) || ismachinery(thing))
			var/obj/O = thing
			O?.take_damage(100, BRUTE, MELEE, 1)

/datum/action/innate/zombie/charge
	name = "Unstopabble Charge"
	desc = "Charge."
	button_icon_state = "charge"
	ability_type = ZOMBIE_FIREABLE
	cooldown = 15 SECONDS
	range = 5
	///See code\modules\antagonists\bloodsuckers\powers\targeted\haste.dm
	var/list/hit
	var/speed_override

/datum/action/innate/zombie/charge/IsTargetable(atom/target_atom)
	return isturf(target_atom) || isliving(target_atom) || target_atom.loc != owner.loc

/datum/action/innate/zombie/charge/UseFireableAbility(atom/target_atom)
	. = ..()
	hit = list()
	var/mob/living/user = owner
	RegisterSignal(user, COMSIG_MOVABLE_BUMP, .proc/Obliterate)
	var/turf/targeted_turf = isturf(target_atom) ? target_atom : get_turf(target_atom)
	// Pulled? Not anymore.
	user.pulledby?.stop_pulling()
	// Go to target turf
	// DO NOT USE WALK TO.
	playsound(get_turf(owner), 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	var/safety = get_dist(user, targeted_turf) * 3 + 1
	var/consequetive_failures = 0
	var/speed = isnull(speed_override)? world.tick_lag : speed_override
	while(--safety && (get_turf(user) != targeted_turf))
		var/success = step_towards(user, targeted_turf) //This does not try to go around obstacles.
		if(!success)
			success = step_to(user, targeted_turf) //this does
		if(!success)
			if(++consequetive_failures >= 3) //if 3 steps don't work
				break //just stop
		else
			consequetive_failures = 0
		if(user.incapacitated(ignore_restraints = TRUE, ignore_grab = TRUE)) //actually down? stop.
			break
		if(success) //don't sleep if we failed to move.
			sleep(speed)
	UnregisterSignal(user, COMSIG_MOVABLE_BUMP)
	hit = null

/datum/action/innate/zombie/charge/proc/Obliterate(mob/living/zource, atom/affected)
	if(isliving(affected))
		var/mob/living/L = affected
		zource.do_attack_animation(target, ATTACK_EFFECT_SMASH)
		L.adjustBruteLoss(30)
		L.throw_at((get_ranged_target_turf(L, get_dir(zource, L), 10)), 10, TRUE, zource)
	if(isobj(affected))
		var/obj/O = affected
		if(istype(affected, /obj/machinery/door))
			var/obj/machinery/door/D = O
			if(!D.open())
				D.obj_break(BRUTE)
		if(O.density)
			O.obj_break(BRUTE)
	if(iswallturf(affected))
		var/turf/closed/wall/W
		W.dismantle_wall(1)

/////////////////||\\\\\\\\\\\\\\\\\
////							\\\\
////	PURCHASABLE ABILITIES	\\\\
////							\\\\
////\\\\\\\\\\\\\||/////////////\\\\

/datum/action/innate/zombie/jab
	name = "Quick Jab"
	desc = "Jab."
	button_icon_state = "jab"
	ability_type = ZOMBIE_FIREABLE
	cooldown = 15 SECONDS
	range = 1

/datum/action/innate/zombie/jab/IsTargetable(atom/target_atom)
	return iswallturf(target_atom) || isliving(target_atom) || isstructure(target_atom) || ismachinery(target_atom)

//code\modules\antagonists\bloodsuckers\powers\targeted\brawn.dm
/datum/action/innate/zombie/jab/UseFireableAbility(atom/target_atom)
	. = ..()
	var/mob/living/user = owner
	// Target Type: Mob
	if(isliving(target_atom))
		var/mob/living/target = target_atom
		var/mob/living/carbon/carbonuser = user
		var/hitStrength = carbonuser.dna.species.punchdamagehigh * 1.25 + 2
		// Knockdown!
		target.visible_message(
			span_danger("[user] lands a vicious punch, sending [target] away!"), \
			span_userdanger("[user] has landed a horrifying punch on you, sending you flying!"),
		)
		target.Knockdown(10 SECONDS)
		// Attack!
		to_chat(owner, span_warning("You punch [target]!"))
		playsound(get_turf(target), 'sound/weapons/punch4.ogg', 60, TRUE, -1)
		user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(target.zone_selected))
		target.apply_damage(hitStrength, BRUTE, affecting)
		// Knockback
		var/send_dir = get_dir(owner, target)
		var/turf/turf_thrown_at = get_ranged_target_turf(target, send_dir, 5)
		owner.newtonian_move(send_dir) // Bounce back in 0 G
		target.throw_at(turf_thrown_at, 5, TRUE, owner)
		// Target Type: Cyborg (Also gets the effects above)
		if(issilicon(target))
			target.emp_act(EMP_HEAVY)
		playsound(get_turf(user), 'sound/effects/grillehit.ogg', 80, TRUE, -1)
	// Target Type: Wall
	if(iswallturf(target_atom))
		var/turf/closed/wall/the_wall = target_atom
		var/time_to_open = 1.5 SECONDS
		if(istype(the_wall, /turf/closed/wall/r_wall))
			time_to_open = 2.5 SECONDS
		to_chat(owner, span_warning("You prepare to tear down [the_wall]..."))
		if(!do_mob(user, the_wall, time_to_open))
			return FALSE
		if(the_wall.Adjacent(user))
			the_wall.visible_message(span_danger("[the_wall] breaks into ruble as [user] bashes it!"))
			user.do_attack_animation(the_wall, ATTACK_EFFECT_SMASH)
			playsound(get_turf(the_wall), 'sound/effects/bang.ogg', 30, TRUE, -1)
			the_wall.dismantle_wall(1)