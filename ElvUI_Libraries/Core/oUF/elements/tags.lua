-- Credits: Vika, Cladhaire, Tekkub
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
        local color = _TAGS['threatcolor'](unit)
        local name = _TAGS['name'](unit, realUnit)
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

-- ElvUI block
local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local format, tinsert = format, tinsert
local setfenv, getfenv, gsub, max = setfenv, getfenv, gsub, max
local rawget, rawset, select, wipe = rawget, rawset, select, wipe
local next, type, pcall, unpack = next, type, pcall, unpack
local error, assert, loadstring = error, assert, loadstring
-- end block

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

		-- ElvUI block
		if not r or type(r) == 'string' then --wtf?
			return '|cffFFFFFF'
		end
		-- end block

		return format('|cff%02x%02x%02x', r * 255, g * 255, b * 255)
	end,
}
_ENV.ColorGradient = function(...)
	return _ENV._FRAME:ColorGradient(...)
end

local _PROXY = setmetatable(_ENV, {__index = _G})

local tagStrings = {
	['affix'] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'minus') then
			return 'Affix'
		end
	end]],

	['arcanecharges'] = [[function()
		if(GetSpecialization() == SPEC_MAGE_ARCANE) then
			local num = UnitPower('player', Enum.PowerType.ArcaneCharges)
			if(num > 0) then
				return num
			end
		end
	end]],

	['arenaspec'] = [[function(u)
		local id = u:match('arena(%d)$')
		if(id) then
			local specID = GetArenaOpponentSpec(tonumber(id))
			if(specID and specID > 0) then
				local _, specName = GetSpecializationInfoByID(specID)
				return specName
			end
		end
	end]],

	['chi'] = [[function()
		if(GetSpecialization() == SPEC_MONK_WINDWALKER) then
			local num = UnitPower('player', Enum.PowerType.Chi)
			if(num > 0) then
				return num
			end
		end
	end]],

	['classification'] = [[function(u)
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
	end]],

	['cpoints'] = [[function(u)
		local cp = UnitPower(u, Enum.PowerType.ComboPoints)

		if(cp > 0) then
			return cp
		end
	end]],

	['creature'] = [[function(u)
		return UnitCreatureFamily(u) or UnitCreatureType(u)
	end]],

	['curmana'] = [[function(unit)
		return UnitPower(unit, Enum.PowerType.Mana)
	end]],

	['dead'] = [[function(u)
		if(UnitIsDead(u)) then
			return 'Dead'
		elseif(UnitIsGhost(u)) then
			return 'Ghost'
		end
	end]],

	['deficit:name'] = [[function(u)
		local missinghp = _TAGS['missinghp'](u)
		if(missinghp) then
			return '-' .. missinghp
		else
			return _TAGS['name'](u)
		end
	end]],

	['difficulty'] = [[function(u)
		if UnitCanAttack('player', u) then
			local l = (UnitEffectiveLevel or UnitLevel)(u)
			return Hex(GetCreatureDifficultyColor((l > 0) and l or 999))
		end
	end]],

	['group'] = [[function(unit)
		local name, server = UnitName(unit)
		if(server and server ~= '') then
			name = string.format('%s-%s', name, server)
		end

		for i=1, GetNumGroupMembers() do
			local raidName, _, group = GetRaidRosterInfo(i)
			if( raidName == name ) then
				return group
			end
		end
	end]],

	['holypower'] = [[function()
		if(GetSpecialization() == SPEC_PALADIN_RETRIBUTION) then
			local num = UnitPower('player', Enum.PowerType.HolyPower)
			if(num > 0) then
				return num
			end
		end
	end]],

	['leader'] = [[function(u)
		if(UnitIsGroupLeader(u)) then
			return 'L'
		end
	end]],

	['leaderlong']  = [[function(u)
		if(UnitIsGroupLeader(u)) then
			return 'Leader'
		end
	end]],

	['level'] = [[function(u)
		local l = (UnitEffectiveLevel or UnitLevel)(u)
		if C_PetBattles and (UnitIsWildBattlePet(u) or UnitIsBattlePetCompanion(u)) then
			l = UnitBattlePetLevel(u)
		end

		if(l > 0) then
			return l
		else
			return '??'
		end
	end]],

	['maxmana'] = [[function(unit)
		return UnitPowerMax(unit, Enum.PowerType.Mana)
	end]],

	['missinghp'] = [[function(u)
		local current = UnitHealthMax(u) - UnitHealth(u)
		if(current > 0) then
			return current
		end
	end]],

	['missingpp'] = [[function(u)
		local current = UnitPowerMax(u) - UnitPower(u)
		if(current > 0) then
			return current
		end
	end]],

	['name'] = [[function(u, r)
		return UnitName(r or u)
	end]],

	['offline'] = [[function(u)
		if(not UnitIsConnected(u)) then
			return 'Offline'
		end
	end]],

	['perhp'] = [[function(u)
		local m = UnitHealthMax(u)
		if(m == 0) then
			return 0
		else
			return math.floor(UnitHealth(u) / m * 100 + .5)
		end
	end]],

	['perpp'] = [[function(u)
		local m = UnitPowerMax(u)
		if(m == 0) then
			return 0
		else
			return math.floor(UnitPower(u) / m * 100 + .5)
		end
	end]],

	['plus'] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'elite' or c == 'rareelite') then
			return '+'
		end
	end]],

	['powercolor'] = [[function(u)
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
	end]],

	['pvp'] = [[function(u)
		if(UnitIsPVP(u)) then
			return 'PvP'
		end
	end]],

	['raidcolor'] = [[function(u)
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
	end]],

	['rare'] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'rare' or c == 'rareelite') then
			return 'Rare'
		end
	end]],

	['resting'] = [[function(u)
		if(u == 'player' and IsResting()) then
			return 'zzz'
		end
	end]],

	['runes'] = [[function()
		local amount = 0

		for i = 1, 6 do
			local _, _, ready = GetRuneCooldown(i)
			if(ready) then
				amount = amount + 1
			end
		end

		return amount
	end]],

	['sex'] = [[function(u)
		local s = UnitSex(u)
		if(s == 2) then
			return 'Male'
		elseif(s == 3) then
			return 'Female'
		end
	end]],

	['shortclassification'] = [[function(u)
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
	end]],

	['smartclass'] = [[function(u)
		if(UnitIsPlayer(u)) then
			return _TAGS['class'](u)
		end

		return _TAGS['creature'](u)
	end]],

	['smartlevel'] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'worldboss') then
			return 'Boss'
		else
			local plus = _TAGS['plus'](u)
			local level = _TAGS['level'](u)
			if(plus) then
				return level .. plus
			else
				return level
			end
		end
	end]],

	['soulshards'] = [[function()
		local num = UnitPower('player', Enum.PowerType.SoulShards)
		if(num > 0) then
			return num
		end
	end]],

	['status'] = [[function(u)
		if(UnitIsDead(u)) then
			return 'Dead'
		elseif(UnitIsGhost(u)) then
			return 'Ghost'
		elseif(not UnitIsConnected(u)) then
			return 'Offline'
		else
			return _TAGS['resting'](u)
		end
	end]],

	['threat'] = [[function(u)
		local s = UnitThreatSituation(u)
		if(s == 1) then
			return '++'
		elseif(s == 2) then
			return '--'
		elseif(s == 3) then
			return 'Aggro'
		end
	end]],

	['threatcolor'] = [[function(u)
		return Hex(GetThreatStatusColor(UnitThreatSituation(u)))
	end]],
}

