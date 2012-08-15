//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05

/*
CONTAINS:
RETRACTOR
HEMOSTAT
CAUTERY
SURGICAL DRILL
SCALPEL
CIRCULAR SAW

*/
#define SRG_ALIEN 0
#define SRG_LIMB 1
#define SRG_EYE 2
#define SRG_FACE 3
#define SRG_BONE 4
#define SRG_APPENDIX 5
/*
All tools have function that handles interruptions during surgery.
Called when surgeon interupted operation, or was interrupted (was not there with tool in hand when do_after timer came up)

[TOOL PATH]/proc/interrupt(mob/living/carbon/human/H as mob, mob/living/user as mob, type)
	switch (type)
		if(SRG_ALIEN)
			switch(M:embryo_op_stage)
				if (1.0)
					do something bad to the patient
		if(SRG_LIMB)
		if(SRG_EYE)
		if(SRG_FACE)
		if(SRG_BONE)
		if(SRG_APPENDIX)
*/


//Checks for face/head/eyes covering items
//Returns 1 if NO head surgery is impossible
//Returns 2 if BRAIN surgery is possible
//Returns 0 if ALL kinds of head surgery are possible
/proc/surgery_is_face_covered(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	var/mob/living/carbon/human/H = M
	if(istype(H) && ( \
		(H.head && H.head.flags & HEADCOVERSEYES) || \
		(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
		(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) 	))
		user << "\red You're going to need to remove that mask/helmet/glasses first."
		return 1
	var/mob/living/carbon/monkey/Mo = M
	if(istype(Mo) && ( (Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) ))
		user << "\red You're going to need to remove that mask/helmet/glasses first."
		return 1
	if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/metroid))//Aliens don't have eyes./N
		user << "\red You cannot locate eyes or face on this creature!"
		return 2
	return 0

/////////////
//RETRACTOR//
/////////////
/obj/item/weapon/retractor/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	var/mob/living/carbon/human/H = M
	if (!H || !istype(H))
		return
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
	if(user.zone_sel.selecting == "mouth" || user.zone_sel.selecting == "eyes")
		S = H.organs["head"]
	if (!S)
		return

	//checks for face covering items
	if(user.zone_sel.selecting == "mouth" || user.zone_sel.selecting == "eyes")
		if (surgery_is_face_covered(H,user))
			return

	if(((user.zone_sel.selecting == "l_arm") || (user.zone_sel.selecting == "r_arm") || \
		(user.zone_sel.selecting == "l_leg") || (user.zone_sel.selecting == "r_leg")) 	\
		& (istype(M, /mob/living/carbon/human)))
		if(limb_surgery(M,user))
			return

	if(user.zone_sel.selecting == "chest")
		if(larva_surgery(M,user))
			return

	if(user.zone_sel.selecting == "groin")
		if(appendix_surgery(M,user))
			return

	if (user.zone_sel.selecting == "eyes")
		if (eye_surgery(M,user))
			return

	if(user.zone_sel.selecting == "mouth")
		if (face_surgery(M,user))
			return
	//If it's not other types of surgery, must be broken bone
	if(!try_bone_surgery(M, user) && user.a_intent == "hurt") // if we call ..(), we'll attack them, so require a hurt intent
		return ..()

/obj/item/weapon/retractor/proc/limb_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	var/datum/organ/external/S = M.organs[user.zone_sel.selecting]
	if (!S)
		return 0
	if(S.status & ORGAN_DESTROYED)
		if(S.status & ORGAN_BLEEDING)
			user << "\red There's too much blood here!"
			return 0
		if(!(S.status & ORGAN_CUT_AWAY))
			user << "\red The flesh hasn't been cleanly cut!"
			return 0
		M.visible_message( \
			"\red [user] is beginning reposition flesh and nerve endings where [M]'s [S.display_name] used to be with [src].", \
			"\red [user] begins to reposition flesh and nerve endings where [S.display_name] used to be with [src]!")
		if(do_mob(user, M, 100))
			M.visible_message( \
				"\red [user] finishes repositioning flesh and nerve endings where [M]'s [S.display_name] used to be with [src]!", \
				"\red [user] finishes repositioning flesh and nerve endings where your [S.display_name] used to be with [src]!")
			S.open = 3
			M.updatehealth()
			M.UpdateDamageIcon()
			return 1
		else
			interrupt(M,user,SRG_LIMB)
			return 0
	return 0

/obj/item/weapon/retractor/proc/appendix_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if(!H || !istype(H))
		return 0
	if (H.appendix_op_stage == 2)
		if (try_bone_surgery(H,user))
			H.appendix_op_stage = 3.0
			return 1
		else
			return 0

/obj/item/weapon/retractor/proc/larva_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	switch(M:embryo_op_stage)
		if(2.0)
			if (try_bone_surgery(M,user))
				M:embryo_op_stage = 3.0
				return	1
			else
				return 0
		if(4.0)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [user] starts ripping the larva out of [M]'s torso!", 1)
			M << "\red [user] starts ripping the larva out of [M]'s torso!"
			user << "\red You start ripping the larva out of [M]'s torso!"
			if(do_mob(user, M, 20))
				for(var/mob/O in (viewers(M) - user - M))
					O.show_message("\red [user] rips the larva out of [M]'s torso!", 1)
				M << "\red [user] rip the larva out of [M]'s torso!"
				user << "\red You rip the larva out of [M]'s torso!"

				var/mob/living/carbon/alien/larva/stupid = new(M.loc)
				stupid.death(0)
				//Make a larva and kill it. -- SkyMarshal
				M:embryo_op_stage = 5.0
				for(var/datum/disease/alien_embryo in M.viruses)
					alien_embryo.cure()
				return 1
			else
				interrupt(M,user,SRG_ALIEN)
				return 0
	return 0

/obj/item/weapon/retractor/proc/face_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	switch(M:face_op_stage)
		if(2.0)
			M.visible_message( \
					"\red [user] is beginning to retract the skin on [M]'s face and neck with [src].", \
					"\red [user] begins to retract the flap on your face and neck with [src]!")
			if(do_mob(user, M, 60))
				M.visible_message( \
					"\red [user] retracts the skin on [M]'s face and neck with [src]!", \
						"\red [user] retracts the skin on your face and neck with [src]!")
				M.face_op_stage = 3.0
			else
				interrupt(M,user,SRG_FACE)
				return 0
			M.updatehealth()
			M.UpdateDamageIcon()
			return 1
		if(4.0)
			M.visible_message( \
			"\red [user] is beginning to pull skin back into place on [M]'s face with [src].", \
			"\red [user] begins to pull skin back into place on your face with [src]!")

			if(do_mob(user, M, 90))
				M.visible_message( \
				"\red [user] pulls the skin back into place on [M]'s face with [src]!", \
				"\red [user] pulls the skin back into place on your face and neck with [src]!")

				M.face_op_stage = 5.0
			else
				interrupt(M,user,SRG_FACE)
				return 0
			M.updatehealth()
			M.UpdateDamageIcon()
			return 1
	return 0
