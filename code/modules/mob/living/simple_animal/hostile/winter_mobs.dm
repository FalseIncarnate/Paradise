//////////////////////////
//		Winter Mobs		//
//////////////////////////

/mob/living/simple_animal/hostile/winter
	faction = list("hostile", "syndicate", "winter")
	speak_chance = 0
	turns_per_move = 5
	speed = 1
	maxHealth = 50
	health = 50
	icon = 'icons/mob/winter_mob.dmi'
	icon_state = "placeholder"
	icon_living = "placeholder"
	icon_dead = "placeholder"

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	melee_damage_lower = 3
	melee_damage_upper = 7

	gold_core_spawnable = CHEM_MOB_SPAWN_HOSTILE

	var/ignore_dist = FALSE	//set to TRUE if this mob will counter cheese tactics at range even if not a ranged fighter

/mob/living/simple_animal/hostile/winter/process_ai()
	anti_cheese()
	..()

/mob/living/simple_animal/hostile/winter/proc/anti_cheese()
	var/list/wrappables = list()
	var/list/breakables = list()
	if(ranged || ignore_dist)
		for(var/obj/structure/S in view())
			if(istype(S, /obj/structure/closet) && !istype(S, /obj/structure/closet/crate))
				wrappables += S
			if(istype(S, /obj/structure/stool/bed))
				breakables += src
	else
		for(var/obj/structure/S in view(2))
			if(istype(S, /obj/structure/closet) && !istype(S, /obj/structure/closet/crate))
				wrappables += S
			if(istype(S, /obj/structure/stool/bed))
				breakables += src

	for(var/obj/structure/closet/C in wrappables)
		wrappables -= C
		if(get_turf(C) == get_turf(src))
			new C.material_drop(get_turf(C), C.material_drop_amount)
			qdel(C)
			continue
		if(C.opened && !C.close())
			continue
		var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(C))
		P.wrapped = C
		C.forceMove(P)
		P.init_welded = C.welded
		C.welded = 1
		P.giftwrapped = 1
		P.icon_state = "giftcloset"

	var/num_to_break = rand(1, breakables.len)
	while(num_to_break > 0)
		var/obj/structure/S = pick(breakables)
		breakables -= S
		S.unbuckle_mob(TRUE)
		if(istype(S, /obj/structure/stool/bed))
			var/obj/structure/stool/bed/B = S
			new B.buildstacktype(get_turf(B), B.buildstackamount)
		qdel(S)

/mob/living/simple_animal/hostile/winter/snowman
	name = "snowman"
	desc = "A very angry snowman. Doesn't look like it wants to play around..."
	maxHealth = 75		//slightly beefier to account for it's need to get in your face
	health = 75
	icon_state = "snowman"
	icon_living = "snowman"
	icon_dead = "snowman-dead"

	bodytemperature = 73.0		//it's made of snow and hatred, so it's pretty cold.
	maxbodytemp = 280.15		//at roughly 7 C, these will start melting (dying) from the warmth. Mind over matter or something.
	heat_damage_per_tick = 10	//Now With Rapid Thawing Action!


/mob/living/simple_animal/hostile/winter/snowman/death(gibbed)
	if(prob(50) && !ranged)		//50% chance to drop candy cane sword on death, if it has one to drop
		loot = list(/obj/item/weapon/melee/candy_sword)
	if(prob(20))	//chance to become a stationary snowman structure instead of a corpse
		loot.Add(/obj/structure/snowman)
		deathmessage = "shimmers as its animating magic fades away!"
		del_on_death = 1
		..()		//this is just to make sure it gets properly killed before we qdel it
	else
		..()

/mob/living/simple_animal/hostile/winter/snowman/ranged
	maxHealth = 50
	health = 50
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/snowball

/mob/living/simple_animal/hostile/winter/reindeer
	name = "reindeer"
	desc = "Apparently murder is a reindeer game."
	icon_state = "reindeer"
	icon_living = "reindeer"
	icon_dead = "reindeer-dead"
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 3)
	maxHealth = 80
	health = 80
	melee_damage_lower = 5
	melee_damage_upper = 10

