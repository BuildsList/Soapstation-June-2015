var/datum/uplink/uplink = new()

/datum/uplink
	var/list/items_assoc
	var/list/datum/uplink_item/items
	var/list/datum/uplink_category/categories

/datum/uplink/New()
	items_assoc = list()
	items = init_subtypes(/datum/uplink_item)
	categories = init_subtypes(/datum/uplink_category)
	categories = dd_sortedObjectList(categories)

	for(var/datum/uplink_item/item in items)
		if(!item.name)
			items -= item
			continue

		items_assoc[item.type] = item

		for(var/datum/uplink_category/category in categories)
			if(item.category == category.type)
				category.items += item

	for(var/datum/uplink_category/category in categories)
		category.items = dd_sortedObjectList(category.items)

/datum/uplink_item
	var/name
	var/desc
	var/item_cost = 0
	var/datum/uplink_category/category		// Item category
	var/list/datum/antagonist/antag_roles	// Antag roles this item is displayed to. If empty, display to all.

/datum/uplink_item/item
	var/path = null

/datum/uplink_item/New()
	..()
	antag_roles = list()

/datum/uplink_item/proc/buy(var/obj/item/device/uplink/U, var/mob/user)
	var/extra_args = extra_args(user)
	if(!extra_args)
		return

	if(!can_buy(U))
		return

	var/cost = cost(U.uses)

	var/goods = get_goods(U, get_turf(user), user, extra_args)
	if(!goods)
		return

	purchase_log(U)
	U.uses -= cost
	U.used_TC += cost
	return goods

// Any additional arguments you wish to send to the get_goods
/datum/uplink_item/proc/extra_args(var/mob/user)
	return 1

/datum/uplink_item/proc/can_buy(obj/item/device/uplink/U)
	if(cost(U.uses) > U.uses)
		return 0

	return can_view(U)

/datum/uplink_item/proc/can_view(obj/item/device/uplink/U)
	// Making the assumption that if no uplink was supplied, then we don't care about antag roles
	if(!U || !antag_roles.len)
		return 1

	// With no owner, there's no need to check antag status.
	if(!U.uplink_owner)
		return 0

	for(var/antag_role in antag_roles)
		var/datum/antagonist/antag = all_antag_types[antag_role]
		if(antag.is_antagonist(U.uplink_owner))
			return 1
	return 0

/datum/uplink_item/proc/cost(var/telecrystals)
	return item_cost

/datum/uplink_item/proc/description()
	return desc

// get_goods does not necessarily return physical objects, it is simply a way to acquire the uplink item without paying
/datum/uplink_item/proc/get_goods(var/obj/item/device/uplink/U, var/loc)
	return 0

/datum/uplink_item/proc/log_icon()
	return

/datum/uplink_item/proc/purchase_log(obj/item/device/uplink/U)
	feedback_add_details("traitor_uplink_items_bought", "[src]")
	log_and_message_admins("used \the [U.loc] to buy \a [src]")
	U.purchase_log[src] = U.purchase_log[src] + 1

datum/uplink_item/dd_SortValue()
	return cost(INFINITY)

/********************************
*                           	*
*	Physical Uplink Entries		*
*                           	*
********************************/
/datum/uplink_item/item/buy(var/obj/item/device/uplink/U, var/mob/user)
	var/obj/item/I = ..()
	if(!I)
		return

	if(istype(I, /list))
		var/list/L = I
		if(L.len) I = L[1]

	if(istype(I) && ishuman(user))
		var/mob/living/carbon/human/A = user
		A.put_in_any_hand_if_possible(I)
	return I

/datum/uplink_item/item/get_goods(var/obj/item/device/uplink/U, var/loc)
	var/obj/item/I = new path(loc)
	return I

/datum/uplink_item/item/description()
	if(!desc)
		// Fallback description
		var/obj/temp = src.path
		desc = initial(temp.desc)
	return ..()

/datum/uplink_item/item/log_icon()
	var/obj/I = path
	return "\icon[I]"

/********************************
*                           	*
*	Abstract Uplink Entries		*
*                           	*
********************************/
var/image/default_abstract_uplink_icon
/datum/uplink_item/abstract/log_icon()
	if(!default_abstract_uplink_icon)
		default_abstract_uplink_icon = image('icons/obj/pda.dmi', "pda-syn")

	return "\icon[default_abstract_uplink_icon]"

/****************
* Support procs *
****************/
/proc/get_random_uplink_items(var/obj/item/device/uplink/U, var/remaining_TC, var/loc)
	var/list/bought_items = list()
	while(remaining_TC)
		var/datum/uplink_item/I = default_uplink_selection.get_random_item(remaining_TC, U, bought_items)
		if(!I)
			break
		bought_items += I
		remaining_TC -= I.cost(remaining_TC)

	return bought_items
