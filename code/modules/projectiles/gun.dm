/obj/item/weapon/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/gun.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags =  FPRINT | TABLEPASS | CONDUCT |  USEDELAY
	slot_flags = SLOT_BELT
	m_amt = 2000
	w_class = 3.0
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5.0
	origin_tech = "combat=1"
	attack_verb = list("struck", "hit", "bashed")

	var/fire_sound = 'sound/weapons/Gunshot.ogg'
	var/obj/item/projectile/in_chamber = null
	var/caliber = ""
	var/silenced = 0
	var/recoil = 0
	var/ejectshell = 1
	var/clumsy_check = 1
	var/tmp/list/mob/living/target //List of who yer targeting.
	var/tmp/lock_time = -100
	var/tmp/mouthshoot = 0 ///To stop people from suiciding twice... >.>
	var/automatic = 0 //Used to determine if you can target multiple people.
	var/tmp/mob/living/last_moved_mob //Used to fire faster at more than one person.
	var/tmp/told_cant_shoot = 0 //So that it doesn't spam them with the fact they cannot hit them.
	var/firerate = 1 // 0 for one bullet after tarrget moves and aim is lowered,
	//1 for keep shooting until aim is lowered

	proc/load_into_chamber()
		return

	proc/special_check(var/mob/M)
		return


	load_into_chamber()
		return 0

	//Removing the lock and the buttons.
	dropped(mob/user as mob)
		if(target)
			for(var/mob/living/M in target)
				if(M)
					M.NotTargeted(src) //Untargeting people.
			del(target)
		del(user.item_use_icon) //Removing the control icons.
		del(user.gun_move_icon)
		del(user.gun_run_icon)
		return ..()

	special_check(var/mob/M) //Placeholder for any special checks, like detective's revolver.
		return 1


	emp_act(severity)
		for(var/obj/O in contents)
			O.emp_act(severity)

	verb/lower_aim()
		set name = "Lower Aim"
		set category = "Object"
		if(target)
			for(var/mob/living/M in target)
				if(M)
					M.NotTargeted(src)
			del(target)
			usr.visible_message("\blue \The [usr] lowers \the [src]...")

	//Clicking gun will still lower aim for guns that don't overwrite this
	attack_self()
		lower_aim()

	verb/toggle_firerate()
		set name = "Toggle Firerate"
		set category = "Object"
		firerate = !firerate
		if (firerate == 0)
			loc << "You will now continue firing when your target moves."
		else
			loc << "You will now only fire once, then lower your aim, when your target moves."

