#define SOLID 1
#define LIQUID 2
#define GAS 3
#define REAGENTS_OVERDOSE 30
#define REM REAGENTS_EFFECT_MULTIPLIER

//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.


datum
	reagent
		var/name = "Reagent"
		var/id = "reagent"
		var/description = ""
		var/datum/reagents/holder = null
		var/reagent_state = SOLID
		var/list/data = null
		var/volume = 0
		var/nutriment_factor = 0
		var/custom_metabolism = REAGENTS_METABOLISM
		var/overdose = 0
		var/overdose_dam = 1
		var/scannable = 0 //shows up on health analyzers
		var/glass_icon_state = null
		var/glass_name = null
		var/glass_desc = null
		var/glass_center_of_mass = null
		//var/list/viruses = list()
		var/color = "#000000" // rgb: 0, 0, 0, 0 - supports alpha channels
		var/color_weight = 1

		proc
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume) //By default we have a chance to transfer some
				if(!istype(M, /mob/living))	return 0
				var/datum/reagent/self = src
				src = null										  //of the reagent to the mob on TOUCHING it.

				if(self.holder)		//for catching rare runtimes
					if(!istype(self.holder.my_atom, /obj/effect/effect/smoke/chem))
						// If the chemicals are in a smoke cloud, do not try to let the chemicals "penetrate" into the mob's system (balance station 13) -- Doohl

						if(method == TOUCH)

							var/chance = 1
							var/block  = 0

							for(var/obj/item/clothing/C in M.get_equipped_items())
								if(C.permeability_coefficient < chance) chance = C.permeability_coefficient
								if(istype(C, /obj/item/clothing/suit/bio_suit))
									// bio suits are just about completely fool-proof - Doohl
									// kind of a hacky way of making bio suits more resistant to chemicals but w/e
									if(prob(75))
										block = 1

								if(istype(C, /obj/item/clothing/head/bio_hood))
									if(prob(75))
										block = 1

							chance = chance * 100

							if(prob(chance) && !block)
								if(M.reagents)
									M.reagents.add_reagent(self.id,self.volume/2)
				return 1

			reaction_obj(var/obj/O, var/volume) //By default we transfer a small part of the reagent to the object
				src = null						//if it can hold reagents. nope!
				//if(O.reagents)
				//	O.reagents.add_reagent(id,volume/3)
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				return

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(!istype(M, /mob/living))
					return //Noticed runtime errors from pacid trying to damage ghosts, this should fix. --NEO
				if( (overdose > 0) && (volume >= overdose))//Overdosing, wooo
					M.adjustToxLoss(overdose_dam)
				holder.remove_reagent(src.id, custom_metabolism) //By default it slowly disappears.
				return

			on_move(var/mob/M)
				return

			// Called after add_reagents creates a new reagent.
			on_new(var/data)
				return

			// Called when two reagents of the same are mixing. <-- Blatant lies
			on_merge(var/newdata, var/newamount)
				return

			on_update(var/atom/A)
				return



		blood
			data = new/list("donor"=null,"viruses"=null,"species"="Human","blood_DNA"=null,"blood_type"=null,"blood_colour"= "#A10808","resistances"=null,"trace_chem"=null, "antibodies" = list())
			name = "Blood"
			id = "blood"
			reagent_state = LIQUID
			color = "#C80000" // rgb: 200, 0, 0

			glass_icon_state = "glass_red"
			glass_name = "glass of tomato juice"
			glass_desc = "Are you sure this is tomato juice?"

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				var/datum/reagent/blood/self = src
				src = null
				if(self.data && self.data["viruses"])
					for(var/datum/disease/D in self.data["viruses"])
						//var/datum/disease/virus = new D.type(0, D, 1)
						// We don't spread.
						if(D.spread_type == SPECIAL || D.spread_type == NON_CONTAGIOUS) continue

						if(method == TOUCH)
							M.contract_disease(D)
						else //injected
							M.contract_disease(D, 1, 0)
				if(self.data && self.data["virus2"] && istype(M, /mob/living/carbon))//infecting...
					var/list/vlist = self.data["virus2"]
					if (vlist.len)
						for (var/ID in vlist)
							var/datum/disease2/disease/V = vlist[ID]

							if(method == TOUCH)
								infect_virus2(M,V.getcopy())
							else
								infect_virus2(M,V.getcopy(),1) //injected, force infection!
				if(self.data && self.data["antibodies"] && istype(M, /mob/living/carbon))//... and curing
					var/mob/living/carbon/C = M
					C.antibodies |= self.data["antibodies"]

			on_merge(var/newdata, var/newamount)
				if(!data || !newdata)
					return
				if(newdata["blood_colour"])
					color = newdata["blood_colour"]
				if(data && newdata)
					if(data["viruses"] || newdata["viruses"])

						var/list/mix1 = data["viruses"]
						var/list/mix2 = newdata["viruses"]

						// Stop issues with the list changing during mixing.
						var/list/to_mix = list()

						for(var/datum/disease/advance/AD in mix1)
							to_mix += AD
						for(var/datum/disease/advance/AD in mix2)
							to_mix += AD

						var/datum/disease/advance/AD = Advance_Mix(to_mix)
						if(AD)
							var/list/preserve = list(AD)
							for(var/D in data["viruses"])
								if(!istype(D, /datum/disease/advance))
									preserve += D
							data["viruses"] = preserve
				return ..()

			on_update(var/atom/A)
				if(data["blood_colour"])
					color = data["blood_colour"]
				return ..()

			reaction_turf(var/turf/simulated/T, var/volume)//splash the blood all over the place
				if(!istype(T)) return
				var/datum/reagent/blood/self = src
				src = null
				if(!(volume >= 3)) return

				if(!self.data["donor"] || istype(self.data["donor"], /mob/living/carbon/human))
					blood_splatter(T,self,1)
				else if(istype(self.data["donor"], /mob/living/carbon/alien))
					var/obj/effect/decal/cleanable/blood/B = blood_splatter(T,self,1)
					if(B) B.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"
				if(volume >= 5 && !istype(T.loc, /area/chapel)) //blood desanctifies non-chapel tiles
					T.holy = 0
				return

