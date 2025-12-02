-- Credits: Vika, Cladhaire, Tekkub, and Simpy
--[[
# Element: Tags

Provides a system for text-based display of information by binding a tag string to a font string widget which in turn is
tied to a unit frame.

## Widget

A FontString to hold a tag string. Unlike other elements, this widget must not have a preset name.

## Notes

A `Tag` is a Lua string consisting of a function name surrounded by square brackets. The tag will be replaced by the
output of the function and displayed as text on the font string widget with that the tag has been registered.
Literals can be pre or appended by separating them with a `>` before or `<` after the function name. The literals will be only
displayed when the function returns a non-nil value. I.e. `"[perhp<%]"` will display the current health as a percentage
of the maximum health followed by the % sign.

A `Tag String` is a Lua string consisting of one or multiple tags with optional literals between them.
Each tag will be updated individually and the output will follow the tags order. Literals will be displayed in the
output string regardless of whether the surrounding tag functions return a value. I.e. `"[curhp]/[maxhp]"` will resolve
to something like `2453/5000`.

A `Tag Function` is used to replace a single tag in a tag string by its output. A tag function receives only two
arguments - the unit and the realUnit of the unit frame used to register the tag (see Options for further details). The
tag function is called when the unit frame is shown or when a specified event has fired. It the tag is registered on an
eventless frame (i.e. one holding the unit "targettarget"), then the tag function is called in a set time interval.

A number of built-in tag functions exist. The layout can also define its own tag functions by adding them to the
`oUF.Tags.Methods` table. The events upon which the function will be called are specified in a white-space separated
list added to the `oUF.Tags.Events` table. Should an event fire without unit information, then it should also be listed
in the `oUF.Tags.SharedEvents` table as follows: `oUF.Tags.SharedEvents.EVENT_NAME = true`.

## Options

.overrideUnit    - if specified on the font string widget, the frame's realUnit will be passed as the second argument to
                   every tag function whose name is contained in the relevant tag string. Otherwise the second argument
                   is always nil (boolean)
.frequentUpdates - defines how often the corresponding tag function(s) should be called. This will override the events
                   for the tag(s), if any. If the value is a number, it is taken as a time interval in seconds. If the
                   value is a boolean, the time interval is set to 0.5 seconds (number or boolean)

## Attributes

.parent - the unit frame on which the tag has been registered

## Examples

    -- define the tag function
    oUF.Tags.Methods['mylayout:threatname'] = function(unit, realUnit)
        local color = _TAGS.threatcolor(unit)
        local name = _TAGS.name(unit, realUnit)
        return string.format('%s%s|r', color, name)
    end

    -- add the events
    oUF.Tags.Events['mylayout:threatname'] = 'UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE'

    -- create the text widget
    local info = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    info:SetPoint('LEFT')

    -- register the tag on the text widget with oUF
    self:Tag(info, '[mylayout:threatname]')
--]]

local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local unitExists = Private.unitExists
local validateEvent = Private.validateEvent
local validateUnit = Private.validateUnit

local _G = _G

local wipe, rawset, tonumber = wipe, rawset, tonumber
local format, tinsert, floor = format, tinsert, floor
local setfenv, getfenv, gsub, max = setfenv, getfenv, gsub, max
local next, type, pcall, unpack = next, type, pcall, unpack
local error, assert, loadstring = error, assert, loadstring

local SPEC_MAGE_ARCANE = SPEC_MAGE_ARCANE or 1
local SPEC_PALADIN_RETRIBUTION = SPEC_PALADIN_RETRIBUTION or 3
local SPEC_MONK_WINDWALKER = SPEC_MONK_WINDWALKER or 3

local POWERTYPE_MANA = Enum.PowerType.Mana or 0
local POWERTYPE_COMBO_POINTS = Enum.PowerType.ComboPoints or 4
local POWERTYPE_SOUL_SHARDS = Enum.PowerType.SoulShards or 7
local POWERTYPE_HOLY_POWER = Enum.PowerType.HolyPower or 9
local POWERTYPE_CHI = Enum.PowerType.Chi or 12
local POWERTYPE_ARCANE_CHARGES = Enum.PowerType.ArcaneCharges or 16

