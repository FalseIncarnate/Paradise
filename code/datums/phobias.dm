
/datum/phobia
	var/name = "fear"	//plain words for what the fear is
	var/sci_name = "phobia"	//scientific name for the fear (or a close approximation if fake)
	var/desc = "The only thing we have to fear..."
	var/sanity_value = 0.0	//set to a negative number, this is how much we change their sanity
	var/severity = 3	//Severity scale: Minor = 3, Moderate = 2, Severe = 1

/datum/phobia/proc/check_conditions(mob/my_body)
	//override this proc with the actual condition checking code
	//all severities should be able to use the same checks, or else the fear isn’t well defined
	return FALSE

/datum/phobia/proc/change_severity(change)	//this is a bit confusing, but a high number is less severe, so a positive change is the phobia being overcome
	if(!change)
		return
	if(change == 1 && severity < 3)
		severity++
	else if(change == -1 && severity > 1)
		severity--

/datum/phobia/darkness
	name = "darkness"
	sci_name = "Nyctophobia"
	desc = "Commonly held by children, Nyctophobia is a fear of darkness."
	sanity_value = -1.0
	var/fear_level = 1	//how dark must it be to scare us?

/datum/phobia/darkness/change_severity(change)
	..(change)
	switch(severity)
		if(1)
			sanity_value = -5.0
			fear_level = 5
		if(2)
			sanity_value = -3.0
			fear_level = 3
		if(3)
			sanity_value = -1.0
			fear_level = 1

/datum/phobia/darkness/check_conditions(mob/my_body)
	if(!my_body)
		return FALSE
	var/turf/T = get_turf(my_body)
	if(!T)
		return FALSE
	if(T.get_lumcount() * 10 <= fear_level)
		return TRUE
	return FALSE


/datum/phobia/small_spaces
	name = "small spaces"
	sci_name = "Claustrophobia"
	desc = "Claustrophobia is the fear of small or confined spaces."
	sanity_value = -0.5
	var/percent = 75		//percentage of tiles that must be or contain dense objects to scare us

/datum/phobia/small_spaces/change_severity(change)
	..(change)
	switch(severity)
		if(1)
			sanity_value = -1.5
			percent = 25
		if(2)
			sanity_value = -1.0
			percent = 50
		if(3)
			sanity_value = -0.5
			percent = 75

/datum/phobia/small_spaces/check_conditions(mob/my_body)
	if(!my_body)
		return FALSE
	var/dense_tiles = 0
	var/total_tiles = 0
	for(var/turf/T in view(my_body, 3))
		total_tiles++
		if(T.density)
			dense_tiles++
			continue
		for(var/obj/O in T)
			if(O.density)
				dense_tiles++
				break
	var/dense_percent = (dense_tiles / total_tiles) * 100
	if(dense_percent >= percent)
		return TRUE
	return FALSE


/datum/phobia/crowds
	name = "crowds"
	sci_name = "Enochlophobia"
	desc = "Enochlophobia is the fear of crowds, especially being in one."
	sanity_value = -0.5
	var/crowd_size = 10	//how many people (other than us) before the crowd is too big for us?

/datum/phobia/crowds/change_severity(change)
	..(change)
	switch(severity)
		if(1)
			sanity_value = -1.5
			crowd_size = 3
		if(2)
			sanity_value = -1.0
			crowd_size = 5
		if(3)
			sanity_value = -0.5
			crowd_size = 10

/datum/phobia/crowds/check_conditions(mob/my_body)
	if(!my_body)
		return FALSE
	var/crowd = 0
	for(var/mob/living/carbon/human/H in view(my_body, 3))
		if(H == my_body)
			continue
		if(H.stat == DEAD || H.stat == UNCONSCIOUS)		//unconscious people don't count as part of a crowd to us
			continue
		crowd++
	if(crowd >= crowd_size)
		return TRUE
	return FALSE