/* Must check the transfering of reagents and their data first. They all can point to one disease datum.

			Destroy()
				if(src.data["virus"])
					var/datum/disease/D = src.data["virus"]
					D.cure(0)
				..()
*/
		vaccine
			//data must contain virus type
			name = "Vaccine"
			id = "vaccine"
			reagent_state = LIQUID
			color = "#C81040" // rgb: 200, 16, 64

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				var/datum/reagent/vaccine/self = src
				src = null
				if(self.data&&method == INGEST)
					for(var/datum/disease/D in M.viruses)
						if(istype(D, /datum/disease/advance))
							var/datum/disease/advance/A = D
							if(A.GetDiseaseID() == self.data)
								D.cure()
						else
							if(D.type == self.data)
								D.cure()

					M.resistances += self.data
				return

		woodpulp
			name = "Wood Pulp"
			id = "woodpulp"
			description = "A mass of wood fibers."
			reagent_state = LIQUID
			color = "#B97A57"

		#define WATER_LATENT_HEAT 19000 // How much heat is removed when applied to a hot turf, in J/unit (19000 makes 120 u of water roughly equivalent to 4L)
		water
			name = "Water"
			id = "water"
			description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
			reagent_state = LIQUID
			color = "#0064C877" // rgb: 0, 100, 200
			custom_metabolism = 0.01

			glass_icon_state = "glass_clear"
			glass_name = "glass of water"
			glass_desc = "The father of all refreshments."

			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return

				//If the turf is hot enough, remove some heat
				var/datum/gas_mixture/environment = T.return_air()
				var/min_temperature = T0C + 100	//100C, the boiling point of water

				if (environment && environment.temperature > min_temperature) //abstracted as steam or something
					var/removed_heat = between(0, volume*WATER_LATENT_HEAT, -environment.get_thermal_energy_change(min_temperature))
					environment.add_thermal_energy(-removed_heat)
					if (prob(5))
						T.visible_message("\red The water sizzles as it lands on \the [T]!")

				else //otherwise, the turf gets wet
					if(volume >= 3)
						if(T.wet >= 1) return
						T.wet = 1
						if(T.wet_overlay)
							T.overlays -= T.wet_overlay
							T.wet_overlay = null
						T.wet_overlay = image('icons/effects/water.dmi',T,"wet_floor")
						T.overlays += T.wet_overlay

						src = null
						spawn(800)
							if (!istype(T)) return
							if(T.wet >= 2) return
							T.wet = 0
							if(T.wet_overlay)
								T.overlays -= T.wet_overlay
								T.wet_overlay = null

				//Put out fires.
				var/hotspot = (locate(/obj/fire) in T)
				if(hotspot)
					qdel(hotspot)
					if(environment)
						environment.react() //react at the new temperature

			reaction_obj(var/obj/O, var/volume)
				var/turf/T = get_turf(O)
				var/hotspot = (locate(/obj/fire) in T)
				if(hotspot && !istype(T, /turf/space))
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					qdel(hotspot)
				if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/monkeycube))
					var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
					if(!cube.wrapped)
						cube.Expand()

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if (istype(M, /mob/living/carbon/slime))
					var/mob/living/carbon/slime/S = M
					S.apply_water(volume)
				if(method == TOUCH && isliving(M))
					M.adjust_fire_stacks(-(volume / 10))
					if(M.fire_stacks <= 0)
						M.ExtinguishMob()
					return

		water/holywater
			name = "Holy Water"
			id = "holywater"
			description = "An ashen-obsidian-water mix, this solution will alter certain sections of the brain's rationality."
			color = "#E0E8EF" // rgb: 224, 232, 239

			glass_icon_state = "glass_clear"
			glass_name = "glass of holy water"
			glass_desc = "An ashen-obsidian-water mix, this solution will alter certain sections of the brain's rationality."

			on_mob_life(var/mob/living/M as mob)
				if(ishuman(M))
					if(M.mind && cult.is_antagonist(M.mind) && prob(10))
						cult.remove_antagonist(M.mind)
				holder.remove_reagent(src.id, 10 * REAGENTS_METABOLISM) //high metabolism to prevent extended uncult rolls.
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 5)
					T.holy = 1
				return

		lube
			name = "Space Lube"
			id = "lube"
			description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
			reagent_state = LIQUID
			color = "#009CA8" // rgb: 0, 156, 168
			overdose = REAGENTS_OVERDOSE

			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return
				src = null
				if(volume >= 1)
					if(T.wet >= 2) return
					T.wet = 2
					spawn(800)
						if (!istype(T)) return
						T.wet = 0
						if(T.wet_overlay)
							T.overlays -= T.wet_overlay
							T.wet_overlay = null
						return

		plasticide
			name = "Plasticide"
			id = "plasticide"
			description = "Liquid plastic, do not eat."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0
			custom_metabolism = 0.01

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				// Toxins are really weak, but without being treated, last very long.
				M.adjustToxLoss(0.2)
				..()
				return

		slimetoxin
			name = "Mutation Toxin"
			id = "mutationtoxin"
			description = "A corruptive toxin produced by slimes."
			reagent_state = LIQUID
			color = "#13BC5E" // rgb: 19, 188, 94
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(ishuman(M))
					var/mob/living/carbon/human/human = M
					if(human.species.name != "Slime")
						M << "<span class='danger'>Your flesh rapidly mutates!</span>"
						human.set_species("Slime")
				..()
				return

		aslimetoxin
			name = "Advanced Mutation Toxin"
			id = "amutationtoxin"
			description = "An advanced corruptive toxin produced by slimes."
			reagent_state = LIQUID
			color = "#13BC5E" // rgb: 19, 188, 94
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(istype(M, /mob/living/carbon) && M.stat != DEAD)
					M << "\red Your flesh rapidly mutates!"
					if(M.monkeyizing)	return
					M.monkeyizing = 1
					M.canmove = 0
					M.icon = null
					M.overlays.Cut()
					M.invisibility = 101
					for(var/obj/item/W in M)
						if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
							qdel(W)
							continue
						W.layer = initial(W.layer)
						W.loc = M.loc
						W.dropped(M)
					var/mob/living/carbon/slime/new_mob = new /mob/living/carbon/slime(M.loc)
					new_mob.a_intent = I_HURT
					new_mob.universal_speak = 1
					if(M.mind)
						M.mind.transfer_to(new_mob)
					else
						new_mob.key = M.key
					qdel(M)
				..()
				return

		inaprovaline
			name = "Inaprovaline"
			id = "inaprovaline"
			description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
			reagent_state = LIQUID
			color = "#00BFFF" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE*2
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(!M) M = holder.my_atom

				if(alien && alien == IS_VOX)
					M.adjustToxLoss(REAGENTS_METABOLISM)
				else
					if(M.losebreath >= 10)
						M.losebreath = max(10, M.losebreath-5)

				holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
				return

		space_drugs
			name = "Space drugs"
			id = "space_drugs"
			description = "An illegal chemical compound used as drug."
			reagent_state = LIQUID
			color = "#60A584" // rgb: 96, 165, 132
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(isturf(M.loc) && !istype(M.loc, /turf/space))
					if(M.canmove && !M.restrained())
						if(prob(10)) step(M, pick(cardinal))
				if(prob(7)) M.emote(pick("twitch","drool","moan","giggle"))
				holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
				return

		serotrotium
			name = "Serotrotium"
			id = "serotrotium"
			description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
			reagent_state = LIQUID
			color = "#202040" // rgb: 20, 20, 40
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(ishuman(M))
					if(prob(7)) M.emote(pick("twitch","drool","moan","gasp"))
					holder.remove_reagent(src.id, 0.25 * REAGENTS_METABOLISM)
				return

		silicate
			name = "Silicate"
			id = "silicate"
			description = "A compound that can be used to reinforce glass."
			reagent_state = LIQUID
			color = "#C7FFFF" // rgb: 199, 255, 255

			reaction_obj(var/obj/O, var/volume)
				src = null
				if(istype(O,/obj/structure/window))
					var/obj/structure/window/W = O
					W.apply_silicate(volume)
				return

		oxygen
			name = "Oxygen"
			id = "oxygen"
			description = "A colorless, odorless gas."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2) return
				if(alien && alien == IS_VOX)
					M.adjustToxLoss(REAGENTS_METABOLISM)
					holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
					return
				..()

		copper
			name = "Copper"
			id = "copper"
			description = "A highly ductile metal."
			color = "#6E3B08" // rgb: 110, 59, 8

			custom_metabolism = 0.01

		nitrogen
			name = "Nitrogen"
			id = "nitrogen"
			description = "A colorless, odorless, tasteless gas."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2) return
				if(alien && alien == IS_VOX)
					M.adjustOxyLoss(-2*REM)
					holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
					return
				..()

		hydrogen
			name = "Hydrogen"
			id = "hydrogen"
			description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

		potassium
			name = "Potassium"
			id = "potassium"
			description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
			reagent_state = SOLID
			color = "#A0A0A0" // rgb: 160, 160, 160

			custom_metabolism = 0.01

		mercury
			name = "Mercury"
			id = "mercury"
			description = "A chemical element."
			reagent_state = LIQUID
			color = "#484848" // rgb: 72, 72, 72
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
					step(M, pick(cardinal))
				if(prob(5)) M.emote(pick("twitch","drool","moan"))
				M.adjustBrainLoss(2)
				..()
				return

		sulfur
			name = "Sulfur"
			id = "sulfur"
			description = "A chemical element with a pungent smell."
			reagent_state = SOLID
			color = "#BF8C00" // rgb: 191, 140, 0

			custom_metabolism = 0.01

		carbon
			name = "Carbon"
			id = "carbon"
			description = "A chemical element, the builing block of life."
			reagent_state = SOLID
			color = "#1C1300" // rgb: 30, 20, 0

			custom_metabolism = 0.01

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(!istype(T, /turf/space))
					var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, T)
					if (!dirtoverlay)
						dirtoverlay = new/obj/effect/decal/cleanable/dirt(T)
						dirtoverlay.alpha = volume*30
					else
						dirtoverlay.alpha = min(dirtoverlay.alpha+volume*30, 255)

		chlorine
			name = "Chlorine"
			id = "chlorine"
			description = "A chemical element with a characteristic odour."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.take_organ_damage(1*REM, 0)
				..()
				return

		fluorine
			name = "Fluorine"
			id = "fluorine"
			description = "A highly-reactive chemical element."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1*REM)
				..()
				return

		sodium
			name = "Sodium"
			id = "sodium"
			description = "A chemical element, readily reacts with water."
			reagent_state = SOLID
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

		phosphorus
			name = "Phosphorus"
			id = "phosphorus"
			description = "A chemical element, the backbone of biological energy carriers."
			reagent_state = SOLID
			color = "#832828" // rgb: 131, 40, 40

			custom_metabolism = 0.01

		lithium
			name = "Lithium"
			id = "lithium"
			description = "A chemical element, used as antidepressant."
			reagent_state = SOLID
			color = "#808080" // rgb: 128, 128, 128
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
					step(M, pick(cardinal))
				if(prob(5)) M.emote(pick("twitch","drool","moan"))
				..()
				return

		sugar
			name = "Sugar"
			id = "sugar"
			description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
			reagent_state = SOLID
			color = "#FFFFFF" // rgb: 255, 255, 255

			glass_icon_state = "iceglass"
			glass_name = "glass of sugar"
			glass_desc = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += 1*REM
				..()
				return


		glycerol
			name = "Glycerol"
			id = "glycerol"
			description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
			reagent_state = LIQUID
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

		nitroglycerin
			name = "Nitroglycerin"
			id = "nitroglycerin"
			description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
			reagent_state = LIQUID
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

		radium
			name = "Radium"
			id = "radium"
			description = "Radium is an alkaline earth metal. It is extremely radioactive."
			reagent_state = SOLID
			color = "#C7C7C7" // rgb: 199,199,199

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.apply_effect(2*REM,IRRADIATE,0)
				// radium may increase your chances to cure a disease
				if(istype(M,/mob/living/carbon)) // make sure to only use it on carbon mobs
					var/mob/living/carbon/C = M
					if(C.virus2.len)
						for (var/ID in C.virus2)
							var/datum/disease2/disease/V = C.virus2[ID]
							if(prob(5))
								C.antibodies |= V.antigen
								if(prob(50))
									M.radiation += 50 // curing it that way may kill you instead
									var/absorbed
									var/obj/item/organ/diona/nutrients/rad_organ = locate() in C.internal_organs
									if(rad_organ && !rad_organ.is_broken())
										absorbed = 1
									if(!absorbed)
										M.adjustToxLoss(100)
				..()
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 3)
					if(!istype(T, /turf/space))
						var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
						if(!glow)
							new /obj/effect/decal/cleanable/greenglow(T)
						return


		ryetalyn
			name = "Ryetalyn"
			id = "ryetalyn"
			description = "Ryetalyn can cure all genetic abnomalities via a catalytic process."
			reagent_state = SOLID
			color = "#004000" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom

				var/needs_update = M.mutations.len > 0

				M.mutations = list()
				M.disabilities = 0
				M.sdisabilities = 0

				// Might need to update appearance for hulk etc.
				if(needs_update && ishuman(M))
					var/mob/living/carbon/human/H = M
					H.update_mutations()

				..()
				return

		thermite
			name = "Thermite"
			id = "thermite"
			description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
			reagent_state = SOLID
			color = "#673910" // rgb: 103, 57, 16

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 5)
					if(istype(T, /turf/simulated/wall))
						var/turf/simulated/wall/W = T
						W.thermite = 1
						W.overlays += image('icons/effects/effects.dmi',icon_state = "#673910")
				return

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustFireLoss(1)
				..()
				return

		paracetamol
			name = "Paracetamol"
			id = "paracetamol"
			description = "Most probably know this as Tylenol, but this chemical is a mild, simple painkiller."
			reagent_state = LIQUID
			color = "#C8A5DC"
			overdose = 60
			scannable = 1
			custom_metabolism = 0.025 // Lasts 10 minutes for 15 units

			on_mob_life(var/mob/living/M as mob)
				if (volume > overdose)
					M.hallucination = max(M.hallucination, 2)
				..()
				return

		tramadol
			name = "Tramadol"
			id = "tramadol"
			description = "A simple, yet effective painkiller."
			reagent_state = LIQUID
			color = "#CB68FC"
			overdose = 30
			scannable = 1
			custom_metabolism = 0.025 // Lasts 10 minutes for 15 units

			on_mob_life(var/mob/living/M as mob)
				if (volume > overdose)
					M.hallucination = max(M.hallucination, 2)
				..()
				return

		oxycodone
			name = "Oxycodone"
			id = "oxycodone"
			description = "An effective and very addictive painkiller."
			reagent_state = LIQUID
			color = "#800080"
			overdose = 20
			custom_metabolism = 0.25 // Lasts 10 minutes for 15 units

			on_mob_life(var/mob/living/M as mob)
				if (volume > overdose)
					M.druggy = max(M.druggy, 10)
					M.hallucination = max(M.hallucination, 3)
				..()
				return


		virus_food
			name = "Virus Food"
			id = "virusfood"
			description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
			reagent_state = LIQUID
			nutriment_factor = 2 * REAGENTS_METABOLISM
			color = "#899613" // rgb: 137, 150, 19

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.nutrition += nutriment_factor*REM
				..()
				return

		sterilizine
			name = "Sterilizine"
			id = "sterilizine"
			description = "Sterilizes wounds in preparation for surgery."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			//makes you squeaky clean
			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if (method == TOUCH)
					M.germ_level -= min(volume*20, M.germ_level)

			reaction_obj(var/obj/O, var/volume)
				O.germ_level -= min(volume*20, O.germ_level)

			reaction_turf(var/turf/T, var/volume)
				T.germ_level -= min(volume*20, T.germ_level)

	/*		reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				src = null
				if (method==TOUCH)
					if(istype(M, /mob/living/carbon/human))
						if(M.health >= -100 && M.health <= 0)
							M.crit_op_stage = 0.0
				if (method==INGEST)
					usr << "Well, that was stupid."
					M.adjustToxLoss(3)
				return
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
					M.radiation += 3
					..()
					return
	*/
		iron
			name = "Iron"
			id = "iron"
			description = "Pure iron is a metal."
			reagent_state = SOLID
			color = "#353535"
			overdose = REAGENTS_OVERDOSE

		gold
			name = "Gold"
			id = "gold"
			description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
			reagent_state = SOLID
			color = "#F7C430" // rgb: 247, 196, 48

		silver
			name = "Silver"
			id = "silver"
			description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
			reagent_state = SOLID
			color = "#D0D0D0" // rgb: 208, 208, 208

		uranium
			name ="Uranium"
			id = "uranium"
			description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
			reagent_state = SOLID
			color = "#B8B8C0" // rgb: 184, 184, 192

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.apply_effect(1,IRRADIATE,0)
				..()
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 3)
					if(!istype(T, /turf/space))
						var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
						if(!glow)
							new /obj/effect/decal/cleanable/greenglow(T)
						return

		aluminum
			name = "Aluminum"
			id = "aluminum"
			description = "A silvery white and ductile member of the boron group of chemical elements."
			reagent_state = SOLID
			color = "#A8A8A8" // rgb: 168, 168, 168

		silicon
			name = "Silicon"
			id = "silicon"
			description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
			reagent_state = SOLID
			color = "#A8A8A8" // rgb: 168, 168, 168

		fuel
			name = "Welding fuel"
			id = "fuel"
			description = "Required for welders. Flamable."
			reagent_state = LIQUID
			color = "#660000" // rgb: 102, 0, 0
			overdose = REAGENTS_OVERDOSE

			glass_icon_state = "dr_gibb_glass"
			glass_name = "glass of welder fuel"
			glass_desc = "Unless you are an industrial tool, this is probably not safe for consumption."

			reaction_obj(var/obj/O, var/volume)
				var/turf/the_turf = get_turf(O)
				if(!the_turf)
					return //No sense trying to start a fire if you don't have a turf to set on fire. --NEO
				new /obj/effect/decal/cleanable/liquid_fuel(the_turf, volume)
			reaction_turf(var/turf/T, var/volume)
				new /obj/effect/decal/cleanable/liquid_fuel(T, volume)
				return
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1)
				..()
				return
			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with welding fuel to make them easy to ignite!
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					M.adjust_fire_stacks(volume / 10)
					return

		space_cleaner
			name = "Space cleaner"
			id = "cleaner"
			description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
			reagent_state = LIQUID
			color = "#A5F0EE" // rgb: 165, 240, 238
			overdose = REAGENTS_OVERDOSE

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/effect/decal/cleanable))
					qdel(O)
				else
					if(O)
						O.clean_blood()

			reaction_turf(var/turf/T, var/volume)
				if(volume >= 1)
					if(istype(T, /turf/simulated))
						var/turf/simulated/S = T
						S.dirt = 0
					T.clean_blood()
					for(var/obj/effect/decal/cleanable/C in T.contents)
						src.reaction_obj(C, volume)
						qdel(C)

					for(var/mob/living/carbon/slime/M in T)
						M.adjustToxLoss(rand(5,10))

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					if(C.r_hand)
						C.r_hand.clean_blood()
					if(C.l_hand)
						C.l_hand.clean_blood()
					if(C.wear_mask)
						if(C.wear_mask.clean_blood())
							C.update_inv_wear_mask(0)
					if(ishuman(M))
						var/mob/living/carbon/human/H = C
						if(H.head)
							if(H.head.clean_blood())
								H.update_inv_head(0)
						if(H.wear_suit)
							if(H.wear_suit.clean_blood())
								H.update_inv_wear_suit(0)
						else if(H.w_uniform)
							if(H.w_uniform.clean_blood())
								H.update_inv_w_uniform(0)
						if(H.shoes)
							if(H.shoes.clean_blood())
								H.update_inv_shoes(0)
						else
							H.clean_blood(1)
							return
					M.clean_blood()

		leporazine
			name = "Leporazine"
			id = "leporazine"
			description = "Leporazine can be use to stabilize an individuals body temperature."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
				else if(M.bodytemperature < 311)
					M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
				..()
				return

		cryptobiolin
			name = "Cryptobiolin"
			id = "cryptobiolin"
			description = "Cryptobiolin causes confusion and dizzyness."
			reagent_state = LIQUID
			color = "#000055" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.make_dizzy(1)
				if(!M.confused) M.confused = 1
				M.confused = max(M.confused, 20)
				holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
				..()
				return


		kelotane
			name = "Kelotane"
			id = "kelotane"
			description = "Kelotane is a drug used to treat burns."
			reagent_state = LIQUID
			color = "#FFA800" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				//This needs a diona check but if one is added they won't be able to heal burn damage at all.
				M.heal_organ_damage(0,2*REM)
				..()
				return

		dermaline
			name = "Dermaline"
			id = "dermaline"
			description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
			reagent_state = LIQUID
			color = "#FF8000" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE/2
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2.0) //THE GUY IS **DEAD**! BEREFT OF ALL LIFE HE RESTS IN PEACE etc etc. He does NOT metabolise shit anymore, god DAMN
					return
				if(!M) M = holder.my_atom
				if(!alien || alien != IS_DIONA)
					M.heal_organ_damage(0,3*REM)
				..()
				return

		dexalin
			name = "Dexalin"
			id = "dexalin"
			description = "Dexalin is used in the treatment of oxygen deprivation."
			reagent_state = LIQUID
			color = "#0080FF" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2.0)
					return  //See above, down and around. --Agouri
				if(!M) M = holder.my_atom

				if(alien && alien == IS_VOX)
					M.adjustToxLoss(2*REM)
				else if(!alien || alien != IS_DIONA)
					M.adjustOxyLoss(-2*REM)

				holder.remove_reagent("lexorin", 2*REM)
				..()
				return

		dexalinp
			name = "Dexalin Plus"
			id = "dexalinp"
			description = "Dexalin Plus is used in the treatment of oxygen deprivation. It is highly effective."
			reagent_state = LIQUID
			color = "#0040FF" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE/2
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom

				if(alien && alien == IS_VOX)
					M.adjustOxyLoss()
				else if(!alien || alien != IS_DIONA)
					M.adjustOxyLoss(-M.getOxyLoss())

				holder.remove_reagent("lexorin", 2*REM)
				..()
				return

		tricordrazine
			name = "Tricordrazine"
			id = "tricordrazine"
			description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
			reagent_state = LIQUID
			color = "#8040FF" // rgb: 200, 165, 220
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(!alien || alien != IS_DIONA)
					if(M.getOxyLoss()) M.adjustOxyLoss(-1*REM)
					if(M.getBruteLoss() && prob(80)) M.heal_organ_damage(1*REM,0)
					if(M.getFireLoss() && prob(80)) M.heal_organ_damage(0,1*REM)
					if(M.getToxLoss() && prob(80)) M.adjustToxLoss(-1*REM)
				..()
				return

		anti_toxin
			name = "Dylovene"
			id = "anti_toxin"
			description = "Dylovene is a broad-spectrum antitoxin."
			reagent_state = LIQUID
			color = "#00A000" // rgb: 200, 165, 220
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(!M) M = holder.my_atom
				if(!alien || alien != IS_DIONA)
					M.reagents.remove_all_type(/datum/reagent/toxin, 1*REM, 0, 1)
					M.drowsyness = max(M.drowsyness-2*REM, 0)
					M.hallucination = max(0, M.hallucination - 5*REM)
					M.adjustToxLoss(-2*REM)
				..()
				return

		adminordrazine //An OP chemical for admins
			name = "Adminordrazine"
			id = "adminordrazine"
			description = "It's magic. We don't have to explain it."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			glass_icon_state = "golden_cup"
			glass_name = "golden cup"
			glass_desc = "It's magic. We don't have to explain it."

			on_mob_life(var/mob/living/carbon/M as mob)
				if(!M) M = holder.my_atom ///This can even heal dead people.
				M.reagents.remove_all_type(/datum/reagent/toxin, 5*REM, 0, 1)
				M.setCloneLoss(0)
				M.setOxyLoss(0)
				M.radiation = 0
				M.heal_organ_damage(5,5)
				M.adjustToxLoss(-5)
				M.hallucination = 0
				M.setBrainLoss(0)
				M.disabilities = 0
				M.sdisabilities = 0
				M.eye_blurry = 0
				M.eye_blind = 0
				M.SetWeakened(0)
				M.SetStunned(0)
				M.SetParalysis(0)
				M.silent = 0
				M.dizziness = 0
				M.drowsyness = 0
				M.stuttering = 0
				M.confused = 0
				M.sleeping = 0
				M.jitteriness = 0
				for(var/datum/disease/D in M.viruses)
					D.spread = "Remissive"
					D.stage--
					if(D.stage < 1)
						D.cure()
				..()
				return
		synaptizine

			name = "Synaptizine"
			id = "synaptizine"
			description = "Synaptizine is used to treat various diseases."
			reagent_state = LIQUID
			color = "#99CCFF" // rgb: 200, 165, 220
			custom_metabolism = 0.01
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.drowsyness = max(M.drowsyness-5, 0)
				M.AdjustParalysis(-1)
				M.AdjustStunned(-1)
				M.AdjustWeakened(-1)
				holder.remove_reagent("mindbreaker", 5)
				M.hallucination = max(0, M.hallucination - 10)
				if(prob(60))	M.adjustToxLoss(1)
				..()
				return

		impedrezene
			name = "Impedrezene"
			id = "impedrezene"
			description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.jitteriness = max(M.jitteriness-5,0)
				if(prob(80)) M.adjustBrainLoss(1*REM)
				if(prob(50)) M.drowsyness = max(M.drowsyness, 3)
				if(prob(10)) M.emote("drool")
				..()
				return

		hyronalin
			name = "Hyronalin"
			id = "hyronalin"
			description = "Hyronalin is a medicinal drug used to counter the effect of radiation poisoning."
			reagent_state = LIQUID
			color = "#408000" // rgb: 200, 165, 220
			custom_metabolism = 0.05
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.radiation = max(M.radiation-3*REM,0)
				..()
				return

		arithrazine
			name = "Arithrazine"
			id = "arithrazine"
			description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
			reagent_state = LIQUID
			color = "#008000" // rgb: 200, 165, 220
			custom_metabolism = 0.05
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return  //See above, down and around. --Agouri
				if(!M) M = holder.my_atom
				M.radiation = max(M.radiation-7*REM,0)
				M.adjustToxLoss(-1*REM)
				if(prob(15))
					M.take_organ_damage(1, 0)
				..()
				return

		alkysine
			name = "Alkysine"
			id = "alkysine"
			description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
			reagent_state = LIQUID
			color = "#FFFF66" // rgb: 200, 165, 220
			custom_metabolism = 0.05
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustBrainLoss(-3*REM)
				..()
				return

		imidazoline
			name = "Imidazoline"
			id = "imidazoline"
			description = "Heals eye damage"
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.eye_blurry = max(M.eye_blurry-5 , 0)
				M.eye_blind = max(M.eye_blind-5 , 0)
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					var/obj/item/organ/eyes/E = H.internal_organs_by_name["eyes"]
					if(E && istype(E))
						if(E.damage > 0)
							E.damage = max(E.damage - 1, 0)
				..()
				return

		peridaxon
			name = "Peridaxon"
			id = "peridaxon"
			description = "Used to encourage recovery of internal organs and nervous systems. Medicate cautiously."
			reagent_state = LIQUID
			color = "#561EC3" // rgb: 200, 165, 220
			overdose = 10
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(ishuman(M))
					var/mob/living/carbon/human/H = M

					//Peridaxon heals only non-robotic organs
					for(var/obj/item/organ/I in H.internal_organs)
						if((I.damage > 0) && (I.robotic != 2))
							I.damage = max(I.damage - 0.20, 0)
				..()
				return

		bicaridine
			name = "Bicaridine"
			id = "bicaridine"
			description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
			reagent_state = LIQUID
			color = "#BF0000" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(alien != IS_DIONA)
					M.heal_organ_damage(2*REM,0)
				..()
				return

		hyperzine
			name = "Hyperzine"
			id = "hyperzine"
			description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
			reagent_state = LIQUID
			color = "#FF3300" // rgb: 200, 165, 220
			custom_metabolism = 0.03
			overdose = REAGENTS_OVERDOSE/2

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(prob(5)) M.emote(pick("twitch","blink_r","shiver"))
				..()
				return

		adrenaline
			name = "Adrenaline"
			id = "adrenaline"
			description = "Adrenaline is a hormone used as a drug to treat cardiac arrest and other cardiac dysrhythmias resulting in diminished or absent cardiac output."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.SetParalysis(0)
				M.SetWeakened(0)
				M.adjustToxLoss(rand(3))
				..()
				return

		cryoxadone
			name = "Cryoxadone"
			id = "cryoxadone"
			description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
			reagent_state = LIQUID
			color = "#8080FF" // rgb: 200, 165, 220
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 170)
					M.adjustCloneLoss(-1)
					M.adjustOxyLoss(-1)
					M.heal_organ_damage(1,1)
					M.adjustToxLoss(-1)
				..()
				return

		clonexadone
			name = "Clonexadone"
			id = "clonexadone"
			description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' the cloning process when used in conjunction with a cryo tube."
			reagent_state = LIQUID
			color = "#80BFFF" // rgb: 200, 165, 220
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 170)
					M.adjustCloneLoss(-3)
					M.adjustOxyLoss(-3)
					M.heal_organ_damage(3,3)
					M.adjustToxLoss(-3)
				..()
				return

		rezadone
			name = "Rezadone"
			id = "rezadone"
			description = "A powder derived from fish toxin, this substance can effectively treat genetic damage in humanoids, though excessive consumption has side effects."
			reagent_state = SOLID
			color = "#669900" // rgb: 102, 153, 0
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				data++
				switch(data)
					if(1 to 15)
						M.adjustCloneLoss(-1)
						M.heal_organ_damage(1,1)
					if(15 to 35)
						M.adjustCloneLoss(-2)
						M.heal_organ_damage(2,1)
						M.status_flags &= ~DISFIGURED
					if(35 to INFINITY)
						M.adjustToxLoss(1)
						M.make_dizzy(5)
						M.make_jittery(5)

				..()
				return

		spaceacillin
			name = "Spaceacillin"
			id = "spaceacillin"
			description = "An all-purpose antiviral agent."
			reagent_state = LIQUID
			color = "#C1C1C1" // rgb: 200, 165, 220
			custom_metabolism = 0.01
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				..()
				return