local CreateFrame = CreateFrame
local C_Timer_NewTimer = C_Timer.NewTimer
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization

local IsResting = IsResting
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local GetRuneCooldown = GetRuneCooldown
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetThreatStatusColor = GetThreatStatusColor
local UnitBattlePetLevel = UnitBattlePetLevel
local UnitCanAttack = UnitCanAttack
local UnitClassification = UnitClassification
local UnitCreatureFamily = UnitCreatureFamily
local UnitCreatureType = UnitCreatureType
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitHealthMax = UnitHealthMax
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVP = UnitIsPVP
local UnitIsWildBattlePet = UnitIsWildBattlePet
local UnitLevel = UnitLevel
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitSex = UnitSex
local UnitThreatSituation = UnitThreatSituation

-- GLOBALS: Hex, _TAGS, _COLORS
-- GLOBALS: UnitPower, UnitHealth, UnitName, UnitClass, UnitIsDead, UnitIsGhost, UnitIsDeadOrGhost, UnitIsConnected -- override during testing groups

local _PATTERN = '%[..-%]+'

local _ENV = {
	Hex = function(r, g, b)
		if(type(r) == 'table') then
			if(r.r) then
				r, g, b = r.r, r.g, r.b
			else
				r, g, b = unpack(r)
			end
		end

		if not r or type(r) == 'string' then -- wtf?
			return '|cffFFFFFF'
		end

		return format('|cff%02x%02x%02x', r * 255, g * 255, b * 255)
	end,
}
_ENV.ColorGradient = function(...)
	return _ENV._FRAME:ColorGradient(...)
end

local _PROXY = setmetatable(_ENV, {__index = _G})

local tagFunctions = {
	curhp = UnitHealth,
	curpp = UnitPower,
	maxhp = UnitHealthMax,
	maxpp = UnitPowerMax,
	class = UnitClass,
	faction = UnitFactionGroup,
	race = UnitRace,
}

local tagFuncs = setmetatable(tagFunctions, {
	__newindex = function(self, key, val)
		if(type(val) == 'string') then
			local func, err = loadstring('return ' .. val)
			if(func) then
				val = func()
			else
				error(err, 3)
			end
		end

		assert(type(val) == 'function', 'Tag function must be a function or a string that evaluates to a function.')

		-- We don't want to clash with any custom envs
		if(getfenv(val) == _G) then
			-- pcall is needed for cases when Blizz functions are passed as strings, for
			-- intance, 'UnitPowerMax', an attempt to set a custom env will result in an error
			pcall(setfenv, val, _PROXY)
		end

		rawset(self, key, val)
	end,
})

tagFunctions.affix = function(u)
	local c = UnitClassification(u)
	if(c == 'minus') then
		return 'Affix'
	end
end

tagFunctions.arcanecharges = function()
	if(GetSpecialization() == SPEC_MAGE_ARCANE) then
		local num = UnitPower('player', POWERTYPE_ARCANE_CHARGES)
		if(num > 0) then
			return num
		end
	end
end

tagFunctions.arenaspec = function(u)
	local id = u:match('arena(%d)$')
	if(id) then
		local specID = GetArenaOpponentSpec(tonumber(id))
		if(specID and specID > 0) then
			local _, specName = GetSpecializationInfoByID(specID)
			return specName
		end
	end
end

tagFunctions.chi = function()
	if(GetSpecialization() == SPEC_MONK_WINDWALKER) then
		local num = UnitPower('player', POWERTYPE_CHI)
		if(num > 0) then
			return num
		end
	end
end

tagFunctions.classification = function(u)
	local c = UnitClassification(u)
	if(c == 'rare') then
		return 'Rare'
	elseif(c == 'rareelite') then
		return 'Rare Elite'
	elseif(c == 'elite') then
		return 'Elite'
	elseif(c == 'worldboss') then
		return 'Boss'
	elseif(c == 'minus') then
		return 'Affix'
	end
end