/datum/phobia/spiders
	name = "spiders"
	sci_name = "Arachnophobia"
	desc = "Arachnophobia is the fear of spiders... and completely reasonable."
	sanity_value = -1.0
	var/danger_zone = 3	//how close can we get to a spider before we freak out?

/datum/phobia/spiders/change_severity(change)
	..(change)
	switch(severity)
		if(1)
			sanity_value = -5.0
			danger_zone = 99 //we only check in sight range, so this is overkill but whatever. mostly safeguarding against future changes to view_range
		if(2)
			sanity_value = -2.5
			danger_zone = 5
		if(3)
			sanity_value = -1.0
			danger_zone = 3

/datum/phobia/spiders/check_conditions(mob/my_body)
	if(!my_body)
		return FALSE
	var/in_danger = FALSE
	for(var/mob/living/simple_animal/hostile/H in view(my_body))
		if(istype(H, /mob/living/simple_animal/hostile/poison/giant_spider))
			if(get_dist(my_body, H) <= danger_zone)
				in_danger = TRUE
				break
		if(istype(H, /mob/living/simple_animal/hostile/poison/terror_spider))
			if(get_dist(my_body, H) <= danger_zone)
				in_danger = TRUE
				break
		if(istype(H, /mob/living/simple_animal/hostile/retaliate/araneus))
			if(get_dist(my_body, H) <= danger_zone)
				in_danger = TRUE
				break
	if(!in_danger)
		for(var/obj/structure/spider/spiderling/S in view(my_body))
			if(get_dist(S, my_body) <= danger_zone)
				in_danger = TRUE
				break
	if(in_danger)
		return TRUE
	return FALSE


/datum/phobia/alien_races
	name = "alien races"
	sci_name = "Xenophobia"
	desc = "Xenophobia is the fear of the alien... races."
	sanity_value = -0.1
	var/unacceptable = 5	//how much xeno scum can we tolerate before it is too much to handle

/datum/phobia/alien_races/change_severity(change)
	..(change)
	switch(severity)
		if(1)
			sanity_value = -1.5
			unacceptable = 1
		if(2)
			sanity_value = -1.0
			unacceptable = 3
		if(3)
			sanity_value = -0.1
			unacceptable = 5

/datum/phobia/alien_races/check_conditions(mob/my_body)
	if(!my_body)
		return FALSE
	var/my_species = my_body.get_species()
	var/list/primitives = list("Monkey", "Stok", "Farwa", "Wolpin", "Neara")	//nymphs aren't in here because they are a separate mob type and not a species
	if(my_species in primitives)	//we will ignore our xenophobia if we are a primitive form, too unevolved for concepts of race
		return FALSE
	var/aliens = 0
	for(var/mob/living/carbon/human/H in view(my_body))
		if(H == my_body)	//no matter what we become, we won't be afraid of our own body
			continue
		if(is_species(H, my_species))	//we're cool with our own species, even if it isn't our original
			continue
		if(H.get_species() in primitives)	//primitive forms aren't really a race to be feared... damn dirty apes
			continue
		aliens++
	if(aliens >= unacceptable)		//too many, get scared
		return TRUE
	return FALSE


/datum/phobia/large_spaces
	name = "large spaces"
	sci_name = "Agoraphobia"
	desc = "Agoraphobia is the polar opposite of claustrophobia:the fear of open spaces."
	sanity_value = -0.1
	var/percent = 25	//percentage of dense tiles needed to keep us calm

/datum/phobia/large_spaces/change_severity(change)
	..(change)
	switch(severity)
		if(1)
			sanity_value = -1.0
			percent = 75
		if(2)
			sanity_value = -0.5
			percent = 50
		if(3)
			sanity_value = -0.1
			percent = 25

/datum/phobia/large_spaces/check_conditions(mob/my_body)
	if(!my_body)
		return FALSE
	var/dense_tiles = 0
	var/total_tiles = 0
	for(var/turf/T in view(my_body, 3))
		total_tiles++
		if(T.density)
			dense_tiles++
			continue
		for(var/obj/O in T)
			if(O.density)
				dense_tiles++
				break
	var/dense_percent = (dense_tiles / total_tiles) * 100
	if(dense_percent < percent)
		return TRUE
	return FALSE


