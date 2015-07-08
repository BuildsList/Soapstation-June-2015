/obj/machinery/beehive
	name = "beehive"
	icon = 'icons/obj/beekeeping.dmi'
	icon_state = "beehive"
	density = 1
	anchored = 1

	var/closed = 0
	var/bee_count = 0 // Percent
	var/smoked = 0 // Timer
	var/honeycombs = 0 // Percent
	var/frames = 0
	var/maxFrames = 5

/obj/machinery/beehive/update_icon()
	overlays.Cut()
	icon_state = "beehive"
	if(closed)
		overlays += "lid"
	if(frames)
		overlays += "empty[frames]"
	if(honeycombs >= 100)
		overlays += "full[round(honeycombs / 100)]"
	if(!smoked)
		switch(bee_count)
			if(1 to 40)
				overlays += "bees1"
			if(41 to 80)
				overlays += "bees2"
			if(81 to 100)
				overlays += "bees3"

/obj/machinery/beehive/examine(var/mob/user)
	..()
	if(!closed)
		user << "The lid is open."

/obj/machinery/beehive/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/weapon/crowbar))
		closed = !closed
		user.visible_message("<span class='notice'>[user] [closed ? "closes" : "opens"] \the [src].</span>", "<span class='notice'>You [closed ? "close" : "open"] \the [src].</span>")
		update_icon()
		return
	else if(istype(I, /obj/item/weapon/wrench))
		anchored = !anchored
		user.visible_message("<span class='notice'>[user] [anchored ? "wrenches" : "unwrenches"] \the [src].</span>", "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
		return
	else if(istype(I, /obj/item/bee_smoker))
		if(closed)
			user << "<span class='notice'>You need to open \the [src] with a crowbar before smoking the bees.</span>"
			return
		user.visible_message("<span class='notice'>[user] smokes the bees in \the [src].</span>", "<span class='notice'>You smoke the bees in \the [src].</span>")
		smoked = 30
		update_icon()
		return
	else if(istype(I, /obj/item/honey_frame))
		if(closed)
			user << "<span class='notice'>You need to open \the [src] with a crowbar before inserting \the [I].</span>"
			return
		if(frames >= maxFrames)
			user << "<span class='notice'>There is no place for an another frame.</span>"
			return
		var/obj/item/honey_frame/H = I
		if(H.honey)
			user << "<span class='notice'>\The [I] is full with beeswax and honey, empty it in the extractor first.</span>"
			return
		++frames
		user.visible_message("<span class='notice'>[user] loads \the [I] into \the [src].</span>", "<span class='notice'>You load \the [I] into \the [src].</span>")
		update_icon()
		user.drop_from_inventory(I)
		qdel(I)
		return
	else if(istype(I, /obj/item/bee_pack))
		var/obj/item/bee_pack/B = I
		if(B.full && bee_count)
			user << "<span class='notice'>\The [src] already has bees inside.</span>"
			return
		if(!B.full && bee_count < 90)
			user << "<span class='notice'>\The [src] is not ready to split.</span>"
			return
		if(!B.full && !smoked)
			user << "<span class='notice'>Smoke \the [src] first!</span>"
			return
		if(closed)
			user << "<span class='notice'>You need to open \the [src] with a crowbar before moving the bees.</span>"
			return
		if(B.full)
			user.visible_message("<span class='notice'>[user] puts the queen and the bees from \the [I] into \the [src].</span>", "<span class='notice'>You put the queen and the bees from \the [I] into \the [src].</span>")
			bee_count = 20
			B.empty()
		else
			user.visible_message("<span class='notice'>[user] puts bees and larvae from \the [src] into \the [I].</span>", "<span class='notice'>You put puts bees and larvae from \the [src] into \the [I].</span>")
			bee_count /= 2
			B.fill()
		update_icon()
		return
	else if(istype(I, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='notice'>Scan result of \the [src]...</span>"
		user << "Beehive is [bee_count ? "[round(bee_count)]% full" : "empty"].[bee_count > 90 ? " Colony is ready to split." : ""]"
		if(frames)
			user << "[frames] frames installed, [round(honeycombs / 100)] filled."
			if(honeycombs < frames * 100)
				user << "Next frame is [round(honeycombs % 100)]% full."
		else
			user << "No frames installed."
		if(smoked)
			user << "The hive is smoked."
		return 1

/obj/machinery/beehive/attack_hand(var/mob/user)
	if(!closed)
		if(honeycombs < 100)
			user << "<span class='notice'>There are no filled honeycombs.</span>"
			return
		if(!smoked && bee_count)
			user << "<span class='notice'>The bees won't let you take the honeycombs out like this, smoke them first.</span>"
			return
		user.visible_message("<span class='notice'>[user] starts taking the honeycombs out of \the [src].", "<span class='notice'>You start taking the honeycombs out of \the [src]...</span>")
		while(honeycombs >= 100 && do_after(user, 30))
			new /obj/item/honey_frame/filled(loc)
			honeycombs -= 100
			--frames
			update_icon()
		if(honeycombs < 100)
			user << "<span class='notice'>You take all filled honeycombs out.</span>"
		return

/obj/machinery/beehive/process()
	if(closed && !smoked && bee_count)
		pollinate_flowers()
		update_icon()
	smoked = max(0, smoked - 1)
	if(!smoked && bee_count)
		bee_count = min(bee_count * 1.005, 100)
		update_icon()

/obj/machinery/beehive/proc/pollinate_flowers()
	var/coef = bee_count / 100
	var/trays = 0
	for(var/obj/machinery/portable_atmospherics/hydroponics/H in view(7, src))
		if(H.seed && !H.dead)
			H.health += 0.05 * coef
			++trays
	honeycombs = min(honeycombs + 0.1 * coef * min(trays, 5), frames * 100)

/obj/machinery/honey_extractor
	name = "honey extractor"
	desc = "A machine used to turn honeycombs on the frame into honey and wax."
	icon = 'icons/obj/virology.dmi'
	icon_state = "centrifuge"

	var/processing = 0
	var/honey = 0

/obj/machinery/honey_extractor/attackby(var/obj/item/I, var/mob/user)
	if(processing)
		user << "<span class='notice'>\The [src] is currently spinning, wait until it's finished.</span>"
		return
	else if(istype(I, /obj/item/honey_frame))
		var/obj/item/honey_frame/H = I
		if(!H.honey)
			user << "<span class='notice'>\The [H] is empty, put it into a beehive.</span>"
			return
		user.visible_message("<span class='notice'>[user] loads \the [H] into \the [src] and turns it on.</span>", "<span class='notice'>You load \the [H] into \the [src] and turn it on.</span>")
		processing = H.honey
		icon_state = "centrifuge_moving"
		qdel(H)
		spawn(50)
			new /obj/item/honey_frame(loc)
			new /obj/item/stack/wax(loc)
			honey += processing
			processing = 0
			icon_state = "centrifuge"
	else if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(!honey)
			user << "<span class='notice'>There is no honey in \the [src].</span>"
			return
		var/obj/item/weapon/reagent_containers/glass/G = I
		var/transferred = min(G.reagents.maximum_volume - G.reagents.total_volume, honey)
		G.reagents.add_reagent("honey", transferred)
		honey -= transferred
		user.visible_message("<span class='notice'>[user] collects honey from \the [src] into \the [G].</span>", "<span class='notice'>You collect [transferred] units of honey from \the [src] into \the [G].</span>")
		return 1

/obj/item/bee_smoker
	name = "bee smoker"
	desc = "A device used to calm down bees before harvesting honey."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "apiary"
	w_class = 2

/obj/item/honey_frame
	name = "beehive frame"
	desc = "A frame for the beehive that the bees will fill with honeycombs."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "apiary"
	w_class = 2

	var/honey = 0

/obj/item/honey_frame/filled
	name = "filled beehive frame"
	desc = "A frame for the beehive that the bees have filled with honeycombs."
	honey = 20

/obj/item/beehive_assembly
	name = "beehive assembly"
	desc = "Contains everything you need to build a beehive. Cannot be disassembled once deployed."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "apiary"

/obj/item/beehive_assembly/attack_self(var/mob/user)
	user.visible_message("<span class='notice'>[user] constructs a beehive.</span>", "<span class='notice'>You construct a beehive.</span>")
	new /obj/machinery/beehive(get_turf(user))
	user.drop_from_inventory(src)
	qdel(src)

/obj/item/stack/wax
	name = "wax"
	singular_name = "wax piece"
	desc = "Soft substance produced by bees. Used to make candles."
	icon_state = "sheet-metal"

/obj/item/stack/wax/New()
	..()
	recipes = wax_recipes

var/global/list/datum/stack_recipe/wax_recipes = list( \
	new/datum/stack_recipe("candle", /obj/item/weapon/flame/candle) \
)

/obj/item/bee_pack
	name = "bee pack"
	desc = "Contains a queen bee and some worker bees. Everything you'll need to start a hive!"
	icon = 'icons/obj/beekeeping.dmi'
	icon_state = "beepack"
	var/full = 1

/obj/item/bee_pack/New()
	..()
	overlays += "beepack-full"

/obj/item/bee_pack/proc/empty()
	full = 0
	name = "empty bee pack"
	desc = "A stasis pack for moving bees. It's empty."
	overlays.Cut()
	overlays += "beepack-empty"

/obj/item/bee_pack/proc/fill()
	full = initial(full)
	name = initial(name)
	desc = initial(desc)
	overlays.Cut()
	overlays += "beepack-full"