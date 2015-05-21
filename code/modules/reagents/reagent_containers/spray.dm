/obj/item/weapon/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = OPENCONTAINER|NOBLUDGEON
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10) //Set to null instead of list, if there is only one.
	var/spray_size = 3
	var/list/spray_sizes = list(1,3)
	volume = 250

/obj/item/weapon/reagent_containers/spray/New()
	..()
	src.verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT

/obj/item/weapon/reagent_containers/spray/afterattack(atom/A as mob|obj, mob/user as mob, proximity)
	if(istype(A, /obj/item/weapon/storage) || istype(A, /obj/structure/table) || istype(A, /obj/structure/closet) || istype(A, /obj/item/weapon/reagent_containers) || istype(A, /obj/structure/sink) || istype(A, /obj/structure/janitorialcart))
		return

	if(istype(A, /spell))
		return

	if(proximity)
		if(standard_dispenser_refill(user, A))
			return

	if(reagents.total_volume < amount_per_transfer_from_this)
		user << "<span class='notice'>\The [src] is empty!</span>"
		return

	Spray_at(A, user, proximity)

	playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)

	user.changeNextMove(4)

	if(reagents.has_reagent("sacid"))
		message_admins("[key_name_admin(user)] fired sulphuric acid from \a [src].")
		log_game("[key_name(user)] fired sulphuric acid from \a [src].")
	if(reagents.has_reagent("pacid"))
		message_admins("[key_name_admin(user)] fired Polyacid from \a [src].")
		log_game("[key_name(user)] fired Polyacid from \a [src].")
	if(reagents.has_reagent("lube"))
		message_admins("[key_name_admin(user)] fired Space lube from \a [src].")
		log_game("[key_name(user)] fired Space lube from \a [src].")
	return

/obj/item/weapon/reagent_containers/spray/proc/Spray_at(atom/A as mob|obj, mob/user as mob, proximity)
	if (A.density && proximity)
		A.visible_message("[usr] sprays [A] with [src].")
		reagents.trans_to(A, amount_per_transfer_from_this)
	else
		spawn(0)
			var/obj/effect/effect/water/chempuff/D = new/obj/effect/effect/water/chempuff(get_turf(src))
			var/turf/my_target = get_turf(A)
			D.create_reagents(amount_per_transfer_from_this)
			if(!src)
				return
			reagents.trans_to_obj(D, amount_per_transfer_from_this)
			D.set_color()
			D.set_up(my_target, spray_size, 10)
	return

/obj/item/weapon/reagent_containers/spray/attack_self(var/mob/user)
	if(!possible_transfer_amounts)
		return
	amount_per_transfer_from_this = next_in_list(amount_per_transfer_from_this, possible_transfer_amounts)
	spray_size = next_in_list(spray_size, spray_sizes)
	user << "<span class='notice'>You adjusted the pressure nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>"

/obj/item/weapon/reagent_containers/spray/examine(mob/user)
	if(..(user, 0) && loc == user)
		user << "[round(reagents.total_volume)] units left."
	return

/obj/item/weapon/reagent_containers/spray/verb/empty()

	set name = "Empty Spray Bottle"
	set category = "Object"
	set src in usr

	if (alert(usr, "Are you sure you want to empty that?", "Empty Bottle:", "Yes", "No") != "Yes")
		return
	if(isturf(usr.loc))
		usr << "<span class='notice'>You empty \the [src] onto the floor.</span>"
		reagents.trans_to(usr.loc, reagents.total_volume)

//space cleaner
/obj/item/weapon/reagent_containers/spray/cleaner
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"

/obj/item/weapon/reagent_containers/spray/cleaner/drone
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	volume = 50

/obj/item/weapon/reagent_containers/spray/cleaner/New()
	..()
	reagents.add_reagent("cleaner", volume)

/obj/item/weapon/reagent_containers/spray/pepper
	name = "pepperspray"
	desc = "Manufactured by UhangInc, used to blind and down an opponent quickly."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "pepperspray"
	item_state = "pepperspray"
	possible_transfer_amounts = null
	volume = 40
	var/safety = 1

/obj/item/weapon/reagent_containers/spray/pepper/New()
	..()
	reagents.add_reagent("condensedcapsaicin", 40)

/obj/item/weapon/reagent_containers/spray/pepper/examine(mob/user)
	if(..(user, 1))
		user << "The safety is [safety ? "on" : "off"]."

/obj/item/weapon/reagent_containers/spray/pepper/attack_self(var/mob/user)
	safety = !safety
	usr << "<span class = 'notice'>You switch the safety [safety ? "on" : "off"].</span>"

/obj/item/weapon/reagent_containers/spray/pepper/Spray_at(atom/A as mob|obj)
	if(safety)
		usr << "<span class = 'warning'>The safety is on!</span>"
		return
	..()

/obj/item/weapon/reagent_containers/spray/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/device.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = null
	volume = 10

/obj/item/weapon/reagent_containers/spray/waterflower/New()
	..()
	reagents.add_reagent("water", 10)

/obj/item/weapon/reagent_containers/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagent in a given area."
	icon = 'icons/obj/gun.dmi'
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	throwforce = 3
	w_class = 3.0
	possible_transfer_amounts = null
	volume = 600
	origin_tech = "combat=3;materials=3;engineering=3"

/obj/item/weapon/reagent_containers/spray/chemsprayer/Spray_at(atom/A as mob|obj)
	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T, T1, T2)

	for(var/a = 1 to 3)
		spawn(0)
			if(reagents.total_volume < 1) break
			var/obj/effect/effect/water/chempuff/D = new/obj/effect/effect/water/chempuff(get_turf(src))
			var/turf/my_target = the_targets[a]
			D.create_reagents(amount_per_transfer_from_this)
			if(!src)
				return
			reagents.trans_to_obj(D, amount_per_transfer_from_this)
			D.set_color()
			D.set_up(my_target, rand(6, 8), 2)
	return

/obj/item/weapon/reagent_containers/spray/plantbgone
	name = "Plant-B-Gone"
	desc = "Kills those pesky weeds!"
	icon = 'icons/obj/hydroponics_machines.dmi'
	icon_state = "plantbgone"
	item_state = "plantbgone"
	volume = 100

/obj/item/weapon/reagent_containers/spray/plantbgone/New()
	..()
	reagents.add_reagent("plantbgone", 100)

/obj/item/weapon/reagent_containers/spray/plantbgone/afterattack(atom/A as mob|obj, mob/user as mob, proximity)
	if(!proximity) return

	if(istype(A, /obj/effect/blob)) // blob damage in blob code
		return

	..()