local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local ElvUF = E.oUF
local Tags = ElvUF.Tags

local strlower, strfind = strlower, strfind
local gsub, type, next, strsub = gsub, type, next, strsub
local format, gmatch, strmatch = format, gmatch, strmatch
local utf8lower, utf8sub = string.utf8lower, string.utf8sub

local _G = _G
local GetRuneCooldown = GetRuneCooldown
local UnitHealthMax = UnitHealthMax
local UnitIsUnit = UnitIsUnit
local IsInInstance = IsInInstance
local UnitIsPlayer = UnitIsPlayer
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitStagger = UnitStagger

local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local GetCVarBool = C_CVar.GetCVarBool

local LEVEL = strlower(LEVEL)

-- GLOBALS: UnitPower -- override during testing groups

local POWERTYPE_MANA = Enum.PowerType.Mana
local POWERTYPE_COMBOPOINTS = Enum.PowerType.ComboPoints

local SPEC_PRIEST_SHADOW = SPEC_PRIEST_SHADOW or 3
local SPEC_MONK_BREWMASTER = SPEC_MONK_BREWMASTER or 1

local STAGGER_YELLOW_TRANSITION = STAGGER_YELLOW_TRANSITION or 0.3
local STAGGER_RED_TRANSITION = STAGGER_RED_TRANSITION or 0.6
local STAGGER_GREEN_INDEX = STAGGER_GREEN_INDEX or 1
local STAGGER_YELLOW_INDEX = STAGGER_YELLOW_INDEX or 2
local STAGGER_RED_INDEX = STAGGER_RED_INDEX or 3

local SPEC_MAGE_ARCANE = SPEC_MAGE_ARCANE or 1
local SPEC_MAGE_FROST = SPEC_MAGE_FROST or 3
local SPEC_SHAMAN_ENHANCEMENT = SPEC_SHAMAN_ENHANCEMENT or 2
local SPEC_WARLOCK_DEMONOLOGY = SPEC_WARLOCK_DEMONOLOGY or 2
local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION or 3

local POWERTYPE_SHADOW_ORBS = Enum.PowerType.ShadowOrbs or 28
local POWERTYPE_ARCANE_CHARGES = Enum.PowerType.ArcaneCharges or 16
local POWERTYPE_BURNING_EMBERS = Enum.PowerType.BurningEmbers or 14
local POWERTYPE_DEMONIC_FURY = Enum.PowerType.DemonicFury or 15
local POWERTYPE_SOUL_SHARDS = Enum.PowerType.SoulShards or 7

-- these are not real class powers
local POWERTYPE_ICICLES = -1
local POWERTYPE_MAELSTROM = -2

local SPELL_FROST_ICICLES = 205473
local SPELL_ARCANE_CHARGE = 36032
local SPELL_MAELSTROM = 344179

------------------------------------------------------------------------
--	Tag API
------------------------------------------------------------------------

--[[
	tagName = Tag Name
	category = Category that you want it to fall in
	description = self explainitory
	order = This is optional. It's used for sorting the tags by order and not by name. The +10 is not a rule. I reserve the first 10 slots.
]]

function E:AddTagInfo(tagName, category, description, order, hidden)
	if type(order) == 'number' then order = order + 10 else order = nil end

	local info = E.TagInfo[tagName]
	if not info then
		info = {}

		E.TagInfo[tagName] = info
	end

	info.category = category or 'Miscellaneous'
	info.description = description or ''
	info.order = order or nil
	info.hidden = hidden or nil

	return info
end