//Suiciding.
	attack(mob/living/M as mob, mob/living/user as mob, def_zone)
		world << "[user] USED ATTACK()"
		if (M == user && user.zone_sel.selecting == "mouth" && load_into_chamber() && !mouthshoot) //Suicide handling.
			mouthshoot = 1
			M.visible_message("\red \The [user] sticks their gun in their mouth, ready to pull the trigger...")
			if(!do_after(user, 40))
				M.visible_message("\blue \The [user] decided life was worth living")
				mouthshoot = 0
				return
			if(istype(src.in_chamber, /obj/item/projectile/bullet) && !istype(src.in_chamber, /obj/item/projectile/bullet/stunshot) && !istype(src.in_chamber, /obj/item/ammo_casing/shotgun/beanbag))
				M.apply_damage(75, BRUTE, "head", used_weapon = "Suicide attempt with a projectile weapon.")
				M.apply_damage(85, BRUTE, "chest")
				M.visible_message("\red \The [user] pulls the trigger.")
			else if(istype(src.in_chamber, /obj/item/projectile/bullet/stunshot) || istype(src.in_chamber, /obj/item/projectile/energy/electrode))
				M.apply_damage(10, BURN, "head", used_weapon = "Suicide attempt with a stun round.")
				M.visible_message("\red \The [user] pulls the trigger, but luckily it was a stun round.")
			else if(istype(src.in_chamber, /obj/item/ammo_casing/shotgun/beanbag))
				M.apply_damage(20, BRUTE, "head", used_weapon = "Suicide attempt with a beanbag.")
				M.visible_message("\red \The [user] pulls the trigger, but luckily it was a stun round.")
			else if(istype(src.in_chamber, /obj/item/projectile/beam) || istype(src.in_chamber, /obj/item/projectile/energy))
				M.apply_damage(75, BURN, "head", used_weapon = "Suicide attempt with an energy weapon")
				M.apply_damage(85, BURN, "chest")
				M.visible_message("\red \The [user] pulls the trigger.")
			else
				M.apply_damage(75, BRUTE, "head", used_weapon = "Suicide attempt with a gun")
				M.apply_damage(85, BRUTE, "chest")
				M.visible_message("\red \The [user] pulls the trigger. Ow.")
			del(in_chamber)
			mouthshoot = 0
			return
		else if(user.a_intent == "hurt" && load_into_chamber() && (istype(src.in_chamber, /obj/item/projectile/beam) || istype(src.in_chamber, /obj/item/projectile/energy)\
		 || istype(src.in_chamber, /obj/item/projectile/bullet)) && !istype(in_chamber,/obj/item/projectile/energy/electrode)) //Point blank shooting.
			//Lets shoot them, then.
			user.visible_message("\red <b> \The [user] fires \the [src] point blank at [M]!</b>")
			if(silenced)
				playsound(user, fire_sound, 10, 1)
			else
				playsound(user, fire_sound, 50, 1)
			M.apply_damage(30+in_chamber.damage, BRUTE, user.zone_sel.selecting, used_weapon = "Point Blank Shot") //So we'll put him an inch from death.
			M.attack_log += text("\[[]\] <b>[]/[]</b> shot <b>[]/[]</b> point blank with a <b>[]</b>", time_stamp(), user, user.ckey, M, M.ckey, src)
			user.attack_log += text("\[[]\] <b>[]/[]</b> shot <b>[]/[]</b> point blank with a <b>[]</b>", time_stamp(), user, user.ckey, M, M.ckey, src)
			log_admin("ATTACK: [user] ([user.ckey]) shot [M] ([M.ckey]) point blank with [src].")
			message_admins("ATTACK: [user] ([user.ckey]) shot [M] ([M.ckey]) point blank with [src].")
			del(in_chamber)
			update_icon()
			return
		else if(user.a_intent != "hurt" && load_into_chamber() && istype(in_chamber,/obj/item/projectile/energy/electrode)) //Point blank tasering.
			if (!(M.status_flags & CANSTUN) || !(M.status_flags & CANWEAKEN))
				user.visible_message("\red <B>\The [M] has been stunned with the taser gun by \the [user] to no effect!</B>")
				del(in_chamber)
				update_icon()
				return
			if (prob(50))
				if (M.paralysis < 60 && (!(HULK in M.mutations)) )
					M.paralysis = 60
			else
				if (M.weakened < 60 && (!(HULK in M.mutations)) )
					M.weakened = 60
			if (M.stuttering < 60 && (!(HULK in M.mutations)) )
				M.stuttering = 60
			if(silenced)
				playsound(user, fire_sound, 10, 1)
			else
				playsound(user, fire_sound, 50, 1)
			user.visible_message("\red <B>\The [M] has been stunned with the taser gun by \the [user]!</B>")
			M.attack_log += text("\[[]\] <b>[]/[]</b> stunned <b>[]/[]</b> with a <b>[]</b>", time_stamp(), user, user.ckey, M, M.ckey, src)
			user.attack_log += text("\[[]\] <b>[]/[]</b> stunned <b>[]/[]</b> with a <b>[]</b>", time_stamp(), user, user.ckey, M, M.ckey, src)
			log_admin("ATTACK: [user] ([user.ckey]) stunned [M] ([M.ckey]) with [src].")
			message_admins("ATTACK: [user] ([user.ckey]) stunned [M] ([M.ckey]) with [src].")
			del(in_chamber)
			update_icon()
			return
		else if(target && M in target) //Yer targeting them, and 1 tile away.  FIRE!
			if(!load_into_chamber()) //No ammo, hit them!
				return ..()
			else
				world << "\red PREFIRE IS CALLED TO SHOOT AT [M] BY [user]"
				PreFire(M,user) ///Otherwise, shoot!
			return
		else
			return ..() //Pistolwhippin'

