/obj/item/zombie_hand
	name = "zombie claw"
	desc = "A zombie's claw is its primary tool, capable of infecting \
		humans, butchering all other living things to \
		sustain the zombie, smashing open airlock doors and opening \
		child-safe caps on bottles."
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/obj/zombie.dmi'
	icon_state = "blood_hand_left"
	var/icon_left = "blood_hand_l"
	var/icon_right = "blood_hand_r"
	hitsound = 'sound/hallucinations/growl1.ogg'
	force = 21 // Just enough to break airlocks with melee attacks
	sharpness = SHARP_EDGED
	wound_bonus = -30
	bare_wound_bonus = 15
	damtype = BRUTE
	var/inserted_organ = /obj/item/organ/zombie_infection
	var/infect_chance = 100 //Before armor calculations
	var/scaled_infect_chance = FALSE //Does infection chance scale with damage? (100% of infect chance at 50% health(Crit, humans have 200% health!), 0% at max health)
	//Approx chances, with 100 infect_chance
	//20% at 40 damage
	//40% at 60 damage
	//70% at 80 damage
	//100% at 100 damage

/obj/item/zombie_hand/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/zombie_hand/equipped(mob/user, slot)
	. = ..()
	//these are intentionally inverted
	var/i = user.get_held_index_of_item(src)
	if(!(i % 2))
		icon_state = icon_left
	else
		icon_state = icon_right

/obj/item/zombie_hand/afterattack(atom/target, mob/user, proximity)
	. = ..()

	if(!proximity)
		return

	if(isliving(target))
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/flesh_wound = ran_zone(user.zone_selected)
			if(scaled_infect_chance)
				var/mob/living/mob_target = target
				var/total_damage = mob_target.get_damage_amount(BRUTE)

				var/infect_modifier = (total_damage ** 2) / 100

				infect_modifier = clamp(infect_modifier, 0, 100)

				if(prob(infect_modifier))
					if(prob(infect_chance - H.getarmor(flesh_wound, MELEE)))
						if(!H.stat)
							try_to_zombie_infect(target, inserted_organ)

			else
				if(prob(infect_chance - H.getarmor(flesh_wound, MELEE)))
					try_to_zombie_infect(target, inserted_organ)
		else
			check_feast(target, user)

/proc/try_to_zombie_infect(mob/living/carbon/human/target, organ)
	CHECK_DNA_AND_SPECIES(target)

	if(NOZOMBIE in target.dna.species.species_traits)
		// cannot infect any NOZOMBIE subspecies (such as high functioning zombies)
		return

	var/obj/item/organ/zombie_infection/infection
	infection = target.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(!infection)
		infection = new organ()
		infection.Insert(target)

/obj/item/zombie_hand/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is ripping [user.p_their()] brains out! It looks like [user.p_theyre()] trying to commit suicide!"))
	if(isliving(user))
		var/mob/living/L = user
		var/obj/item/bodypart/O = L.get_bodypart(BODY_ZONE_HEAD)
		if(O)
			O.dismember()
	return (BRUTELOSS)

/obj/item/zombie_hand/proc/check_feast(mob/living/target, mob/living/user)
	if(target.stat == DEAD)
		var/hp_gained = target.maxHealth
		target.gib()
		// zero as argument for no instant health update
		user.adjustBruteLoss(-hp_gained, 0)
		user.adjustToxLoss(-hp_gained, 0)
		user.adjustFireLoss(-hp_gained, 0)
		user.adjustCloneLoss(-hp_gained, 0)
		user.updatehealth()
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -hp_gained) // Zom Bee gibbers "BRAAAAISNSs!1!"
		user.set_nutrition(min(user.nutrition + hp_gained, NUTRITION_LEVEL_FULL))

/obj/item/zombie_hand/gamemode
	inserted_organ = /obj/item/organ/zombie_infection/gamemode
	infect_chance = 70
	scaled_infect_chance = TRUE
	force = 15
	var/door_open_modifier = 1

/obj/item/zombie_hand/gamemode/runner
	force = 10
	infect_chance = 35
	door_open_modifier = 1.1