tagFunctions.cpoints = function(u)
	local cp = UnitPower(u, POWERTYPE_COMBO_POINTS)

	if(cp > 0) then
		return cp
	end
end

tagFunctions.creature = function(u)
	return UnitCreatureFamily(u) or UnitCreatureType(u)
end

tagFunctions.curmana = function(unit)
	return UnitPower(unit, POWERTYPE_MANA)
end

tagFunctions.dead = function(u)
	if(UnitIsDead(u)) then
		return 'Dead'
	elseif(UnitIsGhost(u)) then
		return 'Ghost'
	end
end

tagFunctions['deficit:name'] = function(u)
	local missinghp = _TAGS.missinghp(u)
	if(missinghp) then
		return '-' .. missinghp
	else
		return _TAGS.name(u)
	end
end

tagFunctions.difficulty = function(u)
	if UnitCanAttack('player', u) then
		local l = (UnitEffectiveLevel or UnitLevel)(u)
		return Hex(GetCreatureDifficultyColor((l > 0) and l or 999))
	end
end

tagFunctions.group = function(unit)
	local name, server = UnitName(unit)
	if(server and server ~= '') then
		name = format('%s-%s', name, server)
	end

	for i=1, GetNumGroupMembers() do
		local raidName, _, group = GetRaidRosterInfo(i)
		if( raidName == name ) then
			return group
		end
	end
end

tagFunctions.holypower = function()
	if(GetSpecialization() == SPEC_PALADIN_RETRIBUTION) then
		local num = UnitPower('player', POWERTYPE_HOLY_POWER)
		if(num > 0) then
			return num
		end
	end
end

tagFunctions.leader = function(u)
	if(UnitIsGroupLeader(u)) then
		return 'L'
	end
end

tagFunctions.leaderlong = function(u)
	if(UnitIsGroupLeader(u)) then
		return 'Leader'
	end
end

tagFunctions.level = function(u)
	local l = (UnitEffectiveLevel or UnitLevel)(u)
	if not oUF.isClassic and (UnitIsWildBattlePet(u) or UnitIsBattlePetCompanion(u)) then
		l = UnitBattlePetLevel(u)
	end

	if(l > 0) then
		return l
	else
		return '??'
	end
end

tagFunctions.maxmana = function(unit)
	return UnitPowerMax(unit, POWERTYPE_MANA)
end

tagFunctions.missinghp = function(u)
	local current = UnitHealthMax(u) - UnitHealth(u)
	if(current > 0) then
		return current
	end
end

tagFunctions.missingpp = function(u)
	local current = UnitPowerMax(u) - UnitPower(u)
	if(current > 0) then
		return current
	end
end

tagFunctions.name = function(u, r)
	return UnitName(r or u)
end

tagFunctions.offline = function(u)
	if(not UnitIsConnected(u)) then
		return 'Offline'
	end
end

tagFunctions.perhp = function(u)
	local m = UnitHealthMax(u)
	if(m == 0) then
		return 0
	else
		return floor(UnitHealth(u) / m * 100 + .5)
	end
end

tagFunctions.perpp = function(u)
	local m = UnitPowerMax(u)
	if(m == 0) then
		return 0
	else
		return floor(UnitPower(u) / m * 100 + .5)
	end
end

tagFunctions.plus = function(u)
	local c = UnitClassification(u)
	if(c == 'elite' or c == 'rareelite') then
		return '+'
	end
end

tagFunctions.powercolor = function(u)
	local pType, pToken, altR, altG, altB = UnitPowerType(u)
	local color = _COLORS.power[pToken]

	if(not color) then
		if(altR) then
			if(altR > 1 or altG > 1 or altB > 1) then
				return Hex(altR / 255, altG / 255, altB / 255)
			else
				return Hex(altR, altG, altB)
			end
		else
			return Hex(_COLORS.power[pType] or _COLORS.power.MANA)
		end
	end

	return Hex(color)
end

tagFunctions.pvp = function(u)
	if(UnitIsPVP(u)) then
		return 'PvP'
	end
end

