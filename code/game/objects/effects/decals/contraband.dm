
//########################## CONTRABAND ;3333333333333333333 -Agouri ###################################################

/obj/item/weapon/contraband
	name = "contraband item"
	desc = "You probably shouldn't be holding this."
	icon = 'icons/obj/contraband.dmi'
	force = 0


/obj/item/weapon/contraband/poster
	name = "rolled-up poster"
	desc = "The poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface."
	icon_state = "rolled_poster"
	var/serial_number = 0


/obj/item/weapon/contraband/poster/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, poster_designs.len)
	else
		serial_number = given_serial
	name += " - No. [serial_number]"
	..(loc)

//Places the poster on a wall
/obj/item/weapon/contraband/poster/afterattack(var/atom/A, var/mob/user, var/adjacent, var/clickparams)
	if (!adjacent)
		return

	//must place on a wall and user must not be inside a closet/mecha/whatever
	var/turf/W = A
	if (!iswall(W) || !isturf(user.loc))
		user << "\red You can't place this here!"
		return
	
	var/placement_dir = get_dir(user, W)
	if (!(placement_dir in cardinal))
		user << "<span class='warning'>You must stand directly in front of the wall you wish to place that on.</span>"
		return

	//just check if there is a poster on or adjacent to the wall
	var/stuff_on_wall = 0
	if (locate(/obj/structure/sign/poster) in W)
		stuff_on_wall = 1
	
	//crude, but will cover most cases. We could do stuff like check pixel_x/y but it's not really worth it.
	for (var/dir in cardinal)
		var/turf/T = get_step(W, dir)
		if (locate(/obj/structure/sign/poster) in T)
			stuff_on_wall = 1
			break

	if (stuff_on_wall)
		user << "<span class='notice'>There is already a poster there!</span>"
		return

	user << "<span class='notice'>You start placing the poster on the wall...</span>" //Looks like it's uncluttered enough. Place the poster.

	var/obj/structure/sign/poster/P = new(user.loc, placement_dir=get_dir(user, W), serial=serial_number)

	flick("poster_being_set", P)
	//playsound(W, 'sound/items/poster_being_created.ogg', 100, 1) //why the hell does placing a poster make printer sounds?
	
	var/oldsrc = src //get a reference to src so we can delete it after detaching ourselves
	src = null
	spawn(17)
		if(!P) return

		if(iswall(W) && user && P.loc == user.loc) //Let's check if everything is still there
			user << "<span class='notice'>You place the poster!</span>"
		else
			P.roll_and_drop(P.loc)
	
	del(oldsrc)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway

//I'm 
/obj/structure/sign/poster/proc/placement_check()

//############################## THE ACTUAL DECALS ###########################

/obj/structure/sign/poster
	name = "poster"
	desc = "A large piece of space-resistant printed paper. "
	icon = 'icons/obj/contraband.dmi'
	anchored = 1
	var/serial_number	//Will hold the value of src.loc if nobody initialises it
	var/poster_type		//So mappers can specify a desired poster
	var/ruined = 0

/obj/structure/sign/poster/New(var/newloc, var/placement_dir=null, var/serial=null)
	..(newloc)

	if(!serial)
		serial = rand(1, poster_designs.len) //use a random serial if none is given
	
	serial_number = serial
	var/datum/poster/design = poster_designs[serial_number]
	set_poster(design)
	
	switch (placement_dir)
		if (NORTH)
			pixel_x = 0
			pixel_y = 32
		if (SOUTH)
			pixel_x = 0
			pixel_y = -32
		if (EAST)
			pixel_x = 32
			pixel_y = 0
		if (WEST)
			pixel_x = -32
			pixel_y = 0

/obj/structure/sign/poster/initialize()
	if (poster_type)
		var/path = text2path(poster_type)
		var/datum/poster/design = new path
		set_poster(design)

/obj/structure/sign/poster/proc/set_poster(var/datum/poster/design)
	name = "[initial(name)] - [design.name]"
	desc = "[initial(desc)] [design.desc]"
	icon_state = design.icon_state // poster[serial_number]

/obj/structure/sign/poster/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wirecutters))
		playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
		if(ruined)
			user << "<span class='notice'>You remove the remnants of the poster.</span>"
			del(src)
		else
			user << "<span class='notice'>You carefully remove the poster from the wall.</span>"
			roll_and_drop(user.loc)
		return


/obj/structure/sign/poster/attack_hand(mob/user as mob)
	if(ruined)
		return
	var/temp_loc = user.loc
	switch(alert("Do I want to rip the poster from the wall?","You think...","Yes","No"))
		if("Yes")
			if(user.loc != temp_loc)
				return
			visible_message("<span class='warning'>[user] rips [src] in a single, decisive motion!</span>" )
			playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)
			ruined = 1
			icon_state = "poster_ripped"
			name = "ripped poster"
			desc = "You can't make out anything from the poster's original print. It's ruined."
			add_fingerprint(user)
		if("No")
			return

/obj/structure/sign/poster/proc/roll_and_drop(turf/newloc)
	var/obj/item/weapon/contraband/poster/P = new(src, serial_number)
	P.loc = newloc
	src.loc = P
	del(src)


//separated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/simulated/wall/proc/place_poster(var/obj/item/weapon/contraband/poster/P, var/mob/user)

	if(!istype(src,/turf/simulated/wall))
		user << "\red You can't place this here!"
		return

	var/stuff_on_wall = 0
	for(var/obj/O in contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(O,/obj/structure/sign/poster))
			user << "<span class='notice'>The wall is far too cluttered to place a poster!</span>"
			return
		stuff_on_wall++
		if(stuff_on_wall == 3)
			user << "<span class='notice'>The wall is far too cluttered to place a poster!</span>"
			return

	user << "<span class='notice'>You start placing the poster on the wall...</span>" //Looks like it's uncluttered enough. Place the poster.

	//declaring D because otherwise if P gets 'deconstructed' we lose our reference to P.resulting_poster
	var/obj/structure/sign/poster/D = new(P.serial_number)

	var/temp_loc = user.loc
	flick("poster_being_set",D)
	D.loc = src
	del(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 100, 1)

	sleep(17)
	if(!D)	return

	if(istype(src,/turf/simulated/wall) && user && user.loc == temp_loc)//Let's check if everything is still there
		user << "<span class='notice'>You place the poster!</span>"
	else
		D.roll_and_drop(temp_loc)
	return

/datum/poster
	// Name suffix. Poster - [name]
	var/name=""
	// Description suffix
	var/desc=""
	var/icon_state=""