/datum/phobia/solitude
	name = "solitude"
	sci_name = "Monophobia"
	desc = "Commonly associated with separation anxiety, Monophobia is the fear of being alone."
	sanity_value = -0.1
	var/crowd_size = 0		//number of people needed nearby to keep us from feeling alone

/datum/phobia/solitude/change_severity(change)
	..(change)
	switch(severity)
		if(1)
			sanity_value = -1.0
			crowd_size = 5
		if(2)
			sanity_value = -0.5
			crowd_size = 3
		if(3)
			sanity_value = -0.1
			crowd_size = 0

/datum/phobia/solitude/check_conditions(mob/my_body)
	if(!my_body)
		return FALSE
	var/crowd = 0
	for(var/mob/living/carbon/human/H in view(my_body, 3))
		if(H == my_body)	//we don't count as keeping ourselves company, otherwise we'd never feel truly alone
			continue
		if(H.stat == DEAD)	//unconscious people count so we don't feel truly alone when someone is sleeping nearby (unlike in the fear of crowds conditions)
			continue
		crowd++
	if(crowd <= crowd_size)
		return TRUE
	return FALSE


/datum/phobia/blood
	name = "blood"
	sci_name = "Hemophobia"
	desc = "Hemophobia is the fear of- is that blood? Oh god..."
	sanity_value = -0.1
	var/unacceptable = 10		//how much blood we can tolerate before it overwhelms us in fear

/datum/phobia/blood/change_severity(change)
	..(change)
	switch(severity)
		if(1)
			sanity_value = -1.0
			unacceptable = 1
		if(2)
			sanity_value = -0.5
			unacceptable = 5
		if(3)
			sanity_value = -0.1
			unacceptable = 10

/datum/phobia/blood/check_conditions(mob/my_body)
	if(!my_body)
		return FALSE
	var/blood = 0
	for(var/obj/effect/E in view(my_body))
		if(istype(E, /obj/effect/rune))
			blood++
		if(istype(E, /obj/effect/decal/cleanable/blood))
			if(istype(E, /obj/effect/decal/cleanable/blood/oil))
				continue
			if(istype(E, /obj/effect/decal/cleanable/blood/gibs/robot))
				continue
			//ideally we should add a way to tell if tracks/footprints are blood or oil, but we can't... so they'll all have to count for now.
			blood++
	if(blood >= unacceptable)
		return TRUE
	return FALSE


/datum/phobia/technology
	name = "technology"
	sci_name = "Technophobia"
	desc = "Not to be confused with Space Amish, Technophobia is the fear of advanced technologies."
	sanity_value = -0.5
	var/unacceptable = 5	//how much advanced tech we can tolerate before it overwhelms us

/datum/phobia/technology/change_severity(change)
	..(change)
	switch(severity)
		if(1)
			sanity_value = -1.5
			unacceptable = 1
		if(2)
			sanity_value = -1.0
			unacceptable = 3
		if(3)
			sanity_value = -0.5
			unacceptable = 5

/datum/phobia/technology/check_conditions(mob/my_body)
	if(!my_body)
		return
	var/tech = 0
	for(var/obj/mecha/M in view(my_body))
		if(M.state)		//only complete and functional mechs scare us, otherwise they are big metal statues
			tech++
	for(var/mob/living/L in view(my_body))
		if(L == my_body)
			return
		if(issilicon(L))		//AI, Cyborg, and pAI mobs
			tech++
		if(isbot(L))			//Robots (like the floorbot)
			tech++
		if(isswarmer(L))		//Swarmers (duh)
			tech++
		if(L.isSynthetic())		//pretty much an IPC check that doesn't take more type-casting (this should probably return true for the above mobs too)
			tech++
	if(tech >= unacceptable)
		return TRUE
	return FALSE