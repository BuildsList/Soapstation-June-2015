/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	check_armour = "energy"


//releases a burst of light on impact or after travelling a distance
/obj/item/projectile/energy/flash
	name = "chemical shell"
	icon_state = "bullet"
	damage = 5
	agony = 10
	kill_count = 15 //if the shell hasn't hit anything after travelling this far it just explodes.
	var/flash_range = 0
	var/brightness = 7
	var/light_duration = 5

/obj/item/projectile/energy/flash/on_impact(var/atom/A)
	var/turf/T = flash_range? src.loc : get_turf(A)
	if(!istype(T)) return

	//blind adjacent people
	for (var/mob/living/carbon/M in viewers(T, flash_range))
		if(M.eyecheck() < FLASH_PROTECTION_MODERATE)
			flick("e_flash", M.flash)

	//snap pop
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	src.visible_message("<span class='warning'>\The [src] explodes in a bright flash!</span>")

	new /obj/effect/decal/cleanable/ash(src.loc) //always use src.loc so that ash doesn't end up inside windows
	new /obj/effect/sparks(T)
	new /obj/effect/effect/smoke/illumination(T, brightness=max(flash_range*2, brightness), lifetime=light_duration)

//blinds people like the flash round, but can also be used for temporary illumination
/obj/item/projectile/energy/flash/flare
	damage = 10
	flash_range = 1
	brightness = 9 //similar to a flare
	light_duration = 200

/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	nodamage = 1
	taser_effect = 1
	agony = 40
	damage_type = HALLOSS
	//Damage will be handled on the MOB side, to prevent window shattering.

/obj/item/projectile/energy/electrode/stunshot
	name = "stunshot"
	damage = 5
	taser_effect = 1
	agony = 80

/obj/item/projectile/energy/declone
	name = "declone"
	icon_state = "declone"
	nodamage = 1
	damage_type = CLONE
	irradiate = 40


/obj/item/projectile/energy/dart
	name = "dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	weaken = 5


/obj/item/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 10
	damage_type = TOX
	nodamage = 0
	agony = 40
	stutter = 10


/obj/item/projectile/energy/bolt/large
	name = "largebolt"
	damage = 20


/obj/item/projectile/energy/neurotoxin
	name = "neuro"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX
	weaken = 5

/obj/item/projectile/energy/phoron
	name = "phoron bolt"
	icon_state = "energy"
	damage = 20
	damage_type = TOX
	irradiate = 20

//Gauss beam for gaussguns -RadiantFlash//
/obj/item/projectile/energy/gauss
	name = "gauss bolt"
	icon_state = "gauss"
	damage = 20
	stun = 0
	weaken = 1
	stutter = 4
	damage_type = BURN
	pass_flags = PASSTABLE | PASSGRILLE
	check_armour = "laser"

/obj/item/projectile/energy/gaussweak.
	name = "gauss bolt"
	icon_state = "gauss"
	damage = 15
	stun = 0
	weaken = 5
	stutter = 4
	damage_type = BURN
	pass_flags = PASSTABLE | PASSGRILLE
	check_armour = "laser"

/obj/item/projectile/energy/gaussrifle
	name = "gauss bolt"
	icon_state = "gauss"
	damage = 40
	stun = 2
	weaken = 2
	stutter = 6
	damage_type = BURN
	pass_flags = PASSTABLE | PASSGRILLE
	penetrating = 0
	check_armour = "laser"
//End of gaussguns//

//Stun projectile for HOSgun
/obj/item/projectile/energy/electrode/hosstunshot //used for HoS gun
	name = "Stun Electrode"
	icon = 'icons/obj/soapstation_projectiles.dmi'
	icon_state = "s-spark"
	damage = 35
	taser_effect = 1
	agony = 65
	damage_type = HALLOSS
	stutter = 10

/obj/item/projectile/energy/Plasma
	name = "Plasma Blast"
	icon_state = "plasmablast"
	damage = 25
	damage_type = BURN
	pass_flags = PASSGRILLE
	check_armour = "laser"