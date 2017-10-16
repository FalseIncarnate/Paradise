
/mob/living/simple_animal/defense
	name = "defense mob"
	desc = "Kill it or it will kill the objective!"
	icon = 'icons/mobs/defense_mobs.dmi'
	icon_state = "default"
	faction = list("defense", "hostile")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speak_chance = 0
	speed = 1
	maxHealth = 50
	health = 50

	turns_per_move = 1
	turns_since_move = 0
	universal_speak = 0
	stop_automated_movement = 0 //Use this to temporarely stop random movement or to if you write special movement code for animals.
	wander = 1	// Does the mob wander around when idle?
	stop_automated_movement_when_pulled = 0

	var/seeks_goal = 1		//determines how the mob handles goal-seeking. 0 ignores goal entirely, 1 seeks goal and players, 2 seeks goal and ignores players
	var/obj/structure/defense_objective/goal = null

/mob/living/simple_animal/defense/New()
	..()
	if(!seeks_goal)	//if we ignore the goal, don't bother setting it in the first place
		return
	for(var/obj/structure/defense_objective/maybe_goal in world)
		if(maybe_goal.z == z)
			goal = maybe_goal
			break

/mob/living/simple_animal/defense/Destroy()
	goal = null
	return ..()

/mob/living/simple_animal/defense/process_ai()
