local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

local UnitPlayerControlled = UnitPlayerControlled
local UnitIsOwnerOrControllerOfUnit = UnitIsOwnerOrControllerOfUnit

local function Hide(element)
	if element.Rank then element.Rank:Hide() end
	if element.ProgressText then element.ProgressText:Hide() end
	element:Hide()
end

local function Update(self)
	local npShown = self:IsShown()
	local element = npShown and self.WidgetXPBar
	if not element then return end

	local widget = self.widget
	if not widget then Hide(element) return end

	local unit = self.unit
	if unit and UnitPlayerControlled(unit) and not UnitIsOwnerOrControllerOfUnit('player', unit) then Hide(element) return end

	if element.PreUpdate then
		element:PreUpdate()
	end

	local npcID = self.npcID and tonumber(self.npcID)
	local widgetID = E:GetWidgetInfoID(npcID)
	local realID = npcID and widget.widgetFrames and next(widget.widgetFrames)
	if realID and realID ~= widgetID then -- auto save new npc ids to their widget id
		E:SetWidgetInfoID(npcID, realID)
		widgetID = realID
	end

	local cur, toNext, total, rank, maxRank = E:GetWidgetInfoBase(widgetID)
	if not cur then Hide(element) return end

	element:SetMinMaxValues(0, maxRank and 1 or toNext)
	element:SetValue(maxRank and 1 or cur)
	element:Show()

	if rank and element.Rank then
		element.Rank:SetText(rank)
		element.Rank:Show()
	end

	if element.ProgressText then
		element.ProgressText:SetFormattedText(maxRank and L["Max Rank"] or '%d / %d', cur, toNext)
		element.ProgressText:Show()
	end

	if element.PostUpdate then
		element:PostUpdate(cur, toNext, total, rank, maxRank)
	end
end

local function Path(self, ...)
	return (self.WidgetXPBar.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.WidgetXPBar
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UPDATE_UI_WIDGET', Path, true)
		self:RegisterEvent('QUEST_LOG_UPDATE', Path, true)
		return true
	end
end

local function Disable(self)
	local element = self.WidgetXPBar
	if element then
		Hide(element)

		self:UnregisterEvent('UPDATE_UI_WIDGET', Path)
		self:UnregisterEvent('QUEST_LOG_UPDATE', Path)
	end
end

oUF:AddElement('WidgetXPBar', Path, Enable, Disable)
