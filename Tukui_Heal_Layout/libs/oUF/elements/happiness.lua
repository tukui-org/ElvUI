local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event, unit, powerType)
	if(self.unit ~= unit) then return end

	local happ = self.Happiness
	if(happ and (powerType == 'HAPPINESS' or not powerType)) then
		local happiness = GetPetHappiness()
		local _, hunterPet = HasPetUI()

		if(not (happiness or hunterPet)) then
			return happ:Hide()
		end

		happ:Show()
		if(happiness == 1) then
			happ:SetTexCoord(0.375, 0.5625, 0, 0.359375)
		elseif(happiness == 2) then
			happ:SetTexCoord(0.1875, 0.375, 0, 0.359375)
		elseif(happiness == 3) then
			happ:SetTexCoord(0, 0.1875, 0, 0.359375)
		end

		if(happ.PostUpdate) then
			return happ:PostUpdate(unit, happiness)
		end
	end
end

local Path = function(self, ...)
	return (self.Happiness.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self)
	local happiness = self.Happiness
	if(happiness) then
		happiness.__owner = self
		happiness.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER', Path)

		if(happiness:IsObjectType"Texture" and not happiness:GetTexture()) then
			happiness:SetTexture[[Interface\PetPaperDollFrame\UI-PetHappiness]]
		end

		return true
	end
end

local Disable = function(self)
	local happiness = self.Happiness
	if(happiness) then
		self:UnregisterEvent('UNIT_POWER', Path)
	end
end

oUF:AddElement('Happiness', Path, Enable, Disable)
