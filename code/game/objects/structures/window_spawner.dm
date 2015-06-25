// Ported from Haine and WrongEnd with much gratitude!
/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-=WHAT-EVER=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/obj/effect/wingrille_spawn
	name = "window grille spawner"
	icon = 'icons/obj/structures.dmi'
	icon_state = "wingrille"
	density = 1
	anchored = 1.0
	pressure_resistance = 4*ONE_ATMOSPHERE
	var/win_path = /obj/structure/window/basic
	var/activated

/obj/effect/wingrille_spawn/attack_hand()
	attack_generic()

/obj/effect/wingrille_spawn/attack_ghost()
	attack_generic()

/obj/effect/wingrille_spawn/attack_generic()
	activate()

/obj/effect/wingrille_spawn/initialize()
	..()
	if(!win_path)
		return
	if(ticker && ticker.current_state < GAME_STATE_PLAYING)
		activate()

/obj/effect/wingrille_spawn/proc/activate()
	if(activated) return
	if (!locate(/obj/structure/grille) in get_turf(src))
		var/obj/structure/grille/G = PoolOrNew(/obj/structure/grille, src.loc)
		handle_grille_spawn(G)
	var/list/neighbours = list()
	for (var/dir in cardinal)
		var/turf/T = get_step(src, dir)
		var/obj/effect/wingrille_spawn/other = locate(/obj/effect/wingrille_spawn) in T
		if(!other)
			var/found_connection
			if(locate(/obj/structure/grille) in T)
				for(var/obj/structure/window/W in T)
					if(W.type == win_path && W.dir == get_dir(T,src))
						found_connection = 1
						qdel(W)
			if(!found_connection)
				var/obj/structure/window/new_win = PoolOrNew(win_path, src.loc)
				new_win.set_dir(dir)
				handle_window_spawn(new_win)
		else
			neighbours |= other
	activated = 1
	for(var/obj/effect/wingrille_spawn/other in neighbours)
		if(!other.activated) other.activate()
	qdel(src)

// Currently unused, could be useful for POLARIZED WINDOWS, HUH PSIGAMMA.
/obj/effect/wingrille_spawn/proc/handle_window_spawn(var/obj/structure/window/W)
	return

// Currently unused, could be useful for pre-wired electrified windows.
/obj/effect/wingrille_spawn/proc/handle_grille_spawn(var/obj/structure/grille/G)
	return

/obj/effect/wingrille_spawn/reinforced
	name = "reinforced window grille spawner"
	icon_state = "r-wingrille"
	win_path = /obj/structure/window/reinforced

/obj/effect/wingrille_spawn/phoron
	name = "phoron window grille spawner"
	icon_state = "p-wingrille"
	win_path = /obj/structure/window/phoronbasic

/obj/effect/wingrille_spawn/reinforced_phoron
	name = "reinforced phoron window grille spawner"
	icon_state = "pr-wingrille"
	win_path = /obj/structure/window/phoronreinforced
