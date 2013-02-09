/*
#define FIND_PLANT 1
#define FIND_BIO 2
#define FIND_METEORIC 3
#define FIND_ICE 4
#define FIND_CRYSTALLINE 5
#define FIND_METALLIC 6
#define FIND_IGNEOUS 7
#define FIND_METAMORPHIC 8
#define FIND_SEDIMENTARY 9
#define FIND_NOTHING 10
*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Rock sliver

/obj/item/weapon/rocksliver
	name = "rock sliver"
	desc = "It looks extremely delicate."
	icon = 'xenoarchaeology.dmi'
	icon_state = "sliver1"	//0-4
	w_class = 1
	//item_state = "electronic"
	var/source_rock = "/turf/simulated/mineral/"
	var/datum/geosample/geological_data

/obj/item/weapon/rocksliver/New()
	icon_state = "sliver[rand(1,3)]"
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

var/list/responsive_carriers = list( \
	"carbon", \
	"carbon", \
	"neon", \
	"beryllium", \
	"helium", \
	"silicon", \
	"calcium", \
	"chlorine", \
	"aluminium", \
	"plasma" )

var/list/finds_as_strings = list( \
	"Dead plant cells", \
	"Dead organism cells", \
	"Long exposure particles", \
	"Trace water particles", \
	"Crystalline structures", \
	"Metallics", \
	"Metamorphic/generic rock", \
	"Igneous/generic rock", \
	"Sedimentary/generic rock", \
	"Anomalous material" )

var/list/artifact_spawning_turfs = list()

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Geosample datum

/datum/geosample
	var/age = 0								//age can correspond to different archaeological finds
	var/age_thousand = 0
	var/age_million = 0
	var/age_billion = 0
	var/artifact_id = ""					//id of a nearby artifact, if there is one
	var/artifact_distance = -1				//proportional to distance
	var/source_mineral = "calcium"
	var/total_spread = 0
	//
	//var/source_mineral
	//all potential finds are initialised to null, so nullcheck before you access them
	var/list/find_presence = list()

/datum/geosample/New(var/turf/simulated/mineral/container)

	UpdateTurf(container)

//this should only need to be called once
/datum/geosample/proc/UpdateTurf(var/turf/simulated/mineral/container)
	if(!container || !istype(container))
		return

	//source_mineral = container.mineralName
	age = rand(1,999)

	//find_presence[FIND_METEORIC] = rand(1,10) / 10
	//var/comp_remaining = 1 - find_presence[FIND_METEORIC]
	switch(container.mineralName)
		if("Uranium")
			age_million = rand(1, 704)
			age_thousand = rand(1,999)
			//find_presence[FIND_METALLIC] = comp_remaining * (rand(25, 75) / 100)
			//comp_remaining -= find_presence[FIND_METALLIC]
			find_presence["silicon"] = rand(1,1000) / 100
			source_mineral = "silicon"
		if("Iron")
			age_thousand = rand(1, 999)
			age_million = rand(1, 999)
			//find_presence[FIND_METALLIC] = comp_remaining * (rand(25, 75) / 100)
			//comp_remaining -= find_presence[FIND_METALLIC]
			find_presence["silicon"] = rand(1,1000) / 100
			source_mineral = "silicon"
		if("Diamond")
			age_thousand = rand(1,999)
			age_million = rand(1,999)
			//find_presence[FIND_CRYSTALLINE] = comp_remaining * (rand(25, 75) / 100)
			//comp_remaining -= find_presence[FIND_CRYSTALLINE]
			find_presence["helium"] = rand(1,1000) / 100
			source_mineral = "helium"
		if("Gold")
			age_thousand = rand(1,999)
			age_million = rand(1,999)
			age_billion = rand(3,4)
			//find_presence[FIND_METALLIC] = comp_remaining * (rand(25, 75) / 100)
			//comp_remaining -= find_presence[FIND_METALLIC]
			find_presence["silicon"] = rand(1,1000) / 100
			source_mineral = "silicon"
		if("Silver")
			age_thousand = rand(1,999)
			age_million = rand(1,999)
			//find_presence[FIND_METALLIC] = comp_remaining * (rand(25, 75) / 100)
			//comp_remaining -= find_presence[FIND_METALLIC]
			find_presence["silicon"] = rand(1,1000) / 100
			source_mineral = "silicon"
		if("Plasma")
			age_thousand = rand(1,999)
			age_million = rand(1,999)
			age_billion = rand(10, 13)
			//find_presence[FIND_METALLIC] = comp_remaining * (rand(25, 75) / 100)
			//comp_remaining -= find_presence[FIND_METALLIC]
			find_presence["silicon"] = rand(1,1000) / 100
			source_mineral = "silicon"
		if("Clown")
			age = rand(-1,-999)				//thats_the_joke.mp4
			age_thousand = rand(-1,-999)
			find_presence["beryllium"] = rand(1,1000) / 100
			source_mineral = "beryllium"
			//find_presence[FIND_IGNEOUS] = comp_remaining * (rand(25, 75) / 100)
			//comp_remaining -= find_presence[FIND_IGNEOUS]

	find_presence["neon"] = rand(1,500) / 100
	if(prob(20))
		find_presence["carbon"] = rand(1,10) / 100

	//find_presence[FIND_METAMORPHIC] = comp_remaining
	//allocate the rest to ordinary rock
	find_presence["calcium"] = rand(500,2500) / 100

	//loop over finds, grab any relevant stuff
	for(var/datum/find/F in container.finds)
		var/responsive_reagent = get_responsive_reagent(F.find_type)
		find_presence[responsive_reagent] = F.dissonance_spread

	for(var/entry in find_presence)
		total_spread += find_presence[entry]

//have this separate from UpdateTurf() so that we dont have a billion turfs being updated (redundantly) every time an artifact spawns
/datum/geosample/proc/UpdateNearbyArtifactInfo(var/turf/simulated/mineral/container)
	if(!container || !istype(container))
		return

	for(var/turf/simulated/mineral/holder in artifact_spawning_turfs)
		var/dist = get_dist(container, holder)
		if(dist < artifact_distance)
			artifact_distance = dist
			//artifact_id = A.display_id
/*
#undef FIND_PLANT
#undef FIND_BIO
#undef FIND_METEORIC
#undef FIND_ICE
#undef FIND_CRYSTALLINE
#undef FIND_METALLIC
#undef FIND_IGNEOUS
#undef FIND_METAMORPHIC
#undef FIND_SEDIMENTARY
#undef FIND_NOTHING
*/