///////////////////////////////////////////////////////////////////////////////////////////////////////////////

		nanites
			name = "Nanomachines"
			id = "nanites"
			description = "Microscopic construction robots."
			reagent_state = LIQUID
			color = "#535E66" // rgb: 83, 94, 102

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if( (prob(10) && method==TOUCH) || method==INGEST)
					M.contract_disease(new /datum/disease/robotic_transformation(0),1)

		xenomicrobes
			name = "Xenomicrobes"
			id = "xenomicrobes"
			description = "Microbes with an entirely alien cellular structure."
			reagent_state = LIQUID
			color = "#535E66" // rgb: 83, 94, 102

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if( (prob(10) && method==TOUCH) || method==INGEST)
					M.contract_disease(new /datum/disease/xeno_transformation(0),1)

		fluorosurfactant//foam precursor
			name = "Fluorosurfactant"
			id = "fluorosurfactant"
			description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
			reagent_state = LIQUID
			color = "#9E6B38" // rgb: 158, 107, 56

		foaming_agent// Metal foaming agent. This is lithium hydride. Add other recipes (e.g. LiH + H2O -> LiOH + H2) eventually.
			name = "Foaming agent"
			id = "foaming_agent"
			description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
			reagent_state = SOLID
			color = "#664B63" // rgb: 102, 75, 99

		nicotine
			name = "Nicotine"
			id = "nicotine"
			description = "A highly addictive stimulant extracted from the tobacco plant."
			reagent_state = LIQUID
			color = "#181818" // rgb: 24, 24, 24

		ammonia
			name = "Ammonia"
			id = "ammonia"
			description = "A caustic substance commonly used in fertilizer or household cleaners."
			reagent_state = GAS
			color = "#404030" // rgb: 64, 64, 48

		ultraglue
			name = "Ultra Glue"
			id = "glue"
			description = "An extremely powerful bonding agent."
			color = "#FFFFCC" // rgb: 255, 255, 204

		diethylamine
			name = "Diethylamine"
			id = "diethylamine"
			description = "A secondary amine, mildly corrosive."
			reagent_state = LIQUID
			color = "#604030" // rgb: 96, 64, 48

		ethylredoxrazine	// FUCK YOU, ALCOHOL
			name = "Ethylredoxrazine"
			id = "ethylredoxrazine"
			description = "A powerful oxidizer that reacts with ethanol."
			reagent_state = SOLID
			color = "#605048" // rgb: 96, 80, 72
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.dizziness = 0
				M.drowsyness = 0
				M.stuttering = 0
				M.confused = 0
				M.reagents.remove_all_type(/datum/reagent/ethanol, 1*REM, 0, 1)
				..()
				return

//////////////////////////Ground crayons/////////////////////


		crayon_dust
			name = "Crayon dust"
			id = "crayon_dust"
			description = "Intensely coloured powder obtained by grinding crayons."
			reagent_state = LIQUID
			color = "#888888"
			overdose = 5

			red
				name = "Red crayon dust"
				id = "crayon_dust_red"
				color = "#FE191A"

			orange
				name = "Orange crayon dust"
				id = "crayon_dust_orange"
				color = "#FFBE4F"

			yellow
				name = "Yellow crayon dust"
				id = "crayon_dust_yellow"
				color = "#FDFE7D"

			green
				name = "Green crayon dust"
				id = "crayon_dust_green"
				color = "#18A31A"

			blue
				name = "Blue crayon dust"
				id = "crayon_dust_blue"
				color = "#247CFF"

			purple
				name = "Purple crayon dust"
				id = "crayon_dust_purple"
				color = "#CC0099"

			grey //Mime
				name = "Grey crayon dust"
				id = "crayon_dust_grey"
				color = "#808080"

			brown //Rainbow
				name = "Brown crayon dust"
				id = "crayon_dust_brown"
				color = "#846F35"

//////////////////////////Paint//////////////////////////////

		paint
			name = "Paint"
			id = "paint"
			description = "This paint will stick to almost any object."
			reagent_state = LIQUID
			color = "#808080"
			overdose = 15
			color_weight = 20

			New()
				..()
				data = color

			reaction_turf(var/turf/T, var/volume)
				..()
				if(istype(T) && !istype(T, /turf/space))
					T.color = color

			reaction_obj(var/obj/O, var/volume)
				..()
				if(istype(O,/obj))
					O.color = color

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				..()
				if(istype(M,/mob) && !istype(M,/mob/dead))
					//painting ghosts: not allowed
					M.color = color

			on_merge(var/newdata, var/newamount)
				if(!data || !newdata)
					return
				var/list/colors = list(0, 0, 0, 0)
				var/tot_w = 0

				var/hex1 = uppertext(color)
				var/hex2 = uppertext(newdata)
				if(length(hex1) == 7)
					hex1 += "FF"
				if(length(hex2) == 7)
					hex2 += "FF"
				if(length(hex1) != 9 || length(hex2) != 9)
					return
				colors[1] += hex2num(copytext(hex1, 2, 4)) * volume
				colors[2] += hex2num(copytext(hex1, 4, 6)) * volume
				colors[3] += hex2num(copytext(hex1, 6, 8)) * volume
				colors[4] += hex2num(copytext(hex1, 8, 10)) * volume
				tot_w += volume
				colors[1] += hex2num(copytext(hex2, 2, 4)) * newamount
				colors[2] += hex2num(copytext(hex2, 4, 6)) * newamount
				colors[3] += hex2num(copytext(hex2, 6, 8)) * newamount
				colors[4] += hex2num(copytext(hex2, 8, 10)) * newamount
				tot_w += newamount

				color = rgb(colors[1] / tot_w, colors[2] / tot_w, colors[3] / tot_w, colors[4] / tot_w)
				data = color
				return