//Compute how to fire.....
	proc/PreFire(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, params)
		//GraphicTrace(usr.x,usr.y,A.x,A.y,usr.z)
		if(lock_time > world.time - 2) return //Lets not spam it.
		if(!ismob(A)) //Didn't click someone, check if there is anyone along that guntrace
//				var/mob/M = locate() in range(0,A)
//				if(M && !ismob(A))
//					if(M.type == /mob)
//						return FindTarget(M,user,params)
			var/mob/M = GunTrace(usr.x,usr.y,A.x,A.y,usr.z,usr)  //Find dat mob.
			if(M && ismob(M) && isliving(M) && M in view(user))
				Aim(M) //Aha!  Aim at them!
				return
			else if(!ismob(M) || (ismob(M) && !(M in view(user)))) //Nope!  They weren't there!
				world << "\red CLICKED BUT COULDN'T FIND MOB, FIRED"
				Fire(A,user,params)  //Fire like normal, then.
		if(ismob(A) && isliving(A) && !(A in target))
			Aim(A) //Clicked a mob, aim at them.
		else if(!target)
			world << "\red DIDN'T HAVE A TARGET, FIRED"
			Fire(A,user,params)  //Boom!
		//else
			//var/item/gun/G = usr.OHand
			//if(!G)
				//Fire(A,0)
			//else if(istype(G))
				//G.Fire(A,3)
				//Fire(A,2)
			//else
				//Fire(A)
		// Stolen from sd_get_approx_dir, didn't want to reinclude
		var/d=get_dir(usr,A)
		var/dir_to_fire = d //Turn them to face their target.
		if(d&d-1)        // diagonal
			var/ax=abs(usr.x-A.x)
			var/ay=abs(usr.y-A.y)
			if(ax>=ay<<1) dir_to_fire = d&12   // keep east/west (4 and 8)
			else if(ay>=ax<<1) dir_to_fire = d&3 // keep north/south (1 and 2)
		if(dir_to_fire != usr.dir)
			usr.dir = dir_to_fire

	proc/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)//TODO: go over this

		//Exclude lasertag guns from the CLUMSY check.
		if(src.clumsy_check)
			if(istype(user, /mob/living))
				var/mob/living/M = user
				if ((CLUMSY in M.mutations) && prob(50))
					M << "\red The [src.name] blows up in your face!"
					M.take_organ_damage(0,20)
					M.drop_item()
					del(src)
					return

		if (!user.IsAdvancedToolUser())
			user << "\red You don't have the dexterity to do this!"
			return
		if(istype(user, /mob/living))
			var/mob/living/M = user
			if (HULK in M.mutations)
				M << "\red Your meaty finger is much too large for the trigger guard!"
				return

		add_fingerprint(user)

		var/turf/curloc = user.loc
		var/turf/targloc = get_turf(target)
		if (!istype(targloc) || !istype(curloc))
			return

		if(!special_check(user))
			return
		if(!load_into_chamber()) //CHECK
			user.visible_message("*click click*", "\red <b>*click*</b>")
			for(var/mob/K in viewers(usr))
				K << 'empty.ogg'
			return

		if(!in_chamber)
			return

		in_chamber.firer = user
		in_chamber.def_zone = user.zone_sel.selecting

		if(targloc == curloc)
			user.bullet_act(in_chamber)
			del(in_chamber)
			update_icon()
			return

		if(recoil)
			spawn()
				shake_camera(user, recoil + 1, recoil)

		if(silenced)
			playsound(user, fire_sound, 10, 1)
		else
			playsound(user, fire_sound, 50, 1)
			if(reflex)
				user.visible_message("\red \The [user] fires \the [src] by reflex!", "\red You reflex fire \the [src]!", "\blue You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")
			else
				user.visible_message("\red \The [user] fires \the [src]!", "\red You fire \the [src]!", "\blue You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")

		in_chamber.original = targloc
		in_chamber.loc = get_turf(user)
		in_chamber.starting = get_turf(user)
		user.next_move = world.time + 4
		in_chamber.silenced = silenced
		in_chamber.current = curloc
		in_chamber.yo = targloc.y - curloc.y
		in_chamber.xo = targloc.x - curloc.x

		if(params)
			var/list/mouse_control = params2list(params)
			if(mouse_control["icon-x"])
				in_chamber.p_x = text2num(mouse_control["icon-x"])
			if(mouse_control["icon-y"])
				in_chamber.p_y = text2num(mouse_control["icon-y"])

		spawn()
			if(in_chamber)
				in_chamber.process() //CHECK Might need to be fired()
		sleep(1)
		in_chamber = null

		update_icon()
		return

