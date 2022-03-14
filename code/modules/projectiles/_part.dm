#define GUNPART_BARREL "barrel_slot"
#define GUNPART_STOCK "stock_slot"
#define GUNPART_ACESSORY "acessory_slot"

/obj/item/gun_part
	name = "gun part"
	desc = "Something tells you you aren't supposed to see this and that you should make a bug report about how you got this, whatever the hell that is."
	icon = 'icons/obj/guns/gun_mods.dmi'
	icon_state = "base"
	item_state = "base"
	w_class = WEIGHT_CLASS_TINY
	var/obj/item/gun/gun					//The holder of this part
	var/atom/movable/physical				//The item to get the name and icon from, mainly used for pseudo parts
	var/sound/install_sound					//The sound that plays when this is installed
	var/part_slot							//Slot that this part takes
	var/mutable_appearance/on_gun_overlay	//Overlay that is applied to the gun when attached
	var/on_gun_icon							//Slot that this part takes
	var/on_gun_icon_state					//Slot that this part takes
	var/removable							//If this part can be removed by normal means
	var/x_offset = 0						//Added to the guns X offset for the part slot
	var/y_offset = 0						//Added to the guns Y offset for the part slot

/obj/item/gun_part/New(newloc)
	..()
	if(istype(newloc, /obj/item/gun))
		gun_insert(newloc)

/obj/item/gun_part/Destroy()
	gun_remove()

/obj/item/gun_part/proc/gun_insert(obj/item/gun/G, forced = FALSE)
	if(!(part_slot in G.part_slots) || (!forced && (part_slot in G.locked_part_slots)) || !G.parts?[part_slot] == null)
		return FALSE
	G.parts |= list(part_slot = src)
	gun = G
	forceMove(G)
	return TRUE

/obj/item/gun_part/proc/gun_remove(forced = FALSE)
	if(!gun || !gun.parts?[part_slot] == src) // Doesn't matter if this is a forced removal as this shouldn't happen
		gun = null
		return TRUE
	if(!forced && (part_slot in gun.locked_part_slots || removable))
		return FALSE
	if(gun.parts?[part_slot] == src)
		gun.remove_parts(part_slot)
		gun = null
		return TRUE

/obj/item/gun_part/proc/try_insert(var/obj/item/I)
	return FALSE

/**
  * Adds some little stuff to the bottom of examine text, like part health or ammunition.
 */
/obj/item/gun_part/proc/gun_examine_extra()
	return

/**
  * For when the holder hits something.
 */
/obj/item/gun_part/proc/gun_attack(target, mob/user)
	return

/obj/item
	var/pseudo_gunpart					//The path of the pseudo gunpart, leave null if there isn't one
	var/pseudo_gunpart_icon_override	//An override for the pseudo gunpart's gun icon, leave null if there is none

/obj/item/gun_part/pseudo // Acts as a holder for a non-part item
	var/obj/item/original_item 			//The item this pseudo-part is representing

/obj/item/gun_part/pseudo/New(newloc, obj/item/original)
	..()
	if(original)
		original_item = original
		physical = original
		if(original.pseudo_gunpart_icon_override)
			on_gun_icon_state = original.pseudo_gunpart_icon_override
		original.forceMove(src)

/obj/item/gun_part/pseudo/gun_remove()
	if(..())
		qdel(src) // Don't want this to ever leave the gun