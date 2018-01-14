/obj/effect/mine
	name = "dummy mine"
	desc = "I Better stay away from that thing."
	density = 0
	anchored = 1
	icon = 'icons/obj/weapons.dmi'
	icon_state = "uglyminearmed"
	var/triggered = 0
	var/faction = "syndicate"

/obj/effect/mine/proc/mineEffect(mob/living/victim)
	to_chat(victim, "<span class='danger'>*click*</span>")

/obj/effect/mine/Crossed(AM as mob|obj)
	if(!isliving(AM))
		return
	if(isanimal(AM))
		var/mob/living/simple_animal/SA = AM
		if(faction && (faction in SA.faction))
			return
		if(!SA.flying)
			triggermine(SA)
	else
		triggermine(AM)

/obj/effect/mine/proc/triggermine(mob/living/victim)
	if(triggered)
		return
	visible_message("<span class='danger'>[victim] sets off [bicon(src)] [src]!</span>")
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	mineEffect(victim)
	triggered = 1
	qdel(src)

/obj/effect/mine/explosive
	name = "explosive mine"
	var/range_devastation = 0
	var/range_heavy = 1
	var/range_light = 2
	var/range_flash = 3

/obj/effect/mine/explosive/mineEffect(mob/living/victim)
	explosion(loc, range_devastation, range_heavy, range_light, range_flash)

/obj/effect/mine/stun
	name = "stun mine"
	var/stun_time = 8

/obj/effect/mine/stun/mineEffect(mob/living/victim)
	if(isliving(victim))
		victim.Weaken(stun_time)

/obj/effect/mine/dnascramble
	name = "Radiation Mine"
	var/radiation_amount

/obj/effect/mine/dnascramble/mineEffect(mob/living/victim)
	victim.apply_effect(radiation_amount, IRRADIATE, 0)
	if(ishuman(victim))
		var/mob/living/carbon/human/V = victim
		if(NO_DNA in V.species.species_traits)
			return
	randmutb(victim)
	domutcheck(victim ,null)

/obj/effect/mine/gas
	name = "oxygen mine"
	var/gas_amount = 360
	var/gas_type = SPAWN_OXYGEN

/obj/effect/mine/gas/mineEffect(mob/living/victim)
	atmos_spawn_air(gas_type, gas_amount)

/obj/effect/mine/gas/plasma
	name = "plasma mine"
	gas_type = SPAWN_HEAT | SPAWN_TOXINS

/obj/effect/mine/gas/n2o
	name = "\improper N2O mine"
	gas_type = SPAWN_N2O

/obj/effect/mine/sound
	name = "honkblaster 1000"
	var/sound = 'sound/items/bikehorn.ogg'

/obj/effect/mine/sound/mineEffect(mob/living/victim)
	playsound(loc, sound, 100, 1)

/obj/effect/mine/sound/bwoink
	name = "bwoink mine"
	sound = 'sound/effects/adminhelp.ogg'

/obj/effect/mine/pickup
	name = "pickup"
	desc = "pick me up"
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity2"
	density = 0
	var/duration = 0

/obj/effect/mine/pickup/New()
	..()
	animate(src, pixel_y = 4, time = 20, loop = -1)

/obj/effect/mine/pickup/triggermine(mob/living/victim)
	if(triggered)
		return
	triggered = 1
	invisibility = 101
	mineEffect(victim)
	qdel(src)

/obj/effect/mine/pickup/bloodbath
	name = "Red Orb"
	desc = "You feel angry just looking at it."
	duration = 1200 //2min
	color = "red"

/obj/effect/mine/pickup/bloodbath/mineEffect(mob/living/carbon/victim)
	if(!istype(victim) || !victim.client)
		return
	to_chat(victim, "<span class='reallybig redtext'>RIP AND TEAR</span>")
	victim << 'sound/misc/e1m1.ogg'
	var/old_color = victim.client.color
	var/red_splash = list(1,0,0,0.8,0.2,0, 0.8,0,0.2,0.1,0,0)
	var/pure_red = list(0,0,0,0,0,0,0,0,0,1,0,0)

	spawn(0)
		new /obj/effect/hallucination/delusion(victim.loc, victim, force_kind = "demon", duration = duration, skip_nearby = 0)

	var/obj/item/weapon/twohanded/required/chainsaw/doomslayer/chainsaw = new(victim.loc)
	chainsaw.flags |= NODROP
	victim.drop_l_hand()
	victim.drop_r_hand()
	victim.put_in_hands(chainsaw)
	chainsaw.attack_self(victim)
	chainsaw.wield(victim)
	victim.reagents.add_reagent("adminordrazine", 25)

	victim.client.color = pure_red
	animate(victim.client,color = red_splash, time = 10, easing = SINE_EASING|EASE_OUT)
	spawn(10)
		animate(victim.client,color = old_color, time = duration)//, easing = SINE_EASING|EASE_OUT)
	spawn(duration)
		to_chat(victim, "<span class='notice'>Your bloodlust seeps back into the bog of your subconscious and you regain self control.<span>")
		qdel(chainsaw)
		qdel(src)

