/* This is an attempt to make some easily reusable "particle" type effect, to stop the code
constantly having to be rewritten. An item like the jetpack that uses the ion_trail_follow system, just has one
defined, then set up when it is created with New(). Then this same system can just be reused each time
it needs to create more trails.A beaker could have a steam_trail_follow system set up, then the steam
would spawn and follow the beaker, even if it is carried or thrown.
*/


/obj/effect/effect
	name = "effect"
	icon = 'icons/effects/effects.dmi'
	mouse_opacity = 0
	unacidable = 1//So effect are not targeted by alien acid.
	pass_flags = PASSTABLE | PASSGRILLE

/obj/effect/Destroy()
	if(reagents)
		reagents.delete()
	return ..()

/datum/effect/effect/system
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/setup = 0

	proc/set_up(n = 3, c = 0, turf/loc)
		if(n > 10)
			n = 10
		number = n
		cardinals = c
		location = loc
		setup = 1

	proc/attach(atom/atom)
		holder = atom

	proc/start()


/////////////////////////////////////////////
// GENERIC STEAM SPREAD SYSTEM

//Usage: set_up(number of bits of steam, use North/South/East/West only, spawn location)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like a smoking beaker, so then you can just call start() and the steam
// will always spawn at the items location, even if it's moved.

/* Example:
var/datum/effect/system/steam_spread/steam = new /datum/effect/system/steam_spread() -- creates new system
steam.set_up(5, 0, mob.loc) -- sets up variables
OPTIONAL: steam.attach(mob)
steam.start() -- spawns the effect
*/
/////////////////////////////////////////////
/obj/effect/effect/steam
	name = "steam"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	density = 0

/datum/effect/effect/system/steam_spread

	set_up(n = 3, c = 0, turf/loc)
		if(n > 10)
			n = 10
		number = n
		cardinals = c
		location = loc

	start()
		var/i = 0
		for(i=0, i<src.number, i++)
			spawn(0)
				if(holder)
					src.location = get_turf(holder)
				var/obj/effect/effect/steam/steam = PoolOrNew(/obj/effect/effect/steam, src.location)
				var/direction
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
				for(i=0, i<pick(1,2,3), i++)
					sleep(5)
					step(steam,direction)
				spawn(20)
					qdel(steam)

/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/obj/effect/sparks
	name = "sparks"
	icon_state = "sparks"
	var/amount = 6.0
	anchored = 1.0
	mouse_opacity = 0

/obj/effect/sparks/New()
	..()
	playsound(src.loc, "sparks", 100, 1)
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100)
		
/obj/effect/sparks/initialize()
	..()
	schedule_task_in(10 SECONDS, /proc/qdel, list(src))

/obj/effect/sparks/Destroy()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100)
	return ..()

/obj/effect/sparks/Move()
	..()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100)

/datum/effect/effect/system/spark_spread
	var/total_sparks = 0 // To stop it being spammed and lagging!

	set_up(n = 3, c = 0, loca)
		if(n > 10)
			n = 10
		number = n
		cardinals = c
		if(istype(loca, /turf/))
			location = loca
		else
			location = get_turf(loca)

	start()
		var/i = 0
		for(i=0, i<src.number, i++)
			if(src.total_sparks > 20)
				return
			spawn(0)
				if(holder)
					src.location = get_turf(holder)
				var/obj/effect/sparks/sparks = PoolOrNew(/obj/effect/sparks, src.location)
				src.total_sparks++
				var/direction
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
				for(i=0, i<pick(1,2,3), i++)
					sleep(5)
					step(sparks,direction)
				spawn(20)
					if(sparks)
						qdel(sparks)
					src.total_sparks--



/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optinally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////


/obj/effect/effect/smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	var/time_to_live = 100

	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/effect/smoke/New()
	..()
	spawn (time_to_live)
		qdel(src)

/obj/effect/effect/smoke/Crossed(mob/living/carbon/M as mob )
	..()
	if(istype(M))
		affect(M)