tagFunctions.raidcolor = function(u)
	local _, class = UnitClass(u)
	if(class) then
		return Hex(_COLORS.class[class])
	else
		local id = u:match('arena(%d)$')
		if(id) then
			local specID = GetArenaOpponentSpec(tonumber(id))
			if(specID and specID > 0) then
				_, _, _, _, _, class = GetSpecializationInfoByID(specID)
				return Hex(_COLORS.class[class])
			end
		end
	end
end

tagFunctions.rare = function(u)
	local c = UnitClassification(u)
	if(c == 'rare' or c == 'rareelite') then
		return 'Rare'
	end
end

tagFunctions.resting = function(u)
	if(u == 'player' and IsResting()) then
		return 'zzz'
	end
end

tagFunctions.runes = function()
	local amount = 0

	for i = 1, 6 do
		local _, _, ready = GetRuneCooldown(i)
		if(ready) then
			amount = amount + 1
		end
	end

	return amount
end

tagFunctions.sex = function(u)
	local s = UnitSex(u)
	if(s == 2) then
		return 'Male'
	elseif(s == 3) then
		return 'Female'
	end
end

tagFunctions.shortclassification = function(u)
	local c = UnitClassification(u)
	if(c == 'rare') then
		return 'R'
	elseif(c == 'rareelite') then
		return 'R+'
	elseif(c == 'elite') then
		return '+'
	elseif(c == 'worldboss') then
		return 'B'
	elseif(c == 'minus') then
		return '-'
	end
end

tagFunctions.smartclass = function(u)
	if(UnitIsPlayer(u)) then
		return _TAGS.class(u)
	end

	return _TAGS.creature(u)
end

tagFunctions.smartlevel = function(u)
	local c = UnitClassification(u)
	if(c == 'worldboss') then
		return 'Boss'
	else
		local plus = _TAGS.plus(u)
		local level = _TAGS.level(u)
		if(plus) then
			return level .. plus
		else
			return level
		end
	end
end

tagFunctions.soulshards = function()
	local num = UnitPower('player', POWERTYPE_SOUL_SHARDS)
	if(num > 0) then
		return num
	end
end

tagFunctions.status = function(u)
	if(UnitIsDead(u)) then
		return 'Dead'
	elseif(UnitIsGhost(u)) then
		return 'Ghost'
	elseif(not UnitIsConnected(u)) then
		return 'Offline'
	else
		return _TAGS.resting(u)
	end
end

tagFunctions.threat = function(u)
	local s = UnitThreatSituation(u)
	if(s == 1) then
		return '++'
	elseif(s == 2) then
		return '--'
	elseif(s == 3) then
		return 'Aggro'
	end
end

tagFunctions.threatcolor = function(u)
	return Hex(GetThreatStatusColor(UnitThreatSituation(u) or 0))
end

_ENV._TAGS = tagFuncs

local vars = setmetatable({}, {
	__newindex = function(self, key, val)
		if(type(val) == 'string') then
			local func = loadstring('return ' .. val)
			if(func) then
				val = func() or val
			end
		end

		rawset(self, key, val)
	end,
})

_ENV._VARS = vars

-- list of spells to allow in UNIT_AURA
local tagSpells = {}

