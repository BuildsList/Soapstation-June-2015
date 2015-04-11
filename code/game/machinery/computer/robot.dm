/obj/machinery/computer/robotics
	name = "robotics control console"
	desc = "Used to remotely lockdown or detonate linked cyborgs."
	icon = 'icons/obj/computer.dmi'
	icon_state = "robot"
	req_access = list(access_robotics)
	circuit = "/obj/item/weapon/circuitboard/robotics"

	var/safety = 1

/obj/machinery/computer/robotics/attack_ai(var/mob/user as mob)
	ui_interact(user)

/obj/machinery/computer/robotics/attack_hand(var/mob/user as mob)
	ui_interact(user)

/obj/machinery/computer/robotics/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	data["robots"] = get_cyborgs(user)
	data["safety"] = safety
	// Also applies for cyborgs. Hides the manual self-destruct button.
	data["is_ai"] = istype(user, /mob/living/silicon) ? 1 : 0


	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "robot_control.tmpl", "Robotic Control Console", 400, 500)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/robotics/Topic(href, href_list)
	if(..())
		return
	var/mob/user = usr
	if(!src.allowed(user))
		user << "Access Denied"
		return

	// Destroys the cyborg
	if(href_list["detonate"])
		var/mob/living/silicon/robot/target = get_cyborg_by_name(href_list["detonate"])
		if(!target || !istype(target))
			return
		if(istype(user, /mob/living/silicon/ai) && (target.connected_ai != user))
			user << "Access Denied. This robot is not linked to you."
			return
		var/choice = input("Really detonate [target.name]?") in list ("Yes", "No")
		if(choice != "Yes")
			return
		if(!target || !istype(target))
			return

		// Antagonistic cyborgs? Left here for downstream
		if(target.mind && target.mind.special_role && target.emagged)
			target << "Extreme danger.  Termination codes detected.  Scrambling security codes and automatic AI unlink triggered."
			target.ResetSecurityCodes()
		else
			message_admins("\blue [key_name_admin(usr)] detonated [target.name]!")
			log_game("\blue [key_name_admin(usr)] detonated [target.name]!")
			target << "<span class='danger'>Self-destruct command received.</span>"
			spawn(10)
				target.self_destruct()



	// Locks or unlocks the cyborg
	else if (href_list["lockdown"])
		var/mob/living/silicon/robot/target = get_cyborg_by_name(href_list["lockdown"])
		if(!target || !istype(target))
			return

		if(istype(user, /mob/living/silicon/ai) && (target.connected_ai != user))
			user << "Access Denied. This robot is not linked to you."
			return

		var/choice = input("Really [target.lockcharge ? "unlock" : "lockdown"] [target.name] ?") in list ("Yes", "No")
		if(choice != "Yes")
			return

		if(!target || !istype(target))
			return

		message_admins("\blue [key_name_admin(usr)] [target.canmove ? "locked down" : "released"] [target.name]!")
		log_game("[key_name(usr)] [target.canmove ? "locked down" : "released"] [target.name]!")
		target.canmove = !target.canmove
		if (target.lockcharge)
			target.lockcharge = !target.lockcharge
			target << "Your lockdown has been lifted!"
		else
			target.lockcharge = !target.lockcharge
			target << "You have been locked down!"

	// Remotely hacks the cyborg. Only antag AIs can do this and only to linked cyborgs.
	else if (href_list["hack"])
		var/mob/living/silicon/robot/target = get_cyborg_by_name(href_list["hack"])
		if(!target || !istype(target))
			return

		// Antag AI checks
		if(!istype(user, /mob/living/silicon/ai) || !user.mind.special_role || (user.mind.original != user) || (target.connected_ai != user))
			user << "Access Denied"
			return

		if(target.emagged)
			user << "Robot is already hacked."
			return

		var/choice = input("Really hack [target.name]? This cannot be undone.") in list("Yes", "No")
		if(choice != "Yes")
			return

		if(!target || !istype(target))
			return

		message_admins("\blue [key_name_admin(usr)] emagged [target.name] using robotic console!")
		log_game("[key_name(usr)] emagged [target.name] using robotic console!")
		target.emagged = 1
		target << "<span class='notice'>Failsafe protocols overriden. New tools available.</span>"

	// Arms the emergency self-destruct system
	else if(href_list["arm"])
		if(istype(user, /mob/living/silicon))
			user << "Access Denied"
			return

		safety = !safety
		user << "You [safety ? "disarm" : "arm"] the emergency self destruct"

	// Destroys all accessible cyborgs if safety is disabled
	else if(href_list["nuke"])
		if(istype(user, /mob/living/silicon))
			user << "Access Denied"
			return
		if(safety)
			user << "Self-destruct aborted - safety active"
			return

		message_admins("\blue [key_name_admin(usr)] detonated all cyborgs!")
		log_game("[key_name(usr)] detonated all cyborgs!")

		for(var/mob/living/silicon/robot/R in mob_list)
			if(istype(R, /mob/living/silicon/robot/drone))
				continue
			// Ignore antagonistic cyborgs
			if(R.scrambledcodes)
				continue
			R << "<span class='danger'>Self-destruct command received.</span>"
			spawn(10)
				R.self_destruct()


// Proc: get_cyborgs()
// Parameters: 1 (operator - mob which is operating the console.)
// Description: Returns NanoUI-friendly list of accessible cyborgs.
/obj/machinery/computer/robotics/proc/get_cyborgs(var/mob/operator)
	var/list/robots = list()

	for(var/mob/living/silicon/robot/R in mob_list)
		// Ignore drones
		if(istype(R, /mob/living/silicon/robot/drone))
			continue
		// Ignore antagonistic cyborgs
		if(R.scrambledcodes)
			continue

		var/list/robot = list()
		robot["name"] = R.name
		if(R.stat)
			robot["status"] = "Not Responding"
		else if (!R.canmove)
			robot["status"] = "Lockdown"
		else
			robot["status"] = "Operational"

		if(R.cell)
			robot["cell"] = 1
			robot["cell_capacity"] = R.cell.maxcharge
			robot["cell_current"] = R.cell.charge
			robot["cell_percentage"] = round(R.cell.percent())
		else
			robot["cell"] = 0

		robot["module"] = R.module ? R.module.name : "None"
		robot["master_ai"] = R.connected_ai ? R.connected_ai.name : "None"
		robot["hackable"] = 0
		// Antag AIs know whether linked cyborgs are hacked or not.
		if(operator && istype(operator, /mob/living/silicon/ai) && (R.connected_ai == operator) && operator.mind.special_role && (operator.mind.original != operator))
			robot["hacked"] = R.emagged ? 1 : 0
			robot["hackable"] = R.emagged? 0 : 1
		robots.Add(list(robot))
	return robots

// Proc: get_cyborg_by_name()
// Parameters: 1 (name - Cyborg we are trying to find)
// Description: Helper proc for finding cyborg by name
/obj/machinery/computer/robotics/proc/get_cyborg_by_name(var/name)
	if (!name)
		return
	for(var/mob/living/silicon/robot/R in mob_list)
		if(R.name == name)
			return R
