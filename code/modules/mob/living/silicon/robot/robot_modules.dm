var/global/list/robot_modules = list(
	"Standard"		= /obj/item/weapon/robot_module/standard,
	"Service" 		= /obj/item/weapon/robot_module/butler,
	"Clerical" 		= /obj/item/weapon/robot_module/clerical,
	"Research" 		= /obj/item/weapon/robot_module/research,
	"Miner" 		= /obj/item/weapon/robot_module/miner,
	"Crisis" 		= /obj/item/weapon/robot_module/crisis,
	"Surgeon" 		= /obj/item/weapon/robot_module/surgeon,
	"Security" 		= /obj/item/weapon/robot_module/security/general,
	"Engineering"	= /obj/item/weapon/robot_module/engineering/general,
	"Construction"	= /obj/item/weapon/robot_module/engineering/construction,
	"Janitor" 		= /obj/item/weapon/robot_module/janitor,
	"Combat" 		= /obj/item/weapon/robot_module/security/combat
	)

/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = 100.0
	item_state = "electronic"
	flags = CONDUCT
	var/channels = list()
	var/networks = list()
	var/languages = list(LANGUAGE_SOL_COMMON = 1, LANGUAGE_TRADEBAND = 1, LANGUAGE_UNATHI = 0, LANGUAGE_SIIK_TAJR = 0, LANGUAGE_SKRELLIAN = 0, LANGUAGE_GUTTER = 0)
	var/sprites = list()
	var/can_be_pushed = 1
	var/no_slip = 0
	var/list/modules = list()
	var/list/datum/matter_synth/synths = list()
	var/obj/item/emag = null
	var/obj/item/borg/upgrade/jetpack = null

	var/list/obj/item/borg/upgrade/supported_upgrades = list()

	// Bookkeeping
	var/list/added_languages = list()
	var/list/added_networks = list()
	var/obj/item/device/radio/borg/modified_radio = null
	var/list/modified_key = null
	var/list/original_radio_channels = list()

/obj/item/weapon/robot_module/New(var/mob/living/silicon/robot/R)
	..()
	add_camera_networks(R)
	add_languages(R)
	add_radio_channels(R)
	apply_status_flags(R)

/obj/item/weapon/robot_module/proc/Reset(var/mob/living/silicon/robot/R)
	..()
	remove_camera_networks(R)
	remove_languages(R)
	remove_radio_channels(R)
	remove_status_flags(R)

/obj/item/weapon/robot_module/emp_act(severity)
	if(modules)
		for(var/obj/O in modules)
			O.emp_act(severity)
	if(emag)
		emag.emp_act(severity)
	if(synths)
		for(var/datum/matter_synth/S in synths)
			S.emp_act(severity)
	..()
	return

/obj/item/weapon/robot_module/proc/respawn_consumable(var/mob/living/silicon/robot/R, var/rate)
	if(!synths || !synths.len)
		return

	for(var/datum/matter_synth/T in synths)
		T.add_charge(T.recharge_rate * rate)

/obj/item/weapon/robot_module/proc/rebuild()//Rebuilds the list so it's possible to add/remove items from the module
	var/list/temp_list = modules
	modules = list()
	for(var/obj/O in temp_list)
		if(O)
			modules += O

/obj/item/weapon/robot_module/proc/add_languages(var/mob/living/silicon/robot/R)
	for(var/language in languages)
		if(R.add_language(language, languages[language]))
			added_languages |= language

/obj/item/weapon/robot_module/proc/remove_languages(var/mob/living/silicon/robot/R)
	for(var/language in added_languages)
		R.remove_language(language)
	added_languages.Cut()

/obj/item/weapon/robot_module/proc/add_camera_networks(var/mob/living/silicon/robot/R)
	if(R.camera && "Robots" in R.camera.network)
		for(var/network in networks)
			if(!(network in R.camera.network))
				R.camera.add_network(network)
				added_networks |= network

