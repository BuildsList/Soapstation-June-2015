/obj/effect/electrical_field
	name = "small electric field"
	icon = 'icons/rust.dmi'
	icon_state = "emfield_s1"
	pixel_x = 0
	pixel_y = 0
	var/last_x = -1
	var/last_y = -1

/obj/effect/electrical_field/proc/process_field()
	if(last_x == -1 && last_y == -1)
		last_x = x
		last_y = y

	if(last_x != x || last_y != y)
		del(src)

	for(var/mob/M in loc.contents)
		shock(M, 4) //more condensed or somethin' -DrBrock

/obj/effect/electrical_field/proc/shock(var/mob/M, var/damage = 2.5)
	for(var/datum/reagent/phororeagent/R in M.reagents.reagent_list)
		if(R.id == "fulguracin")
			if(prob(20))
				M << "\blue Your hairs stand up, but you resist the shock for the most part"
			return //no shock for you
	var/isHuman = istype(M, /mob/living/carbon/human)
	if(isHuman)
		var/mob/living/carbon/human/H = M
		H.apply_effect(10, STUN, 0)
		H.apply_effect(10, WEAKEN, 0)
		H.apply_effect(10, STUTTER, 0)
		H.take_overall_damage(0, damage) //has to be high or they just heal it away instantly
		H.jitteriness = 140
		if(!H.is_jittery)
			spawn(0)
				H.jittery_process()
	else
		M.Stun(10)

	if(!isHuman && istype(M, /mob/living)) //should be guaranteed, making a check anyway
		var/mob/living/L = M
		L.apply_damage(3, BURN)

/obj/effect/electrical_field/big
	name = "large electric field"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "emfield_s3"
	pixel_x = -32
	pixel_y = -32

/obj/effect/electrical_field/big/process_field()
	if(last_x == -1 && last_y == -1)
		last_x = x
		last_y = y

	if(last_x != x || last_y != y)
		del(src)

	var/turf/T = null
	for(var/i = src.x - 1 to src.x + 1)
		for(var/j = src.y - 1 to src.y + 1)
			T = locate(i, j, z)
			for(var/mob/M in T.contents) //only the middle X 9
				shock(M)

/*/obj/effect/electrical_field/New()
	..()
	spawn(50)
		del(src)*/