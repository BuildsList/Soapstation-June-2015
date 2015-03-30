//Corgi
/mob/living/simple_animal/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps","pants")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 10
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	meat_amount = 3
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	see_in_dark = 5
	mob_size = 8

	var/obj/item/inventory_head
	var/obj/item/inventory_back
	var/facehugger

//IAN! SQUEEEEEEEEE~
/mob/living/simple_animal/corgi/Ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	gender = MALE
	desc = "It's a corgi."
	var/turns_since_scan = 0
	var/obj/movement_target
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"

/mob/living/simple_animal/corgi/Ian/Life()
	..()

	//Feeding, chasing food, FOOOOODDDD
	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/obj/item/weapon/reagent_containers/food/snacks/S in oview(src,3))
					if(isturf(S.loc) || ishuman(S.loc))
						movement_target = S
						break
			if(movement_target)
				stop_automated_movement = 1
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)

				if(movement_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
					if (movement_target.loc.x < src.x)
						set_dir(WEST)
					else if (movement_target.loc.x > src.x)
						set_dir(EAST)
					else if (movement_target.loc.y < src.y)
						set_dir(SOUTH)
					else if (movement_target.loc.y > src.y)
						set_dir(NORTH)
					else
						set_dir(SOUTH)

					if(isturf(movement_target.loc) )
						UnarmedAttack(movement_target)
					else if(ishuman(movement_target.loc) && prob(20))
						visible_emote("stares at the [movement_target] that [movement_target.loc] has with sad puppy eyes.")

		if(prob(1))
			visible_emote(pick("dances around","chases their tail"))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					set_dir(i)
					sleep(1)

/obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."

/mob/living/simple_animal/corgi/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/weapon/newspaper))
		if(!stat)
			for(var/mob/M in viewers(user, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\blue [user] baps [name] on the nose with the rolled up [O]")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					set_dir(i)
					sleep(1)
	else
		..()

/mob/living/simple_animal/corgi/regenerate_icons()
	overlays = list()

	if(inventory_head)
		var/head_icon_state = inventory_head.icon_state
		if(health <= 0)
			head_icon_state += "2"

		var/icon/head_icon = image('icons/mob/corgi_head.dmi',head_icon_state)
		if(head_icon)
			overlays += head_icon

	if(inventory_back)
		var/back_icon_state = inventory_back.icon_state
		if(health <= 0)
			back_icon_state += "2"

		var/icon/back_icon = image('icons/mob/corgi_back.dmi',back_icon_state)
		if(back_icon)
			overlays += back_icon

	if(facehugger)
		if(istype(src, /mob/living/simple_animal/corgi/puppy))
			overlays += image('icons/mob/mask.dmi',"facehugger_corgipuppy")
		else
			overlays += image('icons/mob/mask.dmi',"facehugger_corgi")

	return


/mob/living/simple_animal/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "It's a corgi puppy."
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"

//pupplies cannot wear anything.
/mob/living/simple_animal/corgi/puppy/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		usr << "\red You can't fit this on [src]"
		return
	..()


//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "It's a corgi with a cute pink bow."
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	var/turns_since_scan = 0
	var/puppies = 0

//Lisa already has a cute bow!
/mob/living/simple_animal/corgi/Lisa/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		usr << "\red [src] already has a cute bow!"
		return
	..()

/mob/living/simple_animal/corgi/Lisa/Life()
	..()

	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 15)
			turns_since_scan = 0
			var/alone = 1
			var/ian = 0
			for(var/mob/M in oviewers(7, src))
				if(istype(M, /mob/living/simple_animal/corgi/Ian))
					if(M.client)
						alone = 0
						break
					else
						ian = M
				else
					alone = 0
					break
			if(alone && ian && puppies < 4)
				if(near_camera(src) || near_camera(ian))
					return
				new /mob/living/simple_animal/corgi/puppy(loc)


		if(prob(1))
			visible_emote(pick("dances around","chases her tail"))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					set_dir(i)
					sleep(1)
