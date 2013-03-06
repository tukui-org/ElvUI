local _, ns = ...
local oUF = oUF or ns.oUF
if not oUF then return end

if select(2, UnitClass('player')) ~= "MAGE" then return end

local function UpdateBar(self, elapsed)
	if not self.expirationTime then return end
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.5 then	
		local timeLeft = self.expirationTime - GetTime()
		if timeLeft > 0 then
			self:SetValue(timeLeft)
		else
			self:SetScript("OnUpdate", nil)
		end
	end		
end

local Update = function(self, event)
	local unit = self.unit or 'player'
	local bar = self.ArcaneChargeBar
	if(bar.PreUpdate) then bar:PreUpdate(event) end

	local talentSpecialization = GetSpecialization()
	
	if talentSpecialization == 1 then
		bar:Show()
	else
		bar:Hide()
	end
	
	local arcaneCharges, maxCharges, duration, expirationTime = 0, 4
	if bar:IsShown() then		
		for index=1, 30 do
			local _, _, _, count, _, start, timeLeft, _, _, _, spellID = UnitDebuff(unit, index)
			if spellID == 36032 then
				arcaneCharges = count or 0
				duration = start
				expirationTime = timeLeft
				break
			end			
		end

		for i = 1, maxCharges do
			if duration and expirationTime then
				bar[i]:SetMinMaxValues(0, duration)
				bar[i].duration = duration
				bar[i].expirationTime = expirationTime
			end
			
			if i <= arcaneCharges then
				bar[i]:SetValue(duration)
				bar[i]:SetScript('OnUpdate', UpdateBar)
			else
				bar[i]:SetValue(0)
				bar[i]:SetScript('OnUpdate', nil)
			end
		end		
	end
	
	if(bar.PostUpdate) then
		return bar:PostUpdate(event, arcaneCharges, maxCharges)
	end
end


local Path = function(self, ...)
	return (self.ArcaneChargeBar.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local bar = self.ArcaneChargeBar

	if(bar) then
		self:RegisterEvent("UNIT_AURA", Path)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", Path)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Path)
		bar.__owner = self
		bar.ForceUpdate = ForceUpdate

		for i = 1, 4 do
			if not bar[i]:GetStatusBarTexture() then
				bar[i]:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end

			bar[i]:SetFrameLevel(bar:GetFrameLevel() + 1)
			bar[i]:GetStatusBarTexture():SetHorizTile(false)
			
			if bar[i].bg then
				bar[i]:SetMinMaxValues(0, 1)
				bar[i]:SetValue(0)
				bar[i].bg:SetAlpha(0.2)
				bar[i].bg:SetAllPoints()
			end		
		end
		
		return true;
	end	
end

local function Disable(self,unit)
	local bar = self.ArcaneChargeBar

	if(bar) then
		self:UnregisterEvent("UNIT_AURA", Path)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Path)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Path)
		bar:Hide()
	end
end
			
oUF:AddElement("ArcaneChargeBar",Path,Enable,Disable)