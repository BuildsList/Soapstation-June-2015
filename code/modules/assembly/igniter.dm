/obj/item/device/assembly/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustable substances."
	icon_state = "igniter"
	matter = list("steel" = 500, "glass" = 50, "waste" = 10)
	origin_tech = "magnets=1"

	secured = 1
	wires = WIRE_RECEIVE

	activate()
		if(!..())	return 0//Cooldown check

		if(holder && istype(holder.loc,/obj/item/weapon/grenade/chem_grenade))
			var/obj/item/weapon/grenade/chem_grenade/grenade = holder.loc
			grenade.prime()
		else
			var/turf/location = get_turf(loc)
			if(location)
				location.hotspot_expose(1000,1000)
			if (istype(src.loc,/obj/item/device/assembly_holder))
				if (istype(src.loc.loc, /obj/structure/reagent_dispensers/fueltank/))
					var/obj/structure/reagent_dispensers/fueltank/tank = src.loc.loc
					if (tank && tank.modded)
						tank.explode()

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()

		return 1


	attack_self(mob/user as mob)
		activate()
		add_fingerprint(user)
		return