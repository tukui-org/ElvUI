local parent, ns = ...
local oUF = ns.oUF

do
	local Update = function(self, event)
		if(IsResting()) then
			self.Resting:Show()
		else
			self.Resting:Hide()
		end
	end

	local Enable = function(self, unit)
		if(self.Resting and unit == 'player') then
			self:RegisterEvent("PLAYER_UPDATE_RESTING", Update)

			if(self.Resting:IsObjectType"Texture" and not self.Resting:GetTexture()) then
				self.Resting:SetTexture[[Interface\CharacterFrame\UI-StateIcon]]
				self.Resting:SetTexCoord(0, .5, 0, .421875)
			end

			return true
		end
	end

	local Disable = function(self)
		if(self.Resting) then
			self:UnregisterEvent("PLAYER_UPDATE_RESTING", Update)
		end
	end

	oUF:AddElement('Resting', Update, Enable, Disable)
end

do
	local Update = function(self, event)
		if(UnitAffectingCombat"player") then
			self.Combat:Show()
		else
			self.Combat:Hide()
		end
	end

	local Enable = function(self, unit)
		if(self.Combat and unit == 'player') then
			self:RegisterEvent("PLAYER_REGEN_DISABLED", Update)
			self:RegisterEvent("PLAYER_REGEN_ENABLED", Update)

			if(self.Combat:IsObjectType"Texture" and not self.Combat:GetTexture()) then
				self.Combat:SetTexture[[Interface\CharacterFrame\UI-StateIcon]]
				self.Combat:SetTexCoord(.5, 1, 0, .5)
			end

			return true
		end
	end

	local Disable = function(self)
		if(self.Combat) then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED", Update)
			self:UnregisterEvent("PLAYER_REGEN_ENABLED", Update)
		end
	end

	oUF:AddElement('Combat', Update, Enable, Disable)
end
