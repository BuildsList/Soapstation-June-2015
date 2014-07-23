/var/xgm_gas_data/gas_data

/xgm_gas_data
	//Simple list of all the gas IDs.
	var/list/gases = list()
	//The friendly, human-readable name for the gas.
	var/list/name = list()
	//Specific heat of the gas.  Used for calculating heat capacity.
	var/list/specific_heat = list()
	//Tile overlays.  /images, created from references to 'icons/effects/tile_effects.dmi'
	var/list/tile_overlay = list()
	//Overlay limits.  There must be at least this many moles for the overlay to appear.
	var/list/overlay_limit = list()
	//Flags.
	var/list/flags = list()

/xgm_gas
	var/id = ""
	var/name = "Unnamed Gas"
	var/specific_heat = 20

	var/tile_overlay = null
	var/overlay_limit = null

	var/flags = 0

/hook/startup/proc/generateGasData()
	gas_data = new
	for(var/p in (typesof(/xgm_gas) - /xgm_gas))
		var/xgm_gas/gas = new p

		if(gas.id in gas_data.gases)
			error("Duplicate gas id `[gas.id]` in `[p]`")

		gas_data.gases += gas.id
		gas_data.name[gas.id] = gas.name
		gas_data.specific_heat[gas.id] = gas.specific_heat
		if(gas.tile_overlay) gas_data.tile_overlay[gas.id] = image('icons/effects/tile_effects.dmi', gas.tile_overlay, FLY_LAYER)
		if(gas.overlay_limit) gas_data.overlay_limit[gas.id] = gas.overlay_limit
		gas_data.flags[gas.id] = gas.flags

	return 1
