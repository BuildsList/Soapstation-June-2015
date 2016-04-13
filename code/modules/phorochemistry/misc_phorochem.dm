#define REM 0.2
#define SOLID 1
#define LIQUID 2
#define GAS 3

proc/gaseous_reagent_check(var/mob/living/carbon/human/H) //protective clothing check
	return (istype(H.wear_suit, /obj/item/clothing/suit/space) && istype(H.head, /obj/item/clothing/head/helmet/space)) \
		|| (istype(H.wear_suit, /obj/item/clothing/suit/bio_suit) && istype(H.head, /obj/item/clothing/head/bio_hood) && H.gloves) \
		|| (H.species.flags & IS_SYNTHETIC)

/datum/reagent/acid/phoronic_acid
	name = "Phoronic acid"
	id = "phoronic_acid"
	description = "Violently corrosive substance, large volumes could potentially breach hull"
	color = "#CDEB0C"
	power = 12
	meltdose = 5

	reaction_turf(var/turf/T, var/volume) //can't melt space, centcomm walls, or shuttles
											//maybe make work off explosion resistance?
		if(!istype(T, /turf/space) && !istype(T, /turf/unsimulated/wall) && !istype(T.loc, /area/shuttle) \
						 && !istype(T.loc, /area/supply/station)) //TODO: Deal with bluespace tiles
			src = null //ensure sleep proc doesn't return upon completion
			if(volume <= 10)
				return
			for(var/mob/M in viewers(7, T))
				M << "\green You hear sizzling as the solution begins to eat away the [T.name]."
			sleep(30)
			if(volume >= 50)
				for(var/mob/M in viewers(7, T))
					M << "\green The acid melts through the [T.name]!"

				if(istype(T, /turf/simulated/wall))
					for(var/obj/O in T.contents) //Shamelessly stolen from walls.dm
						if(istype(O,/obj/structure/sign/poster))
							var/obj/structure/sign/poster/P = O
							P.roll_and_drop(T)
						else
							O.loc = T
					T.ChangeTurf(/turf/simulated/floor/plating)
				else
					T.ChangeTurf(/turf/space)
				//del(src)
			else
				for(var/mob/M in viewers(7, T))
					M << "\green The sizzling stops leaving the floor intact."
		return

	reaction_obj(var/obj/O, var/volume)
		if(istype(O, /obj/machinery) || istype(O, /obj/structure))
			src = null //ensure sleep proc doesn't return upon completion
			if(volume <= 10)
				return
			for(var/mob/M in viewers(7, O))
				M << "\green You hear sizzling as the solution begins to eat away the [O.name]."
			sleep(30)
			if(volume >= 50)
				for(var/mob/M in viewers(7, O))
					M << "\green The acid melts through the [O.name]!"
				del(O)
			else
				for(var/mob/M in viewers(7, O))
					M << "\green The sizzling stops leaving the floor intact."
		else
			return ..()

/datum/reagent/nitrate
	id = "nitrate"
	name = "Nitrate"
	description = "Nitrate, not that interesting."
	reagent_state = LIQUID
	color = "#D8DFE3"

/datum/reagent/aluminum_nitrate
	id = "aluminum_nitrate"
	name = "Aluminum Nitrate"
	description = "Aluminum Nitrate, now that's interesting!"
	reagent_state = LIQUID
	color = "#E1CFE3"

/datum/chemical_reaction/nitrate
	name = "Nitrate"
	id = "nitrate"
	result = "nitrate"
	required_reagents = list("nitrogen" = 1, "oxygen" = 3)
	result_amount = 4

/datum/chemical_reaction/aluminum_nitrate
	name = "Aluminum Nitrate"
	id = "aluminum_nitrate"
	result = "aluminum_nitrate"
	required_reagents = list("aluminum" = 1, "nitrate" = 3)
	result_amount = 4

/datum/chemical_reaction/brownies
	name = "Brownies"
	id = "brownies"
	result = null
	required_reagents = list("aluminum_nitrate" = 40, "tartrate" = 20)
	result_amount = 1
	on_reaction(var/datum/reagents/holder, var/created_volume)
		for(var/i = 0; i < 3; i++)
			new /obj/item/weapon/reagent_containers/food/snacks/brownies(get_turf(holder.my_atom))
		return

/obj/item/weapon/reagent_containers/food/snacks/brownies
	name = "Brownies"
	icon_state = "waffles"
	desc = "Ovenless Brownies!"
	filling_color = "#A79459"

	New()
		..()
		reagents.add_reagent("nutriment", 6)

/obj/item/weapon/induromol
	name = "Hardened Induromol"
	icon = 'icons/obj/mining.dmi'
	icon_state = "Platinum ore"
	desc = "Looks like it would make a great throwing weapon."
	throwforce = 40