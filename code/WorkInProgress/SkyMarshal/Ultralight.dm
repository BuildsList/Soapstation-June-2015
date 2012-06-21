//UltraLight system, by Sukasa


#define UL_I_FALLOFF_SQUARE 0
#define UL_I_FALLOFF_ROUND 1

#define UL_I_LIT 0
#define UL_I_EXTINGUISHED 1
#define UL_I_ONZERO 2

#define ul_LightingEnabled 1
#define ul_LightingResolution 1
#define ul_Steps 7
#define ul_FalloffStyle UL_I_FALLOFF_ROUND // Sets the lighting falloff to be either squared or circular.
#define ul_Layer 10
#define ul_TopLuminosity 12 //Maximum brightness an object can have.

var
	ul_LightingResolutionSqrt = sqrt(ul_LightingResolution)
	ul_SuppressLightLevelChanges = 0

	list/ul_FastRoot = list(0, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5,
							5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
							7, 7)


proc/ul_Clamp(var/Value)
	return min(max(Value, 0), ul_Steps)

proc/ul_UnblankLocal(var/list/ReApply = view(ul_TopLuminosity, src))
	for(var/atom/Light in ReApply)
		if(Light.ul_IsLuminous())
			Light.ul_Illuminate()
	return

atom/var/LuminosityRed = 0
atom/var/LuminosityGreen = 0
atom/var/LuminosityBlue = 0

atom/var/ul_Extinguished = UL_I_ONZERO

atom/proc/ul_SetLuminosity(var/Red, var/Green = Red, var/Blue = Red)

	if(LuminosityRed == Red && LuminosityGreen == Green && LuminosityBlue == Blue)
		return //No point doing all that work if it won't have any effect anyways...

	if (ul_Extinguished == UL_I_EXTINGUISHED)
		LuminosityRed = min(Red,ul_TopLuminosity)
		LuminosityGreen = min(Green,ul_TopLuminosity)
		LuminosityBlue = min(Blue,ul_TopLuminosity)

		return

	if (ul_IsLuminous())
		ul_Extinguish()

	LuminosityRed = min(Red,ul_TopLuminosity)
	LuminosityGreen = min(Green,ul_TopLuminosity)
	LuminosityBlue = min(Blue,ul_TopLuminosity)

	ul_Extinguished = UL_I_ONZERO

	if (ul_IsLuminous())
		ul_Illuminate()

	return

atom/proc/ul_Illuminate()
	if (ul_Extinguished == UL_I_LIT)
		return

	ul_Extinguished = UL_I_LIT

	luminosity = ul_Luminosity()

	for(var/turf/Affected in view(luminosity, src))
		var/Falloff = src.ul_FalloffAmount(Affected)

		var/DeltaRed = LuminosityRed - Falloff
		var/DeltaGreen = LuminosityGreen - Falloff
		var/DeltaBlue = LuminosityBlue - Falloff

		if(DeltaRed > 0 || DeltaGreen > 0 || DeltaBlue > 0)

			if(DeltaRed > 0)
				if(!Affected.MaxRed)
					Affected.MaxRed = list()
					Affected.MaxRedSources = list()
				if(!(DeltaRed in Affected.MaxRed))
					Affected.MaxRed.Add(DeltaRed)
					Affected.MaxRedSources.Add(1)
				else
					var/list_location = Affected.MaxRed.Find(DeltaRed)
					Affected.MaxRedSources[list_location]++

			if(DeltaGreen > 0)
				if(!Affected.MaxGreen)
					Affected.MaxGreen = list()
					Affected.MaxGreenSources = list()
				if(!(DeltaGreen in Affected.MaxGreen))
					Affected.MaxGreen.Add(DeltaGreen)
					Affected.MaxGreenSources.Add(1)
				else
					var/list_location = Affected.MaxGreen.Find(DeltaGreen)
					Affected.MaxGreenSources[list_location]++

			if(DeltaBlue > 0)
				if(!Affected.MaxBlue)
					Affected.MaxBlue = list()
					Affected.MaxBlueSources = list()
				if(!(DeltaBlue in Affected.MaxBlue))
					Affected.MaxBlue.Add(DeltaBlue)
					Affected.MaxBlueSources.Add(1)
				else
					var/list_location = Affected.MaxBlue.Find(DeltaBlue)
					Affected.MaxBlueSources[list_location]++

			Affected.ul_UpdateLight()

			if (ul_SuppressLightLevelChanges == 0)
				Affected.ul_LightLevelChanged()

				for(var/atom/AffectedAtom in Affected)
					AffectedAtom.ul_LightLevelChanged()
	return

