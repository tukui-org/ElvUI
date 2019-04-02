local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF FloatingCombatFeedback was unable to locate oUF install")

local _G = getfenv(0)
local b_and = _G.bit.band
local hooksecurefunc = _G.hooksecurefunc
local m_cos = _G.math.cos
local m_pi = _G.math.pi
local m_random = _G.math.random
local m_sin = _G.math.sin
local next = _G.next
local select = _G.select
local t_insert = _G.table.insert
local t_remove = _G.table.remove
local t_wipe = _G.table.wipe
local type = _G.type

local AbbreviateNumbers = _G.AbbreviateNumbers
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local GetSpellTexture = _G.GetSpellTexture
local UnitGUID = _G.UnitGUID

local function copyTable(src, dst)
	if type(dst) ~= "table" then
		dst = {}
	end

	for k, v in next, src do
		if type(v) == "table" then
			dst[k] = copyTable(v, dst[k])
		else
			if dst[k] == nil then
				dst[k] = v
			end
		end
	end

	return dst
end

local function clamp(v)
	if v > 1 then
		return 1
	elseif v < 0 then
		return 0
	end

	return v
end

-- sourced from FrameXML/Constants.lua
local SCHOOL_MASK_NONE = _G.SCHOOL_MASK_NONE or 0x00
local SCHOOL_MASK_PHYSICAL = _G.SCHOOL_MASK_PHYSICAL or 0x01
local SCHOOL_MASK_HOLY = _G.SCHOOL_MASK_HOLY or 0x02
local SCHOOL_MASK_FIRE = _G.SCHOOL_MASK_FIRE or 0x04
local SCHOOL_MASK_NATURE = _G.SCHOOL_MASK_NATURE or 0x08
local SCHOOL_MASK_FROST = _G.SCHOOL_MASK_FROST or 0x10
local SCHOOL_MASK_SHADOW = _G.SCHOOL_MASK_SHADOW or 0x20
local SCHOOL_MASK_ARCANE = _G.SCHOOL_MASK_ARCANE or 0x40

-- multi-schools
local SCHOOL_MASK_ASTRAL = SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE
local SCHOOL_MASK_CHAOS = SCHOOL_MASK_ARCANE + SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_HOLY + SCHOOL_MASK_NATURE + SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_SHADOW
local SCHOOL_MASK_ELEMENTAL = SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_NATURE
local SCHOOL_MASK_MAGIC =  SCHOOL_MASK_ARCANE + SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_HOLY + SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW
local SCHOOL_MASK_PLAGUE = SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW
local SCHOOL_MASK_RADIANT = SCHOOL_MASK_FIRE + SCHOOL_MASK_HOLY
local SCHOOL_MASK_SHADOWFLAME = SCHOOL_MASK_FIRE + SCHOOL_MASK_SHADOW
local SCHOOL_MASK_SHADOWFROST = SCHOOL_MASK_FROST + SCHOOL_MASK_SHADOW

local function rgb(r, g, b)
	return {r = r / 255, g = g / 255, b = b /255}
end

local colors = {
	["ABSORB"   ] = rgb(255, 255, 255),
	["BLOCK"    ] = rgb(255, 255, 255),
	["DEFLECT"  ] = rgb(255, 255, 255),
	["DODGE"    ] = rgb(255, 255, 255),
	["ENERGIZE" ] = rgb(105, 204, 240),
	["EVADE"    ] = rgb(255, 255, 255),
	["HEAL"     ] = rgb(26, 204, 26),
	["IMMUNE"   ] = rgb(255, 255, 255),
	["INTERRUPT"] = rgb(255, 255, 255),
	["MISS"     ] = rgb(255, 255, 255),
	["PARRY"    ] = rgb(255, 255, 255),
	["REFLECT"  ] = rgb(255, 255, 255),
	["RESIST"   ] = rgb(255, 255, 255),
	["WOUND"    ] = rgb(179, 26, 26),
}

