#define DRYING_TIME 5 * 60*10                        //for 1 unit of depth in puddle (amount var)

var/global/list/image/splatter_cache=list()

/obj/effect/decal/cleanable/blood
        name = "blood"
        desc = "It's thick and gooey. Perhaps it's the chef's cooking?"
        gender = PLURAL
        density = 0
        anchored = 1
        layer = 2
        icon_state = "floor1"
        random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")
        var/list/viruses = list()
        blood_DNA = list()
        var/basecolor="#A10808" // Color when wet.
        var/list/datum/disease2/disease/virus2 = list()
        var/amount = 5

/obj/effect/decal/cleanable/blood/Del()
        for(var/datum/disease/D in viruses)
                D.cure(0)
        ..()

/obj/effect/decal/cleanable/blood/New()
        ..()
        if(istype(src, /obj/effect/decal/cleanable/blood/gibs))
                return
        if(istype(src, /obj/effect/decal/cleanable/blood/tracks))
                return // We handle our own drying.
        if(src.type == /obj/effect/decal/cleanable/blood)
                if(src.loc && isturf(src.loc))
                        for(var/obj/effect/decal/cleanable/blood/B in src.loc)
                                if(B != src)
                                        if (B.blood_DNA)
                                                blood_DNA |= B.blood_DNA.Copy()
                                        del(B)
        spawn(DRYING_TIME * (amount+1))
                dry()

/obj/effect/decal/cleanable/blood/update_icon()

	var/cache_key="[basecolor]|[icon_state]"
	var/icon/I=null
	if(cache_key in splatter_cache)
		I = splatter_cache[cache_key]
	else
		I = new /icon('icons/effects/blood.dmi', icon_state=icon_state)
		I.SwapColor("#000000",basecolor);
		splatter_cache[cache_key]=I
	icon = I

/obj/effect/decal/cleanable/blood/HasEntered(mob/living/carbon/human/perp)
        if (!istype(perp))
                return
        if(amount < 1)
                return

        if(perp.shoes)
                perp.shoes:track_blood = max(amount,perp.shoes:track_blood)                //Adding blood to shoes
                if(!perp.shoes.blood_overlay)
                        perp.shoes.generate_blood_overlay()
                if(!perp.shoes.blood_DNA)
                        perp.shoes.blood_DNA = list()
                        perp.shoes.overlays += perp.shoes.blood_overlay
                        perp.update_inv_shoes(1)
                perp.shoes.blood_DNA |= blood_DNA.Copy()
                perp.shoes.blood_color=basecolor
        else
                perp.track_blood = max(amount,perp.track_blood)                                //Or feet
                if(!perp.feet_blood_DNA)
                        perp.feet_blood_DNA = list()
                perp.feet_blood_DNA |= blood_DNA.Copy()
                perp.feet_blood_color=basecolor

        amount--

/obj/effect/decal/cleanable/blood/proc/dry()
        name = "dried [src]"
        desc = "It's dark red and crusty. Someone is not doing their job."
        var/icon/I = icon(icon,icon_state)
        I.SetIntensity(0.7)
        icon = I
        amount = 0

/obj/effect/decal/cleanable/blood/splatter
        random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")
        amount = 2

/obj/effect/decal/cleanable/blood/drip
        name = "drips of blood"
        desc = "It's red."
        gender = PLURAL
        icon = 'icons/effects/drip.dmi'
        icon_state = "1"
        amount = 0

/obj/effect/decal/cleanable/blood/gibs
        name = "gibs"
        desc = "They look bloody and gruesome."
        gender = PLURAL
        density = 0
        anchored = 1
        layer = 2
        icon = 'icons/effects/blood.dmi'
        icon_state = "gibbl5"
        random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")

/obj/effect/decal/cleanable/blood/gibs/up
        random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
        random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
        random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/limb
        random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
        random_icon_states = list("gibmid1", "gibmid2", "gibmid3")


/obj/effect/decal/cleanable/blood/gibs/proc/streak(var/list/directions)
        spawn (0)
                var/direction = pick(directions)
                for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
                        sleep(3)
                        if (i > 0)
                                var/obj/effect/decal/cleanable/blood/b = new /obj/effect/decal/cleanable/blood/splatter(src.loc)
                                b.basecolor = src.basecolor
                                for(var/datum/disease/D in src.viruses)
                                        var/datum/disease/ND = D.Copy(1)
                                        b.viruses += ND
                                        ND.holder = b

                        if (step_to(src, get_step(src, direction), 0))
                                break


/obj/effect/decal/cleanable/mucus
        name = "mucus"
        desc = "Disgusting mucus."
        gender = PLURAL
        density = 0
        anchored = 1
        layer = 2
        icon = 'icons/effects/blood.dmi'
        icon_state = "mucus"
        random_icon_states = list("mucus")
        var/list/datum/disease2/disease/virus2 = list()
        var/dry=0 // Keeps the lag down

/obj/effect/decal/cleanable/mucus/New()
        spawn(DRYING_TIME * 2)
                dry=1