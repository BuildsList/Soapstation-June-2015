var/datum/antagonist/loyalists/loyalists

/datum/antagonist/loyalists
	id = MODE_LOYALIST
	role_type = BE_LOYALIST
	role_text = "Head Loyalist"
	role_text_plural = "Loyalists"
	bantype = "loyalist"
	feedback_tag = "loyalist_objective"
	antag_indicator = "loyal_head"
	welcome_text = "You belong to the Company, body and soul. Preserve its interests against the conspirators amongst the crew."
	victory_text = "The heads of staff remained at their posts! The loyalists win!"
	loss_text = "The heads of staff did not stop the revolution!"
	victory_feedback_tag = "win - rev heads killed"
	loss_feedback_tag = "loss - heads killed"
	flags = 0
	max_antags =       1
	max_antags_round = 1

	// Inround loyalists.
	faction_role_text = "Loyalist"
	faction_descriptor = "Company"
	faction_verb = /mob/living/proc/convert_to_loyalist
	faction_welcome = "Preserve NanoTrasen's interests against the traitorous recidivists amongst the crew. Protect the heads of staff with your life."
	faction_indicator = "loyal"
	faction_invisible = 1

/datum/antagonist/loyalists/New()
	..()
	loyalists = src

/datum/antagonist/loyalists/create_global_objectives()
	if(!..())
		return
	global_objectives = list()
	for(var/mob/living/carbon/human/player in mob_list)
		if(!player.mind || player.stat==2 || !(player.mind.assigned_role in command_positions))
			continue
		var/datum/objective/protect/loyal_obj = new
		loyal_obj.target = player.mind
		loyal_obj.explanation_text = "Protect [player.real_name], the [player.mind.assigned_role]."
		global_objectives += loyal_obj