local schoolColors = {
	[SCHOOL_MASK_ARCANE     ] = rgb(255, 128, 255),
	[SCHOOL_MASK_FIRE       ] = rgb(255, 128, 000),
	[SCHOOL_MASK_FROST      ] = rgb(128, 255, 255),
	[SCHOOL_MASK_HOLY       ] = rgb(255, 230, 128),
	[SCHOOL_MASK_NATURE     ] = rgb(77, 255, 77),
	[SCHOOL_MASK_NONE       ] = rgb(255, 255, 255),
	[SCHOOL_MASK_PHYSICAL   ] = rgb(179, 26, 26),
	[SCHOOL_MASK_SHADOW     ] = rgb(128, 128, 255),
	-- multi-schools
	[SCHOOL_MASK_ASTRAL     ] = rgb(166, 192, 166),
	[SCHOOL_MASK_CHAOS      ] = rgb(182, 164, 142),
	[SCHOOL_MASK_ELEMENTAL  ] = rgb(153, 212, 111),
	[SCHOOL_MASK_MAGIC      ] = rgb(183, 187, 162),
	[SCHOOL_MASK_PLAGUE     ] = rgb(103, 192, 166),
	[SCHOOL_MASK_RADIANT    ] = rgb(255, 178, 64),
	[SCHOOL_MASK_SHADOWFLAME] = rgb(192, 128, 128),
	[SCHOOL_MASK_SHADOWFROST] = rgb(128, 192, 255),
}

local animations = {
	["fountain"] = function(self)
		return self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),
			self.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress)
	end,
	["vertical"] = function(self)
		return self.x,
			self.y + self.yDirection * self.radius * self.progress
	end,
	["horizontal"] = function(self)
		return self.x + self.xDirection * self.radius * self.progress,
			self.y
	end,
	["diagonal"] = function(self)
		return self.x + self.xDirection * self.radius * self.progress,
			self.y + self.yDirection * self.radius * self.progress
	end,
	["static"] = function(self)
		return self.x, self.y
	end,
	["random"] = function(self)
		if self.elapsed == 0 then
			self.x, self.y = m_random(-self.radius * 0.66, self.radius * 0.66), m_random(-self.radius * 0.66, self.radius * 0.66)
		end

		return self.x, self.y
	end,
}

local animationsByEvent = {
	["ABSORB"   ] = "fountain",
	["BLOCK"    ] = "fountain",
	["DEFLECT"  ] = "fountain",
	["DODGE"    ] = "fountain",
	["ENERGIZE" ] = "fountain",
	["EVADE"    ] = "fountain",
	["HEAL"     ] = "fountain",
	["IMMUNE"   ] = "fountain",
	["INTERRUPT"] = "fountain",
	["MISS"     ] = "fountain",
	["PARRY"    ] = "fountain",
	["REFLECT"  ] = "fountain",
	["RESIST"   ] = "fountain",
	["WOUND"    ] = "fountain",
}

local animationsByFlag = {
	["ABSORB"  ] = false,
	["BLOCK"   ] = false,
	["CRITICAL"] = false,
	["CRUSHING"] = false,
	["GLANCING"] = false,
	["RESIST"  ] = false,
}

local multipliersByFlag = {
	[""        ] = 1,
	["ABSORB"  ] = 0.75,
	["BLOCK"   ] = 0.75,
	["CRITICAL"] = 1.25,
	["CRUSHING"] = 1.25,
	["GLANCING"] = 0.75,
	["RESIST"  ] = 0.75,
}

local xOffsetsByAnimation = {
	["diagonal"  ] = 24,
	["fountain"  ] = 24,
	["horizontal"] = 8,
	["random"    ] = 0,
	["static"    ] = 0,
	["vertical"  ] = 8,
}

local yOffsetsByAnimation = {
	["diagonal"  ] = 8,
	["fountain"  ] = 8,
	["horizontal"] = 8,
	["random"    ] = 0,
	["static"    ] = 0,
	["vertical"  ] = 8,
}

