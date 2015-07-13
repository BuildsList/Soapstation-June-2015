/mob/living/simple_animal/spiderbot

	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 500
	mob_size = 5

	var/obj/item/device/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/cell/cell = null
	var/obj/machinery/camera/camera = null
	var/obj/item/device/mmi/mmi = null
	var/list/req_access = list(access_robotics) //Access needed to pop out the brain.
	var/positronic

	name = "spider-bot"
	desc = "A skittering robotic friend!"
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"

	wander = 0

	health = 10
	maxHealth = 10

	attacktext = "shocked"
	melee_damage_lower = 1
	melee_damage_upper = 3

	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"

	var/emagged = 0
	var/obj/item/held_item = null //Storage for single item they can hold.
	speed = -1                    //Spiderbots gotta go fast.
	pass_flags = PASSTABLE
	small = 1
	speak_emote = list("beeps","clicks","chirps")

/mob/living/simple_animal/spiderbot/New()
	..()
	add_language("Galactic Common")
	default_language = all_languages["Galactic Common"]
	verbs |= /mob/living/proc/ventcrawl
	verbs |= /mob/living/proc/hide

/mob/living/simple_animal/spiderbot/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(istype(O, /obj/item/device/mmi))
		var/obj/item/device/mmi/B = O
		if(src.mmi)
			user << "<span class='warning'>There's already a brain in [src]!</span>"
			return
		if(!B.brainmob)
			user << "<span class='warning'>Sticking an empty MMI into the frame would sort of defeat the purpose.</span>"
			return
		if(!B.brainmob.key)
			var/ghost_can_reenter = 0
			if(B.brainmob.mind)
				for(var/mob/dead/observer/G in player_list)
					if(G.can_reenter_corpse && G.mind == B.brainmob.mind)
						ghost_can_reenter = 1
						break
			if(!ghost_can_reenter)
				user << "<span class='notice'>[O] is completely unresponsive; there's no point.</span>"
				return

		if(B.brainmob.stat == DEAD)
			user << "<span class='warning'>[O] is dead. Sticking it into the frame would sort of defeat the purpose.</span>"
			return

		if(jobban_isbanned(B.brainmob, "Cyborg"))
			user << "<span class='warning'>\The [O] does not seem to fit.</span>"
			return

		user << "<span class='notice'>You install \the [O] in \the [src]!</span>"

		if(istype(O, /obj/item/device/mmi/digital))
			positronic = 1
			add_language("Robot Talk")

		user.drop_item()
		src.mmi = O
		src.transfer_personality(O)

		O.loc = src
		src.update_icon()
		return 1

	if (istype(O, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = O
		if (WT.remove_fuel(0))
			if(health < maxHealth)
				health += pick(1,1,1,2,2,3)
				if(health > maxHealth)
					health = maxHealth
				add_fingerprint(user)
				src.visible_message("<span class='notice'>\The [user] has spot-welded some of the damage to \the [src]!</span>")
			else
				user << "<span class='warning'>\The [src] is undamaged!</span>"
		else
			user << "<span class='danger'>You need more welding fuel for this task!</span>"
			return
	else if(istype(O, /obj/item/weapon/card/id)||istype(O, /obj/item/device/pda))
		if (!mmi)
			user << "<span class='danger'>There's no reason to swipe your ID - \the [src] has no brain to remove.</span>"
			return 0

		var/obj/item/weapon/card/id/id_card

		if(istype(O, /obj/item/weapon/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if(access_robotics in id_card.access)
			user << "<span class='notice'>You swipe your access card and pop the brain out of \the [src].</span>"
			eject_brain()
			if(held_item)
				held_item.loc = src.loc
				held_item = null
			return 1
		else
			user << "<span class='danger'>You swipe your card with no effect.</span>"
			return 0
	else if (istype(O, /obj/item/weapon/card/emag))
		if (emagged)
			user << "<span class='danger'>\The [src] is already overloaded - better run!</span>"
			return 0
		else
			var/obj/item/weapon/card/emag/emag = O
			emag.uses--
			emagged = 1
			user << "<span class='danger'>You short out the security protocols and overload \the [src]'s cell, priming it to explode in a short time.</span>"
			spawn(0)
				sleep(100)
				if(!src) return
				src << "<span class='warning'>Your cell seems to be outputting a lot of power...</span>"
				sleep(200)
				if(!src) return
				src << "<span class='danger'>Internal heat sensors are spiking! Something is badly wrong with your cell!</span>"
				sleep(300)
				if(!src) return
				src.explode()
				return
	else
		attacked_with_item(O, user)

/mob/living/simple_animal/spiderbot/proc/transfer_personality(var/obj/item/device/mmi/M as obj)

		src.mind = M.brainmob.mind
		src.mind.key = M.brainmob.key
		src.ckey = M.brainmob.ckey
		src.name = "spider-bot ([M.brainmob.name])"

/mob/living/simple_animal/spiderbot/proc/explode() //When emagged.
	src.visible_message("<span class='danger'>\The [src] makes an odd warbling noise, fizzles, and explodes!</span>")
	explosion(get_turf(loc), -1, -1, 3, 5)
	eject_brain()
	death()

/mob/living/simple_animal/spiderbot/proc/update_icon()
	if(mmi)
		if(positronic)
			icon_state = "spiderbot-chassis-posi"
			icon_living = "spiderbot-chassis-posi"
		else
			icon_state = "spiderbot-chassis-mmi"
			icon_living = "spiderbot-chassis-mmi"
	else
		icon_state = "spiderbot-chassis"
		icon_living = "spiderbot-chassis"

/mob/living/simple_animal/spiderbot/proc/eject_brain()
	if(mmi)
		var/turf/T = get_turf(loc)
		if(T)
			mmi.loc = T
		if(mind)	mind.transfer_to(mmi.brainmob)
		mmi = null
		real_name = initial(real_name)
		name = real_name
		update_icon()
	remove_language("Robot Talk")
	positronic = null

/mob/living/simple_animal/spiderbot/Destroy()
	eject_brain()
	..()

/mob/living/simple_animal/spiderbot/New()

	radio = new /obj/item/device/radio/borg(src)
	camera = new /obj/machinery/camera(src)
	camera.c_tag = "spiderbot-[real_name]"
	camera.replace_networks(list("SS13"))

	..()

/mob/living/simple_animal/spiderbot/death()

	living_mob_list -= src
	dead_mob_list += src

	if(camera)
		camera.status = 0

	held_item.loc = src.loc
	held_item = null

	gibs(loc, viruses, null, null, /obj/effect/gibspawner/robot) //TODO: use gib() or refactor spiderbots into synthetics.
	qdel(src)
	return

//Cannibalized from the parrot mob. ~Zuhayr
/mob/living/simple_animal/spiderbot/verb/drop_held_item()
	set name = "Drop held item"
	set category = "Spiderbot"
	set desc = "Drop the item you're holding."

	if(stat)
		return

	if(!held_item)
		usr << "\red You have nothing to drop!"
		return 0

	if(istype(held_item, /obj/item/weapon/grenade))
		visible_message("<span class='danger'>\The [src] launches \the [held_item]!</span>", \
			"<span class='danger'>You launch \the [held_item]!</span>", \
			"You hear a skittering noise and a thump!")
		var/obj/item/weapon/grenade/G = held_item
		G.loc = src.loc
		G.prime()
		held_item = null
		return 1

	visible_message("<span class='notice'>\The [src] drops \the [held_item].</span>", \
		"<span class='notice'>You drop \the [held_item].</span>", \
		"You hear a skittering noise and a soft thump.")

	held_item.loc = src.loc
	held_item = null
	return 1

	return

/mob/living/simple_animal/spiderbot/verb/get_item()
	set name = "Pick up item"
	set category = "Spiderbot"
	set desc = "Allows you to take a nearby small item."

	if(stat)
		return -1

	if(held_item)
		src << "<span class='warning'>You are already holding \the [held_item]</span>"
		return 1

	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		if(I.loc != src && I.w_class <= 2 && I.Adjacent(src) )
			items.Add(I)

	var/obj/selection = input("Select an item.", "Pickup") in items

	if(selection)
		for(var/obj/item/I in view(1, src))
			if(selection == I)
				held_item = selection
				selection.loc = src
				visible_message("<span class='notice'>\The [src] scoops up \the [held_item].</span>", \
					"<span class='notice'>You grab \the [held_item].</span>", \
					"You hear a skittering noise and a clink.")
				return held_item
		src << "<span class='warning'>\The [selection] is too far away.</span>"
		return 0

	src << "<span class='warning'>There is nothing of interest to take.</span>"
	return 0

/mob/living/simple_animal/spiderbot/examine(mob/user)
	..(user)
	if(src.held_item)
		user << "It is carrying \icon[src.held_item] \a [src.held_item]."

/mob/living/simple_animal/spiderbot/cannot_use_vents()
	return

/mob/living/simple_animal/spiderbot/binarycheck()
	return positronic