local RefreshNewTags -- will turn true at EOF
function E:AddTag(tagName, eventsOrSeconds, func, block, spells)
	if block then return end -- easy killer for tags

	if type(eventsOrSeconds) == 'number' then
		Tags.OnUpdateThrottle[tagName] = eventsOrSeconds
	else
		Tags.Events[tagName] = (E.Classic and gsub(eventsOrSeconds, 'UNIT_HEALTH([^%s_]?)', 'UNIT_HEALTH_FREQUENT%1')) or gsub(eventsOrSeconds, 'UNIT_HEALTH_FREQUENT', 'UNIT_HEALTH')
	end

	-- we need to trigger the newindex on oUF side to set the env
	if Tags.Methods[tagName] then
		Tags.Methods[tagName] = nil
	end

	-- when we set these the env will be from oUF
	Tags.Methods[tagName] = func

	-- if it uses UNIT_AURA we block spells unless allowed
	if spells then
		for spellID, allow in next, spells do
			Tags.Spells[spellID] = allow
		end
	end

	if RefreshNewTags then
		Tags:RefreshEvents(tagName)
		Tags:RefreshMethods(tagName)
	end
end

function E:CallTag(tag, ...)
	local func = ElvUF.Tags.Methods[tag]
	if not func then return end

	return func(...)
end

function E:TagUpdateRate(second)
	Tags:SetEventUpdateTimer(second)
end

------------------------------------------------------------------------
--	Tag Extra Events
------------------------------------------------------------------------

Tags.SharedEvents.INSTANCE_ENCOUNTER_ENGAGE_UNIT = true
Tags.SharedEvents.PLAYER_GUILD_UPDATE = true
Tags.SharedEvents.PLAYER_TALENT_UPDATE = true
Tags.SharedEvents.QUEST_LOG_UPDATE = true

------------------------------------------------------------------------
--	Tag Functions
------------------------------------------------------------------------

Tags.Env.UnitEffectiveLevel = function(unit)
	if E.Retail or E.Mists or E.Wrath or E.TBC then
		return _G.UnitEffectiveLevel(unit)
	else
		return _G.UnitLevel(unit)
	end
end

Tags.Env.Abbrev = function(name)
	local letters, text = '', gsub(name, '%s<.+>$', '') -- clean titles
	local lastWord = strmatch(text, '.+%s(.+)$')
	if lastWord then
		for word in gmatch(text, '.-%s') do
			local firstLetter = utf8sub(gsub(word, '^[%s%p]*', ''), 1, 1)
			if firstLetter ~= utf8lower(firstLetter) then
				letters = format('%s%s. ', letters, firstLetter)
			end
		end

		name = format('%s%s', letters, lastWord)
	end

	return name
end

Tags.Env.NameHealthColor = function(tags, str, unit, default)
	if str == 'class' or str == 'reaction' then
		return tags.classcolor(unit) or default
	elseif str and strmatch(str, '^%x%x%x%x%x%x$') then
		return '|cFF'..str
	end

	return default
end

Tags.Env.GetTitleNPC = function(unit, custom)
	if UnitIsPlayer(unit) then return end

	-- similar to TT.GetLevelLine
	local info = E.ScanTooltip:GetUnitInfo(unit)
	local line = info and info.lines[GetCVarBool('colorblindmode') and 3 or 2]
	local text = line and line.leftText

	local lower = E:NotSecretValue(text) and text and strlower(text)
	if lower and not strfind(lower, LEVEL) then
		return custom and format(custom, text) or text
	end
end

