/*
 * Contains
 * /obj/item/rig_module/ai_container
 * /obj/item/rig_module/datajack
 * /obj/item/rig_module/power_sink
 * /obj/item/rig_module/electrowarfare_suite
 */

/obj/item/ai_verbs
	name = "AI verb holder"

/obj/item/ai_verbs/verb/hardsuit_interface()
	set category = "Hardsuit"
	set name = "Open Hardsuit Interface"
	set src in usr

	if(!usr.loc || !usr.loc.loc || !istype(usr.loc.loc, /obj/item/rig_module))
		usr << "You are not loaded into a hardsuit."
		return

	var/obj/item/rig_module/module = usr.loc.loc
	if(!module.holder)
		usr << "Your module is not installed in a hardsuit."
		return

	module.holder.ui_interact(usr)

/obj/item/rig_module/ai_container

	name = "IIS module"
	desc = "An integrated intelligence system module suitable for most hardsuits."
	toggleable = 1
	usable = 1
	disruptive = 0
	activates_on_touch = 1

	engage_string = "Eject AI"
	activate_string = "Enable Dataspike"
	deactivate_string = "Disable Dataspike"

	interface_name = "integrated intelligence system"
	interface_desc = "A socket that supports a range of artificial intelligence systems."

	var/mob/integrated_ai // Direct reference to the actual mob held in the suit.
	var/obj/item/ai_card  // Reference to the MMI, posibrain, intellicard or pAI card previously holding the AI.
	var/obj/item/ai_verbs/verb_holder

/obj/item/rig_module/ai_container/proc/update_verb_holder()
	if(!verb_holder)
		verb_holder = new(src)
	if(integrated_ai)
		verb_holder.loc = integrated_ai
	else
		verb_holder.loc = src

/obj/item/rig_module/ai_container/accepts_item(var/obj/item/input_device, var/mob/living/user)

	// Check if there's actually an AI to deal with.
	var/mob/living/silicon/ai/target_ai
	if(istype(input_device, /mob/living/silicon/ai))
		target_ai = input_device
	else
		target_ai = locate(/mob/living/silicon/ai) in input_device.contents

	var/obj/item/device/aicard/card = ai_card

	// Downloading from/loading to a terminal.
	if(istype(input_device,/obj/machinery/computer/aifixer) || istype(input_device,/mob/living/silicon/ai) || istype(input_device,/obj/structure/AIcore/deactivated))

		// If we're stealing an AI, make sure we have a card for it.
		if(!card)
			card = new /obj/item/device/aicard(src)

		// Terminal interaction only works with an intellicarded AI.
		if(!istype(card))
			return 0

		// Since we've explicitly checked for three types, this should be safe.
		input_device.attackby(card,user)

		// If the transfer failed we can delete the card.
		if(locate(/mob/living/silicon/ai) in card)
			ai_card = card
			integrated_ai = locate(/mob/living/silicon/ai) in card
		else
			eject_ai()
		update_verb_holder()
		return 1

	if(istype(input_device,/obj/item/device/aicard))
		// We are carding the AI in our suit.
		if(integrated_ai)
			integrated_ai.attackby(input_device,user)
			// If the transfer was successful, we can clear out our vars.
			if(integrated_ai.loc != src)
				integrated_ai = null
				eject_ai()
		else
			// You're using an empty card on an empty suit, idiot.
			if(!target_ai)
				return 0
			integrate_ai(input_device,user)
		return 1

	// Okay, it wasn't a terminal being touched, check for all the simple insertions.
	if(input_device.type in list(/obj/item/device/paicard, /obj/item/device/mmi, /obj/item/device/mmi/digital/posibrain))
		integrate_ai(input_device,user)
		return 1

	return 0

/obj/item/rig_module/ai_container/engage(atom/target)

	if(!..())
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	if(!target)
		if(ai_card)
			if(istype(ai_card,/obj/item/device/aicard))
				ai_card.attack_self(H)
			else
				eject_ai(H)
		update_verb_holder()
		return 1

	if(accepts_item(target,H))
		return 1

	return 0

/obj/item/rig_module/ai_container/removed()
	eject_ai()
	..()

/obj/item/rig_module/ai_container/proc/eject_ai(var/mob/user)

	if(ai_card)
		if(istype(ai_card, /obj/item/device/aicard))
			if(integrated_ai && integrated_ai.client)
				if(user)
					user << "<span class='danger'>You cannot eject your currently stored AI. Purge it manually.</span>"
				return 0
			del(ai_card)
		else if(user)
			user.put_in_hands(ai_card)
		else
			ai_card.loc = get_turf(src)
	ai_card = null
	integrated_ai = null
	update_verb_holder()

