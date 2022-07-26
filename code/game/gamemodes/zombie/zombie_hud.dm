/datum/hud
	var/obj/screen/zombie_infection/infection_display

/datum/hud/New(mob/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	. = ..()
	infection_display = new /obj/screen/zombie_infection

/datum/hud/human/New(mob/living/carbon/human/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	. = ..()
	infection_display = new /obj/screen/zombie_infection
	infodisplay += infection_display

/datum/hud/Destroy()
	. = ..()
	infection_display = null