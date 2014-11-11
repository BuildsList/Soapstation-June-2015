/datum/event_meta
	var/name = ""
	var/weight = 1
	var/min_weight = 1
	var/max_weight = 1
	var/severity = 0
	var/has_fired = 0
	var/list/role_weights = list()
	var/datum/event/event_type

/datum/event_meta/New(var/event_severity, var/event_name, var/datum/event/type, var/event_weight, var/list/job_weights, var/min_event_weight, var/max_event_weight)
	name = event_name
	severity = event_severity
	event_type = type
	weight = event_weight
	if(job_weights)
		role_weights = job_weights

/datum/event_meta/proc/get_weight(var/list/active_with_role)
	var/job_weight = 0
	for(var/role in role_weights)
		job_weight = active_with_role[role] * role_weights[role]

	var/total_weight = weight + job_weight

	// Only min/max the weight if the values are set
	if(min_weight && total_weight < min_weight) total_weight = min_weight
	if(max_weight && total_weight > max_weight) total_weight = max_weight

	return total_weight

/datum/event_meta/alien/get_weight(var/list/active_with_role)
	if(aliens_allowed)
		return ..(active_with_role)
	return 0

/datum/event_meta/ninja/get_weight(var/list/active_with_role)
	if(toggle_space_ninja)
		return ..(active_with_role)
	return 0

/datum/event	//NOTE: Times are measured in master controller ticks!
	var/name			= ""//Name of the event
	var/startWhen		= 0	//When in the lifetime to call start().
	var/announceWhen	= 0	//When in the lifetime to call announce().
	var/endWhen			= 0	//When in the lifetime the event should end.
	var/oneShot			= 0	//If true, then the event removes itself from the list of potential events on creation.

	var/severity		= 0 //Severity. Lower means less severe, higher means more severe. Does not have to be supported. Is set on New().
	var/activeFor		= 0	//How long the event has existed. You don't need to change this.
	var/isRunning		= 1 //If this event is currently running. You should not change this.
	var/datum/event_meta/event_meta = null

/datum/event/nothing
	name = "Nothing"

//Called first before processing.
//Allows you to setup your event, such as randomly
//setting the startWhen and or announceWhen variables.
//Only called once.
/datum/event/proc/setup()
	return

//Called when the tick is equal to the startWhen variable.
//Allows you to start before announcing or vice versa.
//Only called once.
/datum/event/proc/start()
	return

//Called when the tick is equal to the announceWhen variable.
//Allows you to announce before starting or vice versa.
//Only called once.
/datum/event/proc/announce()
	return

//Called on or after the tick counter is equal to startWhen.
//You can include code related to your event or add your own
//time stamped events.
//Called more than once.
/datum/event/proc/tick()
	return

//Called on or after the tick is equal or more than endWhen
//You can include code related to the event ending.
//Do not place spawn() in here, instead use tick() to check for
//the activeFor variable.
//For example: if(activeFor == myOwnVariable + 30) doStuff()
//Only called once.
/datum/event/proc/end()
	return


//Do not override this proc, instead use the appropiate procs.
//This proc will handle the calls to the appropiate procs.
/datum/event/proc/process()
	if(activeFor > startWhen && activeFor < endWhen)
		tick()

	if(activeFor == startWhen)
		isRunning = 1
		start()

	if(activeFor == announceWhen)
		announce()

	if(activeFor == endWhen)
		isRunning = 0
		end()

	// Everything is done, let's clean up.
	if(activeFor >= endWhen && activeFor >= announceWhen && activeFor >= startWhen)
		kill()

	activeFor++

//Called when start(), announce() and end() has all been called.
/datum/event/proc/kill()
	// If this event was forcefully killed run end() for individual cleanup
	if(isRunning)
		isRunning = 0
		end()

	event_manager.active_events -= src
	event_manager.event_complete(src)

/datum/event/New(var/datum/event_meta/EM)
	// event needs to be responsible for this, as stuff like APLUs currently make their own events for curious reasons
	event_manager.active_events += src

	event_meta = EM
	severity = event_meta.severity
	if(severity < EVENT_LEVEL_MUNDANE) severity = EVENT_LEVEL_MUNDANE
	if(severity > EVENT_LEVEL_MAJOR) severity = EVENT_LEVEL_MAJOR

	setup()
	..()
