	////////////
	//SECURITY//
	////////////
#define TOPIC_SPAM_DELAY	2		//2 ticks is about 2/10ths of a second; it was 4 ticks, but that caused too many clicks to be lost due to lag
#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?
#define MIN_CLIENT_VERSION	0		//Just an ambiguously low version for now, I don't want to suddenly stop people playing.
									//I would just like the code ready should it ever need to be used.
	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn
	*/
/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

	//Reduces spamming of links by dropping calls that happen during the delay period
	if(next_allowed_topic_time > world.time)
		return
	next_allowed_topic_time = world.time + TOPIC_SPAM_DELAY

	//search the href for script injection
	if( findtext(href,"<script",1,0) )
		world.log << "Attempted use of scripts within a topic call, by [src]"
		message_admins("Attempted use of scripts within a topic call, by [src]")
		//del(usr)
		return

	//Admin PM
	if(href_list["priv_msg"])
		var/client/C = locate(href_list["priv_msg"])
		if(ismob(C)) 		//Old stuff can feed-in mobs instead of clients
			var/mob/M = C
			C = M.client
		cmd_admin_pm(C,null)
		return

	if(href_list["irc_msg"])
		if(!holder && received_irc_pm < world.time - 6000) //Worse they can do is spam IRC for 10 minutes
			usr << "<span class='warning'>You are no longer able to use this, it's been more then 10 minutes since an admin on IRC has responded to you</span>"
			return
		if(mute_irc)
			usr << "<span class='warning'You cannot use this as your client has been muted from sending messages to the admins on IRC</span>"
			return
		cmd_admin_irc_pm()
		return



	//Logs all hrefs
	if(config && config.log_hrefs && href_logfile)
		href_logfile << "<small>[time2text(world.timeofday,"hh:mm")] [src] (usr:[usr])</small> || [hsrc ? "[hsrc] " : ""][href]<br>"

	switch(href_list["_src_"])
		if("holder")	hsrc = holder
		if("usr")		hsrc = mob
		if("prefs")		return prefs.process_link(usr,href_list)
		if("vars")		return view_var_Topic(href,href_list,hsrc)

	..()	//redirect to hsrc.Topic()

/client/proc/handle_spam_prevention(var/message, var/mute_type)
	if(config.automute_on && !holder && src.last_message == message)
		src.last_message_count++
		if(src.last_message_count >= SPAM_TRIGGER_AUTOMUTE)
			src << "\red You have exceeded the spam filter limit for identical messages. An auto-mute was applied."
			cmd_admin_mute(src.mob, mute_type, 1)
			return 1
		if(src.last_message_count >= SPAM_TRIGGER_WARNING)
			src << "\red You are nearing the spam filter limit for identical messages."
			return 0
	else
		last_message = message
		src.last_message_count = 0
		return 0

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		src << "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>"
		return 0
/*	//Don't need this at the moment. But it's here if it's needed later.
	//Helps prevent multiple files being uploaded at once. Or right after eachother.
	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		src << "<font color='red'>Error: AllowUpload(): Spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>"
		return 0
	fileaccess_timer = world.time + FTPDELAY	*/
	return 1


	///////////
	//CONNECT//
	///////////
/client/New(TopicData)
	TopicData = null							//Prevent calls to client.Topic from connect

	if(!(connection in list("seeker", "web")))					//Invalid connection type.
		return null
	if(byond_version < MIN_CLIENT_VERSION)		//Out of date client.
		return null

	if(!config.guests_allowed && IsGuestKey(key))
		alert(src,"This server doesn't allow guest accounts to play. Please go to http://www.byond.com/ and register for a key.","Guest","OK")
		del(src)
		return

	// Change the way they should download resources.
	if(config.resource_urls)
		src.preload_rsc = pick(config.resource_urls)
	else src.preload_rsc = 1 // If config.resource_urls is not set, preload like normal.

	src << "\red If the title screen is black, resources are still downloading. Please be patient until the title screen appears."


	clients += src
	directory[ckey] = src

	//Admin Authorisation
	holder = admin_datums[ckey]
	if(holder)
		admins += src
		holder.owner = src

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = preferences_datums[ckey]
	if(!prefs)
		prefs = new /datum/preferences(src)
		preferences_datums[ckey] = prefs
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning

	. = ..()	//calls mob.Login()

	if(custom_event_msg && custom_event_msg != "")
		src << "<h1 class='alert'>Custom Event</h1>"
		src << "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>"
		src << "<span class='alert'>[custom_event_msg]</span>"
		src << "<br>"

	if( (world.address == address || !address) && !host )
		host = key
		world.update_status()

	if(holder)
		add_admin_verbs()
		admin_memo_show()

	// Forcibly enable hardware-accelerated graphics, as we need them for the lighting overlays.
	// (but turn them off first, since sometimes BYOND doesn't turn them on properly otherwise)
	spawn(5) // And wait a half-second, since it sounds like you can do this too fast.
		if(src)
			winset(src, null, "command=\".configure graphics-hwmode off\"")
			winset(src, null, "command=\".configure graphics-hwmode on\"")

	log_client_to_db()

	send_resources()
	nanomanager.send_resources(src)

	if(prefs.lastchangelog != changelog_hash) //bolds the changelog button on the interface so we know there are updates.
		src << "<span class='info'>You have unread updates in the changelog.</span>"
		winset(src, "rpane.changelog", "background-color=#eaeaea;font-style=bold")
		if(config.aggressive_changelog)
			src.changes()



	//////////////
	//DISCONNECT//
	//////////////
/client/Del()
	if(holder)
		holder.owner = null
		admins -= src
	directory -= ckey
	clients -= src
	return ..()


