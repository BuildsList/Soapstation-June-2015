//DIONA ORGANS.
/obj/item/organ/diona/process()
	return

/obj/item/organ/diona/strata
	name = "neural strata"
	parent_organ = "chest"

/obj/item/organ/diona/bladder
	name = "gas bladder"
	parent_organ = "head"

/obj/item/organ/diona/polyp
	name = "polyp segment"
	parent_organ = "groin"

/obj/item/organ/diona/ligament
	name = "anchoring ligament"
	parent_organ = "groin"

/obj/item/organ/diona/node
	name = "receptor node"
	parent_organ = "head"

/obj/item/organ/diona/nutrients
	name = "nutrient vessel"
	parent_organ = "chest"

/obj/item/organ/diona
	name = "diona nymph"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	organ_tag = "special" // Turns into a nymph instantly, no transplanting possible.

/obj/item/organ/diona/removed(var/mob/living/target,var/mob/living/user)

	..()
	var/mob/living/carbon/human/H = target
	if(!istype(target))
		del(src)

	if(!H.internal_organs.len)
		H.death()

	//This is a terrible hack and I should be ashamed.
	var/datum/seed/diona = plant_controller.seeds["diona"]
	if(!diona)
		del(src)

	spawn(1) // So it has time to be thrown about by the gib() proc.
		var/mob/living/carbon/alien/diona/D = new(get_turf(src))
		diona.request_player(D)
		del(src)

// These are different to the standard diona organs as they have a purpose in other
// species (absorbing radiation and light respectively)
/obj/item/organ/diona/nutrients
	name = "nutrient vessel"
	organ_tag = "nutrient vessel"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

/obj/item/organ/diona/nutrients/removed()
	return

/obj/item/organ/diona/node
	name = "receptor node"
	organ_tag = "receptor node"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

/obj/item/organ/diona/node/removed()
	return

//CORTICAL BORER ORGANS.
/obj/item/organ/borer
	name = "cortical borer"
	parent_organ = "head"
	vital = 1

/obj/item/organ/borer/process()

	// Borer husks regenerate health, feel no pain, and are resistant to stuns and brainloss.
	for(var/chem in list("tricordrazine","tramadol","hyperzine","alkysine"))
		if(owner.reagents.get_reagent_amount(chem) < 3)
			owner.reagents.add_reagent(chem, 5)

	// They're also super gross and ooze ichor.
	if(prob(5))
		var/mob/living/carbon/human/H = owner
		if(!istype(H))
			return

		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in H.vessel.reagent_list
		blood_splatter(H,B,1)
		var/obj/effect/decal/cleanable/blood/splatter/goo = locate() in get_turf(owner)
		if(goo)
			goo.name = "husk ichor"
			goo.desc = "It's thick and stinks of decay."
			goo.basecolor = "#412464"
			goo.update_icon()

/obj/item/organ/borer
	name = "cortical borer"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borer"
	organ_tag = "brain"
	desc = "A disgusting space slug."

/obj/item/organ/borer/removed(var/mob/living/target,var/mob/living/user)

	..()

	var/mob/living/simple_animal/borer/B = target.has_brain_worms()
	if(B)
		B.leave_host()
		B.ckey = target.ckey

	spawn(0)
		del(src)

//XENOMORPH ORGANS
/obj/item/organ/xenos/eggsac
	name = "egg sac"
	parent_organ = "groin"

/obj/item/organ/xenos/plasmavessel
	name = "plasma vessel"
	parent_organ = "chest"
	var/stored_plasma = 0
	var/max_plasma = 500

/obj/item/organ/xenos/plasmavessel/queen
	name = "bloated plasma vessel"
	stored_plasma = 200
	max_plasma = 500

/obj/item/organ/xenos/plasmavessel/sentinel
	stored_plasma = 100
	max_plasma = 250

/obj/item/organ/xenos/plasmavessel/hunter
	name = "tiny plasma vessel"
	stored_plasma = 100
	max_plasma = 150

/obj/item/organ/xenos/acidgland
	name = "acid gland"
	parent_organ = "head"

/obj/item/organ/xenos/hivenode
	name = "hive node"
	parent_organ = "chest"

/obj/item/organ/xenos/resinspinner
	name = "resin spinner"
	parent_organ = "head"

/obj/item/organ/xenos
	name = "xeno organ"
	icon = 'icons/effects/blood.dmi'
	desc = "It smells like an accident in a chemical factory."

/obj/item/organ/xenos/eggsac
	name = "egg sac"
	icon_state = "xgibmid1"
	organ_tag = "egg sac"

/obj/item/organ/xenos/plasmavessel
	name = "plasma vessel"
	icon_state = "xgibdown1"
	organ_tag = "plasma vessel"

/obj/item/organ/xenos/acidgland
	name = "acid gland"
	icon_state = "xgibtorso"
	organ_tag = "acid gland"

/obj/item/organ/xenos/hivenode
	name = "hive node"
	icon_state = "xgibmid2"
	organ_tag = "hive node"

/obj/item/organ/xenos/resinspinner
	name = "hive node"
	icon_state = "xgibmid2"
	organ_tag = "resin spinner"

//VOX ORGANS.
/obj/item/organ/stack
	name = "cortical stack"
	parent_organ = "head"
	robotic = 2
	vital = 1
	var/backup_time = 0
	var/datum/mind/backup

/obj/item/organ/stack/process()
	if(owner && owner.stat != 2 && !is_broken())
		backup_time = world.time
		if(owner.mind) backup = owner.mind

/obj/item/organ/stack/vox

/obj/item/organ/stack/vox/stack

/obj/item/organ/stack
	name = "cortical stack"
	icon_state = "brain-prosthetic"
	organ_tag = "stack"
	robotic = 2

/obj/item/organ/stack/vox
	name = "vox cortical stack"