/obj/item/zombie_hand/gamemode/tank // /obj/item/melee/flesh_maul
	name = "zombie maul"
	desc = "A horrifying mass of pulsing flesh and glistening bone. More than capable of crushing anyone unfortunate enough to be hit by it."
	icon_state = "jugger_hand"
	icon_left = "jugger_hand"
	icon_right = "jugger_stub"
	lefthand_file = 'icons/mob/inhands/antag/zombie_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/zombie_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	tool_behaviour = TOOL_MINING
	weapon_stats = list(SWING_SPEED = 2, ENCUMBRANCE = 1, ENCUMBRANCE_TIME = 20, REACH = 1, DAMAGE_LOW = 0, DAMAGE_HIGH = 0)
	force = 30
	armour_penetration = -20
	wound_bonus = 30
	hitsound = "swing_hit"
	attack_verb = list("smashed", "slammed", "crushed", "whacked")
	sharpness = SHARP_NONE
	var/is_stub = FALSE
	var/defensive_mode = FALSE
	door_open_modifier = 0.5

/obj/item/zombie_hand/gamemode/tank/equipped(mob/user)
	. = ..()
	var/i = user.get_held_index_of_item(src)
	if(!(i % 2))
		return
	var/obj/item/zombie_hand/gamemode/tank/stub = src
	stub.is_stub = TRUE
	stub.force = 5
	stub.armour_penetration = 30
	stub.weapon_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 1, DAMAGE_LOW = 0, DAMAGE_HIGH = 0)
	stub.w_class = WEIGHT_CLASS_SMALL
	stub.tool_behaviour = NONE

/obj/item/zombie_hand/gamemode/tank/afterattack(atom/target, mob/user, proximity)	
	. = ..()
	if(!proximity)
		return
	
	if(is_stub)
		return

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.add_movespeed_modifier("zombie maul", update = TRUE, priority = 101, multiplicative_slowdown = 1)
		addtimer(CALLBACK(C, /mob.proc/remove_movespeed_modifier, "zombie maul"), 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)	
		to_chat(target, span_danger("You are staggered from the blow!"))

	if(iscyborg(target))
		var/mob/living/silicon/robot/R = target
		R.Paralyze(1 SECONDS)

	if(isstructure(target) || ismachinery(target))	
		var/obj/structure/S = target
		var/structure_damage = S.max_integrity		
		var/make_sound = TRUE
		if(istype(target, /obj/structure/window) || istype(target, /obj/structure/grille))
			structure_damage *= 2
			make_sound = FALSE
		if(ismachinery(target) || istype(target, /obj/structure/door_assembly))
			structure_damage *= 0.5
		if(istype(target, /obj/machinery/door/airlock))
			structure_damage = 29
		if(istype(target, /obj/structure/table))
			var/obj/structure/table/T = target
			T.deconstruct(FALSE)
			return
		if(!isnull(target))
			S.take_damage(structure_damage, BRUTE, MELEE, FALSE)
		if(make_sound)
			playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/item/zombie_hand/gamemode/tank/attack_self(mob/user)
	. = ..()
	if(is_stub)
		return

	var/mob/living/carbon/human/zombie = user
	var/datum/antagonist/zombie/zombie_owner = user.mind?.has_antag_datum(/datum/antagonist/zombie)
	defensive_mode = !defensive_mode
	if(defensive_mode)
		var/damage_mod = 0.75
		if(locate("strong_arm") in zombie_owner.zombie_abilities)
			damage_mod = 0.6
		zombie.physiology.brute_mod = damage_mod
		zombie.physiology.burn_mod = damage_mod
		zombie.add_movespeed_modifier("zombie defense", update = TRUE, priority = 101, multiplicative_slowdown = 1)
	else
		zombie.physiology.brute_mod = initial(zombie.physiology.brute_mod)	
		zombie.physiology.burn_mod = initial(zombie.physiology.burn_mod)
		zombie.remove_movespeed_modifier("zombie defense")
	update_icon()

/obj/item/zombie_hand/gamemode/tank/update_icon()
	if(is_stub)
		return
	icon_state = defensive_mode ? "jugger_hand_d" : initial(icon_state)

/obj/effect/ebeam/smokertongue
	name = "rotten tongue"
	mouse_opacity = MOUSE_OPACITY_ICON
	desc = "A gross, slimy tongue. It's sticky to the touch."

/obj/effect/ebeam/smokertongue/stickier/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/L = AM
		L.Paralyze(1 SECONDS)

/obj/effect/ebeam/smokertongue/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/L = AM			
		if(isinfectedzombie(L))
			return
		L.Paralyze(1.5 SECONDS)
		to_chat(L, span_warning("You get caught in the smoker's tongue!"))

/obj/item/zombie_hand/gamemode/smoker
	desc = "The smoker's claw has an unique ability to incapacitate targets, \
		clicking on a far away mob will tongue them and bring them closer to you slowly. \
		You can't damage someone until you fully incapacitate then, \
		but you deal more damage and can quickly tear someone down."
	force = 25
	var/datum/beam/tongue = null
	var/tongue_range = 6
	var/obj/item/zombie_hand/gamemode/smoker/sister_hand = null

