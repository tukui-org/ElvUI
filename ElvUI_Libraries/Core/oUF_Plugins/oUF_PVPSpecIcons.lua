local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF not loaded')

local Update = function(frame, event, unit)
	if (frame.isForced and event ~= 'ElvUI_UpdateAllElements') or (unit and unit ~= frame.unit) then return end

	local element = frame.PVPSpecIcon
	local _, instanceType = IsInInstance()
	element.instanceType = instanceType

	if(element.PreUpdate) then element:PreUpdate(event, instanceType) end

	if instanceType == 'arena' then
		local unitID = tonumber(frame.unit:match('arena(%d)') or frame:GetID() or 0)
		local specID = unitID and GetArenaOpponentSpec(unitID)
		if specID and specID > 0 then
			local _, _, _, icon = GetSpecializationInfoByID(specID);
			element.Icon:SetTexture(icon)
		else
			element.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	else
		local unitFactionGroup = UnitFactionGroup(frame.unit)
		if unitFactionGroup == 'Horde' then
			element.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_01]])
		elseif unitFactionGroup == 'Alliance' then
			element.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_02]])
		else
			element.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	end

	element:Show()

	if(element.PostUpdate) then element:PostUpdate(event, instanceType) end
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self)
	local element = self.PVPSpecIcon
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if not element.Icon then
			element.Icon = element:CreateTexture(nil, "OVERLAY")
			element.Icon:SetAllPoints(element)
			element.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		end

		self:RegisterEvent("ARENA_OPPONENT_UPDATE", Update)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Update, true)

		if oUF.isRetail then
			self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", Update, true)
		end

		return true
	end
end

local Disable = function(self)
	local element = self.PVPSpecIcon
	if element then
		self:UnregisterEvent("ARENA_OPPONENT_UPDATE", Update)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Update)

		if oUF.isRetail then
			self:UnregisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", Update)
		end

		element:Hide()
	end
end

oUF:AddElement('PVPSpecIcon', Update, Enable, Disable)