//Aiming at the target mob.
	proc/Aim(var/mob/M)
		if(!target || !(M in target))
			lock_time = world.time
			if(target && !automatic) //If they're targeting someone and they have a non automatic weapon.
				//usr.ClearRequest("Aim")
				for(var/mob/living/L in target)
					if(L)
						L.NotTargeted(src)
				del(target)
				usr.visible_message("\red <b>[usr] turns \the [src] on [M]!</b>")
			else
				usr.visible_message("\red <b>[usr] aims \a [src] at [M]!</b>")
			M.Targeted(src)


//HE MOVED, SHOOT HIM!
	proc/TargetActed(var/mob/living/T)
		var/mob/living/M = loc
		if(M == T) return
		if(!istype(M) || src != M.equipped())
			for(var/mob/living/N in target)
				if(N)
					N.NotTargeted(src)
			del(target)
			return
		M.last_move_intent = world.time
		if(load_into_chamber())
			var/firing_check = in_chamber.check_fire(T,usr) //0 if it cannot hit them, 1 if it is capable of hitting, and 2 if a special check is preventing it from firing.
			if(firing_check > 0)
				if(firing_check == 1)
					Fire(T,usr, reflex = 1)
			else if(!told_cant_shoot)
				M << "\red They can't be hit from here!"
				told_cant_shoot = 1
				spawn(30)
					told_cant_shoot = 0
		else
			usr.visible_message("*click click*", "\red <b>*click*</b>")
			for(var/mob/K in viewers(usr))
				K << 'empty.ogg'
		// Stolen from sd_get_approx_dir, didn't want to reinclude
		var/d=get_dir(M,T)
		var/dir_to_fire = d
		if(d&d-1)        // diagonal
			var/ax=abs(M.x-T.x)
			var/ay=abs(M.y-T.y)
			if(ax>=ay<<1) dir_to_fire = d&12   // keep east/west (4 and 8)
			else if(ay>=ax<<1) dir_to_fire = d&3 // keep north/south (1 and 2)
		if(dir_to_fire != M.dir)
			M.dir = dir_to_fire
		if (!firerate) // If firerate is set to lower aim after one shot, untarget the target
			T.NotTargeted(src)

	afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
		if(flag)	return //we're placing gun on a table or in backpack
		if(istype(target, /obj/machinery/recharger) && istype(src, /obj/item/weapon/gun/energy))	return//Shouldnt flag take care of this?
		if(user && user.client && user.client.gun_mode)
			PreFire(A,user,params) //They're using the new gun system, locate what they're aiming at.
		else
			Fire(A,user,params) //Otherwise, fire normally.

//Yay, math!

#define SIGN(X) ((X<0)?-1:1)

