/datum/expansion/multitool
	var/window_x = 370
	var/window_y = 470
	var/list/interact_predicates

/datum/expansion/multitool/New(var/atom/holder, var/list/can_interact_predicates)
	..()
	interact_predicates = can_interact_predicates ? can_interact_predicates : list()

/datum/expansion/multitool/Destroy()
	interact_predicates.Cut()
	return ..()

/datum/expansion/multitool/proc/interact(var/obj/item/device/multitool/M, var/mob/user)
	if(CanUseTopic(user) != STATUS_INTERACTIVE)
		return

	var/html = get_interact_window(M, user)
	if(html)
		var/datum/browser/popup = new(usr, "multitool", holder.name, window_x, window_y)
		popup.set_content(html)
		popup.set_title_image(user.browse_rsc_icon(holder.icon, holder.icon_state))
		popup.open()
	else
		close_window(usr)

/datum/expansion/multitool/proc/get_interact_window(var/obj/item/device/multitool/M, var/mob/user)
	return

/datum/expansion/multitool/proc/close_window(var/mob/user)
	user << browse(null, "window=multitool")

/datum/expansion/multitool/proc/buffer(var/obj/item/device/multitool/multitool)
	. += "<b>Buffer Memory:</b><br>"
	if(multitool.buffer_name)
		. += "[multitool.buffer_name] <a href='?src=\ref[src];send=\ref[multitool.buffer_object]'>Send</a> <a href='?src=\ref[src];purge=1'>Purge</a><br>"
	else
		. += "No connection stored in the buffer."

/datum/expansion/multitool/CanUseTopic(var/mob/user)
	. = ..()
	if(. == STATUS_CLOSE)
		return

	if(!user.get_multitool())
		return STATUS_CLOSE

	if(!all_predicates_true(list(holder, user), interact_predicates))
		return STATUS_CLOSE

	var/datum/host = holder.nano_host()
	return user.default_can_use_topic(host)

/datum/expansion/multitool/Topic(href, href_list)
	if(..())
		close_window(usr)
		return 1

	var/mob/user = usr
	var/obj/item/device/multitool/M = user.get_multitool()
	if(href_list["send"])
		var/atom/buffer = locate(href_list["send"])
		. = send_buffer(M, buffer, user)
	else if(href_list["purge"])
		M.set_buffer(null)
		. = MT_REFRESH
	else
		. = OnTopic(href, href_list, user)

	switch(.)
		if(MT_REFRESH)
			interact(M, user)
		if(MT_CLOSE)
			close_window(user)
	return 1

/datum/expansion/multitool/proc/OnTopic(href, href_list, usr)
	return MT_NOACTION

/datum/expansion/multitool/proc/send_buffer(var/obj/item/device/multitool/M, var/atom/buffer, var/mob/user)
	if(M.get_buffer() == buffer)
		receive_buffer(M, buffer, user)
	return MT_REFRESH

/datum/expansion/multitool/proc/receive_buffer(var/obj/item/device/multitool/M, var/atom/buffer, var/mob/user)
	return
