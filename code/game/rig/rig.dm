obj/machinery/rig_fabricator
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fabricator"
	name = "Rigsuit Fabricator"
	desc = "Nothing is being built."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 5000
	req_access = list(access_robotics)
	var/time_coeff = 1.5 //can be upgraded with research
	var/resource_coeff = 1.5 //can be upgraded with research
	var/list/resources = list(
										"metal"=0,
										"glass"=0,
										"gold"=0,
										"silver"=0,
										"diamond"=0,
										"phoron"=0,
										"uranium"=0, //Note: Look into using metallic hyddrogen, osmium, and other rare resources as resources -RadiantFlash//
										)
	var/res_max_amount = 200000
	var/datum/research/files
	var/id
	var/sync = 0
	var/part_set
	var/obj/being_built
	var/list/queue = list()
	var/processing_queue = 0
	var/screen = "main"
	var/opened = 0
	var/temp
	var/output_dir = EAST	//the direction relative to the fabber at which completed parts appear.
	var/list/part_sets = list( //set names must be unique
		"Basic Rig Suit"=list())