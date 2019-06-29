local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

local NPCIDToWidgetIDMap = {
	[154304] = 1940, -- Farseer Ori
	--[0] = 1613, -- Hunter Akana
	[154371] = 1966 -- Bladesman Inowari
	--[0] = 1621, -- Neri Sharpfin
	--[0] = 1622, -- Poen Gillbrack
	--[0] = 1920 -- Vim Brineheart
}

local function GetBodyguardXP(widgetID)
	local widget = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widgetID)
	local rank = string.match(widget.overrideBarText, "%d+")
	local cur = widget.barValue - widget.barMin
	local next = widget.barMax - widget.barMin
	local total = widget.barValue
	return rank, cur, next, total
end

local function Update(self, ...)
	local element = self.NazjatarFollowerXP
	if (not self.npcID) then
		element:Hide()
		return
	end

	if element.PreUpdate then
		element:PreUpdate()
	end

	local widgetID = NPCIDToWidgetIDMap[tonumber(self.npcID)]
	if not widgetID then
		element:Hide()
		return
	end

	local rank, cur, next, total = GetBodyguardXP(widgetID)
	element:SetMinMaxValues(0, next)
	element:SetValue(cur)

	if (element.Rank) then
		element.Rank:SetText(rank)
	end

	element:Show()

	if (element.PostUpdate) then
		element:PostUpdate(rank, cur, next, total)
	end
end

local function Path(self, ...)
	return (self.NazjatarFollowerXP.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.NazjatarFollowerXP
	if (element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UPDATE_UI_WIDGET", Path, true)
		return true
	end
end

local function Disable(self)
	local element = self.NazjatarFollowerXP
	if (element) then
		element:Hide()

		self:UnregisterEvent("UPDATE_UI_WIDGET", Path)
	end
end

oUF:AddElement("NazjatarFollowerXP", Path, Enable, Disable)
