/datum/zombie_mutation/class/strong_arm
	name = "Muscular Fibers"
	desc = "Increased damage resistence on defense mode."
	id = "strong_arm"
	owner_class = JUGGERNAUT
	mutation_cost = 1

/datum/zombie_mutation/class/jab
	name = "Neuron Repathing"
	desc = "Gain the Quick Jab ability."
	id = "quick_jab"
	owner_class = JUGGERNAUT
	mutation_cost = 1

/datum/zombie_mutation/class/jab/apply_effects()
	. = ..()
	var/datum/action/innate/zombie/jab/J = new
	J.Grant(zombie_owner.owner?.current)

/datum/zombie_mutation/class/increased_rage
	name = "Adapted Pain Receptors"
	desc = "Doubled Rage gain on damage."
	id = "increased_rage"
	owner_class = JUGGERNAUT
	mutation_cost = 2

/datum/zombie_mutation/class/increased_rage/apply_effects()
	. = ..()
	var/mob/living/carbon/human/user = zombie_owner.owner?.current
	var/datum/species/zombie/infectious/gamemode/juggernaut/jugg = user?.dna?.species
	jugg.infection_per_damage = 4