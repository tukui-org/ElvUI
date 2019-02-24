local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF not loaded')


local Update = function(self, event, unit)
	if event == 'ARENA_OPPONENT_UPDATE' and unit ~= self.unit then return; end
	local specIcon = self.PVPSpecIcon

	local _, instanceType = IsInInstance();
	specIcon.instanceType = instanceType

	if(specIcon.PreUpdate) then specIcon:PreUpdate(event) end

	if instanceType == 'arena' then
		local numOpps = GetNumArenaOpponentSpecs()
		local ID = self.unit:match('arena(%d)') or self:GetID() or 0
		local specID = GetArenaOpponentSpec(tonumber(ID))
		if specID and specID > 0 then
			local _, _, _, icon = GetSpecializationInfoByID(specID);
			specIcon.Icon:SetTexture(icon)
		else
			specIcon.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	else
		local unitFactionGroup = UnitFactionGroup(self.unit)
		if unitFactionGroup == "Horde" then
			specIcon.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_01]])
		elseif unitFactionGroup == 'Alliance' then
			specIcon.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_02]])
		else
			specIcon.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	end

	if(specIcon.PostUpdate) then specIcon:PostUpdate(event) end
end

local Enable = function(self)
	local specIcon = self.PVPSpecIcon
	if specIcon then
		self:RegisterEvent("ARENA_OPPONENT_UPDATE", Update, true)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Update, true)

		if not specIcon.Icon then
			specIcon.Icon = specIcon:CreateTexture(nil, "OVERLAY")
			specIcon.Icon:SetAllPoints(specIcon)
			specIcon.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		end
		specIcon:Show()
		return true
	end
end

local Disable = function(self)
	local specIcon = self.PVPSpecIcon
	if specIcon then
		self:UnregisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", Update)
		self:UnregisterEvent("ARENA_OPPONENT_UPDATE", Update)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Update)
		specIcon:Hide()
	end
end

oUF:AddElement('PVPSpecIcon', Update, Enable, Disable)
