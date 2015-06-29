/obj/machinery/portable_atmospherics
	name = "atmoalter"
	use_power = 0
	var/datum/gas_mixture/air_contents = new

	var/obj/machinery/atmospherics/portables_connector/connected_port
	var/obj/item/weapon/tank/holding

	var/volume = 0
	var/destroyed = 0

	var/start_pressure = ONE_ATMOSPHERE
	var/maximum_pressure = 90 * ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/New()
	..()

	air_contents.volume = volume
	air_contents.temperature = T20C

	return 1

/obj/machinery/portable_atmospherics/Destroy()
	qdel(air_contents)
	qdel(holding)
	..()

/obj/machinery/portable_atmospherics/initialize()
	. = ..()
	spawn()
		var/obj/machinery/atmospherics/portables_connector/port = locate() in loc
		if(port)
			connect(port)
			update_icon()

/obj/machinery/portable_atmospherics/process()
	if(!connected_port) //only react when pipe_network will ont it do it for you
		//Allow for reactions
		air_contents.react()
	else
		update_icon()

/obj/machinery/portable_atmospherics/Destroy()
	qdel(air_contents)

	..()

/obj/machinery/portable_atmospherics/proc/StandardAirMix()
	return list(
		"oxygen" = O2STANDARD * MolesForPressure(),
		"nitrogen" = N2STANDARD *  MolesForPressure())

/obj/machinery/portable_atmospherics/proc/MolesForPressure(var/target_pressure = start_pressure)
	return (target_pressure * air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

/obj/machinery/portable_atmospherics/update_icon()
	return null

/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return 0

	//Make sure are close enough for a valid connection
	if(new_port.loc != loc)
		return 0

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	connected_port.on = 1 //Activate port updates

	anchored = 1 //Prevent movement

	//Actually enforce the air sharing
	var/datum/pipe_network/network = connected_port.return_network(src)
	if(network && !network.gases.Find(air_contents))
		network.gases += air_contents
		network.update = 1

	return 1

/obj/machinery/portable_atmospherics/proc/disconnect()
	if(!connected_port)
		return 0

	var/datum/pipe_network/network = connected_port.return_network(src)
	if(network)
		network.gases -= air_contents

	anchored = 0

	connected_port.connected_device = null
	connected_port = null

	return 1

/obj/machinery/portable_atmospherics/proc/update_connected_network()
	if(!connected_port)
		return

	var/datum/pipe_network/network = connected_port.return_network(src)
	if (network)
		network.update = 1

/obj/machinery/portable_atmospherics/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	var/obj/icon = src
	if ((istype(W, /obj/item/weapon/tank) && !( src.destroyed )))
		if (src.holding)
			return
		var/obj/item/weapon/tank/T = W
		user.drop_item()
		T.loc = src
		src.holding = T
		update_icon()
		return

	else if (istype(W, /obj/item/weapon/wrench))
		if(connected_port)
			disconnect()
			user << "<span class='notice'>You disconnect \the [src] from the port.</span>"
			update_icon()
			return
		else
			var/obj/machinery/atmospherics/portables_connector/possible_port = locate(/obj/machinery/atmospherics/portables_connector/) in loc
			if(possible_port)
				if(connect(possible_port))
					user << "<span class='notice'>You connect \the [src] to the port.</span>"
					update_icon()
					return
				else
					user << "<span class='notice'>\The [src] failed to connect to the port.</span>"
					return
			else
				user << "<span class='notice'>Nothing happens.</span>"
				return

	else if ((istype(W, /obj/item/device/analyzer)) && Adjacent(user))
		visible_message("<span class='notice'>\The [user] has used \the [W] on \the [src] \icon[icon]</span>")
		if(air_contents)
			var/pressure = air_contents.return_pressure()
			var/total_moles = air_contents.total_moles

			user << "<span class='notice'>Results of analysis of \icon[icon]</span>"
			if (total_moles>0)
				user << "<span class='notice'>Pressure: [round(pressure,0.1)] kPa</span>"
				for(var/g in air_contents.gas)
					user << "<span class='notice'>[gas_data.name[g]]: [round((air_contents.gas[g] / total_moles) * 100)]%</span>"
				user << "<span class='notice'>Temperature: [round(air_contents.temperature-T0C)]&deg;C</span>"
			else
				user << "<span class='notice'>Tank is empty!</span>"
		else
			user << "<span class='notice'>Tank is empty!</span>"
		return

	return



/obj/machinery/portable_atmospherics/powered
	var/power_rating
	var/power_losses
	var/last_power_draw = 0
	var/obj/item/weapon/cell/cell

/obj/machinery/portable_atmospherics/powered/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/cell))
		if(cell)
			user << "There is already a power cell installed."
			return

		var/obj/item/weapon/cell/C = I

		user.drop_item()
		C.add_fingerprint(user)
		cell = C
		C.loc = src
		user.visible_message("<span class='notice'>[user] opens the panel on [src] and inserts [C].</span>", "<span class='notice'>You open the panel on [src] and insert [C].</span>")
		return

	if(istype(I, /obj/item/weapon/screwdriver))
		if(!cell)
			user << "<span class='warning'>There is no power cell installed.</span>"
			return

		user.visible_message("<span class='notice'>[user] opens the panel on [src] and removes [cell].</span>", "<span class='notice'>You open the panel on [src] and remove [cell].</span>")
		cell.add_fingerprint(user)
		cell.loc = src.loc
		cell = null
		return

	..()

/obj/machinery/portable_atmospherics/proc/log_open()
	if(air_contents.gas.len == 0)
		return

	var/gases = ""
	for(var/gas in air_contents.gas)
		if(gases)
			gases += ", [gas]"
		else
			gases = gas
	log_admin("[usr] ([usr.ckey]) opened '[src.name]' containing [gases].")
	message_admins("[usr] ([usr.ckey]) opened '[src.name]' containing [gases].")