proc/GunTrace(X1,Y1,X2,Y2,Z=1,exc_obj,PX1=16,PY1=16,PX2=16,PY2=16)
	//bluh << "Tracin' [X1],[Y1] to [X2],[Y2] on floor [Z]."
	var/turf/T
	var/mob/M
	if(X1==X2)
		if(Y1==Y2) return 0 //Light cannot be blocked on same tile
		else
			var/s = SIGN(Y2-Y1)
			Y1+=s
			while(1)
				T = locate(X1,Y1,Z)
				if(!T) return 0
				M = locate() in T
				if(M) return M
				M = locate() in orange(1,T)-exc_obj
				if(M) return M
				Y1+=s
	else
		var
			m=(32*(Y2-Y1)+(PY2-PY1))/(32*(X2-X1)+(PX2-PX1))
			b=(Y1+PY1/32-0.015625)-m*(X1+PX1/32-0.015625) //In tiles
			signX = SIGN(X2-X1)
			signY = SIGN(Y2-Y1)
		if(X1<X2) b+=m
		while(1)
			var/xvert = round(m*X1+b-Y1)
			if(xvert) Y1+=signY //Line exits tile vertically
			else X1+=signX //Line exits tile horizontally
			T = locate(X1,Y1,Z)
			if(!T) return 0
			M = locate() in T
			if(M) return M
			M = locate() in orange(1,T)-exc_obj
			if(M) return M
	return 0


//Targeting management procs
mob/var
	list/targeted_by
	target_time = -100
	last_move_intent = -100
	last_target_click = -5
	target_locked = null

mob/proc
	Targeted(var/obj/item/weapon/gun/I) //Self explanitory.
		if(!I.target)
			I.target = list(src)
		else if(I.automatic && I.target.len < 5) //Automatic weapon, they can hold down a room.
			I.target += src
		else if(I.target.len >= 5)
			if(ismob(I.loc))
				I.loc << "You can only target 5 people at once!"
			return
		else
			return
		for(var/mob/K in viewers(usr))
			K << 'TargetOn.ogg'
		if(!targeted_by) targeted_by = list()
		targeted_by += I
		I.lock_time = world.time + 20 //Target has 2 second to realize they're targeted and stop (or target the opponent).
		src << "((\red <b>Your character is being targeted. They have 2 seconds to stop any click or move actions.</b> \black While targeted, they may \
		drag and drop items in or into the map, speak, and click on interface buttons. Clicking on the map, their items \
		 (other than a weapon to de-target), or moving will result in being fired upon. \red The aggressor may also fire manually, \
		 so try not to get on their bad side.\black ))"
		if(targeted_by.len == 1)
			spawn(0)
				target_locked = image("icon" = 'icons/effects/Targeted.dmi', "icon_state" = "locking")
				overlays += target_locked
				spawn(0)
					sleep(20)
					if(target_locked)
						target_locked = image("icon" = 'icons/effects/Targeted.dmi', "icon_state" = "locked")
						update_targeted()
				var/mob/T = I.loc
				//Adding the buttons to the controler person
				if(T)
					T.item_use_icon = new /obj/screen/gun/item(null)
					T.gun_move_icon = new /obj/screen/gun/move(null)
					if(T.client)
						T.client.screen += T.item_use_icon
						T.client.screen += T.gun_move_icon
					else //If the client's gone, stop aiming
						I.lower_aim()
						return
					if(m_intent == "run" && T.client.target_can_move == 1 && T.client.target_can_run == 0)
						src << "\red Your move intent is now set to walk, as your targeter permits it."  //Self explanitory.
						m_intent = "walk"
						hud_used.move_intent.icon_state = "walking"
				while(targeted_by && T.client)
					if(last_move_intent > I.lock_time + 10 && !T.client.target_can_move) //If target moved when not allowed to
						I.TargetActed(src)
						if(I.last_moved_mob == src) //If they were the last ones to move, give them more of a grace period, so that an automatic weapon can hold down a room better.
							I.lock_time = world.time + 5
						I.lock_time = world.time + 5
						I.last_moved_mob = src
					else if(last_move_intent > I.lock_time + 10 && !T.client.target_can_run && m_intent == "run") //If the target ran while targeted
						I.TargetActed(src)
						if(I.last_moved_mob == src) //If they were the last ones to move, give them more of a grace period, so that an automatic weapon can hold down a room better.
							I.lock_time = world.time + 5
						I.lock_time = world.time + 5
						I.last_moved_mob = src
					if(last_target_click > I.lock_time + 10 && !T.client.target_can_click) //If the target clicked the map to pick something up/shoot/etc
						I.TargetActed(src)
						if(I.last_moved_mob == src) //If they were the last ones to move, give them more of a grace period, so that an automatic weapon can hold down a room better.
							I.lock_time = world.time + 5
						I.lock_time = world.time + 5
						I.last_moved_mob = src
					sleep(1)

	NotTargeted(var/obj/item/weapon/gun/I)
		if(!I.silenced)
			for(var/mob/M in viewers(src))
				M << 'TargetOff.ogg'
		del(target_locked) //Remove the overlay
		targeted_by -= I
		I.target.Remove(src) //De-target them
		if(!I.target.len)
			del(I.target)
		var/mob/T = I.loc //Remove the targeting icons
		if(T && ismob(T) && !I.target)
			del(T.item_use_icon)
			del(T.gun_move_icon)
			del(T.gun_run_icon)
		if(!targeted_by.len) del targeted_by
		spawn(1) update_targeted()