atom/proc/ul_Extinguish()

	if (ul_Extinguished != UL_I_LIT)
		return

	ul_Extinguished = UL_I_EXTINGUISHED

	for(var/turf/Affected in view(ul_Luminosity(), src))

		var/Falloff = ul_FalloffAmount(Affected)

		var/DeltaRed = LuminosityRed - Falloff
		var/DeltaGreen = LuminosityGreen - Falloff
		var/DeltaBlue = LuminosityBlue - Falloff

		if(DeltaRed > 0 || DeltaGreen > 0 || DeltaBlue > 0)

			if(DeltaRed > 0)
				if(Affected.MaxRed)
					var/list_location = Affected.MaxRed.Find(DeltaRed)
					if(list_location)
						if(Affected.MaxRedSources[list_location] > 1)
							Affected.MaxRedSources[list_location]--
						else
							Affected.MaxRed.Remove(DeltaRed)
							Affected.MaxRedSources.Cut(list_location, list_location + 1)
					if(!Affected.MaxRed.len)
						del Affected.MaxRed
						del Affected.MaxRedSources

			if(DeltaGreen > 0)
				if(Affected.MaxGreen)
					var/list_location = Affected.MaxGreen.Find(DeltaGreen)
					if(list_location)
						if(Affected.MaxGreenSources[list_location] > 1)
							Affected.MaxGreenSources[list_location]--
						else
							Affected.MaxGreen.Remove(DeltaGreen)
							Affected.MaxGreenSources.Cut(list_location, list_location + 1)
					if(!Affected.MaxGreen.len)
						del Affected.MaxGreen
						del Affected.MaxGreenSources

			if(DeltaBlue > 0)
				if(Affected.MaxBlue)
					var/list_location = Affected.MaxBlue.Find(DeltaBlue)
					if(list_location)
						if(Affected.MaxBlueSources[list_location] > 1)
							Affected.MaxBlueSources[list_location]--
						else
							Affected.MaxBlue.Remove(DeltaBlue)
							Affected.MaxBlueSources.Cut(list_location, list_location + 1)
					if(!Affected.MaxBlue.len)
						del Affected.MaxBlue
						del Affected.MaxBlueSources

			Affected.ul_UpdateLight()

			if (ul_SuppressLightLevelChanges == 0)
				Affected.ul_LightLevelChanged()

				for(var/atom/AffectedAtom in Affected)
					AffectedAtom.ul_LightLevelChanged()

	luminosity = 0

	return


/*
 Calculates the correct lighting falloff value (used to calculate what brightness to set the turf to) to use,
  when called on a luminous atom and passed an atom in the turf to be lit.

 Supports multiple configurations, BS12 uses the circular falloff setting. This setting uses an array lookup
  to avoid the cost of the square root function.
*/
atom/proc/ul_FalloffAmount(var/atom/ref)
	if (ul_FalloffStyle == UL_I_FALLOFF_ROUND)
		var/x = (ref.x - src.x)
		var/y = (ref.y - src.y)
		if(ul_LightingResolution != 1)
			if (round((x*x + y*y)*ul_LightingResolutionSqrt,1) > ul_FastRoot.len)
				for(var/i = ul_FastRoot.len, i <= round(x*x+y*y*ul_LightingResolutionSqrt,1), i++)
					ul_FastRoot += round(sqrt(i))
			return ul_FastRoot[round((x*x + y*y)*ul_LightingResolutionSqrt, 1) + 1]/ul_LightingResolution

		else
			if ((x*x + y*y) > ul_FastRoot.len)
				for(var/i = ul_FastRoot.len, i <= x*x+y*y, i++)
					ul_FastRoot += round(sqrt(i))
			return ul_FastRoot[x*x + y*y + 1]/ul_LightingResolution

	else if (ul_FalloffStyle == UL_I_FALLOFF_SQUARE)
		return get_dist(src, ref)

	return 0

atom/proc/ul_SetOpacity(var/NewOpacity)
	if(opacity != NewOpacity)

		var/list/Blanked = ul_BlankLocal()

		opacity = NewOpacity

		ul_UnblankLocal(Blanked)

	return

atom/proc/ul_BlankLocal()
	var/list/Blanked = list( )
	var/TurfAdjust = isturf(src) ? 1 : 0

	for(var/atom/Affected in view(ul_TopLuminosity, src))
		if(Affected.ul_IsLuminous() && Affected.ul_Extinguished == UL_I_LIT && (ul_FalloffAmount(Affected) <= Affected.luminosity + TurfAdjust))
			Affected.ul_Extinguish()
			Blanked += Affected

	return Blanked