/obj/item/weapon/retractor/proc/eye_surgery(mob/living/carbon/M as mob, mob/living/user as mob)
	switch(M.eye_op_stage)
		if(1.0)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [M] is having \his eyes retracted by [user].", 1)
			M << "\red [user] begins separating your eyes with [src]!"
			user << "\red You begin separating [M]'s eyes with [src]!"
			if(do_mob(user, M, 20))
				for(var/mob/O in (viewers(M) - user - M))
					O.show_message("\red [M] had \his eyes retracted by [user].", 1)
				M << "\red [user] to seperates your eyes with [src]!"
				user << "\red You seperate [M]'s eyes with [src]!"
				M:eye_op_stage = 2.0
				return 1
			else
				interrupt(M,user,SRG_EYE)
				return 0
	return 0

/obj/item/weapon/retractor/proc/try_bone_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if(!istype(H))
		return 0

	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
	if(!S || !istype(S))
		return 0

	if(S.status & ORGAN_DESTROYED)
		return 0

	if(S.status & ORGAN_ROBOT)
		user << "Medical equipment for a robot arm?  How would that do any good..."
		return 0

	if(!S.open)
		user << "\red There is skin in the way!"
		return 0

	if(S.status & ORGAN_BLEEDING)
		user << "\red [H] is profusely bleeding in \his [S.display_name]!"
		return 0

	if(S.open > 1)
		user << "\red Wound is already open fully!"
		return 0

	H.visible_message( \
		"\red [user] is beginning to retract the flap in the wound in [H]'s [S.display_name] with [src].", \
		"\red [user] begins to retract the flap in the wound in your [S.display_name] with [src]!")

	if(do_mob(user, H, 30))
		H.visible_message( \
			"\red [user] retracts the flap in the wound in [H]'s [S.display_name] with [src]!", \
			"\red [user] retracts the flap in the wound in your [S.display_name] with [src]!")

		S.open = 2

		H.updatehealth()
		H.UpdateDamageIcon()

	else
		interrupt(H,user,SRG_BONE)


	return 1

/obj/item/weapon/retractor/proc/interrupt(mob/living/carbon/human/H as mob, mob/living/user as mob, type)
	H.visible_message( "\red [user] quickly stops the surgery.", \
						"\red [user] quickly stops the surgery." )

////////////
//Hemostat//
////////////

/obj/item/weapon/hemostat/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	var/mob/living/carbon/human/H = M
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
	if(user.zone_sel.selecting == "mouth" || user.zone_sel.selecting == "eyes")
		S = H.organs["head"]

	if(!S || !istype(S))
		return ..()

	//checks for face covering items
	if(user.zone_sel.selecting == "mouth" || user.zone_sel.selecting == "eyes")
		if (surgery_is_face_covered(H,user))
			return

	if (user.zone_sel.selecting == "eyes")
		eye_surgery(M,user)
		return

	if(istype(M, /mob/living/carbon/human))

		if(((user.zone_sel.selecting == "l_arm") || (user.zone_sel.selecting == "r_arm") || (user.zone_sel.selecting == "l_leg") || (user.zone_sel.selecting == "r_leg")) & (istype(M, /mob/living/carbon/human)))
			if(limb_surgery(M,user))
				return

		if(user.zone_sel.selecting == "chest")
			if(larva_surgery(M,user))
				return

		if(user.zone_sel.selecting == "groin")
			if(appendix_surgery(M,user))
				return

		if(user.zone_sel.selecting == "mouth")
			if(face_surgery(M,user))
				return

	if(!try_bone_surgery(M, user) && user.a_intent == "hurt") // if we call ..(), we'll attack them, so require a hurt intent
		return ..()

/obj/item/weapon/hemostat/proc/limb_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if (!istype(H))
		return 0
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
	if (!S)
		return 0
	if(S.status & ORGAN_DESTROYED)
		if(!(S.status & ORGAN_BLEEDING))
			user << "\red There is nothing bleeding here!"
			return 0
		if(!(S.status & ORGAN_CUT_AWAY))
			user << "\red The flesh hasn't been cleanly cut!"
			return 0
		H.visible_message( \
			"\red [user] is beginning to clamp bleeders in the stump where [H]'s [S.display_name] used to be with [src].", \
			"\red [user] begins to clamp bleeders in the stump where [S.display_name] used to be with [src]!")
		if(do_mob(user, H, 100))
			H.visible_message( \
			"\red [user] finishes clamping bleeders in the stump where [H]'s [S.display_name] used to be with [src]!", \
			"\red [user] finishes clamping bleeders in the stump where your [S.display_name] used to be with [src]!")
			S.status &= ~ORGAN_BLEEDING
			H.updatehealth()
			H.UpdateDamageIcon()
			return 1
		else
			interrupt(H,user,SRG_LIMB)
			return 0

/obj/item/weapon/hemostat/proc/larva_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	if (!M || !istype(M))
		return 0
	switch(M:embryo_op_stage)
		if(1.0)
			if (try_bone_surgery(M,user))
				M:embryo_op_stage = 2.0
				return 1
			else
				return 0
		if(5.0)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [user] starts to clean out the debris from [M]'s cut open torso with [src].", 1)
			M << "\red [user] starts to clean out the debris in your torso with [src]!"
			user << "\red You start cleaning out the debris from in [M]'s torso with [src]!"
			if(do_mob(user, M, 60))
				for(var/mob/O in (viewers(M) - user - M))
					O.show_message("\red [user] cleans out the debris from [M]'s cut open torso with [src].", 1)
				M << "\red [user] clean out the debris in your torso with [src]!"
				user << "\red You clean out the debris from in [M]'s torso with [src]!"
				M:embryo_op_stage = 6.0
				return 1
			else
				interrupt(M,user,SRG_ALIEN)
				return 0
			return 1
	return 0