/obj/item/weapon/robot_module/proc/remove_camera_networks(var/mob/living/silicon/robot/R)
	if(R.camera)
		R.camera.remove_networks(added_networks)
	added_networks.Cut()

/obj/item/weapon/robot_module/proc/add_radio_channels(var/mob/living/silicon/robot/R)
	if(!R.radio)
		return

	modified_radio = R.radio
	modified_key = R.radio.keyslot
	original_radio_channels = modified_radio.channels.Copy()
	modified_radio.config(channels)

/obj/item/weapon/robot_module/proc/remove_radio_channels(var/mob/living/silicon/robot/R)
	// Only reset if the original radio component hasn't been altered/replaced
	if(!(R.radio && R.radio == modified_radio && R.radio.keyslot == modified_key))
		return

	modified_radio.config(original_radio_channels)
	original_radio_channels.Cut()

/obj/item/weapon/robot_module/proc/apply_status_flags(var/mob/living/silicon/robot/R)
	if(!can_be_pushed)
		R.status_flags &= ~CANPUSH

/obj/item/weapon/robot_module/proc/remove_status_flags(var/mob/living/silicon/robot/R)
	if(!can_be_pushed)
		R.status_flags |= CANPUSH

/obj/item/weapon/robot_module/standard
	name = "standard robot module"
	sprites = list(	"Basic" = "robot_old",
					"Android" = "droid",
					"Default" = "robot",
					"Drone" = "drone-standard"
				  )

/obj/item/weapon/robot_module/standard/New()
	..()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/melee/baton/loaded(src)
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.emag = new /obj/item/weapon/melee/energy/sword(src)
	return

/obj/item/weapon/robot_module/surgeon
	name = "surgeon robot module"
	channels = list("Medical" = 1)
	networks = list(NETWORK_MEDICAL)
	can_be_pushed = 0
	sprites = list(
					"Basic" = "Medbot",
					"Standard" = "surgeon",
					"Advanced Droid" = "droid-medical",
					"Needles" = "medicalrobot",
					"Drone" = "drone-surgery"
					)

