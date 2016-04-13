//Killer Penguins!!
/mob/living/simple_animal/hostile/penguin_hostile
	name = "Penguin"
	desc = "I think it's plotting something..."
	icon = 'icons/mob/penguin.dmi'
	icon_state = "penguin_hostile"
	icon_living = "penguin_hostile"
	icon_dead = "penguin_dead"
	icon_gib = ""
	speak = list("Death to humans!","For the emperor!","I want carp!")
	speak_emote = list("screams", "squawks")
	emote_hear = list("rawrs","grumbles","grawls")
	emote_see = list("stares ferociously", "flaps")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/cell/crap
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "pokes"
	stop_automated_movement_when_pulled = 0
	maxHealth = 1
	health = 1
	melee_damage_lower = 20
	melee_damage_upper = 30

/mob/living/simple_animal/hostile/penguin_hostile/proc/handle_environment(var/datum/gas_mixture/environment)
	if(!environment) return

	if(environment.temperature > (T0C+66))
		adjustFireLoss((environment.temperature - (T0C+66))/5) // Might be too high, check in testing.
		if (fire) fire.icon_state = "fire2"
		if(prob(20))
			src << "\red You feel a searing heat!"
	else
		if (fire) fire.icon_state = "fire0"


	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 350

	faction = "penguin"

	//Penguin Weakness
	heat_damage_per_tick = 120	//amount of damage applied if animal's body temperature is higher than maxbodytemp

/* Removing this because strange
mob/living/simple_animal/penguin_friendly/Process_Spacemove(var/check_drift = 0)
	return 1	//No drifting in space for space penguins!	//original comments do not steal
*/

/mob/living/simple_animal/hostile/penguin_hostile/strong_version_very_OP
	name = "Penguin"
	desc = "I think it's plotting something..."
	maxHealth = 120
	health = 120