atom/proc/ul_Luminosity()
	return max(LuminosityRed, LuminosityGreen, LuminosityBlue)

atom/proc/ul_IsLuminous(var/Red = LuminosityRed, var/Green = LuminosityGreen, var/Blue = LuminosityBlue)
	return (Red > 0 || Green > 0 || Blue > 0)

atom/proc/ul_LightLevelChanged()
	//Designed for client projects to use.  Called on items when the turf they are in has its light level changed
	return

atom/New()
	. = ..()
	if(ul_IsLuminous())
		spawn(2)
			ul_Illuminate()

atom/Del()
	if(ul_IsLuminous())
		ul_Extinguish()
	. = ..()

atom/movable/Move()
	if(LuminosityRed || LuminosityGreen || LuminosityBlue)
		ul_Extinguish()
		. = ..()
		ul_Illuminate()
	else
		return ..()


turf/var/list/MaxRed
turf/var/list/MaxGreen
turf/var/list/MaxBlue
turf/var/list/MaxRedSources
turf/var/list/MaxGreenSources
turf/var/list/MaxBlueSources

turf/proc/ul_GetRed()
	if(MaxRed)
		return ul_Clamp(max(MaxRed))
	return 0
turf/proc/ul_GetGreen()
	if(MaxGreen)
		return ul_Clamp(max(MaxGreen))
	return 0
turf/proc/ul_GetBlue()
	if(MaxBlue)
		return ul_Clamp(max(MaxBlue))
	return 0

turf/proc/ul_UpdateLight()
	var/area/CurrentArea = loc

	if(!isarea(CurrentArea) || !CurrentArea.ul_Lighting)
		return

	var/LightingTag = copytext(CurrentArea.tag, 1, findtext(CurrentArea.tag, ":UL")) + ":UL[ul_GetRed()]_[ul_GetGreen()]_[ul_GetBlue()]"

	if(CurrentArea.tag != LightingTag)
		var/area/NewArea = locate(LightingTag)

		if(!NewArea)
			NewArea = new CurrentArea.type()
			NewArea.tag = LightingTag

			for(var/V in CurrentArea.vars - "contents")
				if(issaved(CurrentArea.vars[V]))
					NewArea.vars[V] = CurrentArea.vars[V]

			NewArea.tag = LightingTag

			NewArea.ul_Light(ul_GetRed(), ul_GetGreen(), ul_GetBlue())


		NewArea.contents += src

	return

turf/proc/ul_Recalculate()

	ul_SuppressLightLevelChanges++

	var/list/Lights = ul_BlankLocal()

	ul_UnblankLocal(Lights)

	ul_SuppressLightLevelChanges--

	return

area/var/ul_Overlay = null
area/var/ul_Lighting = 1

area/var/LightLevelRed = 0
area/var/LightLevelGreen = 0
area/var/LightLevelBlue = 0
area/var/list/LightLevels

area/proc/ul_Light(var/Red = LightLevelRed, var/Green = LightLevelGreen, var/Blue = LightLevelBlue)

	if(!src || !src.ul_Lighting)
		return

	overlays -= ul_Overlay
	if(LightLevels)
		if(Red < LightLevels["Red"])
			Red = LightLevels["Red"]
		if(Green < LightLevels["Green"])
			Green = LightLevels["Green"]
		if(Blue < LightLevels["Blue"])
			Blue = LightLevels["Blue"]

	LightLevelRed = Red
	LightLevelGreen = Green
	LightLevelBlue = Blue

	luminosity = ul_IsLuminous(LightLevelRed, LightLevelGreen, LightLevelBlue)

	ul_Overlay = image('ULIcons.dmi', , num2text(LightLevelRed) + "-" + num2text(LightLevelGreen) + "-" + num2text(LightLevelBlue), ul_Layer)

	overlays += ul_Overlay

	return

area/proc/ul_Prep()

	if(!tag)
		tag = "[type]"
	if(ul_Lighting)
		if(!findtext(tag,":UL"))
			ul_Light()
	//world.log << tag

	return

#undef UL_I_FALLOFF_SQUARE
#undef UL_I_FALLOFF_ROUND
#undef UL_I_LIT
#undef UL_I_EXTINGUISHED
#undef UL_I_ONZERO
#undef ul_LightingEnabled
#undef ul_LightingResolution
#undef ul_Steps
#undef ul_FalloffStyle
#undef ul_Layer
#undef ul_TopLuminosity