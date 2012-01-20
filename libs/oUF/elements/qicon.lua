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
		self:UnregisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)
	end
end

oUF:AddElement('QuestIcon', Path, Enable, Disable)