/*	Captive(var/obj/item/weapon/gun/I)
		Sound(src,'CounterAttack.ogg')
		if(!targeted_by) targeted_by = list()
		targeted_by += I
		I.target = src
//		Stun("Captive")
		I.lock_time = world.time + 10 //Target has 1 second to realize they're targeted and stop (or target the opponent).
		src << "(Your character is being held captive. They have 1 second to stop any click or move actions. While held, they may \
		drag and drop items in or into the map, speak, and click on interface buttons. Clicking on the map or their items \
		 (other than a weapon to de-target) will result in being attacked. The aggressor may also attack manually, \
		 so try not to get on their bad side.)"
		if(targeted_by.len == 1)
			var/mob/T = I.loc
			while(targeted_by)
				sleep(1)
				if(last_target_click > I.lock_time + 10 && !T.target_can_click) //If the target clicked the map to pick something up/shoot/etc
					I.TargetActed()

	NotCaptive(var/obj/item/weapon/gun/I,silent)
		if(!silent) Sound(src,'SwordSheath.ogg')
//		UnStun("Captive")
		targeted_by -= I
		I.target = null
		if(!targeted_by.len) del targeted_by*/


//Used to overlay the awesome stuff
///obj/effect
//	target_locking
//		icon = 'icons/effects/Targeted.dmi'
//		icon_state = "locking"
//		layer = 99
//	target_locked
//		icon = 'icons/effects/Targeted.dmi'
//		icon_state = "locking"
//		layer = 17.9
//	captured
//		icon = 'Captured.dmi'
//		layer = 99

//If you move out of range, it isn't going to still stay locked on you any more.
client/var
	target_can_move = 0
	move_dir = 2
	target_can_run = 0
	run_dir = 2
	target_can_click = 0
	click_dir = 2
	gun_mode = 0
	mode_dir = 1
mob/Move()
	. = ..()
	for(var/obj/item/weapon/gun/G in targeted_by) //Handle moving out of the gunner's view.
		var/mob/M = G.loc
		if(!(M in view(src)))
			//ClearRequest("Aim")
			NotTargeted(G)
	for(var/obj/item/weapon/gun/G in src) //Handle the gunner loosing sight of their target/s
		if(G.target)
			for(var/mob/living/M in G.target)
				if(M && !(M in view(src)))
					//ClearRequest("Aim")
					M.NotTargeted(G)
client/verb
//These are called by the on-screen buttons, adjusting what the victim can and cannot do.
	AllowTargetMove()
		set hidden=1
		if (move_dir == 2)
			move_dir = 1
		else
			move_dir = 2
		if(!target_can_move)
