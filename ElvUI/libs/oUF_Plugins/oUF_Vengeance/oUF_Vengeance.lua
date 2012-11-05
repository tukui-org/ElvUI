local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF not loaded')

local STAMINA_INDEX = 3
local VENG_NAME = (GetSpellInfo(93098))

local function CalculateVengeanceMax(self)
	local _, stamina = UnitStat("player", STAMINA_INDEX);
	self.Stamina = stamina;
	local basehp = (UnitHealthMax("player") or 0) - stamina*(UnitHPPerStamina("player") or 10);

	if self.BaseHealth > 0 then
		self.BaseHealth = min(self.BaseHealth, basehp);
	else
		self.BaseHealth = basehp;
	end

	self.VengeanceMax = self.BaseHealth * .1 + stamina;
	self:SetMinMaxValues(0, self.VengeanceMax);
end

local Update = function(self, event, unit)
	local bar = self.Vengeance

	if(bar.PreUpdate) then bar:PreUpdate(event) end
	local value = select(14, UnitBuff("player", VENG_NAME));
	
	if not value or value == 0 then
		bar:Hide()
	elseif not bar:IsShown() or event ~= 'UNIT_AURA' then
		bar:Show()
		CalculateVengeanceMax(bar);
	end
	
	
	bar:SetValue(value or 0);
	print('Vengeance: '..(value or 0)..'/'..bar.VengeanceMax..'  '..(((value or 0) > bar.VengeanceMax) and 'BAD!' or 'GOOD!'))
	if(bar.PostUpdate) then bar:PostUpdate(event, value or 0) end
end

local Enable = function(self)
	local bar = self.Vengeance
	if bar then
		self:RegisterEvent("UNIT_AURA", Update, true);
		self:RegisterEvent("UNIT_MAXHEALTH", Update, true);
		self:RegisterEvent("PLAYER_LEVEL_UP", Update, true);
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", Update, true);
		self:RegisterEvent("PLAYER_TALENT_UPDATE", Update, true);
		bar.BaseHealth = 0;
		bar.Stamina = 0;
		bar.VengeanceMax = 1;
	
		bar:Show()
		if(bar:IsObjectType'StatusBar' and not bar:GetStatusBarTexture()) then
			bar:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end
		
		return true
	end
end

local Disable = function(self)
	local bar = self.Vengeance
	if bar then
		self:UnregisterEvent("UNIT_AURA", Update);
		self:UnregisterEvent("UNIT_MAXHEALTH", Update);
		self:UnregisterEvent("PLAYER_LEVEL_UP", Update);
		self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED", Update);
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Update);	
		bar:Hide()
	end
end
 
oUF:AddElement('Vengeance', Update, Enable, Disable)