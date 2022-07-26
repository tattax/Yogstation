//this is mostly kind of bloodsucker abilities code since the base for powers there works very well
#define ZOMBIE_TOGGLEABLE "toggleable" //self explainable
#define ZOMBIE_FIREABLE "fireable" //same as above
#define ZOMBIE_INSTANT "instant" //if you make this put . = ..() below it on Activate()

/datum/action/innate/zombie
	name = "Putrid"
	desc = "make a bug report if you see this."
	background_icon_state = "bg_zombie"
	icon_icon = 'icons/mob/actions/actions_zombie.dmi'
	button_icon_state = ""
	buttontooltipstyle = "cult"
	COOLDOWN_DECLARE(zombie_ability_cooldown)
	var/obj/effect/proc_holder/zombie/zombie_ph //i hate proc_holders i hate proc_holders
	var/ability_type = null
	var/cooldown = 0
	var/fireable_power_usable = FALSE
	var/range = 99
	var/custom_mouse_icon = null

/datum/action/innate/zombie/New()
	. = ..()
	if(ability_type == ZOMBIE_FIREABLE)
		zombie_ph = new()
		zombie_ph.linked_power = src

/datum/action/innate/zombie/Grant(mob/M)
	if(isinfected(M))
		var/datum/antagonist/zombie/zombie_owner = M.mind?.has_antag_datum(/datum/antagonist/zombie)
		zombie_owner.zombie_abilities += src
	. = ..()

/datum/action/innate/zombie/Remove(mob/M)
	if(isinfected(M))
		var/datum/antagonist/zombie/zombie_owner = M.mind?.has_antag_datum(/datum/antagonist/zombie)
		zombie_owner.zombie_abilities -= src
	. = ..()

/datum/action/innate/zombie/Destroy()
	if(active)
		STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/datum/action/innate/zombie/Trigger()
	if(!..())
		return FALSE

	if(ability_type == ZOMBIE_FIREABLE)
		var/mob/living/user = owner
		if(user.ranged_ability)
			user.ranged_ability.remove_ranged_ability()
		zombie_ph.add_ranged_ability(user)
	UpdateButtonIcon()
	return TRUE

/datum/action/innate/zombie/IsAvailable()
	if(!COOLDOWN_FINISHED(src, zombie_ability_cooldown))
		return FALSE
	if(!isinfected(owner))
		return FALSE
	. = ..()	

/datum/action/innate/zombie/Activate()
	switch(ability_type)
		if(ZOMBIE_TOGGLEABLE)
			START_PROCESSING(SSfastprocess, src)
		if(ZOMBIE_FIREABLE)
			fireable_power_usable = TRUE
			check_flags += AB_CHECK_CONSCIOUS
			owner?.client?.mouse_override_icon = custom_mouse_icon
		if(ZOMBIE_INSTANT)
			Deactivate()
			return
	active = TRUE

/datum/action/innate/zombie/Deactivate(forced = FALSE)
	switch(ability_type)
		if(ZOMBIE_TOGGLEABLE)
			STOP_PROCESSING(SSfastprocess, src)
		if(ZOMBIE_FIREABLE)
			zombie_ph.remove_ranged_ability()
			fireable_power_usable = FALSE
	active = FALSE
	owner?.client?.mouse_override_icon = null
	owner?.update_mouse_pointer()
	UpdateButtonIcon()
	if(!forced && ability_type == ZOMBIE_FIREABLE)
		return
	StartCooldown()

/datum/action/innate/zombie/proc/StartCooldown()
	button.color = rgb(128,0,0,128)
	button.alpha = 100
	COOLDOWN_START(src, zombie_ability_cooldown, cooldown)
	addtimer(CALLBACK(src, .proc/alpha_in), cooldown)

/datum/action/innate/zombie/proc/alpha_in()
	button.color = rgb(255,255,255,255)
	button.alpha = 255

/datum/action/innate/zombie/UpdateButtonIcon()
	background_icon_state = active ? initial(background_icon_state) + "_on" : initial(background_icon_state)
	. = ..()

/datum/action/innate/zombie/proc/IsTargetable(atom/target_atom)
	if(!(target_atom in view(range, owner)))
		if(range > 1)
			to_chat(owner, span_warning("Target out of range."))
		return FALSE
	return istype(target_atom)

/datum/action/innate/zombie/proc/StartFiringAbility(atom/target_atom) //where we do initial checks and end
	if(target_atom == owner)
		return

	if(!fireable_power_usable)
		return

	if(!IsTargetable(target_atom))
		return

	UseFireableAbility(target_atom)
	Deactivate(TRUE)

