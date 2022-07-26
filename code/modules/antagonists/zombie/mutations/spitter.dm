/datum/zombie_mutation/class/stronger_acid
	name = "Effecient Glands"
	id = "stronger_acid"
	desc = "Increases acid effectiveness on walls."
	owner_class = SPITTER
	mutation_cost = 1

/datum/zombie_mutation/class/bubble_blood
	name = "Effecient Glands"
	id = "stronger_acid"
	desc = "Increases acid effectiveness on walls."
	owner_class = SPITTER
	mutation_cost = 1

/datum/zombie_mutation/class/bubble_blood/apply_effects()
	. = ..()
	var/datum/action/innate/zombie/default/bubble/B = new
	B.Grant(zombie_owner.owner?.current)

/datum/zombie_mutation/class/acid_puke
	name = "Effecient Glands"
	id = "stronger_acid"
	desc = "Increases acid effectiveness on walls."
	owner_class = SPITTER
	mutation_cost = 2

/datum/zombie_mutation/class/acid_puke/apply_effects()
	. = ..()
	var/datum/action/innate/zombie/default/puke/P = new
	P.Grant(zombie_owner.owner?.current)