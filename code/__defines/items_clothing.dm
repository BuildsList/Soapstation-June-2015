#define HUMAN_STRIP_DELAY        40   // Takes 40ds = 4s to strip someone.

#define SHOES_SLOWDOWN          -1.0  // How much shoes slow you down by default. Negative values speed you up.

#define CANDLE_LUM 3 // For how bright candles are.

// Item inventory slot bitmasks.
#define SLOT_OCLOTHING  1
#define SLOT_ICLOTHING  2
#define SLOT_GLOVES     4
#define SLOT_EYES       8
#define SLOT_EARS       16
#define SLOT_MASK       32
#define SLOT_HEAD       64
#define SLOT_FEET       128
#define SLOT_ID         256
#define SLOT_BELT       512
#define SLOT_BACK       1024
#define SLOT_POCKET     2048  // This is to allow items with a w_class of 3 or 4 to fit in pockets.
#define SLOT_DENYPOCKET 4096  // This is to  deny items with a w_class of 2 or 1 from fitting in pockets.
#define SLOT_TWOEARS    8192
#define SLOT_TIE        16384
#define SLOT_HOLSTER	32768 //16th bit

// Flags bitmasks.
#define STOPPRESSUREDAMAGE 1 // This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_BACK) if you see it anywhere
                             // To successfully stop you taking all pressure damage you must have both a suit and head item with this flag.
#define NOBLUDGEON         2    // When an item has this it produces no "X has been hit by Y with Z" message with the default handler.
#define AIRTIGHT           4    // Functions with internals.
#define USEDELAY           8    // 1 second extra delay on use. (Can be used once every 2s)
#define NOSHIELD           16   // Weapon not affected by shield.
#define CONDUCT            32   // Conducts electricity. (metal etc.)
#define ON_BORDER          64   // Item has priority to check when entering or leaving.
#define NOBLOODY           512  // Used for items if they don't want to get a blood overlay.
#define NODELAY            8192 // 1 second attack-by delay skipped (Can be used once every 0.2s). Most objects have a 1s attack-by delay, which doesn't require a flag.
#define PROXMOVE          16384 // Does this object require proximity checking in Enter()?

//Use these flags to indicate if an item obscures the specified slots from view, whereas body_parts_covered seems to be used to indicate what body parts the item protects.
#define GLASSESCOVERSEYES 256
#define    MASKCOVERSEYES 256 // Get rid of some of the other retardation in these flags.
#define    HEADCOVERSEYES 256 // Feel free to reallocate these numbers for other purposes.
#define   MASKCOVERSMOUTH 512 // On other items, these are just for mask/head.
#define   HEADCOVERSMOUTH 512

#define THICKMATERIAL          256  // From /tg/station: prevents syringes, parapens and hyposprays if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body. (NOTE: flag shared with NOSLIP for shoes)
#define NOSLIP                 256  // Prevents from slipping on wet floors, in space, etc.
#define OPENCONTAINER          1024 // Is an open container for chemistry purposes.
#define BLOCK_GAS_SMOKE_EFFECT 2048 // Blocks the effect that chemical clouds would have on a mob -- glasses, mask and helmets ONLY! (NOTE: flag shared with ONESIZEFITSALL)
#define ONESIZEFITSALL         2048
#define PHORONGUARD            4096 // Does not get contaminated by phoron.
#define	NOREACT                4096 // Reagents don't react inside this container.
#define BLOCKHEADHAIR          4    // Temporarily removes the user's hair overlay. Leaves facial hair.
#define BLOCKHAIR              8192 // Temporarily removes the user's hair, facial and otherwise.

// Flags for pass_flags.
#define PASSTABLE  1
#define PASSGLASS  2
#define PASSGRILLE 4
#define PASSBLOB   8

// Bitmasks for the flags_inv variable. These determine when a piece of clothing hides another, i.e. a helmet hiding glasses.
// WARNING: The following flags apply only to the external suit!
#define HIDEGLOVES      1
#define HIDESUITSTORAGE 2
#define HIDEJUMPSUIT    4
#define HIDESHOES       8
#define HIDETAIL        16

// WARNING: The following flags apply only to the helmets and masks!
#define HIDEMASK 1
#define HIDEEARS 2 // Headsets and such.
#define HIDEEYES 4 // Glasses.
#define HIDEFACE 8 // Dictates whether we appear as "Unknown".

// Slots.
#define slot_back        1
#define slot_wear_mask   2
#define slot_handcuffed  3
#define slot_l_hand      4
#define slot_r_hand      5
#define slot_belt        6
#define slot_wear_id     7
#define slot_l_ear       8
#define slot_glasses     9
#define slot_gloves      10
#define slot_head        11
#define slot_shoes       12
#define slot_wear_suit   13
#define slot_w_uniform   14
#define slot_l_store     15
#define slot_r_store     16
#define slot_s_store     17
#define slot_in_backpack 18
#define slot_legcuffed   19
#define slot_r_ear       20
#define slot_legs        21
#define slot_tie         22

// Inventory slot strings.
// since numbers cannot be used as associative list keys.
//icon_back, icon_l_hand, etc would be much better names for these...
#define slot_back_str		"slot_back"
#define slot_l_hand_str		"slot_l_hand"
#define slot_r_hand_str		"slot_r_hand"
#define slot_w_uniform_str	"slot_w_uniform"
#define slot_head_str		"slot_head"
#define slot_wear_suit_str	"slot_suit"