/datum/action/innate/zombie/proc/UseFireableAbility(atom/target_atom)
	log_combat(owner, target_atom, "used zombie ability [name] on")
	
/obj/effect/proc_holder/zombie
	var/datum/action/innate/zombie/linked_power

/obj/effect/proc_holder/zombie/InterceptClickOn(mob/living/caller, params, atom/targeted_atom)
	return linked_power.StartFiringAbility(targeted_atom)

///Default abilities that all roundstart special zombies get. They need use infection points to be used and provide a significant bonus.
/datum/action/innate/zombie/default
	var/cost = 0
	var/constant_cost = 0

/datum/action/innate/zombie/default/IsAvailable()
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(zombie_owner.infection < cost)
		return FALSE
	. = ..()

/datum/action/innate/zombie/default/Activate()
	if(ability_type == ZOMBIE_TOGGLEABLE || ability_type == ZOMBIE_INSTANT)
		var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
		if(locate("reduced_cost") in zombie_owner.zombie_mutations)
			cost = initial(cost) / 2
		if(!zombie_owner.use_infection(cost, "You don't have enough infection points to activate this ability!")) //failsafe
			return
	. = ..()

/datum/action/innate/zombie/default/UseFireableAbility()
	. = ..()
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(!zombie_owner.use_infection(cost, "You don't have enough infection points to activate this ability!"))
		Deactivate()
		return

/datum/action/innate/zombie/default/process()
	UpdateButtonIcon()
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(!zombie_owner.use_infection(constant_cost, "You don't have enough infection points to maintain this ability active!"))
		Deactivate()
		return

/datum/action/innate/zombie/menu
	name = "Menu"
	desc = ""
	button_icon_state = "adaptation_menu"
	ability_type = ZOMBIE_INSTANT

/datum/action/innate/zombie/menu/Activate()
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	zombie_owner.ui_interact(owner)
	. = ..()

/datum/action/innate/zombie/zomb
	name = "Zombify!"
	desc = "Initiate the infection, and kill this host.. THIS ACTION IS INSTANT."
	button_icon_state = "zombify"
	ability_type = ZOMBIE_INSTANT

/datum/action/innate/zombie/zomb/Activate(forced = FALSE)
	var/mob/living/carbon/human/H = owner
	var/datum/antagonist/zombie/Z = H.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(!forced)
		if(alert(H, "Are you sure you want to kill yourself, and revive as a zombie some time after?", "Confirmation", "Yes", "No") == "No")
			return FALSE

	if(!H.getorganslot(ORGAN_SLOT_ZOMBIE))
		var/obj/item/organ/zombie_infection/gamemode/special/ZI = new()
		ZI.Insert(H)

	H.mind?.zombified = TRUE
	H.death()
	Z.zombify.Remove(H)
	Z.zombified = TRUE
	Z.uncuff.Grant(H)
	Z.evolutionTime = TIER_2_TIME + world.time
	Z.start_evolution_2()
	. = ..()

/datum/action/innate/zombie/talk
	name = "Chat"
	desc = "Chat with your fellow infected."
	button_icon_state = "zombie_comms"

/datum/action/innate/zombie/talk/Activate()
	var/input = stripped_input(usr, "Please choose a message to tell to the other zombies.", "Infected Communications", "")
	if(!input || !IsAvailable())
		return

	talk(usr, input)

