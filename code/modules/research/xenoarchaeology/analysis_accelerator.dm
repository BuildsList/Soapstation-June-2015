
obj/machinery/anomaly/accelerator
	name = "Accelerator spectrometer"
	desc = "A specialised, complex analysis machine."
	icon = 'virology.dmi'
	icon_state = "analyser"

obj/machinery/anomaly/accelerator/ScanResults()
	var/results = "The scan was inconclusive. Check sample integrity and carrier consistency."

	var/datum/geosample/scanned_sample
	var/carrier
	var/num_reagents = 0

	for(var/datum/reagent/A in held_container.reagents.reagent_list)
		var/datum/reagent/R = A
		if(istype(R, /datum/reagent/analysis_sample))
			scanned_sample = R.data
		else
			carrier = R.id
		num_reagents++

	if(num_reagents == 2 && scanned_sample && carrier)
		var/specifity = GetResultSpecifity(scanned_sample, carrier)
		var/accuracy = (specifity / (specifity + 0.2))
		results = "Kinetic acceleration  of carrier ([carrier]) indicates age ([100 * accuracy]% accuracy): <br><br>"

		if(scanned_sample.age_billion)
			var/displayed_age_millions = scanned_sample.age_million + max(scanned_sample.age_million * ((1 - accuracy) * (2 * rand() - 1)), 0)
			var/displayed_age_billions = scanned_sample.age_billion + max(scanned_sample.age_billion * ((1 - accuracy) * (2 * rand() - 1)), 0)
			results += "[displayed_age_billions + displayed_age_millions / 1000] billion years.<br>"
		else if(scanned_sample.age_million)
			var/displayed_age_thousands = scanned_sample.age_thousand + max(scanned_sample.age * ((1 - accuracy) * (4 * rand() - 2)), 0)
			var/displayed_age_millions = scanned_sample.age_million + max(scanned_sample.age_million * ((1 - accuracy) * (2 * rand() - 1)), 0)
			results += "[displayed_age_millions + displayed_age_thousands / 1000] million years.<br>"
		else if(scanned_sample.age_thousand)
			var/displayed_age = scanned_sample.age + max(scanned_sample.age * ((1 - accuracy) * (8 * rand() - 4)), 0)
			var/displayed_age_thousands = scanned_sample.age_thousand + max(scanned_sample.age * ((1 - accuracy) * (4 * rand() - 2)), 0)
			results += "[displayed_age_thousands + displayed_age / 1000] thousand years.<br>"
		else
			var/displayed_age = scanned_sample.age + max(scanned_sample.age * ((1 - accuracy) * (8 * rand() - 4)), 0)
			results += "[displayed_age] years.<br>"

		results += "<br>Warning, results only valid for ages on the scale of billions of years."

	return results
