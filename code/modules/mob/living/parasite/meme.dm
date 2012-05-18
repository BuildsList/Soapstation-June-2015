// === MEMETIC ANOMALY ===
// =======================

/**
This life form is a form of parasite that can gain a certain level of control
over its host. Its player will share vision and hearing with the host, and it'll
be able to influence the host through various commands.
**/

// The maximum amount of points a meme can gather.
var/global/const/MAXIMUM_MEME_POINTS = 500


// === PARASITE ===
// ================

// a list of all the parasites in the mob
mob/living/carbon/var/list/parasites = list()

mob/living/parasite
	var
		mob/living/carbon/host // the host that this parasite occupies

	Login()
		..()

		// make the client see through the host instead
		client.eye = host
		client.perspective = EYE_PERSPECTIVE


mob/living/parasite/proc/enter_host(mob/living/carbon/host)
	// by default, parasites can't share a body with other life forms
	if(host.parasites.len > 0)
		return 0

	src.host = host
	host.parasites.Add(src)

	if(client) client.eye = host

	return 1

mob/living/parasite/proc/exit_host()
	src.host.parasites.Remove(src)
	src.host = null

	return 1


// === MEME ===
// ============

// Memes use points for many actions
mob/living/parasite/meme/var/meme_points = 100
mob/living/parasite/meme/var/dormant = 0

// Memes have a list of indoctrinated hosts
mob/living/parasite/meme/var/list/indoctrinated = list()

mob/living/parasite/meme/Life()
	..()

	// recover meme points slowly
	var/gain = 1
	if(dormant) gain = 3 // dormant recovers points faster

	meme_points = min(meme_points + gain, MAXIMUM_MEME_POINTS)

	if(host)
		// if there are sleep toxins in the host's body, that's bad
		if(host.reagents.has_reagent("stoxin"))
			src << "\red <b>Something in your host's blood makes you lose consciousness.. you fade away..</b>"
			src.death()
			return
		// a host without brain is no good
		if(!host.mind)
			src << "\red <b>Your host has no mind.. you fade away..</b>"
			src.death()
			return
		if(host.stat == 2)
			src << "\red <b>Your host has died.. you fade away..</b>"
			src.death()
			return

	if(host.blinded) src.blinded = 1
	else 			 src.blinded = 0


mob/living/parasite/meme/death()
	// make sure the mob is on the actual map before gibbing
	if(host) src.loc = host.loc
	return ..(1)

// When a meme speaks, it speaks through its host
mob/living/parasite/meme/say(message as text)
	if(dormant)
		usr << "\red You're dormant!"
		return
	if(!host)
		usr << "\red You can't speak without host!"
		return

	return host.say(message)

// Same as speak, just with whisper
mob/living/parasite/meme/whisper(message as text)
	if(dormant)
		usr << "\red You're dormant!"
		return
	if(!host)
		usr << "\red You can't speak without host!"
		return

	return host.whisper(message)

// Make the host do things
mob/living/parasite/meme/me_verb(message as text)
	set name = "Me"


	if(dormant)
		usr << "\red You're dormant!"
		return

	if(!host)
		usr << "\red You can't emote without host!"
		return

	return host.me_verb(message)

// A meme understands everything their host understands
mob/living/parasite/meme/say_understands(mob/other)
	if(!host) return 0

	return host.say_understands(other)

// Try to use amount points, return 1 if successful
mob/living/parasite/meme/proc/use_points(amount)
	if(dormant)
		usr << "\red You're dormant!"
		return
	if(src.meme_points < amount)
		src << "<b>* You don't have enough meme points(need [amount]).</b>"
		return 0

	src.meme_points -= round(amount)
	return 1

// Let the meme choose one of his indoctrinated mobs as target
mob/living/parasite/meme/proc/select_indoctrinated(var/title, var/message)
	var/list/candidates

	// Can only affect other mobs thant he host if not blinded
	if(blinded)
		candidates = list()
		src << "\red You are blinded, so you can not affect mobs other than your host."
	else
		candidates = indoctrinated.Copy()

	candidates.Add(src.host)

	var/mob/target = null
	if(candidates.len == 1)
		target = candidates[1]
	else
		target = input(message,title) as null|mob in candidates

	return target