/obj/effect/mine/pickup/healing
	name = "Blue Orb"
	desc = "You feel better just looking at it."
	color = "blue"

/obj/effect/mine/pickup/healing/mineEffect(mob/living/carbon/victim)
	if(!victim.client || !istype(victim))
		return
	to_chat(victim, "<span class='notice'>You feel great!</span>")
	victim.revive()

/obj/effect/mine/pickup/speed
	name = "Yellow Orb"
	desc = "You feel faster just looking at it."
	color = "yellow"
	duration = 300

/obj/effect/mine/pickup/speed/mineEffect(mob/living/carbon/victim)
	if(!victim.client || !istype(victim))
		return
	to_chat(victim, "<span class='notice'>You feel fast!</span>")
	victim.status_flags |= GOTTAGOREALLYFAST
	spawn(duration)
		victim.status_flags &= ~GOTTAGOREALLYFAST
		to_chat(victim, "<span class='notice'>You slow down.</span>")



/obj/effect/mine/present
	name = "present"
	desc = "A gift?"
	icon = 'icons/obj/items.dmi'
	icon_state = "gift"
	faction = "winter"

/obj/effect/mine/present/attackby(obj/item/I, mob/user, params)
	if(iswirecutter(I))
		to_chat(user, "<span class=notice'>You cut apart [src] carefully.</span>")
		qdel(src)
		return

/obj/effect/mine/present/Crossed(AM as mob|obj)
	if(istype(AM, /obj/mecha))
		triggermine(AM)
		return
	..()


/obj/effect/mine/present/explosive
	icon_state = "gift_red"
	var/range_devastation = 0
	var/range_heavy = 1
	var/range_light = 2
	var/range_flash = 4

/obj/effect/mine/present/explosive/mineEffect(mob/living/victim)
	explosion(loc, range_devastation, range_heavy, range_light, range_flash)

/obj/effect/mine/present/shock
	icon_state = "gift_yellow"

/obj/effect/mine/present/shock/mineEffect(mob/living/victim)
	//Strike them down with a lightning bolt to complete the illusion (copied from the surge reagent overdose, probably could make this a general-use proc in the future)
	playsound(get_turf(src), 'sound/effects/eleczap.ogg', 75, 1)
	var/icon/I=new('icons/obj/zap.dmi',"lightningend")
	I.Turn(-135)
	var/obj/effect/overlay/beam/B = new(get_turf(src))
	B.pixel_x = rand(-20, 0)
	B.pixel_y = rand(-20, 0)
	B.icon = I
	//then actually do the damage/stun
	if(iscarbon(victim))
		var/mob/living/carbon/C = victim
		C.electrocute_act(20, src, 1)
	else
		victim.apply_damage(20, BURN)

/obj/effect/mine/present/emp
	icon_state = "gift_blue"

/obj/effect/mine/present/emp/mineEffect(mob/living/victim)
	empulse(get_turf(src), 1, 2)

/obj/effect/mine/present/mob
	icon_state = "gift_purple"
	var/mob/living/simple_animal/hostile/winter/surprise = null

/obj/effect/mine/present/mob/New()
	..()
	if(!surprise)
		var/list/spawn_types = subtypesof(/mob/living/simple_animal/hostile/winter) - typesof(/mob/living/simple_animal/hostile/winter/santa)
		if(prob(75))	//25% chance of being a dud
			surprise = pick(spawn_types)

/obj/effect/mine/present/mob/mineEffect(mob/living/victim)
	if(surprise)
		new surprise(get_turf(src))
	else
		new /obj/effect/decal/cleanable/confetti(get_turf(src))