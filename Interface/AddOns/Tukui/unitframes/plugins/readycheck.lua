--[[

	Elements handled:
	 .ReadyCheck [texture]

	Options:
	 - delayTime [value] default: 10
	 - fadeTime [value] default: 1.5

	Add-on originally made by Starlon
--]]

if not TukuiDB["unitframes"].enable == true then return end

local GetReadyCheckStatus = GetReadyCheckStatus

local statusTexture = {
	notready = [=[Interface\RAIDFRAME\ReadyCheck-NotReady]=],
	ready = [=[Interface\RAIDFRAME\ReadyCheck-Ready]=],
	waiting = [=[Interface\RAIDFRAME\ReadyCheck-Waiting]=],
}

function onUpdate(self, elapsed)
	if(self.finish) then
		self.finish = self.finish - elapsed
		if(self.finish <= 0) then
			self.finish = nil
		end
	elseif(self.fade) then
		self.fade = self.fade - elapsed
		if(self.fade <= 0) then
			self.fade = nil
			self:SetScript('OnUpdate', nil)

			for k, v in next, oUF.objects do
				if(v.ReadyCheck and v.unit == self.unit) then
					v.ReadyCheck:Hide()
				end
			end
		else
			for k, v in next, oUF.objects do
				if(v.ReadyCheck and v.unit == self.unit) then
					v.ReadyCheck:SetAlpha(self.fade / self.offset)
				end
			end
		end
	end
end

local function update(self)
	if(not IsRaidLeader() and not IsRaidOfficer() and not IsPartyLeader()) then return end

	local status = GetReadyCheckStatus(self.unit)
	if(status) then
		self.ReadyCheck:SetTexture(statusTexture[status])
		self.ReadyCheck:SetAlpha(1)
		self.ReadyCheck:Show()
	end
end

local function prepare(self)
	local readycheck = self.ReadyCheck
	local dummy = readycheck.dummy

	dummy.unit = self.unit
	dummy.finish = readycheck.delayTime or 10
	dummy.fade = readycheck.fadeTime or 1.5
	dummy.offset = readycheck.fadeTime or 1.5

	dummy:SetScript('OnUpdate', onUpdate)
end

local function enable(self)
	local readycheck = self.ReadyCheck
	if(readycheck) then
		self:RegisterEvent('READY_CHECK', update)
		self:RegisterEvent('READY_CHECK_CONFIRM', update)
		self:RegisterEvent('READY_CHECK_FINISHED', prepare)

		readycheck.dummy = CreateFrame('Frame', nil, self)

		return true
	end
end

local function disable(self)
	if(self.ReadyCheck) then
		self:UnregisterEvent('READY_CHECK', update)
		self:UnregisterEvent('READY_CHECK_CONFIRM', update)
		self:UnregisterEvent('READY_CHECK_FINISHED', prepare)
	end
end

oUF:AddElement('ReadyCheck', update, enable, disable)