-- ElvUI switches to UNIT_POWER_FREQUENT for regen powers
local tagEvents = {
	['affix']               = 'UNIT_CLASSIFICATION_CHANGED',
	['arenaspec']           = 'ARENA_PREP_OPPONENT_SPECIALIZATIONS',
	['classification']      = 'UNIT_CLASSIFICATION_CHANGED',
	['cpoints']             = 'UNIT_POWER_UPDATE PLAYER_TARGET_CHANGED',
	['curhp']               = 'UNIT_HEALTH UNIT_MAXHEALTH',
	['curmana']             = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER',
	['curpp']               = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER',
	['dead']                = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED',
	['deficit:name']        = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE',
	['difficulty']          = 'UNIT_FACTION',
	['faction']             = 'NEUTRAL_FACTION_SELECT_RESULT',
	['group']               = 'GROUP_ROSTER_UPDATE',
	['leader']              = 'PARTY_LEADER_CHANGED',
	['leaderlong']          = 'PARTY_LEADER_CHANGED',
	['level']               = 'UNIT_LEVEL PLAYER_LEVEL_UP',
	['maxhp']               = 'UNIT_MAXHEALTH',
	['maxmana']             = 'UNIT_POWER_UPDATE UNIT_MAXPOWER',
	['maxpp']               = 'UNIT_MAXPOWER',
	['missinghp']           = 'UNIT_HEALTH UNIT_MAXHEALTH',
	['missingpp']           = 'UNIT_MAXPOWER UNIT_POWER_FREQUENT',
	['name']                = 'UNIT_NAME_UPDATE',
	['offline']             = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED',
	['perhp']               = 'UNIT_HEALTH UNIT_MAXHEALTH',
	['perpp']               = 'UNIT_MAXPOWER UNIT_POWER_FREQUENT',
	['plus']                = 'UNIT_CLASSIFICATION_CHANGED',
	['powercolor']          = 'UNIT_DISPLAYPOWER',
	['pvp']                 = 'UNIT_FACTION',
	['rare']                = 'UNIT_CLASSIFICATION_CHANGED',
	['resting']             = 'PLAYER_UPDATE_RESTING',
	['runes']               = 'RUNE_POWER_UPDATE',
	['shortclassification'] = 'UNIT_CLASSIFICATION_CHANGED',
	['smartlevel']          = 'UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED',
	['soulshards']          = 'UNIT_POWER_UPDATE',
	['status']              = 'UNIT_HEALTH PLAYER_UPDATE_RESTING UNIT_CONNECTION PLAYER_FLAGS_CHANGED',
	['threat']              = 'UNIT_THREAT_SITUATION_UPDATE',
	['threatcolor']         = 'UNIT_THREAT_SITUATION_UPDATE',
}

local unitlessEvents = {
	ARENA_PREP_OPPONENT_SPECIALIZATIONS = true,
	GROUP_ROSTER_UPDATE = true,
	NEUTRAL_FACTION_SELECT_RESULT = true,
	PARTY_LEADER_CHANGED = true,
	PLAYER_LEVEL_UP = true,
	PLAYER_TARGET_CHANGED = true,
	PLAYER_UPDATE_RESTING = true,
	RAID_TARGET_UPDATE = true,
	RUNE_POWER_UPDATE = true,
}

if oUF.isRetail then
	tagEvents.arcanecharges       = 'UNIT_POWER_UPDATE PLAYER_TALENT_UPDATE'
	tagEvents.chi                 = 'UNIT_POWER_UPDATE PLAYER_TALENT_UPDATE'
	tagEvents.holypower           = 'UNIT_POWER_UPDATE PLAYER_TALENT_UPDATE'
	unitlessEvents.PLAYER_TALENT_UPDATE = true
elseif oUF.isWrath or oUF.isMists then
	unitlessEvents.PLAYER_TALENT_UPDATE = true
end

for tag, events in pairs(tagEvents) do -- ElvUI: UNIT_HEALTH is bugged on TBC, use same method to convert as E.AddTag
	tagEvents[tag] = (oUF.isClassic and gsub(events, 'UNIT_HEALTH([^%s_]?)', 'UNIT_HEALTH_FREQUENT%1')) or gsub(events, 'UNIT_HEALTH_FREQUENT', 'UNIT_HEALTH')
end

local timerFrames = {}
local timerFontStrings = {}
local function UpdateTimer(frame, elapsed)
	local total = frame.total
	if total >= frame.timer then
		for fs, parent in next, frame.strings do -- isForced prevents spam in ElvUI
			if not parent.isForced and parent:IsShown() and unitExists(parent.unit) then
				fs:UpdateTag()
			end
		end

		total = 0
	end

	frame.total = total + elapsed
end

local function EnableTimer(timer)
	local frame = timerFrames[timer]
	if frame then
		frame.total = timer

		frame:Show()
	else
		frame = CreateFrame('Frame')
		frame.strings = timerFontStrings[timer]
		frame.timer = timer
		frame.total = timer

		frame:SetScript('OnUpdate', UpdateTimer)

		timerFrames[timer] = frame
	end