//////////////////////////Poison stuff///////////////////////

		toxin
			name = "Toxin"
			id = "toxin"
			description = "A toxic chemical."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0
			var/toxpwr = 0.7 // Toxins are really weak, but without being treated, last very long.
			custom_metabolism = 0.1

			on_mob_life(var/mob/living/M as mob,var/alien)
				if(!M) M = holder.my_atom
				if(toxpwr)
					M.adjustToxLoss(toxpwr*REM)
				if(alien) ..() // Kind of a catch-all for aliens without the liver. Because this does not metabolize 'naturally', only removed by the liver.
				return

		toxin/amatoxin
			name = "Amatoxin"
			id = "amatoxin"
			description = "A powerful poison derived from certain species of mushroom."
			reagent_state = LIQUID
			color = "#792300" // rgb: 121, 35, 0
			toxpwr = 1

		toxin/mutagen
			name = "Unstable mutagen"
			id = "mutagen"
			description = "Might cause unpredictable mutations. Keep away from children."
			reagent_state = LIQUID
			color = "#13BC5E" // rgb: 19, 188, 94
			toxpwr = 0

			reaction_mob(var/mob/living/carbon/M, var/method=TOUCH, var/volume)
				if(!..())	return
				if(!istype(M) || !M.dna)	return  //No robots, AIs, aliens, Ians or other mobs should be affected by this.
				src = null
				if((method==TOUCH && prob(33)) || method==INGEST)
					randmuti(M)
					if(prob(98))	randmutb(M)
					else			randmutg(M)
					domutcheck(M, null)
					M.UpdateAppearance()
				return
			on_mob_life(var/mob/living/carbon/M)
				if(!istype(M))	return
				if(!M) M = holder.my_atom
				M.apply_effect(10,IRRADIATE,0)
				..()
				return

		toxin/phoron
			name = "Phoron"
			id = "phoron"
			description = "Phoron in its liquid form."
			reagent_state = LIQUID
			color = "#9D14DB"
			toxpwr = 3

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				holder.remove_reagent("inaprovaline", 2*REM)
				..()
				return
			reaction_obj(var/obj/O, var/volume)
				src = null
				/*if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg/slime))
					var/obj/item/weapon/reagent_containers/food/snacks/egg/slime/egg = O
					if (egg.grown)
						egg.Hatch()*/
				if((!O) || (!volume))	return 0
				var/turf/the_turf = get_turf(O)
				the_turf.assume_gas("volatile_fuel", volume, T20C)
			reaction_turf(var/turf/T, var/volume)
				src = null
				T.assume_gas("volatile_fuel", volume, T20C)
				return
			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with plasma is stronger than fuel!
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					M.adjust_fire_stacks(volume / 5)
					return

		toxin/lexorin
			name = "Lexorin"
			id = "lexorin"
			description = "Lexorin temporarily stops respiration. Causes tissue damage."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			toxpwr = 0
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(prob(33))
					M.take_organ_damage(1*REM, 0)
				if(M.losebreath < 15)
					M.losebreath++
				..()
				return

		toxin/slimejelly
			name = "Slime Jelly"
			id = "slimejelly"
			description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
			reagent_state = LIQUID
			color = "#801E28" // rgb: 128, 30, 40
			toxpwr = 0

			on_mob_life(var/mob/living/M as mob)
				if(prob(10))
					M << "\red Your insides are burning!"
					M.adjustToxLoss(rand(20,60)*REM)
				else if(prob(40))
					M.heal_organ_damage(5*REM,0)
				..()
				return

		toxin/cyanide //Fast and Lethal
			name = "Cyanide"
			id = "cyanide"
			description = "A highly toxic chemical."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0
			toxpwr = 4
			custom_metabolism = 0.4

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustOxyLoss(4*REM)
				M.sleeping += 1
				..()
				return

		toxin/minttoxin
			name = "Mint Toxin"
			id = "minttoxin"
			description = "Useful for dealing with undesirable customers."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0
			toxpwr = 0

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if (FAT in M.mutations)
					M.gib()
				..()
				return

		toxin/carpotoxin
			name = "Carpotoxin"
			id = "carpotoxin"
			description = "A deadly neurotoxin produced by the dreaded space carp."
			reagent_state = LIQUID
			color = "#003333" // rgb: 0, 51, 51
			toxpwr = 2

		toxin/zombiepowder
			name = "Zombie Powder"
			id = "zombiepowder"
			description = "A strong neurotoxin that puts the subject into a death-like state."
			reagent_state = SOLID
			color = "#669900" // rgb: 102, 153, 0
			toxpwr = 0.5

			on_mob_life(var/mob/living/carbon/M as mob)
				if(!M) M = holder.my_atom
				M.status_flags |= FAKEDEATH
				M.adjustOxyLoss(0.5*REM)
				M.Weaken(10)
				M.silent = max(M.silent, 10)
				M.tod = worldtime2text()
				..()
				return

			Destroy()
				if(holder && ismob(holder.my_atom))
					var/mob/M = holder.my_atom
					M.status_flags &= ~FAKEDEATH
				..()

		toxin/mindbreaker
			name = "Mindbreaker Toxin"
			id = "mindbreaker"
			description = "A powerful hallucinogen, it can cause fatal effects in users."
			reagent_state = LIQUID
			color = "#B31008" // rgb: 139, 166, 233
			toxpwr = 0
			custom_metabolism = 0.05
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M)
				if(!M) M = holder.my_atom
				M.hallucination += 10
				..()
				return

		//Reagents used for plant fertilizers.
		toxin/fertilizer
			name = "fertilizer"
			id = "fertilizer"
			description = "A chemical mix good for growing plants with."
			reagent_state = LIQUID
			toxpwr = 0.2 //It's not THAT poisonous.
			color = "#664330" // rgb: 102, 67, 48

		toxin/fertilizer/eznutrient
			name = "EZ Nutrient"
			id = "eznutrient"

		toxin/fertilizer/left4zed
			name = "Left-4-Zed"
			id = "left4zed"

		toxin/fertilizer/robustharvest
			name = "Robust Harvest"
			id = "robustharvest"

		toxin/plantbgone
			name = "Plant-B-Gone"
			id = "plantbgone"
			description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
			reagent_state = LIQUID
			color = "#49002E" // rgb: 73, 0, 46
			toxpwr = 1

			// Clear off wallrot fungi
			reaction_turf(var/turf/T, var/volume)
				if(istype(T, /turf/simulated/wall))
					var/turf/simulated/wall/W = T
					if(W.rotting)
						W.rotting = 0
						for(var/obj/effect/E in W) if(E.name == "Wallrot") qdel(E)

						for(var/mob/O in viewers(W, null))
							O.show_message(text("\blue The fungi are completely dissolved by the solution!"), 1)

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/effect/alien/weeds/))
					var/obj/effect/alien/weeds/alien_weeds = O
					alien_weeds.health -= rand(15,35) // Kills alien weeds pretty fast
					alien_weeds.healthcheck()
				else if(istype(O,/obj/effect/plant))
					var/obj/effect/plant/plant = O
					plant.die_off()
				else if(istype(O,/obj/machinery/portable_atmospherics/hydroponics))
					var/obj/machinery/portable_atmospherics/hydroponics/tray = O

					if(tray.seed)
						tray.health -= rand(30,50)
						if(tray.pestlevel > 0)
							tray.pestlevel -= 2
						if(tray.weedlevel > 0)
							tray.weedlevel -= 3
						tray.toxins += 4
						tray.check_level_sanity()
						tray.update_icon()

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				src = null
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					if(!C.wear_mask) // If not wearing a mask
						C.adjustToxLoss(2) // 4 toxic damage per application, doubled for some reason
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.dna)
							if(H.species.flags & IS_PLANT) //plantmen take a LOT of damage
								H.adjustToxLoss(50)

		toxin/stoxin
			name = "Soporific"
			id = "stoxin"
			description = "An effective hypnotic used to treat insomnia."
			reagent_state = LIQUID
			color = "#009CA8" // rgb: 232, 149, 204
			toxpwr = 0
			custom_metabolism = 0.1
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(1 to 12)
						if(prob(5))	M.emote("yawn")
					if(12 to 15)
						M.eye_blurry = max(M.eye_blurry, 10)
					if(15 to 49)
						if(prob(50))
							M.Weaken(2)
						M.drowsyness = max(M.drowsyness, 20)
					if(50 to INFINITY)
						M.sleeping = max(M.sleeping, 20)
						M.drowsyness = max(M.drowsyness, 60)
				data++
				..()
				return

		toxin/chloralhydrate
			name = "Chloral Hydrate"
			id = "chloralhydrate"
			description = "A powerful sedative."
			reagent_state = SOLID
			color = "#000067" // rgb: 0, 0, 103
			toxpwr = 1
			custom_metabolism = 0.1 //Default 0.2
			overdose = 15
			overdose_dam = 5

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				data++
				switch(data)
					if(1)
						M.confused += 2
						M.drowsyness += 2
					if(2 to 20)
						M.Weaken(30)
						M.eye_blurry = max(M.eye_blurry, 10)
					if(20 to INFINITY)
						M.sleeping = max(M.sleeping, 30)
				..()
				return

		toxin/potassium_chloride
			name = "Potassium Chloride"
			id = "potassium_chloride"
			description = "A delicious salt that stops the heart when injected into cardiac muscle."
			reagent_state = SOLID
			color = "#FFFFFF" // rgb: 255,255,255
			toxpwr = 0
			overdose = 30

			on_mob_life(var/mob/living/carbon/M as mob)
				var/mob/living/carbon/human/H = M
				if(H.stat != 1)
					if (volume >= overdose)
						if(H.losebreath >= 10)
							H.losebreath = max(10, H.losebreath-10)
						H.adjustOxyLoss(2)
						H.Weaken(10)
				..()
				return

		toxin/potassium_chlorophoride
			name = "Potassium Chlorophoride"
			id = "potassium_chlorophoride"
			description = "A specific chemical based on Potassium Chloride to stop the heart for surgery. Not safe to eat!"
			reagent_state = SOLID
			color = "#FFFFFF" // rgb: 255,255,255
			toxpwr = 2
			overdose = 20

			on_mob_life(var/mob/living/carbon/M as mob)
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.stat != 1)
						if(H.losebreath >= 10)
							H.losebreath = max(10, M.losebreath-10)
						H.adjustOxyLoss(2)
						H.Weaken(10)
				..()
				return

		toxin/beer2	//disguised as normal beer for use by emagged brobots
			name = "Beer"
			id = "beer2"
			description = "An alcoholic beverage made from malted grains, hops, yeast, and water. The fermentation appears to be incomplete." //If the players manage to analyze this, they deserve to know something is wrong.
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0
			custom_metabolism = 0.15 // Sleep toxins should always be consumed pretty fast
			overdose = REAGENTS_OVERDOSE/2

			glass_icon_state = "beerglass"
			glass_name = "glass of beer"
			glass_desc = "A freezing pint of beer"
			glass_center_of_mass = list("x"=16, "y"=8)

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(1)
						M.confused += 2
						M.drowsyness += 2
					if(2 to 50)
						M.sleeping += 1
					if(51 to INFINITY)
						M.sleeping += 1
						M.adjustToxLoss((data - 50)*REM)
				data++
				..()
				return

		toxin/acid
			name = "Sulphuric acid"
			id = "sacid"
			description = "A very corrosive mineral acid with the molecular formula H2SO4."
			reagent_state = LIQUID
			color = "#DB5008" // rgb: 219, 80, 8
			toxpwr = 1
			var/meltprob = 10

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.take_organ_damage(0, 1*REM)
				..()
				return

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//magic numbers everywhere
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M

						if(H.head)
							if(prob(meltprob) && !H.head.unacidable)
								H << "<span class='danger'>Your headgear melts away but protects you from the acid!</span>"
								qdel(H.head)
								H.update_inv_head(0)
								H.update_hair(0)
							else
								H << "<span class='warning'>Your headgear protects you from the acid.</span>"
							return

						if(H.wear_mask)
							if(prob(meltprob) && !H.wear_mask.unacidable)
								H << "<span class='danger'>Your mask melts away but protects you from the acid!</span>"
								qdel (H.wear_mask)
								H.update_inv_wear_mask(0)
								H.update_hair(0)
							else
								H << "<span class='warning'>Your mask protects you from the acid.</span>"
							return

						if(H.glasses) //Doesn't protect you from the acid but can melt anyways!
							if(prob(meltprob) && !H.glasses.unacidable)
								H << "<span class='danger'>Your glasses melts away!</span>"
								qdel (H.glasses)
								H.update_inv_glasses(0)

					if(!M.unacidable)
						if(istype(M, /mob/living/carbon/human) && volume >= 10)
							var/mob/living/carbon/human/H = M
							var/obj/item/organ/external/affecting = H.get_organ("head")
							if(affecting)
								if(affecting.take_damage(4*toxpwr, 2*toxpwr))
									H.UpdateDamageIcon()
								if(prob(meltprob)) //Applies disfigurement
									if (!(H.species && (H.species.flags & NO_PAIN)))
										H.emote("scream")
									H.status_flags |= DISFIGURED
						else
							M.take_organ_damage(min(6*toxpwr, volume * toxpwr)) // uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
				else
					if(!M.unacidable)
						M.take_organ_damage(min(6*toxpwr, volume * toxpwr))

			reaction_obj(var/obj/O, var/volume)
				if((istype(O,/obj/item) || istype(O,/obj/effect/plant)) && prob(meltprob * 3))
					if(!O.unacidable)
						var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
						I.desc = "Looks like this was \an [O] some time ago."
						for(var/mob/M in viewers(5, O))
							M << "\red \the [O] melts."
						qdel(O)

		toxin/acid/polyacid
			name = "Polytrinic acid"
			id = "pacid"
			description = "Polytrinic acid is a an extremely corrosive chemical substance."
			reagent_state = LIQUID
			color = "#8E18A9" // rgb: 142, 24, 169
			toxpwr = 2
			meltprob = 30

/////////////////////////Food Reagents////////////////////////////
// Part of the food code. Nutriment is used instead of the old "heal_amt" code. Also is where all the food
// 	condiments, additives, and such go.
		nutriment
			name = "Nutriment"
			id = "nutriment"
			description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
			reagent_state = SOLID
			nutriment_factor = 15 * REAGENTS_METABOLISM
			color = "#664330" // rgb: 102, 67, 48

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(prob(50)) M.heal_organ_damage(1,0)
				M.nutrition += nutriment_factor	// For hunger and fatness
				..()
				return

		nutriment/protein // Bad for Skrell!
			name = "animal protein"
			id = "protein"
			color = "#440000"

			on_mob_life(var/mob/living/M, var/alien)
				if(alien && alien == IS_SKRELL)
					M.adjustToxLoss(0.5)
					M.nutrition -= nutriment_factor
				..()

		nutriment/egg // Also bad for skrell. Not a child of protein because it might mess up, not sure.
			name = "egg yolk"
			id = "egg"
			color = "#FFFFAA"

			on_mob_life(var/mob/living/M, var/alien)
				if(alien && alien == IS_SKRELL)
					M.adjustToxLoss(0.5)
					M.nutrition -= nutriment_factor
				..()

		lipozine
			name = "Lipozine" // The anti-nutriment.
			id = "lipozine"
			description = "A chemical compound that causes a powerful fat-burning reaction."
			reagent_state = LIQUID
			nutriment_factor = 10 * REAGENTS_METABOLISM
			color = "#BBEDA4" // rgb: 187, 237, 164
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.nutrition = max(M.nutrition - nutriment_factor, 0)
				M.overeatduration = 0
				if(M.nutrition < 0)//Prevent from going into negatives.
					M.nutrition = 0
				..()
				return

		soysauce
			name = "Soysauce"
			id = "soysauce"
			description = "A salty sauce made from the soy plant."
			reagent_state = LIQUID
			nutriment_factor = 2 * REAGENTS_METABOLISM
			color = "#792300" // rgb: 121, 35, 0

		ketchup
			name = "Ketchup"
			id = "ketchup"
			description = "Ketchup, catsup, whatever. It's tomato paste."
			reagent_state = LIQUID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			color = "#731008" // rgb: 115, 16, 8

		capsaicin
			name = "Capsaicin Oil"
			id = "capsaicin"
			description = "This is what makes chilis hot."
			reagent_state = LIQUID
			color = "#B31008" // rgb: 179, 16, 8

			on_mob_life(var/mob/living/M as mob)
				if(!M)
					M = holder.my_atom
				if(!data)
					data = 1
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.species && !(H.species.flags & (NO_PAIN | IS_SYNTHETIC)) )
						switch(data)
							if(1 to 2)
								H << "\red <b>Your insides feel uncomfortably hot !</b>"
							if(2 to 20)
								if(prob(5))
									H << "\red <b>Your insides feel uncomfortably hot !</b>"
							if(20 to INFINITY)
								H.apply_effect(2,AGONY,0)
								if(prob(5))
									H.visible_message("<span class='warning'>[H] [pick("dry heaves!","coughs!","splutters!")]</span>")
									H << "\red <b>You feel like your insides are burning !</b>"
				else if(istype(M, /mob/living/carbon/slime))
					M.bodytemperature += rand(10,25)
				holder.remove_reagent("frostoil", 5)
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				data++
				..()
				return

		condensedcapsaicin
			name = "Condensed Capsaicin"
			id = "condensedcapsaicin"
			description = "A chemical agent used for self-defense and in police work."
			reagent_state = LIQUID
			color = "#B31008" // rgb: 179, 16, 8

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					if(istype(M, /mob/living/carbon/human))
						var/mob/living/carbon/human/victim = M
						var/mouth_covered = 0
						var/eyes_covered = 0
						var/obj/item/safe_thing = null
						if( victim.wear_mask )
							if ( victim.wear_mask.flags & MASKCOVERSEYES )
								eyes_covered = 1
								safe_thing = victim.wear_mask
							if ( victim.wear_mask.flags & MASKCOVERSMOUTH )
								mouth_covered = 1
								safe_thing = victim.wear_mask
						if( victim.head )
							if ( victim.head.flags & MASKCOVERSEYES )
								eyes_covered = 1
								safe_thing = victim.head
							if ( victim.head.flags & MASKCOVERSMOUTH )
								mouth_covered = 1
								safe_thing = victim.head
						if(victim.glasses)
							eyes_covered = 1
							if ( !safe_thing )
								safe_thing = victim.glasses
						if ( eyes_covered && mouth_covered )
							victim << "\red Your [safe_thing] protects you from the pepperspray!"
							return
						else if ( eyes_covered )	// Reduced effects if partially protected
							victim << "\red Your [safe_thing] protect you from most of the pepperspray!"
							victim.eye_blurry = max(M.eye_blurry, 15)
							victim.eye_blind = max(M.eye_blind, 5)
							victim.Stun(5)
							victim.Weaken(5)
							//victim.Paralyse(10)
							//victim.drop_item()
							return
						else if ( mouth_covered ) // Mouth cover is better than eye cover
							victim << "\red Your [safe_thing] protects your face from the pepperspray!"
							if (!(victim.species && (victim.species.flags & NO_PAIN)))
								victim.emote("scream")
							victim.eye_blurry = max(M.eye_blurry, 5)
							return
						else // Oh dear :D
							if (!(victim.species && (victim.species.flags & NO_PAIN)))
								victim.emote("scream")
							victim << "\red You're sprayed directly in the eyes with pepperspray!"
							victim.eye_blurry = max(M.eye_blurry, 25)
							victim.eye_blind = max(M.eye_blind, 10)
							victim.Stun(5)
							victim.Weaken(5)
							//victim.Paralyse(10)
							//victim.drop_item()

			on_mob_life(var/mob/living/M as mob)
				if(!M)
					M = holder.my_atom
				if(!data)
					data = 1
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.species && !(H.species.flags & (NO_PAIN | IS_SYNTHETIC)) )
						switch(data)
							if(1)
								H << "\red <b>You feel like your insides are burning !</b>"
							if(2 to INFINITY)
								H.apply_effect(4,AGONY,0)
								if(prob(5))
									H.visible_message("<span class='warning'>[H] [pick("dry heaves!","coughs!","splutters!")]</span>")
									H << "\red <b>You feel like your insides are burning !</b>"
				else if(istype(M, /mob/living/carbon/slime))
					M.bodytemperature += rand(15,30)
				holder.remove_reagent("frostoil", 5)
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				data++
				..()
				return

		frostoil
			name = "Frost Oil"
			id = "frostoil"
			description = "A special oil that noticably chills the body. Extracted from Ice Peppers."
			reagent_state = LIQUID
			color = "#B31008" // rgb: 139, 166, 233

			on_mob_life(var/mob/living/M as mob)
				if(!M)
					M = holder.my_atom
				M.bodytemperature = max(M.bodytemperature - 10 * TEMPERATURE_DAMAGE_COEFFICIENT, 0)
				if(prob(1))
					M.emote("shiver")
				if(istype(M, /mob/living/carbon/slime))
					M.bodytemperature = max(M.bodytemperature - rand(10,20), 0)
				holder.remove_reagent("capsaicin", 5)
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				..()
				return

			reaction_turf(var/turf/simulated/T, var/volume)
				for(var/mob/living/carbon/slime/M in T)
					M.adjustToxLoss(rand(15,30))

		sodiumchloride
			name = "Table Salt"
			id = "sodiumchloride"
			description = "A salt made of sodium chloride. Commonly used to season food."
			reagent_state = SOLID
			color = "#FFFFFF" // rgb: 255,255,255
			overdose = REAGENTS_OVERDOSE

		blackpepper
			name = "Black Pepper"
			id = "blackpepper"
			description = "A powder ground from peppercorns. *AAAACHOOO*"
			reagent_state = SOLID
			// no color (ie, black)

		coco
			name = "Coco Powder"
			id = "coco"
			description = "A fatty, bitter paste made from coco beans."
			reagent_state = SOLID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return

		hot_coco // there's also drink/hot_coco for whatever reason
			name = "Hot Chocolate"
			id = "hot_coco"
			description = "Made with love! And cocoa beans."
			reagent_state = LIQUID
			nutriment_factor = 2 * REAGENTS_METABOLISM
			color = "#403010" // rgb: 64, 48, 16

			glass_icon_state  = "chocolateglass"
			glass_name = "glass of hot chocolate"
			glass_desc = "Made with love! And cocoa beans."

			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
				M.nutrition += nutriment_factor
				..()
				return

		psilocybin
			name = "Psilocybin"
			id = "psilocybin"
			description = "A strong psycotropic derived from certain species of mushroom."
			color = "#E700E7" // rgb: 231, 0, 231
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 30)
				if(!data) data = 1
				switch(data)
					if(1 to 5)
						if (!M.stuttering) M.stuttering = 1
						M.make_dizzy(5)
						if(prob(10)) M.emote(pick("twitch","giggle"))
					if(5 to 10)
						if (!M.stuttering) M.stuttering = 1
						M.make_jittery(10)
						M.make_dizzy(10)
						M.druggy = max(M.druggy, 35)
						if(prob(20)) M.emote(pick("twitch","giggle"))
					if (10 to INFINITY)
						if (!M.stuttering) M.stuttering = 1
						M.make_jittery(20)
						M.make_dizzy(20)
						M.druggy = max(M.druggy, 40)
						if(prob(30)) M.emote(pick("twitch","giggle"))
				holder.remove_reagent(src.id, 0.2)
				data++
				..()
				return

		sprinkles
			name = "Sprinkles"
			id = "sprinkles"
			description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#FF00FF" // rgb: 255, 0, 255

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				/*if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
					if(!M) M = holder.my_atom
					M.heal_organ_damage(1,1)
					M.nutrition += nutriment_factor
					..()
					return
				*/
				..()