// A meme can make people hear things with the thought ability
mob/living/parasite/meme/verb/Thought()
	set category = "Meme"

	if(meme_points < 150)
		// just call use_points() to give the standard failure message
		use_points(150)
		return

	var/list/candidates = indoctrinated.Copy()
	candidates.Add(src.host)

	var/mob/target = select_indoctrinated("Thought", "Select a target which will hear your thought.")

	if(!target) return

	var/speaker = input("Select the voice in which you would like to make yourself heard.", "Voice") as null|text
	if(!speaker) return

	var/message = input("What would you like to say?", "Message") as null|text
	if(!message) return

	// Use the points at the end rather than the beginning, because the user might cancel
	if(!use_points(150)) return

	message = say_quote(message)
	var/rendered = "<span class='game say'><span class='name'>[speaker]</span> <span class='message'>[message]</span></span>"
	target.show_message(rendered)

	usr << "<i>You make [target] hear:</i> [rendered]"

// Mutes the host
mob/living/parasite/meme/verb/Mute()
	set category = "Meme"

	if(!src.host) return
	if(!host.speech_allowed)
		usr << "\red Your host already can't speak.."
		return
	if(!use_points(250)) return

	spawn
		// backup the host incase we switch hosts after using the verb
		var/mob/host = src.host

		host << "\red Your tongue feels numb.. You lose your ability to speak."
		usr << "\red Your host can't speak anymore."

		host.speech_allowed = 0

		sleep(1200)

		host.speech_allowed = 1
		host << "\red Your tongue has feeling again.."
		usr << "\red [host] can speak again."

// Makes the host unable to emote
mob/living/parasite/meme/verb/Paralyze()
	set category = "Meme"

	if(!src.host) return
	if(!host.emote_allowed)
		usr << "\red Your host already can't use body language.."
		return
	if(!use_points(250)) return

	spawn
		// backup the host incase we switch hosts after using the verb
		var/mob/host = src.host

		host << "\red Your body feels numb.. You lose your ability to use body language."
		usr << "\red Your host can't use body language anymore."

		host.emote_allowed = 0

		sleep(1200)

		host.emote_allowed = 1
		host << "\red Your body has feeling again.."
		usr << "\red [host] can use body language again."



// Cause great agony with the host, used for conditioning the host
mob/living/parasite/meme/verb/Agony()
	set category = "Meme"

	if(!src.host) return
	if(!use_points(200)) return

	spawn
		// backup the host incase we switch hosts after using the verb
		var/mob/host = src.host

		host.paralysis = max(host.paralysis, 2)

		host.flash_pain()
		host << "\red <font size=5>You feel excrutiating pain all over your body! It is so bad you can't think or articulate yourself properly..</font>"

		usr << "<b>You send a jolt of agonizing pain through [host], they should be unable to concentrate on anything else for half a minute.</b>"

		host.emote("scream")

		for(var/i=0, i<10, i++)
			sleep(50)
			if(prob(50)) host.flash_pain()
			if(prob(10)) host.paralysis = max(host.paralysis, 2)
			if(prob(15)) host.emote("twitch")
			else if(prob(15)) host.emote("scream")
			else if(prob(10)) host.emote("collapse")

			if(i == 10)
				host << "\red THE PAIN! AGHH, THE PAIN! MAKE IT STOP! ANYTHING TO MAKE IT STOP!"

		host << "\red The pain subsides.."

// Cause great joy with the host, used for conditioning the host
mob/living/parasite/meme/verb/Joy()
	set category = "Meme"

	if(!src.host) return
	if(!use_points(200)) return

	spawn
		var/mob/host = src.host
		host.druggy = max(host.druggy, 50)
		host.slurring = max(host.slurring, 10)

		usr << "<b>You stimulate [host.name]'s brain, injecting waves of endorphines and dopamine into the tissue. They should now forget all their worries, particularly relating to you, for around a minute."

		host << "\red You are feeling wonderful! Your head is numb and drowsy, and you can't help forgetting all the worries in the world."

		while(host.druggy > 0)
			sleep(10)

		host << "\red You are feeling clear-headed again.."

// Cause the target to hallucinate.
mob/living/parasite/meme/verb/Hallucinate()
	set category = "Meme"

	if(!src.host) return
	if(!use_points(300)) return

	var/mob/target = select_indoctrinated("Hallucination", "Who should hallucinate?")

	target.hallucination += 100

	usr << "<b>You make [target] hallucinate.</b>"