/obj/item/weapon/hemostat/proc/appendix_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	if (!M || !istype(M))
		return
	switch(M:appendix_op_stage)
		if(1.0)
			if (try_bone_surgery(M,user))
				M:appendix_op_stage = 2.0
				return 1
			else
				return 0
		if(4.0)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [user] is removing [M]'s appendix with [src].", 1)
			M << "\red [user] begins to remove your appendix with [src]!"
			user << "\red You begin to remove [M]'s appendix with [src]!"
			if(do_mob(user, M, 70))
				for(var/mob/O in (viewers(M) - user - M))
					O.show_message("\red [user] removed [M]'s appendix with [src].", 1)
				M << "\red [user] removes your appendix with [src]!"
				user << "\red You remove [M]'s appendix with [src]!"
				for(var/datum/disease/appendicitis/appendicitis in M.viruses)
					new /obj/item/weapon/appendixinflamed(get_turf(M))
					appendicitis.cure()
					M.resistances += appendicitis
					M:appendix_op_stage = 5.0
				return 1
			else
				interrupt(M,user,SRG_APPENDIX)
				return 0
	return 0
/obj/item/weapon/hemostat/proc/face_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	switch(M:face_op_stage)
		if(1.0)
			M.visible_message( \
				"\red [user] is beginning is beginning to clamp bleeders in [M]'s face and neck with [src].", \
				"\red [user] begins to clamp bleeders on your face and neck with [src]!")

			if(do_mob(user, M, 50))
				M.visible_message( \
					"\red [user] stops the bleeding on [M]'s face and neck with [src]!", \
					"\red [user] stops the bleeding on your face and neck with [src]!")

				M.face_op_stage = 2.0

				var/datum/organ/external/S = M.organs["head"]
				S.status &= ~ORGAN_BLEEDING
				M.updatehealth()
				M.UpdateDamageIcon()
				return 1
			else
				interrupt(M,user,SRG_FACE)
				return 0
		if(3.0)
			M.visible_message( \
				"\red [user] is beginning to reshape [M]'s vocal cords and face with [src].", \
				"\red [user] begins to reshape your vocal chords and face [src]!")

			if(do_mob(user, M, 120))
				M.visible_message( "\red Halfway there...", "\red Halfway there...")

			if(do_mob(user, M, 120))
				M.visible_message( \
					"\red [user] reshapes [M]'s vocal cords and face with [src]!", )

				M.face_op_stage = 4.0
				M.updatehealth()
				M.UpdateDamageIcon()
				return 1
			else
				interrupt(M,user,SRG_FACE)
			return 0
	return 0

/obj/item/weapon/hemostat/proc/eye_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	switch(M.eye_op_stage)
		if(2.0)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [user] begins to mend [user]'s eyes with [src].", 1)
			M << "\red [user] begins to mend your eyes with [src]!"
			user << "\red You begin to mend [M]'s eyes with [src]!"
			if(do_mob(user, M, 70))
				for(var/mob/O in (viewers(M) - user - M))
					O.show_message("\red [user] mends [user]'s eyes with [src].", 1)
				M << "\red [user] mends your eyes with [src]!"
				user << "\red You mend [M]'s eyes with [src]!"
				M:eye_op_stage = 3.0
			else
				interrupt(M,user,SRG_EYE)
			return

/obj/item/weapon/hemostat/proc/implant_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]

	H.visible_message( \
		"\red [user] is attempting to remove the implant in [H]'s [S.display_name] with \the [src].", \
		"\red [user] attempts to remove the implant in your [S.display_name] with \the [src]!")
	do
		if(do_mob(user, H, 50))
			if(prob(50))
				H.visible_message( \
					"\red [user] successfully removes the implant in [H]'s [S.display_name] with \a [src]!", \
					"\red [user] successfully removes the implant in your [S.display_name] with \the [src]!")
				var/obj/item/weapon/implant/implant = pick(S.implant)
				implant.loc = (get_turf(H))
				implant.implanted = 0
				S.implant.Remove(implant)
				playsound(user, 'squelch1.ogg', 50, 1)
				if(istype(implant, /obj/item/weapon/implant/explosive) || istype(implant, /obj/item/weapon/implant/uplink) || istype(implant, /obj/item/weapon/implant/dexplosive) || istype(implant, /obj/item/weapon/implant/explosive) || istype(implant, /obj/item/weapon/implant/compressed))
					usr << "The implant disintegrates into nothing..."
					del(implant)
					if(!S.implant.len)
						del S.implant
			else
				user.visible_message( \
					"\red [user] fails to remove the implant!", \
					"\red You fail to remove the implant!")
		else
			break
	while (S.implant && S.implant.len)

/obj/item/weapon/hemostat/proc/try_bone_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if(!istype(H))
		return 0
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]

	if(!S || !istype(S))
		return 0

	if(S.status & ORGAN_DESTROYED)
		return 0

	if(S.status & ORGAN_ROBOT)
		user << "Medical equipment for a robot arm?  How would that do any good?"
		return 0

	if(!S.open)
		user << "\red There is skin in the way!"
		return 0

	if(!(S.status & ORGAN_BLEEDING))
		if(S.implant)
			implant_surgery(H,user)
			return 1
		else
			user << "\red [H] is not bleeding in \his [S.display_name]!"
			return 0

	H.visible_message( \
		"\red [user] is beginning to clamp bleeders in the wound in [H]'s [S.display_name] with [src].", \
		"\red [user] begins to clamp bleeders in the wound in your [S.display_name] with [src]!")

	if(do_mob(user, H, 50))
		H.visible_message( \
			"\red [user] clamps bleeders in the wound in [H]'s [S.display_name] with [src]!", \
			"\red [user] clamps bleeders in the wound in your [S.display_name] with [src]!")

		if(user.zone_sel.selecting == "head" && H:brain_op_stage == 1)
			H:brain_op_stage = 0

		S.status &= ~ORGAN_BLEEDING
		H.updatehealth()
		H.UpdateDamageIcon()
	else
		interrupt(H,user,SRG_BONE)
	return 1

/obj/item/weapon/hemostat/proc/interrupt(mob/living/carbon/human/H as mob, mob/living/user as mob, type)
	H.visible_message( "\red [user] quickly stops the surgery.", \
						"\red [user] quickly stops the surgery." )


///////////////////
//AUTOPSY SCANNER//
///////////////////
/obj/item/weapon/autopsy_scanner/var/list/datum/autopsy_data_data/wdata = list()
/obj/item/weapon/autopsy_scanner/var/list/datum/autopsy_data_data/chemtraces = list()
/obj/item/weapon/autopsy_scanner/var/target_name = null
/obj/item/weapon/autopsy_scanner/var/timeofdeath = null

/datum/autopsy_data_data
	var/weapon = null // this is the DEFINITE weapon type that was used
	var/list/organs_scanned = list() // this maps a number of scanned organs to
		                             // the wounds to those organs with this data's weapon type
	var/organ_names = ""