// Bitflags for clothing parts.
#define HEAD        1
#define FACE        2
#define EYES        4
#define UPPER_TORSO 8
#define LOWER_TORSO 16
#define LEG_LEFT    32
#define LEG_RIGHT   64
#define LEGS        96   //  LEG_LEFT | LEG_RIGHT
#define FOOT_LEFT   128
#define FOOT_RIGHT  256
#define FEET        384  // FOOT_LEFT | FOOT_RIGHT
#define ARM_LEFT    512
#define ARM_RIGHT   1024
#define ARMS        1536 //  ARM_LEFT | ARM_RIGHT
#define HAND_LEFT   2048
#define HAND_RIGHT  4096
#define HANDS       6144 // HAND_LEFT | HAND_RIGHT
#define FULL_BODY   8191

// Bitflags for the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_heat_protection() and human/proc/get_cold_protection().
// The values here should add up to 1, e.g., the head has 30% protection.
#define THERMAL_PROTECTION_HEAD        0.3
#define THERMAL_PROTECTION_UPPER_TORSO 0.15
#define THERMAL_PROTECTION_LOWER_TORSO 0.15
#define THERMAL_PROTECTION_LEG_LEFT    0.075
#define THERMAL_PROTECTION_LEG_RIGHT   0.075
#define THERMAL_PROTECTION_FOOT_LEFT   0.025
#define THERMAL_PROTECTION_FOOT_RIGHT  0.025
#define THERMAL_PROTECTION_ARM_LEFT    0.075
#define THERMAL_PROTECTION_ARM_RIGHT   0.075
#define THERMAL_PROTECTION_HAND_LEFT   0.025
#define THERMAL_PROTECTION_HAND_RIGHT  0.025

// Pressure limits.
#define  HAZARD_HIGH_PRESSURE 550 // This determines at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define WARNING_HIGH_PRESSURE 325 // This determines when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_LOW_PRESSURE  50  // This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define  HAZARD_LOW_PRESSURE  20  // This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)

#define TEMPERATURE_DAMAGE_COEFFICIENT  1.5 // This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.
#define BODYTEMP_AUTORECOVERY_DIVISOR   12  // This is the divisor which handles how much of the temperature difference between the current body temperature and 310.15K (optimal temperature) humans auto-regenerate each tick. The higher the number, the slower the recovery. This is applied each tick, so long as the mob is alive.
#define BODYTEMP_AUTORECOVERY_MINIMUM   1   // Minimum amount of kelvin moved toward 310.15K per tick. So long as abs(310.15 - bodytemp) is more than 50.
#define BODYTEMP_COLD_DIVISOR           6   // Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is lower than their body temperature. Make it lower to lose bodytemp faster.
#define BODYTEMP_HEAT_DIVISOR           6   // Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is higher than their body temperature. Make it lower to gain bodytemp faster.
#define BODYTEMP_COOLING_MAX           -30  // The maximum number of degrees that your body can cool down in 1 tick, when in a cold area.
#define BODYTEMP_HEATING_MAX            30  // The maximum number of degrees that your body can heat up in 1 tick,   when in a hot  area.

#define BODYTEMP_HEAT_DAMAGE_LIMIT 360.15 // The limit the human body can take before it starts taking damage from heat.
#define BODYTEMP_COLD_DAMAGE_LIMIT 260.15 // The limit the human body can take before it starts taking damage from coldness.

#define SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE 2.0 // What min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define   SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE 2.0 // What min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define       HELMET_MIN_COLD_PROTECTION_TEMPERATURE 160 // For normal helmets.
#define        ARMOR_MIN_COLD_PROTECTION_TEMPERATURE 160 // For armor.
#define       GLOVES_MIN_COLD_PROTECTION_TEMPERATURE 2.0 // For some gloves.
#define         SHOE_MIN_COLD_PROTECTION_TEMPERATURE 2.0 // For shoes.

#define  SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE 5000  // These need better heat protect, but not as good heat protect as firesuits.
#define    FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE 30000 // What max_heat_protection_temperature is set to for firesuit quality headwear. MUST NOT BE 0.
#define FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE 30000 // For fire-helmet quality items. (Red and white hardhats)
#define      HELMET_MAX_HEAT_PROTECTION_TEMPERATURE 600   // For normal helmets.
#define       ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE 600   // For armor.
#define      GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE 1500  // For some gloves.
#define        SHOE_MAX_HEAT_PROTECTION_TEMPERATURE 1500  // For shoes.

// Fire.
#define FIRE_MIN_STACKS          -20
#define FIRE_MAX_STACKS           25
#define FIRE_MAX_FIRESUIT_STACKS  20 // If the number of stacks goes above this firesuits won't protect you anymore. If not, you can walk around while on fire like a badass.

#define THROWFORCE_SPEED_DIVISOR    5  // The throwing speed value at which the throwforce multiplier is exactly 1.
#define THROWNOBJ_KNOCKBACK_SPEED   15 // The minumum speed of a w_class 2 thrown object that will cause living mobs it hits to be knocked back. Heavier objects can cause knockback at lower speeds.
#define THROWNOBJ_KNOCKBACK_DIVISOR 2  // Affects how much speed the mob is knocked back with.

// Suit sensor levels
#define SUIT_SENSOR_OFF      0
#define SUIT_SENSOR_BINARY   1
#define SUIT_SENSOR_VITAL    2
#define SUIT_SENSOR_TRACKING 3