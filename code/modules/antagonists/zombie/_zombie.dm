#define TIER_2_TIME 7.5 MINUTES
#define SMOKER "Smoker"
#define RUNNER "Runner"
#define SPITTER "Spitter"
#define JUGGERNAUT "Juggernaut"
#define BRAINY "Brainy"

/datum/antagonist/zombie
	name = "Zombie"
	roundend_category = "zombies"
	antagpanel_category = "Zombie"

	var/datum/action/innate/zombie/zomb/zombify = new

	var/datum/action/innate/zombie/talk/talk_action = new

	var/datum/action/innate/zombie/menu/ui_interact = new

	var/datum/action/innate/zombie/choose_class/evolution = new

	var/datum/action/innate/zombie/choose_class/tier2/evolution2 = new

	//EVOLUTION
	var/evolutionTime = 0 //When can we evolve?

	//GENERAL ABILITIES
	var/datum/action/innate/zombie/uncuff/uncuff = new

	job_rank = ROLE_ZOMBIE

	var/datum/team/zombie/team
	var/hud_type = "zombie"

	var/class_chosen = null
	var/class_chosen_2 = FALSE

	var/zombified = FALSE

	var/mutation_rate = 0

	var/mutation_points = 0

	var/infection = 100

	var/infection_max = 100

	var/list/zombie_abilities = list()
	var/list/zombie_mutations = list()


/datum/antagonist/zombie/create_team(datum/team/zombie/new_team)
	if(!new_team)
		for(var/HU in GLOB.zombies)
			var/datum/antagonist/zombie/H = HU
			if(!H.owner)
				continue
			if(H.team)
				team = H.team
				return
		team = new /datum/team/zombie
		team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/zombie/proc/add_objectives()
	objectives |= team.objectives

/datum/antagonist/zombie/Destroy()
	QDEL_NULL(zombify)
	return ..()

/datum/antagonist/zombie/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You have been infected with a zombie virus! In 15 minutes you will be able to turn into a zombie...</font><B>")
	to_chat(owner.current, "<b>Use the button at the top of the screen (When it appears) to activate the infection. It will kill you, but you will rise as a zombie shortly after!<b>") //Yogs
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	owner.announce_objectives()

/datum/antagonist/zombie/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	add_objectives()
	GLOB.zombies += owner

	current.log_message("has been made a zombie!", LOG_ATTACK, color="#960000")

	var/datum/atom_hud/antag/zombie_hud = GLOB.huds[ANTAG_HUD_ZOMBIE]
	zombie_hud.join_hud(current)
	set_antag_hud(current, hud_type)
	owner.current.hud_used.infection_display.invisibility = 0
	update_infection_hud()

/datum/antagonist/zombie/on_removal()
	GLOB.zombies -= owner

	var/datum/atom_hud/antag/zombie_hud = GLOB.huds[ANTAG_HUD_ZOMBIE]
	zombie_hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)
	owner.current.hud_used.infection_display.invisibility = initial(owner.current.hud_used.infection_display.invisibility)
	owner.current.hud_used.infection_display.maptext = ""
	. = ..()

/datum/antagonist/zombie/apply_innate_effects()
	. = ..()
	var/mob/living/current = owner.current
	current.faction |= "zombies"
	ui_interact.Grant(current)
	talk_action.Grant(current)

/datum/antagonist/zombie/remove_innate_effects()
	. = ..()
	var/mob/living/current = owner.current
	current.faction -= "zombies"
	ui_interact.Remove(current)
	talk_action.Remove(current)

/datum/antagonist/zombie/proc/use_infection(amt, msg = "")
	if(infection < amt)
		to_chat(owner, span_warning(msg))
		return FALSE
	infection -= amt
	update_infection_hud()
	return TRUE

/datum/antagonist/zombie/proc/acquire_mutation(amt)
	mutation_points++

/datum/antagonist/zombie/proc/update_infection_hud()
	var/obj/screen/counter = owner?.current?.hud_used?.infection_display
	if(!counter)
		return
	if(class_chosen)
		counter.add_overlay("overlay_[class_chosen]")
	counter.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#E6E6C6'>[infection]</font></div>"

/datum/antagonist/zombie/ui_state(mob/user)
	return GLOB.always_state

/datum/antagonist/zombie/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EvolutionMenu", "Host Genetic Management")
		ui.open()

