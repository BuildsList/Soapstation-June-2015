/obj/item/stack/tile/steel
	name = "floor tile"
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon" //why?
	icon_state = "tile"
	force = 6.0
	matter = list(DEFAULT_WALL_MATERIAL = 937.5)
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	flags = CONDUCT

/obj/item/stack/tile/steel/New(var/loc, var/amount=null)
	..()
	src.pixel_x = rand(1, 14)
	src.pixel_y = rand(1, 14)
	return

/obj/item/stack/tile/steel/cyborg
	name = "floor tile synthesizer"
	desc = "A device that makes floor tiles."
	gender = NEUTER
	matter = null
	uses_charge = 1
	charge_costs = list(250)
	stacktype = /obj/item/stack/tile/steel
	build_type = /obj/item/stack/tile/steel

/*
/obj/item/stack/tile/steel/attack_self(mob/user as mob)
	if (usr.stat)
		return
	var/T = user.loc
	if (!( istype(T, /turf) ))
		user << "\red You must be on the ground!"
		return
	if (!( istype(T, /turf/space) ))
		user << "\red You cannot build on or repair this turf!"
		return
	src.build(T)
	src.add_fingerprint(user)
	use(1)
	return
*/

/obj/item/stack/tile/steel/proc/build(turf/S as turf)
	if (istype(S,/turf/space))
		S.ChangeTurf(/turf/simulated/floor/plating/airless)
	else
		S.ChangeTurf(/turf/simulated/floor/plating)
//	var/turf/simulated/floor/W = S.ReplaceWithFloor()
//	W.make_plating()
	return
