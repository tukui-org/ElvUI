--[[
-- Experimental oUF tags
-- Status: Incomplete
--
-- Credits: Vika, Cladhaire, Tekkub
--
-- TODO:
--	- Tag and Untag should be able to handle more than one fontstring at a time.
]]

local parent, ns = ...
local oUF = ns.oUF

local classColors

local function Hex(r, g, b)
	if type(r) == "table" then
		if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

local tags
tags = {

	["[curhp]"] = UnitHealth,
	["[curpp]"] = UnitPower,
	["[maxhp]"] = UnitHealthMax,
	["[maxpp]"] = UnitPowerMax,

	["[class]"] = function(u)
		return UnitClass(u)
	end,

	["[creature]"] = function(u)
		return UnitCreatureFamily(u) or UnitCreatureType(u)
	end,

	["[dead]"] = function(u)
		return UnitIsDead(u) and "Dead" or UnitIsGhost(u) and "Ghost"
	end,

	["[difficulty]"]  = function(u)
		if UnitCanAttack("player", u) then
			local l = UnitLevel(u)
			return Hex(GetQuestDifficultyColor((l > 0) and l or 99))
		end
	end,

	["[faction]"] = function(u)
		return UnitFactionGroup(u)
	end,

	["[leader]"] = function(u)
		return UnitIsPartyLeader(u) and "(L)"
	end,

	["[leaderlong]"]  = function(u)
		return UnitIsPartyLeader(u) and "(Leader)"
	end,

	["[level]"] = function(u)
		local l = UnitLevel(u)
		return (l > 0) and l or "??"
	end,

	["[missinghp]"] = function(u)
		local current = UnitHealthMax(u) - UnitHealth(u)
		if(current > 0) then
			return current
		end
	end,

	["[missingpp]"] = function(u)
		local current = UnitPowerMax(u) - UnitPower(u)
		if(current > 0) then
			return current
		end
	end,

	["[name]"] = function(u, r)
		return UnitName(r or u)
	end,

	["[offline]"] = function(u)
		return  (not UnitIsConnected(u) and "Offline")
	end,

	["[perhp]"] = function(u)
		local m = UnitHealthMax(u)
		return m == 0 and 0 or math.floor(UnitHealth(u)/m*100+0.5)
	end,

	["[perpp]"] = function(u)
		local m = UnitPowerMax(u)
		return m == 0 and 0 or math.floor(UnitPower(u)/m*100+0.5)
	end,

	["[plus]"] = function(u)
		local c = UnitClassification(u)
		return (c == "elite" or c == "rareelite") and "+"
	end,

	["[pvp]"] = function(u)
		return UnitIsPVP(u) and "PvP"
	end,

	["[race]"] = function(u)
		return UnitRace(u)
	end,

	["[raidcolor]"]   = function(u)
		local _, x = UnitClass(u)
		return x and Hex(classColors[x])
	end,

	["[rare]"] = function(u)
		local c = UnitClassification(u)
		return (c == "rare" or c == "rareelite") and "Rare"
	end,

	["[resting]"] = function(u)
		return u == "player" and IsResting() and "zzz"
	end,

	["[sex]"] = function(u)
		local s = UnitSex(u)
		return s == 2 and "Male" or s == 3 and "Female"
	end,

	["[smartclass]"] = function(u)
		return UnitIsPlayer(u) and tags["[class]"](u) or tags["[creature]"](u)
	end,

	["[status]"] = function(u)
		return UnitIsDead(u) and "Dead" or UnitIsGhost(u) and "Ghost" or not UnitIsConnected(u) and "Offline" or tags["[resting]"](u)
	end,

	["[threat]"] = function(u)
		local s = UnitThreatSituation(u)
		return s == 1 and "++" or s == 2 and "--" or s == 3 and "Aggro"
	end,

	["[threatcolor]"] = function(u)
		return Hex(GetThreatStatusColor(UnitThreatSituation(u)))
	end,

	["[cpoints]"] = function(u)
		local cp = GetComboPoints(u, 'target')
		return (cp > 0) and cp
	end,

	['[smartlevel]'] = function(u)
		local c = UnitClassification(u)
		if(c == 'worldboss') then
			return 'Boss'
		else
			local plus = tags['[plus]'](u)
			local level = tags['[level]'](u)
			if(plus) then
				return level .. plus
			else
				return level
			end
		end
	end,

	["[classification]"] = function(u)
		local c = UnitClassification(u)
		return c == "rare" and "Rare" or c == "eliterare" and "Rare Elite" or c == "elite" and "Elite" or c == "worldboss" and "Boss"
	end,

	["[shortclassification]"] = function(u)
		local c = UnitClassification(u)
		return c == "rare" and "R" or c == "eliterare" and "R+" or c == "elite" and "+" or c == "worldboss" and "B"
	end,

	["[group]"] = function(unit)
		local name, server = UnitName(unit)
		if(server and server ~= "") then
			name = string.format("%s-%s", name, server)
		end

		for i=1, GetNumRaidMembers() do
			local raidName, _, group = GetRaidRosterInfo(i)
			if( raidName == name ) then
				return group
			end
		end
	end,

	["[defict:name]"] = function(u)
		return tags['[missinghp]'](u) or tags['[name]'](u)
	end,
}
local tagEvents = {
	["[curhp]"]               = "UNIT_HEALTH",
	["[curpp]"]               = "UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER",
	["[dead]"]                = "UNIT_HEALTH",
	["[leader]"]              = "PARTY_LEADER_CHANGED",
	["[leaderlong]"]          = "PARTY_LEADER_CHANGED",
	["[level]"]               = "UNIT_LEVEL PLAYER_LEVEL_UP",
	["[maxhp]"]               = "UNIT_MAXHEALTH",
	["[maxpp]"]               = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_MAXRUNIC_POWER",
	["[missinghp]"]           = "UNIT_HEALTH UNIT_MAXHEALTH",
	["[missingpp]"]           = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_MAXRUNIC_POWER UNIT_RUNIC_POWER",
	["[name]"]                = "UNIT_NAME_UPDATE",
	["[offline]"]             = "UNIT_HEALTH",
	["[perhp]"]               = "UNIT_HEALTH UNIT_MAXHEALTH",
	["[perpp]"]               = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_MAXRUNIC_POWER UNIT_RUNIC_POWER",
	["[pvp]"]                 = "UNIT_FACTION",
	["[resting]"]             = "PLAYER_UPDATE_RESTING",
	["[status]"]              = "UNIT_HEALTH PLAYER_UPDATE_RESTING",
	["[smartlevel]"]          = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED",
	["[threat]"]              = "UNIT_THREAT_SITUATION_UPDATE",
	["[threatcolor]"]         = "UNIT_THREAT_SITUATION_UPDATE",
	['[cpoints]']             = 'UNIT_COMBO_POINTS UNIT_TARGET',
	['[rare]']                = 'UNIT_CLASSIFICATION_CHANGED',
	['[classification]']      = 'UNIT_CLASSIFICATION_CHANGED',
	['[shortclassification]'] = 'UNIT_CLASSIFICATION_CHANGED',
	["[group]"]               = "RAID_ROSTER_UPDATE",
}