/datum/action/innate/zombie/talk/proc/talk(mob/living/user, message)
	var/my_message
	if(!message)
		return
	my_message = span_cult("<font size = 2>Zombie [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]: [message]</font>")
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(isinfected(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="zombie")

/datum/action/innate/zombie/choose_class
	name = "Evolve"
	desc = "Evolve into a special class."
	button_icon_state = "evolve"
	ability_type = ZOMBIE_INSTANT

/datum/action/innate/zombie/choose_class/Activate()
	var/selected = input(usr, "Choose a class to evolve into", "Evolution") as null|anything in list(SMOKER, RUNNER, SPITTER, JUGGERNAUT, BRAINY)
	if(!selected || !IsAvailable())
		return
	if(!isinfectedzombie(owner))
		return
	evolve(selected)
	. = ..()

/datum/action/innate/zombie/choose_class/IsAvailable(forced = FALSE)
	if(!isinfected(owner))
		return
	var/datum/antagonist/zombie/Z = locate() in owner.mind.antag_datums

	if(Z.class_chosen && !forced)
		return FALSE
	return ..()

/datum/action/innate/zombie/choose_class/proc/evolve(class)
	var/mob/living/carbon/human/H = owner
	var/datum/antagonist/zombie/Z = owner?.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(!isinfected(H))
		return
	switch(class)
		if(SMOKER)
			var/datum/action/innate/zombie/default/smoke/Sm = new()
			var/datum/action/innate/zombie/scorch/Sc = new()
			Sm.Grant(H)
			Sc.Grant(H)
			H.set_species(/datum/species/zombie/infectious/gamemode/smoker)
		if(RUNNER)
			var/datum/action/innate/zombie/default/bolt/Bt = new()
			var/datum/action/innate/zombie/parkour/Pk = new()
			Bt.Grant(H)
			Pk.Grant(H)
			H.set_species(/datum/species/zombie/infectious/gamemode/runner)
			to_chat(owner, span_warning("You can now run, and your movement speed is considerably faster. You do less damage and can take less damage though."))
		if(SPITTER)
			var/datum/action/innate/zombie/default/spit/Sp = new()
			var/datum/action/innate/zombie/default/overclock/Ov = new()
			Sp.Grant(H)
			Ov.Grant(H)
			H.set_species(/datum/species/zombie/infectious/gamemode/spitter)
			to_chat(owner, span_warning("You can now right click on walls and doors, and cover them in acid! You are weaker in combat though."))
		if(JUGGERNAUT)
			var/datum/action/innate/zombie/charge/C = new()
			var/datum/action/innate/zombie/default/rage/R = new()
			H.set_species(/datum/species/zombie/infectious/gamemode/juggernaut)
			R.Grant(H)
			C.Grant(H)
			to_chat(owner, span_warning("You can now take quite a beating, and heal a bit slower."))
	//	if(BRAINY)
		//	var/mob/living/simple_animal/brainy/B = new /mob/living/simple_animal/brainy(get_turf(owner))
		//	qdel(owner)
		//	owner.mind.transfer_to(B)

	owner.visible_message(span_danger("[owner] suddenly convulses, as [owner.p_they()] evolve into a [class]!"), span_alien("You have evolved into a [class]"))
	playsound(owner.loc, 'sound/hallucinations/far_noise.ogg', 50, TRUE)
	H.do_jitter_animation(15)
	Z.evolution.Remove(H)
	Z.class_chosen = class

/datum/action/innate/zombie/choose_class/tier2
	name = "Evolve - Tier 2"
	desc = "Evolve into a Tier 2 special class."

/datum/action/innate/zombie/choose_class/tier2/IsAvailable()
	if(!isinfected(owner))
		return
	var/datum/antagonist/zombie/Z = locate() in owner.mind.antag_datums

	if(Z.class_chosen_2)
		return FALSE

	if(!Z.class_chosen)
		return FALSE
	return ..(TRUE)

/datum/action/innate/zombie/choose_class/tier2/Activate()
	var/selected = input(usr, "Choose a class to evolve into", "Evolution") as null|anything in list("Necromancer")
	if(!selected || !IsAvailable())
		return
	if(!isinfectedzombie(owner))
		return

	var/datum/game_mode/zombie/mode = SSticker.mode
	if(!mode.can_evolve_tier_2())
		to_chat(usr, span_userdanger("There are currently too many tier 2 zombies. Please wait."))
		return
	evolve(selected)

/datum/action/innate/zombie/choose_class/tier2/evolve(class)
	var/mob/living/carbon/human/H = owner
	var/datum/antagonist/zombie/Z = locate() in owner.mind.antag_datums
	if(!isinfected(H))
		return
	switch(class)
		if("Necromancer")
			H.set_species(/datum/species/zombie/infectious/gamemode/necromancer)
			//Z.necro = new()
			//H.AddAbility(Z.necro)
			to_chat(owner, span_warning("You can now run, and your movement speed is considerably faster. You do less damage and can take less damage though."))
		if("Coordinator")
			H.set_species(/datum/species/zombie/infectious/gamemode/coordinator)
			to_chat(owner, span_warning("You can now communicate with the horde!"))


	owner.visible_message(span_danger("[owner] suddenly convulses, as [owner.p_they()] evolve into a [class]!"), span_alien("You have evolved into a [class]"))
	playsound(owner.loc, 'sound/hallucinations/far_noise.ogg', 50, 1)
	H.do_jitter_animation(15)
	Z.evolution2.Remove(H)
	Z.class_chosen_2 = TRUE