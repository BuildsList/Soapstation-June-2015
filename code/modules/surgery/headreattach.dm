//This is an uguu head restoration surgery TOTALLY not yoinked from chinsky's limb reattacher
/datum/surgery_step/attach_bodypart
	priority = 3 // Must be higher than /datum/surgery_step/internal
	allowed_tools = list(/obj/item/organ/external = 100)
	can_infect = 0

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/E = target.get_organ(target_zone)
		return isnull(E) && !isnull(target.species.has_limbs[target_zone])

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/E = tool
		user.visible_message("[user] starts attaching [E.name] to [target]'s [E.amputation_point].", \
		"You start attaching [E.name] to [target]'s [E.amputation_point].")

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/E = tool
		user.visible_message("\blue [user] has attached [target]'s [E.name] to the [E.amputation_point].",	\
		"\blue You have attached [target]'s [E.name] to the [E.amputation_point].")
		user.drop_from_inventory(E)
		E.replaced(target)
		E.loc = target
		target.update_body()
		target.updatehealth()
		target.UpdateDamageIcon()

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/E = tool
		user.visible_message("\red [user]'s hand slips, damaging [target]'s [E.amputation_point]!", \
		"\red Your hand slips, damaging [target]'s [E.amputation_point]!")
		target.apply_damage(10, BRUTE, null, sharp=1)

/datum/surgery_step/connect_bodypart
	priority = 3
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/stack/cable_coil = 75, 	\
	/obj/item/device/assembly/mousetrap = 20
	)
	can_infect = 1

	min_duration = 120
	max_duration = 150

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/E = target.get_organ(target_zone)
		return E && (E.status & ORGAN_DESTROYED)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/E = target.get_organ(target_zone)
		user.visible_message("[user] starts connecting tendons and muscles in [target]'s [E.amputation_point] with [tool].", \
		"You start connecting tendons and muscle in [target]'s [E.amputation_point].")

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/E = target.get_organ(target_zone)
		user.visible_message("\blue [user] has connected tendons and muscles in [target]'s [E.amputation_point] with [tool].",	\
		"\blue You have connected tendons and muscles in [target]'s [E.amputation_point] with [tool].")
		E.status &= ~ORGAN_DESTROYED
		if(E.children)
			for(var/obj/item/organ/external/C in E.children)
				C.status &= ~ORGAN_DESTROYED
		target.update_body()
		target.updatehealth()
		target.UpdateDamageIcon()

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/E = tool
		user.visible_message("\red [user]'s hand slips, damaging [target]'s [E.amputation_point]!", \
		"\red Your hand slips, damaging [target]'s [E.amputation_point]!")
		target.apply_damage(10, BRUTE, null, sharp=1)