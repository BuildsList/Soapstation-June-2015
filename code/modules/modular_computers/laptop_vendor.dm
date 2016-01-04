// A vendor machine for modular computer portable devices - Laptops and Tablets

/obj/machinery/lapvend
	name = "computer vendor"
	desc = "A vending machine with microfabricator capable of dispensing various NT-branded computers"
	icon = 'icons/obj/vending.dmi'
	icon_state = "robotics"
	layer = 2.9
	anchored = 1
	density = 1

	// The actual laptop/tablet
	var/obj/machinery/modular_computer/laptop/fabricated_laptop = null
	var/obj/item/modular_computer/tablet/fabricated_tablet = null

	// Utility vars
	var/state = 0 							// 0: Select device type, 1: Select loadout, 2: Payment, 3: Thankyou screen
	var/devtype = 0 						// 0: None(unselected), 1: Laptop, 2: Tablet
	var/total_price = 0						// Price of currently vended device.

	// Device loadout
	var/dev_battery = 1						// 1: Default, 2: Upgraded, 3: Advanced
	var/dev_disk = 1						// 1: Default, 2: Upgraded, 3: Advanced
	var/dev_netcard = 0						// 0: None, 1: Basic, 2: Long-Range
	var/dev_tesla = 0						// 0: None, 1: Standard (LAPTOP ONLY)
	var/dev_nanoprint = 0					// 0: None, 1: Standard
	var/dev_card = 0						// 0: None, 1: Standard

// Removes all traces of old order and allows you to begin configuration from scratch.
/obj/machinery/lapvend/proc/reset_order()
	state = 0
	devtype = 0
	if(fabricated_laptop)
		qdel(fabricated_laptop)
		fabricated_laptop = null
	if(fabricated_tablet)
		qdel(fabricated_tablet)
		fabricated_tablet = null
	dev_battery = 1
	dev_disk = 1
	dev_netcard = 0
	dev_tesla = 0
	dev_nanoprint = 0
	dev_card = 0

// Recalculates the price and optionally even fabricates the device.
/obj/machinery/lapvend/proc/fabricate_and_recalc_price(var/fabricate = 0)
	total_price = 0
	if(devtype == 1) 		// Laptop, generally cheaper to make it accessible for most station roles
		if(fabricate)
			fabricated_laptop = new(src)
		total_price = 99
		switch(dev_battery)
			if(1) // Basic(750C)
				if(fabricate)
					fabricated_laptop.cpu.battery_module = new/obj/item/weapon/computer_hardware/battery_module(fabricated_tablet)
			if(2) // Upgraded(1100C)
				if(fabricate)
					fabricated_laptop.cpu.battery_module = new/obj/item/weapon/computer_hardware/battery_module/advanced(fabricated_tablet)
				total_price += 199
			if(3) // Advanced(1500C)
				if(fabricate)
					fabricated_laptop.cpu.battery_module = new/obj/item/weapon/computer_hardware/battery_module/super(fabricated_tablet)
				total_price += 499
		switch(dev_disk)
			if(1) // Basic(128GQ)
				if(fabricate)
					fabricated_laptop.cpu.hard_drive = new/obj/item/weapon/computer_hardware/hard_drive(fabricated_laptop.cpu)
			if(2) // Upgraded(256GQ)
				if(fabricate)
					fabricated_laptop.cpu.hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/advanced(fabricated_laptop.cpu)
				total_price += 99
			if(3) // Advanced(512GQ)
				if(fabricate)
					fabricated_laptop.cpu.hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/super(fabricated_laptop.cpu)
				total_price += 299
		switch(dev_netcard)
			if(1) // Basic(Short-Range)
				if(fabricate)
					fabricated_laptop.cpu.network_card = new/obj/item/weapon/computer_hardware/network_card(fabricated_laptop.cpu)
				total_price += 99
			if(2) // Advanced (Long Range)
				if(fabricate)
					fabricated_laptop.cpu.network_card = new/obj/item/weapon/computer_hardware/network_card/advanced(fabricated_laptop.cpu)
				total_price += 299
		if(dev_tesla)
			total_price += 399
			if(fabricate)
				fabricated_laptop.tesla_link = new/obj/item/weapon/computer_hardware/tesla_link(fabricated_laptop)
		if(dev_nanoprint)
			total_price += 99
			if(fabricate)
				fabricated_laptop.cpu.nano_printer = new/obj/item/weapon/computer_hardware/nano_printer(fabricated_laptop.cpu)
		if(dev_card)
			total_price += 199
			if(fabricate)
				fabricated_laptop.cpu.card_slot = new/obj/item/weapon/computer_hardware/card_slot(fabricated_laptop.cpu)

		return total_price
	else if(devtype == 2) 	// Tablet, more expensive, not everyone could probably afford this.
		if(fabricate)
			fabricated_tablet = new(src)
		total_price = 199
		switch(dev_battery)
			if(1) // Basic(300C)
				if(fabricate)
					fabricated_tablet.battery_module = new/obj/item/weapon/computer_hardware/battery_module/nano(fabricated_tablet)
			if(2) // Upgraded(500C)
				if(fabricate)
					fabricated_tablet.battery_module = new/obj/item/weapon/computer_hardware/battery_module/micro(fabricated_tablet)
				total_price += 199
			if(3) // Advanced(750C)
				if(fabricate)
					fabricated_tablet.battery_module = new/obj/item/weapon/computer_hardware/battery_module(fabricated_tablet)
				total_price += 499
		switch(dev_disk)
			if(1) // Basic(32GQ)
				if(fabricate)
					fabricated_tablet.hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/micro(fabricated_tablet)
			if(2) // Upgraded(64GQ)
				if(fabricate)
					fabricated_tablet.hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/small(fabricated_tablet)
				total_price += 99
			if(3) // Advanced(128GQ)
				if(fabricate)
					fabricated_tablet.hard_drive = new/obj/item/weapon/computer_hardware/hard_drive(fabricated_tablet)
				total_price += 299
		switch(dev_netcard)
			if(1) // Basic(Short-Range)
				if(fabricate)
					fabricated_tablet.network_card = new/obj/item/weapon/computer_hardware/network_card(fabricated_tablet)
				total_price += 99
			if(2) // Advanced (Long Range)
				if(fabricate)
					fabricated_tablet.network_card = new/obj/item/weapon/computer_hardware/network_card/advanced(fabricated_tablet)
				total_price += 299
		if(dev_nanoprint)
			total_price += 99
			if(fabricate)
				fabricated_tablet.nano_printer = new/obj/item/weapon/computer_hardware/nano_printer(fabricated_tablet)
		if(dev_card)
			total_price += 199
			if(fabricate)
				fabricated_tablet.card_slot = new/obj/item/weapon/computer_hardware/card_slot(fabricated_tablet)
		return total_price
	return 0





