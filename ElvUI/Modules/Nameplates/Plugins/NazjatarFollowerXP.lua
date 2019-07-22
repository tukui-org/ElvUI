local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

local strmatch, tonumber = strmatch, tonumber
local UnitIsOwnerOrControllerOfUnit = UnitIsOwnerOrControllerOfUnit
local IsQuestFlaggedCompleted = IsQuestFlaggedCompleted
local C_UIWidgetManager_GetStatusBarWidgetVisualizationInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo

local NPCIDToWidgetIDMap = {
	[154304] = 1940, -- Farseer Ori
	[150202] = 1613, -- Hunter Akana
	[154297] = 1966, -- Bladesman Inowari
	[151300] = 1621, -- Neri Sharpfin
	[151310] = 1622, -- Poen Gillbrack
	[151309] = 1920 -- Vim Brineheart
}

local CampfireNPCIDToWidgetIDMap = {
	[149805] = 1940, -- Farseer Ori
	[149804] = 1613, -- Hunter Akana
	[149803] = 1966, -- Bladesman Inowari
	[149904] = 1621, -- Neri Sharpfin
	[149902] = 1622, -- Poen Gillbrack
	[149906] = 1920 -- Vim Brineheart
}

local NeededQuestIDs = {
	["Horde"] = 55500,
	["Alliance"] = 56156
}

local MAX_RANK = 30

local function GetBodyguardXP(widgetID)
	local widget = widgetID and C_UIWidgetManager_GetStatusBarWidgetVisualizationInfo(widgetID)
	if not widget then
		return
	end

	local rank = strmatch(widget.overrideBarText, "%d+")
	local cur = widget.barValue - widget.barMin
	local next = widget.barMax - widget.barMin
	local total = widget.barValue
	return rank, cur, next, total
end

local function Update(self)
	local element = self.NazjatarFollowerXP
	if not element then
		return
	end

	local npcID, questID = tonumber(self.npcID), NeededQuestIDs[E.myfaction]
	local hasQuestCompleted = questID and IsQuestFlaggedCompleted(questID)
	local isProperNPC = npcID and (NPCIDToWidgetIDMap[npcID] and self.unit and UnitIsOwnerOrControllerOfUnit("player", self.unit)) or CampfireNPCIDToWidgetIDMap[npcID]
	if (not hasQuestCompleted or not isProperNPC) then
		element:Hide()
		if element.Rank then
			element.Rank:Hide()
		end
		if element.ProgressText then
			element.ProgressText:Hide()
		end

		return
	end

	if element.PreUpdate then
		element:PreUpdate()
	end

	local widgetID = NPCIDToWidgetIDMap[npcID] or CampfireNPCIDToWidgetIDMap[npcID]
	if not widgetID then
		element:Hide()
		if element.Rank then
			element.Rank:Hide()
		end
		if element.ProgressText then
			element.ProgressText:Hide()
		end
		return
	end

	local rank, cur, next, total = GetBodyguardXP(widgetID)
	if not rank then
		return
	end

	local nrank = tonumber(rank)
	if nrank == MAX_RANK then
		element:SetMinMaxValues(0, 1)
	else
		element:SetMinMaxValues(0, next)
	end
	element:SetValue(nrank == MAX_RANK and 1 or cur)

	if (element.Rank) then
		element.Rank:SetText(rank)
	end

	if element.ProgressText then
		if nrank == MAX_RANK then
			element.ProgressText:SetText(L["Max Rank"])
		else
			element.ProgressText:SetText(("%d / %d"):format(cur, next))
		end
		element.ProgressText:Show()
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
		self:RegisterEvent("QUEST_LOG_UPDATE", Path, true)
		return true
	end
end

local function Disable(self)
	local element = self.NazjatarFollowerXP
	if (element) then
		element:Hide()
		if element.Rank then
			element.Rank:Hide()
		end
		if element.ProgressText then
			element.ProgressText:Hide()
		end

		self:UnregisterEvent("UPDATE_UI_WIDGET", Path)
		self:UnregisterEvent("QUEST_LOG_UPDATE", Path)
	end
end

oUF:AddElement("NazjatarFollowerXP", Path, Enable, Disable)
