
/obj/structure/defense_objective
	name = "Defense Objective"
	desc = "Defend this with your lives!"
	icon = 'icons/obj/halloween_objects.dmi'
	icon_state = "crystal"
	light_range = 5
	light_color = LIGHT_COLOR_WHITE
	anchored = 1
	density = 1
	var/health_remaining = 100
	var/ex_string = ""
	var/fail_event = null

/obj/structure/defense_objective/halloween
	name = "Life Crystal"
	desc = "Defend this with your lives to halt the spread of necromantic energies!"
	fail_event = /datum/event/undead

/obj/structure/defense_objective/Destroy()
	for(var/mob/living/simple_animal/defense/D in world)
		if(D.goal == src)
			D.goal = null
	if(fail_event)
		new fail_event(new /datum/event_meta(EVENT_LEVEL_MAJOR, "Defense Failure")
	return ..()

/obj/structure/defense_objective/proc/update_health(change = 0)
	if(change)
		health_remaining += change

	if(health_remaining <= 0)
		visible_message("<span class='userdanger'>The [name] explodes from its sustained damage!</span>", "<span class='userdanger'>You hear an explosion followed by eerie silence.</span>")
		qdel(src)
		return

	if(change)
		if(health_remaining > 75)
			ex_string = ""
		else if(health_remaining >= 50)
			ex_string = "<span class='notice'>The [name] is starting to crack.</span>"
		else if(health_remaining >= 25)
			ex_string = "<span class='warning'>The [name] looks unstable!</span>"
		else if(health_remaining > 1)
			ex_string = "<span class='danger'>The [name] can't withstand much more! It's falling apart!</span>"
		else if health_remaing == 1)
			ex_string = "<span class='userdanger'>One more hit and [name] will be destroyed!!!</span>"
		else
			ex_string = "How are you seeing this? Alert a coder!"

/obj/structure/defense_objective/examine(mob/user)
	..(user)
	to_chat(user, "[ex_string] (Health Remaining: [health_remaining])")

/obj/structure/defense_objective/ex_act(severity)
	switch(severity)
		if(1.0)
			update_health(-10)
		if(2.0)
			update_health(-5)
		if(3.0)
			update_health(-2)
	return

/obj/structure/defense_objective/fire_act()
	return

/obj/structure/defense_objective/singularity_act()
	remaining_health = 0	//game over
	update_health()
	return

/obj/structure/defense_objective/singularity_pull()
	return

/obj/structure/defense_objective/narsie_act()
	return

/obj/structure/defense_objective/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	update_health(-1)

/obj/structure/defense_objective/bullet_act(obj/item/projectile/Proj)
	if(Proj.nodamage)
		return
	update_health(min(1, Proj.damage/10))