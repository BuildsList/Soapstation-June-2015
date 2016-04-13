/mob/living/simple_animal/hostile/syndifox
	name = "Syndi-Cat"
	desc = "Death to Nanotransen. Yip."
	icon = 'icons/mob/newpets.dmi'
	icon_state = "Syndifox"
	icon_living = "Syndifox"
	icon_dead = "Syndifox_dead"
	speak_chance = 3
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "pushes aside"
	response_harm = "kicks"
	speak = list("YIP!?", "DEATH TO ALL HOOMANS!", "YIP!", "YAP!", "AWOOOOOOOO!", "YAP!?")
	emote_see = list("honks")
	a_intent = "harm"
	stop_automated_movement_when_pulled = 1
	maxHealth = 50
	health = 50
	speed = -1
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "clawed"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	var/weapon1
	var/weapon2

	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 270
	maxbodytemp = 370
	heat_damage_per_tick = 15	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	cold_damage_per_tick = 10	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	unsuitable_atoms_damage = 10



/mob/living/simple_animal/hostile/syndifox/weak_melee
	name = "Combat SyndiFox"

/mob/living/simple_animal/hostile/syndifox/weak_ranged
	name = "Ranged SyndiFox"
	attacktext = "shot lasers at"
	projectilesound = 'sound/weapons/laser.ogg'
	ranged = 1
	rapid = 1
	projectiletype = /obj/item/projectile/beam
	weapon1 = /obj/item/weapon/gun/energy/laser

/mob/living/simple_animal/hostile/syndifox/tough_melee
	name = "Combat SyndiFox"
	desc = "Death to Nanotransen. Yip. This one looks pretty tough..."
	maxHealth = 200
	health = 200
	stop_automated_movement_when_pulled = 0


/mob/living/simple_animal/hostile/syndifox/tough_ranged
	name = "Ranged SyndiFox"
	desc = "Death to Nanotransen. Yap. Wait a second, this one is shooting lasers!?"
	maxHealth = 200
	health = 200
	attacktext = "shot lasers at"
	projectilesound = 'sound/weapons/laser.ogg'
	ranged = 1
	rapid = 1
	projectiletype = /obj/item/projectile/beam
	weapon1 = /obj/item/weapon/gun/energy/laser