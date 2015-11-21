/obj/item/weapon/tape_roll
	name = "tape roll"
	desc = "A roll of sticky tape. Possibly for taping ducks... or was that ducts?"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "taperoll"
	w_class = 1

/obj/item/weapon/tape_roll/attack(var/mob/living/carbon/human/H, var/mob/user)
	if(istype(H))
		if(user.zone_sel.selecting == "eyes")

			if(!H.organs_by_name["head"])
				user << "<span class='warning'>\The [H] doesn't have a head.</span>"
				return
			if(!H.has_eyes())
				user << "<span class='warning'>\The [H] doesn't have any eyes.</span>"
				return
			if(H.glasses)
				user << "<span class='warning'>\The [H] is already wearing somethign on their eyes.</span>"
				return
			if(H.head && (H.head.body_parts_covered & FACE))
				user << "<span class='warning'>Remove their [H.head] first.</span>"
				return
			user.visible_message("<span class='danger'>\The [user] begins taping over \the [H]'s eyes!")

			if(!do_after(user, 30))
				return

			// Repeat failure checks.
			if(!H || !src || !H.organs_by_name["head"] || !H.has_eyes() || H.glasses || (H.head && (H.head.body_parts_covered & FACE)))
				return

			user.visible_message("<span class='danger'>\The [user] has taped up \the [H]'s eyes!")
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/blindfold/tape(H), slot_glasses)

		else if(user.zone_sel.selecting == "mouth" || user.zone_sel.selecting == "head")
			if(!H.organs_by_name["head"])
				user << "<span class='warning'>\The [H] doesn't have a head.</span>"
				return
			if(!H.check_has_mouth())
				user << "<span class='warning'>\The [H] doesn't have a mouth.</span>"
				return
			if(H.wear_mask)
				user << "<span class='warning'>\The [H] is already wearing a mask.</span>"
				return
			if(H.head && (H.head.body_parts_covered & FACE))
				user << "<span class='warning'>Remove their [H.head] first.</span>"
				return
			user.visible_message("<span class='danger'>\The [user] begins taping up \the [H]'s mouth!")

			if(!do_after(user, 30))
				return

			// Repeat failure checks.
			if(!H || !src || !H.organs_by_name["head"] || !H.check_has_mouth() || H.wear_mask || (H.head && (H.head.body_parts_covered & FACE)))
				return

			user.visible_message("<span class='danger'>\The [user] has taped up \the [H]'s mouth!")
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/muzzle/tape(H), slot_wear_mask)

		else if(user.zone_sel.selecting == "r_hand" || user.zone_sel.selecting == "l_hand")
			var/obj/item/weapon/handcuffs/cable/tape/T = new(user)
			if(!T.place_handcuffs(H, user))
				user.unEquip(T)
				qdel(T)
		else
			return ..()
		return 1

/obj/item/weapon/tape_roll/proc/stick(var/obj/item/weapon/W, mob/user)
	if(!istype(W, /obj/item/weapon/paper))
		return
	user.drop_from_inventory(W)
	var/obj/item/weapon/ducttape/tape = new(get_turf(src))
	tape.attach(W)
	user.put_in_hands(tape)

/obj/item/weapon/ducttape
	name = "tape"
	desc = "A piece of sticky tape."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "tape"
	w_class = 1
	layer = 4
	anchored = 1 //it's sticky, no you cant move it

	var/obj/item/weapon/stuck = null

/obj/item/weapon/ducttape/New()
	..()
	flags |= NOBLUDGEON

/obj/item/weapon/ducttape/examine(mob/user)
	return stuck.examine(user)

/obj/item/weapon/ducttape/proc/attach(var/obj/item/weapon/W)
	stuck = W
	W.forceMove(src)
	icon_state = W.icon_state + "_taped"
	name = W.name + " (taped)"
	overlays = W.overlays

/obj/item/weapon/ducttape/attack_self(mob/user)
	if(!stuck)
		return

	user << "You remove \the [initial(name)] from [stuck]."

	user.drop_from_inventory(src)
	stuck.forceMove(get_turf(src))
	user.put_in_hands(stuck)
	stuck = null
	overlays = null
	qdel(src)

/obj/item/weapon/ducttape/afterattack(var/A, mob/user, flag, params)

	if(!in_range(user, A) || istype(A, /obj/machinery/door) || !stuck)
		return

	var/turf/target_turf = get_turf(A)
	var/turf/source_turf = get_turf(user)

	var/dir_offset = 0
	if(target_turf != source_turf)
		dir_offset = get_dir(source_turf, target_turf)
		if(!(dir_offset in cardinal))
			user << "You cannot reach that from here."		// can only place stuck papers in cardinal directions, to
			return											// reduce papers around corners issue.

	user.drop_from_inventory(src)
	forceMove(source_turf)

	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			pixel_x = text2num(mouse_control["icon-x"]) - 16
			if(dir_offset & EAST)
				pixel_x += 32
			else if(dir_offset & WEST)
				pixel_x -= 32
		if(mouse_control["icon-y"])
			pixel_y = text2num(mouse_control["icon-y"]) - 16
			if(dir_offset & NORTH)
				pixel_y += 32
			else if(dir_offset & SOUTH)
				pixel_y -= 32
