#define ORE_COUNT 1000
/*
	This module is used to generate the debris fields/distribution maps/procedural stations.
*/

var/global/list/random_maps = list()

/datum/random_map
	var/descriptor = "asteroid"      // Display name.
	var/real_size = 246             // Size of each edge (must be square :().
	var/cell_range = 2              // Random range for initial cells.
	var/iterations = 5              // Number of times to apply the automata rule.
	var/max_attempts = 5            // Fail if a sane map isn't generated by this point.
	var/raw_map_size                // Used for creating new maps each iteration. Value must be real_size^2
	var/list/map = list()           // Actual map.
	var/origin_x = 1                // Origin point, left.
	var/origin_y = 1                // Origin point, bottom.
	var/origin_z = 1                // Target Z-level.
	var/limit_x = 256               // Maximum x bound.
	var/limit_y = 256               // Maximum y bound.
	var/iterate_before_fail = 120   // Infinite loop safeguard.

/datum/random_map/proc/get_map_cell(var/x,var/y)
	return ((y-1)*real_size)+x

/datum/random_map/proc/display_map(atom/user)

	if(!user)
		user = world

	for(var/x = 1, x <= real_size, x++)
		var/line = ""
		for(var/y = 1, y <= real_size, y++)
			var/current_cell = get_map_cell(x,y)
			if(within_bounds(current_cell))
				if(map[current_cell] == 2)
					line += "#"
				else
					line += "."
		user << line

/datum/random_map/New(var/seed, var/tx, var/ty, var/tz, var/tlx, var/tly)

	// Store this for debugging.
	random_maps |= src

	// Initialize map.
	set_map_size()

	// Get origins for applying the map later.
	if(tx)  origin_x = tx
	if(ty)  origin_y = ty
	if(tz)  origin_z = tz
	if(tlx) limit_x = tlx
	if(tly) limit_y = tly

	// testing needed to see how reliable this is (asynchronous calls, called during worldgen), DM ref is not optimistic
	if(seed) rand_seed(seed)

	var/start_time = world.timeofday
	world << "<span class='danger'>Generating [descriptor].</span>"
	for(var/i = 0;i<max_attempts;i++)
		if(generate())
			world << "<span class='danger'>[capitalize(descriptor)] generation completed in [round(0.1*(world.timeofday-start_time),0.1)] seconds.</span>"
			return
	world << "<span class='danger'>[capitalize(descriptor)] generation failed in [round(0.1*(world.timeofday-start_time),0.1)] seconds: could not produce sane map.</span>"

/datum/random_map/proc/within_bounds(var/val)
	return (val>0) && (val<=raw_map_size)

/datum/random_map/proc/set_map_size(var/raw_size)
	if(!raw_size)
		raw_size = real_size * real_size
	raw_map_size = raw_size
	map.len = raw_map_size

/datum/random_map/proc/seed_map()
	for(var/x = 1, x <= real_size, x++)
		for(var/y = 1, y <= real_size, y++)
			var/current_cell = get_map_cell(x,y)
			if(prob(55))
				map[current_cell] = 2
			else
				map[current_cell] = 1

/datum/random_map/proc/clear_map()
	for(var/x = 1, x <= real_size, x++)
		for(var/y = 1, y <= real_size, y++)
			map[get_map_cell(x,y)] = 0

/datum/random_map/proc/generate()
	seed_map()
	for(var/i=1;i<=iterations;i++)
		iterate(i)
	if(check_map_sanity())
		cleanup()
		apply_to_map()
		return 1
	return 0

/datum/random_map/proc/iterate(var/iteration)
	var/list/next_map[raw_map_size]
	for(var/x = 1, x <= real_size, x++)
		for(var/y = 1, y <= real_size, y++)
			var/current_cell = get_map_cell(x,y)
			// Sanity check.
			if(!within_bounds(current_cell))
				continue
			// Copy over original value.
			next_map[current_cell] = map[current_cell]
			// Check all neighbors.
			var/count = 0
			for(var/cell in list(current_cell,get_map_cell(x+1,y+1),get_map_cell(x-1,y-1),get_map_cell(x+1,y-1),get_map_cell(x-1,y+1),get_map_cell(x-1,y),get_map_cell(x,y-1),get_map_cell(x+1,y),get_map_cell(x,y+1)))
				if(within_bounds(cell) && map[cell] == 2)
					count++
			if(count>=5)
				next_map[current_cell] = 2 // becomes a wall
			else
				next_map[current_cell] = 1 // becomes a floor
	map = next_map

/datum/random_map/proc/check_map_sanity()
	return 1

/datum/random_map/proc/apply_to_map()
	for(var/x = 0, x < real_size, x++)
		if((origin_x + x) > limit_x) continue
		for(var/y = 0, y < real_size, y++)
			if((origin_y + y) > limit_y) continue
			sleep(-1)
			apply_to_turf(origin_x+x,origin_y+y)

/datum/random_map/proc/apply_to_turf(var/x,var/y)
	var/current_cell = get_map_cell(x,y)
	if(!within_bounds(current_cell))
		return
	var/turf/T = locate(x,y,origin_z)
	if(!T || !istype(T,/turf/unsimulated/mask))
		return
	switch(map[current_cell])
		if(1)
			T.ChangeTurf(/turf/simulated/floor/plating/airless/asteroid)
		if(2)
			T.ChangeTurf(/turf/simulated/mineral)
		if(3)
			T.ChangeTurf(/turf/simulated/mineral/random)
		if(4)
			T.ChangeTurf(/turf/simulated/mineral/random/high_chance)

/datum/random_map/proc/cleanup()

	sleep(-1)
	// Create ore.
	var/ore_count = ORE_COUNT
	while(ore_count)
		var/check_cell = get_map_cell(rand(1,real_size),rand(1,real_size))
		if(!(within_bounds(check_cell)) || map[check_cell] != 2)
			continue
		if(prob(25))
			map[check_cell] = 4
		else
			map[check_cell] = 3
		ore_count--

	sleep(-1)

	// Place random asteroid rooms.
	var/rooms_placed = 0
	for(var/i = 0, i < max_secret_rooms, i++)
		if(make_mining_asteroid_secret())
			rooms_placed++
	world << "<span class='danger'>Placed [rooms_placed] secrets.</span>"
	return 1