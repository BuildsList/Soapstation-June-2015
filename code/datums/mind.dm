/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse

	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:

			mind.transfer_to(new_mob)

	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
		the player.

	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.

			new_mob.key = key

		The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.

*/

datum/mind
	var/key
	var/name				//replaces mob/var/original_name
	var/mob/living/current
	var/mob/living/original	//TODO: remove.not used in any meaningful way ~Carn. First I'll need to tweak the way silicon-mobs handle minds.
	var/active = 0

	var/memory

	var/assigned_role
	var/special_role

	var/role_alt_title

	var/datum/job/assigned_job

	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	var/datum/faction/faction 			//associated faction
	var/datum/changeling/changeling		//changeling holder

	var/rev_cooldown = 0

	// the world.time since the mob has been brigged, or -1 if not at all
	var/brigged_since = -1

	New(var/key)
		src.key = key

	//put this here for easier tracking ingame
	var/datum/money_account/initial_account

	proc/transfer_to(mob/living/new_character)
		if(!istype(new_character))
			world.log << "## DEBUG: transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob. Please inform Carn"
		if(current)					//remove ourself from our old body's mind variable
			if(changeling)
				current.remove_changeling_powers()
				current.verbs -= /datum/changeling/proc/EvolutionMenu
			current.mind = null

			nanomanager.user_transferred(current, new_character) // transfer active NanoUI instances to new user
		if(new_character.mind)		//remove any mind currently in our new body's mind variable
			new_character.mind.current = null

		current = new_character		//link ourself to our new body
		new_character.mind = src	//and link our new body to ourself

		if(changeling)
			new_character.make_changeling()

		if(active)
			new_character.key = key		//now transfer the key to link the client to our new body

	proc/store_memory(new_text)
		memory += "[new_text]<BR>"

	proc/show_memory(mob/recipient)
		var/output = "<B>[current.real_name]'s Memory</B><HR>"
		output += memory

		if(objectives.len>0)
			output += "<HR><B>Objectives:</B>"

			var/obj_count = 1
			for(var/datum/objective/objective in objectives)
				output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++

		recipient << browse(output,"window=memory")

	proc/edit_memory()
		if(!ticker || !ticker.mode)
			alert("Not before round-start!", "Alert")
			return

		var/out = "<B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""]<br>"
		out += "Mind currently owned by key: [key] [active?"(synced)":"(not synced)"]<br>"
		out += "Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>"
		out += "<hr>"
		out += "Factions and special roles:<br><table>"
		for(var/antag_type in all_antag_types)
			var/datum/antagonist/antag = all_antag_types[antag_type]
			out += "[antag.get_panel_entry(src)]"
		out += "</table><hr>"
		out += "<b>Objectives</b></br>"

		if(objectives && objectives.len)
			var/num = 1
			for(var/datum/objective/O in objectives)
				out += "<b>Objective #[num]:</b> [O.explanation_text] "
				if(O.completed)
					out += "(<font color='green'>complete</font>)"
				else
					out += "(<font color='red'>incomplete</font>)"
				out += " <a href='?src=\ref[src];obj_completed=\ref[O]'>\[toggle\]</a>"
				out += " <a href='?src=\ref[src];obj_delete=\ref[O]'>\[remove\]</a><br>"
				num++
			out += "<br><a href='?src=\ref[src];obj_announce=1'>\[announce objectives\]</a>"

		else
			out += "None."
		out += "<br><a href='?src=\ref[src];obj_add=1'>\[add\]</a>"
		usr << browse(out, "window=edit_memory[src]")

	Topic(href, href_list)
		if(!check_rights(R_ADMIN))	return

		if(href_list["add_antagonist"])
			var/datum/antagonist/antag = all_antag_types[href_list["add_antagonist"]]
			if(antag) antag.add_antagonist(src)

		else if(href_list["remove_antagonist"])
			var/datum/antagonist/antag = all_antag_types[href_list["remove_antagonist"]]
			if(antag) antag.remove_antagonist(src)

		else if(href_list["equip_antagonist"])
			var/datum/antagonist/antag = all_antag_types[href_list["equip_antagonist"]]
			if(antag) antag.equip(src.current)

		else if(href_list["unequip_antagonist"])
			var/datum/antagonist/antag = all_antag_types[href_list["unequip_antagonist"]]
			if(antag) antag.unequip(src.current)

		else if(href_list["move_antag_to_spawn"])
			var/datum/antagonist/antag = all_antag_types[href_list["move_antag_to_spawn"]]
			if(antag) antag.place_mob(src.current)

		else if (href_list["role_edit"])
			var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in joblist
			if (!new_role) return
			assigned_role = new_role

		else if (href_list["memory_edit"])
			var/new_memo = sanitize(input("Write new memory", "Memory", memory) as null|message)
			if (isnull(new_memo)) return
			memory = new_memo

		else if (href_list["obj_edit"] || href_list["obj_add"])
			var/datum/objective/objective
			var/objective_pos
			var/def_value

			if (href_list["obj_edit"])
				objective = locate(href_list["obj_edit"])
				if (!objective) return
				objective_pos = objectives.Find(objective)

				//Text strings are easy to manipulate. Revised for simplicity.
				var/temp_obj_type = "[objective.type]"//Convert path into a text string.
				def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
				if(!def_value)//If it's a custom objective, it will be an empty string.
					def_value = "custom"

			var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "debrain", "protect", "prevent", "harm", "brig", "hijack", "escape", "survive", "steal", "download", "mercenary", "capture", "absorb", "custom")
			if (!new_obj_type) return

			var/datum/objective/new_objective = null

			switch (new_obj_type)
				if ("assassinate","protect","debrain", "harm", "brig")
					//To determine what to name the objective in explanation text.
					var/objective_type_capital = uppertext(copytext(new_obj_type, 1,2))//Capitalize first letter.
					var/objective_type_text = copytext(new_obj_type, 2)//Leave the rest of the text.
					var/objective_type = "[objective_type_capital][objective_type_text]"//Add them together into a text string.

					var/list/possible_targets = list("Free objective")
					for(var/datum/mind/possible_target in ticker.minds)
						if ((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
							possible_targets += possible_target.current

					var/mob/def_target = null
					var/objective_list[] = list(/datum/objective/assassinate, /datum/objective/protect, /datum/objective/debrain)
					if (objective&&(objective.type in objective_list) && objective:target)
						def_target = objective:target.current

					var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
					if (!new_target) return

					var/objective_path = text2path("/datum/objective/[new_obj_type]")
					if (new_target == "Free objective")
						new_objective = new objective_path
						new_objective.owner = src
						new_objective:target = null
						new_objective.explanation_text = "Free objective"
					else
						new_objective = new objective_path
						new_objective.owner = src
						new_objective:target = new_target:mind
						//Will display as special role if the target is set as MODE. Ninjas/commandos/nuke ops.
						new_objective.explanation_text = "[objective_type] [new_target:real_name], the [new_target:mind:assigned_role=="MODE" ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."

				if ("prevent")
					new_objective = new /datum/objective/block
					new_objective.owner = src

				if ("hijack")
					new_objective = new /datum/objective/hijack
					new_objective.owner = src

				if ("escape")
					new_objective = new /datum/objective/escape
					new_objective.owner = src

				if ("survive")
					new_objective = new /datum/objective/survive
					new_objective.owner = src

				if ("mercenary")
					new_objective = new /datum/objective/nuclear
					new_objective.owner = src

				if ("steal")
					if (!istype(objective, /datum/objective/steal))
						new_objective = new /datum/objective/steal
						new_objective.owner = src
					else
						new_objective = objective
					var/datum/objective/steal/steal = new_objective
					if (!steal.select_target())
						return

				if("download","capture","absorb")
					var/def_num
					if(objective&&objective.type==text2path("/datum/objective/[new_obj_type]"))
						def_num = objective.target_amount

					var/target_number = input("Input target number:", "Objective", def_num) as num|null
					if (isnull(target_number))//Ordinarily, you wouldn't need isnull. In this case, the value may already exist.
						return

					switch(new_obj_type)
						if("download")
							new_objective = new /datum/objective/download
							new_objective.explanation_text = "Download [target_number] research levels."
						if("capture")
							new_objective = new /datum/objective/capture
							new_objective.explanation_text = "Accumulate [target_number] capture points."
						if("absorb")
							new_objective = new /datum/objective/absorb
							new_objective.explanation_text = "Absorb [target_number] compatible genomes."
					new_objective.owner = src
					new_objective.target_amount = target_number

				if ("custom")
					var/expl = sanitize(input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null)
					if (!expl) return
					new_objective = new /datum/objective
					new_objective.owner = src
					new_objective.explanation_text = expl

			if (!new_objective) return

			if (objective)
				objectives -= objective
				objectives.Insert(objective_pos, new_objective)
			else
				objectives += new_objective

		else if (href_list["obj_delete"])
			var/datum/objective/objective = locate(href_list["obj_delete"])
			if(!istype(objective))	return
			objectives -= objective

		else if(href_list["obj_completed"])
			var/datum/objective/objective = locate(href_list["obj_completed"])
			if(!istype(objective))	return
			objective.completed = !objective.completed

		else if(href_list["implant"])
			var/mob/living/carbon/human/H = current

			BITSET(H.hud_updateflag, IMPLOYAL_HUD)   // updates that players HUD images so secHUD's pick up they are implanted or not.

			switch(href_list["implant"])
				if("remove")
					for(var/obj/item/weapon/implant/loyalty/I in H.contents)
						for(var/obj/item/organ/external/organs in H.organs)
							if(I in organs.implants)
								qdel(I)
								break
					H << "<span class='notice'><font size =3><B>Your loyalty implant has been deactivated.</font></span>"
					log_admin("[key_name_admin(usr)] has de-loyalty implanted [current].")
				if("add")
					H << "<span class='danger'><font size =3>You somehow have become the recepient of a loyalty transplant, and it just activated!</font>"
					H.implant_loyalty(H, override = TRUE)
					log_admin("[key_name_admin(usr)] has loyalty implanted [current].")
				else
		/*
		else if (href_list["monkey"])
			var/mob/living/L = current
			if (L.transforming)
				return
			switch(href_list["monkey"])
				if("healthy")
					if (usr.client.holder.rights & R_ADMIN)
						var/mob/living/carbon/human/H = current
						var/mob/living/carbon/monkey/M = current
						if (istype(H))
							log_admin("[key_name(usr)] attempting to monkeyize [key_name(current)]")
							message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize [key_name_admin(current)]</span>")
							src = null
							M = H.monkeyize()
							src = M.mind
							//world << "DEBUG: \"healthy\": M=[M], M.mind=[M.mind], src=[src]!"
						else if (istype(M) && length(M.viruses))
							for(var/datum/disease/D in M.viruses)
								D.cure(0)
							sleep(0) //because deleting of virus is done through spawn(0)
				if("infected")
					if (usr.client.holder.rights & R_ADMIN)
						var/mob/living/carbon/human/H = current
						var/mob/living/carbon/monkey/M = current
						if (istype(H))
							log_admin("[key_name(usr)] attempting to monkeyize and infect [key_name(current)]")
							message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize and infect [key_name_admin(current)]</span>", 1)
							src = null
							M = H.monkeyize()
							src = M.mind
							current.contract_disease(new /datum/disease/jungle_fever,1,0)
						else if (istype(M))
							current.contract_disease(new /datum/disease/jungle_fever,1,0)
				if("human")
					var/mob/living/carbon/monkey/M = current
					if (istype(M))
						for(var/datum/disease/D in M.viruses)
							if (istype(D,/datum/disease/jungle_fever))
								D.cure(0)
								sleep(0) //because deleting of virus is doing throught spawn(0)
						log_admin("[key_name(usr)] attempting to humanize [key_name(current)]")
						message_admins("<span class='notice'>[key_name_admin(usr)] attempting to humanize [key_name_admin(current)]</span>")
						var/obj/item/weapon/dnainjector/m2h/m2h = new
						var/obj/item/weapon/implant/mobfinder = new(M) //hack because humanizing deletes mind --rastaf0
						src = null
						m2h.inject(M)
						src = mobfinder.loc:mind
						qdel(mobfinder)
						current.radiation -= 50
		*/
		else if (href_list["silicon"])
			BITSET(current.hud_updateflag, SPECIALROLE_HUD)
			switch(href_list["silicon"])

				if("unemag")
					var/mob/living/silicon/robot/R = current
					if (istype(R))
						R.emagged = 0
						if (R.activated(R.module.emag))
							R.module_active = null
						if(R.module_state_1 == R.module.emag)
							R.module_state_1 = null
							R.contents -= R.module.emag
						else if(R.module_state_2 == R.module.emag)
							R.module_state_2 = null
							R.contents -= R.module.emag
						else if(R.module_state_3 == R.module.emag)
							R.module_state_3 = null
							R.contents -= R.module.emag
						log_admin("[key_name_admin(usr)] has unemag'ed [R].")

				if("unemagcyborgs")
					if (istype(current, /mob/living/silicon/ai))
						var/mob/living/silicon/ai/ai = current
						for (var/mob/living/silicon/robot/R in ai.connected_robots)
							R.emagged = 0
							if (R.module)
								if (R.activated(R.module.emag))
									R.module_active = null
								if(R.module_state_1 == R.module.emag)
									R.module_state_1 = null
									R.contents -= R.module.emag
								else if(R.module_state_2 == R.module.emag)
									R.module_state_2 = null
									R.contents -= R.module.emag
								else if(R.module_state_3 == R.module.emag)
									R.module_state_3 = null
									R.contents -= R.module.emag
						log_admin("[key_name_admin(usr)] has unemag'ed [ai]'s Cyborgs.")

		else if (href_list["common"])
			switch(href_list["common"])
				if("undress")
					for(var/obj/item/W in current)
						current.drop_from_inventory(W)
				if("takeuplink")
					take_uplink()
					memory = null//Remove any memory they may have had.
				if("crystals")
					if (usr.client.holder.rights & R_FUN)
						var/obj/item/device/uplink/hidden/suplink = find_syndicate_uplink()
						var/crystals
						if (suplink)
							crystals = suplink.uses
						crystals = input("Amount of telecrystals for [key]","Operative uplink", crystals) as null|num
						if (!isnull(crystals))
							if (suplink)
								suplink.uses = crystals

		else if (href_list["obj_announce"])
			var/obj_count = 1
			current << "<span class='notice'>Your current objectives:</span>"
			for(var/datum/objective/objective in objectives)
				current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++
		edit_memory()
/*
	proc/clear_memory(var/silent = 1)
		var/datum/game_mode/current_mode = ticker.mode

		// remove traitor uplinks
		var/list/L = current.get_contents()
		for (var/t in L)
			if (istype(t, /obj/item/device/pda))
				if (t:uplink) qdel(t:uplink)
				t:uplink = null
			else if (istype(t, /obj/item/device/radio))
				if (t:traitorradio) qdel(t:traitorradio)
				t:traitorradio = null
				t:traitor_frequency = 0.0
			else if (istype(t, /obj/item/weapon/SWF_uplink) || istype(t, /obj/item/weapon/syndicate_uplink))
				if (t:origradio)
					var/obj/item/device/radio/R = t:origradio
					R.loc = current.loc
					R.traitorradio = null
					R.traitor_frequency = 0.0
				qdel(t)

		// remove wizards spells
		//If there are more special powers that need removal, they can be procced into here./N
		current.spellremove(current)

		// clear memory
		memory = ""
		special_role = null

*/

	proc/find_syndicate_uplink()
		var/list/L = current.get_contents()
		for (var/obj/item/I in L)
			if (I.hidden_uplink)
				return I.hidden_uplink
		return null

	proc/take_uplink()
		var/obj/item/device/uplink/hidden/H = find_syndicate_uplink()
		if(H)
			qdel(H)


	// check whether this mind's mob has been brigged for the given duration
	// have to call this periodically for the duration to work properly
	proc/is_brigged(duration)
		var/turf/T = current.loc
		if(!istype(T))
			brigged_since = -1
			return 0

		var/is_currently_brigged = 0

		if(istype(T.loc,/area/security/brig))
			is_currently_brigged = 1
			for(var/obj/item/weapon/card/id/card in current)
				is_currently_brigged = 0
				break // if they still have ID they're not brigged
			for(var/obj/item/device/pda/P in current)
				if(P.id)
					is_currently_brigged = 0
					break // if they still have ID they're not brigged

		if(!is_currently_brigged)
			brigged_since = -1
			return 0

		if(brigged_since == -1)
			brigged_since = world.time

		return (duration <= world.time - brigged_since)


//Antagonist role check
/mob/living/proc/check_special_role(role)
	if(mind)
		if(!role)
			return mind.special_role
		else
			return (mind.special_role == role) ? 1 : 0
	else
		return 0

//Initialisation procs
/mob/living/proc/mind_initialize()
	if(mind)
		mind.key = key
	else
		mind = new /datum/mind(key)
		mind.original = src
		if(ticker)
			ticker.minds += mind
		else
			world.log << "## DEBUG: mind_initialize(): No ticker ready yet! Please inform Carn"
	if(!mind.name)	mind.name = real_name
	mind.current = src

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)	mind.assigned_role = "Assistant"	//defualt

//slime
/mob/living/carbon/slime/mind_initialize()
	..()
	mind.assigned_role = "slime"

/mob/living/carbon/alien/larva/mind_initialize()
	..()
	mind.special_role = "Larva"

//AI
/mob/living/silicon/ai/mind_initialize()
	..()
	mind.assigned_role = "AI"

//BORG
/mob/living/silicon/robot/mind_initialize()
	..()
	mind.assigned_role = "Cyborg"

//PAI
/mob/living/silicon/pai/mind_initialize()
	..()
	mind.assigned_role = "pAI"
	mind.special_role = ""

//Animals
/mob/living/simple_animal/mind_initialize()
	..()
	mind.assigned_role = "Animal"

/mob/living/simple_animal/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"

/mob/living/simple_animal/shade/mind_initialize()
	..()
	mind.assigned_role = "Shade"

/mob/living/simple_animal/construct/builder/mind_initialize()
	..()
	mind.assigned_role = "Artificer"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/wraith/mind_initialize()
	..()
	mind.assigned_role = "Wraith"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/armoured/mind_initialize()
	..()
	mind.assigned_role = "Juggernaut"
	mind.special_role = "Cultist"
