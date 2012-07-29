local _, ns = ...
local oUF = ns.oUF or oUF or ElvUF
if not oUF then return end

if select(2, UnitClass('player')) ~= "MAGE" then return end

local Update = function(self, event, unit, powerType)
	if unit ~= self.unit then return end
	
	local bar = self.ArcaneChargeBar
	if(bar.PreUpdate) then bar:PreUpdate(event, unit) end

	local talentSpecialization = GetSpecialization()
	
	if talentSpecialization == 1 then
		bar:Show()
	else
		bar:Hide()
	end
	
	local arcaneCharges, maxCharges = 0, 4
	if bar:IsShown() then
		for index = 1, 40 do
			local count, _, _, _, _, _, _, spellID = select(4, UnitDebuff(unit, index))
			if spellID == 36032 then
				arcaneCharges = count or 0
			end
		end	

		for i = 1, maxCharges do
			if i <= arcaneCharges then
				bar[i]:SetValue(1)
			else
				bar[i]:SetValue(0)
			end
		end		
	end
	
	if(bar.PostUpdate) then
		return bar:PostUpdate(event, unit, arcaneCharges, maxCharges)
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
	end	
end

local function Disable(self,unit)
	local bar = self.ArcaneChargeBar
	if(bar) then
		self:UnregisterEvent("UNIT_AURA", Path)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Path)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Path)
	end
end
			
oUF:AddElement("ArcaneCharge",Update,Enable,Disable)