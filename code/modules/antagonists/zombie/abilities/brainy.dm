/mob/living/simple_animal/horror/brainy
	name = "stupid bloody spies"
	desc = "sex"
	icon_state = "horror"
	icon_living = "horror"
	icon_dead = "horror_dead"
	icon_gib = "horror_gib"
	health = 100
	maxHealth = 100
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_in_dark = 10
	pass_flags = PASSTABLE | PASSGRILLE
	abilities_to_give = list(/datum/action/innate/horror/mutate, /datum/action/innate/horror/seek_soul, /datum/action/innate/horror/consume_soul,
	/datum/action/innate/horror/talk_to_host, /datum/action/innate/horror/freeze_victim, /datum/action/innate/horror/toggle_hide, /datum/action/innate/horror/talk_to_brain,
	/datum/action/innate/horror/take_control, /datum/action/innate/horror/leave_body, /datum/action/innate/horror/make_chems, /datum/action/innate/horror/give_back_control)

	var/datum/antagonist/zombie/zombie_owner

/mob/living/simple_animal/horror/brainy/Initialize()
	. = ..()
	real_name = initial(real_name)