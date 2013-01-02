/* Hydroponic stuff
 * Contains:
 *		Plant Bags
 *		Sunflowers
 *		Nettle
 *		Deathnettle
 *		Corbcob
 */

/*
 * Plant Bags
 */
/obj/item/weapon/plantbag
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "plantbag"
	name = "Plant Bag"
	var/mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	var/capacity = 50; //the number of plant pieces it can carry.
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	w_class = 1

/obj/item/weapon/plantbag/attack_self(mob/user as mob)
	for (var/obj/item/weapon/reagent_containers/food/snacks/grown/O in contents)
		contents -= O
		O.loc = user.loc
	user << "\blue You empty the plant bag."
	return

/obj/item/weapon/plantbag/verb/toggle_mode()
	set name = "Switch Bagging Method"
	set category = "Object"

	mode = !mode
	switch (mode)
		if(1)
			usr << "The bag now picks up all plants in a tile at once."
		if(0)
			usr << "The bag now picks up one plant at a time."

/*
 * SeedBag
 */

/obj/item/weapon/seedbag
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "seedbag"
	name = "Seed Bag"
	desc = "A small satchel made for organizing seeds."
	var/mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	var/capacity = 500; //the number of seeds it can carry.
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	w_class = 1
	var/item_quants = list()

/obj/item/weapon/seedbag/attack_self(mob/user as mob)
	user.machine = src
	interact(user)


/obj/item/weapon/seedbag/verb/toggle_mode()
	set name = "Switch Bagging Method"
	set category = "Object"

	mode = !mode
	switch (mode)
		if(1)
			usr << "The bag now picks up all seeds in a tile at once."
		if(0)
			usr << "The bag now picks up one seed pouch at a time."

/obj/item/seeds/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (istype(O, /obj/item/weapon/seedbag))
		var/obj/item/weapon/seedbag/S = O
		if (S.mode == 1)
			for (var/obj/item/seeds/G in locate(src.x,src.y,src.z))
				if (S.contents.len < S.capacity)
					S.contents += G;
					if(S.item_quants[G.name])
						S.item_quants[G.name]++
					else
						S.item_quants[G.name] = 1
				else
					user << "\blue The seed bag is full."
					S.updateUsrDialog()
					return
			user << "\blue You pick up all the seeds."
		else
			if (S.contents.len < S.capacity)
				S.contents += src;
				if(S.item_quants[name])
					S.item_quants[name]++
				else
					S.item_quants[name] = 1
			else
				user << "\blue The seed bag is full."
		S.updateUsrDialog()
	return

/obj/item/weapon/seedbag/proc/interact(mob/user as mob)

	var/dat = "<TT><b>Select an item:</b><br>"

	if (contents.len == 0)
		dat += "<font color = 'red'>No seeds loaded!</font>"
	else
		for (var/O in item_quants)
			if(item_quants[O] > 0)
				var/N = item_quants[O]
				dat += "<FONT color = 'blue'><B>[capitalize(O)]</B>:"
				dat += " [N] </font>"
				dat += "<a href='byond://?src=\ref[src];vend=[O]'>Vend</A>"
				dat += "<br>"

		dat += "</TT>"
	user << browse("<HEAD><TITLE>Seedbag Supplies</TITLE></HEAD><TT>[dat]</TT>", "window=seedbag")
	onclose(user, "seedbag")
	return
/obj/item/weapon/seedbag/Topic(href, href_list)
	if(..())
		return

	usr.machine = src

	var/N = href_list["vend"]

	if(item_quants[N] <= 0) // Sanity check, there are probably ways to press the button when it shouldn't be possible.
		return

	item_quants[N] -= 1
	for(var/obj/O in contents)
		if(O.name == N)
			O.loc = get_turf(src)
			break
	src.updateUsrDialog()
	return

/obj/item/weapon/seedbag/updateUsrDialog()
	var/list/nearby = range(1, src)
	for(var/mob/M in nearby)
		if ((M.client && M.machine == src))
			src.attack_self(M)

/*
 * Sunflower
 */

/obj/item/weapon/grown/sunflower/attack(mob/M as mob, mob/user as mob)
	M << "<font color='green'><b> [user] smacks you with a sunflower!</font><font color='yellow'><b>FLOWER POWER<b></font>"
	user << "<font color='green'> Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>"


/*
 * Nettle
 */
/obj/item/weapon/grown/nettle/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		user << "\red The nettle burns your bare hand!"
		if(istype(user, /mob/living/carbon/human))
			var/organ = ((user.hand ? "l_":"r_") + "arm")
			var/datum/organ/external/affecting = user.get_organ(organ)
			if(affecting.take_damage(0,force))
				user.UpdateDamageIcon()
		else
			user.take_organ_damage(0,force)

/obj/item/weapon/grown/nettle/afterattack(atom/A as mob|obj, mob/user as mob)
	if(force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off
		playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	else
		usr << "All the leaves have fallen off the nettle from violent whacking."
		del(src)

/obj/item/weapon/grown/nettle/changePotency(newValue) //-QualityVan
	potency = newValue
	force = round((5+potency/5), 1)

/*
 * Deathnettle
 */

/obj/item/weapon/grown/deathnettle/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		if(istype(user, /mob/living/carbon/human))
			var/organ = ((user.hand ? "l_":"r_") + "arm")
			var/datum/organ/external/affecting = user.get_organ(organ)
			if(affecting.take_damage(0,force))
				user.UpdateDamageIcon()
		else
			user.take_organ_damage(0,force)
		if(prob(50))
			user.Paralyse(5)
			user << "\red You are stunned by the Deathnettle when you try picking it up!"

/obj/item/weapon/grown/deathnettle/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!..()) return
	if(istype(M, /mob/living))
		M << "\red You are stunned by the powerful acid of the Deathnettle!"
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had the [src.name] used on them by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] on [M.name] ([M.ckey])</font>")

		log_attack("<font color='red'> [user.name] ([user.ckey]) used the [src.name] on [M.name] ([M.ckey])</font>")

		log_admin("ATTACK: [user.name] ([user.ckey]) used the [src.name] on [M.name] ([M.ckey])")
		msg_admin_attack("ATTACK: [user.name] ([user.ckey]) used the [src.name] on [M.name] ([M.ckey])") //BS12 EDIT ALG

		playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)

		M.eye_blurry += force/7
		if(prob(20))
			M.Paralyse(force/6)
			M.Weaken(force/15)
		M.drop_item()

/obj/item/weapon/grown/deathnettle/afterattack(atom/A as mob|obj, mob/user as mob)
	if (force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off

	else
		usr << "All the leaves have fallen off the deathnettle from violent whacking."
		del(src)

/obj/item/weapon/grown/deathnettle/changePotency(newValue) //-QualityVan
	potency = newValue
	force = round((5+potency/2.5), 1)


/*
 * Corncob
 */
/obj/item/weapon/corncob/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || istype(W, /obj/item/weapon/kitchen/utensil/knife))
		user << "<span class='notice'>You use [W] to fashion a pipe out of the corn cob!</span>"
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe (user.loc)
		del(src)
		return