/*	//removed because of meta bullshit. this is why we can't have nice things.
		syndicream
			name = "Cream filling"
			id = "syndicream"
			description = "Delicious cream filling of a mysterious origin. Tastes criminally good."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#AB7878" // rgb: 171, 120, 120

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				if(istype(M, /mob/living/carbon/human) && M.mind)
					if(M.mind.special_role)
						if(!M) M = holder.my_atom
						M.heal_organ_damage(1,1)
						M.nutrition += nutriment_factor
						..()
						return
				..()
*/
		cornoil
			name = "Corn Oil"
			id = "cornoil"
			description = "An oil derived from various types of corn."
			reagent_state = LIQUID
			nutriment_factor = 20 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return
			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return
				src = null
				if(volume >= 3)
					if(T.wet >= 1) return
					T.wet = 1
					if(T.wet_overlay)
						T.overlays -= T.wet_overlay
						T.wet_overlay = null
					T.wet_overlay = image('icons/effects/water.dmi',T,"wet_floor")
					T.overlays += T.wet_overlay

					spawn(800)
						if (!istype(T)) return
						if(T.wet >= 2) return
						T.wet = 0
						if(T.wet_overlay)
							T.overlays -= T.wet_overlay
							T.wet_overlay = null
				var/hotspot = (locate(/obj/fire) in T)
				if(hotspot)
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					qdel(hotspot)

		enzyme
			name = "Universal Enzyme"
			id = "enzyme"
			description = "A universal enzyme used in the preperation of certain chemicals and foods."
			reagent_state = LIQUID
			color = "#365E30" // rgb: 54, 94, 48
			overdose = REAGENTS_OVERDOSE

		dry_ramen
			name = "Dry Ramen"
			id = "dry_ramen"
			description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
			reagent_state = SOLID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return

		hot_ramen
			name = "Hot Ramen"
			id = "hot_ramen"
			description = "The noodles are boiled, the flavors are artificial, just like being back in school."
			reagent_state = LIQUID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))
				..()
				return

		hell_ramen
			name = "Hell Ramen"
			id = "hell_ramen"
			description = "The noodles are boiled, the flavors are artificial, just like being back in school."
			reagent_state = LIQUID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
				..()
				return

		flour
			name = "flour"
			id = "flour"
			description = "This is what you rub all over yourself to pretend to be a ghost."
			reagent_state = SOLID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#FFFFFF" // rgb: 0, 0, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(!istype(T, /turf/space))
					new /obj/effect/decal/cleanable/flour(T)

		rice
			name = "Rice"
			id = "rice"
			description = "Enjoy the great taste of nothing."
			reagent_state = SOLID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#FFFFFF" // rgb: 0, 0, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return

		cherryjelly
			name = "Cherry Jelly"
			id = "cherryjelly"
			description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#801E28" // rgb: 128, 30, 40

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

		drink
			name = "Drink"
			id = "drink"
			description = "Uh, some kind of drink."
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#E78108" // rgb: 231, 129, 8
			var/adj_dizzy = 0
			var/adj_drowsy = 0
			var/adj_sleepy = 0
			var/adj_temp = 0

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.nutrition += nutriment_factor
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				// Drinks should be used up faster than other reagents.
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				if (adj_dizzy) M.dizziness = max(0,M.dizziness + adj_dizzy)
				if (adj_drowsy)	M.drowsyness = max(0,M.drowsyness + adj_drowsy)
				if (adj_sleepy) M.sleeping = max(0,M.sleeping + adj_sleepy)
				if (adj_temp)
					if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
						M.bodytemperature = min(310, M.bodytemperature + (25 * TEMPERATURE_DAMAGE_COEFFICIENT))

				..()
				return

		drink/orangejuice
			name = "Orange juice"
			id = "orangejuice"
			description = "Both delicious AND rich in Vitamin C, what more do you need?"
			color = "#E78108" // rgb: 231, 129, 8

			glass_icon_state = "glass_orange"
			glass_name = "glass of orange juice"
			glass_desc = "Vitamins! Yay!"

			on_mob_life(var/mob/living/M as mob)
				..()
				if(M.getOxyLoss() && prob(30)) M.adjustOxyLoss(-1)
				return

		drink/tomatojuice
			name = "Tomato Juice"
			id = "tomatojuice"
			description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
			color = "#731008" // rgb: 115, 16, 8

			glass_icon_state = "glass_red"
			glass_name = "glass of tomato juice"
			glass_desc = "Are you sure this is tomato juice?"

			on_mob_life(var/mob/living/M as mob)
				..()
				if(M.getFireLoss() && prob(20)) M.heal_organ_damage(0,1)
				return

		drink/limejuice
			name = "Lime Juice"
			id = "limejuice"
			description = "The sweet-sour juice of limes."
			color = "#365E30" // rgb: 54, 94, 48

			glass_icon_state = "glass_green"
			glass_name = "glass of lime juice"
			glass_desc = "A glass of sweet-sour lime juice"

			on_mob_life(var/mob/living/M as mob)
				..()
				if(M.getToxLoss() && prob(20)) M.adjustToxLoss(-1*REM)
				return

		drink/carrotjuice
			name = "Carrot juice"
			id = "carrotjuice"
			description = "It is just like a carrot but without crunching."
			color = "#FF8C00" // rgb: 255, 140, 0

			glass_icon_state = "carrotjuice"
			glass_name = "glass of carrot juice"
			glass_desc = "It is just like a carrot but without crunching."

			on_mob_life(var/mob/living/M as mob)
				..()
				M.eye_blurry = max(M.eye_blurry-1 , 0)
				M.eye_blind = max(M.eye_blind-1 , 0)
				if(!data) data = 1
				switch(data)
					if(1 to 20)
						//nothing
					if(21 to INFINITY)
						if (prob(data-10))
							M.disabilities &= ~NEARSIGHTED
				data++
				return

		drink/berryjuice
			name = "Berry Juice"
			id = "berryjuice"
			description = "A delicious blend of several different kinds of berries."
			color = "#990066" // rgb: 153, 0, 102

			glass_icon_state = "berryjuice"
			glass_name = "glass of berry juice"
			glass_desc = "Berry juice. Or maybe it's jam. Who cares?"

		drink/grapejuice
			name = "Grape Juice"
			id = "grapejuice"
			description = "It's grrrrrape!"
			color = "#863333" // rgb: 134, 51, 51

			glass_icon_state = "grapejuice"
			glass_name = "glass of grape juice"
			glass_desc = "It's grrrrrape!"

		drink/grapesoda
			name = "Grape Soda"
			id = "grapesoda"
			description = "Grapes made into a fine drank."
			color = "#421C52" // rgb: 98, 57, 53
			adj_drowsy 	= 	-3

			glass_icon_state = "gsodaglass"
			glass_name = "glass of grape soda"
			glass_desc = "Looks like a delicious drink!"

		drink/poisonberryjuice
			name = "Poison Berry Juice"
			id = "poisonberryjuice"
			description = "A tasty juice blended from various kinds of very deadly and toxic berries."
			color = "#863353" // rgb: 134, 51, 83

			glass_icon_state = "poisonberryjuice"
			glass_name = "glass of poison berry juice"
			glass_desc = "A glass of deadly juice."

			on_mob_life(var/mob/living/M as mob)
				..()
				M.adjustToxLoss(1)
				return

		drink/watermelonjuice
			name = "Watermelon Juice"
			id = "watermelonjuice"
			description = "Delicious juice made from watermelon."
			color = "#B83333" // rgb: 184, 51, 51

			glass_icon_state = "glass_red"
			glass_name = "glass of watermelon juice"
			glass_desc = "Delicious juice made from watermelon."

		drink/lemonjuice
			name = "Lemon Juice"
			id = "lemonjuice"
			description = "This juice is VERY sour."
			color = "#AFAF00" // rgb: 175, 175, 0

			glass_icon_state = "lemonjuice"
			glass_name = "glass of lemon juice"
			glass_desc = "Sour..."

		drink/banana
			name = "Banana Juice"
			id = "banana"
			description = "The raw essence of a banana."
			color = "#C3AF00" // rgb: 195, 175, 0

			glass_icon_state = "banana"
			glass_name = "glass of banana juice"
			glass_desc = "The raw essence of a banana. HONK!"

		drink/nothing
			name = "Nothing"
			id = "nothing"
			description = "Absolutely nothing."

			glass_icon_state = "nothing"
			glass_name = "glass of nothing"
			glass_desc = "Absolutely nothing."

		drink/potato_juice
			name = "Potato Juice"
			id = "potato"
			description = "Juice of the potato. Bleh."
			nutriment_factor = 2 * FOOD_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			glass_icon_state = "glass_brown"
			glass_name = "glass of potato juice"
			glass_desc = "Juice from a potato. Bleh."

		drink/milk
			name = "Milk"
			id = "milk"
			description = "An opaque white liquid produced by the mammary glands of mammals."
			color = "#DFDFDF" // rgb: 223, 223, 223

			glass_icon_state = "glass_white"
			glass_name = "glass of milk"
			glass_desc = "White and nutritious goodness!"

			on_mob_life(var/mob/living/M as mob)
				if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
				holder.remove_reagent("capsaicin", 10*REAGENTS_METABOLISM)
				..()
				return

		drink/milk/soymilk
			name = "Soy Milk"
			id = "soymilk"
			description = "An opaque white liquid made from soybeans."
			color = "#DFDFC7" // rgb: 223, 223, 199

			glass_icon_state = "glass_white"
			glass_name = "glass of soy milk"
			glass_desc = "White and nutritious soy goodness!"

		drink/milk/cream
			name = "Cream"
			id = "cream"
			description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
			color = "#DFD7AF" // rgb: 223, 215, 175

			glass_icon_state = "glass_white"
			glass_name = "glass of cream"
			glass_desc = "Ewwww..."

		drink/grenadine
			name = "Grenadine Syrup"
			id = "grenadine"
			description = "Made in the modern day with proper pomegranate substitute. Who uses real fruit, anyways?"
			color = "#FF004F" // rgb: 255, 0, 79

			glass_icon_state = "grenadineglass"
			glass_name = "glass of grenadine syrup"
			glass_desc = "Sweet and tangy, a bar syrup used to add color or flavor to drinks."
			glass_center_of_mass = list("x"=17, "y"=6)

		drink/hot_coco
			name = "Hot Chocolate"
			id = "hot_coco"
			description = "Made with love! And cocoa beans."
			nutriment_factor = 2 * FOOD_METABOLISM
			color = "#403010" // rgb: 64, 48, 16
			adj_temp = 5

			glass_icon_state = "chocolateglass"
			glass_name = "glass of hot chocolate"
			glass_desc = "Made with love! And cocoa beans."

		drink/coffee
			name = "Coffee"
			id = "coffee"
			description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
			color = "#482000" // rgb: 72, 32, 0
			adj_dizzy = -5
			adj_drowsy = -3
			adj_sleepy = -2
			adj_temp = 25

			glass_icon_state = "hot_coffee"
			glass_name = "cup of coffee"
			glass_desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."

			on_mob_life(var/mob/living/M as mob)
				..()
				M.make_jittery(5)
				if(adj_temp > 0)
					holder.remove_reagent("frostoil", 10*REAGENTS_METABOLISM)

				holder.remove_reagent(src.id, 0.1)

		drink/coffee/icecoffee
			name = "Iced Coffee"
			id = "icecoffee"
			description = "Coffee and ice, refreshing and cool."
			color = "#102838" // rgb: 16, 40, 56
			adj_temp = -5

			glass_icon_state = "icedcoffeeglass"
			glass_name = "glass of iced coffee"
			glass_desc = "A drink to perk you up and refresh you!"

		drink/coffee/soy_latte
			name = "Soy Latte"
			id = "soy_latte"
			description = "A nice and tasty beverage while you are reading your hippie books."
			color = "#664300" // rgb: 102, 67, 0
			adj_sleepy = 0
			adj_temp = 5

			glass_icon_state = "soy_latte"
			glass_name = "glass of soy latte"
			glass_desc = "A nice and refrshing beverage while you are reading."
			glass_center_of_mass = list("x"=15, "y"=9)

			on_mob_life(var/mob/living/M as mob)
				..()
				M.sleeping = 0
				if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
				return

		drink/coffee/cafe_latte
			name = "Cafe Latte"
			id = "cafe_latte"
			description = "A nice, strong and tasty beverage while you are reading."
			color = "#664300" // rgb: 102, 67, 0
			adj_sleepy = 0
			adj_temp = 5

			glass_icon_state = "cafe_latte"
			glass_name = "glass of cafe latte"
			glass_desc = "A nice, strong and refreshing beverage while you are reading."
			glass_center_of_mass = list("x"=15, "y"=9)

			on_mob_life(var/mob/living/M as mob)
				..()
				M.sleeping = 0
				if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
				return

		drink/tea
			name = "Tea"
			id = "tea"
			description = "Tasty black tea, it has antioxidants, it's good for you!"
			color = "#101000" // rgb: 16, 16, 0
			adj_dizzy = -2
			adj_drowsy = -1
			adj_sleepy = -3
			adj_temp = 20

			glass_icon_state = "bigteacup"
			glass_name = "cup of tea"
			glass_desc = "Tasty black tea, it has antioxidants, it's good for you!"

			on_mob_life(var/mob/living/M as mob)
				..()
				if(M.getToxLoss() && prob(20))
					M.adjustToxLoss(-1)
				return

		drink/tea/icetea
			name = "Iced Tea"
			id = "icetea"
			description = "No relation to a certain rap artist/ actor."
			color = "#104038" // rgb: 16, 64, 56
			adj_temp = -5

			glass_icon_state = "icedteaglass"
			glass_name = "glass of iced tea"
			glass_desc = "No relation to a certain rap artist/ actor."
			glass_center_of_mass = list("x"=15, "y"=10)

		drink/cold
			name = "Cold drink"
			adj_temp = -5

		drink/cold/tonic
			name = "Tonic Water"
			id = "tonic"
			description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
			color = "#664300" // rgb: 102, 67, 0
			adj_dizzy = -5
			adj_drowsy = -3
			adj_sleepy = -2

			glass_icon_state = "glass_clear"
			glass_name = "glass of tonic water"
			glass_desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."

		drink/cold/sodawater
			name = "Soda Water"
			id = "sodawater"
			description = "A can of club soda. Why not make a scotch and soda?"
			color = "#619494" // rgb: 97, 148, 148
			adj_dizzy = -5
			adj_drowsy = -3

			glass_icon_state = "glass_clear"
			glass_name = "glass of soda water"
			glass_desc = "Soda water. Why not make a scotch and soda?"

		drink/cold/ice
			name = "Ice"
			id = "ice"
			description = "Frozen water, your dentist wouldn't like you chewing this."
			reagent_state = SOLID
			color = "#619494" // rgb: 97, 148, 148

			glass_icon_state = "iceglass"
			glass_name = "glass of ice"
			glass_desc = "Generally, you're supposed to put something else in there too..."

		drink/cold/space_cola
			name = "Space Cola"
			id = "cola"
			description = "A refreshing beverage."
			reagent_state = LIQUID
			color = "#100800" // rgb: 16, 8, 0
			adj_drowsy 	= 	-3

			glass_icon_state  = "glass_brown"
			glass_name = "glass of Space Cola"
			glass_desc = "A glass of refreshing Space Cola"

		drink/cold/nuka_cola
			name = "Nuka Cola"
			id = "nuka_cola"
			description = "Cola, cola never changes."
			color = "#100800" // rgb: 16, 8, 0
			adj_sleepy = -2

			glass_icon_state = "nuka_colaglass"
			glass_name = "glass of Nuka-Cola"
			glass_desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland"
			glass_center_of_mass = list("x"=16, "y"=6)

			on_mob_life(var/mob/living/M as mob)
				M.make_jittery(20)
				M.druggy = max(M.druggy, 30)
				M.dizziness +=5
				M.drowsyness = 0
				..()
				return

		drink/cold/spacemountainwind
			name = "Mountain Wind"
			id = "spacemountainwind"
			description = "Blows right through you like a space wind."
			color = "#102000" // rgb: 16, 32, 0
			adj_drowsy = -7
			adj_sleepy = -1

			glass_icon_state = "Space_mountain_wind_glass"
			glass_name = "glass of Space Mountain Wind"
			glass_desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."

		drink/cold/dr_gibb
			name = "Dr. Gibb"
			id = "dr_gibb"
			description = "A delicious blend of 42 different flavours"
			color = "#102000" // rgb: 16, 32, 0
			adj_drowsy = -6

			glass_icon_state = "dr_gibb_glass"
			glass_name = "glass of Dr. Gibb"
			glass_desc = "Dr. Gibb. Not as dangerous as the name might imply."

		drink/cold/space_up
			name = "Space-Up"
			id = "space_up"
			description = "Tastes like a hull breach in your mouth."
			color = "#202800" // rgb: 32, 40, 0
			adj_temp = -8

			glass_icon_state = "space-up_glass"
			glass_name = "glass of Space-up"
			glass_desc = "Space-up. It helps keep your cool."

		drink/cold/lemon_lime
			name = "Lemon Lime"
			description = "A tangy substance made of 0.5% natural citrus!"
			id = "lemon_lime"
			color = "#878F00" // rgb: 135, 40, 0
			adj_temp = -8

			glass_icon_state = "lemonlime"
			glass_name = "glass of lemon lime soda"
			glass_desc = "A tangy substance made of 0.5% natural citrus!"

		drink/cold/lemonade
			name = "Lemonade"
			description = "Oh the nostalgia..."
			id = "lemonade"
			color = "#FFFF00" // rgb: 255, 255, 0

			glass_icon_state = "lemonadeglass"
			glass_name = "glass of lemonade"
			glass_desc = "Oh the nostalgia..."

		drink/cold/kiraspecial
			name = "Kira Special"
			description = "Long live the guy who everyone had mistaken for a girl. Baka!"
			id = "kiraspecial"
			color = "#CCCC99" // rgb: 204, 204, 153

			glass_icon_state = "kiraspecial"
			glass_name = "glass of Kira Special"
			glass_desc = "Long live the guy who everyone had mistaken for a girl. Baka!"
			glass_center_of_mass = list("x"=16, "y"=12)

		drink/cold/brownstar
			name = "Brown Star"
			description = "It's not what it sounds like..."
			id = "brownstar"
			color = "#9F3400" // rgb: 159, 052, 000
			adj_temp = - 2

			glass_icon_state = "brownstar"
			glass_name = "glass of Brown Star"
			glass_desc = "It's not what it sounds like..."

		drink/cold/milkshake
			name = "Milkshake"
			description = "Glorious brainfreezing mixture."
			id = "milkshake"
			color = "#AEE5E4" // rgb" 174, 229, 228
			adj_temp = -9

			glass_icon_state = "milkshake"
			glass_name = "glass of milkshake"
			glass_desc = "Glorious brainfreezing mixture."
			glass_center_of_mass = list("x"=16, "y"=7)

			on_mob_life(var/mob/living/M as mob)
				if(!M)
					M = holder.my_atom
				if(prob(1))
					M.emote("shiver")
				M.bodytemperature = max(M.bodytemperature - 10 * TEMPERATURE_DAMAGE_COEFFICIENT, 0)
				if(istype(M, /mob/living/carbon/slime))
					M.bodytemperature = max(M.bodytemperature - rand(10,20), 0)
				holder.remove_reagent("capsaicin", 5)
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				..()
				return

		drink/cold/rewriter
			name = "Rewriter"
			description = "The secret of the sanctuary of the Libarian..."
			id = "rewriter"
			color = "#485000" // rgb:72, 080, 0

			glass_icon_state = "rewriter"
			glass_name = "glass of Rewriter"
			glass_desc = "The secret of the sanctuary of the Libarian..."
			glass_center_of_mass = list("x"=16, "y"=9)

			on_mob_life(var/mob/living/M as mob)
				..()
				M.make_jittery(5)
				return


		doctor_delight
			name = "The Doctor's Delight"
			id = "doctorsdelight"
			description = "A gulp a day keeps the MediBot away. That's probably for the best."
			reagent_state = LIQUID
			color = "#FF8CFF" // rgb: 255, 140, 255
			nutriment_factor = 1 * FOOD_METABOLISM

			glass_icon_state = "doctorsdelightglass"
			glass_name = "glass of The Doctor's Delight"
			glass_desc = "A healthy mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."
			glass_center_of_mass = list("x"=16, "y"=8)

			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				if(!M) M = holder.my_atom
				if(M:getOxyLoss() && prob(50)) M:adjustOxyLoss(-2)
				if(M:getBruteLoss() && prob(60)) M:heal_organ_damage(2,0)
				if(M:getFireLoss() && prob(50)) M:heal_organ_damage(0,2)
				if(M:getToxLoss() && prob(50)) M:adjustToxLoss(-2)
				if(M.dizziness !=0) M.dizziness = max(0,M.dizziness-15)
				if(M.confused !=0) M.confused = max(0,M.confused - 5)
				..()
				return