local unitlessEvents = {
	PLAYER_LEVEL_UP = true,
	RAID_ROSTER_UPDATE = true,
}

local events = {}
local frame = CreateFrame"Frame"
frame:SetScript('OnEvent', function(self, event, unit)
	local strings = events[event]
	if(strings) then
		for k, fontstring in next, strings do
			if(not unitlessEvents[event] and fontstring.parent.unit == unit and fontstring:IsVisible()) then
				-- XXX: Fix this for 1.4
				classColors = fontstring.parent.colors.class
				fontstring:UpdateTag()
			end
		end
	end
end)

local OnUpdates = {}
local eventlessUnits = {}

local createOnUpdate = function(timer)
	local OnUpdate = OnUpdates[timer]

	if(not OnUpdate) then
		local total = timer
		local frame = CreateFrame'Frame'
		local strings = eventlessUnits[timer]

		frame:SetScript('OnUpdate', function(self, elapsed)
			if(total >= timer) then
				for k, fs in next, strings do
					if(fs.parent:IsShown() and UnitExists(fs.parent.unit)) then
						-- XXX: Fix this for 1.4.
						classColors = fs.parent.colors.class
						fs:UpdateTag()
					end
				end

				total = 0
			end

			total = total + elapsed
		end)

		OnUpdates[timer] = OnUpdate
	end
end

local OnShow = function(self)
	-- XXX: Fix this for 1.4.
	classColors = self.colors.class
	for _, fs in next, self.__tags do
		fs:UpdateTag()
	end
end

local RegisterEvent = function(fontstr, event)
	if(not events[event]) then events[event] = {} end

	frame:RegisterEvent(event)
	table.insert(events[event], fontstr)
end