/obj/machinery/lapvend/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["pick_device"])
		if(state) // We've already picked a device type
			return 0
		devtype = text2num(href_list["pick_device"])
		state = 1
		fabricate_and_recalc_price(0)
		return 1
	if(href_list["clean_order"])
		reset_order()
		return 1
	if((state != 1) && devtype) // Following IFs should only be usable when in the Select Loadout mode
		return 0
	if(href_list["confirm_order"])
		state = 2 // Wait for ID swipe for payment processing
		fabricate_and_recalc_price(0)
		return 1
	if(href_list["hw_battery"])
		dev_battery = text2num(href_list["hw_battery"])
		fabricate_and_recalc_price(0)
		return 1
	if(href_list["hw_disk"])
		dev_disk = text2num(href_list["hw_disk"])
		fabricate_and_recalc_price(0)
		return 1
	if(href_list["hw_netcard"])
		dev_netcard = text2num(href_list["hw_netcard"])
		fabricate_and_recalc_price(0)
		return 1
	if(href_list["hw_tesla"])
		dev_tesla = text2num(href_list["hw_tesla"])
		fabricate_and_recalc_price(0)
		return 1
	if(href_list["hw_nanoprint"])
		dev_nanoprint = text2num(href_list["hw_nanoprint"])
		fabricate_and_recalc_price(0)
		return 1
	if(href_list["hw_card"])
		dev_card = text2num(href_list["hw_card"])
		fabricate_and_recalc_price(0)
		return 1
	return 0

/obj/machinery/lapvend/attack_hand(var/mob/user)
	ui_interact(user)

/obj/machinery/lapvend/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(stat & (BROKEN | NOPOWER | MAINT))
		if(ui)
			ui.close()
		return 0

	var/list/data[0]
	data["state"] = state
	data["devtype"] = devtype
	data["hw_battery"] = dev_battery
	data["hw_disk"] = dev_disk
	data["hw_netcard"] = dev_netcard
	data["hw_tesla"] = dev_tesla
	data["hw_nanoprint"] = dev_nanoprint
	data["hw_card"] = dev_card
	data["totalprice"] = "[total_price]$"

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "computer_fabricator.tmpl", "Personal Computer Vendor", 500, 400)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


obj/machinery/lapvend/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/obj/item/weapon/card/id/I = W.GetID()
	// Awaiting payment state
	if(state == 2)
		if(process_payment(I,W))
			fabricate_and_recalc_price(1)
			if((devtype == 1) && fabricated_laptop)
				fabricated_laptop.forceMove(src.loc)
				fabricated_laptop.close_laptop()
				fabricated_laptop = null
			else if((devtype == 2) && fabricated_tablet)
				fabricated_tablet.forceMove(src.loc)
				fabricated_tablet = null
			ping("Enjoy your new product!")
			state = 3
			return 1
		return 0
	return ..()


// Simplified payment processing, returns 1 on success.
/obj/machinery/lapvend/proc/process_payment(var/obj/item/weapon/card/id/I, var/obj/item/ID_container)
	if(I==ID_container || ID_container == null)
		visible_message("<span class='info'>\The [usr] swipes \the [I] through \the [src].</span>")
	else
		visible_message("<span class='info'>\The [usr] swipes \the [ID_container] through \the [src].</span>")
	var/datum/money_account/customer_account = get_account(I.associated_account_number)
	if (!customer_account || customer_account.suspended)
		ping("Connection error. Unable to connect to account.")
		return 0

	if(customer_account.security_level != 0) //If card requires pin authentication (ie seclevel 1 or 2)
		var/attempt_pin = input("Enter pin code", "Vendor transaction") as num
		customer_account = attempt_account_access(I.associated_account_number, attempt_pin, 2)

		if(!customer_account)
			ping("Unable to access account: incorrect credentials.")
			return 0

	if(total_price > customer_account.money)
		ping("Insufficient funds in account.")
		return 0
	else
		customer_account.money -= total_price
		var/datum/transaction/T = new()
		T.target_name = "Computer Manufacturer (via [src.name])"
		T.purpose = "Purchase of [(devtype == 1) ? "laptop computer" : "tablet microcomputer"]."
		T.amount = total_price
		T.source_terminal = src.name
		T.date = current_date_string
		T.time = worldtime2text()
		customer_account.transaction_log.Add(T)
		return 1