/obj/item/weapon/autopsy_scanner/proc/add_data(var/datum/organ/external/O)
	if(!O.autopsy_data.len && !O.trace_chemicals.len) return

	for(var/V in O.autopsy_data)
		var/datum/autopsy_data/W = O.autopsy_data[V]

		if(!W.pretend_weapon)
			// the more hits, the more likely it is that we get the right weapon type
			if(prob(50 + W.hits * 10 + W.damage))
				W.pretend_weapon = W.weapon
			else
				W.pretend_weapon = pick("mechanical toolbox", "wirecutters", "revolver", "crowbar", "fire extinguisher", "tomato soup", "oxygen tank", "emergency oxygen tank", "laser", "bullet")


		var/datum/autopsy_data_data/D = wdata[V]
		if(!D)
			D = new()
			D.weapon = W.weapon
			wdata[V] = D

		if(!D.organs_scanned[O.name])
			if(D.organ_names == "")
				D.organ_names = O.display_name
			else
				D.organ_names += ", [O.display_name]"

		del D.organs_scanned[O.name]
		D.organs_scanned[O.name] = W.copy()

	for(var/V in O.trace_chemicals)
		if(O.trace_chemicals[V] > 0 && !chemtraces.Find(V))
			chemtraces += V

/obj/item/weapon/autopsy_scanner/verb/print_data()
	set src in view(usr, 1)
	set name = "Print Data"
	if(usr.stat)
		usr << "No."
		return

	if(wdata.len == 0 && chemtraces.len == 0)
		usr << "<b>* There is no data about any wounds in the scanner's database. You may have to scan more bodyparts, or otherwise this wound type may not be in the scanner's database."
		return

	var/scan_data = ""

	if(timeofdeath)
		scan_data += "<b>Time since death:</b> [round((world.time - timeofdeath) / (60*10))] minutes<br><br>"

	var/n = 1
	for(var/wdata_idx in wdata)
		var/datum/autopsy_data_data/D = wdata[wdata_idx]
		var/total_hits = 0
		var/total_score = 0
		var/list/weapon_chances = list() // maps weapon names to a score
		var/age = 0

		for(var/wound_idx in D.organs_scanned)
			var/datum/autopsy_data/W = D.organs_scanned[wound_idx]
			total_hits += W.hits

			var/wname = W.pretend_weapon

			if(wname in weapon_chances) weapon_chances[wname] += W.damage
			else weapon_chances[wname] = max(W.damage, 1)
			total_score+=W.damage


			var/wound_age = world.time - W.time_inflicted
			age = max(age, wound_age)

		var/damage_desc

		var/damaging_weapon = (total_score != 0)

		// total score happens to be the total damage
		switch(total_score)
			if(0)
				damage_desc = "Unknown"
			if(1 to 5)
				damage_desc = "<font color='green'>negligible</font>"
			if(5 to 15)
				damage_desc = "<font color='green'>light</font>"
			if(15 to 30)
				damage_desc = "<font color='orange'>moderate</font>"
			if(30 to 1000)
				damage_desc = "<font color='red'>severe</font>"

		if(!total_score) total_score = D.organs_scanned.len

		scan_data += "<b>Weapon #[n]</b><br>"
		if(damaging_weapon)
			scan_data += "Severity: [damage_desc]<br>"
			scan_data += "Hits by weapon: [total_hits]<br>"
		scan_data += "Age of wound: [round(age / (60*10))] minutes<br>"
		scan_data += "Affected limbs: [D.organ_names]<br>"
		scan_data += "Possible weapons:<br>"
		for(var/weapon_name in weapon_chances)
			scan_data += "\t[100*weapon_chances[weapon_name]/total_score]% [weapon_name]<br>"

		scan_data += "<br>"

		n++

	if(chemtraces.len)
		scan_data += "<b>Trace Chemicals: </b><br>"
		for(var/chemID in chemtraces)
			scan_data += chemID
			scan_data += "<br>"

	for(var/mob/O in viewers(usr))
		O.show_message("\red \the [src] rattles and prints out a sheet of paper.", 1)

	sleep(10)

	var/obj/item/weapon/paper/P = new(usr.loc)
	P.name = "Autopsy Data ([target_name])"
	P.info = "<tt>[scan_data]</tt>"
	P.overlays += "paper_words"

	if(istype(usr,/mob/living/carbon))
		// place the item in the usr's hand if possible
		if(!usr.r_hand)
			P.loc = usr
			usr.r_hand = P
			P.layer = 20
		else if(!usr.l_hand)
			P.loc = usr
			usr.l_hand = P
			P.layer = 20

	usr.update_clothing()

