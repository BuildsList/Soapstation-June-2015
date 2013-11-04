/area/telescience
	name = "\improper Telescience Lab"
	icon_state = "teleporter"
	music = "signal"

/obj/machinery/computer/telescience
	name = "Telepad Control Console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_state = "teleport"

	// VARIABLES //
	var/teles_left	// How many teleports left until it becomes uncalibrated
	var/x_off	// X offset
	var/y_off	// Y offset
	var/x_co	// X coordinate
	var/y_co	// Y coordinate
	var/z_co	// Z coordinate

/obj/machinery/computer/telescience/New()
	teles_left = rand(8,12)
	x_off = rand(-10,10)
	y_off = rand(-10,10)

/obj/machinery/computer/telescience/update_icon()
	if(stat & BROKEN)
		icon_state = "telescib"
	else
		if(stat & NOPOWER)
			src.icon_state = "teleport0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

/obj/machinery/computer/telescience/attack_paw(mob/user)
	usr << "You are too primitive to use this computer."
	return

/obj/machinery/computer/telescience/attack_ai(mob/user)
	src.attack_hand()

/obj/machinery/computer/telescience/attack_hand(mob/user)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	var/t = ""
	t += "<A href='?src=\ref[src];setx=1'>Set X</A>"
	t += "<A href='?src=\ref[src];sety=1'>Set Y</A>"
	t += "<A href='?src=\ref[src];setz=1'>Set Z</A>"
	t += "<BR><BR>Current set coordinates:"
	t += "([x_co], [y_co], [z_co])"
	t += "<BR><BR><A href='?src=\ref[src];send=1'>Send</A>"
	t += " <A href='?src=\ref[src];receive=1'>Receive</A>"
	t += "<BR><BR><A href='?src=\ref[src];recal=1'>Recalibrate</A>"
	var/datum/browser/popup = new(user, "telesci", name, 640, 480)
	popup.set_content(t)
	popup.open()
	return

/obj/machinery/computer/telescience/proc/telefail()
	if(prob(65))
		for(var/mob/O in hearers(src, null))
			O.show_message("\red The telepad weakly fizzles.", 2)
		for(var/obj/machinery/telepad/E in world)
			var/L = get_turf(E)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, L)
			s.start()
		return
	if(prob(10))
		// Irradiate everyone in telescience!
		for(var/obj/machinery/telepad/E in world)
			var/L = get_turf(E)
			for(var/mob/living/carbon/human/M in viewers(L, null))
				M.apply_effect((rand(25, 50)), IRRADIATE, 0)
				M << "\red You feel strange."
		return
	if(prob(5))
		// AI CALL SHUTTLE I SAW RUNE
		for(var/mob/living/carbon/O in viewers(src, null))
			var/datum/game_mode/cult/temp = new
			O.show_message("\red The telepad flashes with a strange light, and you have a sudden surge of allegiance toward the true dark one!", 2)
			O.mind.make_Cultist()
			temp.grant_runeword(O)
		for(var/obj/machinery/telepad/E in world)
			var/L = get_turf(E)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, L)
			s.start()
		return
	if(prob(5))
		// VIVA LA FUCKING REVOLUTION BITCHES.
		for(var/mob/living/carbon/O in viewers(src, null))
			O.show_message("\red The telepad flashes with a strange light, and you see all kind of images flash through your mind, of murderous things Nanotrasen has done, and you decide to rebel!", 2)
			O.mind.make_Rev()
		for(var/obj/machinery/telepad/E in world)
			var/L = get_turf(E)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, L)
			s.start()
		return
	if(prob(10))
		// *fart
		for(var/mob/living/carbon/O in viewers(src, null))
			O.show_message("\red The telepad flashes with a rainbow light, and a portal opens, to what appears to be a Galactic Space Authority owned station. There is an Assistant mooning you through the portal, and-Oh god, he farted! The bad smell of the fart knocks you down.", 2)
			O.Weaken(10)
		for(var/obj/machinery/telepad/E in world)
			var/L = get_turf(E)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, L)
			s.start()
		return
	if(prob(15))
		// The OH SHIT FUCK GOD DAMN IT LYNCH THE SCIENTISTS event.
		for(var/mob/living/carbon/O in viewers(src, null))
			O.show_message("\red The telepad changes colors rapidly, and opens a portal, and you see what your mind seems to think is the very threads that hold the pattern of the universe together, and a eerie sense of paranoia creeps into you.", 2)
			switch(rand(1,3))
				if(1)
					mini_blob_event()
				if(2)
					immovablerod()
					immovablerod()
					immovablerod()
				if(3)
					spacevine_infestation()
					spacevine_infestation()
		for(var/obj/machinery/telepad/E in world)
			var/L = get_turf(E)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, L)
			s.start()
		return
	if(prob(10))
		// HOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOONK
		for(var/mob/living/carbon/M in hearers(src, null))

			M << sound('sound/items/AirHorn.ogg')
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
					continue
			M << "<font color='red' size='7'>HONK</font>"
			M.sleeping = 0
			M.stuttering += 20
			M.ear_deaf += 30
			M.Weaken(3)
			if(prob(30))
				M.Stun(10)
				M.Paralyse(4)
			else
				M.make_jittery(500)
		for(var/obj/machinery/telepad/E in world)
			var/L = get_turf(E)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, L)
			s.start()
		return
	if(prob(5))
		// They did the mash! (They did the monster mash!) The monster mash! (It was a graveyard smash!)
		// copied from gold slime code because it's efficient
		for(var/obj/machinery/telepad/E in world)
			var/L = get_turf(E)
			var/blocked = list(/mob/living/simple_animal/hostile,
				/mob/living/simple_animal/hostile/alien/queen/large,
				/mob/living/simple_animal/hostile/retaliate,
				/mob/living/simple_animal/hostile/retaliate/clown,
				/mob/living/simple_animal/hostile/giant_spider/nurse)
			var/list/hostiles = typesof(/mob/living/simple_animal/hostile) - blocked
			playsound(L, 'sound/effects/phasein.ogg', 100, 1)
			for(var/mob/living/carbon/human/M in viewers(L, null))
				flick("e_flash", M.flash)
			var/chosen = pick(hostiles)
			var/mob/living/simple_animal/hostile/H = new chosen
			H.loc = L
			return
		return
	return

