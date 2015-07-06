var/datum/admin_secrets/admin_secrets = new()

/datum/admin_secrets
	var/list/datum/admin_secret_category/categories
	var/list/datum/admin_secret_item/items

/datum/admin_secrets/New()
	..()
	categories = init_subtypes(/datum/admin_secret_category)
	items = list()
	var/list/category_assoc = list()
	for(var/datum/category in categories)
		category_assoc[category.type] = category

	for(var/item_type in (typesof(/datum/admin_secret_item) - /datum/admin_secret_item))
		var/datum/admin_secret_item/secret_item = item_type
		if(!initial(secret_item.name))
			continue

		var/datum/admin_secret_item/item = new item_type()
		var/datum/admin_secret_category/category = category_assoc[item.category]
		category.items += item
		items += item

/datum/admin_secret_category
	var/name = ""
	var/desc = ""
	var/list/datum/admin_secret_item/items

/datum/admin_secret_category
	..()
	items = list()

/datum/admin_secret_category/proc/can_view(var/mob/user)
	for(var/datum/admin_secret_item/item in items)
		if(item.can_execute(user))
			return 1
	return 0

/datum/admin_secret_item
	var/name = ""
	var/category = null
	var/log = 1
	var/permissions = R_HOST

/datum/admin_secret_item/proc/name()
	return name

/datum/admin_secret_item/proc/can_execute(var/mob/user)
	return check_rights(permissions, 0, user)

/datum/admin_secret_item/proc/execute(var/mob/user)
	if(!can_execute(user))
		return 0

	if(log)
		log_admin("[key_name(user)] used secret '[name()]'")
	return 1

/*************************
* Pre-defined categories *
*************************/
/datum/admin_secret_category/admin_secrets
	name = "Admin Secrets"

/datum/admin_secret_category/random_events
	name = "'Random' Events"

/*************************
* Pre-defined base items *
*************************/
/datum/admin_secret_item/admin_secret
	category = /datum/admin_secret_category/admin_secrets
	log = 0
	permissions = R_ADMIN


/datum/admin_secret_item/random_event
	category = /datum/admin_secret_category/random_events
	permissions = R_FUN
