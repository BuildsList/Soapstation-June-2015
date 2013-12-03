/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */

//Main cryopod console.



//Decorative structures to go alongside cryopods.
/obj/structure/cryofeed

	name = "\improper cryogenic feed"
	desc = "A bewildering tangle of machinery and pipes."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "cryo_rear"
	anchored = 1

	var/orient_right = null //Flips the sprite.

/obj/structure/cryofeed/right
	orient_right = 1
	icon_state = "cryo_rear-r"

/obj/structure/cryofeed/New()

	if(orient_right)
		icon_state = "cryo_rear-r"
	else
		icon_state = "cryo_rear"
	..()

//Cryopods themselves.
/obj/machinery/cryopod
	name = "\improper cryogenic freezer"
	desc = "A man-sized pod for entering suspended animation."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "body_scanner_0"
	density = 1
	anchored = 1

	var/mob/occupant = null      //Person waiting to be despawned.
	var/orient_right = null      //Flips the sprite.
	var/time_till_despawn = 10   //(9000 ticks) 15 minutes-ish safe period before being despawned.
	var/time_entered = 0         //Used to keep track of the safe period.
	var/obj/item/device/radio/intercom/announce //

	//These items are preserved when the process() despawn proc occurs.
	var/list/preserve_items = list(
		/obj/item/weapon/hand_tele,
		/obj/item/weapon/card/id/captains_spare,
		/obj/item/device/aicard,
		/obj/item/device/mmi,
		/obj/item/device/paicard,
		/obj/item/weapon/gun,
		/obj/item/weapon/pinpointer,
		/obj/item/clothing/suit,
		/obj/item/clothing/shoes/magboots,
		/obj/item/blueprints,
		/obj/item/clothing/head/helmet/space/
	)

/obj/machinery/cryopod/right
	orient_right = 1
	icon_state = "body_scanner_0-r"

/obj/machinery/cryopod/New()

	announce = new /obj/item/device/radio/intercom(src)

	if(orient_right)
		icon_state = "body_scanner_0-r"
	else
		icon_state = "body_scanner_0"
	..()

//Lifted from Unity stasis.dm and refactored. ~Zuhayr
/obj/machinery/cryopod/process()
	if(occupant)

		//Allow a ten minute gap between entering the pod and actually despawning.
		if(world.time - time_entered < time_till_despawn)
			return

		if(!occupant.client && occupant.stat<2) //Occupant is living and has no client.

			//Delete all items not on the preservation list and drop all others into the pod.
			for(var/obj/item/W in occupant)
				occupant.drop_from_inventory(W)
				W.loc = src

				var/preserve = null
				for(var/T in preserve_items)
					if(istype(W,T))
						preserve = 1
						break

				if(!preserve) del(W)

			var/job = occupant.mind.assigned_role
			var/role = occupant.mind.special_role

			job_master.FreeRole(job)

			if(role == "traitor" || role == "MODE")
				del(occupant.mind.objectives)
				occupant.mind.special_role = null
			else
				if(ticker.mode.name == "AutoTraitor")
					var/datum/game_mode/traitor/autotraitor/current_mode = ticker.mode
					current_mode.possible_traitors.Remove(occupant)

			// Delete them from datacore.
			for(var/datum/data/record/R in data_core.medical)
				if ((R.fields["name"] == occupant.real_name))
					del(R)
			for(var/datum/data/record/T in data_core.security)
				if ((T.fields["name"] == occupant.real_name))
					del(T)
			for(var/datum/data/record/G in data_core.general)
				if ((G.fields["name"] == occupant.real_name))
					del(G)

			if(orient_right)
				icon_state = "body_scanner_0-r"
			else
				icon_state = "body_scanner_0"

			//TODO: Check objectives/mode, update new targets if this mob is the target, spawn new antags?

			//This should guarantee that ghosts don't spawn.
			occupant.ckey = null

			//Make an announcement and log the person entering storage.
			announce.autosay("[occupant.real_name] has entered long-term storage.", "Cryogenic Oversight")

			// Delete the mob.
			del(occupant)
			occupant = null

	return


/obj/machinery/cryopod/attackby(var/obj/item/weapon/G as obj, var/mob/user as mob)

	if(istype(G, /obj/item/weapon/grab))

		if(occupant)
			user << "\blue The cryo pod is in use."
			return

		if(!ismob(G:affecting))
			return

		var/willing = null //We don't want to allow people to be forced into despawning.
		var/mob/M = G:affecting

		if(M.client)
			if(alert(M,"Would you like to enter cryosleep?",,"Yes","No") == "Yes")
				if(!M || !G || !G:affecting) return
				willing = 1
		else
			willing = 1

		if(willing)

			visible_message("[user] starts putting [G:affecting:name] into the cryo pod.", 3)

			if(do_after(user, 20))
				if(!M || !G || !G:affecting) return

				M.loc = src

				if(M.client)
					M.client.perspective = EYE_PERSPECTIVE
					M.client.eye = src

			if(orient_right)
				icon_state = "body_scanner_1-r"
			else
				icon_state = "body_scanner_1"

			M << "\blue You feel cool air surround you. You go numb as your senses turn inward."
			M << "\blue <b>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</b>"
			occupant = M
			time_entered = world.time

			// Book keeping!
			log_admin("[key_name_admin(M)] has entered a stasis pod.")
			message_admins("\blue [key_name_admin(M)] has entered a stasis pod.")

			//Despawning occurs when process() is called with an occupant without a client.
			src.add_fingerprint(M)

/obj/machinery/cryopod/verb/eject()
	set name = "Eject Pod"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return

	if(orient_right)
		icon_state = "body_scanner0-r"
	else
		icon_state = "body_scanner0"

	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/cryopod/verb/move_inside()
	set name = "Enter Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0 || !(ishuman(usr) || ismonkey(usr)))
		return

	if(src.occupant)
		usr << "\blue <B>The cryo pod is in use.</B>"
		return

	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			usr << "You're too busy getting your life sucked out of you."
			return

	visible_message("[usr] starts climbing into the sleeper.", 3)

	if(do_after(usr, 20))

		if(!usr || !usr.client)
			return

		if(src.occupant)
			usr << "\blue <B>The cryo pod is in use.</B>"
			return

		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.loc = src
		src.occupant = usr

		if(orient_right)
			icon_state = "body_scanner_1-r"
		else
			icon_state = "body_scanner_1"

		usr << "\blue You feel cool air surround you. You go numb as your senses turn inward."
		usr << "\blue <b>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</b>"
		occupant = usr
		time_entered = world.time

		src.add_fingerprint(usr)

	return

/obj/machinery/cryopod/proc/go_out()

	if(!occupant)
		return

	if(occupant.client)
		occupant.client.eye = src.occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE

	occupant.loc = get_turf(src)
	occupant = null

	if(orient_right)
		icon_state = "body_scanner_0-r"
	else
		icon_state = "body_scanner_0"

	return


//Attacks/effects.
/obj/machinery/cryopod/blob_act()
	return //Sorta gamey, but we don't really want these to be destroyed.