//////////////////////////////////////////////The ten friggen million reagents that get you drunk//////////////////////////////////////////////

		atomicbomb
			name = "Atomic Bomb"
			id = "atomicbomb"
			description = "Nuclear proliferation never tasted so good."
			reagent_state = LIQUID
			color = "#666300" // rgb: 102, 99, 0

			glass_icon_state = "atomicbombglass"
			glass_name = "glass of Atomic Bomb"
			glass_desc = "Nanotrasen cannot take legal responsibility for your actions after imbibing."
			glass_center_of_mass = list("x"=15, "y"=7)

			on_mob_life(var/mob/living/M as mob)
				M.druggy = max(M.druggy, 50)
				M.confused = max(M.confused+2,0)
				M.make_dizzy(10)
				if (!M.stuttering) M.stuttering = 1
				M.stuttering += 3
				if(!data) data = 1
				data++
				switch(data)
					if(51 to 200)
						M.sleeping += 1
					if(201 to INFINITY)
						M.sleeping += 1
						M.adjustToxLoss(2)
				..()
				return

		gargle_blaster
			name = "Pan-Galactic Gargle Blaster"
			id = "gargleblaster"
			description = "Whoah, this stuff looks volatile!"
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0

			glass_icon_state = "gargleblasterglass"
			glass_name = "glass of Pan-Galactic Gargle Blaster"
			glass_desc = "Does... does this mean that Arthur and Ford are on the station? Oh joy."
			glass_center_of_mass = list("x"=17, "y"=6)

			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=6
				switch(data)
					if(15 to 45)
						M.stuttering = max(M.stuttering+3,0)
					if(45 to 55)
						if (prob(50))
							M.confused = max(M.confused+3,0)
					if(55 to 200)
						M.druggy = max(M.druggy, 55)
					if(200 to INFINITY)
						M.adjustToxLoss(2)
				..()

		neurotoxin
			name = "Neurotoxin"
			id = "neurotoxin"
			description = "A strong neurotoxin that puts the subject into a death-like state."
			reagent_state = LIQUID
			color = "#2E2E61" // rgb: 46, 46, 97

			glass_icon_state = "neurotoxinglass"
			glass_name = "glass of Neurotoxin"
			glass_desc = "A drink that is guaranteed to knock you silly."
			glass_center_of_mass = list("x"=16, "y"=8)

			on_mob_life(var/mob/living/carbon/M as mob)
				if(!M) M = holder.my_atom
				M.weakened = max(M.weakened, 3)
				if(!data) data = 1
				data++
				M.dizziness +=6
				switch(data)
					if(15 to 45)
						M.stuttering = max(M.stuttering+3,0)
					if(45 to 55)
						if (prob(50))
							M.confused = max(M.confused+3,0)
					if(55 to 200)
						M.druggy = max(M.druggy, 55)
					if(200 to INFINITY)
						M.adjustToxLoss(2)
				..()

		hippies_delight
			name = "Hippies' Delight"
			id = "hippiesdelight"
			description = "You just don't get it maaaan."
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0

			glass_icon_state = "hippiesdelightglass"
			glass_name = "glass of Hippie's Delight"
			glass_desc = "A drink enjoyed by people during the 1960's."
			glass_center_of_mass = list("x"=16, "y"=8)

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 50)
				if(!data) data = 1
				data++
				switch(data)
					if(1 to 5)
						if (!M.stuttering) M.stuttering = 1
						M.make_dizzy(10)
						if(prob(10)) M.emote(pick("twitch","giggle"))
					if(5 to 10)
						if (!M.stuttering) M.stuttering = 1
						M.make_jittery(20)
						M.make_dizzy(20)
						M.druggy = max(M.druggy, 45)
						if(prob(20)) M.emote(pick("twitch","giggle"))
					if (10 to 200)
						if (!M.stuttering) M.stuttering = 1
						M.make_jittery(40)
						M.make_dizzy(40)
						M.druggy = max(M.druggy, 60)
						if(prob(30)) M.emote(pick("twitch","giggle"))
					if(200 to INFINITY)
						if (!M.stuttering) M.stuttering = 1
						M.make_jittery(60)
						M.make_dizzy(60)
						M.druggy = max(M.druggy, 75)
						if(prob(40)) M.emote(pick("twitch","giggle"))
						if(prob(30)) M.adjustToxLoss(2)
				holder.remove_reagent(src.id, 0.2)
				..()
				return

