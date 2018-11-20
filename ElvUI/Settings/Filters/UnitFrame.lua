local E, L, V, P, G = unpack(select(2, ...)); --Engine

--Cache global variables
--Lua functions
local print, unpack = print, unpack
local strlower = string.lower
--WoW API / Variables
local GetSpellInfo = GetSpellInfo
local IsPlayerSpell = IsPlayerSpell

local function SpellName(id)
	local name = GetSpellInfo(id)
	if not name then
		print('|cff1784d1ElvUI:|r SpellID is not valid: '..id..'. Please check for an updated version, if none exists report to ElvUI author.')
		return 'Impale'
	else
		return name
	end
end

local function Defaults(priorityOverride)
	return {['enable'] = true, ['priority'] = priorityOverride or 0, ['stackThreshold'] = 0}
end

G.unitframe.aurafilters = {};

-- These are debuffs that are some form of CC
G.unitframe.aurafilters['CCDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
	--Death Knight
		[47476]  = Defaults(2), -- Strangulate
		[108194] = Defaults(4), -- Asphyxiate UH
		[221562] = Defaults(4), -- Asphyxiate Blood
		[207171] = Defaults(4), -- Winter is Coming
		[206961] = Defaults(3), -- Tremble Before Me
		[207167] = Defaults(4), -- Blinding Sleet
		[212540] = Defaults(1), -- Flesh Hook (Pet)
		[91807]  = Defaults(1), -- Shambling Rush (Pet)
		[204085] = Defaults(1), -- Deathchill
		[233395] = Defaults(1), -- Frozen Center
		[212332] = Defaults(4), -- Smash (Pet)
		[212337] = Defaults(4), -- Powerful Smash (Pet)
		[91800]  = Defaults(4), -- Gnaw (Pet)
		[91797]  = Defaults(4), -- Monstrous Blow (Pet)
	--	[?????]  = Defaults(),  -- Reanimation (missing data)
		[210141] = Defaults(3), -- Zombie Explosion
	--Demon Hunter
		[207685] = Defaults(4), -- Sigil of Misery
		[217832] = Defaults(3), -- Imprison
		[221527] = Defaults(5), -- Imprison (Banished version)
		[204490] = Defaults(2), -- Sigil of Silence
		[179057] = Defaults(3), -- Chaos Nova
		[211881] = Defaults(4), -- Fel Eruption
		[205630] = Defaults(3), -- Illidan's Grasp
		[208618] = Defaults(3), -- Illidan's Grasp (Afterward)
		[213491] = Defaults(4), -- Demonic Trample (it's this one or the other)
		[208645] = Defaults(4), -- Demonic Trample
	--Druid
		[81261]  = Defaults(2), -- Solar Beam
		[5211]   = Defaults(4), -- Mighty Bash
		[163505] = Defaults(4), -- Rake
		[203123] = Defaults(4), -- Maim
		[202244] = Defaults(4), -- Overrun
		[99]     = Defaults(4), -- Incapacitating Roar
		[33786]  = Defaults(5), -- Cyclone
		[209753] = Defaults(5), -- Cyclone Balance
		[45334]  = Defaults(1), -- Immobilized
		[102359] = Defaults(1), -- Mass Entanglement
		[339]    = Defaults(1), -- Entangling Roots
		[2637]   = Defaults(1), -- Hibernate
	--Hunter
		[202933] = Defaults(2), -- Spider Sting (it's this one or the other)
		[233022] = Defaults(2), -- Spider Sting
		[213691] = Defaults(4), -- Scatter Shot
		[19386]  = Defaults(3), -- Wyvern Sting
		[3355]   = Defaults(3), -- Freezing Trap
		[203337] = Defaults(5), -- Freezing Trap (Survival PvPT)
		[209790] = Defaults(3), -- Freezing Arrow
		[24394]  = Defaults(4), -- Intimidation
		[117526] = Defaults(4), -- Binding Shot
		[190927] = Defaults(1), -- Harpoon
		[201158] = Defaults(1), -- Super Sticky Tar
		[162480] = Defaults(1), -- Steel Trap
		[212638] = Defaults(1), -- Tracker's Net
		[200108] = Defaults(1), -- Ranger's Net
	--Mage
		[61721]  = Defaults(3), -- Rabbit (Poly)
		[61305]  = Defaults(3), -- Black Cat (Poly)
		[28272]  = Defaults(3), -- Pig (Poly)
		[28271]  = Defaults(3), -- Turtle (Poly)
		[126819] = Defaults(3), -- Porcupine (Poly)
		[161354] = Defaults(3), -- Monkey (Poly)
		[161353] = Defaults(3), -- Polar bear (Poly)
		[61780] = Defaults(3),  -- Turkey (Poly)
		[161355] = Defaults(3), -- Penguin (Poly)
		[161372] = Defaults(3), -- Peacock (Poly)
		[277787] = Defaults(3), -- Direhorn (Poly)
		[277792] = Defaults(3), -- Bumblebee (Poly)
		[118]    = Defaults(3), -- Polymorph
		[82691]  = Defaults(3), -- Ring of Frost
		[31661]  = Defaults(3), -- Dragon's Breath
		[122]    = Defaults(1), -- Frost Nova
		[33395]  = Defaults(1), -- Freeze
		[157997] = Defaults(1), -- Ice Nova
		[228600] = Defaults(1), -- Glacial Spike
		[198121] = Defaults(1), -- Forstbite
	--Monk
		[119381] = Defaults(4), -- Leg Sweep
		[202346] = Defaults(4), -- Double Barrel
		[115078] = Defaults(4), -- Paralysis
		[198909] = Defaults(3), -- Song of Chi-Ji
		[202274] = Defaults(3), -- Incendiary Brew
		[233759] = Defaults(2), -- Grapple Weapon
		[123407] = Defaults(1), -- Spinning Fire Blossom
		[116706] = Defaults(1), -- Disable
		[232055] = Defaults(4), -- Fists of Fury (it's this one or the other)
	--Paladin
		[853]    = Defaults(3), -- Hammer of Justice
		[20066]  = Defaults(3), -- Repentance
		[105421] = Defaults(3), -- Blinding Light
		[31935]  = Defaults(2), -- Avenger's Shield
		[217824] = Defaults(2), -- Shield of Virtue
		[205290] = Defaults(3), -- Wake of Ashes
	--Priest
		[9484]   = Defaults(3), -- Shackle Undead
		[200196] = Defaults(4), -- Holy Word: Chastise
		[200200] = Defaults(4), -- Holy Word: Chastise
		[226943] = Defaults(3), -- Mind Bomb
		[605]    = Defaults(5), -- Mind Control
		[8122]   = Defaults(3), -- Psychic Scream
		[15487]  = Defaults(2), -- Silence
		[64044]  = Defaults(1), -- Psychic Horror
	--Rogue
		[2094]   = Defaults(4), -- Blind
		[6770]   = Defaults(4), -- Sap
		[1776]   = Defaults(4), -- Gouge
		[1330]   = Defaults(2), -- Garrote - Silence
		[207777] = Defaults(2), -- Dismantle
		[199804] = Defaults(4), -- Between the Eyes
		[408]    = Defaults(4), -- Kidney Shot
		[1833]   = Defaults(4), -- Cheap Shot
		[207736] = Defaults(5), -- Shadowy Duel (Smoke effect)
		[212182] = Defaults(5), -- Smoke Bomb
	--Shaman
		[51514]  = Defaults(3), -- Hex
		[211015] = Defaults(3), -- Hex (Cockroach)
		[211010] = Defaults(3), -- Hex (Snake)
		[211004] = Defaults(3), -- Hex (Spider)
		[210873] = Defaults(3), -- Hex (Compy)
		[196942] = Defaults(3), -- Hex (Voodoo Totem)
		[269352] = Defaults(3), -- Hex (Skeletal Hatchling)
		[277778] = Defaults(3), -- Hex (Zandalari Tendonripper)
		[277784] = Defaults(3), -- Hex (Wicker Mongrel)
		[118905] = Defaults(3), -- Static Charge
		[77505]  = Defaults(4), -- Earthquake (Knocking down)
		[118345] = Defaults(4), -- Pulverize (Pet)
		[204399] = Defaults(3), -- Earthfury
		[204437] = Defaults(3), -- Lightning Lasso
		[157375] = Defaults(4), -- Gale Force
		[64695]  = Defaults(1), -- Earthgrab
	--Warlock
		[710]    = Defaults(5), -- Banish
		[6789]   = Defaults(3), -- Mortal Coil
		[118699] = Defaults(3), -- Fear
		[6358]   = Defaults(3), -- Seduction (Succub)
		[171017] = Defaults(4), -- Meteor Strike (Infernal)
		[22703]  = Defaults(4), -- Infernal Awakening (Infernal CD)
		[30283]  = Defaults(3), -- Shadowfury
		[89766]  = Defaults(4), -- Axe Toss
		[233582] = Defaults(1), -- Entrenched in Flame
	--Warrior
		[5246]   = Defaults(4), -- Intimidating Shout
		[7922]   = Defaults(4), -- Warbringer
		[132169] = Defaults(4), -- Storm Bolt
		[132168] = Defaults(4), -- Shockwave
		[199085] = Defaults(4), -- Warpath
		[105771] = Defaults(1), -- Charge
		[199042] = Defaults(1), -- Thunderstruck
		[236077] = Defaults(2), -- Disarm
	--Racial
		[20549]  = Defaults(4), -- War Stomp
		[107079] = Defaults(4), -- Quaking Palm
	},
}

-- These are buffs that can be considered "protection" buffs
G.unitframe.aurafilters['TurtleBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
	--Death Knight
		[48707]  = Defaults(), -- Anti-Magic Shell
		[81256]  = Defaults(), -- Dancing Rune Weapon
		[55233]  = Defaults(), -- Vampiric Blood
		[193320] = Defaults(), -- Umbilicus Eternus
		[219809] = Defaults(), -- Tombstone
		[48792]  = Defaults(), -- Icebound Fortitude
		[207319] = Defaults(), -- Corpse Shield
		[194844] = Defaults(), -- BoneStorm
		[145629] = Defaults(), -- Anti-Magic Zone
		[194679] = Defaults(), -- Rune Tap
	--Demon Hunter
		[207811] = Defaults(), -- Nether Bond (DH)
		[207810] = Defaults(), -- Nether Bond (Target)
		[187827] = Defaults(), -- Metamorphosis
		[227225] = Defaults(), -- Soul Barrier
		[209426] = Defaults(), -- Darkness
		[196555] = Defaults(), -- Netherwalk
		[212800] = Defaults(), -- Blur
		[188499] = Defaults(), -- Blade Dance
		[203819] = Defaults(), -- Demon Spikes
		[218256] = Defaults(), -- Empower Wards
	-- Druid
		[102342] = Defaults(), -- Ironbark
		[61336]  = Defaults(), -- Survival Instincts
		[210655] = Defaults(), -- Protection of Ashamane
		[22812]  = Defaults(), -- Barkskin
		[200851] = Defaults(), -- Rage of the Sleeper
		[234081] = Defaults(), -- Celestial Guardian
		[202043] = Defaults(), -- Protector of the Pack (it's this one or the other)
		[201940] = Defaults(), -- Protector of the Pack
		[201939] = Defaults(), -- Protector of the Pack (Allies)
		[192081] = Defaults(), -- Ironfur
	--Hunter
		[186265] = Defaults(), -- Aspect of the Turtle
		[53480]  = Defaults(), -- Roar of Sacrifice
		[202748] = Defaults(), -- Survival Tactics
	--Mage
		[45438]  = Defaults(), -- Ice Block
		[113862] = Defaults(), -- Greater Invisibility
		[198111] = Defaults(), -- Temporal Shield
		[198065] = Defaults(), -- Prismatic Cloak
		[11426]  = Defaults(), -- Ice Barrier
	--Monk
		[122783] = Defaults(), -- Diffuse Magic
		[122278] = Defaults(), -- Dampen Harm
		[125174] = Defaults(), -- Touch of Karma
		[201318] = Defaults(), -- Fortifying Elixir
		[201325] = Defaults(), -- Zen Moment
		[202248] = Defaults(), -- Guided Meditation
		[120954] = Defaults(), -- Fortifying Brew
		[116849] = Defaults(), -- Life Cocoon
		[202162] = Defaults(), -- Guard
		[215479] = Defaults(), -- Ironskin Brew
	--Paladin
		[642]    = Defaults(), -- Divine Shield
		[498]    = Defaults(), -- Divine Protection
		[205191] = Defaults(), -- Eye for an Eye
		[184662] = Defaults(), -- Shield of Vengeance
		[1022]   = Defaults(), -- Blessing of Protection
		[6940]   = Defaults(), -- Blessing of Sacrifice
		[204018] = Defaults(), -- Blessing of Spellwarding
		[199507] = Defaults(), -- Spreading The Word: Protection
		[216857] = Defaults(), -- Guarded by the Light
		[228049] = Defaults(), -- Guardian of the Forgotten Queen
		[31850]  = Defaults(), -- Ardent Defender
		[86659]  = Defaults(), -- Guardian of Ancien Kings
		[212641] = Defaults(), -- Guardian of Ancien Kings (Glyph of the Queen)
		[209388] = Defaults(), -- Bulwark of Order
		[204335] = Defaults(), -- Aegis of Light
		[152262] = Defaults(), -- Seraphim
		[132403] = Defaults(), -- Shield of the Righteous
	--Priest
		[81782]  = Defaults(), -- Power Word: Barrier
		[47585]  = Defaults(), -- Dispersion
		[19236]  = Defaults(), -- Desperate Prayer
		[213602] = Defaults(), -- Greater Fade
		[27827]  = Defaults(), -- Spirit of Redemption
		[197268] = Defaults(), -- Ray of Hope
		[47788]  = Defaults(), -- Guardian Spirit
		[33206]  = Defaults(), -- Pain Suppression
	--Rogue
		[5277]   = Defaults(), -- Evasion
		[31224]  = Defaults(), -- Cloak of Shadows
		[1966]   = Defaults(), -- Feint
		[199754] = Defaults(), -- Riposte
		[45182]  = Defaults(), -- Cheating Death
		[199027] = Defaults(), -- Veil of Midnight
	--Shaman
		[204293] = Defaults(), -- Spirit Link
		[204288] = Defaults(), -- Earth Shield
		[210918] = Defaults(), -- Ethereal Form
		[207654] = Defaults(), -- Servant of the Queen
		[108271] = Defaults(), -- Astral Shift
		[98007]  = Defaults(), -- Spirit Link Totem
		[207498] = Defaults(), -- Ancestral Protection
	--Warlock
		[108416] = Defaults(), -- Dark Pact
		[104773] = Defaults(), -- Unending Resolve
		[221715] = Defaults(), -- Essence Drain
		[212295] = Defaults(), -- Nether Ward
	--Warrior
		[118038] = Defaults(), -- Die by the Sword
		[184364] = Defaults(), -- Enraged Regeneration
		[209484] = Defaults(), -- Tactical Advance
		[97463]  = Defaults(), -- Commanding Shout
		[213915] = Defaults(), -- Mass Spell Reflection
		[199038] = Defaults(), -- Leave No Man Behind
		[223658] = Defaults(), -- Safeguard
		[147833] = Defaults(), -- Intervene
		[198760] = Defaults(), -- Intercept
		[12975]  = Defaults(), -- Last Stand
		[871]    = Defaults(), -- Shield Wall
		[23920]  = Defaults(), -- Spell Reflection
		[216890] = Defaults(), -- Spell Reflection (PvPT)
		[227744] = Defaults(), -- Ravager
		[203524] = Defaults(), -- Neltharion's Fury
		[190456] = Defaults(), -- Ignore Pain
		[132404] = Defaults(), -- Shield Block
	--Racial
		[65116]  = Defaults(), -- Stoneform
	--Potion
		[251231] = Defaults(), -- Steelskin Potion (BfA Armor Potion)
	},
}

G.unitframe.aurafilters['PlayerBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
	--Death Knight
		[48707]  = Defaults(), -- Anti-Magic Shell
		[81256]  = Defaults(), -- Dancing Rune Weapon
		[55233]  = Defaults(), -- Vampiric Blood
		[193320] = Defaults(), -- Umbilicus Eternus
		[219809] = Defaults(), -- Tombstone
		[48792]  = Defaults(), -- Icebound Fortitude
		[207319] = Defaults(), -- Corpse Shield
		[194844] = Defaults(), -- BoneStorm
		[145629] = Defaults(), -- Anti-Magic Zone
		[194679] = Defaults(), -- Rune Tap
		[51271]  = Defaults(), -- Pilar of Frost
		[207256] = Defaults(), -- Obliteration
		[152279] = Defaults(), -- Breath of Sindragosa
		[233411] = Defaults(), -- Blood for Blood
		[212552] = Defaults(), -- Wraith Walk
		[215711] = Defaults(), -- Soul Reaper
		[194918] = Defaults(), -- Blighted Rune Weapon
	--Demon Hunter
		[207811] = Defaults(), -- Nether Bond (DH)
		[207810] = Defaults(), -- Nether Bond (Target)
		[187827] = Defaults(), -- Metamorphosis
		[227225] = Defaults(), -- Soul Barrier
		[209426] = Defaults(), -- Darkness
		[196555] = Defaults(), -- Netherwalk
		[212800] = Defaults(), -- Blur
		[188499] = Defaults(), -- Blade Dance
		[203819] = Defaults(), -- Demon Spikes
		[218256] = Defaults(), -- Empower Wards
		[206804] = Defaults(), -- Rain from Above
		[211510] = Defaults(), -- Solitude
		[211048] = Defaults(), -- Chaos Blades
		[162264] = Defaults(), -- Metamorphosis
		[205629] = Defaults(), -- Demonic Trample
	-- Druid
		[102342] = Defaults(), -- Ironbark
		[61336]  = Defaults(), -- Survival Instincts
		[210655] = Defaults(), -- Protection of Ashamane
		[22812]  = Defaults(), -- Barkskin
		[200851] = Defaults(), -- Rage of the Sleeper
		[234081] = Defaults(), -- Celestial Guardian
		[202043] = Defaults(), -- Protector of the Pack (it's this one or the other)
		[201940] = Defaults(), -- Protector of the Pack
		[201939] = Defaults(), -- Protector of the Pack (Allies)
		[192081] = Defaults(), -- Ironfur
		[29166]  = Defaults(), -- Innervate
		[208253] = Defaults(), -- Essence of G'Hanir
		[194223] = Defaults(), -- Celestial Alignment
		[102560] = Defaults(), -- Incarnation: Chosen of Elune
		[102543] = Defaults(), -- Incarnation: King of the Jungle
		[102558] = Defaults(), -- Incarnation: Guardian of Ursoc
		[117679] = Defaults(), -- Incarnation
		[106951] = Defaults(), -- Berserk
		[5217]   = Defaults(), -- Tiger's Fury
		[1850]   = Defaults(), -- Dash
		[137452] = Defaults(), -- Displacer Beast
		[102416] = Defaults(), -- Wild Charge
		[77764]  = Defaults(), -- Stampeding Roar (Cat)
		[77761]  = Defaults(), -- Stampeding Roar (Bear)
		[203727] = Defaults(), -- Thorns
		[233756] = Defaults(), -- Eclipse (it's this one or the other)
		[234084] = Defaults(), -- Eclipse
		[22842]  = Defaults(), -- Frenzied Regeneration
	--Hunter
		[186265] = Defaults(), -- Aspect of the Turtle
		[53480]  = Defaults(), -- Roar of Sacrifice
		[202748] = Defaults(), -- Survival Tactics
		[62305]  = Defaults(), -- Master's Call (it's this one or the other)
		[54216]  = Defaults(), -- Master's Call
		[193526] = Defaults(), -- Trueshot
		[193530] = Defaults(), -- Aspect of the Wild
		[19574]  = Defaults(), -- Bestial Wrath
		[186289] = Defaults(), -- Aspect of the Eagle
		[186257] = Defaults(), -- Aspect of the Cheetah
		[118922] = Defaults(), -- Posthaste
		[90355]  = Defaults(), -- Ancient Hysteria (Pet)
		[160452] = Defaults(), -- Netherwinds (Pet)
	--Mage
		[45438]  = Defaults(), -- Ice Block
		[113862] = Defaults(), -- Greater Invisibility
		[198111] = Defaults(), -- Temporal Shield
		[198065] = Defaults(), -- Prismatic Cloak
		[11426]  = Defaults(), -- Ice Barrier
		[190319] = Defaults(), -- Combustion
		[80353]  = Defaults(), -- Time Warp
		[12472]  = Defaults(), -- Icy Veins
		[12042]  = Defaults(), -- Arcane Power
		[116014] = Defaults(), -- Rune of Power
		[198144] = Defaults(), -- Ice Form
		[108839] = Defaults(), -- Ice Floes
		[205025] = Defaults(), -- Presence of Mind
		[198158] = Defaults(), -- Mass Invisibility
		[221404] = Defaults(), -- Burning Determination
	--Monk
		[122783] = Defaults(), -- Diffuse Magic
		[122278] = Defaults(), -- Dampen Harm
		[125174] = Defaults(), -- Touch of Karma
		[201318] = Defaults(), -- Fortifying Elixir
		[201325] = Defaults(), -- Zen Moment
		[202248] = Defaults(), -- Guided Meditation
		[120954] = Defaults(), -- Fortifying Brew
		[116849] = Defaults(), -- Life Cocoon
		[202162] = Defaults(), -- Guard
		[215479] = Defaults(), -- Ironskin Brew
		[152173] = Defaults(), -- Serenity
		[137639] = Defaults(), -- Storm, Earth, and Fire
		[216113] = Defaults(), -- Way of the Crane
		[213664] = Defaults(), -- Nimble Brew
		[201447] = Defaults(), -- Ride the Wind
		[195381] = Defaults(), -- Healing Winds
		[116841] = Defaults(), -- Tiger's Lust
		[119085] = Defaults(), -- Chi Torpedo
		[199407] = Defaults(), -- Light on Your Feet
		[209584] = Defaults(), -- Zen Focus Tea
	--Paladin
		[642]    = Defaults(), -- Divine Shield
		[498]    = Defaults(), -- Divine Protection
		[205191] = Defaults(), -- Eye for an Eye
		[184662] = Defaults(), -- Shield of Vengeance
		[1022]   = Defaults(), -- Blessing of Protection
		[6940]   = Defaults(), -- Blessing of Sacrifice
		[204018] = Defaults(), -- Blessing of Spellwarding
		[199507] = Defaults(), -- Spreading The Word: Protection
		[216857] = Defaults(), -- Guarded by the Light
		[228049] = Defaults(), -- Guardian of the Forgotten Queen
		[31850]  = Defaults(), -- Ardent Defender
		[86659]  = Defaults(), -- Guardian of Ancien Kings
		[212641] = Defaults(), -- Guardian of Ancien Kings (Glyph of the Queen)
		[209388] = Defaults(), -- Bulwark of Order
		[204335] = Defaults(), -- Aegis of Light
		[152262] = Defaults(), -- Seraphim
		[132403] = Defaults(), -- Shield of the Righteous
		[31842]  = Defaults(), -- Avenging Wrath (Holy)
		[31884]  = Defaults(), -- Avenging Wrath
		[105809] = Defaults(), -- Holy Avenger
		[224668] = Defaults(), -- Crusade
		[200652] = Defaults(), -- Tyr's Deliverance
		[216331] = Defaults(), -- Avenging Crusader
		[1044]   = Defaults(), -- Blessing of Freedom
		[210256] = Defaults(), -- Blessing of Sanctuary
		[199545] = Defaults(), -- Steed of Glory
		[210294] = Defaults(), -- Divine Favor
		[221886] = Defaults(), -- Divine Steed
		[31821]  = Defaults(), -- Aura Mastery
		[203538] = Defaults(), -- Greater Blessing of Kings
		[203539] = Defaults(), -- Greater Blessing of Wisdom
	--Priest
		[81782]  = Defaults(), -- Power Word: Barrier
		[47585]  = Defaults(), -- Dispersion
		[19236]  = Defaults(), -- Desperate Prayer
		[213602] = Defaults(), -- Greater Fade
		[27827]  = Defaults(), -- Spirit of Redemption
		[197268] = Defaults(), -- Ray of Hope
		[47788]  = Defaults(), -- Guardian Spirit
		[33206]  = Defaults(), -- Pain Suppression
		[200183] = Defaults(), -- Apotheosis
		[10060]  = Defaults(), -- Power Infusion
		[47536]  = Defaults(), -- Rapture
		[194249] = Defaults(), -- Voidform
		[193223] = Defaults(), -- Surrdender to Madness
		[197862] = Defaults(), -- Archangel
		[197871] = Defaults(), -- Dark Archangel
		[197874] = Defaults(), -- Dark Archangel
		[215769] = Defaults(), -- Spirit of Redemption
		[213610] = Defaults(), -- Holy Ward
		[121557] = Defaults(), -- Angelic Feather
		[214121] = Defaults(), -- Body and Mind
		[65081]  = Defaults(), -- Body and Soul
		[197767] = Defaults(), -- Speed of the Pious
		[210980] = Defaults(), -- Focus in the Light
		[221660] = Defaults(), -- Holy Concentration
		[15286]  = Defaults(), -- Vampiric Embrace
	--Rogue
		[5277]   = Defaults(), -- Evasion
		[31224]  = Defaults(), -- Cloak of Shadows
		[1966]   = Defaults(), -- Feint
		[199754] = Defaults(), -- Riposte
		[45182]  = Defaults(), -- Cheating Death
		[199027] = Defaults(), -- Veil of Midnight
		[121471] = Defaults(), -- Shadow Blades
		[13750]  = Defaults(), -- Adrenaline Rush
		[51690]  = Defaults(), -- Killing Spree
		[185422] = Defaults(), -- Shadow Dance
		[198368] = Defaults(), -- Take Your Cut
		[198027] = Defaults(), -- Turn the Tables
		[213985] = Defaults(), -- Thief's Bargain
		[197003] = Defaults(), -- Maneuverability
		[212198] = Defaults(), -- Crimson Vial
		[185311] = Defaults(), -- Crimson Vial
		[209754] = Defaults(), -- Boarding Party
		[36554]  = Defaults(), -- Shadowstep
		[2983]   = Defaults(), -- Sprint
		[202665] = Defaults(), -- Curse of the Dreadblades (Self Debuff)
	--Shaman
		[204293] = Defaults(), -- Spirit Link
		[204288] = Defaults(), -- Earth Shield
		[210918] = Defaults(), -- Ethereal Form
		[207654] = Defaults(), -- Servant of the Queen
		[108271] = Defaults(), -- Astral Shift
		[98007]  = Defaults(), -- Spirit Link Totem
		[207498] = Defaults(), -- Ancestral Protection
		[204366] = Defaults(), -- Thundercharge
		[209385] = Defaults(), -- Windfury Totem
		[208963] = Defaults(), -- Skyfury Totem
		[204945] = Defaults(), -- Doom Winds
		[205495] = Defaults(), -- Stormkeeper
		[208416] = Defaults(), -- Sense of Urgency
		[2825]   = Defaults(), -- Bloodlust
		[16166]  = Defaults(), -- Elemental Mastery
		[167204] = Defaults(), -- Feral Spirit
		[114050] = Defaults(), -- Ascendance (Elem)
		[114051] = Defaults(), -- Ascendance (Enh)
		[114052] = Defaults(), -- Ascendance (Resto)
		[79206]  = Defaults(), -- Spiritwalker's Grace
		[58875]  = Defaults(), -- Spirit Walk
		[157384] = Defaults(), -- Eye of the Storm
		[192082] = Defaults(), -- Wind Rush
		[2645]   = Defaults(), -- Ghost Wolf
		[32182]  = Defaults(), -- Heroism
		[108281] = Defaults(), -- Ancestral Guidance
	--Warlock
		[108416] = Defaults(), -- Dark Pact
		[104773] = Defaults(), -- Unending Resolve
		[221715] = Defaults(), -- Essence Drain
		[212295] = Defaults(), -- Nether Ward
		[212284] = Defaults(), -- Firestone
		[196098] = Defaults(), -- Soul Harvest
		[221705] = Defaults(), -- Casting Circle
		[111400] = Defaults(), -- Burning Rush
		[196674] = Defaults(), -- Planeswalker
	--Warrior
		[118038] = Defaults(), -- Die by the Sword
		[184364] = Defaults(), -- Enraged Regeneration
		[209484] = Defaults(), -- Tactical Advance
		[97463]  = Defaults(), -- Commanding Shout
		[213915] = Defaults(), -- Mass Spell Reflection
		[199038] = Defaults(), -- Leave No Man Behind
		[223658] = Defaults(), -- Safeguard
		[147833] = Defaults(), -- Intervene
		[198760] = Defaults(), -- Intercept
		[12975]  = Defaults(), -- Last Stand
		[871]    = Defaults(), -- Shield Wall
		[23920]  = Defaults(), -- Spell Reflection
		[216890] = Defaults(), -- Spell Reflection (PvPT)
		[227744] = Defaults(), -- Ravager
		[203524] = Defaults(), -- Neltharion's Fury
		[190456] = Defaults(), -- Ignore Pain
		[132404] = Defaults(), -- Shield Block
		[1719]   = Defaults(), -- Battle Cry
		[107574] = Defaults(), -- Avatar
		[227847] = Defaults(), -- Bladestorm (Arm)
		[46924]  = Defaults(), -- Bladestorm (Fury)
		[12292]  = Defaults(), -- Bloodbath
		[118000] = Defaults(), -- Dragon Roar
		[199261] = Defaults(), -- Death Wish
		[18499]  = Defaults(), -- Berserker Rage
		[202164] = Defaults(), -- Bounding Stride
		[215572] = Defaults(), -- Frothing Berserker
		[199203] = Defaults(), -- Thirst for Battle
	--Racial
		[65116] = Defaults(), -- Stoneform
		[59547] = Defaults(), -- Gift of the Naaru
		[20572] = Defaults(), -- Blood Fury
		[26297] = Defaults(), -- Berserking
		[68992] = Defaults(), -- Darkflight
		[58984] = Defaults(), -- Shadowmeld
	--Consumables
		[251231] = Defaults(), -- Steelskin Potion (BfA Armor)
		[251316] = Defaults(), -- Potion of Bursting Blood (BfA Melee)
		[269853] = Defaults(), -- Potion of Rising Death (BfA Caster)
		[279151] = Defaults(), -- Battle Potion of Intellect (BfA Intellect)
		[279152] = Defaults(), -- Battle Potion of Agility (BfA Agility)
		[279153] = Defaults(), -- Battle Potion of Strength (BfA Strength)
		[178207] = Defaults(), -- Drums of Fury
		[230935] = Defaults(), -- Drums of the Mountain (Legion)
		[256740] = Defaults(), -- Drums of the Maelstrom (BfA)
	},
}

-- Buffs that really we dont need to see
G.unitframe.aurafilters['Blacklist'] = {
	['type'] = 'Blacklist',
	['spells'] = {
		[36900]  = Defaults(), -- Soul Split: Evil!
		[36901]  = Defaults(), -- Soul Split: Good
		[36893]  = Defaults(), -- Transporter Malfunction
		[97821]  = Defaults(), -- Void-Touched
		[36032]  = Defaults(), -- Arcane Charge
		[8733]   = Defaults(), -- Blessing of Blackfathom
		[25771]  = Defaults(), -- Forbearance (pally: divine shield, hand of protection, and lay on hands)
		[57724]  = Defaults(), -- Sated (lust debuff)
		[57723]  = Defaults(), -- Exhaustion (heroism debuff)
		[80354]  = Defaults(), -- Temporal Displacement (timewarp debuff)
		[95809]  = Defaults(), -- Insanity debuff (hunter pet heroism: ancient hysteria)
		[58539]  = Defaults(), -- Watcher's Corpse
		[26013]  = Defaults(), -- Deserter
		[71041]  = Defaults(), -- Dungeon Deserter
		[41425]  = Defaults(), -- Hypothermia
		[55711]  = Defaults(), -- Weakened Heart
		[8326]   = Defaults(), -- Ghost
		[23445]  = Defaults(), -- Evil Twin
		[24755]  = Defaults(), -- Tricked or Treated
		[25163]  = Defaults(), -- Oozeling's Disgusting Aura
		[124275] = Defaults(), -- Stagger
		[124274] = Defaults(), -- Stagger
		[124273] = Defaults(), -- Stagger
		[117870] = Defaults(), -- Touch of The Titans
		[123981] = Defaults(), -- Perdition
		[15007]  = Defaults(), -- Ress Sickness
		[113942] = Defaults(), -- Demonic: Gateway
		[89140]  = Defaults(), -- Demonic Rebirth: Cooldown
	},
}

--[[
	This should be a list of important buffs that we always want to see when they are active
	bloodlust, paladin hand spells, raid cooldowns, etc..
]]
G.unitframe.aurafilters['Whitelist'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		[31821]  = Defaults(), -- Devotion Aura
		[2825]   = Defaults(), -- Bloodlust
		[32182]  = Defaults(), -- Heroism
		[80353]  = Defaults(), -- Time Warp
		[90355]  = Defaults(), -- Ancient Hysteria
		[47788]  = Defaults(), -- Guardian Spirit
		[33206]  = Defaults(), -- Pain Suppression
		[116849] = Defaults(), -- Life Cocoon
		[22812]  = Defaults(), -- Barkskin
	},
}

-- RAID DEBUFFS: This should be pretty self explainitory
G.unitframe.aurafilters['RaidDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
	-- Mythic+ Dungeons
		[209858] = Defaults(), -- Necrotic
		[226512] = Defaults(), -- Sanguine
		[240559] = Defaults(), -- Grievous
		[240443] = Defaults(), -- Bursting
		[196376] = Defaults(), -- Grievous Tear

		--BFA Dungeons
		--Freehold
		[258323] = Defaults(), -- Infected Wound
		[257775] = Defaults(), -- Plague Step
		[257908] = Defaults(), -- Oiled Blade
		[257436] = Defaults(), -- Poisoning Strike
		[274389] = Defaults(), -- Rat Traps
		[274555] = Defaults(), -- Scabrous Bites
		[258875] = Defaults(), -- Blackout Barrel
		[256363] = Defaults(), -- Ripper Punch

		--Shrine of the Storm
		[264560] = Defaults(), -- Choking Brine
		[268233] = Defaults(), -- Electrifying Shock
		[268322] = Defaults(), -- Touch of the Drowned
		[268896] = Defaults(), -- Mind Rend
		[268104] = Defaults(), -- Explosive Void
		[267034] = Defaults(), -- Whispers of Power
		[276268] = Defaults(), -- Heaving Blow
		[264166] = Defaults(), -- Undertow
		[264526] = Defaults(), -- Grasp of the Depths
		[274633] = Defaults(), -- Sundering Blow
		[268214] = Defaults(), -- Carving Flesh
		[267818] = Defaults(), -- Slicing Blast
		[268309] = Defaults(), -- Unending Darkness
		[268317] = Defaults(), -- Rip Mind
		[268391] = Defaults(), -- Mental Assault
		[274720] = Defaults(), -- Abyssal Strike

		--Siege of Boralus
		[257168] = Defaults(), -- Cursed Slash
		[272588] = Defaults(), -- Rotting Wounds
		[272571] = Defaults(), -- Choking Waters
		[274991] = Defaults(), -- Putrid Waters
		[275835] = Defaults(), -- Stinging Venom Coating
		[273930] = Defaults(), -- Hindering Cut
		[257292] = Defaults(), -- Heavy Slash
		[261428] = Defaults(), -- Hangman's Noose
		[256897] = Defaults(), -- Clamping Jaws
		[272874] = Defaults(), -- Trample
		[273470] = Defaults(), -- Gut Shot
		[272834] = Defaults(), -- Viscous Slobber
		[257169] = Defaults(), -- Terrifying Roar
		[272713] = Defaults(), -- Crushing Slam

		-- Tol Dagor
		[258128] = Defaults(), -- Debilitating Shout
		[265889] = Defaults(), -- Torch Strike
		[257791] = Defaults(), -- Howling Fear
		[258864] = Defaults(), -- Suppression Fire
		[257028] = Defaults(), -- Fuselighter
		[258917] = Defaults(), -- Righteous Flames
		[257777] = Defaults(), -- Crippling Shiv
		[258079] = Defaults(), -- Massive Chomp
		[258058] = Defaults(), -- Squeeze
		[260016] = Defaults(), -- Itchy Bite
		[257119] = Defaults(), -- Sand Trap
		[260067] = Defaults(), -- Vicious Mauling
		[258313] = Defaults(), -- Handcuff
		[259711] = Defaults(), -- Lockdown
		[256198] = Defaults(), -- Azerite Rounds: Incendiary
		[256101] = Defaults(), -- Explosive Burst
		[256044] = Defaults(), -- Deadeye
		[256474] = Defaults(), -- Heartstopper Venom

		--Waycrest Manor
		[260703] = Defaults(), -- Unstable Runic Mark
		[263905] = Defaults(), -- Marking Cleave
		[265880] = Defaults(), -- Dread Mark
		[265882] = Defaults(), -- Lingering Dread
		[264105] = Defaults(), -- Runic Mark
		[264050] = Defaults(), -- Infected Thorn
		[261440] = Defaults(), -- Virulent Pathogen
		[263891] = Defaults(), -- Grasping Thorns
		[264378] = Defaults(), -- Fragment Soul
		[266035] = Defaults(), -- Bone Splinter
		[266036] = Defaults(), -- Drain Essence
		[260907] = Defaults(), -- Soul Manipulation
		[260741] = Defaults(), -- Jagged Nettles
		[264556] = Defaults(), -- Tearing Strike
		[265760] = Defaults(), -- Thorned Barrage
		[260551] = Defaults(), -- Soul Thorns
		[263943] = Defaults(), -- Etch
		[265881] = Defaults(), -- Decaying Touch
		[261438] = Defaults(), -- Wasting Strike
		[268202] = Defaults(), -- Death Lens
		[278456] = Defaults(), -- Infest

		-- Atal'Dazar
		[252781] = Defaults(), -- Unstable Hex
		[250096] = Defaults(), -- Wracking Pain
		[250371] = Defaults(), -- Lingering Nausea
		[253562] = Defaults(), -- Wildfire
		[255582] = Defaults(), -- Molten Gold
		[255041] = Defaults(), -- Terrifying Screech
		[255371] = Defaults(), -- Terrifying Visage
		[252687] = Defaults(), -- Venomfang Strike
		[254959] = Defaults(), -- Soulburn
		[255814] = Defaults(), -- Rending Maul
		[255421] = Defaults(), -- Devour
		[255434] = Defaults(), -- Serrated Teeth
		[256577] = Defaults(), -- Soulfeast

		--King's Rest
		[270492] = Defaults(), -- Hex
		[267763] = Defaults(), -- Wretched Discharge
		[276031] = Defaults(), -- Pit of Despair
		[265773] = Defaults(), -- Spit Gold
		[270920] = Defaults(), -- Seduction
		[270865] = Defaults(), -- Hidden Blade
		[271564] = Defaults(), -- Embalming Fluid
		[270507] = Defaults(), -- Poison Barrage
		[267273] = Defaults(), -- Poison Nova
		[270003] = Defaults(), -- Suppression Slam
		[270084] = Defaults(), -- Axe Barrage
		[267618] = Defaults(), -- Drain Fluids
		[267626] = Defaults(), -- Dessication
		[270487] = Defaults(), -- Severing Blade
		[266238] = Defaults(), -- Shattered Defenses
		[266231] = Defaults(), -- Severing Axe
		[266191] = Defaults(), -- Whirling Axes
		[272388] = Defaults(), -- Shadow Barrage
		[271640] = Defaults(), -- Dark Revelation
		[268796] = Defaults(), -- Impaling Spear

		--Motherlode
		[263074] = Defaults(), -- Festering Bite
		[280605] = Defaults(), -- Brain Freeze
		[257337] = Defaults(), -- Shocking Claw
		[270882] = Defaults(), -- Blazing Azerite
		[268797] = Defaults(), -- Transmute: Enemy to Goo
		[259856] = Defaults(), -- Chemical Burn
		[269302] = Defaults(), -- Toxic Blades
		[280604] = Defaults(), -- Iced Spritzer
		[257371] = Defaults(), -- Tear Gas
		[257544] = Defaults(), -- Jagged Cut
		[268846] = Defaults(), -- Echo Blade
		[262794] = Defaults(), -- Energy Lash
		[262513] = Defaults(), -- Azerite Heartseeker
		[260829] = Defaults(), -- Homing Missle (travelling)
		[260838] = Defaults(), -- Homing Missle (exploded)
		[263637] = Defaults(), -- Clothesline

		--Temple of Sethraliss
		[269686] = Defaults(), -- Plague
		[268013] = Defaults(), -- Flame Shock
		[268008] = Defaults(), -- Snake Charm
		[273563] = Defaults(), -- Neurotoxin
		[272657] = Defaults(), -- Noxious Breath
		[267027] = Defaults(), -- Cytotoxin
		[272699] = Defaults(), -- Venomous Spit
		[263371] = Defaults(), -- Conduction
		[272655] = Defaults(), -- Scouring Sand
		[263914] = Defaults(), -- Blinding Sand
		[263958] = Defaults(), -- A Knot of Snakes
		[266923] = Defaults(), -- Galvanize
		[268007] = Defaults(), -- Heart Attack

		--Underrot
		[265468] = Defaults(), -- Withering Curse
		[278961] = Defaults(), -- Decaying Mind
		[259714] = Defaults(), -- Decaying Spores
		[272180] = Defaults(), -- Death Bolt
		[272609] = Defaults(), -- Maddening Gaze
		[269301] = Defaults(), -- Putrid Blood
		[265533] = Defaults(), -- Blood Maw
		[265019] = Defaults(), -- Savage Cleave
		[265377] = Defaults(), -- Hooked Snare
		[265625] = Defaults(), -- Dark Omen
		[260685] = Defaults(), -- Taint of G'huun
		[266107] = Defaults(), -- Thirst for Blood
		[260455] = Defaults(), -- Serrated Fangs

	-- Uldir
		-- MOTHER
		[268277] = Defaults(), -- Purifying Flame
		[268253] = Defaults(), -- Surgical Beam
		[268095] = Defaults(), -- Cleansing Purge
		[267787] = Defaults(), -- Sundering Scalpel
		[268198] = Defaults(), -- Clinging Corruption
		[267821] = Defaults(), -- Defense Grid

		-- Vectis
		[265127] = Defaults(), -- Lingering Infection
		[265178] = Defaults(), -- Mutagenic Pathogen
		[265206] = Defaults(), -- Immunosuppression
		[265212] = Defaults(), -- Gestate
		[265129] = Defaults(), -- Omega Vector
		[267160] = Defaults(), -- Omega Vector
		[267161] = Defaults(), -- Omega Vector
		[267162] = Defaults(), -- Omega Vector
		[267163] = Defaults(), -- Omega Vector
		[267164] = Defaults(), -- Omega Vector

		-- Mythrax
		--[272146] = Defaults(), -- Annihilation
		[272536] = Defaults(), -- Imminent Ruin
		[274693] = Defaults(), -- Essence Shear
		[272407] = Defaults(), -- Oblivion Sphere

		-- Fetid Devourer
		[262313] = Defaults(), -- Malodorous Miasma
		[262292] = Defaults(), -- Rotting Regurgitation
		[262314] = Defaults(), -- Deadly Disease

		-- Taloc
		[270290] = Defaults(), -- Blood Storm
		[275270] = Defaults(), -- Fixate
		[271224] = Defaults(), -- Plasma Discharge
		[271225] = Defaults(), -- Plasma Discharge

		-- Zul
		[273365] = Defaults(), -- Dark Revelation
		[273434] = Defaults(), -- Pit of Despair
		--[274195] = Defaults(), -- Corrupted Blood
		[272018] = Defaults(), -- Absorbed in Darkness
		[274358] = Defaults(), -- Rupturing Blood

		-- Zek'voz, Herald of N'zoth
		[265237] = Defaults(), -- Shatter
		[265264] = Defaults(), -- Void Lash
		[265360] = Defaults(), -- Roiling Deceit
		[265662] = Defaults(), -- Corruptor's Pact
		[265646] = Defaults(), -- Will of the Corruptor

		-- G'huun
		[263436] = Defaults(), -- Imperfect Physiology
		[263227] = Defaults(), -- Putrid Blood
		[263372] = Defaults(), -- Power Matrix
		[272506] = Defaults(), -- Explosive Corruption
		[267409] = Defaults(), -- Dark Bargain
		[267430] = Defaults(), -- Torment
		[263235] = Defaults(), -- Blood Feast
		[270287] = Defaults(), -- Blighted Ground

	-- Siege of Zuldazar
		-- Ra'wani Kanae/Frida Ironbellows
		[283573] = Defaults(), -- Sacred Blade
		[283617] = Defaults(), -- Wave of Light
		[283651] = Defaults(), -- Blinding Faith
		[284595] = Defaults(), -- Penance
		[283582] = Defaults(), -- Consecration

		-- Grong
		[285998] = Defaults(), -- Ferocious Roar
		[283069] = Defaults(), -- Megatomic Fire
		[285671] = Defaults(), -- Crushed
		[285875] = Defaults(), -- Rending Bite
		--[282010] = Defaults(), -- Shaken
	},
}