// Jump to a closeby target through a whisper
mob/living/parasite/meme/verb/SubtleJump(mob/living/carbon/human/target as mob in world)
	set category = "Meme"

	if(!istype(target, /mob/living/carbon/human) || !target.mind)
		src << "<b>You can't jump to this creature..</b>"
		return
	if(!(target in view(1, host)+src))
		src << "<b>The target is not close enough.</b>"
		return

	// Find out whether we can speak
	if (host.silent || (host.disabilities & 64))
		src << "<b>Your host can't speak..</b>"
		return

	if(!use_points(350)) return

	for(var/mob/M in view(1, host))
		M.show_message("<B>[host]</B> whispers something incoherent.",2) // 2 stands for hearable message

	// Find out whether the target can hear
	if(target.disabilities & 32 || target.ear_deaf)
		src << "<b>Your target doesn't seem to hear you..</b>"
		return

	src.exit_host()
	src.enter_host(target)

	usr << "<b>You successfully jumped to [target]."

// Jump to a distant target through a shout
mob/living/parasite/meme/verb/ObviousJump(mob/living/carbon/human/target as mob in world)
	set category = "Meme"

	if(!istype(target, /mob/living/carbon/human) || !target.mind)
		src << "<b>You can't jump to this creature..</b>"
		return
	if(!(target in view(host)))
		src << "<b>The target is not close enough.</b>"
		return

	// Find out whether we can speak
	if (host.silent || (host.disabilities & 64))
		src << "<b>Your host can't speak..</b>"
		return

	if(!use_points(500)) return

	for(var/mob/M in view(host)+src)
		M.show_message("<B>[host]</B> screams something incoherent!",2) // 2 stands for hearable message

	// Find out whether the target can hear
	if(target.disabilities & 32 || target.ear_deaf)
		src << "<b>Your target doesn't seem to hear you..</b>"
		return

	src.exit_host()
	src.enter_host(target)

	usr << "<b>You successfully jumped to [target]."

// ATTUNE a mob, adding it to the indoctrinated list
mob/living/parasite/meme/verb/Attune()
	set category = "Meme"

	if(host in src.indoctrinated)
		usr << "<b>You have already attuned this host.</b>"
		return

	if(!host) return
	if(!use_points(400)) return

	src.indoctrinated.Add(host)

	usr << "<b>You successfully indoctrinated [host]."

// Enables the mob to take a lot more damage
mob/living/parasite/meme/verb/Analgesic()
	set category = "Meme"

	if(!host) return
	if(!(host in indoctrinated))
		usr << "\red You need to attune the host first."
		return
	if(!use_points(500)) return

	usr << "<b>You inject drugs into [host]."
	host << "\red You feel your body strengthen and your pain subside.."
	host.analgesic = 60
	while(host.analgesic > 0)
		sleep(10)
	host << "\red The dizziness wears off, and you can feel pain again.."


// Take control of the mob
mob/living/parasite/meme/verb/Possession()
	set category = "Meme"

	if(!host) return
	if(!(host in indoctrinated))
		usr << "\red You need to attune the host first."
		return
	if(!use_points(500)) return

	usr << "<b>You take control of [host]!</b>"
	host << "\red Everything goes black.."

	spawn
		var/mob/dummy = new
		var/client/host_key = host.key
		var/client/meme_key = src.key

		dummy.key = host_key
		host.key = meme_key

		sleep(600)

		host.key = host_key
		src.key = meme_key
		src << "\red You lose control.."

		del dummy

// Enter dormant mode, increases meme point gain
mob/living/parasite/meme/verb/Dormant()
	set category = "Meme"

	if(!host) return
	if(!use_points(100)) return

	usr << "<b>You enter dormant mode.. You won't be able to take action until all your points have recharged.</b>"

	dormant = 1

	while(meme_points < 500)
		sleep(10)

	dormant = 0

	usr << "\red You have regained all points and exited dormant mode!"


// TEST CODE
client/verb/become_meme(target as mob in world)
	var/mob/living/parasite/meme/M = new
	M.enter_host(target)
	src.mob = M
// END TEST CODE