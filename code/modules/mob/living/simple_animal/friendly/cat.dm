//Cat
/mob/living/simple_animal/cat
	name = "cat"
	desc = "A domesticated, feline pet. Has a tendency to adopt crewmembers."
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	speak = list("Meow!","Esp!","Purr!","HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows","mews")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	holder_type = /obj/item/weapon/holder/cat

/mob/living/simple_animal/cat/Life()
	//MICE!
	if((src.loc) && isturf(src.loc))
		if(!stat && !resting && !buckled)
			for(var/mob/living/simple_animal/mouse/M in view(1,src))
				if(!M.stat)
					M.splat()
					emote(pick("\red splats the [M]!","\red toys with the [M]","worries the [M]"))
					movement_target = null
					stop_automated_movement = 0
					break

	..()

	for(var/mob/living/simple_animal/mouse/snack in oview(src, 3))
		if(prob(15))
			emote(pick("hisses and spits!","mrowls fiercely!","eyes [snack] hungrily."))
		break

	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/mob/living/simple_animal/mouse/snack in oview(src,3))
					if(isturf(snack.loc) && !snack.stat)
						movement_target = snack
						break
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src,movement_target,0,3)


/mob/living/simple_animal/cat/MouseDrop(atom/over_object)

	var/mob/living/carbon/H = over_object
	if(!istype(H) || !Adjacent(H)) return ..()

	if(H.a_intent == "help")
		get_scooped(H)
		return
	else
		return ..()

//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/simple_animal/cat/Runtime
	name = "Runtime"
	desc = "Her fur has the look and feel of velvet, and her tail quivers occasionally."
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"

/mob/living/simple_animal/cat/kitten
	name = "kitten"
	desc = "D'aaawwww"
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	gender = NEUTER