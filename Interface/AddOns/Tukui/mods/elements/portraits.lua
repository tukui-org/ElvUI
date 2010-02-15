local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event, unit)
	if(not UnitIsUnit(self.unit, unit)) then return end
	if(self.PreUpdatePortrait) then self:PreUpdatePortrait(event, unit) end

	local portrait = self.Portrait
	if(portrait:IsObjectType'Model') then
		local name = UnitName(unit)
		if(not UnitExists(unit) or not UnitIsConnected(unit) or not UnitIsVisible(unit)) then
			portrait:SetModelScale(4.25)
			portrait:SetPosition(0, 0, -1.5)
			portrait:SetModel"Interface\\Buttons\\talktomequestionmark.mdx"
		elseif(portrait.name ~= name or event == 'UNIT_MODEL_CHANGED') then
			local alpha = portrait:GetAlpha()
			portrait:SetUnit(unit)
			portrait:SetCamera(0)
			portrait:SetAlpha(alpha)

			portrait.name = name
		else
			portrait:SetCamera(0)
		end
	else
		SetPortraitTexture(portrait, unit)
	end

	if(self.PostUpdatePortrait) then
		return self:PostUpdatePortrait(event, unit)
	end
end

local Enable = function(self)
	if(self.Portrait) then
		self:RegisterEvent("UNIT_PORTRAIT_UPDATE", Update)
		self:RegisterEvent("UNIT_MODEL_CHANGED", Update)

		return true
	end
end

local Disable = function(self)
	if(self.Portrait) then
		self:UnregisterEvent("UNIT_PORTRAIT_UPDATE", Update)
		self:UnregisterEvent("UNIT_MODEL_CHANGED", Update)
	end
end

oUF:AddElement('Portrait', Update, Enable, Disable)
