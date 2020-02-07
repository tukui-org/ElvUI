local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

local function Hide(element)
	if element.Rank then element.Rank:Hide() end
	if element.ProgressText then element.ProgressText:Hide() end
	element:Hide()
end

local function Update(self)
	local element = self.WidgetXPBar
	if not element then return end

	local widget = self.widget
	if not (widget and widget.widgetFrames) then return end

	if element.PreUpdate then
		element:PreUpdate()
	end

	local widgetID, data = next(widget.widgetFrames)
	local widgetType = data and data.widgetType
	if widgetType ~= 2 then Hide(element) return end -- ignore other types than statusbar for now

	-- 2342 == E:GetWidgetInfoBase(widgetID)
	--local rank, cur, toNext, total, isMax
	--if VoidtouchedEggNPCIDToWidgetIDMap[npcID] then
	--	cur, toNext, total, extra = E:GetWidgetInfoBase(widgetID)
	--else
	--	E:Dump(C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widgetID))
	local rank, cur, toNext, total, isMax = E:GetNazjatarBodyguardXP(widgetID)
	print(widgetID, rank, cur, toNext, total, isMax)
	--end

	element:SetMinMaxValues(0, (isMax and 1) or toNext)
	element:SetValue(isMax and 1 or cur)
	element:Show()

	if rank and element.Rank then
		element.Rank:SetText(rank)
		element.Rank:Show()
	end

	if element.ProgressText then
		element.ProgressText:SetText((isMax and L["Max Rank"]) or ("%d / %d"):format(cur, toNext))
		element.ProgressText:Show()
	end

	if element.PostUpdate then
		element:PostUpdate(rank, cur, toNext, total)
	end
end

local function Path(self, ...)
	return (self.WidgetXPBar.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.WidgetXPBar
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UPDATE_UI_WIDGET", Path, true)
		self:RegisterEvent("QUEST_LOG_UPDATE", Path, true)
		return true
	end
end

local function Disable(self)
	local element = self.WidgetXPBar
	if element then
		Hide(element)

		self:UnregisterEvent("UPDATE_UI_WIDGET", Path)
		self:UnregisterEvent("QUEST_LOG_UPDATE", Path)
	end
end

oUF:AddElement("WidgetXPBar", Path, Enable, Disable)