/obj/effect/effect/smoke/proc/affect(var/mob/living/carbon/M)
	if (istype(M))
		return 0
	if (M.internal != null)
		if(M.wear_mask && (M.wear_mask.item_flags & AIRTIGHT))
			return 0
		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.head && (H.head.item_flags & AIRTIGHT))
				return 0
		return 0
	return 1

/////////////////////////////////////////////
// Illumination
/////////////////////////////////////////////

/obj/effect/effect/smoke/illumination
	name = "illumination"
	opacity = 0
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparks"

/obj/effect/effect/smoke/illumination/New(var/newloc, var/brightness=15, var/lifetime=10)
	time_to_live=lifetime
	..()
	set_light(brightness)

/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/effect/smoke/bad
	time_to_live = 200

/obj/effect/effect/smoke/bad/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		affect(M)

/obj/effect/effect/smoke/bad/affect(var/mob/living/carbon/M)
	if (!..())
		return 0
	M.drop_item()
	M.adjustOxyLoss(1)
	if (M.coughedtime != 1)
		M.coughedtime = 1
		M.emote("cough")
		spawn ( 20 )
			M.coughedtime = 0

/obj/effect/effect/smoke/bad/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = mover
		B.damage = (B.damage/2)
	return 1
/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/effect/smoke/sleepy

/obj/effect/effect/smoke/sleepy/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		affect(M)

/obj/effect/effect/smoke/sleepy/affect(mob/living/carbon/M as mob )
	if (!..())
		return 0

	M.drop_item()
	M:sleeping += 1
	if (M.coughedtime != 1)
		M.coughedtime = 1
		M.emote("cough")
		spawn ( 20 )
			M.coughedtime = 0
/////////////////////////////////////////////
// Mustard Gas
/////////////////////////////////////////////


/obj/effect/effect/smoke/mustard
	name = "mustard gas"
	icon_state = "mustard"

/obj/effect/effect/smoke/mustard/Move()
	..()
	for(var/mob/living/carbon/human/R in get_turf(src))
		affect(R)

/obj/effect/effect/smoke/mustard/affect(var/mob/living/carbon/human/R)
	if (!..())
		return 0
	if (R.wear_suit != null)
		return 0

	R.burn_skin(0.75)
	if (R.coughedtime != 1)
		R.coughedtime = 1
		R.emote("gasp")
		spawn (20)
			R.coughedtime = 0
	R.updatehealth()
	return

/////////////////////////////////////////////
// Smoke spread
/////////////////////////////////////////////

/datum/effect/effect/system/smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction
	var/smoke_type = /obj/effect/effect/smoke

/datum/effect/effect/system/smoke_spread/set_up(n = 5, c = 0, loca, direct)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct

