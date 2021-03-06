/obj/item/weapon/gun/energy/gun
	name = "energy gun"
	desc = "Another bestseller of Lawson Arms and the FTU, the LAEP90 Perun is a versatile energy based sidearm, capable of switching between low and high capacity projectile settings. In other words: Stun or Kill."
	icon_state = "energystun100"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/Taser.ogg'
	max_shots = 10

	projectile_type = /obj/item/projectile/beam/stun
	origin_tech = list(TECH_COMBAT = 3, TECH_MAGNET = 2)
	modifystate = "energystun"

	firemodes = list(
		list(mode_name="stun", projectile_type=/obj/item/projectile/beam/stun, modifystate="energystun", fire_sound='sound/weapons/Taser.ogg'),
		list(mode_name="lethal", projectile_type=/obj/item/projectile/beam, modifystate="energykill", fire_sound='sound/weapons/Laser.ogg'),
		)

/obj/item/weapon/gun/energy/gun/mounted
	name = "mounted energy gun"
	self_recharge = 1
	use_external_power = 1

/obj/item/weapon/gun/energy/hosgun
	name = "\improper X-01 MultiPhase Energy Gun"
	desc = "This is a expensive, modern recreation of a antique laser gun. This gun has several unique firemodes, but lacks the ability to recharge over time."
	icon = 'icons/obj/soapstation_weapons.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/soapstation_lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/items/soapstation_righthand_guns.dmi',
		)
	icon_state = "hosstun100"
	item_state = "hosstun100 "	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/taser3.ogg'
	max_shots = 10
	charge_meter = 1
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 6, TECH_POWER = 4)
	modifystate = "hosstun"
	force = 8 //looks heavier than a pistol'
	firemodes = list(
		list(mode_name="stun", projectile_type=/obj/item/projectile/energy/electrode/hosstunshot, modifystate="hosstun", fire_sound='sound/weapons/taser3.ogg'),
		list(mode_name="lethal", projectile_type=/obj/item/projectile/beam, modifystate="hoslaser", fire_sound='sound/weapons/Laser.ogg'),
		list(mode_name="hypoxia", projectile_type=/obj/item/projectile/beam/omni, modifystate="hosother", fire_sound='sound/weapons/taser2.ogg'),
				)

/obj/item/weapon/gun/energy/gun/nuclear
	name = "advanced energy gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	icon_state = "nucgun"
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 5, TECH_POWER = 3)
	slot_flags = SLOT_BELT
	force = 8 //looks heavier than a pistol
	self_recharge = 1
	modifystate = null

	firemodes = list(
		list(mode_name="stun", projectile_type=/obj/item/projectile/beam/stun, fire_sound='sound/weapons/Taser.ogg'),
		list(mode_name="lethal", projectile_type=/obj/item/projectile/beam, fire_sound='sound/weapons/Laser.ogg'),
		)

	var/lightfail = 0

//override for failcheck behaviour
/obj/item/weapon/gun/energy/gun/nuclear/process()
	charge_tick++
	if(charge_tick < 4) return 0
	charge_tick = 0
	if(!power_supply) return 0
	if((power_supply.charge / power_supply.maxcharge) != 1)
		power_supply.give(charge_cost)
		update_icon()
	return 1

/obj/item/weapon/gun/energy/gun/nuclear/proc/update_charge()
	var/ratio = power_supply.charge / power_supply.maxcharge
	ratio = round(ratio, 0.25) * 100
	overlays += "nucgun-[ratio]"

/obj/item/weapon/gun/energy/gun/nuclear/proc/update_reactor()
	if(lightfail)
		overlays += "nucgun-medium"
	else if ((power_supply.charge/power_supply.maxcharge) <= 0.5)
		overlays += "nucgun-light"
	else
		overlays += "nucgun-clean"

/obj/item/weapon/gun/energy/gun/nuclear/proc/update_mode()
	var/datum/firemode/current_mode = firemodes[sel_mode]
	switch(current_mode.name)
		if("stun") overlays += "nucgun-stun"
		if("lethal") overlays += "nucgun-kill"

/obj/item/weapon/gun/energy/gun/nuclear/update_icon()
	overlays.Cut()
	update_charge()
	update_reactor()
	update_mode()