end

local function DisableTimer(timer)
	local frame = timerFrames[timer]
	if not frame then return end

	frame:Hide()
end

--[[ Tags: frame:UpdateTags()
Used to update all tags on a frame.

* self - the unit frame from which to update the tags
--]]

local function Update(self)
	if not self.__tags then return end

	for fs in next, self.__tags do
		fs:UpdateTag()
	end
end

local onUpdateDelay = {}
local function EscapeSequence(a)
	return format('|%s', a)
end

local function CreateDeadTagFunc(bracket)
	return function()
		return format('|cFFffffff%s|r', bracket)
	end
end

local function CreateTagFunc(tag, prefix, suffix)
	return function(unit, realUnit, customArgs)
		local str = tag(unit, realUnit, customArgs)
		return str and format('%s%s%s', prefix or '', str, suffix or '') or nil
	end
end

local tagStringFuncs = {}
local bracketFuncs = {}
local tagBuffer = {}

local function GetTagName(tag)
	local tagStart = tag:match('.*>()') or 2
	local tagEnd = (tag:match('.-()<') or -1) - 1

	return tag:sub(tagStart, tagEnd), tagStart, tagEnd
end

local function GetTagFunc(tagstr)
	local func = tagStringFuncs[tagstr]
	if not func then
		local frmt, numTags = tagstr:gsub('%%', '%%%%'):gsub(_PATTERN, '%%s')
		local funcs = {}

		for bracket in tagstr:gmatch(_PATTERN) do
			local tagFunc = bracketFuncs[bracket] or tagFuncs[bracket:sub(2, -2)]
			if not tagFunc then
				local tagName, tagStart, tagEnd = GetTagName(bracket)

				local tag = tagFuncs[tagName]
				if tag then
					tagStart, tagEnd = tagStart - 2, tagEnd + 2
					tagFunc = CreateTagFunc(tag, tagStart ~= 0 and bracket:sub(2, tagStart), tagEnd ~= 0 and bracket:sub(tagEnd, -2))
					bracketFuncs[bracket] = tagFunc
				end
			end

			tinsert(funcs, tagFunc or CreateDeadTagFunc(bracket))
		end

		func = function(self)
			local parent = self.parent
			local unit = parent.unit
			local realUnit = self.overrideUnit and parent.realUnit
			local customArgs = parent.__customargs[self]

			_ENV._FRAME = parent
			_ENV._COLORS = parent.colors

			for i, fnc in next, funcs do
				tagBuffer[i] = fnc(unit, realUnit, customArgs) or ''
			end

			-- we do 1 to num because buffer is shared by all tags and can hold several unneeded vars.
			self:SetFormattedText(frmt, unpack(tagBuffer, 1, numTags))
		end

		tagStringFuncs[tagstr] = func
	end

	return func
end

local tempStrings = {}
local eventHandlers = {}
local eventAuraCache = {}
local eventExtraUnits = {}
local eventWaiters = {}
local eventTimerThreshold = 0.1
local function verifyAura(frame, event, unit, auraInstanceID, aura)
	if aura and tagSpells[aura.spellId] then
		eventAuraCache[auraInstanceID] = aura
		return true -- added or updated
	elseif eventAuraCache[auraInstanceID] then
		eventAuraCache[auraInstanceID] = nil
		return true -- removed
	end
end

local function ShouldUpdateTag(frame, event, unit)
	if not frame:IsShown() or frame.isForced then return end -- isForced prevents spam in ElvUI

	if unitlessEvents[event] then
		return true
	elseif validateUnit(unit) and unitExists(unit) then
		if frame.unit == unit then
			return true
		else
			local allowExtra = eventExtraUnits[frame]
			return allowExtra and allowExtra[unit]
		end
	end
end

local function ProcessStrings(strs)
	if not strs then return end

	for fs in next, strs do
		tempStrings[fs] = true
	end
end

local function UpdateStrings(strs)
	if not strs then return end

	for fs in next, strs do
		if fs:IsVisible() then
			fs:UpdateTag()
		end
	end