// here because it's similar to below

// Returns null if no DB connection can be established, or -1 if the requested key was not found in the database

/proc/get_player_age(key)
	establish_db_connection()
	if(!dbcon.IsConnected())
		return null

	var/sql_ckey = sql_sanitize_text(ckey(key))

	var/DBQuery/query = dbcon.NewQuery("SELECT datediff(Now(),firstseen) as age FROM erro_player WHERE ckey = '[sql_ckey]'")
	query.Execute()

	if(query.NextRow())
		return text2num(query.item[1])
	else
		return -1


/client/proc/log_client_to_db()

	if ( IsGuestKey(src.key) )
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/sql_ckey = sql_sanitize_text(src.ckey)

	var/DBQuery/query = dbcon.NewQuery("SELECT id, datediff(Now(),firstseen) as age FROM erro_player WHERE ckey = '[sql_ckey]'")
	query.Execute()
	var/sql_id = 0
	player_age = 0	// New players won't have an entry so knowing we have a connection we set this to zero to be updated if their is a record.
	while(query.NextRow())
		sql_id = query.item[1]
		player_age = text2num(query.item[2])
		break

	var/DBQuery/query_ip = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE ip = '[address]'")
	query_ip.Execute()
	related_accounts_ip = ""
	while(query_ip.NextRow())
		related_accounts_ip += "[query_ip.item[1]], "
		break

	var/DBQuery/query_cid = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE computerid = '[computer_id]'")
	query_cid.Execute()
	related_accounts_cid = ""
	while(query_cid.NextRow())
		related_accounts_cid += "[query_cid.item[1]], "
		break

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			return

	var/admin_rank = "Player"
	if(src.holder)
		admin_rank = src.holder.rank

	var/sql_ip = sql_sanitize_text(src.address)
	var/sql_computerid = sql_sanitize_text(src.computer_id)
	var/sql_admin_rank = sql_sanitize_text(admin_rank)


	if(sql_id)
		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/DBQuery/query_update = dbcon.NewQuery("UPDATE erro_player SET lastseen = Now(), ip = '[sql_ip]', computerid = '[sql_computerid]', lastadminrank = '[sql_admin_rank]' WHERE id = [sql_id]")
		query_update.Execute()
	else
		//New player!! Need to insert all the stuff
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO erro_player (id, ckey, firstseen, lastseen, ip, computerid, lastadminrank) VALUES (null, '[sql_ckey]', Now(), Now(), '[sql_ip]', '[sql_computerid]', '[sql_admin_rank]')")
		query_insert.Execute()

	//Logging player access
	var/serverip = "[world.internet_address]:[world.port]"
	var/DBQuery/query_accesslog = dbcon.NewQuery("INSERT INTO `erro_connection_log`(`id`,`datetime`,`serverip`,`ckey`,`ip`,`computerid`) VALUES(null,Now(),'[serverip]','[sql_ckey]','[sql_ip]','[sql_computerid]');")
	query_accesslog.Execute()


#undef TOPIC_SPAM_DELAY
#undef UPLOAD_LIMIT
#undef MIN_CLIENT_VERSION

//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration=3000)
	if(inactivity > duration)	return inactivity
	return 0

//send resources to the client. It's here in its own proc so we can move it around easiliy if need be
/client/proc/send_resources()

	getFiles(
		'html/search.js',
		'html/panels.css',
		'html/images/loading.gif',
		'html/images/ntlogo.png',
		'html/images/talisman.png',
		'icons/pda_icons/pda_atmos.png',
		'icons/pda_icons/pda_back.png',
		'icons/pda_icons/pda_bell.png',
		'icons/pda_icons/pda_blank.png',
		'icons/pda_icons/pda_boom.png',
		'icons/pda_icons/pda_bucket.png',
		'icons/pda_icons/pda_crate.png',
		'icons/pda_icons/pda_cuffs.png',
		'icons/pda_icons/pda_eject.png',
		'icons/pda_icons/pda_exit.png',
		'icons/pda_icons/pda_flashlight.png',
		'icons/pda_icons/pda_honk.png',
		'icons/pda_icons/pda_mail.png',
		'icons/pda_icons/pda_medical.png',
		'icons/pda_icons/pda_menu.png',
		'icons/pda_icons/pda_mule.png',
		'icons/pda_icons/pda_notes.png',
		'icons/pda_icons/pda_power.png',
		'icons/pda_icons/pda_rdoor.png',
		'icons/pda_icons/pda_reagent.png',
		'icons/pda_icons/pda_refresh.png',
		'icons/pda_icons/pda_scanner.png',
		'icons/pda_icons/pda_signaler.png',
		'icons/pda_icons/pda_status.png',
		'icons/spideros_icons/sos_1.png',
		'icons/spideros_icons/sos_2.png',
		'icons/spideros_icons/sos_3.png',
		'icons/spideros_icons/sos_4.png',
		'icons/spideros_icons/sos_5.png',
		'icons/spideros_icons/sos_6.png',
		'icons/spideros_icons/sos_7.png',
		'icons/spideros_icons/sos_8.png',
		'icons/spideros_icons/sos_9.png',
		'icons/spideros_icons/sos_10.png',
		'icons/spideros_icons/sos_11.png',
		'icons/spideros_icons/sos_12.png',
		'icons/spideros_icons/sos_13.png',
		'icons/spideros_icons/sos_14.png'
		)


mob/proc/MayRespawn()
	return 0

client/proc/MayRespawn()
	if(mob)
		return mob.MayRespawn()

	// Something went wrong, client is usually kicked or transfered to a new mob at this point
	return 0
