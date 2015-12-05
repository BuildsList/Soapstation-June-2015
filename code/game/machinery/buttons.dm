/obj/machinery/button
	name = "button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for something."
	var/id = null
	var/active = 0
	var/operating = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4
	var/_wifi_id
	var/datum/wifi/sender/button/wifi_sender

/obj/machinery/button/initialize()
	..()
	update_icon()
	if(_wifi_id)
		wifi_sender = new(_wifi_id, src)

/obj/machinery/button/Destroy()
	qdel(wifi_sender)
	wifi_sender = null
	return..()

/obj/machinery/button/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/button/attackby(obj/item/weapon/W, mob/user as mob)
	return attack_hand(user)

/obj/machinery/button/attack_hand(mob/living/user)
	if(..()) return 1
	activate(user)

/obj/machinery/button/proc/activate(mob/living/user)
	if(operating || !istype(wifi_sender))
		return

	operating = 1
	active = 1
	use_power(5)
	update_icon()
	wifi_sender.activate(user)
	sleep(10)
	active = 0
	update_icon()
	operating = 0

/obj/machinery/button/update_icon()
	if(active)
		icon_state = "launcheract"
	else
		icon_state = "launcherbtt"

//alternate button with the same functionality, except has a lightswitch sprite instead
/obj/machinery/button/switch
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"

/obj/machinery/button/switch/update_icon()
	icon_state = "light[active]"

//alternate button with the same functionality, except has a door control sprite instead
/obj/machinery/button/alternate
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"

/obj/machinery/button/alternate/update_icon()
	if(active)
		icon_state = "doorctrl0"
	else
		icon_state = "doorctrl2"

//Toggle button with two states (on and off) and calls seperate procs for each state
/obj/machinery/button/toggle/activate(mob/living/user)
	if(operating || !istype(wifi_sender))
		return

	operating = 1
	active = !active
	use_power(5)
	if(active)
		wifi_sender.activate(user)
	else
		wifi_sender.deactivate(user)
	update_icon()
	operating = 0

//alternate button with the same toggle functionality, except has a lightswitch sprite instead
/obj/machinery/button/toggle/switch
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"

/obj/machinery/button/toggle/switch/update_icon()
	icon_state = "light[active]"

//alternate button with the same toggle functionality, except has a door control sprite instead
/obj/machinery/button/toggle/alternate
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"

/obj/machinery/button/toggle/alternate/update_icon()
	if(active)
		icon_state = "doorctrl0"
	else
		icon_state = "doorctrl2"

//-------------------------------
// Mass Driver Button
//  Passes the activate call to a mass driver wifi sender
//-------------------------------
/obj/machinery/button/mass_driver
	name = "mass driver button"
	var/datum/wifi/sender/mass_driver/sender

/obj/machinery/button/mass_driver/initialize()
	..()
	sender = new(_wifi_id, src)

/obj/machinery/button/mass_driver/activate(mob/living/user)
	if(active || !istype(wifi_sender))
		return
	active = 1
	use_power(5)
	update_icon()
	sender.cycle()
	active = 0
	update_icon()


//-------------------------------
// Door Button
//-------------------------------

// Bitmasks for door switches.
#define OPEN   0x1
#define IDSCAN 0x2
#define BOLTS  0x4
#define SHOCK  0x8
#define SAFE   0x10

/obj/machinery/button/toggle/door
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	var/datum/wifi/sender/door/sender

	var/_door_functions = 1
/*	Bitflag, 	1 = open
				2 = idscan
				4 = bolts
				8 = shock
				16 = door safties  */

/obj/machinery/button/toggle/door/update_icon()
	if(active)
		icon_state = "doorctrl0"
	else
		icon_state = "doorctrl2"

/obj/machinery/button/toggle/door/initialize()
	..()
	sender = new(_wifi_id, src)

/obj/machinery/button/toggle/door/activate(mob/living/user)
	if(operating || !istype(sender))
		return

	operating = 1
	active = !active
	use_power(5)
	update_icon()
	if(active)
		if(_door_functions & IDSCAN)
			sender.activate("enable_idscan")
		if(_door_functions & SHOCK)
			sender.activate("electrify")
		if(_door_functions & SAFE)
			sender.activate("enable_safeties")
		if(_door_functions & BOLTS)
			sender.activate("unlock")
		if(_door_functions & OPEN)
			sender.activate("open")
	else
		if(_door_functions & IDSCAN)
			sender.activate("disable_idscan")
		if(_door_functions & SHOCK)
			sender.activate("unelectrify")
		if(_door_functions & SAFE)
			sender.activate("disable_safeties")
		if(_door_functions & OPEN)
			sender.activate("close")
		if(_door_functions & BOLTS)
			sender.activate("lock")
	operating = 0

#undef OPEN
#undef IDSCAN
#undef BOLTS
#undef SHOCK
#undef SAFE
