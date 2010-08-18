local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event, unit)
	if(self.unit ~= unit) then return end

	local happ = self.Happiness
	if(happ) then
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

local Enable = function(self)
	local happiness = self.Happiness
	if(happiness) then
		self:RegisterEvent("UNIT_HAPPINESS", happiness.Update or Update)

		if(happiness:IsObjectType"Texture" and not happiness:GetTexture()) then
			happiness:SetTexture[[Interface\PetPaperDollFrame\UI-PetHappiness]]
		end

		return true
	end
end

local Disable = function(self)
	local happiness = self.Happiness
	if(happiness) then
		self:UnregisterEvent("UNIT_HAPPINESS", happiness.Update or Update)
	end
end

oUF:AddElement('Happiness', Update, Enable, Disable)
