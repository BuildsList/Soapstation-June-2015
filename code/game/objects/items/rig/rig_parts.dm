/obj/item/rig_parts
	name = "rig parts"
	icon = 'icons/obj/robot_parts.dmi'
	item_state = "buildpipe"
	icon_state = "blank"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/construction_time = 100
	var/list/construction_cost = list("metal"=20000,"glass"=5000)
	var/list/part = null

/obj/item/rig_parts/circuits
	name = "robot left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_arm"
	construction_time = 200
	construction_cost = list("metal"=18000)

/obj/item/rig_parts/rig_case
	name = "Rig Control Case"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon_state = "robo_suit"
	construction_time = 500
	construction_cost = list("metal"=50000)
	var/obj/item/robot_parts/l_arm/l_arm = null
	var/obj/item/robot_parts/r_arm/r_arm = null
	var/obj/item/robot_parts/l_leg/l_leg = null
	var/obj/item/robot_parts/r_leg/r_leg = null
	var/obj/item/robot_parts/chest/chest = null
	var/obj/item/robot_parts/head/head = null
	var/created_name = ""