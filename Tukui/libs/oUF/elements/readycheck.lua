local parent, ns = ...
local oUF = ns.oUF

local _TIMERS = {}
local ReadyCheckFrame

local removeEntry = function(icon)
	_TIMERS[icon] = nil
	if(not next(_TIMERS)) then
		return ReadyCheckFrame:Hide()
	end
end

local Start = function(self)
	removeEntry(self)

	self:SetTexture(READY_CHECK_WAITING_TEXTURE)
	self.state = 'waiting'
	self:SetAlpha(1)
	self:Show()
end

local Confirm = function(self, ready)
	removeEntry(self)

	if(ready) then
		self:SetTexture(READY_CHECK_READY_TEXTURE)
		self.state = 'ready'
	else
		self:SetTexture(READY_CHECK_NOT_READY_TEXTURE)
		self.state = 'notready'
	end

	self:SetAlpha(1)
	self:Show()
end

local Finish = function(self)
	if(self.state == 'waiting') then
		self:SetTexture(READY_CHECK_AFK_TEXTURE)
		self.state = 'afk'
	end

	self.finishedTimer = 10
	self.fadeTimer = 1.5

	_TIMERS[self] = true
	ReadyCheckFrame:Show()
end

local OnUpdate = function(self, elapsed)
	for icon in next, _TIMERS do
		if(icon.finishedTimer) then
			icon.finishedTimer = icon.finishedTimer - elapsed
			if(icon.finishedTimer <= 0) then
				icon.finishedTimer = nil
			end
		elseif(icon.fadeTimer) then
			icon.fadeTimer = icon.fadeTimer - elapsed
			icon:SetAlpha(icon.fadeTimer / 1.5)

			if(icon.fadeTimer <= 0) then
				icon:Hide()
				removeEntry(icon)
			end
		end
	end
end

local Update = function(self, event, unit)
	local readyCheck = self.ReadyCheck
	if(event == 'READY_CHECK_FINISHED') then
		Finish(readyCheck)
	elseif(self.unit == unit) then
		local status = GetReadyCheckStatus(unit)
		if(UnitExists(unit) and status) then
			if(status == 'ready') then
				Confirm(readyCheck, 1)
			elseif(status == 'notready') then
				Confirm(readyCheck)
			else
				Start(readyCheck)
			end
		--- XXX: RegisterAttributeDriver is making my life hell...
		-- Remove when it actually gets fixed.
		elseif(event) then
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
	if(readyCheck and (unit and unit:sub(1, 5) == 'party')) then
		readyCheck.__owner = self
		readyCheck.ForceUpdate = ForceUpdate

		if(not ReadyCheckFrame) then
			ReadyCheckFrame = CreateFrame'Frame'
			ReadyCheckFrame:SetScript('OnUpdate', OnUpdate)
		end

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
