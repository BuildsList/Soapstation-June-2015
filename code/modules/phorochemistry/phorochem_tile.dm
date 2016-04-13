/turf/simulated/floor/phorochem
	name = "electromagnetic tile"
	icon_state = "gcircuitoff"
	icon_regular_floor = "gicircuitoff"
	floor_type = /obj/item/stack/tile/phorochem
	var/obj/item/stack/tile/fake_tile
	var/icon_state_covered

/turf/simulated/floor/phorochem/attackby(obj/item/C as obj, mob/user as mob)
	if(istype(C, /obj/item/stack/tile))
		var/obj/item/stack/tile/T = C
		fake_tile = new T.type
		T.use(1)
		var/new_icon = get_tile_icon(fake_tile)
		if(new_icon)
			if(new_icon == "floor")
				if(icon_state_covered)
					icon_state = icon_state_covered
				else
					icon_state = "floor"
			else
				icon_state = new_icon
		levelupdate()
		user << "\blue You cover the electromagnetic tile with [fake_tile]"
		name = "floor"
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
	else if(istype(C, /obj/item/weapon/crowbar))
		if(fake_tile)
			var/obj/item/stack/tile/T
			T = new fake_tile.type(src)
			user << "\red You remove the fake covering from the electromagnetic tile"
			playsound(src, 'sound/items/Crowbar.ogg', 80, 1)
			T.x = T.x //make the compiler stop yelling at me, no YOUR variable is undefined but not used
			del(fake_tile)
			src.icon_state = icon_regular_floor
			name = "electromagnetic tile"
		else
			var/obj/item/stack/tile/T
			T = new floor_type(src)
			T.x = T.x
			src.ChangeTurf(/turf/simulated/floor) //make it plating through and through
			src.make_plating()
			icon_state = icon_plating
			user << "\red You remove the electromagnetic tile."
			playsound(src, 'sound/items/Crowbar.ogg', 80, 1)


/turf/simulated/floor/phorochem/proc/get_tile_icon(var/obj/item/stack/tile/T) //horrible but it works -DrBrock
	if(istype(T, /obj/item/stack/tile/light)) //NU
		return 0

	if(istype(T, /obj/item/stack/tile/wood))
		if( !(icon_state in wood_icons) )
			return "wood"

	if(istype(T, /obj/item/stack/tile/grass))
		if(!(icon_state in list("grass1","grass2","grass3","grass4")))
			return "grass[pick("1","2","3","4")]"

	if(istype(T, /obj/item/stack/tile/carpet))
		if(icon_state != "carpetsymbol")
			var/connectdir = 0
			for(var/direction in cardinal)
				if(istype(get_step(src,direction),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,direction)
					if(FF.is_carpet_floor())
						connectdir |= direction

			//Check the diagonal connections for corners, where you have, for example, connections both north and east. In this case it checks for a north-east connection to determine whether to add a corner marker or not.
			var/diagonalconnect = 0 //1 = NE; 2 = SE; 4 = NW; 8 = SW

			//Northeast
			if(connectdir & NORTH && connectdir & EAST)
				if(istype(get_step(src,NORTHEAST),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,NORTHEAST)
					if(FF.is_carpet_floor())
						diagonalconnect |= 1

			//Southeast
			if(connectdir & SOUTH && connectdir & EAST)
				if(istype(get_step(src,SOUTHEAST),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,SOUTHEAST)
					if(FF.is_carpet_floor())
						diagonalconnect |= 2

			//Northwest
			if(connectdir & NORTH && connectdir & WEST)
				if(istype(get_step(src,NORTHWEST),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,NORTHWEST)
					if(FF.is_carpet_floor())
						diagonalconnect |= 4

			//Southwest
			if(connectdir & SOUTH && connectdir & WEST)
				if(istype(get_step(src,SOUTHWEST),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,SOUTHWEST)
					if(FF.is_carpet_floor())
						diagonalconnect |= 8

			return "carpet[connectdir]-[diagonalconnect]"

	return "floor"

/turf/simulated/floor/phorochem/examine(mob/user)
	if(!fake_tile)
		user << "That's an electromagnetic tile."
	else
		user << "That's a floor. It looks a bit off-center."
	return 1

//phorochem floor tile object
/obj/item/stack/tile/phorochem
	name = "electromagnetic tile"
	singular_name = "electromagnetic tile"
	desc = "A tile for use in the creation of electromagnetic fields"
	icon_state = "fr_tile"
	w_class = 3.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	flags = CONDUCT
	max_amount = 1
	origin_tech = "magnets=3"

/obj/item/stack/tile/phorochem/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target, /turf/simulated/floor))
		var/turf/simulated/floor/T = target
		if(ispath(T.floor_type, /obj/item/stack/tile/phorochem))
			//var/turf/simulated/floor/phorochem/tile = null
			var/icon = T.icon_regular_floor
			T.ChangeTurf(/turf/simulated/floor/phorochem)
			T:icon_state_covered = icon
			return
	return ..()

datum/design/item/phorochem_tile
	name = "electromagnetic floor tile"
	id = "phorochem_tile"
	req_tech = list("magnets" = 3, "materials" = 3)
	materials = list("$metal" = 1000)
	build_path = /obj/item/stack/tile/phorochem