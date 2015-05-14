var/list/global/wall_cache = list()

/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/wall_masks.dmi'
	icon_state = "generic"
	opacity = 1
	density = 1
	blocks_air = 1
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/damage = 0
	var/damage_overlay
	var/global/damage_overlays[8]
	var/active
	var/last_event
	var/can_open = 0
	var/material/material
	var/material/reinf_material
	var/last_state
	var/construction_stage

/turf/simulated/wall/New(var/newloc, var/materialtype, var/rmaterialtype)
	..(newloc)
	icon_state = "blank"
	if(!materialtype)
		materialtype = DEFAULT_WALL_MATERIAL
	material = get_material_by_name(materialtype)
	if(!isnull(rmaterialtype))
		reinf_material = name_to_material[rmaterialtype]
	update_material()

/turf/simulated/wall/bullet_act(var/obj/item/projectile/Proj)

	radiate()
	if(istype(Proj,/obj/item/projectile/beam))
		ignite(2500)
	else if(istype(Proj,/obj/item/projectile/ion))
		ignite(500)

	// Tasers and stuff? No thanks. Also no clone or tox damage crap.
	if(!(Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		return

	//cap the amount of damage, so that things like emitters can't destroy walls in one hit.
	var/damage = min(Proj.damage, 100)

	take_damage(damage)
	return

/turf/simulated/wall/hitby(AM as mob|obj, var/speed=THROWFORCE_SPEED_DIVISOR)
	..()
	if(ismob(AM))
		return

	var/tforce = AM:throwforce * (speed/THROWFORCE_SPEED_DIVISOR)
	if (tforce < 15)
		return

	take_damage(tforce)

/turf/simulated/wall/proc/clear_plants()
	for(var/obj/effect/overlay/wallrot/WR in src)
		qdel(WR)
	for(var/obj/effect/plant/plant in range(src, 1))
		if(!plant.floor) //shrooms drop to the floor
			plant.floor = 1
			plant.update_icon()
			plant.pixel_x = 0
			plant.pixel_y = 0
		plant.update_neighbors()

/turf/simulated/wall/ChangeTurf(var/newtype)
	clear_plants()
	..(newtype)

//Appearance
/turf/simulated/wall/examine(mob/user)
	. = ..(user)

	if(!damage)
		user << "<span class='notice'>It looks fully intact.</span>"
	else
		var/dam = damage / material.integrity
		if(dam <= 0.3)
			user << "<span class='warning'>It looks slightly damaged.</span>"
		else if(dam <= 0.6)
			user << "<span class='warning'>It looks moderately damaged.</span>"
		else
			user << "<span class='danger'>It looks heavily damaged.</span>"

	if(locate(/obj/effect/overlay/wallrot) in src)
		user << "<span class='warning'>There is fungus growing on [src].</span>"

//Damage

/turf/simulated/wall/melt()

	if(!can_melt())
		return

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	if(!F)
		return
	F.burn_tile()
	F.icon_state = "wall_thermite"
	visible_message("<span class='danger'>\The [src] spontaneously combusts!.</span>") //!!OH SHIT!!
	return

/turf/simulated/wall/proc/take_damage(dam)
	if(dam)
		damage = max(0, damage + dam)
		update_damage()
	return

/turf/simulated/wall/proc/update_damage()
	var/cap = material.integrity
	if(reinf_material)
		cap += reinf_material.integrity

	if(locate(/obj/effect/overlay/wallrot) in src)
		cap = cap / 10

	if(damage >= cap)
		dismantle_wall()
	else
		update_icon()

	return

/turf/simulated/wall/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	ignite(exposed_temperature)

/turf/simulated/wall/adjacent_fire_act(turf/simulated/floor/adj_turf, datum/gas_mixture/adj_air, adj_temp, adj_volume)
	ignite(adj_temp)
	if(adj_temp > material.melting_point)
		take_damage(log(RAND_F(0.9, 1.1) * (adj_temp - material.melting_point)))

	return ..()

/turf/simulated/wall/proc/dismantle_wall(devastated=0, explode=0)

	playsound(src, 'sound/items/Welder.ogg', 100, 1)
	if(reinf_material)
		reinf_material.place_dismantled_girder(src, reinf_material)
		reinf_material.place_dismantled_product(src,devastated)
	else
		material.place_dismantled_girder(src)
	material.place_dismantled_product(src,devastated)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.loc = src

	ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1.0)
			src.ChangeTurf(/turf/space)
			return
		if(2.0)
			if(prob(75))
				take_damage(rand(150, 250))
			else
				dismantle_wall(1,1)
		if(3.0)
			take_damage(rand(0, 250))
		else
	return

/turf/simulated/wall/blob_act()
	take_damage(rand(75, 125))
	return

// Wall-rot effect, a nasty fungus that destroys walls.
/turf/simulated/wall/proc/rot()
	if(locate(/obj/effect/overlay/wallrot) in src)
		return
	var/number_rots = rand(2,3)
	for(var/i=0, i<number_rots, i++)
		new/obj/effect/overlay/wallrot(src)

/turf/simulated/wall/proc/can_melt()
	if(material.unmeltable)
		return 0
	return 1

/turf/simulated/wall/proc/thermitemelt(mob/user as mob)
	if(!can_melt())
		return
	var/obj/effect/overlay/O = new/obj/effect/overlay( src )
	O.name = "Thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.density = 1
	O.layer = 5

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	F.burn_tile()
	F.icon_state = "wall_thermite"
	user << "<span class='warning'>The thermite starts melting through the wall.</span>"

	spawn(100)
		if(O)
			qdel(O)
//	F.sd_LumReset()		//TODO: ~Carn
	return

/turf/simulated/wall/meteorhit(obj/M as obj)
	var/rotting = (locate(/obj/effect/overlay/wallrot) in src)
	if (prob(15) && !rotting)
		dismantle_wall()
	else if(prob(70) && !rotting)
		ChangeTurf(/turf/simulated/floor/plating)
	else
		ReplaceWithLattice()
	return 0

/turf/simulated/wall/proc/radiate()
	var/material/M = name_to_material[material]
	if(!istype(M) || !M.radioactivity)
		return

	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(M.radioactivity,IRRADIATE,0)
			for(var/turf/simulated/wall/T in range(3,src))
				T.radiate()
			last_event = world.time
			active = null
			return
	return

/turf/simulated/wall/proc/burn(temperature)
	spawn(2)
	new /obj/structure/girder(src)
	src.ChangeTurf(/turf/simulated/floor)
	for(var/turf/simulated/floor/target_tile in range(0,src))
		if(material == "phoron") //ergh
			target_tile.assume_gas("phoron", 20, 400+T0C)
		spawn (0) target_tile.hotspot_expose(temperature, 400)
	for(var/turf/simulated/wall/W in range(3,src))
		W.ignite((temperature/4))
	for(var/obj/machinery/door/airlock/phoron/D in range(3,src))
		D.ignite(temperature/4)

/turf/simulated/wall/proc/ignite(var/exposed_temperature)

	var/material/M = name_to_material[material]
	if(!istype(M) || !isnull(M.ignition_point))
		return
	if(exposed_temperature > M.ignition_point)//If the temperature of the object is over 300, then ignite
		burn(exposed_temperature)
		return
	..()

/turf/simulated/wall/Bumped(AM as mob|obj)
	radiate()
	..()

/turf/simulated/wall/Destroy()
	clear_plants()
	check_relatives()
	..()