/*boozepwr chart
1-2 = non-toxic alcohol
3 = medium-toxic
4 = the hard stuff
5 = potent mixes
<6 = deadly toxic
*/

		ethanol
			name = "Ethanol" //Parent class for all alcoholic reagents.
			id = "ethanol"
			description = "A well-known alcohol with a variety of applications."
			reagent_state = LIQUID
			nutriment_factor = 0 //So alcohol can fill you up! If they want to.
			color = "#404030" // rgb: 64, 64, 48
			var/boozepwr = 5 //higher numbers mean the booze will have an effect faster.
			var/dizzy_adj = 3
			var/adj_drowsy = 0
			var/adj_sleepy = 0
			var/slurr_adj = 3
			var/confused_adj = 2
			var/slur_start = 90			//amount absorbed after which mob starts slurring
			var/confused_start = 150	//amount absorbed after which mob starts confusing directions
			var/blur_start = 300	//amount absorbed after which mob starts getting blurred vision
			var/pass_out = 400	//amount absorbed after which mob starts passing out

			glass_icon_state = "glass_clear"
			glass_name = "glass of ethanol"
			glass_desc = "A well-known alcohol with a variety of applications."

			on_mob_life(var/mob/living/M as mob, var/alien)
				M:nutrition += nutriment_factor
				holder.remove_reagent(src.id, (alien ? FOOD_METABOLISM : ALCOHOL_METABOLISM)) // Catch-all for creatures without livers.

				if (adj_drowsy)	M.drowsyness = max(0,M.drowsyness + adj_drowsy)
				if (adj_sleepy) M.sleeping = max(0,M.sleeping + adj_sleepy)

				if(!src.data || (!isnum(src.data)  && src.data.len)) data = 1   //if it doesn't exist we set it.  if it's a list we're going to set it to 1 as well.  This is to
				src.data += boozepwr						//avoid a runtime error associated with drinking blood mixed in drinks (demon's blood).

				var/d = data

				// make all the beverages work together
				for(var/datum/reagent/ethanol/A in holder.reagent_list)
					if(A != src && isnum(A.data)) d += A.data

				if(alien && alien == IS_SKRELL) //Skrell get very drunk very quickly.
					d*=5

				M.dizziness += dizzy_adj.
				if(d >= slur_start && d < pass_out)
					if (!M:slurring) M:slurring = 1
					M:slurring += slurr_adj
				if(d >= confused_start && prob(33))
					if (!M:confused) M:confused = 1
					M.confused = max(M:confused+confused_adj,0)
				if(d >= blur_start)
					M.eye_blurry = max(M.eye_blurry, 10)
					M:drowsyness  = max(M:drowsyness, 0)
				if(d >= pass_out)
					M:paralysis = max(M:paralysis, 20)
					M:drowsyness  = max(M:drowsyness, 30)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						var/obj/item/organ/liver/L = H.internal_organs_by_name["liver"]
						if (!L)
							H.adjustToxLoss(5)
						else if(istype(L))
							L.take_damage(0.1, 1)
						H.adjustToxLoss(0.1)
				..()
				return

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/item/weapon/paper))
					var/obj/item/weapon/paper/paperaffected = O
					paperaffected.clearpaper()
					usr << "The solution dissolves the ink on the paper."
				if(istype(O,/obj/item/weapon/book))
					if(istype(O,/obj/item/weapon/book/tome))
						usr << "The solution does nothing. Whatever this is, it isn't normal ink."
						return
					if(volume >= 5)
						var/obj/item/weapon/book/affectedbook = O
						affectedbook.dat = null
						usr << "The solution dissolves the ink on the book."
					else
						usr << "It wasn't enough..."
				return

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with ethanol isn't quite as good as fuel.
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					M.adjust_fire_stacks(volume / 15)
					return
		ethanol/beer
			name = "Beer"
			id = "beer"
			description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1
			nutriment_factor = 1 * FOOD_METABOLISM

			glass_icon_state = "beerglass"
			glass_name = "glass of beer"
			glass_desc = "A freezing pint of beer"
			glass_center_of_mass = list("x"=16, "y"=8)

			on_mob_life(var/mob/living/M as mob)
				M:jitteriness = max(M:jitteriness-3,0)
				..()
				return

		ethanol/kahlua
			name = "Kahlua"
			id = "kahlua"
			description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1.5
			dizzy_adj = -5
			adj_drowsy = -3
			adj_sleepy = -2

			glass_icon_state = "kahluaglass"
			glass_name = "glass of RR coffee liquor"
			glass_desc = "DAMN, THIS THING LOOKS ROBUST"
			glass_center_of_mass = list("x"=15, "y"=7)

			on_mob_life(var/mob/living/M as mob)
				M.make_jittery(5)
				..()
				return

		ethanol/whiskey
			name = "Whiskey"
			id = "whiskey"
			description = "A superb and well-aged single-malt whiskey. Damn."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2
			dizzy_adj = 4

			glass_icon_state = "whiskeyglass"
			glass_name = "glass of whiskey"
			glass_desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/specialwhiskey
			name = "Special Blend Whiskey"
			id = "specialwhiskey"
			description = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2
			dizzy_adj = 4
			slur_start = 30		//amount absorbed after which mob starts slurring

			glass_icon_state = "whiskeyglass"
			glass_name = "glass of special blend whiskey"
			glass_desc = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/thirteenloko
			name = "Thirteen Loko"
			id = "thirteenloko"
			description = "A potent mixture of caffeine and alcohol."
			color = "#102000" // rgb: 16, 32, 0
			boozepwr = 2
			nutriment_factor = 1 * FOOD_METABOLISM

			glass_icon_state = "thirteen_loko_glass"
			glass_name = "glass of Thirteen Loko"
			glass_desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass."

			on_mob_life(var/mob/living/M as mob)
				M:drowsyness = max(0,M:drowsyness-7)
				if (M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
				M.make_jittery(5)
				..()
				return

		ethanol/vodka
			name = "Vodka"
			id = "vodka"
			description = "Number one drink AND fueling choice for Russians worldwide."
			color = "#0064C8" // rgb: 0, 100, 200
			boozepwr = 2

			glass_icon_state = "ginvodkaglass"
			glass_name = "glass of vodka"
			glass_desc = "The glass contain wodka. Xynta."
			glass_center_of_mass = list("x"=16, "y"=12)

			on_mob_life(var/mob/living/M as mob)
				M.radiation = max(M.radiation-1,0)
				..()
				return

		ethanol/bilk
			name = "Bilk"
			id = "bilk"
			description = "This appears to be beer mixed with milk. Disgusting."
			color = "#895C4C" // rgb: 137, 92, 76
			boozepwr = 1
			nutriment_factor = 2 * FOOD_METABOLISM

			glass_icon_state = "glass_brown"
			glass_name = "glass of bilk"
			glass_desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."

		ethanol/threemileisland
			name = "Three Mile Island Iced Tea"
			id = "threemileisland"
			description = "Made for a woman, strong enough for a man."
			color = "#666340" // rgb: 102, 99, 64
			boozepwr = 5

			glass_icon_state = "threemileislandglass"
			glass_name = "glass of Three Mile Island iced tea"
			glass_desc = "A glass of this is sure to prevent a meltdown."
			glass_center_of_mass = list("x"=16, "y"=2)

			on_mob_life(var/mob/living/M as mob)
				M.druggy = max(M.druggy, 50)
				..()
				return

		ethanol/gin
			name = "Gin"
			id = "gin"
			description = "It's gin. In space. I say, good sir."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1
			dizzy_adj = 3

			glass_icon_state = "ginvodkaglass"
			glass_name = "glass of gin"
			glass_desc = "A crystal clear glass of Griffeater gin."
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/tequilla
			name = "Tequila"
			id = "tequilla"
			description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
			color = "#FFFF91" // rgb: 255, 255, 145
			boozepwr = 2

			glass_icon_state = "tequillaglass"
			glass_name = "glass of Tequilla"
			glass_desc = "Now all that's missing is the weird colored shades!"
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/vermouth
			name = "Vermouth"
			id = "vermouth"
			description = "You suddenly feel a craving for a martini..."
			color = "#91FF91" // rgb: 145, 255, 145
			boozepwr = 1.5

			glass_icon_state = "vermouthglass"
			glass_name = "glass of vermouth"
			glass_desc = "You wonder why you're even drinking this straight."
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/wine
			name = "Wine"
			id = "wine"
			description = "An premium alchoholic beverage made from distilled grape juice."
			color = "#7E4043" // rgb: 126, 64, 67
			boozepwr = 1.5
			dizzy_adj = 2
			slur_start = 65			//amount absorbed after which mob starts slurring
			confused_start = 145	//amount absorbed after which mob starts confusing directions

			glass_icon_state = "wineglass"
			glass_name = "glass of wine"
			glass_desc = "A very classy looking drink."
			glass_center_of_mass = list("x"=15, "y"=7)

		ethanol/cognac
			name = "Cognac"
			id = "cognac"
			description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
			color = "#AB3C05" // rgb: 171, 60, 5
			boozepwr = 1.5
			dizzy_adj = 4
			confused_start = 115	//amount absorbed after which mob starts confusing directions

			glass_icon_state = "cognacglass"
			glass_name = "glass of cognac"
			glass_desc = "Damn, you feel like some kind of French aristocrat just by holding this."
			glass_center_of_mass = list("x"=16, "y"=6)

		ethanol/hooch
			name = "Hooch"
			id = "hooch"
			description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2
			dizzy_adj = 6
			slurr_adj = 5
			slur_start = 35			//amount absorbed after which mob starts slurring
			confused_start = 90	//amount absorbed after which mob starts confusing directions

			glass_icon_state = "glass_brown2"
			glass_name = "glass of Hooch"
			glass_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."

		ethanol/ale
			name = "Ale"
			id = "ale"
			description = "A dark alchoholic beverage made by malted barley and yeast."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1

			glass_icon_state = "aleglass"
			glass_name = "glass of ale"
			glass_desc = "A freezing pint of delicious ale"
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/absinthe
			name = "Absinthe"
			id = "absinthe"
			description = "Watch out that the Green Fairy doesn't come for you!"
			color = "#33EE00" // rgb: 51, 238, 0
			boozepwr = 4
			dizzy_adj = 5
			slur_start = 15
			confused_start = 30

			glass_icon_state = "absintheglass"
			glass_name = "glass of absinthe"
			glass_desc = "Wormwood, anise, oh my."
			glass_center_of_mass = list("x"=16, "y"=5)

		ethanol/pwine
			name = "Poison Wine"
			id = "pwine"
			description = "Is this even wine? Toxic! Hallucinogenic! Probably consumed in boatloads by your superiors!"
			color = "#000000" // rgb: 0, 0, 0 SHOCKER
			boozepwr = 1
			dizzy_adj = 1
			slur_start = 1
			confused_start = 1

			glass_icon_state = "pwineglass"
			glass_name = "glass of ???"
			glass_desc = "A black ichor with an oily purple sheer on top. Are you sure you should drink this?"
			glass_center_of_mass = list("x"=16, "y"=5)

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 50)
				if(!data) data = 1
				data++
				switch(data)
					if(1 to 25)
						if (!M.stuttering) M.stuttering = 1
						M.make_dizzy(1)
						M.hallucination = max(M.hallucination, 3)
						if(prob(1)) M.emote(pick("twitch","giggle"))
					if(25 to 75)
						if (!M.stuttering) M.stuttering = 1
						M.hallucination = max(M.hallucination, 10)
						M.make_jittery(2)
						M.make_dizzy(2)
						M.druggy = max(M.druggy, 45)
						if(prob(5)) M.emote(pick("twitch","giggle"))
					if (75 to 150)
						if (!M.stuttering) M.stuttering = 1
						M.hallucination = max(M.hallucination, 60)
						M.make_jittery(4)
						M.make_dizzy(4)
						M.druggy = max(M.druggy, 60)
						if(prob(10)) M.emote(pick("twitch","giggle"))
						if(prob(30)) M.adjustToxLoss(2)
					if (150 to 300)
						if (!M.stuttering) M.stuttering = 1
						M.hallucination = max(M.hallucination, 60)
						M.make_jittery(4)
						M.make_dizzy(4)
						M.druggy = max(M.druggy, 60)
						if(prob(10)) M.emote(pick("twitch","giggle"))
						if(prob(30)) M.adjustToxLoss(2)
						if(prob(5)) if(ishuman(M))
							var/mob/living/carbon/human/H = M
							var/obj/item/organ/heart/L = H.internal_organs_by_name["heart"]
							if (L && istype(L))
								L.take_damage(5, 0)
					if (300 to INFINITY)
						if(ishuman(M))
							var/mob/living/carbon/human/H = M
							var/obj/item/organ/heart/L = H.internal_organs_by_name["heart"]
							if (L && istype(L))
								L.take_damage(100, 0)
				holder.remove_reagent(src.id, FOOD_METABOLISM)

		ethanol/rum
			name = "Rum"
			id = "rum"
			description = "Yohoho and all that."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1.5

			glass_icon_state = "rumglass"
			glass_name = "glass of rum"
			glass_desc = "Now you want to Pray for a pirate suit, don't you?"
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/deadrum
			name = "Deadrum"
			id = "rum" // duplicate ids?
			description = "Popular with the sailors. Not very popular with everyone else."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1

			glass_icon_state = "rumglass"
			glass_name = "glass of rum"
			glass_desc = "Now you want to Pray for a pirate suit, don't you?"
			glass_center_of_mass = list("x"=16, "y"=12)

			on_mob_life(var/mob/living/M as mob)
				..()
				M.dizziness +=5
				return

		ethanol/sake
			name = "Sake"
			id = "sake"
			description = "Anime's favorite drink."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2

			glass_icon_state = "ginvodkaglass"
			glass_name = "glass of sake"
			glass_desc = "A glass of sake."
			glass_center_of_mass = list("x"=16, "y"=12)