/obj/item/zombie_hand/gamemode/smoker/Initialize()
	. = ..()
	for(var/obj/item/zombie_hand/gamemode/smoker/S in loc)
		if(S != src)
			sister_hand = S
			S.sister_hand = src

/obj/item/zombie_hand/gamemode/smoker/attack(mob/living/target, mob/living/user)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.getStaminaLoss() >= 100)
			damtype = BRUTE
		else
			damtype = STAMINA //choke them out	
	. = ..()

/obj/item/zombie_hand/gamemode/smoker/afterattack(atom/target, mob/user, proximity)	
	if(proximity || tongue)
		return ..()
	if(iscarbon(target))
		var/datum/antagonist/zombie/zombie_owner = user?.mind?.has_antag_datum(/datum/antagonist/zombie)
		if(locate("big_tongue") in zombie_owner.zombie_mutations)
			tongue_range = initial(tongue_range) + 2
		tongue = user.Beam(target, "smokertongue", time = INFINITY, maxdistance = tongue_range, beam_type = \
			(locate("stickier_tongue") in zombie_owner.zombie_mutations) ? /obj/effect/ebeam/smokertongue/stickier : /obj/effect/ebeam/smokertongue)
		sister_hand?.tongue = TRUE //only one tongue!
		RegisterSignal(user, COMSIG_LIVING_BIOLOGICAL_LIFE, .proc/pull_tongue_to)
		RegisterSignal(tongue, COMSIG_PARENT_QDELETING, .proc/nullify)

/obj/item/zombie_hand/gamemode/smoker/proc/pull_tongue_to()
	if(tongue?.target && tongue?.origin)
		if(istype(tongue.target, /atom/movable))
			var/atom/movable/AM = tongue.target
			if(!AM.anchored)
				step(AM, get_dir(AM, tongue.origin))
		if(!get_dist(tongue.origin, tongue.target))
			QDEL_NULL(tongue)
	else
		QDEL_NULL(tongue)

/obj/item/zombie_hand/gamemode/smoker/proc/nullify()
	QDEL_NULL(tongue)

/obj/item/zombie_hand/gamemode/spitter
	desc = "A zombie's claw is its primary tool, capable of infecting \
		humans, butchering all other living things to \
		sustain the zombie, smashing open airlock doors and opening \
		child-safe caps on bottles."
	icon_state = "spitter_hand_l_on"
	icon_left = "spitter_hand_l_on"
	icon_right = "spitter_hand_r_on"
	COOLDOWN_DECLARE(acid_splatter_cooldown)
	var/cooldown = 30 SECONDS

/obj/item/zombie_hand/gamemode/spitter/examine()
	. = ..()
	. += COOLDOWN_FINISHED(src, acid_splatter_cooldown) ? span_notice("It is dripping with acid!") : span_warning("Requires [COOLDOWN_TIMELEFT(src, acid_splatter_cooldown) / 10] more seconds to refill.")

/obj/item/zombie_hand/gamemode/spitter/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(!COOLDOWN_FINISHED(src, acid_splatter_cooldown))
		return

	if(isclosedturf(target) || isobj(target))
		var/list/acid_ratio_to_use = list(250, 150)
		var/datum/antagonist/zombie/zombie_owner = user.mind?.has_antag_datum(/datum/antagonist/zombie)
		if(locate("stronger_acid") in zombie_owner.zombie_mutations)
			acid_ratio_to_use = list(300, 200)
		if(!target.acid_act(acid_ratio_to_use))
			to_chat(user, span_warning("You can't dissolve [target]."))
			return
		user.visible_message(span_danger("[user] smears acid onto [target], causing it to melt!"))
		COOLDOWN_START(src, acid_splatter_cooldown, cooldown)
		addtimer(CALLBACK(src, .proc/on_cooldown_end, user), cooldown)
		update_icon(user)

/obj/item/zombie_hand/gamemode/spitter/update_icon(mob/user)
	var/i = user.get_held_index_of_item(src)
	if(!(i % 2))
		icon_state = acid_splatter_cooldown <= world.time ? initial(icon_left) : "spitter_hand_l"
	else
		icon_state = acid_splatter_cooldown <= world.time ? initial(icon_right) : "spitter_hand_r"

/obj/item/zombie_hand/gamemode/spitter/proc/on_cooldown_end(mob/user)
	update_icon(user)
	to_chat(user, span_notice("Acid drips down your fingertips, you are ready to melt something again!"))