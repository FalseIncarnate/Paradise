
//Highlander Style Martial Art
//	Prevents use of guns, but makes the highlander impervious to ranged attacks. Their bravery in battle shields them from the weapons of COWARDS!

/datum/martial_art/highlander
	name = "Highlander Style"
	deflection_chance = 100
	no_guns = TRUE
	no_guns_message = "You'd never stoop so low as to use the weapon of a COWARD!"


//Highlander Claymore
//	Grants the wielder the Highlander Style Martial Art

/obj/item/weapon/claymore/highlander
	name = "Highlander Claymore"
	desc = "Imbues the wielder with legendary martial prowress and a nigh-unquenchable thirst for glorious battle!"
	var/datum/martial_art/highlander/style = new

/obj/item/weapon/claymore/highlander/Destroy()
	if(ishuman(loc))	//just in case it gets destroyed while in someone's possession, such as due to acid or something?
		var/mob/living/carbon/human/H = loc
		style.remove(H)
	QDEL_NULL(style)
	return ..()

/obj/item/weapon/claymore/highlander/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(slot == slot_r_hand || slot == slot_l_hand)
		if(H.martial_art && H.martial_art != style)
			style.teach(H, 1)
			to_chat(H, "<span class='notice'>THERE CAN ONLY BE ONE!</span>")
	else if(H.martial_art && H.martial_art == style)
		style.remove(H)
		var/obj/item/weapon/claymore/highlander/sword = H.is_in_hands(/obj/item/weapon/claymore/highlander)
		if(sword)
			//if we have a highlander sword in the other hand, relearn the style from that sword.
			sword.style.teach(H, 1)

/obj/item/weapon/claymore/highlander/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	style.remove(H)
	var/obj/item/weapon/claymore/highlander/sword = H.is_in_hands(/obj/item/weapon/claymore/highlander)
	if(sword)
		//if we have a highlander sword in the other hand, relearn the style from that sword.
		sword.style.teach(H, 1)


//////////////////////////////////
//		LEGENDARY SWORDS		//
//////////////////////////////////

/obj/item/weapon/claymore/highlander/thunderfury
	name = "\[Thunderfury, Blessed Blade of the Windseeker\]"
	desc = "Did someone say..."
	force = 30	//lower base damage, but has a chance to strike the victim with lightning

/obj/item/weapon/claymore/highlander/thunderfury/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(isliving(target))
		var/mob/living/victim = target
		if(prob(15))
			var/icon/I=new('icons/obj/zap.dmi',"lightningend")
			I.Turn(-135)
			var/obj/effect/overlay/beam/B = new(get_turf(victim))
			B.pixel_x = rand(-20, 0)
			B.pixel_y = rand(-20, 0)
			B.icon = I
			victim.electrocute_act(rand(40, 100), src, 0.5, tesla_shock = 1)		//this should zap them for 20-50 damage but NOT stun them.

/obj/item/weapon/claymore/highlander/iajutsu
	name = "Iajutsu Katana"
	desc = "Faster than the eye, they'll be dead before they realize it."
	force = 0	//does no damage on hit, but instead stores hits and deals damage on command based on the number of hits stored
	var/hit_dam = 10	//the amount of damage each strike does when triggered
	var/gib_threshold = 300		//the minimum amount of damage needed to be dealt at once to just outright gib the victim (below this just deals damage normally)
	var/list/strikes = list()
	var/sheathed = 1

/obj/item/weapon/claymore/highlander/iajutsu/Destroy()
	strikes.Cut()
	..()

/obj/item/weapon/claymore/highlander/iajutsu/attack_self(mob/user)
	sheathed = !sheathed
	to_chat(user, "<span class='warning'>You [sheathed ? "draw" : "sheathe"] your blade.</span>")
	if(sheathed)
		playsound(user, 'sound/weapons/blade_sheathe.ogg', 50, 1)
		trigger_damage(user)
	else
		playsound(user, 'sound/weapons/blade_unsheathe.ogg', 50, 1)

/obj/item/weapon/claymore/highlander/iajutsu/proc/trigger_damage(mob/user)
	var/victim_gibbed = 0
	for(var/mob/living/L in strikes)
		var/dam_to_deal = strikes[L] * hit_dam
		if(dam_to_deal >= gib_threshold)		//fountain of blood, in the most animu fashion
			L.gib()
			victim_gibbed = 1
		else
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				H.take_overall_damage(dam_to_deal, 0, sharp = 1, edge = 1, used_weapon = "A thousand cuts")
			else if(is_robot(L))
				var/mob/living/silicon/robot/R = L
				R.take_overall_damage(dam_to_deal, 0, sharp = 1, used_weapon = "A thousand cuts")
			else
				L.take_overall_damage(dam_to_deal, 0, used_weapon = "A thousand cuts")	//this apparently doesn't have the sharp or edge arguments the subtype versions get
		strikes[L] = 0
		strikes.Remove(L)
	if(victim_gibbed)
		var/taunt = pick("Nothing personal, kid.", "Ryujin no ken o kurae!", "They were already dead.", "They blinked.", "Dishonorable fool.", "I win.")
		user.say(taunt)

/obj/item/weapon/claymore/highlander/iajutsu/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(isliving(A))
		var/mob/living/L = A
		if(L in strikes)
			strikes[L]++
		else
			strikes[L] = 1