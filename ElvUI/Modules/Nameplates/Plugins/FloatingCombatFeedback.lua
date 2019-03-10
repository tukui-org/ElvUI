local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

local _G = _G
local wipe = wipe
local pairs = pairs
local m_cos = math.cos
local m_max = math.max
local m_pi = math.pi
local m_sin = math.sin
local t_insert = table.insert
local t_remove = table.remove

local AbbreviateNumbers = AbbreviateNumbers
local BreakUpLargeNumbers = BreakUpLargeNumbers

-- sourced from FrameXML/Constants.lua
local SCHOOL_MASK_NONE = SCHOOL_MASK_NONE or 0x00
local SCHOOL_MASK_PHYSICAL = SCHOOL_MASK_PHYSICAL or 0x01
local SCHOOL_MASK_HOLY = SCHOOL_MASK_HOLY or 0x02
local SCHOOL_MASK_FIRE = SCHOOL_MASK_FIRE or 0x04
local SCHOOL_MASK_NATURE = SCHOOL_MASK_NATURE or 0x08
local SCHOOL_MASK_FROST = SCHOOL_MASK_FROST or 0x10
local SCHOOL_MASK_SHADOW = SCHOOL_MASK_SHADOW or 0x20
local SCHOOL_MASK_ARCANE = SCHOOL_MASK_ARCANE or 0x40

local colors = {
	ABSORB		= {r = 1.00, g = 1.00, b = 1.00},
	BLOCK		= {r = 1.00, g = 1.00, b = 1.00},
	DEFLECT		= {r = 1.00, g = 1.00, b = 1.00},
	DODGE		= {r = 1.00, g = 1.00, b = 1.00},
	ENERGIZE	= {r = 0.41, g = 0.80, b = 0.94},
	EVADE		= {r = 1.00, g = 1.00, b = 1.00},
	HEAL		= {r = 0.10, g = 0.80, b = 0.10},
	IMMUNE		= {r = 1.00, g = 1.00, b = 1.00},
	INTERRUPT	= {r = 1.00, g = 1.00, b = 1.00},
	MISS		= {r = 1.00, g = 1.00, b = 1.00},
	PARRY		= {r = 1.00, g = 1.00, b = 1.00},
	REFLECT		= {r = 1.00, g = 1.00, b = 1.00},
	RESIST		= {r = 1.00, g = 1.00, b = 1.00},
	WOUND		= {r = 0.70, g = 0.10, b = 0.10},
}

local schoolColors = {
	[SCHOOL_MASK_NONE]		= {r = 1.00, g = 1.00, b = 1.00},
	[SCHOOL_MASK_PHYSICAL]	= {r = 0.70, g = 0.10, b = 0.10},
	[SCHOOL_MASK_HOLY]		= {r = 1.00, g = 0.90, b = 0.50},
	[SCHOOL_MASK_FIRE]		= {r = 1.00, g = 0.50, b = 0.00},
	[SCHOOL_MASK_NATURE]	= {r = 0.30, g = 1.00, b = 0.30},
	[SCHOOL_MASK_FROST]		= {r = 0.50, g = 1.00, b = 1.00},
	[SCHOOL_MASK_SHADOW]	= {r = 0.50, g = 0.50, b = 1.00},
	[SCHOOL_MASK_ARCANE]	= {r = 1.00, g = 0.50, b = 1.00},
}

local function removeString(self, i, string)
	t_remove(self.FeedbackToAnimate, i)
	string:SetText(nil)
	string:SetAlpha(0)
	string:Hide()

	return string
end

local function getAvailableString(self)
	for i = 1, self.__max do
		if not self[i]:IsShown() then
			return self[i]
		end
	end

	return removeString(self, 1, self.FeedbackToAnimate[1])
end

local function fountainScroll(self)
	return self.x + self.xDirection * 65 * (1 - m_cos(m_pi / 2 * self.elapsed / self.scrollTime)),
		self.y + self.yDirection * 65 * m_sin(m_pi / 2 * self.elapsed / self.scrollTime)
end

local function standardScroll(self)
	return self.x,
		self.y + self.yDirection * 65 * self.elapsed / self.scrollTime
end

local function onUpdate(self, elapsed)
	for index, string in pairs(self.FeedbackToAnimate) do
		if string.elapsed >= string.scrollTime then
			removeString(self, index, string)
		else
			string.elapsed = string.elapsed + elapsed

			string:Point("CENTER", self, "CENTER", self.Scroll(string))

			if (string.elapsed >= self.fadeout) then
				string:SetAlpha(m_max(1 - (string.elapsed - self.fadeout) / (self.scrollTime - self.fadeout), 0))
			end
		end
	end

	if #self.FeedbackToAnimate == 0 then
		self:SetScript("OnUpdate", nil)
	end