/obj/item/rig_module/ai_container/proc/integrate_ai(var/obj/item/ai,var/mob/user)

	if(!ai) return

	// The ONLY THING all the different AI systems have in common is that they all store the mob inside an item.
	var/mob/living/ai_mob = locate(/mob/living) in ai.contents
	if(ai_mob)

		if(ai_mob.key && ai_mob.client)

			if(istype(ai, /obj/item/device/aicard))

				if(!ai_card)
					ai_card = new /obj/item/device/aicard(src)

				var/obj/item/device/aicard/source_card = ai
				var/obj/item/device/aicard/target_card = ai_card
				if(istype(source_card) && istype(target_card))
					if(target_card.grab_ai(ai_mob, user))
						source_card.clear()
					else
						return 0
				else
					return 0
			else
				user.drop_from_inventory(ai)
				ai.loc = src
				ai_card = ai
				ai_mob << "<font color='blue'>You have been transferred to \the [holder]'s [src].</font>"
				user << "<font color='blue'>You load [ai_mob] into \the [holder]'s [src].</font>"

			integrated_ai = ai_mob

			if(!(locate(integrated_ai) in ai_card))
				integrated_ai = null
				eject_ai()
		else
			user << "<span class='warning'>There is no active AI within \the [ai].</span>"
	else
		user << "<span class='warning'>There is no active AI within \the [ai].</span>"
	update_verb_holder()
	return

/obj/item/rig_module/datajack

	name = "datajack module"
	desc = "A simple induction datalink module."
	toggleable = 1
	activates_on_touch = 1
	usable = 0

	activate_string = "Enable Datajack"
	deactivate_string = "Disable Datajack"

	interface_name = "contact datajack"
	interface_desc = "An induction-powered high-throughput datalink suitable for hacking encrypted networks."
	var/list/stored_research

/obj/item/rig_module/datajack/New()
	..()
	stored_research = list()

/obj/item/rig_module/datajack/engage(atom/target)

	if(!..())
		return 0

	if(target)
		var/mob/living/carbon/human/H = holder.wearer
		if(!accepts_item(target,H))
			return 0
	return 1

/obj/item/rig_module/datajack/accepts_item(var/obj/item/input_device, var/mob/living/user)

	if(istype(input_device,/obj/item/weapon/disk/tech_disk))
		user << "You slot the disk into [src]."
		var/obj/item/weapon/disk/tech_disk/disk = input_device
		if(disk.stored)
			if(load_data(disk.stored))
				user << "<font color='blue'>Download successful; disk erased.</font>"
				disk.stored = null
			else
				user << "<span class='warning'>The disk is corrupt. It is useless to you.</span>"
		else
			user << "<span class='warning'>The disk is blank. It is useless to you.</span>"
		return 1

	// I fucking hate R&D code. This typecheck spam would be totally unnecessary in a sane setup.
	else if(istype(input_device,/obj/machinery))
		var/datum/research/incoming_files
		if(istype(input_device,/obj/machinery/computer/rdconsole))
			var/obj/machinery/computer/rdconsole/input_machine = input_device
			incoming_files = input_machine.files
		else if(istype(input_device,/obj/machinery/r_n_d/server))
			var/obj/machinery/r_n_d/server/input_machine = input_device
			incoming_files = input_machine.files
		else if(istype(input_device,/obj/machinery/mecha_part_fabricator))
			var/obj/machinery/mecha_part_fabricator/input_machine = input_device
			incoming_files = input_machine.files

		if(!incoming_files || !incoming_files.known_tech || !incoming_files.known_tech.len)
			user << "<span class='warning'>Memory failure. There is nothing accessible stored on this terminal.</span>"
		else
			// Maybe consider a way to drop all your data into a target repo in the future.
			if(load_data(incoming_files.known_tech))
				user << "<font color='blue'>Download successful; local and remote repositories synchronized.</font>"
			else
				user << "<span class='warning'>Scan complete. There is nothing useful stored on this terminal.</span>"
		return 1
	return 0

/obj/item/rig_module/datajack/proc/load_data(var/incoming_data)

	if(islist(incoming_data))
		for(var/entry in incoming_data)
			load_data(entry)
		return 1

	if(istype(incoming_data, /datum/tech))
		var/data_found
		var/datum/tech/new_data = incoming_data
		for(var/datum/tech/current_data in stored_research)
			if(current_data.id == new_data.id)
				data_found = 1
				if(current_data.level < new_data.level)
					current_data.level = new_data.level
				break
		if(!data_found)
			stored_research += incoming_data
		return 1
	return 0