--[[
	RAID BUFFS:
	Buffs that are provided by NPCs in raid or other PvE content.
	This can be buffs put on other enemies or on players.
]]
G.unitframe.aurafilters['RaidBuffsElvUI'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		--Mythic/Mythic+
		[209859] = Defaults(), -- Bolster
		[178658] = Defaults(), -- Raging
		[226510] = Defaults(), -- Sanguine
		[277242] = Defaults(), -- Symbiote of G'huun (Infested)

		--Raids
	},
}

-- Spells that we want to show the duration backwards
E.ReverseTimer = {

}

-- BuffWatch: List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, anyUnit, onlyShowMissing, style, displayText, decimalThreshold, textColor, textThreshold, xOffset, yOffset, sizeOverride)
	local r, g, b = unpack(color)

	local r2, g2, b2 = 1, 1, 1
	if textColor then
		r2, g2, b2 = unpack(textColor)
	end

	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b},
	["anyUnit"] = anyUnit, ["onlyShowMissing"] = onlyShowMissing, ['style'] = style or 'coloredIcon', ['displayText'] = displayText or false, ['decimalThreshold'] = decimalThreshold or 5,
	['textColor'] = {["r"] = r2, ["g"] = g2, ["b"] = b2}, ['textThreshold'] = textThreshold or -1, ['xOffset'] = xOffset or 0, ['yOffset'] = yOffset or 0, ["sizeOverride"] = sizeOverride or 0}
