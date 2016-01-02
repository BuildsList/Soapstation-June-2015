/obj/item/device/multitool/hacktool
	var/is_hacking = 0
	var/max_known_targets

	var/in_hack_mode = 0
	var/list/known_targets
	var/list/supported_types
	var/datum/topic_state/default/must_hack/hack_state

/obj/item/device/multitool/hacktool/New()
	..()
	known_targets = list()
	max_known_targets = 5 + rand(1,3)
	supported_types = list(/obj/machinery/door/airlock)
	hack_state = new(src)

/obj/item/device/multitool/hacktool/Destroy()
	for(var/T in known_targets)
		var/atom/target = T
		target.destruction.unregister(src)
	known_targets.Cut()
	qdel(hack_state)
	hack_state = null
	return ..()

/obj/item/device/multitool/hacktool/attackby(var/obj/W, var/mob/user)
	if(isscrewdriver(W))
		in_hack_mode = !in_hack_mode
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
	else
		..()

/obj/item/device/multitool/hacktool/resolve_attackby(atom/A, mob/user)
	sanity_check()

	if(!in_hack_mode)
		return ..()

	if(!attempt_hack(user, A))
		return 0

	A.ui_interact(user, state = hack_state)
	return 1

/obj/item/device/multitool/hacktool/proc/attempt_hack(var/mob/user, var/atom/target)
	if(is_hacking)
		user << "<span class='warning'>You are already hacking!</span>"
		return 0
	if(!is_type_in_list(target, supported_types))
		user << "\icon[src] <span class='warning'>Unable to hack this target!</span>"
		return 0
	var/found = known_targets.Find(target)
	if(found)
		known_targets.Swap(1, found)	// Move the last hacked item first
		return 1

	user << "<span class='notice'>You begin hacking \the [target]...</span>"
	is_hacking = 1
	// On average hackin takes ~30 seconds. Fairly small random span to avoid people simply aborting and trying again
	var/hack_result = do_after(user, (20 SECONDS + rand(0, 10 SECONDS) + rand(0, 10 SECONDS)))
	is_hacking = 0

	if(hack_result && in_hack_mode)
		user << "<span class='notice'>Your hacking attempt was succesful!</span>"
		playsound(src.loc, 'sound/piano/A#6.ogg', 75)
	else
		user << "<span class='warning'>Your hacking attempt failed!</span>"
		return 0

	known_targets.Insert(1, target)	// Insert the newly hacked target first,
	target.destruction.register(src, /obj/item/device/multitool/hacktool/proc/on_target_destroy)
	return 1

/obj/item/device/multitool/hacktool/proc/sanity_check()
	if(max_known_targets < 1) max_known_targets = 1
	// Cut away the oldest items if the capacity has been reached
	if(known_targets.len > max_known_targets)
		for(var/i = (max_known_targets + 1) to known_targets.len)
			var/atom/A = known_targets[i]
			A.destruction.unregister(src)
		known_targets.Cut(max_known_targets + 1)

/obj/item/device/multitool/hacktool/proc/on_target_destroy(var/target)
	known_targets -= target

/datum/topic_state/default/must_hack
	var/obj/item/device/multitool/hacktool/hacktool

/datum/topic_state/default/must_hack/New(var/hacktool)
	src.hacktool = hacktool
	..()

/datum/topic_state/default/must_hack/Destroy()
	hacktool = null
	return ..()

/datum/topic_state/default/must_hack/can_use_topic(var/src_object, var/mob/user)
	if(!hacktool || !hacktool.in_hack_mode || !(src_object in hacktool.known_targets))
		return STATUS_CLOSE
	return ..()
