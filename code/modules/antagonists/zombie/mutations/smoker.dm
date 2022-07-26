/datum/zombie_mutation/class/tongue_range
	name = "Tongue Size"
	id = "big_tongue"
	desc = "Increases effective tongue range by 2."
	owner_class = SMOKER
	mutation_cost = 1

/datum/zombie_mutation/class/tongue_stun
	name = "Tongue Spikes"
	id = "stickier_tongue"
	desc = "Increases stun time by 1 second on non-targets interacting with the tongue."
	owner_class = SMOKER
	mutation_cost = 1

/datum/zombie_mutation/class/tongue_swing
	name = "Tongue Myocytes"
	id = "strong_tongue"
	desc = "Gain the Tongue Swing ability."
	owner_class = SMOKER
	mutation_cost = 2

/datum/zombie_mutation/class/tongue_swing/apply_effects()
	. = ..()
	var/datum/action/innate/zombie/swing/S = new
	S.Grant(zombie_owner.owner?.current)