Tags.Env.GetQuestData = function(unit, which, Hex)
	if IsInInstance() or UnitIsPlayer(unit) then return end

	local notMyQuest, lastTitle
	local info = E.ScanTooltip:GetUnitInfo(unit)
	if not (info and info.lines[2]) then return end

	for _, line in next, info.lines, 2 do
		local text = line and line.leftText
		if E:NotSecretValue(text) then -- skip any secret lines
			if not text or text == '' then return end

			if line.type == 18 or (not E.Retail and UnitIsPlayer(text)) then -- 18 is QuestPlayer
				notMyQuest = text ~= E.myname
			elseif text and not notMyQuest then
				if line.type == 17 or (not E.Retail and not lastTitle) then
					lastTitle = NP.QuestIcons.activeQuests[text]
				end -- this line comes from one line up in the tooltip

				local objectives = (line.type == 8 or not E.Retail) and lastTitle and lastTitle.objectives
				if objectives then
					local quest = objectives[text] or (not E.Retail and objectives[strsub(text, 4)])
					if quest then
						if not which then
							return text
						elseif which == 'count' then
							return quest.isPercent and format('%s%%', quest.value) or quest.value
						elseif which == 'title' then
							local colors = lastTitle.color
							if colors then
								return format('%s%s|r', Hex(colors), lastTitle.title)
							end

							return lastTitle.title
						elseif (which == 'info' or which == 'full') then
							local title = lastTitle.title

							local colors = lastTitle.color
							if colors then
								title = format('%s%s|r', Hex(colors), title)
							end

							if which == 'full' then
								return format('%s: %s', title, text)
							else
								return format(quest.isPercent and '%s: %s%%' or '%s: %s', title, quest.value)
							end
						end
					end
				end
			end
		end
	end
end

