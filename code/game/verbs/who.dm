
/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "<b>Current Players:</b>\n"

	var/list/Lines = list()

	if(holder && (R_ADMIN & holder.rights || R_MOD & holder.rights))
		for(var/client/C in clients)
			var/entry = "\t[C.key]"
			if(C.holder && C.holder.fakekey)
				entry += " <i>(as [C.holder.fakekey])</i>"
			entry += " - Playing as [C.mob.real_name]"
			switch(C.mob.stat)
				if(UNCONSCIOUS)
					entry += " - <font color='darkgray'><b>Unconscious</b></font>"
				if(DEAD)
					if(isobserver(C.mob))
						var/mob/dead/observer/O = C.mob
						if(O.started_as_observer)
							entry += " - <font color='gray'>Observing</font>"
						else
							entry += " - <font color='black'><b>DEAD</b></font>"
					else
						entry += " - <font color='black'><b>DEAD</b></font>"
			if(is_special_character(C.mob))
				entry += " - <b><font color='red'>Antagonist</font></b>"
			entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"
			Lines += entry
	else
		for(var/client/C in clients)
			if(C.holder && C.holder.fakekey)
				Lines += C.holder.fakekey
			else
				Lines += C.key

	for(var/line in sortList(Lines))
		msg += "[line]\n"

	msg += "<b>Total Players: [length(Lines)]</b>"
	src << msg

/client/verb/staffwho()
	set category = "Admin"
	set name = "Staffwho"

	var/msg = ""
	var/modmsg = ""
	var/mentmsg = ""
	var/num_mods_online = 0
	var/num_admins_online = 0
	var/num_mentors_online = 0
	if(holder)
		for(var/client/C in admins)
			if(R_ADMIN & C.holder.rights || (!R_MOD & C.holder.rights && !R_MENTOR & C.holder.rights))	//Used to determine who shows up in admin rows

				if(C.holder.fakekey && (!R_ADMIN & holder.rights && !R_MOD & holder.rights))		//Mentors can't see stealthmins
					continue

				msg += "\t[C] is a [C.holder.rank]"

				if(C.holder.fakekey)
					msg += " <i>(as [C.holder.fakekey])</i>"

				if(isobserver(C.mob))
					msg += " - Observing"
				else if(istype(C.mob,/mob/new_player))
					msg += " - Lobby"
				else
					msg += " - Playing"

				if(C.is_afk())
					msg += " (AFK)"
				msg += "\n"

				num_admins_online++
			else if(R_MOD & C.holder.rights)				//Who shows up in mod/mentor rows.
				modmsg += "\t[C] is a [C.holder.rank]"

				if(isobserver(C.mob))
					modmsg += " - Observing"
				else if(istype(C.mob,/mob/new_player))
					modmsg += " - Lobby"
				else
					modmsg += " - Playing"

				if(C.is_afk())
					modmsg += " (AFK)"
				modmsg += "\n"
				num_mods_online++

			else if(R_MENTOR & C.holder.rights)
				mentmsg += "\t[C] is a [C.holder.rank]"
				if(isobserver(C.mob))
					mentmsg += " - Observing"
				else if(istype(C.mob,/mob/new_player))
					mentmsg += " - Lobby"
				else
					mentmsg += " - Playing"

				if(C.is_afk())
					mentmsg += " (AFK)"
				mentmsg += "\n"
				num_mentors_online++

	else
		for(var/client/C in admins)
			if(R_ADMIN & C.holder.rights || (!R_MOD & C.holder.rights && !R_MENTOR & C.holder.rights))
				if(!C.holder.fakekey)
					msg += "\t[C] is a [C.holder.rank]\n"
					num_admins_online++
			else if (R_MOD & C.holder.rights)
				modmsg += "\t[C] is a [C.holder.rank]\n"
				num_mods_online++
			else if (R_MENTOR & C.holder.rights)
				mentmsg += "\t[C] is a [C.holder.rank]\n"
				num_mentors_online++

	if(config.admin_irc)
		src << "<span class='info'>Adminhelps are also sent to IRC. If no admins are available in game try anyway and an admin on IRC may see it and respond.</span>"
	msg = "<b>Current Admins ([num_admins_online]):</b>\n" + msg

	if(config.show_mods)
		msg += "\n<b> Current Moderators ([num_mods_online]):</b>\n" + modmsg

	if(config.show_mentors)
		msg += "\n<b> Current Mentors ([num_mentors_online]):</b>\n" + mentmsg

	src << msg