/mob/living/simple_animal/hostile/winter/santa
	maxHealth = 150		//if this seems low for a "boss", it's because you have to fight him multiple times, with him fully healing between stages
	health = 150
	var/next_stage = null
	var/death_message
	name = "Santa Claus"

	icon_state = "santa"
	icon_living = "santa"
	icon_dead = "santa-dead"

	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	sentience_type = SENTIENCE_BOSS

	ignore_dist = TRUE	//naughty cheese tactics cannot escape his list!
	var/base_chance = 10
	var/list/special_moves = list("self_heal")
	var/using_special = FALSE

	var/list/special_time = list("heal" = 0, "mine" = 0, "wrap" = 0, "adds" = 0)
	var/list/special_cd = list("heal" = 300, "mine" = 400, "wrap" = 300, "adds" = 600)

/mob/living/simple_animal/hostile/winter/santa/death(gibbed)
	..()
	if(death_message)
		visible_message(death_message)
	if(next_stage)
		spawn(10)
			new next_stage(get_turf(src))
			qdel(src)	//hide the body

/mob/living/simple_animal/hostile/winter/santa/process_ai()
	if(using_special)
		return
	if(target)
		var/prob_chance = base_chance
		if(health <= maxHealth * 0.75)
			prob_chance *= 3
		else if(health <= maxHealth * 0.5)
			prob_chance *= 2
		if(prob(prob_chance))
			var/special = pick(special_moves)
			if(call(src, special)())
				return
	else
		if(health < maxHealth)
			var/success = 0
			if("self_heal_big" in special_moves)
				success = self_heal_big()
			else
				success = self_heal()
			if(success)
				return
	..()

/mob/living/simple_animal/hostile/winter/santa/proc/self_heal()
	if(world.time < special_time["heal"])
		return 0
	using_special = TRUE
	visible_message("<span class='warning'>[name] stops to enjoy a refreshing mug of cocoa!</span>")
	if(do_mob(src, src, 30, 1, 0))
		if(!src || health <= 0)
			adjustHealth(-50)
			special_time["heal"] = world.time + special_cd["heal"]
			using_special = FALSE
			return 1
	using_special = FALSE
	return 0

/mob/living/simple_animal/hostile/winter/santa/proc/self_heal_big()
	if(world.time < special_time["heal"])
		return 0
	using_special = TRUE
	visible_message("<span class='warning'>[name] begins devouring milk and cookies!</span>")
	if(do_mob(src, src, 30, 1, 0))
		if(!src || health <= 0)
			adjustHealth(-100)
			special_time["heal"] = world.time + special_cd["heal"]
			using_special = FALSE
			return 1
	using_special = FALSE
	return 0

/mob/living/simple_animal/hostile/winter/santa/proc/present_mines()
	if(world.time < special_time["mine"])
		return 0
	using_special = TRUE
	var/list/possible_mine_turfs = list()
	for(var/turf/T in orange(5, src))
		if(!T.density)
			continue
		if(locate(/obj/effect/mine) in T)
			continue
		possible_mine_turfs += T
	if(!possible_mine_turfs.len)
		using_special = FALSE
		return 0
	var/num_mines = rand(1, possible_mine_turfs.len)
	while(num_mines > 0)
		var/turf/mine_turf = pick(possible_mine_turfs)
		var/mine_type = pick(subtypesof(/obj/effect/mine/present))
		new mine_type(mine_turf)
		possible_mine_turfs -= mine_turf
	special_time = world.time + special_cd["mine"]
	using_special["mine"] = FALSE
	return 1

/mob/living/simple_animal/hostile/winter/santa/proc/gift_wrap()
	if(world.time < special_time["wrap"])
		return 0
	using_special = TRUE
	var/list/possible_targets = list()
	for(var/mob/living/L in view())
		if(L.stat == DEAD)
			continue
		if(faction_check(L))
			continue
		possible_targets += T
	if(!possible_targets.len)
		using_special = FALSE
		return 0
	var/mob/living/victim = pick(possible_targets)
	var/obj/effect/spresent/wrap = new /obj/effect/spresent(get_turf(victim))
	victim.forceMove(wrap)

	special_time["wrap"] = world.time + special_cd["wrap"]
	using_special = FALSE
	return 1