do
	local ClassPowers = {
		MONK		= Enum.PowerType.Chi or 12,
		PALADIN		= Enum.PowerType.HolyPower or 9,
		DEATHKNIGHT	= Enum.PowerType.Runes or 5,
		WARLOCK		= POWERTYPE_SOUL_SHARDS
	}

	local ClassPowerMax = {
		[POWERTYPE_MAELSTROM] = 10,
		[POWERTYPE_ICICLES] = 5,
	}

	local function CurrentApplications(spellID, filter) -- same as in oUF
		local info = GetPlayerAuraBySpellID(spellID)
		local checkFilter = info and (not filter or (filter == 'HELPFUL' and info.isHelpful) or (filter == 'HARMFUL' and info.isHarmful))
		return checkFilter and info.applications or 0
	end

	local function ClassPowerSpecial(unit, spellID, powerType, color, filter)
		local current, r, g, b = CurrentApplications(spellID, filter)
		local maximum = ClassPowerMax[powerType] or UnitPowerMax(unit, powerType)

		if color then r, g, b = color.r, color.g, color.b end
		return current or 0, maximum or 0, r or 1, g or 1, b or 1
	end

	Tags.Env.GetClassPower = function(unit)
		local isme = UnitIsUnit(unit, 'player')

		local spec, unitClass, barType, Min, Max
		if isme then
			spec = E.myspec
			unitClass = E.myclass
		elseif E.Retail then
			local info = E:GetUnitSpecInfo(unit)
			if info then
				spec = info.index
				unitClass = info.classFile
			end
		end

		-- handle the fake powers (these use UNIT_AURA)
		if E.Mists and unitClass == 'MAGE' and spec == SPEC_MAGE_ARCANE then
			return ClassPowerSpecial(unit, SPELL_ARCANE_CHARGE, POWERTYPE_ARCANE_CHARGES, ElvUF.colors.ClassBars.MAGE.ARCANE_CHARGES, 'HARMFUL')
		elseif E.Retail and unitClass == 'MAGE' and spec == SPEC_MAGE_FROST then
			return ClassPowerSpecial(unit, SPELL_FROST_ICICLES, POWERTYPE_ICICLES, ElvUF.colors.ClassBars.MAGE.FROST_ICICLES, 'HELPFUL')
		elseif E.Retail and unitClass == 'SHAMAN' and spec == SPEC_SHAMAN_ENHANCEMENT then
			return ClassPowerSpecial(unit, SPELL_MAELSTROM, POWERTYPE_MAELSTROM, ElvUF.colors.ClassBars.SHAMAN.MAELSTROM, 'HELPFUL')
		end

		local monk = unitClass == 'MONK' -- checking brewmaster
		if monk and spec == SPEC_MONK_BREWMASTER then
			Min = UnitStagger(unit) or 0
			Max = UnitHealthMax(unit)

			local staggerRatio = Min / Max
			local staggerIndex = (staggerRatio >= STAGGER_RED_TRANSITION and STAGGER_RED_INDEX) or (staggerRatio >= STAGGER_YELLOW_TRANSITION and STAGGER_YELLOW_INDEX) or STAGGER_GREEN_INDEX
			local color = ElvUF.colors.power.STAGGER[staggerIndex]
			local r, g, b = color.r, color.g, color.b

			return Min or 0, Max or 0, r or 1, g or 1, b or 1
		end

		-- try special powers or combo points
		local mistWarlock = E.Mists and unitClass == 'WARLOCK'
		if mistWarlock then -- little gremlins
			barType = (spec == SPEC_WARLOCK_DEMONOLOGY and POWERTYPE_DEMONIC_FURY) or (spec == SPEC_WARLOCK_DESTRUCTION and POWERTYPE_BURNING_EMBERS) or POWERTYPE_SOUL_SHARDS
		elseif E.Mists and unitClass == 'PRIEST' then -- only shadow orbs
			barType = spec == SPEC_PRIEST_SHADOW and POWERTYPE_SHADOW_ORBS
		elseif unitClass == 'MAGE' then
			barType = spec == SPEC_MAGE_ARCANE and POWERTYPE_ARCANE_CHARGES
		else
			barType = ClassPowers[unitClass]
		end

		local r, g, b
		if barType then
			local dk = unitClass == 'DEATHKNIGHT'
			Min = (dk and 0) or UnitPower(unit, barType)
			Max = (dk and 6) or UnitPowerMax(unit, barType)

			if dk and isme then
				for i = 1, Max do
					local _, _, runeReady = GetRuneCooldown(i)
					if runeReady then
						Min = Min + 1
					end
				end
			end

			local power = ElvUF.colors.ClassBars[unitClass]
			local warlockColor = (barType == POWERTYPE_BURNING_EMBERS and power.BURNING_EMBERS[Min]) or (barType == POWERTYPE_DEMONIC_FURY and power.DEMONIC_FURY) or power.SOUL_SHARDS
			local color = (mistWarlock and warlockColor) or (monk and power[Min]) or (dk and ((E.Mists or E.Wrath) and ElvUF.colors.class.DEATHKNIGHT or power[spec ~= 5 and spec or 1])) or power
			r, g, b = color.r, color.g, color.b
		else
			Min = UnitPower(unit, POWERTYPE_COMBOPOINTS)
			Max = UnitPowerMax(unit, POWERTYPE_COMBOPOINTS)

			local combo = ElvUF.colors.ComboPoints
			local c1, c2, c3 = combo[1], combo[2], combo[3]

			r, g, b = E:ColorGradient(Max == 0 and 0 or (Min / Max), c1.r, c1.g, c1.b, c2.r, c2.g, c2.b, c3.r, c3.g, c3.b)
		end

		-- try additional mana
		local altIndex = not r and E.Retail and _G.ALT_POWER_BAR_PAIR_DISPLAY_INFO[unitClass]
		if altIndex and altIndex[UnitPowerType(unit)] then
			Min = UnitPower(unit, POWERTYPE_MANA)
			Max = UnitPowerMax(unit, POWERTYPE_MANA)

			local mana = ElvUF.colors.power.MANA
			r, g, b = mana.r, mana.g, mana.b
		end

		return Min or 0, Max or 0, r or 1, g or 1, b or 1
	end
end

-- expose local functions for plugins onto this table
E.TagFunctions = {
	UnitEffectiveLevel = Tags.Env.UnitEffectiveLevel,
	UnitName = Tags.Env.UnitName,
	Abbrev = Tags.Env.Abbrev,
	NameHealthColor = Tags.Env.NameHealthColor,
	GetClassPower = Tags.Env.GetClassPower,
	GetTitleNPC = Tags.Env.GetTitleNPC,
	GetQuestData = Tags.Env.GetQuestData
}

------------------------------------------------------------------------
--	Available Tags: this is the list of stock oUF tags
------------------------------------------------------------------------

