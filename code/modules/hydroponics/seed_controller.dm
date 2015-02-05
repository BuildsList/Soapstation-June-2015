//Attempts to offload processing for the spreading plants from the MC.
// Processes vines/spreading plants.

#define PLANTS_PER_TICK 5
#define PLANT_TICK_TIME 5

// Debug for testing seed genes.
/client/proc/show_plant_genes()
	set category = "Debug"
	set name = "Show Plant Genes"
	set desc = "Prints the round's plant gene masks."

	if(!holder)	return

	if(!plant_controller.gene_tag_masks)
		usr << "Gene masks not set."
		return

	for(var/mask in plant_controller.gene_tag_masks)
		usr << "[mask]: [plant_controller.gene_tag_masks[mask]]"

var/global/datum/controller/plants/plant_controller // Set in New().

/datum/controller/plants
	var/list/plants = list()                // All currently processing plants.
	var/list/seeds = list()                 // All seed data stored here.
	var/list/gene_tag_masks = list()        // Gene obfuscation for delicious trial and error goodness.
	var/list/plant_icon_cache = list()      // Stores images of growth, fruits and seeds.
	var/list/plant_sprites = list()         // List of all harvested product sprites.
	var/list/plant_product_sprites = list() // List of all growth sprites plus number of growth stages.
	var/processing = 0

/datum/controller/plants/New()
	if(plant_controller && plant_controller != src)
		log_debug("Rebuilding plant controller.")
		del(plant_controller)
	plant_controller = src
	setup()
	process()

// Predefined/roundstart varieties use a string key to make it
// easier to grab the new variety when mutating. Post-roundstart
// and mutant varieties use their uid converted to a string instead.
// Looks like shit but it's sort of necessary.
/datum/controller/plants/proc/setup()

	// Build the icon lists.
	for(var/icostate in icon_states('icons/obj/hydroponics_growing.dmi'))
		var/split = findtext(icostate,"-")
		if(!split)
			// invalid icon_state
			continue

		var/ikey = copytext(icostate,(split+1))
		if(ikey == "dead")
			// don't count dead icons
			continue
		ikey = text2num(ikey)
		var/base = copytext(icostate,1,split)

		if(!(plant_sprites[base]) || (plant_sprites[base]<ikey))
			plant_sprites[base] = ikey

	for(var/icostate in icon_states('icons/obj/hydroponics_products.dmi'))
		plant_product_sprites |= icostate

	// Populate the global seed datum list.
	for(var/type in typesof(/datum/seed)-/datum/seed)
		var/datum/seed/S = new type
		seeds[S.name] = S
		S.uid = "[seeds.len]"
		S.roundstart = 1

	// Make sure any seed packets that were mapped in are updated
	// correctly (since the seed datums did not exist a tick ago).
	for(var/obj/item/seeds/S in world)
		S.update_seed()

	//Might as well mask the gene types while we're at it.
	var/list/used_masks = list()
	var/list/plant_traits = ALL_GENES
	while(plant_traits && plant_traits.len)
		var/gene_tag = pick(plant_traits)
		var/gene_mask = "[num2hex(rand(0,255))]"

		while(gene_mask in used_masks)
			gene_mask = "[num2hex(rand(0,255))]"

		used_masks += gene_mask
		plant_traits -= gene_tag
		gene_tag_masks[gene_tag] = gene_mask

// Proc for creating a random seed type.
/datum/controller/plants/proc/create_random_seed(var/survive_on_station)
	var/datum/seed/seed = new()
	seed.randomize()
	seed.uid = plant_controller.seeds.len + 1
	seed.name = "[seed.uid]"
	seeds[seed.name] = seed

	if(survive_on_station)
		if(seed.consume_gasses)
			seed.consume_gasses["phoron"] = null
			seed.consume_gasses["carbon_dioxide"] = null
		seed.set_trait(TRAIT_IDEAL_HEAT,293)
		seed.set_trait(TRAIT_HEAT_TOLERANCE,20)
		seed.set_trait(TRAIT_IDEAL_LIGHT,8)
		seed.set_trait(TRAIT_LIGHT_TOLERANCE,5)
		seed.set_trait(TRAIT_LOWKPA_TOLERANCE,25)
		seed.set_trait(TRAIT_HIGHKPA_TOLERANCE,200)
	return seed

/datum/controller/plants/proc/process()
	processing = 1
	spawn(0)
		set background = 1
		while(1)
			if(!processing)
				sleep(PLANT_TICK_TIME)
			else
				for(var/x=0;x<PLANTS_PER_TICK;x++)
					if(!plants.len)
						break
					sleep(-1)
					var/obj/effect/plant/plant = pick(plants)
					plants -= plant
					plant.process()

/datum/controller/plants/proc/add_plant(var/obj/effect/plant/plant)
	plants |= plant