end

G.unitframe.buffwatch = {
	PRIEST = {
		[194384] = ClassBuff(194384, "TOPRIGHT", {1, 1, 0.66}),          -- Atonement
		[214206] = ClassBuff(214206, "TOPRIGHT", {1, 1, 0.66}),          -- Atonement (PvP)
		[41635]  = ClassBuff(41635, "BOTTOMRIGHT", {0.2, 0.7, 0.2}),     -- Prayer of Mending
		[193065] = ClassBuff(193065, "BOTTOMRIGHT", {0.54, 0.21, 0.78}), -- Masochism
		[139]    = ClassBuff(139, "BOTTOMLEFT", {0.4, 0.7, 0.2}),        -- Renew
		[17]     = ClassBuff(17, "TOPLEFT", {0.7, 0.7, 0.7}, true),      -- Power Word: Shield
		[47788]  = ClassBuff(47788, "LEFT", {0.86, 0.45, 0}, true),      -- Guardian Spirit
		[33206]  = ClassBuff(33206, "LEFT", {0.47, 0.35, 0.74}, true),   -- Pain Suppression
	},
	DRUID = {
		[774]    = ClassBuff(774, "TOPRIGHT", {0.8, 0.4, 0.8}),   		-- Rejuvenation
		[155777] = ClassBuff(155777, "RIGHT", {0.8, 0.4, 0.8}),   		-- Germination
		[8936]   = ClassBuff(8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}),		-- Regrowth
		[33763]  = ClassBuff(33763, "TOPLEFT", {0.4, 0.8, 0.2}),  		-- Lifebloom
		[48438]  = ClassBuff(48438, "BOTTOMRIGHT", {0.8, 0.4, 0}),		-- Wild Growth
		[207386] = ClassBuff(207386, "TOP", {0.4, 0.2, 0.8}),     		-- Spring Blossoms
		[102351] = ClassBuff(102351, "LEFT", {0.2, 0.8, 0.8}),    		-- Cenarion Ward (Initial Buff)
		[102352] = ClassBuff(102352, "LEFT", {0.2, 0.8, 0.8}),    		-- Cenarion Ward (HoT)
		[200389] = ClassBuff(200389, "BOTTOM", {1, 1, 0.4}),      		-- Cultivation
	},
	PALADIN = {
		[53563]  = ClassBuff(53563, "TOPRIGHT", {0.7, 0.3, 0.7}),          -- Beacon of Light
		[156910] = ClassBuff(156910, "TOPRIGHT", {0.7, 0.3, 0.7}),         -- Beacon of Faith
		[200025] = ClassBuff(200025, "TOPRIGHT", {0.7, 0.3, 0.7}),         -- Beacon of Virtue
		[1022]   = ClassBuff(1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true),    -- Hand of Protection
		[1044]   = ClassBuff(1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true),  -- Hand of Freedom
		[6940]   = ClassBuff(6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true), -- Hand of Sacrifice
		[223306] = ClassBuff(223306, 'BOTTOMLEFT', {0.7, 0.7, 0.3}),       -- Bestow Faith
	},
	SHAMAN = {
		[61295]  = ClassBuff(61295, "TOPRIGHT", {0.7, 0.3, 0.7}),   	 -- Riptide
		[974] = ClassBuff(974, "BOTTOMRIGHT", {0.2, 0.2, 1}), 	 -- Earth Shield
	},
	MONK = {
		[119611] = ClassBuff(119611, "TOPLEFT", {0.3, 0.8, 0.6}),        -- Renewing Mist
		[116849] = ClassBuff(116849, "TOPRIGHT", {0.2, 0.8, 0.2}, true), -- Life Cocoon
		[124682] = ClassBuff(124682, "BOTTOMLEFT", {0.8, 0.8, 0.25}),    -- Enveloping Mist
		[191840] = ClassBuff(191840, "BOTTOMRIGHT", {0.27, 0.62, 0.7}),  -- Essence Font
	},
	ROGUE = {
		[57934] = ClassBuff(57934, "TOPRIGHT", {0.89, 0.09, 0.05}),		 -- Tricks of the Trade
	},
	WARRIOR = {
		[114030] = ClassBuff(114030, "TOPLEFT", {0.2, 0.2, 1}),     	 -- Vigilance
		[3411]   = ClassBuff(3411, "TOPRIGHT", {0.89, 0.09, 0.05}), 	 -- Intervene
	},
	PET = {
		-- Warlock Pets
		[193396] = ClassBuff(193396, 'TOPRIGHT', {0.6, 0.2, 0.8}, true), -- Demonic Empowerment
		-- Hunter Pets
		[272790] = ClassBuff(272790, 'TOPLEFT', {0.89, 0.09, 0.05}, true), -- Frenzy
		[136]   = ClassBuff(136, 'TOPRIGHT', {0.2, 0.8, 0.2}, true)      -- Mend Pet
	},
	HUNTER = {}, --Keep even if it's an empty table, so a reference to G.unitframe.buffwatch[E.myclass][SomeValue] doesn't trigger error
	DEMONHUNTER = {},
	WARLOCK = {},
	MAGE = {},
	DEATHKNIGHT = {},
}