local function removeString(self, i, string)
	t_remove(self.FeedbackToAnimate, i)
	string:SetText(nil)
	string:SetAlpha(0)
	string:Hide()

	return string
end

local function getString(self)
	for i = 1, #self do
		if not self[i]:IsShown() then
			return self[i]
		end
	end

	return removeString(self, 1, self.FeedbackToAnimate[1])
end

local function onUpdate(self, elapsed)
	for index, string in next, self.FeedbackToAnimate do
		if string.elapsed >= self.scrollTime then
			removeString(self, index, string)
		else
			string.progress = string.elapsed / self.scrollTime
			string:SetPoint("CENTER", self, "CENTER", string:GetXY())

			string.elapsed = string.elapsed + elapsed
			string:SetAlpha(clamp(1 - (string.elapsed - self.fadeTime) / (self.scrollTime - self.fadeTime)))
		end
	end

	if #self.FeedbackToAnimate == 0 then
		self:SetScript("OnUpdate", nil)
	end
end

local function flush(self)
	t_wipe(self.FeedbackToAnimate)

	for i = 1, #self do
		self[i]:SetText(nil)
		self[i]:SetAlpha(0)
		self[i]:Hide()
	end
end

local function Update(self, _, unit, event, flag, amount, school, texture)
	if self.unit ~= unit then return end
	local element = self.FloatingCombatFeedback

	local unitGUID = UnitGUID(unit)
	if unitGUID ~= element.unitGUID then
		flush(element)
		element.unitGUID = unitGUID
	end

	local animation = element.animationsByEvent[event]
	if not animation then return end

	animation = element.animationsByFlag[flag] or animation

	local text, color
	if event == "WOUND" then
		if amount ~= 0	then
			text = element.abbreviateNumbers and AbbreviateNumbers(amount) or BreakUpLargeNumbers(amount)
		elseif flag ~= "" and flag ~= "CRITICAL" and flag ~= "CRUSHING" and flag ~= "GLANCING" then
			text = _G[flag]
		end

		color = element.schoolColors[school] or element.colors[event]
	else
		if amount ~= 0 then
			text = element.abbreviateNumbers and AbbreviateNumbers(amount) or BreakUpLargeNumbers(amount)
		else
			text = _G[event]
		end

		color = element.colors[event]
	end

	if text then
		local string = getString(element)

		string.elapsed = 0
		string.GetXY = element.animations[animation]
		string.radius = element.radius
		string.xDirection = element.xDirection
		string.yDirection = element.yDirection
		string.x = string.xDirection * element.xOffsetsByAnimation[animation]
		string.y = string.yDirection * element.yOffsetsByAnimation[animation]

		string:SetFont(element.font, element.fontHeight * (element.multipliersByFlag[flag] or element.multipliersByFlag[""]), element.fontFlags)
		string:SetFormattedText(element.format, text, texture or "")
		string:SetTextColor(color.r, color.g, color.b)
		string:SetPoint("CENTER", element, "CENTER", string.x, string.y)
		string:SetAlpha(0)
		string:Show()

		t_insert(element.FeedbackToAnimate, string)

		if not element:GetScript("OnUpdate") then
			element:SetScript("OnUpdate", onUpdate)
		end

		if element.alternateX then
			element.xDirection = element.xDirection * -1
		end

		if element.alternateY then
			element.yDirection = element.yDirection * -1
		end
	end
end

