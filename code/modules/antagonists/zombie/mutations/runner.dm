/datum/zombie_mutation/class/leg_response
	name = "Harder Leg Tissue"
	id = "leg_response"
	desc = "Doubles your possible Parkour jumps."
	owner_class = RUNNER
	mutation_cost = 1

/datum/zombie_mutation/class/pick_pocket
	name = "Faster Neuron Response"
	id = "pick_pocket"
	desc = "Gain the Pickpocket ability."
	owner_class = RUNNER
	mutation_cost = 1

/datum/zombie_mutation/class/pick_pocket/apply_effects()
	. = ..()
	var/datum/action/innate/zombie/pickpocket/P = new
	P.Grant(zombie_owner.owner?.current)

/datum/zombie_mutation/class/better_reflexes
	name = "Better Brain Reaction"
	id = "better_reflexes"
	desc = "Bolt makes you immune to projectiles."
	owner_class = RUNNER
	mutation_cost = 2