-- Profile specific BuffIndicator
P['unitframe']['filters'] = {
	['buffwatch'] = {},
}

-- List of spells to display ticks
G.unitframe.ChannelTicks = {
	-- Warlock
	[SpellName(198590)] = 6, -- Drain Soul
	[SpellName(755)]    = 6, -- Health Funnel
	[SpellName(234153)] = 6, -- Drain Life
	-- Priest
	[SpellName(64843)]  = 4, -- Divine Hymn
	[SpellName(15407)]  = 4, -- Mind Flay
	-- Mage
	[SpellName(5143)]   = 5,  -- Arcane Missiles
	[SpellName(12051)]  = 3,  -- Evocation
	[SpellName(205021)] = 10, -- Ray of Frost
	--Druid
	[SpellName(740)]    = 4, -- Tranquility
}

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_TALENT_UPDATE")
f:SetScript("OnEvent", function()
	if strlower(E.myclass) ~= "priest" then return end

	local penanceTicks = IsPlayerSpell(193134) and 4 or 3
	E.global.unitframe.ChannelTicks[SpellName(47540)] = penanceTicks --Penance
end)

G.unitframe.ChannelTicksSize = {
	-- Warlock
	[SpellName(198590)] = 1, -- Drain Soul
}

-- Spells Effected By Haste
G.unitframe.HastedChannelTicks = {
	[SpellName(205021)] = true, -- Ray of Frost
}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[2825]  = {r = 0.98, g = 0.57, b = 0.10}, -- Bloodlust
	[32182] = {r = 0.98, g = 0.57, b = 0.10}, -- Heroism
	[80353] = {r = 0.98, g = 0.57, b = 0.10}, -- Time Warp
	[90355] = {r = 0.98, g = 0.57, b = 0.10}, -- Ancient Hysteria
}

G.unitframe.DebuffHighlightColors = {
	[25771] = {enable = false, style = "FILL", color = {r = 0.85, g = 0, b = 0, a = 0.85}},
}

G.unitframe.specialFilters = {
	-- Whitelists
	['Boss'] = true,
	['Personal'] = true,
	['nonPersonal'] = true,
	['CastByUnit'] = true,
	['notCastByUnit'] = true,
	['Dispellable'] = true,
	['notDispellable'] = true,
	['CastByNPC'] = true,
	['CastByPlayers'] = true,

	-- Blacklists
	['blockNonPersonal'] = true,
	['blockCastByPlayers'] = true,
	['blockNoDuration'] = true,
	['blockDispellable'] = true,
	['blockNotDispellable'] = true,
};