/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////


		ethanol/goldschlager
			name = "Goldschlager"
			id = "goldschlager"
			description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "ginvodkaglass"
			glass_name = "glass of Goldschlager"
			glass_desc = "100 proof that teen girls will drink anything with gold in it."
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/patron
			name = "Patron"
			id = "patron"
			description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
			color = "#585840" // rgb: 88, 88, 64
			boozepwr = 1.5

			glass_icon_state = "patronglass"
			glass_name = "glass of Patron"
			glass_desc = "Drinking patron in the bar, with all the subpar ladies."
			glass_center_of_mass = list("x"=7, "y"=8)

		ethanol/gintonic
			name = "Gin and Tonic"
			id = "gintonic"
			description = "An all time classic, mild cocktail."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1

			glass_icon_state = "gintonicglass"
			glass_name = "glass of gin and tonic"
			glass_desc = "A mild but still great cocktail. Drink up, like a true Englishman."
			glass_center_of_mass = list("x"=16, "y"=7)

		ethanol/cuba_libre
			name = "Cuba Libre"
			id = "cubalibre"
			description = "Rum, mixed with cola. Viva la revolucion."
			color = "#3E1B00" // rgb: 62, 27, 0
			boozepwr = 1.5

			glass_icon_state = "cubalibreglass"
			glass_name = "glass of Cuba Libre"
			glass_desc = "A classic mix of rum and cola."
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/whiskey_cola
			name = "Whiskey Cola"
			id = "whiskeycola"
			description = "Whiskey, mixed with cola. Surprisingly refreshing."
			color = "#3E1B00" // rgb: 62, 27, 0
			boozepwr = 2

			glass_icon_state = "whiskeycolaglass"
			glass_name = "glass of whiskey cola"
			glass_desc = "An innocent-looking mixture of cola and Whiskey. Delicious."
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/martini
			name = "Classic Martini"
			id = "martini"
			description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2

			glass_icon_state = "martiniglass"
			glass_name = "glass of classic martini"
			glass_desc = "Damn, the bartender even stirred it, not shook it."
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/vodkamartini
			name = "Vodka Martini"
			id = "vodkamartini"
			description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "martiniglass"
			glass_name = "glass of vodka martini"
			glass_desc ="A bastardisation of the classic martini. Still great."
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/white_russian
			name = "White Russian"
			id = "whiterussian"
			description = "That's just, like, your opinion, man..."
			color = "#A68340" // rgb: 166, 131, 64
			boozepwr = 3

			glass_icon_state = "whiterussianglass"
			glass_name = "glass of White Russian"
			glass_desc = "A very nice looking drink. But that's just, like, your opinion, man."
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/screwdrivercocktail
			name = "Screwdriver"
			id = "screwdrivercocktail"
			description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
			color = "#A68310" // rgb: 166, 131, 16
			boozepwr = 3

			glass_icon_state = "screwdriverglass"
			glass_name = "glass of Screwdriver"
			glass_desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."
			glass_center_of_mass = list("x"=15, "y"=10)

		ethanol/booger
			name = "Booger"
			id = "booger"
			description = "Ewww..."
			color = "#8CFF8C" // rgb: 140, 255, 140
			boozepwr = 1.5

			glass_icon_state = "booger"
			glass_name = "glass of Booger"
			glass_desc = "Ewww..."

		ethanol/bloody_mary
			name = "Bloody Mary"
			id = "bloodymary"
			description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "bloodymaryglass"
			glass_name = "glass of Bloody Mary"
			glass_desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."

		ethanol/brave_bull
			name = "Brave Bull"
			id = "bravebull"
			description = "It's just as effective as Dutch-Courage!"
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "bravebullglass"
			glass_name = "glass of Brave Bull"
			glass_desc = "Tequilla and coffee liquor, brought together in a mouthwatering mixture. Drink up."
			glass_center_of_mass = list("x"=15, "y"=8)

		ethanol/tequilla_sunrise
			name = "Tequila Sunrise"
			id = "tequillasunrise"
			description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
			color = "#FFE48C" // rgb: 255, 228, 140
			boozepwr = 2

			glass_icon_state = "tequillasunriseglass"
			glass_name = "glass of Tequilla Sunrise"
			glass_desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."

		ethanol/toxins_special
			name = "Toxins Special"
			id = "phoronspecial"
			description = "This thing is ON FIRE! CALL THE DAMN SHUTTLE!"
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 5

			glass_icon_state = "toxinsspecialglass"
			glass_name = "glass of Toxins Special"
			glass_desc = "Whoah, this thing is on FIRE"

			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature < 330)
					M.bodytemperature = min(330, M.bodytemperature + (15 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
				..()
				return

		ethanol/beepsky_smash
			name = "Beepsky Smash"
			id = "beepskysmash"
			description = "Deny drinking this and prepare for THE LAW."
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "beepskysmashglass"
			glass_name = "Beepsky Smash"
			glass_desc = "Heavy, hot and strong. Just like the Iron fist of the LAW."
			glass_center_of_mass = list("x"=18, "y"=10)

			on_mob_life(var/mob/living/M as mob)
				M.Stun(2)
				..()
				return

		ethanol/irish_cream
			name = "Irish Cream"
			id = "irishcream"
			description = "Whiskey-imbued cream, what else would you expect from the Irish."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2

			glass_icon_state = "irishcreamglass"
			glass_name = "glass of Irish cream"
			glass_desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/manly_dorf
			name = "The Manly Dorf"
			id = "manlydorf"
			description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2

			glass_icon_state = "manlydorfglass"
			glass_name = "glass of The Manly Dorf"
			glass_desc = "A manly concotion made from Ale and Beer. Intended for true men only."

		ethanol/longislandicedtea
			name = "Long Island Iced Tea"
			id = "longislandicedtea"
			description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "longislandicedteaglass"
			glass_name = "glass of Long Island iced tea"
			glass_desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/moonshine
			name = "Moonshine"
			id = "moonshine"
			description = "You've really hit rock bottom now... your liver packed its bags and left last night."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "glass_clear"
			glass_name = "glass of moonshine"
			glass_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."

		ethanol/b52
			name = "B-52"
			id = "b52"
			description = "Coffee, Irish Cream, and cognac. You will get bombed."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "b52glass"
			glass_name = "glass of B-52"
			glass_desc = "Kahlua, Irish cream, and congac. You will get bombed."

		ethanol/irishcoffee
			name = "Irish Coffee"
			id = "irishcoffee"
			description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "irishcoffeeglass"
			glass_name = "glass of Irish coffee"
			glass_desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."
			glass_center_of_mass = list("x"=15, "y"=10)

		ethanol/margarita
			name = "Margarita"
			id = "margarita"
			description = "On the rocks with salt on the rim. Arriba~!"
			color = "#8CFF8C" // rgb: 140, 255, 140
			boozepwr = 3

			glass_icon_state = "margaritaglass"
			glass_name = "glass of margarita"
			glass_desc = "On the rocks with salt on the rim. Arriba~!"
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/black_russian
			name = "Black Russian"
			id = "blackrussian"
			description = "For the lactose-intolerant. Still as classy as a White Russian."
			color = "#360000" // rgb: 54, 0, 0
			boozepwr = 3

			glass_icon_state = "blackrussianglass"
			glass_name = "glass of Black Russian"
			glass_desc = "For the lactose-intolerant. Still as classy as a White Russian."
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/manhattan
			name = "Manhattan"
			id = "manhattan"
			description = "The Detective's undercover drink of choice. He never could stomach gin..."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "manhattanglass"
			glass_name = "glass of Manhattan"
			glass_desc = "The Detective's undercover drink of choice. He never could stomach gin..."
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/manhattan_proj
			name = "Manhattan Project"
			id = "manhattan_proj"
			description = "A scientist's drink of choice, for pondering ways to blow up the station."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 5

			glass_icon_state = "proj_manhattanglass"
			glass_name = "glass of Manhattan Project"
			glass_desc = "A scienitst drink of choice, for thinking how to blow up the station."
			glass_center_of_mass = list("x"=17, "y"=8)

			on_mob_life(var/mob/living/M as mob)
				M.druggy = max(M.druggy, 30)
				..()
				return

		ethanol/whiskeysoda
			name = "Whiskey Soda"
			id = "whiskeysoda"
			description = "For the more refined griffon."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "whiskeysodaglass2"
			glass_name = "glass of whiskey soda"
			glass_desc = "Ultimate refreshment."
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/antifreeze
			name = "Anti-freeze"
			id = "antifreeze"
			description = "Ultimate refreshment."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "antifreeze"
			glass_name = "glass of Anti-freeze"
			glass_desc = "The ultimate refreshment."
			glass_center_of_mass = list("x"=16, "y"=8)

			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature < 330)
					M.bodytemperature = min(330, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
				..()
				return

		ethanol/barefoot
			name = "Barefoot"
			id = "barefoot"
			description = "Barefoot and pregnant"
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1.5

			glass_icon_state = "b&p"
			glass_name = "glass of Barefoot"
			glass_desc = "Barefoot and pregnant"
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/snowwhite
			name = "Snow White"
			id = "snowwhite"
			description = "A cold refreshment"
			color = "#FFFFFF" // rgb: 255, 255, 255
			boozepwr = 1.5

			glass_icon_state = "snowwhite"
			glass_name = "glass of Snow White"
			glass_desc = "A cold refreshment."
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/melonliquor
			name = "Melon Liquor"
			id = "melonliquor"
			description = "A relatively sweet and fruity 46 proof liquor."
			color = "#138808" // rgb: 19, 136, 8
			boozepwr = 1

			glass_icon_state = "emeraldglass"
			glass_name = "glass of melon liquor"
			glass_desc = "A relatively sweet and fruity 46 proof liquor."
			glass_center_of_mass = list("x"=16, "y"=5)

		ethanol/bluecuracao
			name = "Blue Curacao"
			id = "bluecuracao"
			description = "Exotically blue, fruity drink, distilled from oranges."
			color = "#0000CD" // rgb: 0, 0, 205
			boozepwr = 1.5

			glass_icon_state = "curacaoglass"
			glass_name = "glass of blue curacao"
			glass_desc = "Exotically blue, fruity drink, distilled from oranges."
			glass_center_of_mass = list("x"=16, "y"=5)

		ethanol/suidream
			name = "Sui Dream"
			id = "suidream"
			description = "Comprised of: White soda, blue curacao, melon liquor."
			color = "#00A86B" // rgb: 0, 168, 107
			boozepwr = 0.5

			glass_icon_state = "sdreamglass"
			glass_name = "glass of Sui Dream"
			glass_desc = "A froofy, fruity, and sweet mixed drink. Understanding the name only brings shame."
			glass_center_of_mass = list("x"=16, "y"=5)

		ethanol/demonsblood
			name = "Demons Blood"
			id = "demonsblood"
			description = "AHHHH!!!!"
			color = "#820000" // rgb: 130, 0, 0
			boozepwr = 3

			glass_icon_state = "demonsblood"
			glass_name = "glass of Demons' Blood"
			glass_desc = "Just looking at this thing makes the hair at the back of your neck stand up."
			glass_center_of_mass = list("x"=16, "y"=2)

		ethanol/vodkatonic
			name = "Vodka and Tonic"
			id = "vodkatonic"
			description = "For when a gin and tonic isn't russian enough."
			color = "#0064C8" // rgb: 0, 100, 200
			boozepwr = 3
			dizzy_adj = 4
			slurr_adj = 3

			glass_icon_state = "vodkatonicglass"
			glass_name = "glass of vodka and tonic"
			glass_desc = "For when a gin and tonic isn't Russian enough."
			glass_center_of_mass = list("x"=16, "y"=7)

		ethanol/ginfizz
			name = "Gin Fizz"
			id = "ginfizz"
			description = "Refreshingly lemony, deliciously dry."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1.5
			dizzy_adj = 4
			slurr_adj = 3

			glass_icon_state = "ginfizzglass"
			glass_name = "glass of gin fizz"
			glass_desc = "Refreshingly lemony, deliciously dry."
			glass_center_of_mass = list("x"=16, "y"=7)

		ethanol/bahama_mama
			name = "Bahama mama"
			id = "bahama_mama"
			description = "Tropical cocktail."
			color = "#FF7F3B" // rgb: 255, 127, 59
			boozepwr = 2

			glass_icon_state = "bahama_mama"
			glass_name = "glass of Bahama Mama"
			glass_desc = "Tropical cocktail"
			glass_center_of_mass = list("x"=16, "y"=5)

		ethanol/singulo
			name = "Singulo"
			id = "singulo"
			description = "A blue-space beverage!"
			color = "#2E6671" // rgb: 46, 102, 113
			boozepwr = 5
			dizzy_adj = 15
			slurr_adj = 15

			glass_icon_state = "singulo"
			glass_name = "glass of Singulo"
			glass_desc = "A blue-space beverage."
			glass_center_of_mass = list("x"=17, "y"=4)

		ethanol/sbiten
			name = "Sbiten"
			id = "sbiten"
			description = "A spicy Vodka! Might be a little hot for the little guys!"
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "sbitenglass"
			glass_name = "glass of Sbiten"
			glass_desc = "A spicy mix of Vodka and Spice. Very hot."
			glass_center_of_mass = list("x"=17, "y"=8)

			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature < 360)
					M.bodytemperature = min(360, M.bodytemperature + (50 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
				..()
				return

		ethanol/devilskiss
			name = "Devils Kiss"
			id = "devilskiss"
			description = "Creepy time!"
			color = "#A68310" // rgb: 166, 131, 16
			boozepwr = 3

			glass_icon_state = "devilskiss"
			glass_name = "glass of Devil's Kiss"
			glass_desc = "Creepy time!"
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/red_mead
			name = "Red Mead"
			id = "red_mead"
			description = "The true Viking's drink! Even though it has a strange red color."
			color = "#C73C00" // rgb: 199, 60, 0
			boozepwr = 1.5

			glass_icon_state = "red_meadglass"
			glass_name = "glass of red mead"
			glass_desc = "A true Viking's beverage, though its color is strange."
			glass_center_of_mass = list("x"=17, "y"=10)

		ethanol/mead
			name = "Mead"
			id = "mead"
			description = "A Viking's drink, though a cheap one."
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1.5
			nutriment_factor = 1 * FOOD_METABOLISM

			glass_icon_state = "meadglass"
			glass_name = "glass of mead"
			glass_desc = "A Viking's beverage, though a cheap one."
			glass_center_of_mass = list("x"=17, "y"=10)

		ethanol/iced_beer
			name = "Iced Beer"
			id = "iced_beer"
			description = "A beer which is so cold the air around it freezes."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1

			glass_icon_state = "iced_beerglass"
			glass_name = "glass of iced beer"
			glass_desc = "A beer so frosty, the air around it freezes."
			glass_center_of_mass = list("x"=16, "y"=7)

			on_mob_life(var/mob/living/M as mob)
				if(M.bodytemperature > 270)
					M.bodytemperature = max(270, M.bodytemperature - (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
				..()
				return

		ethanol/grog
			name = "Grog"
			id = "grog"
			description = "Watered down rum, NanoTrasen approves!"
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 0.5

			glass_icon_state = "grogglass"
			glass_name = "glass of grog"
			glass_desc = "A fine and cepa drink for Space."

		ethanol/aloe
			name = "Aloe"
			id = "aloe"
			description = "So very, very, very good."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "aloe"
			glass_name = "glass of Aloe"
			glass_desc = "Very, very, very good."
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/andalusia
			name = "Andalusia"
			id = "andalusia"
			description = "A nice, strangely named drink."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "andalusia"
			glass_name = "glass of Andalusia"
			glass_desc = "A nice, strange named drink."
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/alliescocktail
			name = "Allies Cocktail"
			id = "alliescocktail"
			description = "A drink made from your allies, not as sweet as when made from your enemies."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2

			glass_icon_state = "alliescocktail"
			glass_name = "glass of Allies cocktail"
			glass_desc = "A drink made from your allies."
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/acid_spit
			name = "Acid Spit"
			id = "acidspit"
			description = "A drink for the daring, can be deadly if incorrectly prepared!"
			reagent_state = LIQUID
			color = "#365000" // rgb: 54, 80, 0
			boozepwr = 1.5

			glass_icon_state = "acidspitglass"
			glass_name = "glass of Acid Spit"
			glass_desc = "A drink from Nanotrasen. Made from live aliens."
			glass_center_of_mass = list("x"=16, "y"=7)

		ethanol/amasec
			name = "Amasec"
			id = "amasec"
			description = "Official drink of the NanoTrasen Gun-Club!"
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2

			glass_icon_state = "amasecglass"
			glass_name = "glass of Amasec"
			glass_desc = "Always handy before COMBAT!!!"
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/changelingsting
			name = "Changeling Sting"
			id = "changelingsting"
			description = "You take a tiny sip and feel a burning sensation..."
			color = "#2E6671" // rgb: 46, 102, 113
			boozepwr = 5

			glass_icon_state = "changelingsting"
			glass_name = "glass of Changeling Sting"
			glass_desc = "A stingy drink."

		ethanol/irishcarbomb
			name = "Irish Car Bomb"
			id = "irishcarbomb"
			description = "Mmm, tastes like chocolate cake..."
			color = "#2E6671" // rgb: 46, 102, 113
			boozepwr = 3
			dizzy_adj = 5

			glass_icon_state = "irishcarbomb"
			glass_name = "glass of Irish Car Bomb"
			glass_desc = "An irish car bomb."
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/syndicatebomb
			name = "Syndicate Bomb"
			id = "syndicatebomb"
			description = "Tastes like terrorism!"
			color = "#2E6671" // rgb: 46, 102, 113
			boozepwr = 5

			glass_icon_state = "syndicatebomb"
			glass_name = "glass of Syndicate Bomb"
			glass_desc = "Tastes like terrorism!"
			glass_center_of_mass = list("x"=16, "y"=4)

		ethanol/erikasurprise
			name = "Erika Surprise"
			id = "erikasurprise"
			description = "The surprise is it's green!"
			color = "#2E6671" // rgb: 46, 102, 113
			boozepwr = 3

			glass_icon_state = "erikasurprise"
			glass_name = "glass of Erika Surprise"
			glass_desc = "The surprise is, it's green!"
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/driestmartini
			name = "Driest Martini"
			id = "driestmartini"
			description = "Only for the experienced. You think you see sand floating in the glass."
			nutriment_factor = 1 * FOOD_METABOLISM
			color = "#2E6671" // rgb: 46, 102, 113
			boozepwr = 4

			glass_icon_state = "driestmartiniglass"
			glass_name = "glass of Driest Martini"
			glass_desc = "Only for the experienced. You think you see sand floating in the glass."
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/bananahonk
			name = "Banana Mama"
			id = "bananahonk"
			description = "A drink from Clown Heaven."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#FFFF91" // rgb: 255, 255, 140
			boozepwr = 4

			glass_icon_state = "bananahonkglass"
			glass_name = "glass of Banana Honk"
			glass_desc = "A drink from Banana Heaven."
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/silencer
			name = "Silencer"
			id = "silencer"
			description = "A drink from Mime Heaven."
			nutriment_factor = 1 * FOOD_METABOLISM
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "silencerglass"
			glass_name = "glass of Silencer"
			glass_desc = "A drink from mime Heaven."
			glass_center_of_mass = list("x"=16, "y"=9)

			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=10
				if(data >= 55 && data <115)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 10
				else if(data >= 115 && prob(33))
					M.confused = max(M.confused+15,15)
				..()
				return

datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	..()
	holder = null

// Undefine the alias for REAGENTS_EFFECT_MULTIPLER
#undef REM
