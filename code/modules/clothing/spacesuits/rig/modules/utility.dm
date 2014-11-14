/* Contains:
 * /obj/item/rig_module/device
 * /obj/item/rig_module/device/plasma_cutter
 * /obj/item/rig_module/device/injector
 * /obj/item/rig_module/device/healthscanner
 * /obj/item/rig_module/device/drill
 * /obj/item/rig_module/device/orescanner
 * /obj/item/rig_module/maneuvering_jets
 * /obj/item/rig_module/foam_sprayer
 * /obj/item/rig_module/device/broadcaster
 * /obj/item/rig_module/chem_dispenser
 * /obj/item/rig_module/voice
 */

/obj/item/rig_module/chem_dispenser
	name = "mounted chemical dispenser"
	desc = "A complex web of tubing and needles suitable for hardsuit use."
	usable = 1
	selectable = 0
	toggleable = 0
	disruptive = 0

	interface_name = "integrated chemical dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the wearer's bloodstream."

	charges = list(
		list("tricordrazine", "tricordrazine", 0, 80),
		list("tramadol",      "tramadol",      0, 80),
		list("dexalin plus",  "dexalinp",      0, 80),
		list("antibiotics",   "spaceacillin",  0, 80),
		list("antitoxins",    "anti_toxin",    0, 80),
		list("nutrients",     "nutriment",     0, 80),
		list("hyronalin",     "hyronalin",     0, 80),
		list("radium",        "radium",        0, 80)
		)

	var/max_reagent_volume = 80 //Used when refilling.

/obj/item/rig_module/chem_dispenser/accepts_item(var/obj/item/input_item, var/mob/living/user)

	if(!input_item.is_open_container())
		return 0

	if(!input_item.reagents || !input_item.reagents.total_volume)
		user << "\The [input_item] is empty."
		return 0

	// Magical chemical filtration system, do not question it.
	var/total_transferred = 0
	for(var/datum/reagent/R in input_item.reagents.reagent_list)
		for(var/chargetype in charges)
			var/datum/rig_charge/charge = charges[chargetype]
			if(charge.display_name == R.id)

				var/chems_to_transfer = R.volume

				if((charge.charges + chems_to_transfer) > max_reagent_volume)
					chems_to_transfer = max_reagent_volume - charge.charges

				charge.charges += chems_to_transfer
				input_item.reagents.remove_reagent(R.id, chems_to_transfer)
				total_transferred += chems_to_transfer

				break

	if(total_transferred)
		user << "<font color='blue'>You transfer [total_transferred] units into the suit reservoir.</font>"
	else
		user << "<span class='danger'>None of the reagents seem suitable.</span>"
	return 1

/obj/item/rig_module/chem_dispenser/engage(atom/target)

	if(!..())
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	if(!charge_selected)
		H << "<span class='danger'>You have not selected a chemical type.</span>"
		return 0

	var/datum/rig_charge/charge = charges[charge_selected]

	if(!charge)
		return 0

	var/chems_to_use = 10
	if(charge.charges <= 0)
		H << "<span class='danger'>Insufficient chems!</span>"
		return 0
	else if(charge.charges < chems_to_use)
		chems_to_use = charge.charges

	var/mob/living/target_mob
	if(target)
		if(istype(target,/mob/living))
			target_mob = target
		else
			return 0
	else
		target_mob = H

	if(target_mob != H)
		H << "<span class='danger'>You inject [target_mob] with [chems_to_use] unit[chems_to_use == 1 ? "" : "s"] of [charge.display_name].</span>"
	target_mob << "<span class='danger'>You feel a rushing in your veins as [chems_to_use] unit[chems_to_use == 1 ? "" : "s"] of [charge.display_name] [chems_to_use == 1 ? "is" : "are"] injected.</span>"
	target_mob.reagents.add_reagent(charge.display_name, chems_to_use)

	charge.charges -= chems_to_use
	if(charge.charges < 0) charge.charges = 0

	return 1

/obj/item/rig_module/chem_dispenser/injector

	name = "mounted chemical injector"
	desc = "A complex web of tubing and a large needle suitable for hardsuit use."
	usable = 0
	selectable = 1
	disruptive = 1

	interface_name = "mounted chem injector"
	interface_desc = "Dispenses loaded chemicals via an arm-mounted injector."

/obj/item/rig_module/voice

	name = "hardsuit voice synthesiser"
	desc = "A speaker box and sound processor."
	usable = 1
	selectable = 0
	toggleable = 0
	disruptive = 0

	interface_name = "voice synthesiser"
	interface_desc = "A flexible and powerful voice modulator system."

	var/obj/item/voice_changer/voice_holder

/obj/item/rig_module/voice/New()
	..()
	voice_holder = new(src)
	voice_holder.active = 0

/obj/item/rig_module/voice/installed()
	..()
	holder.speech = src

/obj/item/rig_module/voice/engage()

	if(!..())
		return 0

	var/choice= input("Would you like to toggle the synthesiser or set the name?") as null|anything in list("Enable","Disable","Set Name")

	if(!choice)
		return 0

	switch(choice)
		if("Enable")
			active = 1
			voice_holder.active = 1
			usr << "<font color='blue'>You enable the speech synthesiser.</font>"
		if("Disable")
			active = 0
			voice_holder.active = 0
			usr << "<font color='blue'>You disable the speech synthesiser.</font>"
		if("Set Name")
			var/raw_choice = input(usr, "Please enter a new name.")  as text|null
			if(!raw_choice)
				return 0
			voice_holder.voice = sanitize(copytext(raw_choice,1,MAX_MESSAGE_LEN))
			usr << "You are now mimicking <B>[voice_holder.voice]</B>.</font>"
	return 1