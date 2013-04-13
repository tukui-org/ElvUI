local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if(self.unit ~= unit) or not unit then return end

	local hp = self.HealPrediction
	hp.parent = self
	
	if(hp.PreUpdate) then hp:PreUpdate(unit) end

	local myIncomingHeal = UnitGetIncomingHeals(unit, 'player') or 0
	local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
	local totalAbsorb = UnitGetTotalAbsorbs(unit) or 0;
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)

	if(health + allIncomingHeal > maxHealth * hp.maxOverflow) then
		allIncomingHeal = maxHealth * hp.maxOverflow - health
	end

	if(allIncomingHeal < myIncomingHeal) then
		myIncomingHeal = allIncomingHeal
		allIncomingHeal = 0
	else
		allIncomingHeal = allIncomingHeal - myIncomingHeal
	end
	
	local overAbsorb = false;
	--We don't overfill the absorb bar
	if ( health + myIncomingHeal + allIncomingHeal + totalAbsorb >= maxHealth ) then
		if ( totalAbsorb > 0 ) then
			overAbsorb = true;
		end
		totalAbsorb = max(0,maxHealth - (health + myIncomingHeal + allIncomingHeal));
	end

	if(hp.overAbsorbGlow) then
		if ( overAbsorb ) then
			hp.overAbsorbGlow:Show();
		else
			hp.overAbsorbGlow:Hide();
		end	
	end

	if(hp.myBar) then
		hp.myBar:SetMinMaxValues(0, maxHealth)
		hp.myBar:SetValue(myIncomingHeal)
		hp.myBar:Show()
	end

	if(hp.otherBar) then
		hp.otherBar:SetMinMaxValues(0, maxHealth)
		hp.otherBar:SetValue(allIncomingHeal)
		hp.otherBar:Show()
	end
	
	if(hp.absorbBar) then
		hp.absorbBar:SetMinMaxValues(0, maxHealth)
		hp.absorbBar:SetValue(totalAbsorb)
		hp.absorbBar:Show()	
	end

	if(hp.PostUpdate) then
		return hp:PostUpdate(unit, myIncomingHeal, allIncomingHeal, totalAbsorb)
	end
end

local function Path(self, ...)
	return (self.HealPrediction.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local hp = self.HealPrediction
	if(hp) then
		hp.__owner = self
		hp.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)
		self:RegisterEvent('UNIT_HEAL_PREDICTION', Path)
		self:RegisterEvent('UNIT_MAXHEALTH', Path)
		self:RegisterEvent('UNIT_HEALTH', Path)

		if(not hp.maxOverflow) then
			hp.maxOverflow = 1.05
		end

		if(hp.myBar and hp.myBar:IsObjectType'StatusBar' and not hp.myBar:GetStatusBarTexture()) then
			hp.myBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end
		if(hp.otherBar and hp.otherBar:IsObjectType'StatusBar' and not hp.otherBar:GetStatusBarTexture()) then
			hp.otherBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end
		if(hp.absorbBar and hp.absorbBar:IsObjectType'StatusBar' and not hp.absorbBar:GetStatusBarTexture()) then
			hp.absorbBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end		

		return true
	end
end

local function Disable(self)
	local hp = self.HealPrediction
	if(hp) then
		self:UnregisterEvent('UNIT_HEAL_PREDICTION', Path)
		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_HEALTH', Path)
		self:UnregisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)

		if hp.myBar then
			hp.myBar:Hide()
		end
		if hp.otherBar then
			hp.otherBar:Hide()
		end
		if hp.absorbBar then
			hp.absorbBar:Hide()
		end				
	end
end

oUF:AddElement('HealPrediction', Path, Enable, Disable)