/obj/item/weapon/robot_module/surgeon/New()
	..()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.modules += new /obj/item/weapon/reagent_containers/borghypo/surgeon(src)
	src.modules += new /obj/item/weapon/scalpel(src)
	src.modules += new /obj/item/weapon/hemostat(src)
	src.modules += new /obj/item/weapon/retractor(src)
	src.modules += new /obj/item/weapon/cautery(src)
	src.modules += new /obj/item/weapon/bonegel(src)
	src.modules += new /obj/item/weapon/FixOVein(src)
	src.modules += new /obj/item/weapon/bonesetter(src)
	src.modules += new /obj/item/weapon/circular_saw(src)
	src.modules += new /obj/item/weapon/surgicaldrill(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.emag = new /obj/item/weapon/reagent_containers/spray(src)
	src.emag.reagents.add_reagent("pacid", 250)
	src.emag.name = "Polyacid spray"

	var/datum/matter_synth/medicine = new /datum/matter_synth/medicine(10000)
	synths += medicine

	var/obj/item/stack/nanopaste/N = new /obj/item/stack/nanopaste(src)
	var/obj/item/stack/medical/advanced/bruise_pack/B = new /obj/item/stack/medical/advanced/bruise_pack(src)
	N.uses_charge = 1
	N.charge_costs = list(1000)
	N.synths = list(medicine)
	B.uses_charge = 1
	B.charge_costs = list(1000)
	B.synths = list(medicine)
	src.modules += N
	src.modules += B

	return

/obj/item/weapon/robot_module/surgeon/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	if(src.emag)
		var/obj/item/weapon/reagent_containers/spray/PS = src.emag
		PS.reagents.add_reagent("pacid", 2 * amount)
	..()

/obj/item/weapon/robot_module/crisis
	name = "crisis robot module"
	channels = list("Medical" = 1)
	networks = list(NETWORK_MEDICAL)
	can_be_pushed = 0
	sprites = list(
					"Basic" = "Medbot",
					"Standard" = "surgeon",
					"Advanced Droid" = "droid-medical",
					"Needles" = "medicalrobot",
					"Drone - Medical" = "drone-medical",
					"Drone - Chemistry" = "drone-chemistry"
					)

/obj/item/weapon/robot_module/crisis/New()
	..()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/hud/med(src)
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.modules += new /obj/item/device/reagent_scanner/adv(src)
	src.modules += new /obj/item/roller_holder(src)
	src.modules += new /obj/item/weapon/reagent_containers/borghypo/crisis(src)
	src.modules += new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
	src.modules += new /obj/item/weapon/reagent_containers/robodropper(src)
	src.modules += new /obj/item/weapon/reagent_containers/syringe(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.emag = new /obj/item/weapon/reagent_containers/spray(src)
	src.emag.reagents.add_reagent("pacid", 250)
	src.emag.name = "Polyacid spray"

	var/datum/matter_synth/medicine = new /datum/matter_synth/medicine(15000)
	synths += medicine

	var/obj/item/stack/medical/ointment/O = new /obj/item/stack/medical/ointment(src)
	var/obj/item/stack/medical/bruise_pack/B = new /obj/item/stack/medical/bruise_pack(src)
	var/obj/item/stack/medical/splint/S = new /obj/item/stack/medical/splint(src)
	O.uses_charge = 1
	O.charge_costs = list(1000)
	O.synths = list(medicine)
	B.uses_charge = 1
	B.charge_costs = list(1000)
	B.synths = list(medicine)
	S.uses_charge = 1
	S.charge_costs = list(1000)
	S.synths = list(medicine)
	src.modules += O
	src.modules += B
	src.modules += S

	return

/obj/item/weapon/robot_module/crisis/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)

	var/obj/item/weapon/reagent_containers/syringe/S = locate() in src.modules
	if(S.mode == 2)
		S.reagents.clear_reagents()
		S.mode = initial(S.mode)
		S.desc = initial(S.desc)
		S.update_icon()

	if(src.emag)
		var/obj/item/weapon/reagent_containers/spray/PS = src.emag
		PS.reagents.add_reagent("pacid", 2 * amount)

	..()


/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"
	channels = list("Engineering" = 1)
	networks = list(NETWORK_ENGINEERING)
	sprites = list(
					"Basic" = "Engineering",
					"Antique" = "engineerrobot",
					"Landmate" = "landmate",
					"Landmate - Treaded" = "engiborg+tread",
					"Drone" = "drone-engineer"
					)

/obj/item/weapon/robot_module/engineering/construction
	name = "construction robot module"
	no_slip = 1

/obj/item/weapon/robot_module/engineering/construction/New()
	..()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/meson(src)
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/rcd/borg(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/pickaxe/plasmacutter(src)
	src.modules += new /obj/item/device/pipe_painter(src)

	var/datum/matter_synth/metal = new /datum/matter_synth/metal()
	var/datum/matter_synth/plasteel = new /datum/matter_synth/plasteel()
	var/datum/matter_synth/glass = new /datum/matter_synth/glass()
	synths += metal
	synths += plasteel
	synths += glass

	var/obj/item/stack/sheet/metal/cyborg/M = new /obj/item/stack/sheet/metal/cyborg(src)
	M.synths = list(metal)
	src.modules += M

	var/obj/item/stack/rods/cyborg/R = new /obj/item/stack/rods/cyborg(src)
	R.synths = list(metal)
	src.modules += R

	var/obj/item/stack/sheet/plasteel/cyborg/S = new /obj/item/stack/sheet/plasteel/cyborg(src)
	S.synths = list(plasteel)
	src.modules += S

	var/obj/item/stack/sheet/glass/reinforced/cyborg/RG = new /obj/item/stack/sheet/glass/reinforced/cyborg(src)
	RG.synths = list(metal, glass)
	src.modules += RG

/obj/item/weapon/robot_module/engineering/general/New()
	..()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/meson(src)
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/weldingtool/largetank(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/wirecutters(src)
	src.modules += new /obj/item/device/multitool(src)
	src.modules += new /obj/item/device/t_scanner(src)
	src.modules += new /obj/item/device/analyzer(src)
	src.modules += new /obj/item/taperoll/engineering(src)
	src.modules += new /obj/item/weapon/gripper(src)
	src.modules += new /obj/item/device/pipe_painter(src)
	src.emag = new /obj/item/borg/stun(src)

	var/datum/matter_synth/metal = new /datum/matter_synth/metal(40000)
	var/datum/matter_synth/glass = new /datum/matter_synth/glass(40000)
	var/datum/matter_synth/wire = new /datum/matter_synth/wire()
	synths += metal
	synths += glass
	synths += wire

	var/obj/item/weapon/matter_decompiler/MD = new /obj/item/weapon/matter_decompiler(src)
	MD.metal = metal
	MD.glass = glass
	src.modules += MD

	var/obj/item/stack/sheet/metal/cyborg/M = new /obj/item/stack/sheet/metal/cyborg(src)
	M.synths = list(metal)
	src.modules += M

	var/obj/item/stack/sheet/glass/cyborg/G = new /obj/item/stack/sheet/glass/cyborg(src)
	G.synths = list(glass)
	src.modules += G

	var/obj/item/stack/rods/cyborg/R = new /obj/item/stack/rods/cyborg(src)
	R.synths = list(metal)
	src.modules += R

	var/obj/item/stack/cable_coil/cyborg/C = new /obj/item/stack/cable_coil/cyborg(src)
	C.synths = list(wire)
	src.modules += C

	var/obj/item/stack/tile/plasteel/cyborg/S = new /obj/item/stack/tile/plasteel/cyborg(src)
	S.synths = list(metal)
	src.modules += S

	var/obj/item/stack/sheet/glass/reinforced/cyborg/RG = new /obj/item/stack/sheet/glass/reinforced/cyborg(src)
	RG.synths = list(metal, glass)
	src.modules += RG

	return

/obj/item/weapon/robot_module/security
	name = "security robot module"
	channels = list("Security" = 1)
	networks = list(NETWORK_SECURITY)
	can_be_pushed = 0
	supported_upgrades = list(/obj/item/borg/upgrade/tasercooler)

/obj/item/weapon/robot_module/security/general
	sprites = list(
					"Basic" = "secborg",
					"Red Knight" = "Security",
					"Black Knight" = "securityrobot",
					"Bloodhound" = "bloodhound",
					"Bloodhound - Treaded" = "secborg+tread",
					"Drone" = "drone-sec"
				)

/obj/item/weapon/robot_module/security/general/New()
	..()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/hud/sec(src)
	src.modules += new /obj/item/weapon/handcuffs/cyborg(src)
	src.modules += new /obj/item/weapon/melee/baton/robot(src)
	src.modules += new /obj/item/weapon/gun/energy/taser/mounted/cyborg(src)
	src.modules += new /obj/item/taperoll/police(src)
	src.emag = new /obj/item/weapon/gun/energy/laser/mounted(src)
	return

/obj/item/weapon/robot_module/security/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/device/flash/F = locate() in src.modules
	if(F.broken)
		F.broken = 0
		F.times_used = 0
		F.icon_state = "flash"
	else if(F.times_used)
		F.times_used--
	var/obj/item/weapon/gun/energy/taser/mounted/cyborg/T = locate() in src.modules
	if(T.power_supply.charge < T.power_supply.maxcharge)
		T.power_supply.give(T.charge_cost * amount)
		T.update_icon()
	else
		T.charge_tick = 0

/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"
	channels = list("Service" = 1)
	sprites = list(
					"Basic" = "JanBot2",
					"Mopbot"  = "janitorrobot",
					"Mop Gear Rex" = "mopgearrex",
					"Drone" = "drone-janitor"
					)

/obj/item/weapon/robot_module/janitor/New()
	..()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/soap/nanotrasen(src)
	src.modules += new /obj/item/weapon/storage/bag/trash(src)
	src.modules += new /obj/item/weapon/mop(src)
	src.modules += new /obj/item/device/lightreplacer(src)
	src.emag = new /obj/item/weapon/reagent_containers/spray(src)
	src.emag.reagents.add_reagent("lube", 250)
	src.emag.name = "Lube spray"
	return

/obj/item/weapon/robot_module/janitor/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/device/lightreplacer/LR = locate() in src.modules
	LR.Charge(R, amount)
	if(src.emag)
		var/obj/item/weapon/reagent_containers/spray/S = src.emag
		S.reagents.add_reagent("lube", 2 * amount)

/obj/item/weapon/robot_module/butler
	name = "service robot module"
	channels = list("Service" = 1)
	languages = list(
					LANGUAGE_SOL_COMMON	= 1,
					LANGUAGE_UNATHI		= 1,
					LANGUAGE_SIIK_MAAS	= 1,
					LANGUAGE_SIIK_TAJR	= 0,
					LANGUAGE_SKRELLIAN	= 1,
					LANGUAGE_ROOTSPEAK	= 1,
					LANGUAGE_TRADEBAND	= 1,
					LANGUAGE_GUTTER		= 1
					)
	sprites = list(	"Waitress" = "Service",
					"Kent" = "toiletbot",
					"Bro" = "Brobot",
					"Rich" = "maximillion",
					"Default" = "Service2",
					"Drone - Service" = "drone-service",
					"Drone - Hydro" = "drone-hydro"
				  	)

/obj/item/weapon/robot_module/butler/New()
	..()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/gripper/service(src)
	src.modules += new /obj/item/weapon/reagent_containers/glass/bucket(src)
	src.modules += new /obj/item/weapon/minihoe(src)
	src.modules += new /obj/item/weapon/hatchet(src)
	src.modules += new /obj/item/device/analyzer/plant_analyzer(src)
	src.modules += new /obj/item/weapon/storage/bag/plants(src)
	src.modules += new /obj/item/weapon/robot_harvester(src)

	var/obj/item/weapon/rsf/M = new /obj/item/weapon/rsf(src)
	M.stored_matter = 30
	src.modules += M

	src.modules += new /obj/item/weapon/reagent_containers/robodropper(src)

	var/obj/item/weapon/flame/lighter/zippo/L = new /obj/item/weapon/flame/lighter/zippo(src)
	L.lit = 1
	src.modules += L

	src.modules += new /obj/item/weapon/tray/robotray(src)
	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/shaker(src)
	src.emag = new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)

	var/datum/reagents/R = new/datum/reagents(50)
	src.emag.reagents = R
	R.my_atom = src.emag
	R.add_reagent("beer2", 50)
	src.emag.name = "Mickey Finn's Special Brew"
	return

/obj/item/weapon/robot_module/clerical
	name = "clerical robot module"
	channels = list("Service" = 1)
	languages = list(
					LANGUAGE_SOL_COMMON = 1,
					LANGUAGE_UNATHI = 1,
					LANGUAGE_SIIK_MAAS = 1,
					LANGUAGE_SIIK_TAJR = 0,
					LANGUAGE_SKRELLIAN = 1,
					LANGUAGE_ROOTSPEAK = 1,
					LANGUAGE_TRADEBAND = 1,
					LANGUAGE_GUTTER = 1
					)
	sprites = list(
					"Waitress" = "Service",
					"Kent" = "toiletbot",
					"Bro" = "Brobot",
					"Rich" = "maximillion",
					"Default" = "Service2",
					"Drone" = "drone-service"
					)

/obj/item/weapon/robot_module/clerical/New()
	..()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/pen/robopen(src)
	src.modules += new /obj/item/weapon/form_printer(src)
	src.modules += new /obj/item/weapon/gripper/paperwork(src)
	src.modules += new /obj/item/weapon/hand_labeler(src)
	src.emag = new /obj/item/weapon/stamp/denied(src)

/obj/item/weapon/robot_module/butler/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/weapon/reagent_containers/food/condiment/enzyme/E = locate() in src.modules
	E.reagents.add_reagent("enzyme", 2 * amount)
	if(src.emag)
		var/obj/item/weapon/reagent_containers/food/drinks/cans/beer/B = src.emag
		B.reagents.add_reagent("beer2", 2 * amount)

/obj/item/weapon/robot_module/miner
	name = "miner robot module"
	channels = list("Supply" = 1)
	networks = list(NETWORK_MINE)
	sprites = list(
					"Basic" = "Miner_old",
					"Advanced Droid" = "droid-miner",
					"Treadhead" = "Miner",
					"Drone" = "drone-miner"
				)
	supported_upgrades = list(/obj/item/borg/upgrade/jetpack)

/obj/item/weapon/robot_module/miner/New()
	..()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/meson(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/storage/bag/ore(src)
	src.modules += new /obj/item/weapon/pickaxe/borgdrill(src)
	src.modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
	src.modules += new /obj/item/weapon/gripper/miner(src)
	src.modules += new /obj/item/weapon/mining_scanner(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.emag = new /obj/item/weapon/pickaxe/plasmacutter(src)
	return

/obj/item/weapon/robot_module/research
	name = "research module"
	channels = list("Science" = 1)
	sprites = list(
					"Droid" = "droid-science",
					"Drone" = "drone-science"
					)

/obj/item/weapon/robot_module/research/New()
	..()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/portable_destructive_analyzer(src)
	src.modules += new /obj/item/weapon/gripper/research(src)
	src.modules += new /obj/item/weapon/gripper/no_use/loader(src)
	src.modules += new /obj/item/device/robotanalyzer(src)
	src.modules += new /obj/item/weapon/card/robot(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/scalpel(src)
	src.modules += new /obj/item/weapon/circular_saw(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/weapon/reagent_containers/syringe(src)
	src.modules += new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
	src.emag = new /obj/item/weapon/hand_tele(src)

	var/datum/matter_synth/nanite = new /datum/matter_synth/nanite(10000)
	synths += nanite

	var/obj/item/stack/nanopaste/N = new /obj/item/stack/nanopaste(src)
	N.uses_charge = 1
	N.charge_costs = list(1000)
	N.synths = list(nanite)
	src.modules += N

	return

/obj/item/weapon/robot_module/syndicate
	name = "illegal robot module"
	languages = list(
					LANGUAGE_SOL_COMMON = 1,
					LANGUAGE_TRADEBAND = 1,
					LANGUAGE_UNATHI = 0,
					LANGUAGE_SIIK_TAJR = 0,
					LANGUAGE_SKRELLIAN = 0,
					LANGUAGE_GUTTER = 1
					)

/obj/item/weapon/robot_module/syndicate/New(var/mob/living/silicon/robot/R)
	..()
	loc = R
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/melee/energy/sword(src)
	src.modules += new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(src)
	src.modules += new /obj/item/weapon/card/emag(src)
	var/jetpack = new/obj/item/weapon/tank/jetpack/carbondioxide(src)
	src.modules += jetpack
	R.internals = jetpack
	return

/obj/item/weapon/robot_module/security/combat
	name = "combat robot module"
	sprites = list("Combat Android" = "droid-combat")

/obj/item/weapon/robot_module/combat/New()
	..()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/thermal(src)
	src.modules += new /obj/item/weapon/gun/energy/laser/mounted(src)
	src.modules += new /obj/item/weapon/pickaxe/plasmacutter(src)
	src.modules += new /obj/item/borg/combat/shield(src)
	src.modules += new /obj/item/borg/combat/mobility(src)
	src.emag = new /obj/item/weapon/gun/energy/lasercannon/mounted(src)
	return

/obj/item/weapon/robot_module/drone
	name = "drone module"
	no_slip = 1

/obj/item/weapon/robot_module/drone/New()
	..()
	src.modules += new /obj/item/weapon/weldingtool(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/wirecutters(src)
	src.modules += new /obj/item/device/multitool(src)
	src.modules += new /obj/item/device/lightreplacer(src)
	src.modules += new /obj/item/weapon/gripper(src)
	src.modules += new /obj/item/weapon/soap(src)
	src.emag = new /obj/item/weapon/pickaxe/plasmacutter(src)
	src.emag.name = "Plasma Cutter"

	var/datum/matter_synth/metal = new /datum/matter_synth/metal(25000)
	var/datum/matter_synth/glass = new /datum/matter_synth/glass(25000)
	var/datum/matter_synth/wood = new /datum/matter_synth/wood(2000)
	var/datum/matter_synth/plastic = new /datum/matter_synth/plastic(1000)
	var/datum/matter_synth/wire = new /datum/matter_synth/wire(30)
	synths += metal
	synths += glass
	synths += wood
	synths += plastic
	synths += wire

	var/obj/item/weapon/matter_decompiler/MD = new /obj/item/weapon/matter_decompiler(src)
	MD.metal = metal
	MD.glass = glass
	MD.wood = wood
	MD.plastic = plastic
	src.modules += MD

	var/obj/item/stack/sheet/metal/cyborg/M = new /obj/item/stack/sheet/metal/cyborg(src)
	M.synths = list(metal)
	src.modules += M

	var/obj/item/stack/sheet/glass/cyborg/G = new /obj/item/stack/sheet/glass/cyborg(src)
	G.synths = list(glass)
	src.modules += G

	var/obj/item/stack/rods/cyborg/R = new /obj/item/stack/rods/cyborg(src)
	R.synths = list(metal)
	src.modules += R

	var/obj/item/stack/cable_coil/cyborg/C = new /obj/item/stack/cable_coil/cyborg(src)
	C.synths = list(wire)
	src.modules += C

	var/obj/item/stack/tile/plasteel/cyborg/S = new /obj/item/stack/tile/plasteel/cyborg(src)
	S.synths = list(metal)
	src.modules += S

	var/obj/item/stack/sheet/glass/reinforced/cyborg/RG = new /obj/item/stack/sheet/glass/reinforced/cyborg(src)
	RG.synths = list(metal, glass)
	src.modules += RG

	var/obj/item/stack/tile/wood/cyborg/WT = new /obj/item/stack/tile/wood/cyborg(src)
	WT.synths = list(wood)
	src.modules += WT

	var/obj/item/stack/sheet/wood/cyborg/W = new /obj/item/stack/sheet/wood/cyborg(src)
	W.synths = list(wood)
	src.modules += W

	var/obj/item/stack/sheet/mineral/plastic/cyborg/P = new /obj/item/stack/sheet/mineral/plastic/cyborg(src)
	P.synths = list(plastic)
	src.modules += P

/obj/item/weapon/robot_module/drone/construction
	name = "construction drone module"
	channels = list("Engineering" = 1)
	languages = list()

/obj/item/weapon/robot_module/drone/construction/New()
	..()
	src.modules += new /obj/item/weapon/rcd/borg(src)

/obj/item/weapon/robot_module/drone/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/device/lightreplacer/LR = locate() in src.modules
	LR.Charge(R, amount)
	..()
	return

//checks whether this item is a module of the robot it is located in.
/obj/item/proc/is_robot_module()
	if (!istype(src.loc, /mob/living/silicon/robot))
		return 0
	var/mob/living/silicon/robot/R = src.loc
	return (src in R.module.modules)
