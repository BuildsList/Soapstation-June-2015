/datum/game_mode/revolution
	name = "Revolution"
	config_tag = "revolution"
	round_description = "Some crewmembers are attempting to start a revolution!"
	extended_round_description = "Revolutionaries - Remove the heads of staff from power. Convert other crewmembers to your cause using the 'Convert Bourgeoise' verb. Protect your leaders."
	required_players = 4
	required_players_secret = 15
	required_enemies = 3
	auto_recall_shuttle = 1
	uplink_welcome = "AntagCorp Uplink Console:"
	uplink_uses = 10
	end_on_antag_death = 1
	shuttle_delay = 3
	antag_tags = list(MODE_REVOLUTIONARY, MODE_LOYALIST)
	require_all_templates = 1