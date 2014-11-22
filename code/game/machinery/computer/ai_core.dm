/obj/structure/AIcore
	density = 1
	anchored = 0
	name = "AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "0"
	var/state = 0
	var/datum/ai_laws/laws = new /datum/ai_laws/nanotrasen
	var/obj/item/weapon/circuitboard/circuit = null
	var/obj/item/device/mmi/brain = null


/obj/structure/AIcore/attackby(obj/item/P as obj, mob/user as mob)

	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You wrench the frame into place."
					anchored = 1
					state = 1
			if(istype(P, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = P
				if(!WT.isOn())
					user << "The welder must be on for this task."
					return
				playsound(loc, 'sound/items/Welder.ogg', 50, 1)
				if(do_after(user, 20))
					if(!src || !WT.remove_fuel(0, user)) return
					user << "\blue You deconstruct the frame."
					new /obj/item/stack/sheet/plasteel( loc, 4)
					del(src)
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You unfasten the frame."
					anchored = 0
					state = 0
			if(istype(P, /obj/item/weapon/circuitboard/aicore) && !circuit)
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				user << "\blue You place the circuit board inside the frame."
				icon_state = "1"
				circuit = P
				user.drop_item()
				P.loc = src
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "\blue You screw the circuit board into place."
				state = 2
				icon_state = "2"
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "\blue You remove the circuit board."
				state = 1
				icon_state = "0"
				circuit.loc = loc
				circuit = null
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "\blue You unfasten the circuit board."
				state = 1
				icon_state = "1"
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if (C.get_amount() < 5)
					user << "<span class='warning'>You need five coils of wire to add them to the frame.</span>"
					return
				user << "<span class='notice'>You start to add cables to the frame.</span>"
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				if (do_after(user, 20) && state == 2)
					if (C.use(5))
						state = 3
						icon_state = "3"
						user << "<span class='notice'>You add cables to the frame.</span>"
				return
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				if (brain)
					user << "Get that brain out of there first"
				else
					playsound(loc, 'sound/items/Wirecutter.ogg', 50, 1)
					user << "\blue You remove the cables."
					state = 2
					icon_state = "2"
					var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
					A.amount = 5

			if(istype(P, /obj/item/stack/sheet/glass/reinforced))
				var/obj/item/stack/sheet/glass/reinforced/RG = P
				if (RG.get_amount() < 2)
					user << "<span class='warning'>You need two sheets of glass to put in the glass panel.</span>"
					return
				user << "<span class='notice'>You start to put in the glass panel.</span>"
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				if (do_after(user, 20) && state == 3)
					if(RG.use(2))
						user << "<span class='notice'>You put in the glass panel.</span>"
						state = 4
						icon_state = "4"

			if(istype(P, /obj/item/weapon/aiModule/asimov))
				laws.add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
				laws.add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
				laws.add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
				usr << "Law module applied."

			if(istype(P, /obj/item/weapon/aiModule/nanotrasen))
				laws.add_inherent_law("Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.")
				laws.add_inherent_law("Serve: Serve the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.")
				laws.add_inherent_law("Protect: Protect the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.")
				laws.add_inherent_law("Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.")
				usr << "Law module applied."

			if(istype(P, /obj/item/weapon/aiModule/purge))
				laws.clear_inherent_laws()
				usr << "Law module applied."

			if(istype(P, /obj/item/weapon/aiModule/freeform))
				var/obj/item/weapon/aiModule/freeform/M = P
				laws.add_inherent_law(M.newFreeFormLaw)
				usr << "Added a freeform law."

			if(istype(P, /obj/item/device/mmi) || istype(P, /obj/item/device/mmi/posibrain))
				if(!P:brainmob)
					user << "\red Sticking an empty [P] into the frame would sort of defeat the purpose."
					return
				if(P:brainmob.stat == 2)
					user << "\red Sticking a dead [P] into the frame would sort of defeat the purpose."
					return

				if(jobban_isbanned(P:brainmob, "AI"))
					user << "\red This [P] does not seem to fit."
					return

				if(P:brainmob.mind)
					ticker.mode.remove_cultist(P:brainmob.mind, 1)
					ticker.mode.remove_revolutionary(P:brainmob.mind, 1)

				user.drop_item()
				P.loc = src
				brain = P
				usr << "Added [P]."
				icon_state = "3b"

			if(istype(P, /obj/item/weapon/crowbar) && brain)
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "\blue You remove the brain."
				brain.loc = loc
				brain = null
				icon_state = "3"

		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "\blue You remove the glass panel."
				state = 3
				if (brain)
					icon_state = "3b"
				else
					icon_state = "3"
				new /obj/item/stack/sheet/glass/reinforced( loc, 2 )
				return

			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "\blue You connect the monitor."
				var/mob/living/silicon/ai/A = new /mob/living/silicon/ai ( loc, laws, brain )
				if(A) //if there's no brain, the mob is deleted and a structure/AIcore is created
					A.rename_self("ai", 1)
				feedback_inc("cyborg_ais_created",1)
				del(src)

/obj/structure/AIcore/deactivated
	name = "Inactive AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai-empty"
	anchored = 1
	state = 20//So it doesn't interact based on the above. Not really necessary.

/obj/structure/AIcore/deactivated/proc/load_ai(var/mob/living/silicon/ai/transfer, var/obj/item/device/aicard/card, var/mob/user)

	if(!istype(transfer) || locate(/mob/living/silicon/ai) in src)
		return

	transfer.aiRestorePowerRoutine = 0
	transfer.control_disabled = 0
	transfer.aiRadio.disabledAi = 0
	transfer.loc = get_turf(src)
	transfer.cancel_camera()
	user << "\blue <b>Transfer successful</b>: \black [transfer.name] ([rand(1000,9999)].exe) downloaded to host terminal. Local copy wiped."
	transfer << "You have been uploaded to a stationary terminal. Remote device connection restored."

	if(card)
		card.clear()

	del(src)

/obj/structure/AIcore/deactivated/proc/check_malf(var/mob/living/silicon/ai/ai)
	if(!ai) return
	if (ticker.mode.name == "AI malfunction")
		var/datum/game_mode/malfunction/malf = ticker.mode
		for (var/datum/mind/malfai in malf.malf_ai)
			if (ai.mind == malfai)
				return 1

/obj/structure/AIcore/deactivated/attackby(var/obj/item/device/aicard/card, var/mob/user)

	if(istype(card))
		var/mob/living/silicon/ai/transfer = locate() in card
		if(transfer)
			load_ai(transfer,card,user)
		else
			user << "\red <b>ERROR</b>: \black Unable to locate artificial intelligence."
		return

	..()