/obj/item/weapon/autopsy_scanner/attack(mob/living/carbon/human/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	if(target_name != M.name)
		target_name = M.name
		for(var/V in src.wdata)
			del src.wdata[V]
		src.wdata = list()

	src.timeofdeath = M.timeofdeath

	var/datum/organ/external/S = M.organs[user.zone_sel.selecting]
	if(!S)
		usr << "<b>You can't scan this body part.</b>"
		return
	if(!S.open)
		usr << "<b>You have to cut the limb open first!</b>"
		return
	if(S.status & ORGAN_ROBOT)
		user << "Medical equipment for a robot arm?  How would that do any good?"
		return
	for(var/mob/O in viewers(M))
		O.show_message("\red [user.name] scans the wounds on [M.name]'s [S.display_name] with \the [src.name]", 1)

	src.add_data(S)

	return 1

///////////
//Cautery//
///////////

/obj/item/weapon/cautery/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	var/mob/living/carbon/human/H = M

	//checks for face covering items
	if(user.zone_sel.selecting == "mouth" || user.zone_sel.selecting == "eyes")
		if (surgery_is_face_covered(H,user))
			return

	//Appendix and larva surgeries are handled in try_bone_surgery.

	if(((user.zone_sel.selecting == "l_arm") || (user.zone_sel.selecting == "r_arm") || (user.zone_sel.selecting == "l_leg") || (user.zone_sel.selecting == "r_leg")) & (istype(M, /mob/living/carbon/human)))
		if(limb_surgery(H,user)) return

	if (user.zone_sel.selecting == "eyes")
		if(eye_surgery(M,user)) return

	if (user.zone_sel.selecting == "mouth")
		if(face_surgery(M,user)) return

	if(!try_bone_surgery(M, user) && user.a_intent == "hurt") // if we call ..(), we'll attack them, so require a hurt intent
		return ..()

/obj/item/weapon/cautery/proc/limb_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if (!istype(H))
		return 0
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
	if (!S)
		return 0
	if(S.status & ORGAN_DESTROYED)
		if(S.status & ORGAN_BLEEDING)
			user << "\red There's too much blood here!"
			return 0
		if(!(S.status & ORGAN_CUT_AWAY))
			user << "\red The flesh hasn't been cleanly cut!"
			return 0
		if(S.open != 3)
			user << "\red The wound hasn't been prepared yet!"
			return 0
		H.visible_message( \
			"\red [user] is adjusting the area around [H]'s [S.display_name] for reattachment with [src].", \
			"\red [user] is adjusting the area around your [S.display_name] for reattachment with [src]!")
		if(do_mob(user, H, 100))
			H.visible_message( \
				"\red [user] finishes adjusting the area around [H]'s [S.display_name]!", \
				"\red [user] finishes adjusting the area around your [S.display_name]!")
			S.open = 0
			S.stage = 0
			S.status |= ORGAN_ATTACHABLE
			S.amputated = 1 // this should prevent the wound from hurting etc.
			H.updatehealth()
			H.UpdateDamageIcon()
		else
			interrupt(H,user,SRG_LIMB)
		return 1

/obj/item/weapon/cautery/proc/eye_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	switch(M.eye_op_stage)
		if(3.0)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [M] is having \his eyes cauterized by [user].", 1)
			M << "\red [user] begins to cauterize your eyes!"
			user << "\red You start cauterizing [M]'s eyes with [src]!"

			if(do_mob(user, M, rand(70,100)))
				for(var/mob/O in (viewers(M) - user - M))
					O.show_message("\red [M] had \his eyes cauterized by [user].", 1)
				M << "\red [user] cauterizes your eyes!"
				user << "\red You cauterize [M]'s eyes with [src]!"

				M.disabilities &= ~128
				M.eye_stat = 0
				M:eye_op_stage = 0.0
			else
				interrupt(M,user,SRG_EYE)
			return

/obj/item/weapon/cautery/proc/face_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	switch(M.face_op_stage)
		if(5.0)
			M.visible_message( \
				"\red [user] is beginning is cauterize [M]'s face and neck with [src].", \
				"\red [user] begins cauterize your face and neck with [src]!")

			if(do_mob(user, M, 50))
				M.visible_message( \
					"\red [user] cauterizes [M]'s face and neck with [src]!", \
					"\red [user] cauterizes your face and neck with [src]!")

				for(var/datum/organ/external/head/head)
					if(head && head.disfigured)
						head.disfigured = 0
				M.real_name = "[M.original_name]"
				M.name = "[M.original_name]"
				M << "\blue Your face feels better."
				M.warn_flavor_changed()
				M:face_op_stage = 0.0
				M.updatehealth()
				M.UpdateDamageIcon()
			else
				interrupt(M,user,SRG_FACE)
			return

/obj/item/weapon/cautery/proc/try_bone_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if(!istype(H))
		return 0
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
	if(!S || !istype(S))
		return 0

	if(S.status & ORGAN_DESTROYED)
		user << "What [S.display_name]?"

	if(S.status & ORGAN_ROBOT)
		user << "Medical equipment for a robot arm?  How would that do any good..."
		return
	if(!S.open)
		user << "\red There is no wound to close up!"
		return 0

	H.visible_message( \
		"\red [user] is beginning to cauterize the incision in [H]'s [S.display_name] with [src].", \
		"\red [user] begins to cut open the wound in your [S.display_name] with [src]!")

	if(do_mob(user, H, rand(70,100)))
		H.visible_message( \
			"\red [user] cauterizes the incision in [H]'s [S.display_name] with [src]!", \
			"\red [user] cauterizes the incision in your [S.display_name] with [src]!")

		S.open = 0

		if(S.display_name == "chest")
			if(H:embryo_op_stage == 1.0 || H:embryo_op_stage == 6.0 || \
				H:embryo_op_stage ==  3.0 || H:embryo_op_stage ==  7.0)
				H:embryo_op_stage = 0.0
		if(S.display_name == "groin")
			if (H:appendix_op_stage == 1.0 || H:appendix_op_stage == 5.0)
				H:appendix_op_stage = 0.0

		H.updatehealth()
		H.UpdateDamageIcon()
	else
		interrupt(H,user,SRG_BONE)
	return 1

/obj/item/weapon/cautery/proc/interrupt(mob/living/carbon/human/H as mob, mob/living/user as mob, type)
	H.visible_message( "\red [user] quickly stops the surgery.", \
						"\red [user] quickly stops the surgery." )

//obj/item/weapon/surgicaldrill

///////////
//SCALPEL//
///////////
/obj/item/weapon/scalpel/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if((CLUMSY in user.mutations) && prob(50))
		M = user
		return eyestab(M,user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	src.add_fingerprint(user)

	if(istype(M, /mob/living/carbon/metroid))
		if(core_surgery(M,user))
			return

	if(((user.zone_sel.selecting == "l_arm") || (user.zone_sel.selecting == "r_arm") || (user.zone_sel.selecting == "l_leg") || (user.zone_sel.selecting == "r_leg")) & (istype(M, /mob/living/carbon/human)))
		if(limb_surgery(M,user))
			return

	var/mob/living/carbon/human/H = M
	if(istype(H))
		if(user.zone_sel.selecting == "chest")
			if(larva_surgery(M,user))
				return

		if(user.zone_sel.selecting == "groin")
			if(appendix_surgery(M,user))
				return

	//Checks for items covering head and face and preventing surgery
	if(user.zone_sel.selecting == "mouth" || user.zone_sel.selecting == "eyes")
		if (surgery_is_face_covered(H,user))
			return

	if(user.zone_sel.selecting == "head")
		if (surgery_is_face_covered(H,user) == 1)
			return
		if(istype(H) && H.organs["head"])
			var/datum/organ/external/affecting = H.organs["head"]
			if(affecting.status & ORGAN_DESTROYED)
				return ..()
		if(brain_surgery(M,user))
			return

	if(user.zone_sel.selecting == "eyes")
		if(eye_surgery(M,user))
			return

	if(user.zone_sel.selecting == "mouth")
		if(face_surgery(M,user))
			return

	if(!try_bone_surgery(M, user) && user.a_intent == "hurt") // if we call ..(), we'll attack them, so require a hurt intent
		return ..()

	return

/obj/item/weapon/scalpel/proc/brain_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	switch(M:brain_op_stage)
		if(2.0)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [user] starts severing [M]'s brain connections with [src].", 1)
			M << "\red [user] starts to delicately sever your brain with [src]!"
			user << "\red You start severing [M]'s brain with [src]!"
			if(do_mob(user, M, 50))
				for(var/mob/O in (viewers(M) - user - M))
					O.show_message("\red [M] has \his connections to the brain delicately severed with [src] by [user].", 1)
				M << "\red [user] delicately severes your brain with [src]!"
				user << "\red You severe [M]'s brain with [src]!"
				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M:get_organ("head")
					affecting.take_damage(7)
				else
					M.take_organ_damage(7)
				M.updatehealth()
				M:brain_op_stage = 3.0
				return 1
			else
				interrupt(M,user,0) //interrupt implemented for all types of surgery for now anyway
				return 0
	return 0

/obj/item/weapon/scalpel/proc/core_surgery(mob/living/carbon/metroid/M as mob, mob/living/user as mob)
	if (!istype(M) || M.stat != 2)
		return 0
	switch(M:brain_op_stage)
		if(0.0)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [M.name] has its flesh cut open with [src] by [user].", 1)
			M << "\red [user] cuts open your flesh with [src]!"
			user << "\red You cut [M]'s flesh open with [src]!"
			M:brain_op_stage = 1.0
			return 1
		if(1)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [M.name] has its silky inndards cut apart with [src] by [user].", 1)
			M << "\red [user] cuts apart your innards with [src]!"
			user << "\red You cut [M]'s silky innards apart with [src]!"
			M:brain_op_stage = 2.0
			return 1
		if(2.0)
			if(M.cores > 0)
				user << "\red You attempt to remove [M]'s core, but [src] is ineffective!"
			return 1
	return 0

/obj/item/weapon/scalpel/proc/face_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	switch(M:face_op_stage)
		if(0.0)
			M.visible_message( \
				"\red [user] is beginning is cut open [M]'s face and neck with [src].", \
				"\red [user] begins to cut open your face and neck with [src]!")
			if(do_mob(user, M, 50))
				M.visible_message( \
					"\red [user] cuts open [M]'s face and neck with [src]!", \
					"\red [user] cuts open your face and neck with [src]!")
				M.face_op_stage = 1.0
				M.updatehealth()
				M.UpdateDamageIcon()
				return 1
			else
				interrupt(M,user,SRG_FACE)
				return 0
	return 0

/obj/item/weapon/scalpel/proc/eye_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	switch(M:eye_op_stage)
		if(0.0)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [user] starts to make incision around [M]'s eyes with [src].", 1)
			M << "\red [user] starts to cut open your eyes with [src]!"
			user << "\red You start making an incision around [M]'s eyes with [src]!"
			if(do_mob(user, M, 50))
				for(var/mob/O in (viewers(M) - user - M))
					O.show_message("\red [M] has \his eyes incised with [src] by [user].", 1)
				M << "\red [user] cuts open your eyes with [src]!"
				user << "\red You make an incision around [M]'s eyes with [src]!"
				M.updatehealth()
				M:eye_op_stage = 1.0
				return 1
			else
				interrupt(M,user,SRG_EYE)
				return 0
	return 0

/obj/item/weapon/scalpel/proc/limb_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	if (!M || !istype(M))
		return
	var/datum/organ/external/S = M.organs[user.zone_sel.selecting]
	if (!S)
		return
	if(S.status & ORGAN_DESTROYED)
		M.visible_message( \
			"\red [user] is beginning to cut away at the flesh where [M]'s [S.display_name] used to be with [src].", \
			"\red [user] begins to cut away at the flesh where [S.display_name] used to be with [src]!")
		if(do_mob(user, M, 100))
			M.visible_message( \
				"\red [user] finishes cutting where [M]'s [S.display_name] used to be with [src]!", \
				"\red [user] finishes cutting where your [S.display_name] used to be with [src]!")
			S.status |= ORGAN_BLEEDING|ORGAN_CUT_AWAY
			M.updatehealth()
			M.UpdateDamageIcon()
			return 1
		else
			interrupt(M,user,SRG_LIMB)
			return 0
	return 0

/obj/item/weapon/scalpel/proc/larva_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	switch(M:embryo_op_stage)
		if(3.0)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [user] starts cutting [M]'s stomach open with [src].", 1)
			M << "\red [user] starts to cut open your stomach with [src]!"
			user << "\red You start cutting [M]'s stomach open with [src]!"
			if(do_mob(user, M, 100))
				for(var/mob/O in (viewers(M) - user - M))
					O.show_message("\red [M] has \his stomach cut open with [src] by [user].", 1)
				M << "\red [user] cuts open your stomach with [src]!"
				user << "\red You cut [M]'s stomach open with [src]!"
				for(var/datum/disease/D in M.viruses)
					if(istype(D, /datum/disease/alien_embryo))
						user << "\blue There's something wiggling in there!"
						M:embryo_op_stage = 4.0
				if(M:embryo_op_stage == 3.0)
					M:embryo_op_stage = 7.0 //Make it not cut their stomach open again and again if no larvae.
				return 1
			else
				interrupt(M,user,SRG_ALIEN)
				return 0
	return 0

/obj/item/weapon/scalpel/proc/appendix_surgery(mob/living/carbon/human/M as mob, mob/living/user as mob)
	switch(M:appendix_op_stage)
		if(3.0)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [user] starts separating [M]'s appendix with [src].", 1)
			M << "\red [user] starts separating your appendix with [src]!"
			user << "\red You start separating [M]'s appendix with [src]!"
			if(do_mob(user, M, 100))
				for(var/mob/O in (viewers(M) - user - M))
					O.show_message("\red [M] has \his appendix seperated with [src] by [user].", 1)
				M << "\red [user] seperates your appendix with [src]!"
				user << "\red You seperate [M]'s appendix with [src]!"
				M:appendix_op_stage = 4.0
				return 1
			else
				interrupt(M,user,SRG_APPENDIX)
				return 0
	return 0

/obj/item/weapon/scalpel/proc/try_bone_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if(!istype(H))
		return 0
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]

	if(!S || !istype(S))
		return 0

	if(S.status & ORGAN_DESTROYED)
		return 0

	if(S.status & ORGAN_ROBOT)
		user << "Medical equipment for a robot arm?  How would that do any good..."
		return 0

	if(S.open)
		user << "\red The wound is already open!"
		return 0

	H.visible_message( \
		"\red [user] is beginning to cut open the wound in [H]'s [S.display_name] with [src].", \
		"\red [user] begins to cut open the wound in your [S.display_name] with [src]!")
	if(do_mob(user, H, 100))
		H.visible_message( \
				"\red [user] cuts open the wound in [H]'s [S.display_name] with [src]!", \
				"\red [user] cuts open the wound in your [S.display_name] with [src]!")

		S.status |= ORGAN_BLEEDING
		S.open = 1
		if(S.display_name == "head")
			H:brain_op_stage = 1.0
		if(S.display_name == "chest")
			H:embryo_op_stage = 1.0
		if(S.display_name == "groin")
			H:appendix_op_stage = 1.0
		H.updatehealth()
		H.UpdateDamageIcon()
	else
		interrupt(H,user,SRG_BONE)

	return 1

/obj/item/weapon/scalpel/proc/interrupt(mob/living/carbon/human/H as mob, mob/living/user as mob, type)
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
	if(!S || !istype(S))
		return 0

	var/a = pick(1,2,3)
	var/msg
	switch (a)
		if(1)
			msg = "\red [user]'s move slices open [H]'s wound, causing massive bleeding"
			S.take_damage(35, 0, 1, "Malpractice")
		if(2)
			msg = "\red [user]'s move slices open [H]'s wound, and causes \him to accidentally stab himself"
			S.take_damage(35, 0, 1, "Malpractice")
			var/datum/organ/external/userorgan = user:organs["chest"]
			if(userorgan)
				userorgan.take_damage(35, 0, 1, "Malpractice")
			else
				user.take_organ_damage(35)
		if(3)
			msg = "\red [user] quickly stops the surgery"
	for(var/mob/O in viewers(H))
		O.show_message(msg, 1)

////////////////
//CIRCULAR SAW//
////////////////
/obj/item/weapon/circular_saw/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if((CLUMSY in user.mutations) && prob(50))
		M = user
		return eyestab(M,user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	src.add_fingerprint(user)

	if(istype(M, /mob/living/carbon/metroid))
		if(core_surgery(M,user))
			return

	if(user.zone_sel.selecting == "head")
		if (surgery_is_face_covered(M,user) == 1)
			return
		if (brain_surgery(M,user))
			return

	if(user.zone_sel.selecting != "chest" && hasorgans(M))
		limb_surgery(M,user)

	if (user.a_intent == "hurt") // if we call ..(), we'll attack them, so require a hurt intent
		return ..()
	return

/obj/item/weapon/circular_saw/proc/limb_surgery(mob/living/carbon/H as mob, mob/living/carbon/user as mob)
	var/datum/organ/external/S = H:organs[user.zone_sel.selecting]
	if (!S)
		return
	if(S.status & ORGAN_DESTROYED)
		return

	if(S.status & ORGAN_ROBOT)
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, H)
		spark_system.attach(H)
		spark_system.start()
		spawn(10)
			del(spark_system)
	for(var/mob/O in viewers(H, null))
		O.show_message(text("\red [H] gets \his [S.display_name] sawed at with [src] by [user]... It looks like [user] is trying to cut it off!"), 1)
	if(!do_after(user, rand(20,80)))
		for(var/mob/O in viewers(H, null))
			O.show_message(text("\red [user] tried to cut [H]'s [S.display_name] off with [src], but failed."), 1)
		return
	for(var/mob/O in viewers(H, null))
		O.show_message(text("\red [H] gets \his [S.display_name] sawed off with [src] by [user]."), 1)
	S.droplimb(1)
	H:update_body()

/obj/item/weapon/circular_saw/proc/core_surgery(mob/living/carbon/metroid/M as mob, mob/living/carbon/user as mob)
	if(M.stat == 2)
		if(M.cores > 0)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [M.name] is having one of its cores sawed out with [src] by [user].", 1)
			M.cores--
			M << "\red [user] begins to remove one of your cores with [src]! ([M.cores] cores remaining)"
			user << "\red You cut one of [M]'s cores out with [src]! ([M.cores] cores remaining)"
			if(do_after(user, rand(20,80)))
				new/obj/item/metroid_core(M.loc)
				if(M.cores <= 0)
					M.icon_state = "baby metroid dead-nocore"
			else
				user << "\red You stop cutting out the core."
			return 1

/obj/item/weapon/circular_saw/proc/brain_surgery(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	switch(M:brain_op_stage)
		if(1.0)
			if(istype(M, /mob/living/carbon/metroid))
				return
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [M] is having \his skull sawed open with [src] by [user].", 1)
			M << "\red [user] begins to saw open your head with [src]!"
			user << "\red You start to saw [M]'s head open with [src]!"

			if(do_after(user,rand(40,60)))
				for(var/mob/O in (viewers(M) - user - M))
					O.show_message("\red [M] has \his skull sawed open with [src] by [user].", 1)
				M << "\red [user] saws open your head with [src]!"
				user << "\red You saw [M]'s head open with [src]!"

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M:get_organ("head")
					affecting.take_damage(7)
				else
					M.take_organ_damage(7)

				M.updatehealth()
				M:brain_op_stage = 2.0
			else
				interrupt(M,user,0)
			return 1

		if(3.0)
			if(M.changeling && M.changeling.changeling_fakedeath)
				user << "\red The neural tissue regrows before your eyes as you cut it."
				return

			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("\red [user] starts to severe [user]'s brain connections to spine with [src].", 1)
			M << "\red [user] starts to sever your brain's connection to the spine with [src]!"
			user << "\red You start to sever [M]'s brain's connection to the spine with [src]!"

			if(do_after(user,rand(40,60)))
				for(var/mob/O in (viewers(M) - user - M))
					O.show_message("\red [M] has \his spine's connection to the brain severed with [src] by [user].", 1)
				M << "\red [user] severs your brain's connection to the spine with [src]!"
				user << "\red You sever [M]'s brain's connection to the spine with [src]!"

				user.attack_log += "\[[time_stamp()]\]<font color='red'> Debrained [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
				M.attack_log += "\[[time_stamp()]\]<font color='orange'> Debrained by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"

				log_admin("ATTACK: [user] ([user.ckey]) debrained [M] ([M.ckey]) with [src].")
				message_admins("ATTACK: [user] ([user.ckey]) debrained [M] ([M.ckey]) with [src].")
				log_attack("<font color='red'>[user.name] ([user.ckey]) debrained [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

				var/obj/item/brain/B = new(M.loc)
				B.transfer_identity(M)

				M:brain_op_stage = 4.0
				M.death()//You want them to die after the brain was transferred, so not to trigger client death() twice.
			else
				interrupt(M,user,0)
			return 1
	return 0

/obj/item/weapon/circular_saw/proc/interrupt(mob/living/carbon/human/H as mob, mob/living/user as mob, type)
	H.visible_message( "\red [user] quickly stops the surgery.", \
						"\red [user] quickly stops the surgery." )

//////////////////////////////
// Bone Gel and Bone Setter //
//////////////////////////////

/obj/item/weapon/surgical_tool
	name = "surgical tool"
	var/list/stage = list() //Stage to act on
	var/time = 50 //Time it takes to use
	var/list/wound = list()//Wound type to act on

	proc/get_message(var/mnumber,var/M,var/user,var/datum/organ/external/organ)//=Start,2=finish,3=walk away,4=screw up, 5 = closed wound
	proc/screw_up(mob/living/carbon/M as mob,mob/living/carbon/user as mob,var/datum/organ/external/organ)
		organ.brute_dam += 30
/obj/item/weapon/surgical_tool/proc/IsFinalStage(var/stage)
	var/a = 3
	return stage == a

/obj/item/weapon/surgical_tool/attack(mob/living/carbon/human/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return
	if((CLUMSY in user.mutations) && prob(50))
		M << "\red You stab yourself in the eye."
		M.disabilities |= 128
		M.weakened += 4
		M.bruteloss += 10

	src.add_fingerprint(user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	var/zone = user.zone_sel.selecting
	if (istype(M.organs[zone], /datum/organ/external))
		var/datum/organ/external/temp = M.organs[zone]
		var/msg

		if(temp.status & ORGAN_DESTROYED)
			return ..()

        // quickly convert embryo removal to bone surgery
		if(zone == "chest" && M.embryo_op_stage == 3)
			M.embryo_op_stage = 0
			temp.open = 2
			temp.status &= ~ORGAN_BLEEDING

		// quickly convert appendectomy to bone surgery
		if(zone == "groin" && M.appendix_op_stage == 3)
			M.appendix_op_stage = 0
			temp.open = 2
			temp.status &= ~ORGAN_BLEEDING

		msg = get_message(1,M,user,temp)
		for(var/mob/O in viewers(M,null))
			O.show_message("\red [msg]",1)
		if(do_mob(user,M,time))
			if(temp.open == 2 && !(temp.status & ORGAN_BLEEDING))
				if(temp.broken_description in wound)
					if(temp.stage in stage)
						temp.stage += 1

						if(IsFinalStage(temp.stage))
							temp.status &= ~ORGAN_BROKEN
							temp.status &= ~ORGAN_SPLINTED
							temp.stage = 0
							temp.perma_injury = 0
							temp.brute_dam = temp.min_broken_damage -1
						msg = get_message(2,M,user,temp)
					else
						msg = get_message(4,M,user,temp)
						screw_up(M,user,temp)
				else
					msg = get_message(5,M,user,temp)
		else
			msg = get_message(3,M,user,temp)

		for(var/mob/O in viewers(M,null))
			O.show_message("\red [msg]",1)


/*Broken bone
 Basic:
 Open -> Clean -> Bone-gel -> pop-into-place -> Bone-gel -> close -> glue -> clean

 Split:
 Open -> Clean -> Tweasers -> bone-glue -> close -> glue -> clean

 The above might not apply anymore.

*/

/obj/item/weapon/surgical_tool/bonegel
	name = "bone gel"
	icon = 'surgery.dmi'
	icon_state = "bone gel"

/obj/item/weapon/surgical_tool/bonegel/New()
	stage += 0
	stage += 2
	wound += "broken"
	wound += "fracture"
	wound += "hairline fracture"
/obj/item/weapon/surgical_tool/bonegel/get_message(var/n,var/m,var/usr,var/datum/organ/external/organ)
	var/z
	switch(n)
		if(1)
			z="[usr] starts applying bone gel to [m]'s [organ.display_name]"
		if(2)
			z="[usr] finishes applying bone gel to [m]'s [organ.display_name]"
		if(3)
			z="[usr] stops applying bone gel to [m]'s [organ.display_name]"
		if(4)
			z="[usr] applies bone gel incorrectly to [m]'s [organ.display_name]"
		if(5)
			z="[usr] lubricates [m]'s [organ.display_name]"
	return z

/obj/item/weapon/surgical_tool/bonesetter
	name = "bone setter"
	icon = 'surgery.dmi'
	icon_state = "bone setter"

/obj/item/weapon/surgical_tool/bonesetter/New()
	stage += 1
	wound += "broken"
	wound += "fracture"
	wound += "hairline fracture"
/obj/item/weapon/surgical_tool/bonesetter/get_message(var/n,var/m,var/usr,var/datum/organ/external/organ)
	var/z
	switch(n)
		if(1)
			z="[usr] starts popping [m]'s [organ.display_name] bone into place"
		if(2)
			z="[usr] finishes popping [m]'s [organ.display_name] bone into place"
		if(3)
			z="[usr] stops popping [m]'s [organ.display_name] bone into place"
		if(4)
			z="[usr] pops [m]'s [organ.display_name] bone into the wrong place"
		if(5)
			z="[usr] performs chiropractice on [m]'s [organ.display_name]"
	return z


/obj/item/weapon/boneinjector
	name = "Bone-repairing Nanites Injector"
	desc = "This injects the person with nanites that repair bones."
	icon = 'items.dmi'
	icon_state = "implanter1"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/uses = 5

/obj/item/weapon/boneinjector/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/item/weapon/boneinjector/proc/inject(mob/M as mob)
	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		for(var/name in H.organs)
			var/datum/organ/external/e = H.organs[name]
			if(e.status & ORGAN_DESTROYED) // this is nanites, not space magic
				continue
			e.brute_dam = 0.0
			e.burn_dam = 0.0
			e.status &= ~ORGAN_BANDAGED
			e.max_damage = initial(e.max_damage)
			e.status &= ~ORGAN_BLEEDING
			e.open = 0
			e.status &= ~ORGAN_BROKEN
			e.status &= ~ORGAN_DESTROYED
			e.status &= ~ORGAN_SPLINTED
			e.perma_injury = 0
			e.update_icon()
		H.update_body()
		H.update_face()
		H.UpdateDamageIcon()

	uses--
	if(uses == 0)
		spawn(0)//this prevents the collapse of space-time continuum
			del(src)
	return uses

/obj/item/weapon/boneinjector/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob))
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to inject [M.name] ([M.ckey])</font>")
	log_admin("ATTACK: [user] ([user.ckey]) injected [M] ([M.ckey]) with [src].")

	if (user)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red [] has been injected with [] by [].", M, src, user), 1)
			//Foreach goto(192)
		if (!(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey)))
			user << "\red Apparently it didn't work."
			return
		inject(M)//Now we actually do the heavy lifting.

		if(!isnull(user))//If the user still exists. Their mob may not.
			user.show_message(text("\red You inject [M]"))
	return