/datum/antagonist/zombie/ui_data(mob/user)
	var/list/data = list()
	var/list/abilities = list()
	var/list/mutations = list()
	data["name"] = user.real_name
	data["mutation_rate"] = mutation_rate
	data["mutation_points"] = mutation_points
	data["current_status"] = user.stat
	var/record_name = user.real_name
	if(istype(owner.current, /mob/living/simple_animal/horror/brainy))
		var/mob/living/simple_animal/horror/brainy/B
		record_name = B.victim
	for(var/datum/data/record/R in sortRecord(GLOB.data_core.general, record_name))
		data["host_picture"] = REF(R)

	for(var/datum/action/innate/zombie/ability_raw as anything in subtypesof(/datum/action/innate/zombie))
		var/list/ability_processed = list()
		ability_processed["type"] = initial(ability_raw.ability_type)
		ability_processed["name"] = initial(ability_raw.name)
		ability_processed["typepath"] = ability_raw
		ability_processed["desc"] = initial(ability_raw.desc)

		abilities += list(ability_processed)
	data["abilities"] += abilities

	for(var/datum/zombie_mutation/mutation_raw as anything in subtypesof(/datum/zombie_mutation))

		var/list/mutation_processed = list()
		mutation_processed["name"] = initial(mutation_raw.name)
		mutation_processed["id"] = initial(mutation_raw.id)
		mutation_processed["desc"] = initial(mutation_raw.desc)
		mutation_processed["sector"] = initial(mutation_raw.sector)
		mutation_processed["mutation_cost"] = initial(mutation_raw.mutation_cost)
		mutation_processed["owned"] = (locate(initial(mutation_raw.id)) in zombie_mutations)
		mutation_processed["can_purchase"] = !mutation_processed["owned"] && mutation_points >= initial(mutation_raw.mutation_cost)

		mutations += list(mutation_processed)

	data["mutations"] += mutations

	return data

/datum/antagonist/zombie/ui_act(action, params)
	if(..())
		return

/datum/antagonist/zombie/proc/start_timer()
	addtimer(CALLBACK(src, .proc/add_button_timed), 0.1 MINUTES)

/datum/antagonist/zombie/proc/add_button_timed()
	zombify.Grant(owner.current)
	to_chat(owner.current, span_userdanger("<b>You can now turn into a zombie! The ability INSTANTLY kills you, and starts the process of turning into a zombie. IN 5 MINUTES YOU WILL FORCIBLY BE ZOMBIFIED IF YOU HAVEN'T.<b>"))
	addtimer(CALLBACK(src, .proc/force_zombify), 5 MINUTES)

/datum/antagonist/zombie/proc/force_zombify()
	if(!zombified)
		zombify.Activate()

/datum/antagonist/zombie/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has zombied'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has zombied'ed [key_name(new_owner)].")
	start_timer()


/datum/antagonist/zombie/get_admin_commands()
	. = ..()
	.["Give Button"] = CALLBACK(src, .proc/admin_give_button)
	.["Remove Button"] = CALLBACK(src, .proc/remove_button)
	.["Give Mutation Points"] = CALLBACK(src, .proc/acquire_mutation, 1)

/datum/antagonist/zombie/proc/admin_give_button(mob/admin)
	zombify.Grant(owner.current)

/datum/antagonist/zombie/proc/remove_button(mob/admin)
	zombify.Remove(owner.current)

/datum/antagonist/zombie/proc/start_evolution_2()
	addtimer(CALLBACK(src, .proc/finish_evolution_2), TIER_2_TIME)

/datum/antagonist/zombie/proc/finish_evolution_2()
	evolution2.Grant(owner.current)
	to_chat(owner.current, span_userdanger("<b>You can now evolve into a Tier 2 zombie! There can only be tier 2 zombies equal to the amount of starting zombies!<b>"))

/datum/team/zombie
	name = "Zombies"

/datum/team/zombie/proc/setup_objectives()

	var/datum/objective/custom/obj = new()
	obj.name = "Escape on the shuttle, while gathering as many infected as possible!"
	obj.explanation_text = "Escape on the shuttle, while gathering as many infected as possible!"
	obj.completed = TRUE
	objectives += obj


/datum/team/zombie/proc/zombies_on_shuttle()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(isinfected(H) && (H.onCentCom() || H.onSyndieBase()))
			return TRUE
	return FALSE

/datum/team/zombie/roundend_report()
	var/list/parts = list()
	if(zombies_on_shuttle())
		parts += "<span class='greentext big'>BRAINS! The zombies have made it to CentCom!</span>"
	else
		parts += "<span class='redtext big'>Target destroyed. The crew has stopped the zombies!</span>"


	if(members.len)
		parts += span_header("The zombies were:")
		parts += printplayerlist(members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
