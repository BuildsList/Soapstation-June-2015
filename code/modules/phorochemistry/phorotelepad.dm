/obj/machinery/telepad_phorochem
	name = "telepad"
	desc = "A bluespace telepad used for teleporting objects to and from a location."
	icon = 'icons/phorochemistry.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 500
	var/obj/machinery/telepad_phorochem/dest

/obj/machinery/telepad_phorochem/proc/teleport() //should be guaranteed to only contain one item
	if(dest)
		flick("pad-beam", src)
		playsound(src.loc, 'sound/weapons/flash.ogg', 25, 1)
		flick("pad-beam", dest)
		playsound(dest.loc, 'sound/weapons/flash.ogg', 25, 1)

		for(var/obj/O in src.loc.contents)
			if(!O.anchored)
				O.loc = dest.loc

		for(var/mob/M in src.loc.contents)
			//if(!M.restrained())
			M.loc = dest.loc

/obj/machinery/telepad_phorochem/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/reagent_containers))
		user.drop_item()
		W.loc = src.loc
	else if(istype(W, /obj/item/weapon/wrench))
		var/word = "tighten"
		src.anchored = !src.anchored
		if(!src.anchored)
			word = "undo"
		user << "You [word] the telepad anchor bolts."
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
	else if(istype(W, /obj/item/weapon/screwdriver) && !src.anchored)
		user << "You fold the telepad."
		new /obj/item/weapon/phorochem_telepad(src.loc)
		del(src)
	else
		return ..()

/obj/item/weapon/phorochem_telepad
	name = "telepad"
	desc = "A bluespace telepad used for teleporting objects to and from a location."
	icon = 'icons/phorochemistry.dmi'
	icon_state = "pad-folded"

	attack_self(mob/user as mob)
		user << "You unfold the pad."
		var/obj/machinery/telepad_phorochem/T = new /obj/machinery/telepad_phorochem(user.loc)
		T.anchored = 0
		del(src)

/datum/design/item/phorochem_telepad
	name = "phorochemistry telepad"
	id = "phorochem_telepad"
	req_tech = list("bluespace" = 2, "materials" = 3)
	materials = list("$metal" = 1000)
	build_path = /obj/item/weapon/phorochem_telepad