
//////////////////////////////////////
// RUST Core Control computer

/obj/item/weapon/circuitboard/rust_core_control
	name = "Circuit board (RUST core controller)"
	build_path = "/obj/machinery/computer/rust_core_control"
	origin_tech = "programming=4;engineering=5;power=6"

datum/design/rust_core_control
	name = "Circuit Design (RUST core controller)"
	desc = "Allows for the construction of circuit boards used to build a core control console for the RUST fusion engine."
	id = "rust_core_control"
	req_tech = list("programming" = 4, "engineering" = 5, "power" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$gold" = 2000)
	build_path = "/obj/item/weapon/circuitboard/rust_core_control"

//////////////////////////////////////
// RUST Fuel Control computer

/obj/item/weapon/circuitboard/rust_fuel_control
	name = "Circuit board (RUST fuel controller)"
	build_path = "/obj/machinery/computer/rust_fuel_control"
	origin_tech = "programming=4;engineering=5;power=6"

datum/design/rust_fuel_control
	name = "Circuit Design (RUST fuel controller)"
	desc = "Allows for the construction of circuit boards used to build a fuel injector control console for the RUST fusion engine."
	id = "rust_fuel_control"
	req_tech = list("programming" = 4, "engineering" = 5, "power" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$silver" = 2000)
	build_path = "/obj/item/weapon/circuitboard/rust_fuel_control"

//////////////////////////////////////
// RUST Fuel Port board

/obj/item/weapon/module/rust_fuel_port
	name = "Circuit board (RUST fuel port)"
	icon_state = "card_mod"
	origin_tech = "engineering=3;power=4"

datum/design/rust_fuel_port
	name = "Circuit Design (RUST fuel port)"
	desc = "Allows for the construction of circuit boards used to build a fuel injection port for the RUST fusion engine."
	id = "rust_fuel_port"
	req_tech = list("programming" = 4, "engineering" = 5, "magnets" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$uranium" = 3000)
	build_path = "/obj/item/weapon/module/rust_fuel_port"

//////////////////////////////////////
// RUST Fuel Compressor board

/obj/item/weapon/module/rust_fuel_compressor
	name = "Circuit board (RUST fuel compressor)"
	icon_state = "card_mod"
	origin_tech = "power=4;engineering=5;plasmatech=6"

datum/design/rust_fuel_compressor
	name = "Circuit Design (RUST fuel compressor)"
	desc = "Allows for the construction of circuit boards used to build a fuel compressor of the RUST fusion engine."
	id = "rust_fuel_compressor"
	req_tech = list("power" = 4, "engineering" = 5, "plasmatech" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$plasma" = 3000, "$diamond" = 1000)
	build_path = "/obj/item/weapon/module/rust_fuel_compressor"

//////////////////////////////////////
// RUST Tokamak Core board

/obj/item/weapon/circuitboard/rust_core
	name = "Circuit Design (RUST tokamak core)"
	build_path = "/obj/machinery/power/rust_core"
	board_type = "machine"
	origin_tech = "bluespace=3;engineering=4;plasmatech=5;magnets=6;power=7"
	frame_desc = "Requires 2 Pico Manipulators, 1 Ultra Micro-Laser, 5 Pieces of Cable, 1 Subspace Crystal and 1 Console Screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator/pico" = 2,
							"/obj/item/weapon/stock_parts/micro_laser/ultra" = 1,
							"/obj/item/weapon/stock_parts/subspace/crystal" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1,
							"/obj/item/weapon/cable_coil" = 5)

datum/design/rust_core
	name = "Circuit board (RUST tokamak core)"
	desc = "The circuit board that for a RUST-pattern tokamak fusion core."
	id = "pacman"
	req_tech = list(bluespace = 3, engineering = 4, plasmatech = 5, magnets = 6, power = 7)
	build_type = IMPRINTER
	reliability_base = 79
	materials = list("$glass" = 2000, "sacid" = 20, "$plasma" = 3000, "$diamond" = 2000)
	build_path = "/obj/item/weapon/circuitboard/rust_core"

//////////////////////////////////////
// RUST Fuel Injector board

/obj/item/weapon/circuitboard/rust_injector
	name = "Circuit Design (RUST fuel injector)"
	build_path = "/obj/machinery/power/rust_fuel_injector"
	board_type = "machine"
	origin_tech = "power=3;engineering=4;plasmatech=5;magnets=6;materials=7"
	frame_desc = "Requires 2 Pico Manipulators, 1 Phasic Scanning Module, 1 Super Matter Bin, 1 Console Screen and 5 Pieces of Cable."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator/pico" = 2,
							"/obj/item/weapon/stock_parts/scanning_module/phasic" = 1,
							"/obj/item/weapon/stock_parts/matter_bin/super" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1,
							"/obj/item/weapon/cable_coil" = 5)

datum/design/rust_injector
	name = "Circuit board (RUST tokamak core)"
	desc = "The circuit board that for a RUST-pattern particle accelerator."
	id = "pacman"
	req_tech = list(power = 3, engineering = 4, plasmatech = 5, magnets = 6, materials = 7)
	build_type = IMPRINTER
	reliability_base = 79
	materials = list("$glass" = 2000, "sacid" = 20, "$plasma" = 3000, "$uranium" = 2000)
	build_path = "/obj/item/weapon/circuitboard/rust_core"