/datum/effect/effect/system/smoke_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/smoke/smoke = PoolOrNew(smoke_type, src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(smoke.time_to_live*0.75+rand(10,30))
				if (smoke) qdel(smoke)
				src.total_smoke--


/datum/effect/effect/system/smoke_spread/bad
	smoke_type = /obj/effect/effect/smoke/bad

/datum/effect/effect/system/smoke_spread/sleepy
	smoke_type = /obj/effect/effect/smoke/sleepy


/datum/effect/effect/system/smoke_spread/mustard
	smoke_type = /obj/effect/effect/smoke/mustard


/////////////////////////////////////////////
//////// Attach an Ion trail to any object, that spawns when it moves (like for the jetpack)
/// just pass in the object to attach it to in set_up
/// Then do start() to start it and stop() to stop it, obviously
/// and don't call start() in a loop that will be repeated otherwise it'll get spammed!
/////////////////////////////////////////////

/obj/effect/effect/ion_trails
	name = "ion trails"
	icon_state = "ion_trails"
	anchored = 1.0

/datum/effect/effect/system/ion_trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

	set_up(atom/atom)
		attach(atom)
		oldposition = get_turf(atom)

	start()
		if(!src.on)
			src.on = 1
			src.processing = 1
		if(src.processing)
			src.processing = 0
			spawn(0)
				var/turf/T = get_turf(src.holder)
				if(T != src.oldposition)
					if(istype(T, /turf/space))
						var/obj/effect/effect/ion_trails/I = PoolOrNew(/obj/effect/effect/ion_trails, src.oldposition)
						src.oldposition = T
						I.set_dir(src.holder.dir)
						flick("ion_fade", I)
						I.icon_state = "blank"
						spawn( 20 )
							qdel(I)
					spawn(2)
						if(src.on)
							src.processing = 1
							src.start()
				else
					spawn(2)
						if(src.on)
							src.processing = 1
							src.start()

	proc/stop()
		src.processing = 0
		src.on = 0




/////////////////////////////////////////////
//////// Attach a steam trail to an object (eg. a reacting beaker) that will follow it
// even if it's carried of thrown.
/////////////////////////////////////////////

/datum/effect/effect/system/steam_trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

	set_up(atom/atom)
		attach(atom)
		oldposition = get_turf(atom)

	start()
		if(!src.on)
			src.on = 1
			src.processing = 1
		if(src.processing)
			src.processing = 0
			spawn(0)
				if(src.number < 3)
					var/obj/effect/effect/steam/I = PoolOrNew(/obj/effect/effect/steam, src.oldposition)
					src.number++
					src.oldposition = get_turf(holder)
					I.set_dir(src.holder.dir)
					spawn(10)
						qdel(I)
						src.number--
					spawn(2)
						if(src.on)
							src.processing = 1
							src.start()
				else
					spawn(2)
						if(src.on)
							src.processing = 1
							src.start()

	proc/stop()
		src.processing = 0
		src.on = 0

/datum/effect/effect/system/reagents_explosion
	var/amount 						// TNT equivalent
	var/flashing = 0			// does explosion creates flash effect?
	var/flashing_factor = 0		// factor of how powerful the flash effect relatively to the explosion

	set_up (amt, loc, flash = 0, flash_fact = 0)
		amount = amt
		if(istype(loc, /turf/))
			location = loc
		else
			location = get_turf(loc)

		flashing = flash
		flashing_factor = flash_fact

		return

	start()
		if (amount <= 2)
			var/datum/effect/effect/system/spark_spread/s = PoolOrNew(/datum/effect/effect/system/spark_spread)
			s.set_up(2, 1, location)
			s.start()

			for(var/mob/M in viewers(5, location))
				M << "<span class='warning'>The solution violently explodes.</span>"
			for(var/mob/M in viewers(1, location))
				if (prob (50 * amount))
					M << "<span class='warning'>The explosion knocks you down.</span>"
					M.Weaken(rand(1,5))
			return
		else
			var/devst = -1
			var/heavy = -1
			var/light = -1
			var/flash = -1

			// Clamp all values to fractions of max_explosion_range, following the same pattern as for tank transfer bombs
			if (round(amount/12) > 0)
				devst = devst + amount/12

			if (round(amount/6) > 0)
				heavy = heavy + amount/6

			if (round(amount/3) > 0)
				light = light + amount/3

			if (flashing && flashing_factor)
				flash = (amount/4) * flashing_factor

			for(var/mob/M in viewers(8, location))
				M << "<span class='warning'>The solution violently explodes.</span>"

			explosion(
				location, 
				round(min(devst, BOMBCAP_DVSTN_RADIUS)), 
				round(min(heavy, BOMBCAP_HEAVY_RADIUS)), 
				round(min(light, BOMBCAP_LIGHT_RADIUS)), 
				round(min(flash, BOMBCAP_FLASH_RADIUS))
				)

	proc/holder_damage(var/atom/holder)
		if(holder)
			var/dmglevel = 4

			if (round(amount/8) > 0)
				dmglevel = 1
			else if (round(amount/4) > 0)
				dmglevel = 2
			else if (round(amount/2) > 0)
				dmglevel = 3

			if(dmglevel<4) holder.ex_act(dmglevel)
