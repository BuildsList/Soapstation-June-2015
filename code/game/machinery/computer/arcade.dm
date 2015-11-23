/obj/machinery/computer/arcade/
	name = "random arcade"
	desc = "random arcade machine"
	icon_state = "arcade"
	icon_keyboard = null
	icon_screen = "invaders"
	var/list/prizes = list(	/obj/item/weapon/storage/box/snappops			= 2,
							/obj/item/toy/blink								= 2,
							/obj/item/clothing/under/syndicate/tacticool	= 2,
							/obj/item/toy/sword								= 2,
							/obj/item/weapon/gun/projectile/revolver/capgun	= 2,
							/obj/item/toy/crossbow							= 2,
							/obj/item/clothing/suit/syndicatefake			= 2,
							/obj/item/weapon/storage/fancy/crayons			= 2,
							/obj/item/toy/spinningtoy						= 2,
							/obj/item/toy/prize/ripley						= 1,
							/obj/item/toy/prize/fireripley					= 1,
							/obj/item/toy/prize/deathripley					= 1,
							/obj/item/toy/prize/gygax						= 1,
							/obj/item/toy/prize/durand						= 1,
							/obj/item/toy/prize/honk						= 1,
							/obj/item/toy/prize/marauder					= 1,
							/obj/item/toy/prize/seraph						= 1,
							/obj/item/toy/prize/mauler						= 1,
							/obj/item/toy/prize/odysseus					= 1,
							/obj/item/toy/prize/phazon						= 1,
							/obj/item/toy/waterflower						= 1,
							/obj/random/action_figure						= 1,
							/obj/random/plushie								= 1,
							/obj/item/toy/cultsword							= 1
							)

/obj/machinery/computer/arcade/New()
	..()
	// If it's a generic arcade machine, pick a random arcade
	// circuit board for it and make the new machine
	if(!circuit)
		var/choice = pick(typesof(/obj/item/weapon/circuitboard/arcade) - /obj/item/weapon/circuitboard/arcade)
		var/obj/item/weapon/circuitboard/CB = new choice()
		new CB.build_path(loc, CB)
		qdel(src)

/obj/machinery/computer/arcade/proc/prizevend()
	if(!contents.len)
		var/prizeselect = pickweight(prizes)
		new prizeselect(src.loc)

		if(istype(prizeselect, /obj/item/clothing/suit/syndicatefake)) //Helmet is part of the suit
			new	/obj/item/clothing/head/syndicatefake(src.loc)

	else
		var/atom/movable/prize = pick(contents)
		prize.loc = src.loc