end

local function onShow(self)
	for index, string in pairs(self.FeedbackToAnimate) do
		removeString(self, index, string)
	end
end

local function Update(self, event, unit, message, flag, amount, school)
	if self.unit ~= unit then return end

	local element = self.FloatingCombatFeedback
	local multiplier = 1
	local text, color

	if message == "WOUND" and not element.ignoreDamage then
		if amount ~= 0	then
			if element.abbreviateNumbers then
				text = "-"..AbbreviateNumbers(amount)
			else
				text = "-"..BreakUpLargeNumbers(amount)
			end

			color = element.schoolColors and element.schoolColors[school]
				or schoolColors[school]
				or element.colors and element.colors[message]
				or colors[message]

			if flag == "CRITICAL" or flag == "CRUSHING" then
				multiplier = 1.25
			elseif flag == "GLANCING" then
				multiplier = 0.75
			end
		elseif flag and flag ~= "CRITICAL" and flag ~= "CRUSHING" and flag ~= "GLANCING" and not element.ignoreMisc then
			text = _G[flag]
			color = element.colors and element.colors[flag] or colors[flag]
		end
	elseif message == "ENERGIZE" and not element.ignoreEnergize then
		if element.abbreviateNumbers then
			text = "+"..AbbreviateNumbers(amount)
		else
			text = "+"..BreakUpLargeNumbers(amount)
		end

		color = element.colors and element.colors[message] or colors[message]

		if flag == "CRITICAL" then
			multiplier = 1.25
		end
	elseif message == "HEAL" and not element.ignoreHeal then
		if element.abbreviateNumbers then
			text = "+"..AbbreviateNumbers(amount)
		else
			text = "+"..BreakUpLargeNumbers(amount)
		end

		color = element.colors and element.colors[message] or colors[message]

		if flag == "CRITICAL" then
			multiplier = 1.25
		end
	elseif not element.ignoreMisc then
		text = _G[message]
		color = element.colors and element.colors[message] or colors[message]
	end

	if text then
		local string = getAvailableString(element)

		string.elapsed = 0
		string.scrollTime = element.scrollTime
		string.xDirection = element.xDirection
		string.yDirection = element.yDirection
		string.x = element.xOffset * string.xDirection
		string.y = element.yOffset * string.yDirection

		string:SetText(text)
		string:SetTextHeight(element.fontHeight * multiplier)
		string:SetTextColor(color.r, color.g, color.b)
		string:Point("CENTER", element, "CENTER", string.x, string.y)
		string:SetAlpha(1)
		string:Show()

		t_insert(element.FeedbackToAnimate, string)

		element.xDirection = element.xDirection * -1

		if not element:GetScript("OnUpdate") then
			element.Scroll = element.mode == "Fountain" and fountainScroll or standardScroll

			element:SetScript("OnUpdate", onUpdate)
			element:SetScript("OnHide", function(self)
				wipe(self.FeedbackToAnimate)
				for i = 1, self.__max do
					self[i]:Hide()
				end
			end)
		end
	end
end

local function Path(self, ...)
	return (self.FloatingCombatFeedback.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.FloatingCombatFeedback

	if not element then return end

	element.__owner = self
	element.__max = #element
	element.ForceUpdate = ForceUpdate

	element.scrollTime = element.scrollTime or 1.5
	element.fadeout = element.scrollTime / 3
	element.xDirection = 1
	element.yDirection = element.yDirection or 1
	element.yOffset = element.yOffset or 8
	element.fontHeight = element.fontHeight or 18
	element.FeedbackToAnimate = {}

	if element.mode == "Fountain" then
		element.xOffset = element.xOffset or 6
	else
		element.xOffset = element.xOffset or 30
	end

	for i = 1, element.__max do
		element[i]:Hide()
	end

	element:SetScript("OnShow", onShow)

	self:RegisterEvent("UNIT_COMBAT", Path)

	return true
end

local function Disable(self)
	local element = self.FloatingCombatFeedback

	if element then
		element:SetScript("OnShow", nil)

		self:UnregisterEvent("UNIT_COMBAT", Path)
	end
end

oUF:AddElement("FloatingCombatFeedback", Path, Enable, Disable)
