--[[
		This file is for adding of deleting a spellID for a specific encounter on Grid layout
		or enemy cooldown in Arena displayed on screen.
		
		The best way to add or delete spell is to go at www.wowhead.com, search for a spell :
		Example : Incinerate Flesh from Lord Jaraxxus -> http://www.wowhead.com/?spell=67049
		Take the number ID at the end of the URL, and add it to the list
		
		That's it, That's all! 
		
		Tukz
]]-- 

--------------------------------------------------------------------------------------------
-- PVP! Enemy cooldown tracker or Spell Alert list
--------------------------------------------------------------------------------------------

-- the spellIDs to track on screen in arena.
if TukuiCF["arena"].spelltracker == true then
	TukuiDB.spelltracker = {
		[1766] = 10, -- kick
		[6552] = 10, -- pummel
		[2139] = 24, -- counterspell
		[19647] = 24, -- spell lock
		[10890] = 27, -- fear priest
		[47476] = 120, -- strangulate
		[47528] = 10, -- mindfreeze
		[29166] = 180, -- innervate
		[49039] = 120, -- Lichborne
		[54428] = 60, -- Divine Plea
		[10278] = 180, -- Hand of Protection
		[16190] = 300, -- Mana Tide Totem
		[51514] = 45, -- Hex
		[2094] = 120, -- Blind
		[72] = 12, -- fucking prot warrior shield bash
		[33206] = 144, -- pain sup
		[15487] = 45, -- silence priest
		[34490] = 20, -- i hate hunter silencing shot
		[14311] = 30, -- hunter forst trap shit
	}
end

--------------------------------------------------------------------------------------------
-- New Aurawatch by Foof
--------------------------------------------------------------------------------------------

if TukuiCF["unitframes"].raidunitdebuffwatch == true then
	-- Classbuffs { spell ID, position [, {r,g,b,a}][, anyUnit] }
	-- For oUF_AuraWatch
	do
		TukuiDB.buffids = {
			PRIEST = {
				{6788, "TOPLEFT", {1, 0, 0}, true}, -- Weakened Soul
				{48113, "TOPRIGHT", {0.2, 0.7, 0.2}}, -- Prayer of Mending
				{48068, "BOTTOMLEFT", {0.4, 0.7, 0.2}}, -- Renew
				{48066, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true}, -- Power Word: Shield
			},
			DRUID = {
				{48440, "TOPLEFT", {0.8, 0.4, 0.8}}, -- Rejuvenation
				{48443, "TOPRIGHT", {0.2, 0.8, 0.2}}, -- Regrowth
				{48450, "BOTTOMLEFT", {0.4, 0.8, 0.2}}, -- Lifebloom
				{53249, "BOTTOMRIGHT", {0.8, 0.4, 0}}, -- Wild Growth
			},
			PALADIN = {
				{53563, "TOPLEFT", {0.7, 0.3, 0.7}}, -- Beacon of Light
				{53601, "TOPRIGHT", {0.4, 0.7, 0.2}}, -- Sacred Shield
			},
			SHAMAN = {
				{61301, "TOPLEFT", {0.7, 0.3, 0.7}}, -- Riptide 
				{49284, "TOPRIGHT", {0.2, 0.7, 0.2}}, -- Earthliving Weapon
				{16237, "BOTTOMLEFT", {0.4, 0.7, 0.2}}, -- Ancestral Fortitude
				{52000, "BOTTOMRIGHT", {0.7, 0.4, 0}}, -- Earthliving
			},
			ALL = {
				-- {2893, "RIGHT", {0, 1, 0}}, -- Abolish Poison
				{23333, "LEFT", {1, 0, 0}}, -- Warsong flag xD
			},
		}
	end
	-- Raid debuffs (now using it with oUF_RaidDebuff instead of oUF_Aurawatch)
	do
		local _, ns = ...
		local ORD = ns.oUF_RaidDebuffs or oUF_RaidDebuffs

		if not ORD then return end
		
		ORD.ShowDispelableDebuff = true
		ORD.FilterDispellableDebuff = true
		ORD.MatchBySpellName = false
		ORD.SHAMAN_CAN_DECURSE = true

		TukuiDB.debuffids = {
			-- Naxxramas
			27808, -- Frost Blast
			32407, -- Strange Aura
			28408, -- Chains of Kel'Thuzad

			-- Ulduar
			66313, -- Fire Bomb
			63134, -- Sara's Blessing
			62717, -- Slag Pot
			63018, -- Searing Light
			64233, -- Gravity Bomb
			63495, -- Static Disruption

			-- Trial of the Crusader
			66406, -- Snobolled!
			67574, -- Pursued by Anub'arak
			68509, -- Penetrating Cold
			67651, -- Arctic Breath
			68127, -- Legion Flame
			67049, -- Incinerate Flesh
			66869, -- Burning Bile
			66823, -- Paralytic Toxin

			-- Icecrown Citadel
			71224, -- Mutated Infection
			71822, -- Shadow Resonance
			70447, -- Volatile Ooze Adhesive
			72293, -- Mark of the Fallen Champion
			72448, -- Rune of Blood
			71473, -- Essence of the Blood Queen
			71624, -- Delirious Slash
			70923, -- Uncontrollable Frenzy
			70588, -- Suppression
			71738, -- Corrosion
			71733, -- Acid Burst
			72108, -- Death and Decay
			71289, -- Dominate Mind
			69762, -- Unchained Magic
			69651, -- Wounding Strike
			69065, -- Impaled
			71218, -- Vile Gas
			72442, -- Boiling Blood
			72769, -- Scent of Blood (heroic)
			69279, -- Gas Spore
			70949, -- Essence of the Blood Queen (hand icon)
			72151, -- Frenzied Bloodthirst (bite icon)
			71474, -- Frenzied Bloodthirst (red bite icon)
			71340, -- Pact of the Darkfallen
			72985, -- Swarming Shadows (pink icon)
			71267, -- Swarming Shadows (black purple icon)
			71264, -- Swarming Shadows (swirl icon)
			71807, -- Glittering Sparks
			70873, -- Emerald Vigor
			71283, -- Gut Spray
			69766, -- Instability
			70126, -- Frost Beacon
			70157, -- Ice Tomb
			71056, -- Frost Breath
			70106, -- Chilled to the Bone
			70128, -- Mystic Buffet
			73785, -- Necrotic Plague
			73779, -- Infest
			73800, -- Soul Shriek
			73797, -- Soul Reaper
			73708, -- Defile
			74322, -- Harvested Soul
			
			--Ruby Sanctum
			74502, --Enervating Brand
			75887, --Blazing Aura  
			74562, --Fiery Combustion
			74567, --Mark of Combustion (Fire)
			74792, --Soul Consumption
			74795, --Mark Of Consumption (Soul)

			-- Other debuff
			67479, -- Impale
		}
		
		ORD:RegisterDebuffs(TukuiDB.debuffids)
	end
end