/mob/living/simple_animal/hostile/winter/santa/proc/summon_army()
	if(world.time < special_time["adds"])
		return 0
	using_special = TRUE

	var/list/possible_spawn_turfs = list()
	for(var/turf/T in orange(5, src))
		if(!T.density)
			continue
		possible_spawn_turfs += T
	if(!possible_spawn_turfs.len)
		using_special = FALSE
		return 0
	var/num_mobs = rand(1, possible_spawn_turfs.len)
	var/list/spawn_types = subtypesof(/mob/living/simple_animal/hostile/winter) - typesof(/mob/living/simple_animal/hostile/winter/santa)
	while(num_mobs > 0)
		var/turf/spawn_turf = pick(possible_spawn_turfs)
		var/mob_type = pick(spawn_types)
		new mob_type(spawn_turf)
		possible_spawn_turfs -= spawn_turf

	special_time["adds"] = world.time + special_cd["adds"]
	using_special = FALSE
	return 1

/mob/living/simple_animal/hostile/winter/santa/stage_1		//stage 1: slow melee
	maxHealth = 175
	health = 175
	desc = "GET THE FAT MAN!"
	next_stage = /mob/living/simple_animal/hostile/winter/santa/stage_2
	death_message = "<span class='danger'>HO HO HO! YOU THOUGHT IT WOULD BE THIS EASY?!?</span>"
	speed = 2
	melee_damage_lower = 10
	melee_damage_upper = 20

	base_chance = 10	//chances: 10/20/30
	special_moves = list("self_heal")

/mob/living/simple_animal/hostile/winter/santa/stage_2		//stage 2: slow ranged
	desc = "GET THE FAT MAN AGAIN!"
	next_stage = /mob/living/simple_animal/hostile/winter/santa/stage_3
	death_message = "<span class='danger'>YOU'VE BEEN VERY NAUGHTY! PREPARE TO DIE!</span>"
	maxHealth = 225		//DID YOU REALLY BELIEVE IT WOULD BE THIS EASY!??!!
	health = 225
	ranged = 1
	projectiletype = /obj/item/projectile/ornament
	retreat_distance = 5
	minimum_distance = 5

	base_chance = 15	//chances: 15/30/45
	special_moves = list("self_heal", "present_mines")

/mob/living/simple_animal/hostile/winter/santa/stage_3		//stage 3: fast rapidfire ranged
	desc = "WHY WON'T HE DIE ALREADY!?"
	next_stage = /mob/living/simple_animal/hostile/winter/santa/stage_4
	death_message = "<span class='danger'>FACE MY FINAL FORM AND KNOW DESPAIR!</span>"
	maxHealth = 275
	health = 275
	ranged = 1
	rapid = 1
	speed = 0	//he's lost some weight from the fighting
	projectiletype = /obj/item/projectile/ornament
	retreat_distance = 3
	minimum_distance = 3

	base_chance = 20	//chances: 20/40/60
	special_moves = list("self_heal_big", "present_mines", "gift_wrap")

/mob/living/simple_animal/hostile/winter/santa/stage_4		//stage 4: fast spinebreaker
	name = "Final Form Santa"
	desc = "WHAT THE HELL IS HE!?! WHY WON'T HE STAY DEAD!?!"
	maxHealth = 400		//YOU FACE JARAX- I MEAN SANTA!
	health = 400
	speed = 0	//he's lost some weight from the fighting

	environment_smash = 2		//naughty walls must be punished too
	melee_damage_lower = 20
	melee_damage_upper = 30		//that's gonna leave a mark, for sure

	base_chance = 25	//chances: 25/50/75
	special_moves = list("self_heal_big", "present_mines", "gift_wrap", "summon_army")

/mob/living/simple_animal/hostile/winter/santa/stage_4/death(gibbed)
	to_chat(world, "<span class='notice'><hr></span>")
	to_chat(world, "<span class='notice'>THE FAT MAN HAS FALLEN!</span>")
	to_chat(world, "<span class='notice'>SANTA CLAUS HAS BEEN DEFEATED!</span>")
	to_chat(world, "<span class='notice'><hr></span>")
	..()
	var/obj/item/weapon/grenade/clusterbuster/xmas/X = new /obj/item/weapon/grenade/clusterbuster/xmas(get_turf(src))
	var/obj/item/weapon/grenade/clusterbuster/xmas/Y = new /obj/item/weapon/grenade/clusterbuster/xmas(get_turf(src))
	X.prime()
	Y.prime()