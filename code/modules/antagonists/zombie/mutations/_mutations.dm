///Upgrades for all classes.
#define SECTOR_COMMON "sector_common"
///Upgrades for a specific class.
#define SECTOR_CLASS "sector_class"
///Upgrades that fit under other conditions.
#define SECTOR_SPECIAL "sector_special"

/datum/zombie_mutation
	var/sector = SECTOR_COMMON
	var/name = "sse=wellpsl"
	var/id = ""
	var/desc = "make a bug report if you see this"
	var/mutation_cost = 0
	var/owned = FALSE
	var/datum/antagonist/zombie/zombie_owner

/*
* See darkspawn_upgrade.dm for these
*/
/datum/zombie_mutation/New(zombie_datum)
	..()
	zombie_owner = zombie_datum

/datum/zombie_mutation/proc/on_purchase()
	if(!zombie_owner)
		return
	apply_effects()
	qdel(src)
	return TRUE

/datum/zombie_mutation/proc/apply_effects()
	zombie_owner.zombie_mutations += id
	zombie_owner.mutation_rate++

/datum/zombie_mutation/class
	sector = SECTOR_CLASS
	var/owner_class = null

/datum/zombie_mutation/class/on_purchase()
	if(owner_class != zombie_owner.class_chosen)
		return
	. = ..()

/datum/zombie_mutation/additional_infection
	name = "Storage Glands"
	id = "additional_infection"
	desc = "Gain additional 20 max infection points."
	mutation_cost = 1

/datum/zombie_mutation/additional_infection/apply_effects()
	. = ..()
	zombie_owner.infection_max += 20
	zombie_owner.update_infection_hud() //just incase

/datum/zombie_mutation/less_infection_usage
	name = "Efficient Chemical Management"
	id = "reduced_cost"
	desc = "Halves the cost of infection points to use abilities."
	mutation_cost = 2