local function Path(self, ...)
	(self.FloatingCombatFeedback.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local iconOverrides = {
	[136243] = "",
	["Interface\\Icons\\Trade_Engineering"] = "",
}

local iconCache = {}

local function getTexture(spellID)
	if not iconCache[spellID] then
		local texture = GetSpellTexture(spellID)
		iconCache[spellID] = iconOverrides[texture] or texture
	end

	return iconCache[spellID]
end

local function getEventFlag(resisted, blocked, absorbed, critical, glancing, crushing)
	return (resisted and resisted > 0) and "RESIST"
		or (blocked and blocked > 0) and "BLOCK"
		or (absorbed and absorbed > 0) and "ABSORB"
		or critical and "CRITICAL"
		or glancing and "GLANCING"
		or crushing and "CRUSHING"
		or ""
end

local function prep(event, ...)
	local flag, amount, school, texture, _

	if event == "ENVIRONMENTAL_DAMAGE" then
		_, amount, _, school = ...
		flag = getEventFlag(select(5, ...))
		event = "WOUND"
	elseif event == "RANGE_DAMAGE" or event == "SPELL_BUILDING_DAMAGE" or event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" then
		_, _, _, amount, _, school = ...
		flag = getEventFlag(select(7, ...))
		texture = getTexture(...)
		event = "WOUND"
	elseif event == "SWING_DAMAGE" then
		amount, _, school = ...
		flag = getEventFlag(select(4, ...))
		event = "WOUND"
	elseif event == "SPELL_BUILDING_HEAL" or event == "SPELL_HEAL" or event == "SPELL_PERIODIC_HEAL" then
		_, _, school, amount = ...
		flag = getEventFlag(nil, nil, select(6, ...))
		texture = getTexture(...)
		event = "HEAL"
	elseif event == "RANGE_MISSED" or event == "SPELL_MISSED" or event == "SPELL_PERIODIC_MISSED" then
		_, _, school, flag = ...
		texture = getTexture(...)
		event = flag
	elseif event == "SWING_MISSED" then
		flag = ...
		event = flag
	end

	return event, flag, amount or 0, school or SCHOOL_MASK_NONE, texture
end

local playerGUID = UnitGUID("player")
local COMBATLOG_OBJECT_AFFILIATION_MINE = _G.COMBATLOG_OBJECT_AFFILIATION_MINE or 0x00000001

local frameToGUID = {}
local guidToFrame = {}

local CLEUEvents = {
	-- damage
	["ENVIRONMENTAL_DAMAGE" ] = true, -- environmentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
	["RANGE_DAMAGE"         ] = true, -- spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
	["SPELL_BUILDING_DAMAGE"] = true, -- spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
	["SPELL_DAMAGE"         ] = true, -- spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
	["SPELL_PERIODIC_DAMAGE"] = true, -- spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
	-- miss
	["RANGE_MISSED"         ] = true, -- spellId, spellName, spellSchool, missType, isOffHand, amountMissed = ...
	["SPELL_MISSED"         ] = true, -- spellId, spellName, spellSchool, missType, isOffHand, amountMissed = ...
	["SPELL_PERIODIC_MISSED"] = true, -- spellId, spellName, spellSchool, missType, isOffHand, amountMissed = ...
	-- heal
	["SPELL_BUILDING_HEAL"  ] = true, -- spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = ...
	["SPELL_HEAL"           ] = true, -- spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = ...
	["SPELL_PERIODIC_HEAL"  ] = true, -- spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = ...
	-- swing
	["SWING_DAMAGE"         ] = true, -- amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
	["SWING_MISSED"         ] = true, -- missType, isOffHand, amountMissed = ...
}

local function hasFlag(flags, flag)
	return b_and(flags, flag) > 0
end

local function filter(_, event, _, srcGUID, _, srcFlags, _, dstGUID, _, _, _, ...)
	if guidToFrame[dstGUID] and CLEUEvents[event] then
		if dstGUID == playerGUID or (srcGUID == playerGUID or hasFlag(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE)) then
			for frame in next, guidToFrame[dstGUID] do
				Path(frame, "COMBAT_LOG_EVENT_UNFILTERED", frame.unit, prep(event, ...))
			end
		end
	end
end

local CLEUDispatcher = CreateFrame("Frame")
CLEUDispatcher:SetScript("OnEvent", function()
	filter(CombatLogGetCurrentEventInfo())
end)

local function unGUIDe(frame)
	local guid = frameToGUID[frame]
	if guid then
		frameToGUID[frame] = nil

		if guidToFrame[guid] then
			guidToFrame[guid][frame] = nil
		end
	end
end

local function GUIDe(frame, unit)
	if unit then
		local guid = UnitGUID(unit)
		if guid then
			local oldGUID = frameToGUID[frame]
			if oldGUID then
				if guidToFrame[oldGUID] then
					guidToFrame[oldGUID][frame] = nil
				end
			end

			frameToGUID[frame] = guid

			if not guidToFrame[guid] then
				guidToFrame[guid] = {}
			end

			guidToFrame[guid][frame] = true

			return
		end
	end

	unGUIDe(frame)
end

local hookedFrames = {}
local cleuElements = {}

local function uaeHook(self, event)
	if event ~= "OnUpdate" and next(cleuElements) then
		GUIDe(self, self.unit)
	end
end

local function EnableCLEU(element, state, force)
	if element.useCLEU ~= state or force then
		local frame = element.__owner

		element.useCLEU = state
		if element.useCLEU then
			frame:UnregisterEvent("UNIT_COMBAT", Path)
			CLEUDispatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

			if not hookedFrames[frame] then
				hooksecurefunc(frame, "UpdateAllElements", uaeHook)
				hookedFrames[frame] = true
			end

			GUIDe(frame, frame.unit)

			cleuElements[element] = true
		else
			frame:RegisterEvent("UNIT_COMBAT", Path)

			unGUIDe(frame)

			cleuElements[element] = nil
			if not next(cleuElements) then
				CLEUDispatcher:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			end
		end
	end
end

local function Enable(self)
	local element = self.FloatingCombatFeedback
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.EnableCLEU = EnableCLEU
		element.FeedbackToAnimate = {}

		element.scrollTime = element.scrollTime or 1.2
		element.fadeTime = element.fadeTime or element.scrollTime / 3
		element.format = element.format or "%1$s" -- "%1$s |T%2$s:0:0:0:0:64:64:4:60:4:60|t"
		element.radius = element.radius or 65
		element.xDirection = element.xDirection or 1
		element.yDirection = element.yDirection or 1

		local font, _, fontFlags = element[1]:GetFont()
		element.font = element.font or font or "Fonts\\FRIZQT__.TTF"
		element.fontHeight = element.fontHeight or 18
		element.fontFlags = element.fontFlags or fontFlags or ""

		if element.alternateX == nil then
			element.alternateX = true
		end

		if element.alternateY == nil then
			element.alternateY = false
		end

		for i = 1, #element do
			element[i]:SetFont(element.font, element.fontHeight, element.fontFlags)
			element[i]:Hide()
		end

		element.colors = copyTable(colors, element.colors)
		element.schoolColors = copyTable(schoolColors, element.schoolColors)
		element.animations = copyTable(animations, element.animations)
		element.animationsByEvent = copyTable(animationsByEvent, element.animationsByEvent)
		element.animationsByFlag = copyTable(animationsByFlag, element.animationsByFlag)
		element.multipliersByFlag = copyTable(multipliersByFlag, element.multipliersByFlag)
		element.xOffsetsByAnimation = copyTable(xOffsetsByAnimation, element.xOffsetsByAnimation)
		element.yOffsetsByAnimation = copyTable(yOffsetsByAnimation, element.yOffsetsByAnimation)

		element:SetScript("OnHide", flush)
		element:SetScript("OnShow", flush)
		element:EnableCLEU(element.useCLEU, true)

		return true
	end
end

local function Disable(self)
	local element = self.FloatingCombatFeedback
	if element then
		element:SetScript("OnHide", nil)
		element:SetScript("OnShow", nil)
		element:SetScript("OnUpdate", nil)

		flush(element)

		self:UnregisterEvent("UNIT_COMBAT", Path)

		unGUIDe(self)

		cleuElements[element] = nil
		if not next(cleuElements) then
			CLEUDispatcher:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end

oUF:AddElement("FloatingCombatFeedback", Path, Enable, Disable)