//			winset(usr,"default.target_can_move","is-flat=true;border=sunken")
			usr << "Target may now walk."
			usr.gun_run_icon = new /obj/screen/gun/run(null)
			screen += usr.gun_run_icon
			if(usr.gun_move_icon)
				usr.gun_move_icon.dir = move_dir
				usr.gun_move_icon.name = "Disallow Walking"
		else
//			winset(usr,"default.target_can_move","is-flat=false;border=none")
			usr << "Target may no longer move."
			target_can_run = 0
			del(usr.gun_run_icon)
			if(usr.gun_move_icon)
				usr.gun_move_icon.dir = move_dir
				usr.gun_move_icon.name = "Allow Walking"
		for(var/obj/item/weapon/gun/G in usr)
			G.lock_time = world.time + 5
			if(G.target)
				for(var/mob/living/M in G.target)
					if(!target_can_move)
						M << "Your character may now <b>walk</b> at the discretion of their targeter."
						if(!target_can_run)
							M << "\red Your move intent is now set to walk, as your targeter permits it."
							M.m_intent = "walk"
							if(M.hud_used)
								if (M.hud_used.move_intent)
									M.hud_used.move_intent.icon_state = "walking"
					else
						M << "\red <b>Your character will now be shot if they move.</b>"
		target_can_move = !target_can_move

	AllowTargetRun()
		set hidden=1
		if (run_dir == 2)
			run_dir = 1
		else
			run_dir = 2
		if(!target_can_run)
//			winset(usr,"default.target_can_move","is-flat=true;border=sunken")
			usr << "Target may now run."
			if(usr.gun_run_icon)
				usr.gun_run_icon.dir = run_dir
				usr.gun_run_icon.name = "Disallow Running"
		else
//			winset(usr,"default.target_can_move","is-flat=false;border=none")
			usr << "Target may no longer run."
			if(usr.gun_run_icon)
				usr.gun_run_icon.dir = run_dir
				usr.gun_run_icon.name = "Allow Running"
		for(var/obj/item/weapon/gun/G in src)
			G.lock_time = world.time + 5
			if(G.target)
				for(var/mob/living/M in G.target)
					if(!target_can_run)
						M << "Your character may now <b>run</b> at the discretion of their targeter."
					else
						M << "\red <b>Your character will now be shot if they run.</b>"
		target_can_run = !target_can_run

	AllowTargetClick()
		set hidden=1
		if (click_dir == 2)
			click_dir = 1
		else
			click_dir = 2
		if(!target_can_click)
//			winset(usr,"default.target_can_click","is-flat=true;border=sunken")
			usr << "Target may now use items."
			if(usr.item_use_icon)
				usr.item_use_icon.dir = click_dir
				usr.item_use_icon.name = "Disallow Item Use"
		else
//			winset(usr,"default.target_can_click","is-flat=false;border=none")
			usr << "Target may no longer use items."
			if(usr.item_use_icon)
				usr.item_use_icon.dir = click_dir
				usr.item_use_icon.name = "Allow Item Use"
		for(var/obj/item/weapon/gun/G in src)
			G.lock_time = world.time + 5
			if(G.target)
				for(var/mob/living/M in G.target)
					if(!target_can_click)
						M << "Your character may now <b>use items</b> at the discretion of their targeter."
					else
						M << "\red <b>Your character will now be shot if they use items.</b>"
		target_can_click = !target_can_click

	ToggleGunMode()
		set hidden = 1
		gun_mode = !gun_mode
		if (mode_dir == 1)
			mode_dir = 2
		else if (mode_dir == 2)
			mode_dir = 1
		if(gun_mode)
//			winset(usr,"default.target_can_click","is-flat=true;border=sunken")
			usr << "You will now take people captive."
		else
//			winset(usr,"default.target_can_click","is-flat=false;border=none")
			usr << "You will now shoot where you target."
		if(usr.gun_setting_icon)
			usr.gun_setting_icon.dir = mode_dir

/obj/item/weapon/gun/proc/isHandgun()
	return 1