end

local function WaiterHandler(handler)
	local waiter = eventWaiters[handler]
	if waiter then
		waiter:Cancel() -- this just makes it a timer
	end

	wipe(tempStrings)

	for event in next, handler.eventHappened do
		ProcessStrings(handler.eventStrings[event])

		handler.eventHappened[event] = nil
	end

	UpdateStrings(tempStrings)

	eventWaiters[handler] = nil
end

local function HandlerEvent(handler, event, unit, updateInfo)
	handler.eventHappened[event] = true -- so we know what events fired

	local waiter = eventWaiters[handler]
	if waiter then return end -- already waiting

	-- we only want to show tags on validated units
	if not ShouldUpdateTag(handler.frame, event, unit) then return end

	-- we only want to let auras trigger an update when they are allowed
	if event == 'UNIT_AURA' and oUF:ShouldSkipAuraUpdate(handler.frame, event, unit, updateInfo, verifyAura) then return end

	-- now we wait..
	waiter = C_Timer_NewTimer(eventTimerThreshold, handler.WaiterHandler)

	eventWaiters[handler] = waiter
end

local function GenerateWaiter(handler)
	return function() WaiterHandler(handler) end
end

local function RegisterEvent(frame, event, fs)
	if not validateEvent(event) then return end

	if not eventHandlers[frame] then
		local handler = CreateFrame('Frame')

		handler.frame = frame
		handler.eventStrings = {}
		handler.eventHappened = {}
		handler.WaiterHandler = GenerateWaiter(handler)
		handler:SetScript('OnEvent', HandlerEvent)

		eventHandlers[frame] = handler
	end

	local handler = eventHandlers[frame]
	if handler then
		if not handler.eventStrings[event] then
			handler.eventStrings[event] = {}

			handler:RegisterEvent(event)
		end

		handler.eventStrings[event][fs] = true
	end
end

local function RegisterEvents(frame, fs, ts)
	for tag in ts:gmatch(_PATTERN) do
		local tagevents = tagEvents[GetTagName(tag)]
		if tagevents then
			for event in tagevents:gmatch('%S+') do
				RegisterEvent(frame, event, fs)
			end
		end
	end
end

local function UnregisterEvents(frame, fs)
	local handler = eventHandlers[frame]
	if not handler then return end

	for event, strings in next, handler.eventStrings do
		strings[fs] = nil

		if not next(strings) then
			handler:UnregisterEvent(event)

			handler.eventStrings[event] = nil
		end
	end
end

local function RegisterTimer(frame, fs, timer)
	if not timerFontStrings[timer] then
		timerFontStrings[timer] = {}
	end

	timerFontStrings[timer][fs] = frame

	EnableTimer(timer)
end

local function UnregisterTimer(frame, fs)
	for timer, strings in next, timerFontStrings do
		strings[fs] = nil

		if not next(strings) then
			DisableTimer(timer)
		end
	end
end

--[[ Tags: frame:Tag(fs, tagstr, ...)
Used to register a tag on a unit frame.

* self   - the unit frame on which to register the tag
* fs     - the font string to display the tag (FontString)
* ts     - the tag string (string)
* ...    - additional optional unitID(s) the tag should update for
--]]