E.TagInfo = { -- `classification` is replaced so its included from Shared/Tags.lua
	affix				= { category = 'Classification', description = "Displays low level critter mobs" },
	arenaspec			= { category = 'PvP', description = "Displays the area spec of an unit" },
	cpoints				= { category = 'Classpower', description = "Displays amount of combo points the player has (only for player, shows nothing on 0)" },
	curhp				= { category = 'Health', description = "Displays the current HP without decimals" },
	curmana				= { category = 'Mana', description = "Displays the unit's current mana" },
	curpp				= { category = 'Power', description = "Displays the unit's current power without decimals" },
	dead				= { category = 'Status', description = "Displays <DEAD> if the unit is dead" },
	difficulty			= { category = 'Colors', description = "Changes color of the next tag based on how difficult the unit is compared to the players level" },
	faction				= { category = 'PvP', description = "Displays 'Alliance' or 'Horde'" },
	group				= { category = 'Party and Raid', description = "Displays the group number the unit is in (1-8)" },
	leader				= { category = 'Party and Raid', description = "Displays 'L' if the unit is the group/raid leader" },
	leaderlong			= { category = 'Party and Raid', description = "Displays 'Leader' if the unit is the group/raid leader" },
	level				= { category = 'Level', description = "Displays the level of the unit" },
	maxhp				= { category = 'Health', description = "Displays max HP without decimals" },
	maxmana				= { category = 'Mana', description = "Displays the max amount of mana the unit can have" },
	maxpp				= { category = 'Power', description = "Displays the max amount of power of the unit in whole numbers without decimals" },
	missinghp			= { category = 'Health', description = "Displays the missing health of the unit in whole numbers, when not at full health" },
	missingpp			= { category = 'Power', description = "Displays the missing power of the unit in whole numbers when not at full power" },
	name				= { category = 'Names', description = "Displays the full name of the unit without any letter limitation" },
	offline				= { category = 'Status', description = "Displays 'OFFLINE' if the unit is disconnected" },
	perhp				= { category = 'Health', description = "Displays percentage HP without decimals or the % sign. You can display the percent sign by adjusting the tag to [perhp<%]." },
	perpp				= { category = 'Power', description = "Displays the unit's percentage power without decimals" },
	plus				= { category = 'Classification', description = "Displays the character '+' if the unit is an elite or rare-elite" },
	powercolor			= { category = 'Colors', description = "Colors the power text based upon its type" },
	pvp					= { category = 'PvP', description = "Displays 'PvP' if the unit is pvp flagged" },
	rare				= { category = 'Classification', description = "Displays 'Rare' when the unit is a rare or rareelite" },
	resting				= { category = 'Status', description = "Displays 'zzz' if the unit is resting" },
	runes				= { hidden = E.Classic, category = 'Classpower', description = "Displays the runes (Death Knight)" },
	shortclassification	= { category = 'Classification', description = "Displays the unit's classification in short form (e.g. '+' for ELITE and 'R' for RARE)" },
	smartlevel			= { category = 'Level', description = "Only display the unit's level if it is not the same as yours" },
	soulshards			= { hidden = E.Classic, category = 'Classpower', description = "Displays the soulshards (Warlock)" },
	status				= { category = 'Status', description = "Displays zzz, dead, ghost, offline" },
	threat				= { category = 'Threat', description = "Displays the current threat situation (Aggro is secure tanking, -- is losing threat and ++ is gaining threat)" },
	threatcolor			= { category = 'Colors', description = "Changes the text color, depending on the unit's threat situation" },
	spec				= { hidden = not E.Retail, category = 'Class', description = "Displays the specialization icon of the unit as text" },
	arcanecharges		= { hidden = not E.Retail, category = 'Classpower', description = "Displays the arcane charges (Mage)" },
	chi					= { hidden = not E.Retail, category = 'Classpower', description = "Displays the chi points (Monk)" }
}

-- Allow Refreshing
RefreshNewTags = true
