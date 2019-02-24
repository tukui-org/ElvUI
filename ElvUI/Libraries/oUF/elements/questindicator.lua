--[[
# Element: Quest Indicator

Handles the visibility and updating of an indicator based on the unit's involvement in a quest.

## Widget

QuestIndicator - Any UI widget.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local QuestIndicator = self:CreateTexture(nil, 'OVERLAY')
    QuestIndicator:SetSize(16, 16)
    QuestIndicator:SetPoint('TOPRIGHT', self)

    -- Register it with oUF
    self.QuestIndicator = QuestIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if(unit ~= self.unit) then return end

	local element = self.QuestIndicator

	--[[ Callback: QuestIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the QuestIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local isQuestBoss = UnitIsQuestBoss(unit)
	if(isQuestBoss) then
		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: QuestIndicator:PostUpdate(isQuestBoss)
	Called after the element has been updated.

	* self        - the QuestIndicator element
	* isQuestBoss - indicates if the element is shown (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(isQuestBoss)
	end
end

local function Path(self, ...)
	--[[ Override: QuestIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.QuestIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.QuestIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\TargetingFrame\PortraitQuestBadge]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.QuestIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)
	end
end

oUF:AddElement('QuestIndicator', Path, Enable, Disable)