/obj/machinery/computer/telescience/proc/dosend()
	var/trueX = (x_co + x_off)
	var/trueY = (y_co + y_off)
	for(var/obj/machinery/telepad/E in world)
		var/L = get_turf(E)
		var/target = locate(trueX, trueY, z_co)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, L)
		s.start()
		flick("pad-beam", E)
		usr << "\blue Teleport successful."
		for(var/obj/item/OI in L)
			do_teleport(OI, target, 0)
		for(var/obj/structure/closet/OC in L)
			do_teleport(OC, target, 0)
		for(var/mob/living/carbon/MO in L)
			do_teleport(MO, target, 0)
		for(var/mob/living/simple_animal/SA in L)
			do_teleport(SA, target, 0)
		return
	return

/obj/machinery/computer/telescience/proc/doreceive()
	var/trueX = (x_co + x_off)
	var/trueY = (y_co + y_off)
	for(var/obj/machinery/telepad/E in world)
		var/L = get_turf(E)
		var/T = locate(trueX, trueY, z_co)
		var/G = get_turf(T)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, L)
		s.start()
		flick("pad-beam", E)
		usr << "\blue Teleport successful."
		for(var/obj/item/ROI in G)
			do_teleport(ROI, E, 0)
		for(var/obj/structure/closet/ROC in G)
			do_teleport(ROC, E, 0)
		for(var/mob/living/carbon/RMO in G)
			do_teleport(RMO, E, 0)
		for(var/mob/living/simple_animal/RSA in G)
			do_teleport(RSA, E, 0)
		return
	return

/obj/machinery/computer/telescience/proc/telesend()
	if(x_co == "")
		usr << "\red Error: set coordinates."
		return
	if(y_co == "")
		usr << "\red Error: set coordinates."
		return
	if(z_co == "")
		usr << "\red Error: set coordinates."
		return
	if(x_co < 1 || x_co > 255)
		telefail()
		usr << "\red Error: X is less than 11 or greater than 245."
		return
	if(y_co < 1 || y_co > 255)
		telefail()
		usr << "\red Error: Y is less than 11 or greater than 245."
		return
	if(z_co == 2 || z_co < 1 || z_co > 6)
		telefail()
		usr << "\red Error: Z is less than 1, greater than 6, or equal to 2."
		return
	if(teles_left > 0)
		if(prob(75))
			teles_left -= 1
			dosend()
			if(teles_left == 0)
				for(var/mob/O in hearers(src, null))
					O.show_message("/red The telepad has become uncalibrated.", 2)
		else
			telefail()
		return
	else	// oh no, the telepad is uncalibrated!
		if(prob(35))
			// 35% chance it will work
			dosend()
		else
			// OH NO YOU IDIOT
			telefail()
		return
	return

/obj/machinery/computer/telescience/proc/telereceive()
	// basically the same thing
	if(x_co == "")
		usr << "\red Error: set coordinates."
		return
	if(y_co == "")
		usr << "\red Error: set coordinates."
		return
	if(z_co == "")
		usr << "\red Error: set coordinates."
		return
	if(x_co < 1 || x_co > 255)
		telefail()
		usr << "\red Error: X is less than 11 or greater than 200."
		return
	if(y_co < 1 || y_co > 255)
		telefail()
		usr << "\red Error: Y is less than 11 or greater than 200."
		return
	if(z_co == 2 || z_co < 1 || z_co > 6)
		telefail()
		usr << "\red Error: Z is less than 1, greater than 6, or equal to 2."
		return
	if(teles_left > 0)
		if(prob(85))
			teles_left -= 1
			doreceive()
			if(teles_left == 0)
				for(var/mob/O in hearers(src, null))
					O.show_message("\red The telepad has become uncalibrated.", 2)
		else
			telefail()
		return
	else
		if(prob(55))
			doreceive()
		else
			telefail()
		return
	return

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(..())
		return
	if(href_list["setx"])
		var/a = input("Please input desired X coordinate.", name, x_co) as num
		a = copytext(sanitize(a), 1, 20)
		x_co = a
		x_co = text2num(x_co)
		return
	if(href_list["sety"])
		var/b = input("Please input desired Y coordinate.", name, y_co) as num
		b = copytext(sanitize(b), 1, 20)
		y_co = b
		y_co = text2num(y_co)
		return
	if(href_list["setz"])
		var/c = input("Please input desired Z coordinate.", name, z_co) as num
		c = copytext(sanitize(c), 1, 20)
		z_co = c
		z_co = text2num(z_co)
		return
	if(href_list["send"])
		telesend()
		return
	if(href_list["receive"])
		telereceive()
		return
	if(href_list["recal"])
		teles_left = rand(7,10)
		x_off = rand(-10,10)
		y_off = rand(-10,10)
		for(var/obj/machinery/telepad/E in world)
			var/L = get_turf(E)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, L)
			s.start()
		usr << "\blue Calibration successful."
		return