#define SOLID 1
#define LIQUID 2
#define GAS 3
var/induromol_frequency = rand(700, 750) * 2 + 1 //signallers only increase by .2 increments
var/induromol_code = rand(1, 50)

datum
	reagent
		phororeagent //already shoved into a list by Chemistry-Holder.dm
			name = "Unanalyzed Reagent"
			id = "unknown"
			description = "Currently unknown"
			reagent_state = LIQUID

			proc/initial_reaction(var/obj/item/weapon/reagent_containers/container, var/turf/T, var/volume, var/message)
				if(reagent_state == GAS)
					return "WARNING: Gaseous reaction detected! Repeating reaction inadvisable."
				return message
			//mostly dangerous initial reactions, to ensure protective gear is worn

		//	var/real_name = "Phororeagent"
		//	var/real_desc = "A phororeagent, yeah"

		/*	extreme_mutagen does not work for now
				id = "mutagen_x"
				name = "Extreme Mutagen"
				description = "Seems as if it would induce instant, random mutations in a living humanoid"
				color = "#20E7F5"

				on_mob_life(var/mob/living/M as mob)
					var/damage = min(50, max(15, 3 * src.volume)) //use to stop abuse of one time use stuff
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						H.dna.check_integrity()
						var/block
						if(prob(90))
							block = pick(FAKEBLOCK,CLUMSYBLOCK,BLINDBLOCK,DEAFBLOCK)
						else
							block = pick(HULKBLOCK,XRAYBLOCK,FIREBLOCK,TELEBLOCK)

						var/cur_DNA = H.dna.GetSEState(block)
						while(H.dna.GetSEState(block) == cur_DNA)	//ensure it toggles 100% of the time
							world << "Got here"
							H.dna.SetSEState(block, !cur_DNA)

						domutcheck(M,null,MUTCHK_FORCED)
						M.update_mutations()

					M.adjustToxLoss(damage)
					holder.remove_reagent(src.id, src.volume)
					//..()
			*/

			bicordrazine
				id = "bicordrazine"
				name = "Bicordrazine"
				description = "Testing indicates potentially a more efficient form of Tricordrazine"
				color = "#C8A5DC"
				metabolism = 2.5 * REM

				on_mob_life(var/mob/living/M as mob, var/alien) //make heal less overall than Tricord
					if(M.stat == 2)
						return
					if(!M)
						M = holder.my_atom
					if(!alien || alien != IS_DIONA)
						if(M.getOxyLoss())
							M.adjustOxyLoss(-2*REM)
						if(M.getBruteLoss() && prob(80))
							M.heal_organ_damage(2*REM,0)
						if(M.getFireLoss() && prob(80))
							M.heal_organ_damage(0,2*REM)
						if(M.getToxLoss() && prob(80))
							M.adjustToxLoss(-2*REM)

					..()

			genedrazine
				id = "genedrazine"
				name = "Genedrazine"
				description = "Seems as if it would heal very quickly, but at the cost of genetic damage"

				on_mob_life(var/mob/living/M as mob, var/alien)
					if(M.getOxyLoss())
						M.adjustOxyLoss(-4*REM)
					if(M.getBruteLoss())
						M.heal_organ_damage(4*REM,0)
					if(M.getFireLoss())
						M.heal_organ_damage(0,4*REM)
					if(M.getToxLoss())
						M.adjustToxLoss(-4*REM)

					if(prob(50))
						M.adjustCloneLoss(1)

					return ..()

			lacertusol
				id = "lacertusol"
				name = "Lacertusol"
				description = "Looks as if it turns off muscle inhibitors, increasing strength dramatically"
				color = "#FFFA73"
				//implementation in human_attackhand.dm

			love_potion
				id = "amorapotio"
				name = "Amorapotio"
				description = "Seems as if it would induce incredibly strong feelings of affection"
				color = "#E3209B"
				metabolism = 0.5 * REM
				var/love_name

				on_mob_life(var/mob/living/M as mob, var/alien)
					if(ishuman(M))
						if(!love_name)
							var/dist = 100
							for(var/mob/living/carbon/human/H in view(M))
								if(H == M)
									continue
								var/distTo = sqrt(((M.x - H.x) ** 2) + ((M.y - H.y) ** 2))
								if(distTo < dist)
									dist = distTo
									love_name = H.name

							if(love_name)
								M << "<font color='#e3209b'>You see [love_name]...</font>"
								spawn(0)
									sleep(10)
									M << "<font color='#e3209b'>They are beautiful</font>"

									if(M.mind) //give protect objective
										var/datum/objective/protection = new/datum/objective()
										protection.explanation_text = "<font color='#e3209b'>Protect [love_name] at all costs</font>"
										M.mind.objectives.Add(protection)
										var/obj_count = 1
										M << "\blue Your current objectives:"
										for(var/datum/objective/objective in M.mind.objectives)
											M << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
											obj_count++

										M << "<BR>"
						else
							if(prob(5))
								if(prob(98))
									var/list/love_messages = list("You feel strong affection towards [love_name]",
									"You can't stop thinking about [love_name]", "[love_name] is love, [love_name] is life",
									"[love_name] seems irresistable", "You cannot fathom life without [love_name]",
									"[love_name] seems to be the essence of perfection",
									"[love_name] can never be allowed to leave your side")

									//spruce up with showy colors and more messages later
									M << "<font color='#e3209b'>[pick(love_messages)]</font>"

								else
									M << "<font color='#e3209b'>You begin to build a trouser tent</font>"
					return ..()

				on_remove(var/atom/A)
					if(istype(A, /mob/living))
						var/mob/living/M = A
						if(M.mind)
							var/message = "Your mind feels a lot more focused"
							var/end_message = ""
							var/list/message2list = list()
							var/i = 1
							var/length = lentext(message)
							while(i <= length)
								message2list += copytext(message, i, i + 1)
								i++
							var/col_perc = 1 / length
							var/col_inc = 0
							var/red = 0
							var/green = 0
							var/blue = 0
							for(var/char in message2list)
								red = (227 * (1 - col_inc))
								green = (32 * (1 - col_inc))
								blue = (155 * (1 - col_inc))
								end_message += "<font color = '[rgb(red, green, blue)]'>[char]</font>"
								col_inc += col_perc

							M << end_message


							for(var/datum/objective/O in M.mind.objectives)
								if(findtext(O.explanation_text, "Protect [love_name] at all costs"))
									M.mind.objectives.Remove(O)
									var/obj_count = 1
									M << "\blue Your current objectives:"
									for(var/datum/objective/objective in M.mind.objectives)
										M << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
										obj_count++

									M << "<BR>"
									break

				on_mob_death(var/mob/M)
					//update objectives
					if(M.mind)
						for(var/datum/objective/O in M.mind.objectives)
							if(findtext(O.explanation_text, "Protect [love_name] at all costs"))
								M.mind.objectives.Remove(O)
								var/obj_count = 1
								M << "\blue Your current objectives:"
								for(var/datum/objective/objective in M.mind.objectives)
									M << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
									obj_count++

								M << "<BR>"
								break

			nasty
				id = "nasty"
				name = "Nasty"
				description = "Ewwwwwwwwwwwwwww"
				color = "#F5F2F7"

				touch_mob(var/mob/M, var/volume)
					if(istype(M, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = M
						H << "\red You are so repulsed by the liquid splashed on you that you feel like puking"
					//	H.vomit() not fast enough
						src = null
						spawn(0)
							if(!H.lastpuke)
								H.lastpuke = 1
								H << "<spawn class='warning'>You feel nauseous..."
								spawn(10)	//1 second until second warning
									H << "<spawn class='warning'>You feel like you are about to throw up!"
									spawn(20)	//and you have 2 more to escape
										H.Stun(8)

										H.visible_message("<spawn class='warning'>[H] throws up!","<spawn class='warning'>You throw up!")
										playsound(H.loc, 'sound/effects/splat.ogg', 50, 1)

										var/turf/location = H.loc
										if (istype(location, /turf/simulated))
											location.add_vomit_floor(H, 1)

										H.nutrition -= 40
										H.adjustToxLoss(-3)
										spawn(350)	//wait 35 seconds before next volley
											H.lastpuke = 0

				reaction_turf(var/turf/T, var/volume)
					var/obj/effect/decal/cleanable/vomit/V = locate(/obj/effect/decal/cleanable/vomit, T)
					if(!V)
						V = new/obj/effect/decal/cleanable/vomit(T)
						V.name = "ewwwwwww"
						V.desc = "That's nasty."
						V.icon_state = "vomittox_2"

					var/dist = 100
					var/mob/living/carbon/human/immune
					for(var/mob/living/carbon/human/H in viewers(T, 2))
						var/distTo = sqrt(((T.x - H.x) ** 2) + ((T.y - H.y) ** 2))
						if(distTo < dist && (istype(H.l_hand, /obj/item/weapon/reagent_containers) || \
								 istype(H.r_hand, /obj/item/weapon/reagent_containers)))
							immune = H

					src = null
					for(var/mob/living/carbon/human/H in viewers(T, 7))
						if(H == immune)
							H << "\blue You are absolutely disgusted, but you hold your stomach contents in."
							continue
						H << "\red You are so disgusted by what looks like spilled vomit you might throw up!"
					//	H.vomit() not fast enough
						spawn(0)
							if(!H.lastpuke)
								H.lastpuke = 1
								H << "<spawn class='warning'>You feel nauseous..."
								spawn(50)	//5 seconds until second warning
									H << "<spawn class='warning'>You feel like you are about to throw up!"
									spawn(50)	//and you have 5 more for mad dash to the bucket
										H.Stun(5)

										H.visible_message("<spawn class='warning'>[H] throws up!","<spawn class='warning'>You throw up!")
										playsound(H.loc, 'sound/effects/splat.ogg', 50, 1)

										var/turf/location = H.loc
										if (istype(location, /turf/simulated))
											location.add_vomit_floor(H, 1)

										H.nutrition -= 40
										H.adjustToxLoss(-3)
										spawn(350)	//wait 35 seconds before next volley
											H.lastpuke = 0
					//	return ..()
				initial_reaction(var/obj/item/weapon/reagent_containers/container, var/turf/T, var/volume, var/message)
					for(var/mob/living/carbon/human/H in viewers(T, 7))
						H << "\red There is something about the reagent from the telepad you find absolutely repulsive."
						H.vomit()
					return ..()

			babelizine
				id = "babelizine"
				name = "Babelizine"
				description = "Similar to an enzyme produced by the incredibly rare Babel Fish, might have great linguistic applications"
				color = "#E5F58E"
				metabolism = 0.2 * REM

				on_mob_life(var/mob/living/M as mob, var/alien)
					M.universal_understand = 1
					..()

				on_remove(var/atom/A)
					if(istype(A, /mob/living))
						var/mob/living/M = A
						M.universal_understand = 0
						M << "\red You no longer feel attuned to the spoken word."

				on_mob_death(var/mob/M)
					holder.remove_reagent(src.id, src.volume)

			calcisol
				id = "calcisol"
				name = "Calcisol"
				description = "Looks as though it could have profound effects upon broken limbs"
				color = "#EDE6E1"

				on_mob_life(var/mob/living/M as mob, var/alien) //12 units per bone
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						var/list/broken = list()
						for(var/obj/item/organ/external/E in H.organs)
							if(E && (E.status & ORGAN_BROKEN))
								broken += E

						if(broken.len >= 1 && src.volume >= 12)
							var/obj/item/organ/external/bone = broken[rand(1, broken.len)]
							bone.status &= ~ORGAN_BROKEN
							bone.perma_injury = 0
							H.visible_message(
							"\blue You hear a loud crack as [H.name]'s [bone.name] appears to heal miraculously")
							holder.remove_reagent(src.id, 12)

							//affected.status &= ~ORGAN_BROKEN
							//affected.status &= ~ORGAN_SPLINTED
						//	affected.perma_injury = 0
					..()


			malaxitol //name donated by Flywolfpack
				id = "malaxitol"
				name = "Malaxitol"
				description = "Analysis indicates it could greatly speed up the rate at which other reagents are metabolized"
				color = "#A155ED"
				metabolism = 2 * REM

				on_mob_life(var/mob/living/M as mob, var/alien)
					for(var/datum/reagent/R in M.reagents.reagent_list)
						if(R.id == src.id)
							continue
						R.on_mob_life(M, alien)

					..()

			doloran //To be finished
				id = "doloran"
				name = "Doloran"
				description = "Looks as if it could cause horrifically intense pain"
				color = "#F20A0E"
				metabolism = 2 * REM //(1/2) or normal metabolism?

				on_mob_life(var/mob/living/M as mob, var/alien)
					M.halloss = 100
					M.stuttering = 10

					if(istype(M, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = M
						H.shock_stage = min(H.shock_stage, 100)


					if(prob(10))
						if(prob(33))
							M.emote("scream")
						else
							if(prob(50))
								M.emote("me", 1, "grits their teeth")
							else
								M.emote("me", 1, "writhes in pain")
					..()

			paralitol //Idea by xx_fatalty_xx, //give stun and extreme stutter
				id = "paralitol"
				name = "Paralitol"
				description = "Seems as if it could work as an extreme muscle inhibitor"
				color = "#2F85CC"
				metabolism = 3 * REM

				on_mob_life(var/mob/living/M as mob, var/alien)
					M.Weaken(2)
					M.stuttering = 50
					return ..()


			fulguracin
				id = "fulguracin"
				name = "Fulguracin"
				description = "Looks as though it could work as an extreme electrical inhibitor"
				color = "#362F31"

				touch_mob(var/mob/M, var/volume)
					if(istype(M, /mob/living/silicon))
						var/mob/living/silicon/S = M
						S.take_organ_damage(0, volume/2, emp = 1)
						S << "\red Some of your systems report damage as a result of the liquid."
					else
						if(istype(M, /mob/living/carbon/human))
							var/mob/living/carbon/human/H = M
							if(istype(M, /mob/living/silicon/robot))
								H.take_overall_damage(0, volume/2)
								H << "\red Some of your systems report damage as a result of the liquid."
			//implementation also in power.dm, electrical_field.dm, and stunbaton.dm

			mortemol
				id = "mortemol"
				name = "Mortemol"
				description = "Further testing required, could potentially reanimate dead cells if delivered with enough force"
				color = "#000000"
				metabolism = 5 * REM //gotta balance it somehow
				data = list(0)

				touch_mob(var/mob/M, var/volume) //do we deal with ghosting?
					if(!istype(M, /mob/living/carbon))
						return 0

					var/mob/living/carbon/C = M

					//var/datum/reagent/self = src //don't know why they do it, but they do it in the original proc
					//src = null

					if(holder)
						if(!istype(holder.my_atom, /obj/effect/effect/smoke/chem))
							if(C.reagents)
								if(C.stat && !(data[1]))
									data[1] = 1
									C.reagents.add_reagent(id, volume, data)
									C.rejuvenate()
									C.rejuvenate() //I like C.rejuvenate()
									C.visible_message("\red[C] seems to wake from the dead!")
								else
									C.reagents.add_reagent(id, volume)

				on_mob_life(var/mob/living/M as mob, var/alien)
					if(data[1])
						M.halloss = 100
						M.stuttering = 1 //make moan like zombie -Doomer

					return ..()

				on_remove(var/atom/A) //does not work?
					if(data[1])
						if(istype(A, /mob))
							var/mob/M = A
							M << "\red You feel the last traces of chemicals leave your body as you return to death once more..."
							M.death(0)
						//Reagent giveth, and reagent taketh away

				on_mob_death(var/mob/M)
					if(data[1])
						return
					else
						if(istype(M, /mob/living/carbon))
							var/mob/living/carbon/C = M
							data[1] = 1
							C.rejuvenate()
							C.rejuvenate() //I like C.rejuvenate()
							C.visible_message("\red[C] seems to wake from the dead!")

			tegoxane
				id = "tegoxane"
				name = "Tegoxane"
				description = "Seems like it could render biotic matter incapable of being seen, so long as no large movements are made"
				color = "#7C7D7A"
				var/saved_icon //could probably store these in data, whatever
				var/hair
				var/beard

				on_mob_life(var/mob/living/M as mob, var/alien)
					if(!saved_icon) //|| (saved_icon != 'icons/mob/belt.dmi') figure out how to detect this
						saved_icon = M.icon //kind of hacky, shouldn't really cause too many problems

					M.icon = 'icons/mob/belt.dmi' //belts because I can

					if(istype(M, /mob/living/carbon/human)) //hair still shows even though you're invisible...
						var/mob/living/carbon/human/H = M
						if(!hair || ((H.h_style != hair) && (H.h_style != "Bald")))
							hair = H.h_style
							spawn(10)
								H.update_hair()
						if(!beard || ((H.f_style != beard) && (H.f_style != "Shaved")))
							beard = H.f_style
							spawn(10)
								H.update_hair()

						H.h_style = "Bald"
						H.f_style = "Shaved"

					if(!M.digitalcamo)
						M << "\blue Your skin starts to feel strange"
					M.digitalcamo = 1
					return ..()

				on_remove(var/atom/A)
					if(istype(A, /mob))
						var/mob/M = A
						M << "\red Your skin feels normal again"
						M.digitalcamo = 0
						M.icon = saved_icon
						if(istype(M, /mob/living/carbon/human))
							var/mob/living/carbon/human/H = M
							if(hair)
								H.h_style = hair
							if(beard)
								H.f_style = beard
							H.update_hair()

				on_mob_death(var/mob/M)
					M.icon = saved_icon
					M.digitalcamo = 0
					if(istype(M, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = M
						if(hair)
							H.h_style = hair
						if(beard)
							H.f_style = beard
						H.update_hair()


			expulsicol
				id = "expulsicol"
				name = "Expulsicol"
				description = "Structure indicates it could purge living cells of non-essential reagents"
				color = "#8C4C3E"
				var/message_given = 0

				on_mob_life(var/mob/living/M as mob, var/alien)
					if(!message_given)
						M << "You don't feel very good..."
						message_given = 1

					spawn(20)
						if(ishuman(M))
							var/mob/living/carbon/human/H = M

							H.visible_message("<spawn class='warning'>[H] throws up!","<spawn class='warning'>You throw up!")
							playsound(H.loc, 'sound/effects/splat.ogg', 50, 1)

							var/turf/location = H.loc
							if (istype(location, /turf/simulated))
								location.add_vomit_floor(src, 1)

							H.nutrition -= 40

						for(var/datum/reagent/R in M.reagents.reagent_list)
							if(R.id == src.id)
								continue
							M.reagents.remove_reagent(R.id, R.volume)

						M.reagents.remove_reagent(src.id, src.volume)
			/*
			mutandisol
				id = "mutandisol"
				name = "Mutandisol"
				description = "If reacted with humanoid blood, could cause rapid genetic change in living organisms"
				color = "#51FF00"

			primed_mutandisol //ensure this doesn't get added to list of makeable reagents
				id = "primed_mutandisol"
				name = "Primed Mutandisol"
				description = "Highly volatile substance capable of rapid genetic change"
				color = "#005C06"*/

			destitutionecam
				id = "destitutionecam"
				name = "Destitutionecam"
				description = "Under no circumstances should this substance come into contact with dead bodies"
				color = "#5AD92B"

				touch_mob(var/mob/M, var/volume)
					if(M.stat == 2)
						usr << "\red Absolutely nothing happens. You feel disappointed."
					return ..()

			sapoformator
				id = "sapoformator"
				name = "Sapoformator"
				description = "Enough units splashed on the ground would appear to have great cleaning effects"
				color = "#EEE139"

				reaction_obj(var/obj/O, var/volume)
					if(istype(O,/obj/effect/decal/cleanable))
						del(O)
					else
						if(O)
							O.clean_blood()

				reaction_turf(var/turf/T, var/volume)
					if(src.holder)
						if(istype(src.holder.my_atom, /obj/effect/effect/water/chempuff))
							if(istype(T, /turf/simulated))
								var/turf/simulated/S = T
								S.dirt = 0
							T.clean_blood()
							for(var/obj/effect/decal/cleanable/C in T.contents)
								src.reaction_obj(C, volume)
								del(C)

					src = null
					if(volume >= 25)
						usr << "\blue The solution begins to fizzle."
						playsound(T, 'sound/effects/bamf.ogg', 50, 1)
						var/datum/reagents/cleaner = new()
						cleaner.my_atom = T
						cleaner.add_reagent("cleaner", 10)
						var/datum/effect/effect/system/foam_spread/soapfoam = new()
						soapfoam.set_up(12, T, cleaner, 0)
						soapfoam.start()
						sleep(50)
						var/list/soaps = typesof(/obj/item/weapon/soap)// - /obj/item/weapon/soap/fluff/azare_siraj_1
						var/soap_type = pick(soaps)
						var/obj/item/weapon/soap/S = new soap_type()
						S.loc = T
						if(volume >= 50)
							volume -= 50
							var/list/tiles = list()
							if(istype(locate(T.x + 1, T.y, T.z), /turf/simulated/floor))
								tiles.Add(locate(T.x + 1, T.y, T.z))
							if(istype(locate(T.x - 1, T.y, T.z), /turf/simulated/floor))
								tiles.Add(locate(T.x - 1, T.y, T.z))
							if(istype(locate(T.x, T.y + 1, T.z), /turf/simulated/floor))
								tiles.Add(locate(T.x, T.y + 1, T.z))
							if(istype(locate(T.x, T.y - 1, T.z), /turf/simulated/floor))
								tiles.Add(locate(T.x, T.y - 1, T.z))

							while(tiles.len > 0 && volume >= 0)
								soap_type = pick(soaps)
								S = new soap_type()
								var/turf/location = pick(tiles)
								tiles.Remove(location)
								S.loc = location
								volume -= 20

					else
						usr << "\red The solution does not appear to have enough mass to react."

			rad_x
				id = "rad_x"
				name = "Rad-X"
				description = "Metabolizes only when absorbing radiation damage"
				color = "#64110B"
				metabolism = 0

				on_mob_life(var/mob/living/M as mob, var/alien)
					var/metabolize = max(M.radiation - 25, 0)
					holder.remove_reagent(src.id, metabolize * 0.025)
					return ..()

			oculusosone //idea by demogavin
				id = "oculusosone"
				name = "Oculusosone"
				description = "Might greatly enhance humanoid eye function"
				color = "#FE9144"
				metabolism = 0.5 * REM

				on_mob_life(var/mob/living/M as mob, var/alien)
					if(M.client)
						if(M.client.view == 7)
							M << "\blue You blink and your eyes quickly adapt to enhanced function."
							M.client.view = 10
					return ..()

				on_remove(var/atom/A)
					if(istype(A, /mob))
						var/mob/M = A
						if(M.client)
							M.client.view = 7
							M << "\red After a few blinks, you realize the Oculusosone has worn off."
					return ..()

			caloran //idea by cebutris
				id = "caloran"
				name = "Caloran"
				description = "Potentially grants incredible heat resistance to living organisms"
				color = "#C64714"
				metabolism = 5 * REM
				overdose = 20
				var/burn = -1

				on_mob_life(var/mob/living/M as mob, var/alien)
					if(volume >= 2)
						if(burn == -1)
							M << "\red You feel your skin painfully harden."
							M.take_overall_damage(20, 0)
							burn = M.getFireLoss()
						else
							if(M.getFireLoss() < burn)
								burn = M.getFireLoss()
							else
								M.adjustFireLoss(burn - M.getFireLoss())
						return ..()

				on_remove(var/atom/A)
					if(istype(A, /mob))
						var/mob/M = A
						M << "\red Your skin returns to normal, no longer desensitized to extreme heat."
					return ..()

			the_stuff
				id = "the_stuff"
				name = "The Stuff"
				description = "Looks as though it would metabolize into the ultimate hallucinogenic cocktail"
				color = "#1A979D"
				metabolism = 10 * REM
				var/init = 0

				on_mob_life(var/mob/living/M as mob, var/alien)
					if(!init)
						M << "\red You start tripping balls."
						init = 1
					var/drugs = list("space_drugs", "serotrotium", "psilocybin", "nuka_cola", "atomicbomb", "hippiesdelight")
					for(var/drug in drugs)
						M.reagents.add_reagent(drug, 1)
					M.reagents.add_reagent("mindbreaker", 0.2)
					return ..()

			frioline //idea by Holybond
				id = "frioline"
				name = "Frioline"
				description = "Could cause rapid and sustained decrease in body temperature"
				color = "#A0E1F7"

				on_mob_life(var/mob/living/M as mob, var/alien)
					if(M.bodytemperature > 310)
						M << "\blue You suddenly feel very cold."
					M.bodytemperature = max(165, M.bodytemperature - 30)
					return ..()

			luxitol
				id = "luxitol"
				name = "Luxitol"
				description = "Mimics compounds in known connection with bioluminescence"
				color = "#61E34F"
				metabolism = 0.2 * REM

				on_mob_life(var/mob/living/M as mob, var/alien)
					M.set_light(10)
					return ..()

				on_remove(var/atom/A)
					if(istype(A, /mob))
						var/mob/M = A
						M.set_light(0)
					return ..()

			liquid_skin
				id = "liquid_skin"
				name = "Liquid Skin"
				description = "Fills in microscopic ridges on biotic surfaces and hardens"
				color = "#F7E9BE"

				touch_mob(var/mob/M, var/volume)
					if(istype(M, /mob/living))
						var/mob/living/L = M
						var/burned = L.getFireLoss() > 0
						if(burned)
							L << "\blue In a strange sensation, you feel some burns stop hurting."
							L.heal_organ_damage(0, min(15, volume / 4))

						if (mFingerprints in L.mutations)
							if(!burned)
								L << "\red Another application of the substance does nothing weird to your hands."
						else
							L.mutations.Add(mFingerprints)
							L << "\blue Your fingers feel strange after the substance splashes on your hands."
					return ..()

			energized_phoron
				id = "energized_phoron"
				name = "Energized Phoron"
				description = "Creates an unstable electrical field between molecules"
				color = "#F5EF38"

				initial_reaction(var/obj/item/weapon/reagent_containers/container, var/turf/T, var/volume, var/message)
					empulse(T, round(volume / 8), round(volume / 5), 1)
					src = null
					spawn(1)
						container.reagents.clear_reagents()
					return "You shoved extreme electricity into phoron, what did you expect?"

				on_transfer(var/volume)
					initial_reaction(src.holder, src.holder.my_atom, volume, null)
					return 0

			induromol
				id = "induromol"
				name = "Induromol"
				description = "Please inform DrBrock of this description being viewed"
				color = "#C6C6C6"
				reagent_state = LIQUID
				metabolism = 0

				New()
					var/freq = "[copytext(num2text(induromol_frequency), 1, 4)].[copytext(num2text(induromol_frequency), 4, 5)]"
					description = "Hardens in response to electromagnetic waves, especially frequency [freq] and code [induromol_code]"
					..()

				on_mob_life(var/mob/living/M as mob)
					if(reagent_state == SOLID)
						var/mob/living/carbon/human/H = M
						for(var/obj/item/organ/O in H.internal_organs)
							var/silent = 1
							if(prob(3))
								silent = 0
							O.take_damage(1, silent)

					..()
				//implementation in communcations.dm

			obscuritol
				id = "obscuritol"
				name = "Obscuritol"
				description = "Exhibits strange electromagnetic properties"
				color = "#5D505E"

				initial_reaction(var/obj/item/weapon/reagent_containers/container, var/turf/T, var/volume, var/message)
					var/obj/machinery/light/L
					for(var/obj/machinery/light/light in orange(3, T))
						if(light.status != 2) //LIGHT_BROKEN
							L = light
							break

					if(L)
						L.broken()

					for(var/obj/machinery/light/light in orange(6, T))
						light.flicker(rand(5, 10))
					return "Abnormal electromagnetic pulses detected, machinery recalibrated."

				reaction_turf(var/turf/T, var/volume) //-round(-x) = Ceiling(x)
					for(var/obj/machinery/light/light in orange(-round(-1 * (volume / 5)), T))
						light.broken()

					for(var/obj/machinery/light/light in orange(-round(-1 * (volume / 3)), T))
						light.flicker()

			tartrate
				id = "tartrate"
				name = "Chlorified Tartrate"
				description = "Mix with enough Aluminum Nitrate for tasty results!"
				color = "#EA67B1"
				//OVENLESS BROWNIES! Shameless Rick and Morty references!

			oxyphoromin
				id = "oxyphoromin"
				name = "Oxyphoromin"
				description = "Extreme painkiller derived of Oxycodone, dangerous in high doses"
				color = "#540E5C"
				metabolism = 5 * REM
				overdose = 15

				on_mob_life(var/mob/living/M as mob)
					if(istype(M, /mob/living/carbon))
						var/mob/living/carbon/C = M
						C.analgesic = 2

				on_remove(var/atom/A)
					if(istype(A, /mob/living/carbon))
						var/mob/living/carbon/C = A
						C.analgesic = 0

			liquid_bluespace //idea by DrBrock and Girdo
				id = "liquid_bluespace"
				name = "Liquid Bluespace"
				description = "Appears to bend space around the container"
				color = "#4ECBF5"
				metabolism = 0
				var/initial_time = 0

				on_mob_life(var/mob/living/M as mob)
					if(!initial_time)
						initial_time = world.time

					if(world.time - initial_time >= 30) //three second startup lag
						if(!metabolism)
							metabolism = 1
							M << "\blue You begin to feel transcendental."

						if(M.z == 2)
							M << "\red You feel the bluespace leave your body on this sector, nothing happens"
							src = null
							return

						var/list/params //list(x min, x max, y min, y max, sector)
						switch(M.z)
							if(1)
								params = list(61, 168, 65, 171, 1) //main station
							if(3)
								params = list(113, 141, 110, 143, 3) //telecomms station
							if(4)
								if(prob(50))
									params = list(41, 61, 143, 164, 4) //engineering station
								else
									params = list(140, 180, 116, 200, 4) //derelict
							if(5)
								params = list(143, 181, 186, 211, 5) //research station
							else
								params = list(10, 245, 10, 245, M.z) //probably sector 6 empty space

						M.x = rand(params[1], params[2])
						M.y = rand(params[3], params[4])
						M.z = params[5]

						if(prob(33))
							var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
							s.set_up(3, 1, get_turf(M))
							s.start()
					..()

				on_remove(var/atom/A)
					if(istype(A, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = A
						H.vomit()

			gaseous
				reagent_state = GAS

				initial_reaction(var/obj/item/weapon/reagent_containers/container, var/turf/T, var/volume, var/message)
					var/datum/effect/effect/system/smoke_spread/chem/effect = new/datum/effect/effect/system/smoke_spread/chem()
					var/datum/reagents/R = new/datum/reagents()
					R.my_atom = container
					R.add_reagent(src.id, volume)
					effect.set_up(R, 17, 0, T, 0)
					effect.start()
					spawn(1)
						container.reagents.clear_reagents()
					return ..()

				on_transfer(var/volume)
					initial_reaction(src.holder, src.holder.my_atom, volume, null)
					return 0

				gaseous_death
					id = "gaseous_death"
					name = "Gaseous Death"
					description = "Full eradication of living matter, lethally toxic!"
					color = "#000000"

					touch_mob(var/mob/M, var/volume)
						if(istype(M, /mob/living/carbon/human))
							var/mob/living/carbon/human/H = M
							if(!gaseous_reagent_check(H) && H.stat != 2) //protective clothing and living check
								H <<"\red <b>You realize you probably should have worn some safety equipment around dangerous chemicals.</b>"
								H.death(0)
						else if(!istype(M, /mob/living/silicon))
							M.death(0)
						src = null
						//return ..()

				occaecosone
					id = "occaecosone"
					name = "Occaecosone"
					description = "Would react very negatively with proteins in biotic eyes"
					color = "#213E73"

					touch_mob(var/mob/M, var/volume)
						if(istype(M, /mob/living/carbon/human))
							var/mob/living/carbon/human/H = M
							if(!gaseous_reagent_check(H)) //protective clothing check
								var/obj/item/organ/eyes = H.internal_organs_by_name["eyes"]
								eyes.take_damage(50)
								H << "\red <b>The gas stings your eyes like you have never felt before!</b>"
						else if(!istype(M, /mob/living/silicon))
							M.eye_blind = 500
						src = null

				ignisol
					id = "ignisol"
					name = "Ignisol"
					description = "Could create highly flammable reaction with biotic substances"
					color = "#F78431"

					touch_mob(var/mob/M, var/volume)
						if(istype(M, /mob/living/carbon/human))
							var/mob/living/carbon/human/H = M
							if(!gaseous_reagent_check(H)) //protective clothing check
								H.on_fire = 1
								H.adjust_fire_stacks(20)
								H.update_fire()
						else
							if(istype(M, /mob/living) && !istype(M, /mob/living/silicon))
								var/mob/living/L = M
								L.on_fire = 1
								L.adjust_fire_stacks(20)
						src = null

		/*	nocturnol //idea by CPM //does not work
				id = "nocturnol"
				name = "Nocturnal"
				description = "Reagent bears strong resemblance to enzymes found in feline eyes"
				color = "#61E34F"

				on_mob_life(var/mob/living/M as mob, var/alien)
					M.see_in_dark = 50
					return ..()

				on_remove(var/atom/A)
					if(istype(A, /mob/living/carbon))
						var/mob/living/carbon/human/H = A
						H.see_in_dark = H.species.darksight
					else
						if(istype(A, /mob))
							var/mob/M = A
							M.see_in_dark = 2
					return ..()*/

/*/datum/chemical_reaction/mutandisol_blood
	name = "Primed Mutandisol"
	id = "mutandisol_blood"
	result = "primed_mutandisol"
	result_amount = 1
	required_reagents = list("mutandisol" = 1, "blood" = 1)

	on_reaction(var/datum/reagents/holder, var/created_volume)
		return

/datum/chemical_reaction/primed_mutandisol_mutandisol
	name = "Primed Mutandisol 2"
	id = "primed_mutandisol_mutandisol"
	result = "primed_mutandisol"
	result_amount = 2
	required_reagents = list("primed_mutandisol" = 1, "mutandisol" = 1)*/
//ensures any amount of blood will be sufficient to react
//could probably put this in mutandisol_blood reaction on_reaction proc

			//pressure equalizer -- Puppenspieler or CPM
			//Greek Fire? -- xx_fatalty_xx
			//reagent that allows you to change features to someone else/hair - Holybond
			//Explodium
			//chemicals that affect room temperature -Makkenhoff
			//healing spray -Makkenhoff
			//chemical that aids in cloning process, speeding it up - Makkenhoff
			//Polyjuice potion? -Flywolf