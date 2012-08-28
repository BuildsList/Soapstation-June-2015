#define UPDATE_BUFFER 15

// CAMERA CHUNK
//
// A 16x16 grid of the map with a list of turfs that can be seen, are visible and are dimmed.
// Allows the AI Eye to stream these chunks and know what it can and cannot see.

/datum/camerachunk
	var/list/obscuredTurfs = list()
	var/list/visibleTurfs = list()
	var/list/obscured = list()
	var/list/cameras = list()
	var/list/turfs = list()
	var/list/seenby = list()
	var/visible = 0
	var/changed = 0
	var/updating = 0

// Add an AI eye to the chunk, then update if changed.

/datum/camerachunk/proc/add(mob/aiEye/ai)
	ai.visibleCameraChunks += src
	if(ai.ai.client)
		ai.ai.client.images += obscured
	visible++
	seenby += ai
	if(changed && !updating)
		update()

// Remove an AI eye from the chunk, then update if changed.

/datum/camerachunk/proc/remove(mob/aiEye/ai)
	ai.visibleCameraChunks -= src
	if(ai.ai.client)
		ai.ai.client.images -= obscured
	seenby -= ai
	if(visible > 0)
		visible--

// Called when a chunk has changed. I.E: A wall was deleted.

/datum/camerachunk/proc/visibilityChanged(turf/loc)
	if(!(loc in visibleTurfs))
		return

	hasChanged()

// Updates the chunk, makes sure that it doesn't update too much. If the chunk isn't being watched it will
// instead be flagged to update the next time an AI Eye moves near it.

/datum/camerachunk/proc/hasChanged(var/update_now = 0)
	if(visible || update_now)
		if(!updating)
			updating = 1
			spawn(UPDATE_BUFFER) // Batch large changes, such as many doors opening or closing at once
				update()
				updating = 0
	else
		changed = 1

// The actual updating. It gathers the visible turfs from cameras and puts them into the appropiate lists.

/datum/camerachunk/proc/update()

	var/list/newVisibleTurfs = list()

	for(var/obj/machinery/camera/c in cameras)
		if(!c.can_use())
			continue
		var/turf/pos = get_turf(c)
		if(pos)
			for(var/turf/t in range(7, pos))
				if(t in turfs)
					newVisibleTurfs += t

	var/list/visAdded = newVisibleTurfs - visibleTurfs
	var/list/visRemoved = visibleTurfs - newVisibleTurfs

	visibleTurfs = newVisibleTurfs
	obscuredTurfs = turfs - newVisibleTurfs


	for(var/turf/t in visAdded)
		if(t.obscured)
			obscured -= t.obscured
			for(var/mob/aiEye/m in seenby)
				if(m.ai.client)
					m.ai.client.images -= t.obscured

	for(var/turf/t in visRemoved)
		if(t in obscuredTurfs)
			if(!t.obscured)
				t.obscured = image('icons/effects/cameravis.dmi', t, "black", 15)

			obscured += t.obscured
			for(var/mob/aiEye/m in seenby)
				if(!m)
					seenby -= m
				if(m.ai.client)
					m.ai.client.images += t.obscured

// Create a new camera chunk, since the chunks are made as they are needed.

/datum/camerachunk/New(loc, x, y, z)

	// 0xf = 15
	x &= ~0xf
	y &= ~0xf

	for(var/obj/machinery/camera/c in range(16, locate(x + 8, y + 8, z)))
		if(c.can_use())
			cameras += c

	for(var/turf/t in range(10, locate(x + 8, y + 8, z)))

		if(t.x >= x && t.y >= y && t.x < x + 16 && t.y < y + 16)
			turfs += t

	for(var/obj/machinery/camera/c in cameras)
		if(!c.can_use())
			continue
		var/turf/pos = get_turf(c)
		if(pos)
			for(var/turf/t in range(7, pos))
				if(t in turfs)
					visibleTurfs += t

	obscuredTurfs = turfs - visibleTurfs

	for(var/turf/t in obscuredTurfs)
		if(!t.obscured)
			t.obscured = image('icons/effects/cameravis.dmi', t, "black", 15)
		obscured += t.obscured

#undef UPDATE_BUFFER