/obj/machinery/computer/arcade/attack_ai(mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/arcade/emp_act(severity)
	if(stat & (NOPOWER|BROKEN))
		..(severity)
		return
	var/empprize = null
	var/num_of_prizes = 0
	switch(severity)
		if(1)
			num_of_prizes = rand(1,4)
		if(2)
			num_of_prizes = rand(0,2)
	for(num_of_prizes; num_of_prizes > 0; num_of_prizes--)
		empprize = pickweight(prizes)
		new empprize(src.loc)

	..(severity)

///////////////////
//  BATTLE HERE  //
///////////////////

/obj/machinery/computer/arcade/battle
	name = "arcade machine"
	desc = "Does not support Pinball."
	icon_state = "arcade"
	circuit = /obj/item/weapon/circuitboard/arcade/battle
	var/enemy_name = "Space Villian"
	var/temp = "Winners don't use space drugs" //Temporary message, for attack messages, etc
	var/player_hp = 30 //Player health/attack points
	var/player_mp = 10
	var/enemy_hp = 45 //Enemy health/attack points
	var/enemy_mp = 20
	var/gameover = 0
	var/blocked = 0 //Player cannot attack/heal while set
	var/turtle = 0

/obj/machinery/computer/arcade/battle/New()
	..()
	var/name_action
	var/name_part1
	var/name_part2

	name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ", "Pwn ", "Own ", "Ban ")

	name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Cuban ", "the Evil ", "the Dread King ", "the Space ", "Lord ", "the Great ", "Duke ", "General ")
	name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon", "Uhangoid", "Vhakoid", "Peteoid", "slime", "Griefer", "ERPer", "Lizard Man", "Unicorn", "Bloopers")

	src.enemy_name = replacetext((name_part1 + name_part2), "the ", "")
	src.name = (name_action + name_part1 + name_part2)


/obj/machinery/computer/arcade/battle/attack_hand(mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a>"
	dat += "<center><h4>[src.enemy_name]</h4></center>"

	dat += "<br><center><h3>[src.temp]</h3></center>"
	dat += "<br><center>Health: [src.player_hp] | Magic: [src.player_mp] | Enemy Health: [src.enemy_hp]</center>"

	dat += "<center><b>"
	if (src.gameover)
		dat += "<a href='byond://?src=\ref[src];newgame=1'>New Game</a>"
	else
		dat += "<a href='byond://?src=\ref[src];attack=1'>Attack</a> | "
		dat += "<a href='byond://?src=\ref[src];heal=1'>Heal</a> | "
		dat += "<a href='byond://?src=\ref[src];charge=1'>Recharge Power</a>"

	dat += "</b></center>"

	user << browse(dat, "window=arcade")
	onclose(user, "arcade")
	return

/obj/machinery/computer/arcade/battle/Topic(href, href_list)
	if(..())
		return 1

	if (!src.blocked && !src.gameover)
		if (href_list["attack"])
			src.blocked = 1
			var/attackamt = rand(2,6)
			src.temp = "You attack for [attackamt] damage!"
			src.updateUsrDialog()
			if(turtle > 0)
				turtle--

			sleep(10)
			src.enemy_hp -= attackamt
			src.arcade_action()

		else if (href_list["heal"])
			src.blocked = 1
			var/pointamt = rand(1,3)
			var/healamt = rand(6,8)
			src.temp = "You use [pointamt] magic to heal for [healamt] damage!"
			src.updateUsrDialog()
			turtle++

			sleep(10)
			src.player_mp -= pointamt
			src.player_hp += healamt
			src.blocked = 1
			src.updateUsrDialog()
			src.arcade_action()

		else if (href_list["charge"])
			src.blocked = 1
			var/chargeamt = rand(4,7)
			src.temp = "You regain [chargeamt] points"
			src.player_mp += chargeamt
			if(turtle > 0)
				turtle--

			src.updateUsrDialog()
			sleep(10)
			src.arcade_action()

	if (href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=arcade")

	else if (href_list["newgame"]) //Reset everything
		temp = "New Round"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0
		turtle = 0

		if(emagged)
			src.New()
			emagged = 0

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/arcade/battle/proc/arcade_action()
	if ((src.enemy_mp <= 0) || (src.enemy_hp <= 0))
		if(!gameover)
			src.gameover = 1
			src.temp = "[src.enemy_name] has fallen! Rejoice!"

			if(emagged)
				feedback_inc("arcade_win_emagged")
				new /obj/effect/spawner/newbomb/timer/syndicate(src.loc)
				new /obj/item/clothing/head/collectable/petehat(src.loc)
				message_admins("[key_name_admin(usr)] has outbombed Cuban Pete and been awarded a bomb.")
				log_game("[key_name_admin(usr)] has outbombed Cuban Pete and been awarded a bomb.")
				src.New()
				emagged = 0
			else if(!contents.len)
				feedback_inc("arcade_win_normal")
				src.prizevend()

			else
				feedback_inc("arcade_win_normal")
				src.prizevend()

	else if (emagged && (turtle >= 4))
		var/boomamt = rand(5,10)
		src.temp = "[src.enemy_name] throws a bomb, exploding you for [boomamt] damage!"
		src.player_hp -= boomamt

	else if ((src.enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		src.temp = "[src.enemy_name] steals [stealamt] of your power!"
		src.player_mp -= stealamt
		src.updateUsrDialog()

		if (src.player_mp <= 0)
			src.gameover = 1
			sleep(10)
			src.temp = "You have been drained! GAME OVER"
			if(emagged)
				feedback_inc("arcade_loss_mana_emagged")
				usr.gib()
			else
				feedback_inc("arcade_loss_mana_normal")

	else if ((src.enemy_hp <= 10) && (src.enemy_mp > 4))
		src.temp = "[src.enemy_name] heals for 4 health!"
		src.enemy_hp += 4
		src.enemy_mp -= 4

	else
		var/attackamt = rand(3,6)
		src.temp = "[src.enemy_name] attacks for [attackamt] damage!"
		src.player_hp -= attackamt

	if ((src.player_mp <= 0) || (src.player_hp <= 0))
		src.gameover = 1
		src.temp = "You have been crushed! GAME OVER"
		if(emagged)
			feedback_inc("arcade_loss_hp_emagged")
			usr.gib()
		else
			feedback_inc("arcade_loss_hp_normal")

	src.blocked = 0
	return


/obj/machinery/computer/arcade/battle/emag_act(var/charges, var/mob/user)
	if(!emagged)
		temp = "If you die in the game, you die for real!"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0
		blocked = 0
		emagged = 1

		enemy_name = "Cuban Pete"
		name = "Outbomb Cuban Pete"

		src.updateUsrDialog()
		return 1


//////////////////////////
//   ORION TRAIL HERE   //
//////////////////////////

//Orion Trail Events
#define ORION_TRAIL_RAIDERS				"Vox Raiders"
#define ORION_TRAIL_FLUX				"Interstellar Flux"
#define ORION_TRAIL_ILLNESS				"Illness"
#define ORION_TRAIL_BREAKDOWN			"Breakdown"
#define ORION_TRAIL_MUTINY				"Mutiny?"
#define ORION_TRAIL_MUTINY_ATTACK 		"Mutinous Ambush"
#define ORION_TRAIL_MALFUNCTION			"Malfunction"
#define ORION_TRAIL_COLLISION			"Collision"
#define ORION_TRAIL_SPACEPORT			"Spaceport"
#define ORION_TRAIL_DISASTER			"Disaster"
#define ORION_TRAIL_SPACEPORT_RAIDED	"Raided Spaceport"
#define ORION_TRAIL_DERELICT			"Derelict Spacecraft"
#define ORION_TRAIL_CARP				"Carp Migration"
#define ORION_TRAIL_STUCK				"Stuck!"
#define ORION_TRAIL_START				"Start"
#define ORION_TRAIL_GAMEOVER			"Gameover!"


#define ORION_VIEW_MAIN			0
#define ORION_VIEW_SUPPLIES		1
#define ORION_VIEW_CREW			2


/obj/machinery/computer/arcade/orion_trail
	name = "orion trail"
	desc = "Imported straight fron station-TG!"
	icon_state = "arcade"
	circuit = /obj/item/weapon/circuitboard/arcade/orion_trail
	var/list/supplies = list("1" = 0, "2" = 0, "3" = 0, "4" = 0, "5" = 0, "6" = 0) //engine,hull,electronics,food,fuel
	var/list/supply_cost = list("1" = 1000, "2" = 950, "3" = 1100, "4" = 75, "5" = 100)
	var/list/supply_name = list("1" = "engine parts", "2" = "hull parts", "3" = "electronic parts", "4" = "food", "5" = "fuel", "6" = "thalers")
	var/list/settlers = list()
	var/num_traitors = 0
	var/list/events = list(ORION_TRAIL_RAIDERS		= 3,
						   ORION_TRAIL_FLUX			= 1,
						   ORION_TRAIL_ILLNESS		= 3,
						   ORION_TRAIL_BREAKDOWN	= 2,
						   ORION_TRAIL_MUTINY		= 3,
						   ORION_TRAIL_MALFUNCTION	= 2,
						   ORION_TRAIL_COLLISION	= 1,
						   ORION_TRAIL_CARP			= 3
						   )
	var/list/stops = list("Pluto","Asteroid Belt","Proxima Centauri","Dead Space","Rigel Prime","Tau Ceti Beta","Black Hole","Space Outpost Beta-9","Orion Prime")
	var/list/stopblurbs = list(
		"Pluto, long since occupied with long-range sensors and scanners, stands ready to, and indeed continues to probe the far reaches of the galaxy.",
		"At the edge of the Sol system lies a treacherous asteroid belt. Many have been crushed by stray asteroids and misguided judgement.",
		"The nearest star system to Sol, in ages past it stood as a reminder of the boundaries of sub-light travel, now a low-population sanctuary for adventurers and traders.",
		"This region of space is particularly devoid of matter. Such low-density pockets are known to exist, but the vastness of it is astounding.",
		"Rigel Prime, the center of the Rigel system, burns hot, basking its planetary bodies in warmth and radiation.",
		"Tau Ceti Beta has recently become a waypoint for colonists headed towards Orion. There are many ships and makeshift stations in the vicinity.",
		"Sensors indicate that a black hole's gravitational field is affecting the region of space we were headed through. We could stay of course, but risk of being overcome by its gravity, or we could change course to go around, which will take longer.",
		"You have come into range of the first man-made structure in this region of space. It has been constructed not by travellers from Sol, but by colonists from Orion. It stands as a monument to the colonists' success.",
		"You have made it to Orion! Congratulations! Your crew is one of the few to start a new foothold for mankind!"
		)
	var/list/stop_distance = list(10000,7000,25000,9000,5000,30000,25000,10000,0)
	var/event = null
	var/event_title = ""
	var/event_desc = ""
	var/event_actions = ""
	var/event_info = ""
	var/distance = 0
	var/port = 0
	var/view = 0

/obj/machinery/computer/arcade/orion_trail/proc/newgame(var/emag = 0)
	name = "orion trail[emag ? ": Realism Edition" : ""]"
	supplies = list("1" = 1, "2" = 1, "3" = 1, "4" = 60, "5" = 20, "6" = 5000)
	emagged = emag
	distance = 0
	settlers = list("[usr]")
	for(var/i=0; i<3; i++)
		if(prob(50))
			settlers += pick(first_names_male)
		else
			settlers += pick(first_names_female)
	num_traitors = 0
	event = ORION_TRAIL_START
	port = 0
	view = ORION_VIEW_MAIN

/obj/machinery/computer/arcade/orion_trail/attack_hand(mob/user)
	var/dat = ""
	if(event == null)
		newgame()
	user.set_machine(src)
	switch(view)
		if(ORION_VIEW_MAIN)
			if(event == ORION_TRAIL_START) //new game? New game.
				dat = "<center><h1>Orion Trail[emagged ? ": Realism Edition" : ""]</h1><br>Learn how our ancestors got to Orion, and have fun in the process!<br><P ALIGN=Right><a href='?src=\ref[src];continue=1'>Start New Game</a></P>"
				user << browse(dat, "window=arcade")
				return
			else
				event_title = event
				event_actions = "<a href='?src=\ref[src];continue=1'>Continue your journey</a><br>"
			switch(event)
				if(ORION_TRAIL_GAMEOVER)
					event_info = ""
					event_actions = "<a href='?src=\ref[src];continue=1'>Start New Game</a><br>"
				if(ORION_TRAIL_SPACEPORT)
					event_title   += ": [stops[port]]"
					event_desc     = "[stopblurbs[port]]"
					event_info     = ""
					if(port == 9)
						event_actions = "<a href='?src=\ref[src];continue=1'>Return to the title screen!</a><br>"
					else
						event_actions  = "<a href='?src=\ref[src];continue=1'>Shove off</a><br>"
						event_actions += "<a href='?src=\ref[src];attack=1'>Raid Spaceport</a>"
				if(ORION_TRAIL_SPACEPORT_RAIDED)
					event_title  += ": [stops[port]]"
					event_actions = "<a href='?src=\ref[src];continue=1'>Shove off</a>"
				if(ORION_TRAIL_RAIDERS)
					event_desc   = "You arm yourselves as you prepare to fight off the vox menace!"
				if(ORION_TRAIL_DERELICT)
					event_desc = "You come across an unpowered ship drifting slowly in the vastness of space. Sensors indicate there are no lifeforms aboard."
				if(ORION_TRAIL_ILLNESS)
					event_desc = "A disease has spread amoungst your crew!"
				if(ORION_TRAIL_FLUX)
					event_desc = "You've entered a turbulent region. Slowing down would be better for your ship but would cost more fuel."
					event_actions  = "<a href='?src=\ref[src];continue=1;risky=25'>Continue as normal</a><BR>"
					event_actions += "<a href='?src=\ref[src];continue=1;slow=1;'>Take it slow</a><BR>"
				if(ORION_TRAIL_MALFUNCTION)
					event_info = ""
					event_desc = "The ship's computers are malfunctioning! You can choose to fix it with a part or risk something going awry."
					event_actions  = "<a href='?src=\ref[src];continue=1;risky=25'>Continue as normal</a><BR>"
					if(supplies["3"] != 0)
						event_actions += "<a href='?src=\ref[src];continue=1;fix=3'>Fix using a part.</a><BR>"
				if(ORION_TRAIL_COLLISION)
					event_info = ""
					event_desc = "Something has hit your ship and breached the hull! You can choose to fix it with a part or risk something going awry."
					event_actions  = "<a href='?src=\ref[src];continue=1;risky=25'>Continue as normal</a><BR>"
					if(supplies["2"] != 0)
						event_actions += "<a href='?src=\ref[src];continue=1;fix=2'>Fix using a part.</a><BR>"
				if(ORION_TRAIL_BREAKDOWN)
					event_info = ""
					event_desc = "The ship's engines broke down! You can choose to fix it with a part or risk something going awry."
					event_actions  = "<a href='?src=\ref[src];continue=1;risky=25'>Continue as normal</a><BR>"
					if(supplies["1"] != 0)
						event_actions += "<a href='?src=\ref[src];continue=1;fix=1'>Fix using a part.</a><BR>"
				if(ORION_TRAIL_STUCK)
					event_desc    = "You've ran out of fuel. Your only hope to survive is to get refueled by a passing ship, if there are any."
					if(supplies["5"] == 0)
						event_actions = "<a href='?src=\ref[src];continue=1;food=1'>Wait</a>"
				if(ORION_TRAIL_CARP)
					event_desc = "You've chanced upon a large carp migration! Known both for their delicious meat as well as their bite, you and your crew arm yourselves for a small hunting trip."
				if(ORION_TRAIL_MUTINY)
					event_desc = "You've been hearing rumors of dissenting opinions and missing items from the armory..."
				if(ORION_TRAIL_MUTINY_ATTACK)
					event_desc = "Oh no, some of your crew are attempting to mutiny!!"

			dat = "<center><h1>[event_title]</h1>[event_desc]<br><br>Distance to next port: [distance]<br><b>[event_info]</b><br></center><br>[event_actions]"
		if(ORION_VIEW_SUPPLIES)
			dat  = "<center><h1>Supplies</h1>View your supplies or buy more when at a spaceport.</center><BR>"
			dat += "<center>You have [supplies["6"]] thalers.</center>"
			for(var/i=1; i<6; i++)
				var/amm = (i>3?10:1)
				dat += "[supplies["[i]"]] [supply_name["[i]"]][event==ORION_TRAIL_SPACEPORT ? ", <a href='?src=\ref[src];buy=[i]'>buy [amm] for [supply_cost["[i]"]]T</a>" : ""]<BR>"
				if(supplies["[i]"] >= amm && event == ORION_TRAIL_SPACEPORT)
					dat += "<a href='?src=\ref[src];sell=[i]'>sell [amm] for [supply_cost["[i]"]]T</a><br>"
		if(ORION_VIEW_CREW)
			dat = "<center><h1>Crew</h1>View the status of your crew.</center>"
			for(var/i=1;i<=settlers.len;i++)
				dat += "[settlers[i]] <a href='?src=\ref[src];kill=[i]'>Kill</a><br>"

	dat += "<br><P ALIGN=Right>View:<BR>"
	dat += "[view==ORION_VIEW_MAIN ? "" : "<a href='?src=\ref[src];continue=1'>"]Main[view==ORION_VIEW_MAIN ? "" : "</a>"]<BR>"
	dat += "[view==ORION_VIEW_SUPPLIES ? "" : "<a href='?src=\ref[src];supplies=1'>"]Supplies[view==ORION_VIEW_SUPPLIES ? "" : "</a>"]<BR>"
	dat += "[view==ORION_VIEW_CREW ? "" : "<a href='?src=\ref[src];crew=1'>"]Crew[view==ORION_VIEW_CREW ? "" : "</a>"]</P>"
	user << browse(dat, "window=arcade")

/obj/machinery/computer/arcade/orion_trail/Topic(href,href_list)
	if(href_list["continue"])
		if(view == ORION_VIEW_MAIN)
			var/next_event = null
			if(event == ORION_TRAIL_START)
				event = ORION_TRAIL_SPACEPORT
			if(event == ORION_TRAIL_GAMEOVER)
				event = null
				src.updateUsrDialog()
				return
			if(!settlers.len)
				event_desc = "You and your crew were killed on the way to Orion, your ship left abandoned for scavengers to find."
				next_event = ORION_TRAIL_GAMEOVER
			if(port == 9)
				win()
				return
			var/travel = min(rand(1000,10000),distance)
			if(href_list["fix"])
				var/item = href_list["fix"]
				supplies[item] = max(0, --supplies[item])
			if(href_list["risky"])
				var/risk = text2num(href_list["risky"])
				if(prob(risk))
					next_event = ORION_TRAIL_DISASTER


			if(!href_list["food"])
				var/temp = supplies["5"] - travel/1000 * (href_list["slow"] ? 2 : 1)
				if(temp < 0 && (distance-travel != 0) && next_event == null) //uh oh. Better start a fuel event.
					next_event = ORION_TRAIL_STUCK
					travel -= (temp*-1)*1000/(href_list["slow"] ? 2 : 1)
					temp = 0
				supplies["5"] = temp

				supplies["4"] = round(supplies["4"] - travel/1000 * settlers.len * (href_list["slow"] ? 2 : 1))
				distance = max(0,distance-travel)
			else
				supplies["4"] -= settlers.len * 5
				event_info = "You have [supplies["4"]] food left.<BR>"
				next_event = ORION_TRAIL_STUCK

			if(supplies["4"] <= 0)
				next_event = ORION_TRAIL_GAMEOVER
				event_desc = "You and your crew starved to death, never to reach Orion."
				supplies["4"] = 0

			if(distance == 0 && next_event == null) //POOORT!
				port++
				event = ORION_TRAIL_SPACEPORT
				distance = stop_distance[port]
				//gotta set supply costs. The further out the more expensive it'll generally be
				supply_cost = list("1" = rand(500+100*port,1200+100*port), "2" = rand(700+100*port,1000+100*port), "3" = rand(900+50*port,1500+75*port), "4" =  rand(10+50*port,125+50*port), "5" =  rand(75+25*port,200+100*port))
			else //Event? Event.
				generate_event(next_event)
		else
			view = ORION_VIEW_MAIN

	if(href_list["supplies"])
		view = ORION_VIEW_SUPPLIES

	if(href_list["crew"])
		view = ORION_VIEW_CREW

	if(href_list["buy"])
		var/item = href_list["buy"]
		if(supply_cost["[item]"] <= supplies["6"])
			supplies["[item]"] += (text2num(item) > 3 ? 10 : 1)
			supplies["6"] -= supply_cost["[item]"]

	if(href_list["sell"])
		var/item = href_list["sell"]
		if(supplies["[item]"] >= (text2num(item) > 3 ? 10 : 1))
			supplies["6"] += supply_cost["[item]"]
			supplies["[item]"] -= (text2num(item) > 3 ? 10 : 1)

	if(href_list["kill"])
		var/item = text2num(href_list["kill"])
		remove_settler(item)

	if(href_list["attack"])
		supply_cost = list()
		if(prob(17*settlers.len))
			event_desc = "An empty husk of a station now, all its resources stripped for use in your travels."
			event_info = "You've successfully raided the spaceport!<br>"
			change_resource(null)
			change_resource(null)
		else
			event_desc = "The local police mobilized too quickly, sirens blare as you barely make it away with your ship intact."
			change_resource(null,-1)
			change_resource(null,-1)
			if(prob(50))
				remove_settler(null, "died while you were escaping!")
				if(prob(10))
					remove_settler(null, "died while you were escaping!")
		event = ORION_TRAIL_SPACEPORT_RAIDED
	src.updateUsrDialog()

/obj/machinery/computer/arcade/orion_trail/proc/change_resource(var/specific = null, var/add = 1)
	if(!specific)
		specific = rand(1,6)
	var/cost = (specific < 4 ? rand(1,5) : rand(5,100)) * add
	cost = round(cost)
	if(cost < 0)
		cost = max(cost,supplies["[specific]"] * -1)
	else
		cost = max(cost,1)
	supplies["[specific]"] += cost
	event_info += "You've [add > 0 ? "gained" : "lost"] [abs(cost)] [supply_name["[specific]"]]<BR>"

/obj/machinery/computer/arcade/orion_trail/proc/remove_settler(var/specific = null, var/desc = null)
	if(!settlers.len)
		return
	if(!specific)
		specific = rand(1,settlers.len)

	event_info += "The crewmember, [settlers[specific]] [desc == null ? "has died!":"[desc]"]<BR>"
	settlers -= settlers[specific]
	if(num_traitors > 0 && prob(100/max(1,settlers.len-1)))
		num_traitors--

/obj/machinery/computer/arcade/orion_trail/proc/generate_event(var/specific = null)
	if(!specific)
		if(prob(20*num_traitors))
			specific = ORION_TRAIL_MUTINY_ATTACK
		else
			specific = pickweight(events)

	switch(specific)
		if(ORION_TRAIL_RAIDERS)
			if(prob(17 * settlers.len))
				event_info = "You managed to fight them off!<br>"
				if(prob(5))
					remove_settler(null,"died in the firefight!")
				change_resource(rand(4,5))
				change_resource(rand(1,3))
				if(prob(50))
					change_resource(6,1.1)
			else
				event_info = "You couldn't fight them off!<br>"
				if(prob(10*settlers.len))
					remove_settler(null, "was kidnapped by the Vox!")
				change_resource(null,-1)
				change_resource(null,-0.5)
		if(ORION_TRAIL_DERELICT)
			if(prob(60))
				event_info = "You find resources onboard!"
				change_resource(rand(1,3))
				change_resource(rand(4,5))
			else
				event_info = "You don't find anything onboard..."
		if(ORION_TRAIL_COLLISION)
			event_info = ""
			event_desc = "You've collided with a passing meteor, breaching your hull!"
			if(prob(10))
				event_info = "Your cargo hold was breached!<BR>"
				change_resource(rand(4,5),-1)
			if(prob(5*settlers.len))
				remove_settler(null,"was sucked out into the void!")
		if(ORION_TRAIL_ILLNESS)
			if(prob(15))
				event_info = ""
				var/num = 1
				if(prob(15))
					num++
				for(var/i=0;i<num;i++)
					remove_settler(null,"has succumbed to an illness.")
			else
				event_info = "Thankfully everybody was able to pull through."
		if(ORION_TRAIL_CARP)
			event_info = ""
			if(prob(100-25*settlers.len))
				remove_settler(null, "was swarmed by carp and eaten!")
			change_resource(4)

		if(ORION_TRAIL_MUTINY)
			event_info = ""
			if(num_traitors < settlers.len - 1 && prob(55)) //gotta have at LEAST one non-traitor.
				num_traitors++
		if(ORION_TRAIL_MUTINY_ATTACK)
			//check to see if they just jump ship
			if(prob(30+(settlers.len-num_traitors)*20))
				event_info = "The traitors decided to jump ship along with some of your supplies!<BR>"
				change_resource(4,-1 - (0.2 * num_traitors))
				change_resource(5,-1 - (0.1 * num_traitors))
				for(var/i=0;i<num_traitors;i++)
					remove_settler(rand(2,settlers.len),"decided to up and leave!")
				num_traitors = 0
			else //alright. They wanna fight for the ship.
				event_info = "The traitors are charging you! Prepare your weapons!<BR>"
				var/list/traitors = list()
				for(var/i=0;i<num_traitors;i++)
					traitors += pick((settlers-traitors)-settlers[1])
				var/list/nontraitors = settlers-traitors
				while(nontraitors.len && traitors.len)
					if(prob(50))
						var/t = rand(1,traitors.len)
						remove_settler(t,"was slain like the traitorous scum they were!")
						traitors -= traitors[t]
					else
						var/n = rand(1,nontraitors.len)
						remove_settler(n,"was slain in defense of the ship!")
						nontraitors -= nontraitors[n]
				settlers = nontraitors
				num_traitors = 0
		if(ORION_TRAIL_DISASTER)
			event_desc = "The [event] proved too difficult for you and your crew!"
			change_resource(4,-1)
			change_resource(pick(1,3),-1)
			change_resource(5,-1)
		if(ORION_TRAIL_STUCK)
			event_info = "You have [supplies["4"]] food left.<BR>"
			if(prob(10))
				event_info += "A passing ship has kindly donated fuel to you and wishes you luck on your journey.<BR>"
				change_resource(5,0.3)
	if(emagged)
		emag_effect(specific)
	event = specific

/obj/machinery/computer/arcade/orion_trail/proc/emag_effect(var/event)
	switch(event)
		if(ORION_TRAIL_RAIDERS)
			if(istype(usr,/mob/living/carbon))
				var/mob/living/carbon/M = usr
				if(prob(50))
					usr << "<span class='warning'>You hear battle shouts. The tramping of boots on cold metal. Screams of agony. The rush of venting air. Are you going insane?</span>"
					M.hallucination += 50
				else
					usr << "<span class='danger'>Something strikes you from behind! It hurts like hell and feel like a blunt weapon, but nothing is there...</span>"
					M.take_organ_damage(10)
			else
				usr << "<span class='warning'>The sounds of battle fill your ears...</span>"
		if(ORION_TRAIL_ILLNESS)
			if(istype(usr,/mob/living/carbon/human))
				var/mob/living/carbon/human/M = usr
				M << "<span class='warning'>An overpowering wave of nausea consumes over you. You hunch over, your stomach's contents preparing for a spectacular exit.</span>"
				M.vomit()
			else
				usr << "<span class='warning'>You feel ill.</span>"
		if(ORION_TRAIL_CARP)
			usr << "<span class='danger'> Something bit you!</span>"
			var/mob/living/M = usr
			M.adjustBruteLoss(10)
		if(ORION_TRAIL_FLUX)
			if(istype(usr,/mob/living/carbon) && prob(75))
				var/mob/living/carbon/M = usr
				M.Weaken(3)
				src.visible_message("A sudden gust of powerful wind slams \the [M] into the floor!", "You hear a large fwooshing sound, followed by a bang.")
				M.take_organ_damage(10)
			else
				usr << "<span class='warning'>A violent gale blows past you, and you barely manage to stay standing!</span>"
		if(ORION_TRAIL_MALFUNCTION)
			if(supplies["3"])
				return
			src.visible_message("\The [src]'s screen glitches out and smoke comes out of the back.")
			for(var/i=1;i<7;i++)
				supplies["[i]"] = max(0,supplies["[i]"] + rand(-10,10))
		if(ORION_TRAIL_COLLISION)
			if(prob(90) && !supplies["2"])
				var/turf/simulated/floor/F = src.loc
				F.ChangeTurf(/turf/space)
				src.visible_message("<span class='danger'>Something slams into the floor around \the [src], exposing it to space!</span>", "You hear something crack and break.")
			else
				src.visible_message("Something slams into the floor around \the [src] - luckily, it didn't get through!", "You hear something crack.")
		if(ORION_TRAIL_GAMEOVER)
			usr << "<span class='danger'><font size=3>You're never going to make it to Orion...</font></span>"
			var/mob/living/M = usr
			M.visible_message("\The [M] starts rapidly deteriorating.")
			M << browse (null,"window=arcade")
			for(var/i=0;i<10;i++)
				sleep(10)
				M.Stun(5)
				M.adjustBruteLoss(10)
				M.adjustFireLoss(10)
			usr.gib() //So that people can't cheese it and inject a lot of kelo/bicard before losing



/obj/machinery/computer/arcade/orion_trail/emag_act(mob/user)
	if(!emagged)
		newgame(1)
		src.updateUsrDialog()

/obj/machinery/computer/arcade/orion_trail/proc/win()
	src.visible_message("\The [src] plays a triumpant tune, stating 'CONGRATULATIONS, YOU HAVE MADE IT TO ORION.'")
	if(emagged)
		new /obj/item/weapon/orion_ship(src.loc)
		message_admins("[key_name_admin(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
		log_game("[key_name(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
	else
		prizevend()
	event = null
	src.updateUsrDialog()

/obj/item/weapon/orion_ship
	name = "model settler ship"
	desc = "A model spaceship, it looks like those used back in the day when travelling to Orion! It even has a miniature FX-293 reactor, which was renowned for its instability and tendency to explode..."
	icon = 'icons/obj/toy.dmi'
	icon_state = "ship"
	w_class = 2
	var/active = 0 //if the ship is on
/obj/item/weapon/orion_ship/examine(mob/user)
	..()
	if(!(in_range(user, src)))
		return
	if(!active)
		user << "<span class='notice'>There's a little switch on the bottom. It's flipped down.</span>"
	else
		user << "<span class='notice'>There's a little switch on the bottom. It's flipped up.</span>"
/obj/item/weapon/orion_ship/attack_self(mob/user)
	if(active)
		return
	message_admins("[key_name_admin(usr)] primed an explosive Orion ship for detonation.")
	log_game("[key_name(usr)] primed an explosive Orion ship for detonation.")
	user << "<span class='warning'>You flip the switch on the underside of [src].</span>"
	active = 1
	src.visible_message("<span class='notice'>[src] softly beeps and whirs to life!</span>")
	src.audible_message("<b>\The [src]</b> says, 'This is ship ID #[rand(1,1000)] to Orion Port Authority. We're coming in for landing, over.'")
	sleep(20)
	src.visible_message("<span class='warning'>[src] begins to vibrate...</span>")
	src.audible_message("<b>\The [src]</b> says, 'Uh, Port? Having some issues with our reactor, could you check it out? Over.'")
	sleep(30)
	src.audible_message("<b>\The [src]</b> says, 'Oh, God! Code Eight! CODE EIGHT! IT'S GONNA BL-'")
	sleep(3.6)
	src.visible_message("<span class='danger'>[src] explodes!</span>")
	explosion(src.loc, 1,2,4)
	qdel(src)

#undef ORION_TRAIL_RAIDERS
#undef ORION_TRAIL_FLUX
#undef ORION_TRAIL_ILLNESS
#undef ORION_TRAIL_BREAKDOWN
#undef ORION_TRAIL_MUTINY
#undef ORION_TRAIL_MUTINY_ATTACK
#undef ORION_TRAIL_MALFUNCTION
#undef ORION_TRAIL_COLLISION
#undef ORION_TRAIL_SPACEPORT
#undef ORION_TRAIL_DISASTER
#undef ORION_TRAIL_CARP
#undef ORION_TRAIL_STUCK
#undef ORION_TRAIL_START
#undef ORION_TRAIL_GAMEOVER


#undef ORION_VIEW_MAIN
#undef ORION_VIEW_SUPPLIES
#undef ORION_VIEW_CREW