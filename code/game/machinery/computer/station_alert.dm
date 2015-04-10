
/obj/machinery/computer/station_alert
	name = "Station Alert Console"
	desc = "Used to access the station's automated alert system."
	icon_state = "alert:0"
	circuit = "/obj/item/weapon/circuitboard/stationalert"
	var/obj/nano_module/alarm_monitor/alarm_monitor
	var/monitor_type = /obj/nano_module/alarm_monitor/engineering

/obj/machinery/computer/station_alert/security
	name = "Security Alert Console"
	monitor_type = /obj/nano_module/alarm_monitor/security

/obj/machinery/computer/station_alert/New()
	..()
	alarm_monitor = new monitor_type(src)
	alarm_monitor.register(src, /obj/machinery/computer/station_alert/update_icon)

/obj/machinery/computer/station_alert/Del()
	alarm_monitor.unregister(src)
	..()

/obj/machinery/computer/station_alert/attack_ai(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)
	return

/obj/machinery/computer/station_alert/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)
	return

/obj/machinery/computer/station_alert/interact(mob/user)
	alarm_monitor.ui_interact(user)

/obj/machinery/computer/station_alert/update_icon()
	..()
	if(stat & (BROKEN|NOPOWER))
		return

	var/list/alarms = alarm_monitor.major_alarms()
	if(alarms.len)
		icon_state = "alert:2"
	else
		icon_state = initial(icon_state)
	return
