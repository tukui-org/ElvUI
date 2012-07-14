local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	if not self.unit then return; end
	local assistant = self.Assistant
	
	if(assistant.PreUpdate) then
		assistant:PreUpdate()
	end

	local unit = self.unit
	local isAssistant = UnitInRaid(unit) and UnitIsRaidOfficer(unit) and not UnitIsGroupLeader(unit)
	if(isAssistant) then
		assistant:Show()
	else
		assistant:Hide()
	end

	if(assistant.PostUpdate) then
		return assistant:PostUpdate(isAssistant)
	end
end

local Path = function(self, ...)
	return (self.Assistant.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local assistant = self.Assistant
	if(assistant) then
		self:RegisterEvent("GROUP_ROSTER_UPDATE", Path, true)

		if(assistant:IsObjectType"Texture" and not assistant:GetTexture()) then
			assistant:SetTexture[[Interface\GroupFrame\UI-Group-AssistantIcon]]
		end

		assistant.__owner = self
		assistant.ForceUpdate = ForceUpdate

		return true
	end
end

local Disable = function(self)
	local assistant = self.Assistant
	if(assistant) then
		self:UnregisterEvent("GROUP_ROSTER_UPDATE", Path)
	end
end

oUF:AddElement('Assistant', Path, Enable, Disable)
