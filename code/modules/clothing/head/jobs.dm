
//Bartender
/obj/item/clothing/head/chefhat
	name = "chef's hat"
	desc = "It's a hat used by chefs to keep hair out of your food. Judging by the food in the mess, they don't work."
	icon_state = "chefhat"
	item_state = "chefhat"
	desc = "The commander in chef's head wear."
	flags = FPRINT | TABLEPASS
	siemens_coefficient = 0.9

//Captain: This probably shouldn't be space-worthy
/obj/item/clothing/head/caphat
	name = "captain's hat"
	icon_state = "captain"
	desc = "It's good being the king."
	flags = FPRINT|TABLEPASS
	item_state = "caphat"
	siemens_coefficient = 0.9

//Captain: This probably shouldn't be space-worthy
/obj/item/clothing/head/helmet/cap
	name = "captain's cap"
	desc = "You fear to wear it for the negligence it brings."
	icon_state = "capcap"
	flags = FPRINT|TABLEPASS
	flags_inv = 0
	body_parts_covered = 0
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
	body_parts_covered = 0

//Chaplain
/obj/item/clothing/head/chaplain_hood
	name = "chaplain's hood"
	desc = "It's hood that covers the head. It keeps you warm during the space winters."
	icon_state = "chaplain_hood"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES|BLOCKHAIR
	siemens_coefficient = 0.9
	body_parts_covered = HEAD|EYES

//Chaplain
/obj/item/clothing/head/nun_hood
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES|BLOCKHAIR
	siemens_coefficient = 0.9

//Mime
/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, an artists favorite headwear."
	icon_state = "beret"
	flags = FPRINT | TABLEPASS
	siemens_coefficient = 0.9
	body_parts_covered = 0

//Security
/obj/item/clothing/head/beret/sec
	name = "security beret"
	desc = "A beret with the security insignia emblazoned on it. For officers that are more inclined towards style than safety."
	icon_state = "beret_badge"
	flags = FPRINT | TABLEPASS
/obj/item/clothing/head/beret/sec/alt
	name = "officer beret"
	desc = "A navy blue beret with an officer's rank emblem. For officers that are more inclined towards style than safety."
	icon_state = "officerberet"
	flags = FPRINT | TABLEPASS
/obj/item/clothing/head/beret/sec/hos
	name = "officer beret"
	desc = "A navy blue beret with a commander's rank emblem. For officers that are more inclined towards style than safety."
	icon_state = "hosberet"
	flags = FPRINT | TABLEPASS
/obj/item/clothing/head/beret/sec/warden
	name = "warden beret"
	desc = "A navy blue beret with a warden's rank emblem. For officers that are more inclined towards style than safety."
	icon_state = "wardenberet"
	flags = FPRINT | TABLEPASS
/obj/item/clothing/head/beret/eng
	name = "engineering beret"
	desc = "A beret with the engineering insignia emblazoned on it. For engineers that are more inclined towards style than safety."
	icon_state = "e_beret_badge"
	flags = FPRINT | TABLEPASS

//Medical
/obj/item/clothing/head/surgery
	name = "surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs."
	icon_state = "surgcap_blue"
	flags = FPRINT | TABLEPASS | BLOCKHEADHAIR

/obj/item/clothing/head/surgery/purple
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is deep purple."
	icon_state = "surgcap_purple"

/obj/item/clothing/head/surgery/blue
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is baby blue."
	icon_state = "surgcap_blue"

/obj/item/clothing/head/surgery/green
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is dark green."
	icon_state = "surgcap_green"
