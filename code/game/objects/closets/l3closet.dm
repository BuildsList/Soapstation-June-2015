/obj/structure/closet/l3closet/New()
	..()
	sleep(2)
	new /obj/item/clothing/suit/bio_suit/general( src )
	new /obj/item/clothing/head/bio_hood/general( src )

/obj/structure/closet/l3closet/general/New()
	..()
	sleep(2)
	contents = list()
	new /obj/item/clothing/suit/bio_suit/general( src )
	new /obj/item/clothing/head/bio_hood/general( src )

/obj/structure/closet/l3closet/virology/New()
	..()
	sleep(2)
	contents = list()
	new /obj/item/clothing/suit/bio_suit/virology( src )
	new /obj/item/clothing/head/bio_hood/virology( src )

/obj/structure/closet/l3closet/security/New()
	..()
	sleep(2)
	contents = list()
	new /obj/item/clothing/suit/bio_suit/security( src )
	new /obj/item/clothing/head/bio_hood/security( src )

/obj/structure/closet/l3closet/janitor/New()
	..()
	sleep(2)
	contents = list()
	new /obj/item/clothing/suit/bio_suit/janitor( src )
	new /obj/item/clothing/head/bio_hood/janitor( src )
	new /obj/item/clothing/gloves/latex ( src )
	new /obj/item/clothing/mask/surgical( src )

/obj/structure/closet/l3closet/scientist/New()
	..()
	sleep(2)
	contents = list()
	new /obj/item/clothing/suit/bio_suit/scientist( src )
	new /obj/item/clothing/head/bio_hood/scientist( src )