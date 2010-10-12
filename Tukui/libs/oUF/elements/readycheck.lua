local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	local unit = self.unit
	local readyCheck = self.ReadyCheck

	if(event == 'READY_CHECK_FINISHED') then
		if(GetPartyMember(self:GetID())) then
			ReadyCheck_Finish(readyCheck)
		end
	else
		local status = GetReadyCheckStatus(unit)
		if(UnitExists(unit) and UnitIsConnected(unit) and status) then
			if(status == 'ready') then
				ReadyCheck_Confirm(readyCheck, 1)
			elseif(status == 'notready') then
				ReadyCheck_Confirm(readyCheck, 0)
			else
				ReadyCheck_Start(readyCheck)
			end
		else
			readyCheck:Hide()
		end
	end
end

local Path = function(self, ...)
	return (self.ReadyCheck.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self, unit)
	local readyCheck = self.ReadyCheck
	if(readyCheck) then
		readyCheck.__owner = self
		readyCheck.ForceUpdate = ForceUpdate

		self:RegisterEvent('READY_CHECK', Path)
		self:RegisterEvent('READY_CHECK_CONFIRM', Path)
		self:RegisterEvent('READY_CHECK_FINISHED', Path)

		return true
	end
end

local Disable = function(self)
	local readyCheck = self.ReadyCheck
	if(readyCheck) then
		self:UnregisterEvent('READY_CHECK', Path)
		self:UnregisterEvent('READY_CHECK_CONFIRM', Path)
		self:UnregisterEvent('READY_CHECK_FINISHED', Path)
	end
end

oUF:AddElement('ReadyCheck', Path, Enable, Disable)