/obj/item/rig_module/electrowarfare_suite

	name = "electrowarfare module"
	desc = "A bewilderingly complex bundle of fiber optics and chips."
	toggleable = 1
	usable = 0

	activate_string = "Enable Countermeasures"
	deactivate_string = "Disable Countermeasures"

	interface_name = "electrowarfare system"
	interface_desc = "An active counter-electronic warfare suite that disrupts AI tracking."

/obj/item/rig_module/electrowarfare_suite/activate()

	if(!..())
		return

	// This is not the best way to handle this, but I don't want it to mess with ling camo
	var/mob/living/M = holder.wearer
	M.digitalcamo++

/obj/item/rig_module/electrowarfare_suite/deactivate()

	if(!..())
		return

	var/mob/living/M = holder.wearer
	M.digitalcamo = max(0,(M.digitalcamo-1))

/obj/item/rig_module/power_sink

	name = "hardsuit power sink"
	desc = "An heavy-duty power sink."
	toggleable = 1
	activates_on_touch = 1
	disruptive = 0

	activate_string = "Enable Power Sink"
	deactivate_string = "Disable Power Sink"

	interface_name = "niling d-sink"
	interface_desc = "Colloquially known as a power siphon, this module drains power through the suit hands into the suit battery."

	var/atom/interfaced_with // Currently draining power from this device.
	var/total_power_drained = 0

/obj/item/rig_module/power_sink/deactivate()

	if(interfaced_with)
		if(holder && holder.wearer)
			holder.wearer << "<span class = 'warning'>Your power sink retracts as the module deactivates.</span>"
		drain_complete()
	interfaced_with = null
	total_power_drained = 0
	return ..()

/obj/item/rig_module/power_sink/activate()
	interfaced_with = null
	total_power_drained = 0
	return ..()

/obj/item/rig_module/power_sink/engage(atom/target)

	if(!..())
		return 0

	//Target wasn't supplied or we're already draining.
	if(interfaced_with)
		return 0

	if(!target)
		return 1

	// Are we close enough?
	var/mob/living/carbon/human/H = holder.wearer
	if(!target.Adjacent(H))
		return 0

	// Is it a valid power source?
	if(target.drain_power(1) <= 0)
		return 0

	H << "<span class = 'danger'>You begin draining power from [target]!</span>"
	interfaced_with = target

	holder.spark_system.start()
	playsound(H.loc, 'sound/effects/sparks2.ogg', 50, 1)

	return 1

/obj/item/rig_module/power_sink/accepts_item(var/obj/item/input_device, var/mob/living/user)
	var/can_drain = input_device.drain_power(1)
	if(can_drain > 0)
		engage(input_device)
		return 1
	return 0

/obj/item/rig_module/power_sink/process()

	if(!interfaced_with)
		return ..()

	var/mob/living/carbon/human/H
	if(holder && holder.wearer)
		H = holder.wearer

	if(!H || !istype(H))
		return 0

	holder.spark_system.start()
	playsound(H.loc, 'sound/effects/sparks2.ogg', 50, 1)

	if(!holder.cell)
		H << "<span class = 'danger'>Your power sink flashes an error; there is no cell in your rig.</span>"
		drain_complete(H)
		return

	if(!interfaced_with || !interfaced_with.Adjacent(H))
		H << "<span class = 'warning'>Your power sink retracts into its casing.</span>"
		drain_complete(H)
		return

	var/target_drained = interfaced_with.drain_power()
	if(target_drained <= 0)
		H << "<span class = 'danger'>Your power sink flashes a red light; there is no power left in [interfaced_with].</span>"
		drain_complete(H)
		return

	holder.cell.charge += target_drained
	total_power_drained += target_drained

	if(holder.cell.charge > holder.cell.maxcharge)
		H << "<span class = 'warning'>Your power sink flashes an amber light; your rig cell is full.</span>"
		holder.cell.charge = holder.cell.maxcharge
		drain_complete(H)
		return

	return 1

/obj/item/rig_module/power_sink/proc/drain_complete(var/mob/living/M)

	if(!interfaced_with)
		if(M) M << "<font color='blue'><b>Total power drained:</b> [total_power_drained]W.</font>"
	else
		if(M) M << "<font color='blue'><b>Total power drained from [interfaced_with]:</b> [total_power_drained]W.</font>"
		interfaced_with.drain_power(0,1) // Damage the victim.

	interfaced_with = null
	total_power_drained = 0