local RegisterEvents = function(fontstr, tagstr)
	-- Forcefully strip away any parentheses and the characters in them.
	tagstr = tagstr:gsub('%b()', '')
	for tag in tagstr:gmatch'[%[].-[%]]' do
		local tagevents = tagEvents[tag]
		if(tagevents) then
			for event in tagevents:gmatch'%S+' do
				RegisterEvent(fontstr, event)
			end
		end
	end
end

local UnregisterEvents = function(fontstr)
	for event, data in pairs(events) do
		for k, tagfsstr in pairs(data) do
			if(tagfsstr == fontstr) then
				if(#data == 1) then
					frame:UnregisterEvent(event)
				end

				table.remove(data, k)
			end
		end
	end
end

local tagPool = {}
local funcPool = {}
local tmp = {}

local Tag = function(self, fs, tagstr)
	if(not fs or not tagstr) then return end

	if(not self.__tags) then
		self.__tags = {}
		table.insert(self.__elements, OnShow)
	else
		-- Since people ignore everything that's good practice - unregister the tag
		-- if it already exists.
		for _, tag in pairs(self.__tags) do
			if(fs == tag) then
				-- We don't need to remove it from the __tags table as Untag handles
				-- that for us.
				self:Untag(fs)
			end
		end
	end

	fs.parent = self

	local func = tagPool[tagstr]
	if(not func) then
		-- Using .- in the match prevents use from supporting [] as prepend/append
		-- characters. Supporting these and having a single pattern here is a real
		-- headache however.
		local format = tagstr:gsub('%%', '%%%%'):gsub('[[].-[]]', '%%s')
		local args = {}

		for bracket in tagstr:gmatch'([[](.-)[]])' do
			local tfunc = funcPool[bracket] or tags[bracket]
			if(not tfunc) then
				-- ...
				local pre, tag, ap = bracket:match'[%[](%b())([%w]+)(%b())[%]]'
				if(not pre) then pre, tag = bracket:match'[%[](%b())([%w]+)[%]]' end
				if(not pre) then tag, ap = bracket:match'[%[]([%w]+)(%b())[%]]' end
				tag = (tag and '['.. tag ..']')
				tag = tags[tag]

				if(tag) then
					if(pre and ap) then
						pre = pre:sub(2,-2)
						ap = ap:sub(2,-2)

						tfunc = function(u)
							local str = tag(u)
							if(str) then
								return pre..str..ap
							end
						end
					elseif(pre) then
						pre = pre:sub(2,-2)

						tfunc = function(u)
							local str = tag(u)
							if(str) then
								return pre..str
							end
						end
					elseif(ap) then
						ap = ap:sub(2,-2)

						tfunc = function(u)
							local str = tag(u)
							if(str) then
								return str..ap
							end
						end
					end

					funcPool[bracket] = tfunc
				end
			end

			if(tfunc) then
				table.insert(args,tfunc)
			else
				return error(('Attempted to use invalid tag %s.'):format(bracket), 3)
			end
		end

		func = function(self)
			local unit = self.parent.unit
			local __unit = self.parent.realUnit

			for i, func in next, args do
				tmp[i] = func(unit, __unit) or ''
			end

			self:SetFormattedText(format, unpack(tmp))
		end

		tagPool[tagstr] = func
	end
	fs.UpdateTag = func

	local unit = self.unit
	if((unit and unit:match'%w+target') or fs.frequentUpdates) then
		local timer
		if(type(fs.frequentUpdates) == 'number') then
			timer = fs.frequentUpdates
		else
			timer = .5
		end

		if(not eventlessUnits[timer]) then eventlessUnits[timer] = {} end
		table.insert(eventlessUnits[timer], fs)

		createOnUpdate(timer)
	else
		RegisterEvents(fs, tagstr)
	end

	table.insert(self.__tags, fs)
end

local Untag = function(self, fs)
	if(not fs) then return end

	UnregisterEvents(fs)
	for _, timers in next, eventlessUnits do
		for k, fontstr in next, timers do
			if(fs == fontstr) then
				table.remove(eventlessUnits, k)
			end
		end
	end

	for k, fontstr in next, self.__tags do
		if(fontstr == fs) then
			table.remove(self.__tags, k)
		end
	end

	fs.UpdateTag = nil
end

oUF.Tags = tags
oUF.TagEvents = tagEvents
oUF.UnitlessTagEvents = unitlessEvents

oUF.frame_metatable.__index.Tag = Tag
oUF.frame_metatable.__index.Untag = Untag
