var/obj/nano_module/crew_monitor/crew_monitor
var/obj/nano_module/rcon/rcon

/mob/living/silicon/ai/proc/init_subsystems()
	crew_monitor = new(src)
	rcon = new(src)

/mob/living/silicon/ai/proc/nano_rcon()
	set category = "AI Subystems"
	set name = "RCON"

	rcon.ui_interact(usr)

/mob/living/silicon/ai/proc/nano_crew_monitor()
	set category = "AI Subystems"
	set name = "Crew Monitor"

	crew_monitor.ui_interact(usr)