local tagFuncs = setmetatable(
	{
		curhp = UnitHealth,
		curpp = UnitPower,
		maxhp = UnitHealthMax,
		maxpp = UnitPowerMax,
		class = UnitClass,
		faction = UnitFactionGroup,
		race = UnitRace,
	},
	{
		__index = function(self, key)
			local tagString = tagStrings[key]
			if(tagString) then
				self[key] = tagString
				tagStrings[key] = nil
			end

			return rawget(self, key)
		end,
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
	}
)

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

-- ElvUI switches to UNIT_POWER_FREQUENT for regen powers
local tagEvents = {
	['affix']               = 'UNIT_CLASSIFICATION_CHANGED',
	['arenaspec']           = 'ARENA_PREP_OPPONENT_SPECIALIZATIONS',
	['classification']      = 'UNIT_CLASSIFICATION_CHANGED',
	['cpoints']             = 'UNIT_POWER_UPDATE PLAYER_TARGET_CHANGED',
	['curhp']               = 'UNIT_HEALTH UNIT_MAXHEALTH',
	['curmana']             = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER',
	['curpp']               = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER',
	['dead']                = 'UNIT_HEALTH',
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
	['offline']             = 'UNIT_HEALTH UNIT_CONNECTION',
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
	['status']              = 'UNIT_HEALTH PLAYER_UPDATE_RESTING UNIT_CONNECTION',
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
	tagEvents['arcanecharges']       = 'UNIT_POWER_UPDATE PLAYER_TALENT_UPDATE'
	tagEvents['chi']                 = 'UNIT_POWER_UPDATE PLAYER_TALENT_UPDATE'
	tagEvents['holypower']           = 'UNIT_POWER_UPDATE PLAYER_TALENT_UPDATE'
	unitlessEvents.PLAYER_TALENT_UPDATE = true
elseif oUF.isWrath then
	unitlessEvents.PLAYER_TALENT_UPDATE = true
end

for tag, events in pairs(tagEvents) do -- ElvUI: UNIT_HEALTH is bugged on TBC, use same method to convert as E.AddTag
	tagEvents[tag] = (oUF.isClassic and gsub(events, 'UNIT_HEALTH([^%s_]?)', 'UNIT_HEALTH_FREQUENT%1')) or gsub(events, 'UNIT_HEALTH_FREQUENT', 'UNIT_HEALTH')
end

local stringsToUpdate = {}
local eventFontStrings = {}
local eventFrame = CreateFrame('Frame')
eventFrame:SetScript('OnEvent', function(_, event, unit)
	local strings = eventFontStrings[event]
	if(strings) then
		for fs in next, strings do
			if(not stringsToUpdate[fs] and fs:IsVisible() and (unitlessEvents[event] or fs.parent.unit == unit or (fs.extraUnits and fs.extraUnits[unit]))) then
				stringsToUpdate[fs] = true
			end
		end
	end
end)

local eventTimer = 0
local eventTimerThreshold = 0.25

eventFrame:SetScript('OnUpdate', function(_, elapsed)
	eventTimer = eventTimer + elapsed
	if(eventTimer >= eventTimerThreshold) then
		for fs in next, stringsToUpdate do
			if(fs:IsVisible()) then
				fs:UpdateTag()
			end
		end

		wipe(stringsToUpdate)

		eventTimer = 0
	end
end)

local timerFrames = {}
local timerFontStrings = {}

local function enableTimer(timer)
	local frame = timerFrames[timer]
	if(not frame) then
		local total = timer
		local strings = timerFontStrings[timer]

		frame = CreateFrame('Frame')
		frame:SetScript('OnUpdate', function(_, elapsed)
			if total >= timer then
				for fs in next, strings do
					if fs.parent:IsShown() and unitExists(fs.parent.unit) then
						fs:UpdateTag()
					end
				end

				total = 0
			end

			total = total + elapsed
		end)

		timerFrames[timer] = frame
	else
		frame:Show()
	end
end

local function disableTimer(timer)
	local frame = timerFrames[timer]
	if(frame) then
		frame:Hide()
	end
end

--[[ Tags: frame:UpdateTags()
Used to update all tags on a frame.

* self - the unit frame from which to update the tags
--]]
local function Update(self)
	if(self.__tags) then
		for fs in next, self.__tags do
			fs:UpdateTag()
		end
	end
end

-- ElvUI block
local onUpdateDelay = {}
local function escapeSequence(a) return format('|%s', a) end
local function makeDeadTagFunc(bracket)
	return function()
		return format('|cFFffffff%s|r', bracket)
	end
end

local function makeTagFunc(tag, prefix, suffix)
	return function(unit, realUnit, customArgs)
		local str = tag(unit, realUnit, customArgs)
		if str then
			return format('%s%s%s', prefix or '', str, suffix or '')
		end
	end
end
-- end block

local tagStringFuncs = {}
local bracketFuncs = {}
local buffer = {}

local function getTagName(tag)
	local tagStart = tag:match('>+()') or 2
	local tagEnd = (tag:match('.-()<') or -1) - 1

	return tag:sub(tagStart, tagEnd), tagStart, tagEnd
end

local function getTagFunc(tagstr)
	local func = tagStringFuncs[tagstr]
	if not func then
		local frmt, numTags = tagstr:gsub('%%', '%%%%'):gsub(_PATTERN, '%%s')
		local funcs = {}

		-- ElvUI changed
		for bracket in tagstr:gmatch(_PATTERN) do
			local tagFunc = bracketFuncs[bracket] or tagFuncs[bracket:sub(2, -2)]
			if not tagFunc then
				local tagName, tagStart, tagEnd = getTagName(bracket)

				local tag = tagFuncs[tagName]
				if tag then
					tagStart, tagEnd = tagStart - 2, tagEnd + 2
					tagFunc = makeTagFunc(tag, tagStart ~= 0 and bracket:sub(2, tagStart), tagEnd ~= 0 and bracket:sub(tagEnd, -2))
					bracketFuncs[bracket] = tagFunc
				end
			end

			tinsert(funcs, tagFunc or makeDeadTagFunc(bracket))
		end

		func = function(self)
			local parent = self.parent
			local unit = parent.unit
			local realUnit = self.overrideUnit and parent.realUnit
			local customArgs = parent.__customargs[self]

			_ENV._FRAME = parent
			_ENV._COLORS = parent.colors

			for i, fnc in next, funcs do
				buffer[i] = fnc(unit, realUnit, customArgs) or ''
			end

			-- we do 1 to num because buffer is shared by all tags and can hold several unneeded vars.
			self:SetFormattedText(frmt, unpack(buffer, 1, numTags))
		end

		tagStringFuncs[tagstr] = func
		-- end block
	end

	return func
end

local function registerEvent(event, fs)
	if(validateEvent(event)) then
		if(not eventFontStrings[event]) then
			eventFontStrings[event] = {}
		end

		eventFontStrings[event][fs] = true

		eventFrame:RegisterEvent(event)
	end
end

local function registerEvents(fs, ts)
	for tag in ts:gmatch(_PATTERN) do
		local tagevents = tagEvents[getTagName(tag)]
		if(tagevents) then
			for event in tagevents:gmatch('%S+') do
				registerEvent(event, fs)
			end
		end
	end
end

local function unregisterEvents(fs)
	for event, strings in next, eventFontStrings do
		strings[fs] = nil

		if(not next(strings)) then
			eventFrame:UnregisterEvent(event)
		end
	end
end

-- this bullshit is to fix texture strings not adjusting to its inherited alpha
-- it is a blizzard issue with how texture strings are rendered
local alphaFix = CreateFrame('Frame')
alphaFix.fontStrings = {}
alphaFix:SetScript('OnUpdate', function()
	local strs = alphaFix.fontStrings
	if next(strs) then
		for fs in next, strs do
			strs[fs] = nil

			local a = fs:GetAlpha()
			fs:SetAlpha(0)
			fs:SetAlpha(a)
		end
	else
		alphaFix:Hide()
	end
end)

local function fixAlpha(self)
	alphaFix.fontStrings[self] = true
	alphaFix:Show()
end

local function registerTimer(fs, timer)
	if(not timerFontStrings[timer]) then
		timerFontStrings[timer] = {}
	end

	timerFontStrings[timer][fs] = true

	enableTimer(timer)
end

local function unregisterTimer(fs)
	for timer, strings in next, timerFontStrings do
		strings[fs] = nil

		if(not next(strings)) then
			disableTimer(timer)
		end
	end
end

local taggedFontStrings = {}

--[[ Tags: frame:Tag(fs, tagstr, ...)
Used to register a tag on a unit frame.

* self   - the unit frame on which to register the tag
* fs     - the font string to display the tag (FontString)
* ts     - the tag string (string)
* ...    - additional optional unitID(s) the tag should update for
--]]
local function Tag(self, fs, ts, ...)
	if(not fs or not ts) then return end

	if(not self.__tags) then
		self.__tags = {}
		self.__mousetags = {} -- ElvUI
		self.__customargs = {} -- ElvUI

		tinsert(self.__elements, Update)
	elseif(self.__tags[fs]) then
		-- We don't need to remove it from the __tags table as Untag handles
		-- that for us.
		self:Untag(fs)
	end

	-- ElvUI
	if not fs.__HookedAlphaFix then
		hooksecurefunc(fs, 'SetText', fixAlpha)
		hooksecurefunc(fs, 'SetFormattedText', fixAlpha)
		fs.__HookedAlphaFix = true
	end

	ts = ts:gsub('||([TCRAtcra])', escapeSequence)

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
		tag = getTagName(tag)
		if not tagEvents[tag] then
			containsOnUpdate = onUpdateDelay[tag] or 0.15;
		end
	end
	-- end block

	fs.parent = self
	fs.UpdateTag = getTagFunc(ts)

	if(self.__eventless or fs.frequentUpdates) or containsOnUpdate then -- ElvUI changed
		local timer = 0.5
		if(type(fs.frequentUpdates) == 'number') then
			timer = fs.frequentUpdates
		-- ElvUI added check
		elseif containsOnUpdate then
			timer = containsOnUpdate
		-- end block
		end

		registerTimer(fs, timer)
	else
		registerEvents(fs, ts)

		if(...) then
			if(not fs.extraUnits) then
				fs.extraUnits = {}
			end

			for index = 1, select('#', ...) do
				fs.extraUnits[select(index, ...)] = true
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

	unregisterEvents(fs)
	unregisterTimer(fs)

	fs.UpdateTag = nil

	taggedFontStrings[fs] = nil
	self.__tags[fs] = nil
end

local function strip(tag)
	-- remove prefix, custom args, and suffix
	return tag:gsub("%[[^%[%]]*>", "["):gsub("<[^%[%]]*%]", "]") -- ElvUI uses old tag format
end

oUF.Tags = {
	Methods = tagFuncs,
	Events = tagEvents,
	SharedEvents = unitlessEvents,
	OnUpdateThrottle = onUpdateDelay, -- ElvUI
	Vars = vars,
	RefreshMethods = function(_, tag)
		if(not tag) then return end

		-- if a tag's name contains magic chars, there's a chance that string.match will fail to find the match.
		tag = '%[' .. tag:gsub('[%^%$%(%)%%%.%*%+%-%?]', '%%%1') .. '%]'

		for bracket in next, bracketFuncs do
			if(strip(bracket):match(tag)) then
				bracketFuncs[bracket] = nil
			end
		end

		for tagstr, func in next, tagStringFuncs do
			if(strip(tagstr):match(tag)) then
				tagStringFuncs[tagstr] = nil

				for fs in next, taggedFontStrings do
					if(fs.UpdateTag == func) then
						fs.UpdateTag = getTagFunc(tagstr)

						if(fs:IsVisible()) then
							fs:UpdateTag()
						end
					end
				end
			end
		end
	end,
	RefreshEvents = function(_, tag)
		if(not tag) then return end

		-- If a tag's name contains magic chars, there's a chance that string.match will fail to find the match.
		tag = '%[' .. tag:gsub('[%^%$%(%)%%%.%*%+%-%?]', '%%%1') .. '%]'

		for tagstr in next, tagStringFuncs do
			if(strip(tagstr):match(tag)) then
				for fs, ts in next, taggedFontStrings do
					if(ts == tagstr) then
						unregisterEvents(fs)
						registerEvents(fs, tagstr)
					end
				end
			end
		end
	end,
	SetEventUpdateTimer = function(_, timer)
		if(not timer) then return end
		if(not type(timer) == 'number') then return end

		eventTimerThreshold = max(0.1, timer)
	end,
}

oUF:RegisterMetaFunction('Tag', Tag)
oUF:RegisterMetaFunction('Untag', Untag)
oUF:RegisterMetaFunction('UpdateTags', Update)
