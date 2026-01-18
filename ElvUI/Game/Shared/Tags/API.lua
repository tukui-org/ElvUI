local E, L, V, P, G = unpack(ElvUI)
local ElvUF = E.oUF
local Tags = ElvUF.Tags

local gsub, type, next = gsub, type, next
local format, gmatch, strmatch = format, gmatch, strmatch
local utf8lower, utf8sub = string.utf8lower, string.utf8sub

local _G = _G
local UnitLevel = UnitLevel

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
	if E.Retail or E.Mists or E.Wrath then
		return _G.UnitEffectiveLevel(unit)
	else
		return UnitLevel(unit)
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

Tags.Env.NameHealthColor = function(tags,hex,unit,default)
	if hex == 'class' or hex == 'reaction' then
		return tags.classcolor(unit) or default
	elseif hex and strmatch(hex, '^%x%x%x%x%x%x$') then
		return '|cFF'..hex
	end

	return default
end

-- expose local functions for plugins onto this table, more added from Shared/Tags.lua
E.TagFunctions = {
	UnitEffectiveLevel = Tags.Env.UnitEffectiveLevel,
	UnitName = Tags.Env.UnitName,
	Abbrev = Tags.Env.Abbrev,
	NameHealthColor = Tags.Env.NameHealthColor
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
