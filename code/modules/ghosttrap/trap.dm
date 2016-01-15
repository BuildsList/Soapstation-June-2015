// This system is used to grab a ghost from observers with the required preferences and
// lack of bans set. See posibrain.dm for an example of how they are called/used. ~Z

var/list/ghost_traps

/proc/get_ghost_trap(var/trap_key)
	if(!ghost_traps)
		populate_ghost_traps()
	return ghost_traps[trap_key]

/proc/get_ghost_traps()
	if(!ghost_traps)
		populate_ghost_traps()
	return ghost_traps

/proc/populate_ghost_traps()
	ghost_traps = list()
	for(var/traptype in typesof(/datum/ghosttrap))
		var/datum/ghosttrap/G = new traptype
		ghost_traps[G.object] = G

/datum/ghosttrap
	var/object = "positronic brain"
	var/minutes_since_death = 0     // If non-zero the ghost must have been dead for this many minutes to be allowed to spawn
	var/list/ban_checks = list("AI","Cyborg")
	var/pref_check = BE_AI
	var/ghost_trap_message = "They are occupying a positronic brain now."
	var/ghost_trap_role = "Positronic Brain"
	var/can_set_own_name = TRUE
	var/list_as_special_role = TRUE	// If true, this entry will be listed as a special role in the character setup

// Check for bans, proper atom types, etc.
/datum/ghosttrap/proc/assess_candidate(var/mob/dead/observer/candidate, var/mob/target)
	if(!candidate.MayRespawn(1, minutes_since_death))
		return 0
	if(islist(ban_checks))
		for(var/bantype in ban_checks)
			if(jobban_isbanned(candidate, "[bantype]"))
				candidate << "You are banned from one or more required roles and hence cannot enter play as \a [object]."
				return 0
	return 1

// Print a message to all ghosts with the right prefs/lack of bans.
/datum/ghosttrap/proc/request_player(var/mob/target, var/request_string, var/valid_time)
	for(var/mob/dead/observer/O in player_list)
		if(!O.MayRespawn())
			continue
		if(islist(ban_checks))
			for(var/bantype in ban_checks)
				if(jobban_isbanned(O, "[bantype]"))
					continue
		if(pref_check && !(pref_check in O.client.prefs.be_special_role))
			continue
		if(O.client)
			O << "[request_string] <a href='?src=\ref[src];candidate=\ref[O];target=\ref[target]';valid_until=[world.time + valid_time]>(Occupy)</a> ([ghost_follow_link(target, O)])"

// Handles a response to request_player().
/datum/ghosttrap/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["candidate"] && href_list["target"])
		var/mob/dead/observer/candidate = locate(href_list["candidate"]) // BYOND magic.
		var/mob/target = locate(href_list["target"])                     // So much BYOND magic.
		var/valid_until = text2num(href_list["valid_until"])
		if(!target || !candidate)
			return
		if(candidate != usr)
			return
		if(valid_until && world.time > valid_until)
			candidate << "This occupation request is no longer valid."
			return
		if(target.key)
			candidate << "The target is already occupied."
			return
		if(assess_candidate(candidate, target))
			transfer_personality(candidate,target)
		return 1

// Shunts the ckey/mind into the target mob.
/datum/ghosttrap/proc/transfer_personality(var/mob/candidate, var/mob/target)
	if(!assess_candidate(candidate))
		return 0
	target.ckey = candidate.ckey
	if(target.mind)
		target.mind.assigned_role = "[ghost_trap_role]"
	announce_ghost_joinleave(candidate, 0, "[ghost_trap_message]")
	welcome_candidate(target)
	set_new_name(target)
	return 1

// Fluff!
/datum/ghosttrap/proc/welcome_candidate(var/mob/target)
	target << "<b>You are a positronic brain, brought into existence on [station_name()].</b>"
	target << "<b>As a synthetic intelligence, you answer to all crewmembers, as well as the AI.</b>"
	target << "<b>Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>"
	target << "<b>Use say [target.get_language_prefix()]b to speak to other artificial intelligences.</b>"
	var/turf/T = get_turf(target)
	T.visible_message("<span class='notice'>\The [src] chimes quietly.</span>")
	var/obj/item/device/mmi/digital/posibrain/P = target.loc
	if(!istype(P)) //wat
		return
	P.searching = 0
	P.name = "positronic brain ([P.brainmob.name])"
	P.icon_state = "posibrain-occupied"

// Allows people to set their own name. May or may not need to be removed for posibrains if people are dumbasses.
/datum/ghosttrap/proc/set_new_name(var/mob/target)
	if(!can_set_own_name)
		return

	var/newname = sanitizeSafe(input(target,"Enter a name, or leave blank for the default name.", "Name change","") as text, MAX_NAME_LEN)
	if (newname != "")
		target.real_name = newname
		target.name = target.real_name

/***********************************
* Diona pods and walking mushrooms *
***********************************/
/datum/ghosttrap/plant
	object = "living plant"
	ban_checks = list("Dionaea")
	pref_check = BE_PLANT
	ghost_trap_message = "They are occupying a living plant now."
	ghost_trap_role = "Plant"

/datum/ghosttrap/plant/welcome_candidate(var/mob/target)
	target << "<span class='alium'><B>You awaken slowly, stirring into sluggish motion as the air caresses you.</B></span>"
	// This is a hack, replace with some kind of species blurb proc.
	if(istype(target,/mob/living/carbon/alien/diona))
		target << "<B>You are \a [target], one of a race of drifting interstellar plantlike creatures that sometimes share their seeds with human traders.</B>"
		target << "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>"

/*****************
* Cortical Borer *
*****************/
/datum/ghosttrap/borer
	object = "cortical borer"
	ban_checks = list("Borer")
	pref_check = BE_ALIEN
	ghost_trap_message = "They are occupying a borer now."
	ghost_trap_role = "Cortical Borer"
	can_set_own_name = FALSE
	list_as_special_role = FALSE

/datum/ghosttrap/borer/welcome_candidate(var/mob/target)
	target << "<span class='notice'>You are a cortical borer!</span> You are a brain slug that worms its way \
	into the head of its victim. Use stealth, persuasion and your powers of mind control to keep you, \
	your host and your eventual spawn safe and warm."
	target << "You can speak to your victim with <b>say</b>, to other borers with <b>say [target.get_language_prefix()]x</b>, and use your Abilities tab to access powers."

/********************
* Maintenance Drone *
*********************/
/datum/ghosttrap/drone
	object = "maintenance drone"
	pref_check = BE_PAI
	ghost_trap_message = "They are occupying a maintenance drone now."
	ghost_trap_role = "Maintenance Drone"
	can_set_own_name = FALSE
	list_as_special_role = FALSE

/datum/ghosttrap/drone/New()
	minutes_since_death = DRONE_SPAWN_DELAY
	..()

datum/ghosttrap/drone/assess_candidate(var/mob/dead/observer/candidate, var/mob/target)
	. = ..()
	if(. && !target.can_be_possessed_by(candidate))
		return 0

datum/ghosttrap/drone/transfer_personality(var/mob/candidate, var/mob/living/silicon/robot/drone/drone)
	if(!assess_candidate(candidate))
		return 0
	drone.transfer_personality(candidate.client)
