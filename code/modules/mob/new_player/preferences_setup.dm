datum/preferences
	//The mob should have a gender you want before running this proc.
	proc/randomize_appearance_for(var/mob/living/carbon/human/H)
		if(H.gender == MALE)
			gender = MALE
		else
			gender = FEMALE
		s_tone = random_skin_tone()
		h_style = random_hair_style(gender)
		f_style = random_facial_hair_style(gender)
		r_hair = rand(0,255)
		g_hair = rand(0,255)
		b_hair = rand(0,255)
		r_facial = r_hair
		g_facial = g_hair
		b_facial = b_hair
		r_eyes = rand(0,255)
		g_eyes = rand(0,255)
		b_eyes = rand(0,255)
		underwear = rand(1,underwear_m.len)
		backbag = 2
		age = rand(AGE_MIN,AGE_MAX)
		copy_to(H,1)

	proc/update_preview_icon()		//seriously. This is horrendous.		del(preview_icon_front)
		del(preview_icon_side)
		var/icon/preview_icon = null

		var/g = "m"
		if(gender == FEMALE)	g = "f"
		if(species == "Tajaran")
			preview_icon = new /icon('icons/effects/species.dmi', "tajaran_[g]_s")
			preview_icon.Blend(new /icon('icons/effects/species.dmi', "tajtail_s"), ICON_OVERLAY)
		else if(species == "Soghun")
			preview_icon = new /icon('icons/effects/species.dmi', "lizard_[g]_s")
			preview_icon.Blend(new /icon('icons/effects/species.dmi', "sogtail_s"), ICON_OVERLAY)
		else if(species == "Skrell")
			preview_icon = new /icon('icons/effects/species.dmi', "skrell_[g]_s")
		else
			preview_icon = new /icon('human.dmi', "torso_[g]_s")

			preview_icon.Blend(new /icon('human.dmi', "chest_[g]_s"), ICON_OVERLAY)

			if(organ_data["head"] != "amputated")
				preview_icon.Blend(new /icon('human.dmi', "head_[g]_s"), ICON_OVERLAY)

			for(var/name in list("l_arm","r_arm","l_leg","r_leg","l_foot","r_foot","l_hand","r_hand"))
				// make sure the organ is added to the list so it's drawn
				if(organ_data[name] == null)
					organ_data[name] = null

			for(var/name in organ_data)
				if(organ_data[name] == "amputated") continue

				var/icon/temp = new /icon('human.dmi', "[name]_s")
				if(organ_data[name] == "cyborg")
					temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))

				preview_icon.Blend(temp, ICON_OVERLAY)

			preview_icon.Blend(new /icon('human.dmi', "groin_[g]_s"), ICON_OVERLAY)


		// Skin tone
		if(species == "Human")
			if (s_tone >= 0)
				preview_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
			else
				preview_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "eyes_s")
		eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)

		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if(hair_style)
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
			eyes_s.Blend(hair_s, ICON_OVERLAY)

		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if(facial_hair_style)
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
			eyes_s.Blend(facial_s, ICON_OVERLAY)

		var/icon/clothes_s = null
		if(job_civilian_low & ASSISTANT)//This gives the preview icon clothes depending on which job(if any) is set to 'high'
			clothes_s = new /icon('icons/mob/uniform.dmi', "grey_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
			if(backbag == 2)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
			else if(backbag == 3 || backbag == 4)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

		else if(job_civilian_high)//I hate how this looks, but there's no reason to go through this switch if it's empty
			switch(job_civilian_high)
				if(HOP)
					clothes_s = new /icon('icons/mob/uniform.dmi', "hop_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "helmet"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(BARTENDER)
					clothes_s = new /icon('icons/mob/uniform.dmi', "ba_suit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(BOTANIST)
					clothes_s = new /icon('icons/mob/uniform.dmi', "hydroponics_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "ggloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "apron"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-hyd"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(CHEF)
					clothes_s = new /icon('icons/mob/uniform.dmi', "chef_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "chef"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(JANITOR)
					clothes_s = new /icon('icons/mob/uniform.dmi', "janitor_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(LIBRARIAN)
					clothes_s = new /icon('icons/mob/uniform.dmi', "red_suit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(QUARTERMASTER)
					clothes_s = new /icon('icons/mob/uniform.dmi', "qm_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sun"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "clipboard"), ICON_UNDERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(CARGOTECH)
					clothes_s = new /icon('icons/mob/uniform.dmi', "cargotech_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(MINER)
					clothes_s = new /icon('icons/mob/uniform.dmi', "miner_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(LAWYER)
					clothes_s = new /icon('icons/mob/uniform.dmi', "lawyer_blue_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "briefcase"), ICON_UNDERLAY)

					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(CHAPLAIN)
					clothes_s = new /icon('icons/mob/uniform.dmi', "chapblack_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(CLOWN)
					clothes_s = new /icon('icons/mob/uniform.dmi', "clown_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "clown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "clown"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "clownpack"), ICON_OVERLAY)
				if(MIME)
					clothes_s = new /icon('icons/mob/uniform.dmi', "mime_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "mime"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "beret"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "suspenders"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

		else if(job_medsci_high)
			switch(job_medsci_high)
				if(RD)
					clothes_s = new /icon('icons/mob/uniform.dmi', "director_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "clipboard"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-tox"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(SCIENTIST)
					clothes_s = new /icon('icons/mob/uniform.dmi', "toxinswhite_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-tox"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(CHEMIST)
					clothes_s = new /icon('icons/mob/uniform.dmi', "chemistrywhite_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_chem_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-chem"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(CMO)
					clothes_s = new /icon('icons/mob/uniform.dmi', "cmo_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/items_lefthand.dmi', "firstaid"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_cmo_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-med"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(DOCTOR)
					clothes_s = new /icon('icons/mob/uniform.dmi', "medical_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/items_lefthand.dmi', "firstaid"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-med"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(GENETICIST)
					clothes_s = new /icon('icons/mob/uniform.dmi', "geneticswhite_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_gen_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-gen"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(VIROLOGIST)
					clothes_s = new /icon('icons/mob/uniform.dmi', "virologywhite_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "sterile"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_vir_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-vir"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

		else if(job_engsec_high)
			switch(job_engsec_high)
				if(CAPTAIN)
					clothes_s = new /icon('icons/mob/uniform.dmi', "captain_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "captain"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sun"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "caparmor"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-cap"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(HOS)
					clothes_s = new /icon('icons/mob/uniform.dmi', "hosred_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "helmet"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-sec"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(WARDEN)
					clothes_s = new /icon('icons/mob/uniform.dmi', "warden_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "helmet"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-sec"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(DETECTIVE)
					clothes_s = new /icon('icons/mob/uniform.dmi', "detective_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "detective"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "detective"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(OFFICER)
					clothes_s = new /icon('icons/mob/uniform.dmi', "secred_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "helmet"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-sec"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(CHIEF)
					clothes_s = new /icon('icons/mob/uniform.dmi', "chief_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_white"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "engiepack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(ENGINEER)
					clothes_s = new /icon('icons/mob/uniform.dmi', "engine_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "orange"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_yellow"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "engiepack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(ATMOSTECH)
					clothes_s = new /icon('icons/mob/uniform.dmi', "atmos_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(ROBOTICIST)
					clothes_s = new /icon('icons/mob/uniform.dmi', "robotics_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "toolbox_blue"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(AI)//Gives AI and borgs assistant-wear, so they can still customize their character
					clothes_s = new /icon('icons/mob/uniform.dmi', "grey_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					if(backbag == 2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					else if(backbag == 3 || backbag == 4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(CYBORG)
					clothes_s = new /icon('icons/mob/uniform.dmi', "grey_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					if(backbag == 2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					else if(backbag == 3 || backbag == 4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

		preview_icon.Blend(eyes_s, ICON_OVERLAY)
		if(clothes_s)
			preview_icon.Blend(clothes_s, ICON_OVERLAY)
		preview_icon_front = new(preview_icon, dir = SOUTH)
		preview_icon_side = new(preview_icon, dir = WEST)

		del(preview_icon)
		del(eyes_s)
		del(clothes_s)