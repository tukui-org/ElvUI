--[[ Element: Quest Icon

 Handles updating and toggles visibility based upon the units connection to a
 quest.

 Widget

 QuestIcon - Any UI widget.

 Notes

 The default quest icon will be used if the UI widget is a texture and doesn't
 have a texture or color defined.

 Examples

   -- Position and size
   local QuestIcon = self:CreateTexture(nil, 'OVERLAY')
   QuestIcon:SetSize(16, 16)
   QuestIcon:SetPoint('TOPRIGHT', self)
   
   -- Register it with oUF
   self.QuestIcon = QuestIcon

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
]]

local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event, unit)
	if(unit ~= self.unit) then return end

	local qicon = self.QuestIcon
	if(qicon.PreUpdate) then
		qicon:PreUpdate()
	end

	local isQuestBoss = UnitIsQuestBoss(unit)
	if(isQuestBoss) then
		qicon:Show()
	else
		qicon:Hide()
	end

	if(qicon.PostUpdate) then
		return qicon:PostUpdate(isQuestBoss)
	end
end

local Path = function(self, ...)
	return (self.QuestIcon.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self)
	local qicon = self.QuestIcon
	if(qicon) then
		qicon.__owner = self
		qicon.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)

		if(qicon:IsObjectType'Texture' and not qicon:GetTexture()) then
			qicon:SetTexture[[Interface\TargetingFrame\PortraitQuestBadge]]
		end

		return true
	end
end

local Disable = function(self)
	if(self.QuestIcon) then
		self.QuestIcon:Hide()
		self:UnregisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)
	end
end

oUF:AddElement('QuestIcon', Path, Enable, Disable)
