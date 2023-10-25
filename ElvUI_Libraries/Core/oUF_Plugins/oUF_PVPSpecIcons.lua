local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF not loaded')

local Update = function(specIcon, event, unit)
	local frame = specIcon.__owner
	if not frame then return end

	if event == 'ARENA_OPPONENT_UPDATE' and unit ~= frame.unit then
		return -- another unit
	end

	local _, instanceType = IsInInstance();
	specIcon.instanceType = instanceType

	if(specIcon.PreUpdate) then specIcon:PreUpdate(event, instanceType) end

	if instanceType == 'arena' then
		local unitID = tonumber(frame.unit:match('arena(%d)') or frame:GetID() or 0)
		local specID = unitID and GetArenaOpponentSpec(unitID)
		if specID and specID > 0 then
			local _, _, _, icon = GetSpecializationInfoByID(specID);
			specIcon.Icon:SetTexture(icon)
		else
			specIcon.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	else
		local unitFactionGroup = UnitFactionGroup(frame.unit)
		if unitFactionGroup == 'Horde' then
			specIcon.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_01]])
		elseif unitFactionGroup == 'Alliance' then
			specIcon.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_02]])
		else
			specIcon.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	end

	specIcon:Show()

	if(specIcon.PostUpdate) then specIcon:PostUpdate(event, instanceType) end
end

local Enable = function(self)
	local specIcon = self.PVPSpecIcon
	if specIcon then
		specIcon.__owner = self
		specIcon:RegisterEvent("ARENA_OPPONENT_UPDATE", Update)
		specIcon:RegisterEvent("PLAYER_ENTERING_WORLD", Update)

		if oUF.isRetail then
			specIcon:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", Update)
		end

		if not specIcon.Icon then
			specIcon.Icon = specIcon:CreateTexture(nil, "OVERLAY")
			specIcon.Icon:SetAllPoints(specIcon)
			specIcon.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		end

		return true
	end
end

local Disable = function(self)
	local specIcon = self.PVPSpecIcon
	if specIcon then
		specIcon:UnregisterEvent("ARENA_OPPONENT_UPDATE")
		specIcon:UnregisterEvent("PLAYER_ENTERING_WORLD")

		if oUF.isRetail then
			specIcon:UnregisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
		end

		specIcon:Hide()
	end
end

oUF:AddElement('PVPSpecIcon', Update, Enable, Disable)