local taggedFontStrings = {}
local function Tag(self, fs, ts, arg1, ...)
	if(not fs or not ts) then return end

	if(not self.__tags) then
		self.__tags = {}
		self.__mousetags = {}
		self.__customargs = {}

		tinsert(self.__elements, Update)
	elseif(self.__tags[fs]) then
		-- We don't need to remove it from the __tags table as Untag handles
		-- that for us.
		self:Untag(fs)
	end

	ts = ts:gsub('||([TCRAtncra])', EscapeSequence)

	local customArgs = ts:match('{(.-)}%]')
	if customArgs then
		self.__customargs[fs] = customArgs
		ts = ts:gsub('{.-}%]', ']')
	else
		self.__customargs[fs] = nil
	end

	if not self.isNamePlate then
		if ts:find('%[mouseover%]') then
			self.__mousetags[fs] = true
			fs:SetAlpha(0)

			ts = ts:gsub('%[mouseover%]', '')
		else
			for fontString in next, self.__mousetags do
				if fontString == fs then
					self.__mousetags[fontString] = nil
					fs:SetAlpha(1)
				end
			end
		end
	end

	local containsOnUpdate
	for tag in ts:gmatch(_PATTERN) do
		tag = GetTagName(tag)

		local delay = not tagEvents[tag] and onUpdateDelay[tag]
		if delay then
			containsOnUpdate = delay
		end
	end

	fs.parent = self
	fs.UpdateTag = GetTagFunc(ts)

	if(self.__eventless or fs.frequentUpdates) or containsOnUpdate then
		local timer = 0.5
		if(type(fs.frequentUpdates) == 'number') then
			timer = fs.frequentUpdates
		elseif containsOnUpdate then
			timer = containsOnUpdate
		end

		RegisterTimer(self, fs, timer)
	else
		RegisterEvents(self, fs, ts)

		if arg1 then
			if not eventExtraUnits[self] then
				eventExtraUnits[self] = {}
			end

			local allowExtra = eventExtraUnits[self]
			for _, extraUnit in next, { arg1, ... } do
				allowExtra[extraUnit] = true
			end
		end
	end

	taggedFontStrings[fs] = ts
	self.__tags[fs] = true
end

--[[ Tags: frame:Untag(fs)
Used to unregister a tag from a unit frame.

* self - the unit frame from which to unregister the tag
* fs   - the font string holding the tag (FontString)
--]]

local function Untag(self, fs)
	if(not fs or not self.__tags) then return end

	UnregisterEvents(self, fs)
	UnregisterTimer(self, fs)

	fs.UpdateTag = nil

	eventExtraUnits[self] = nil
	taggedFontStrings[fs] = nil
	self.__tags[fs] = nil
end

local function StripTag(tag) -- remove prefix, custom args, and suffix
	return tag:gsub("%[[^%[%]]*>", "["):gsub("<[^%[%]]*%]", "]") -- ElvUI uses old tag format
end

oUF.Tags = {
	Env = _ENV,
	Methods = tagFuncs,
	Events = tagEvents,
	Spells = tagSpells,
	SharedEvents = unitlessEvents,
	OnUpdateThrottle = onUpdateDelay,
	Vars = vars,
	RefreshMethods = function(_, tag)
		if not tag then return end

		-- if a tag's name contains magic chars, there's a chance that string.match will fail to find the match
		tag = '%[' .. tag:gsub('[%^%$%(%)%%%.%*%+%-%?]', '%%%1') .. '%]'

		for bracket in next, bracketFuncs do
			if StripTag(bracket):match(tag) then
				bracketFuncs[bracket] = nil
			end
		end

		for tagstr, func in next, tagStringFuncs do
			if StripTag(tagstr):match(tag) then
				tagStringFuncs[tagstr] = nil

				for fs in next, taggedFontStrings do
					if fs.UpdateTag == func then
						fs.UpdateTag = GetTagFunc(tagstr)

						if fs:IsVisible() then
							fs:UpdateTag()
						end
					end
				end
			end
		end
	end,
	RefreshEvents = function(self, tag)
		if not tag then return end

		-- if a tag's name contains magic chars, there's a chance that string.match will fail to find the match
		tag = '%[' .. tag:gsub('[%^%$%(%)%%%.%*%+%-%?]', '%%%1') .. '%]'

		for tagstr in next, tagStringFuncs do
			if StripTag(tagstr):match(tag) then
				for fs, ts in next, taggedFontStrings do
					if ts == tagstr then
						UnregisterEvents(self, fs)
						RegisterEvents(self, fs, tagstr)
					end
				end
			end
		end
	end,
	SetEventUpdateTimer = function(_, timer)
		if not timer or type(timer) ~= 'number' then return end

		eventTimerThreshold = max(0.05, timer)
	end
}

oUF:RegisterMetaFunction('Tag', Tag)
oUF:RegisterMetaFunction('Untag', Untag)
oUF:RegisterMetaFunction('UpdateTags', Update)
