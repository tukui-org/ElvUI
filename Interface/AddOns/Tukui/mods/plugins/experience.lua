--[[

	Elements handled:
	 .Experience [statusbar]
	 .Experience.Text [fontstring] (optional)
	 .Experience.Rested [statusbar] (optional)

	Booleans:
	 - Tooltip

	Functions that can be overridden from within a layout:
	 - PostUpdate(self, event, unit, bar, min, max)
	 - OverrideText(bar, unit, min, max)

--]]

if not TukuiUF == true then return end

local function xp(unit)
	if(unit == 'pet') then
		return GetPetExperience()
	else
		return UnitXP(unit), UnitXPMax(unit)
	end
end

local function tooltip(self)
	local unit = self:GetParent().unit
	local min, max = xp(unit)
	local bars = unit == 'pet' and 6 or 20

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 5, -5)
	GameTooltip:AddLine(format('XP: %d / %d (%d%% - %d bars)', min, max, min / max * 100, bars))
	GameTooltip:AddLine(format('Left: %d (%d%% - %d bars)', max - min, (max - min) / max * 100, bars * (max - min) / max))

	if(self.exhaustion) then
		GameTooltip:AddLine(format('|cff0090ffRested: +%d (%d%%)', self.exhaustion, self.exhaustion / max * 100))
	end

	GameTooltip:Show()
end

local function update(self)
	local bar, unit = self.Experience, self.unit
	local min, max = xp(unit)
	bar:SetMinMaxValues(0, max)
	bar:SetValue(min)
	bar.exhaustion = unit == 'player' and GetXPExhaustion()

	if(bar.Text) then
		if(bar.OverrideText) then
			bar:OverrideText(unit, min, max)
		else
			bar.Text:SetFormattedText('%d / %d', min, max)
		end
	end

	if(bar.Rested) then
		if(bar.exhaustion and bar.exhaustion > 0) then
			bar.Rested:SetMinMaxValues(0, max)
			bar.Rested:SetValue(math.min(min + bar.exhaustion, max))
		else
			bar.Rested:SetMinMaxValues(0, 1)
			bar.Rested:SetValue(0)
			bar.exhaustion = nil
		end
	end

	if(bar.PostUpdate) then
		bar.PostUpdate(self, event, unit, bar, min, max)
	end
end

local function argcheck(self)
	if(self.unit == 'player') then
		if(IsXPUserDisabled()) then
			self:DisableElement('Experience')
			self:RegisterEvent('ENABLE_XP_GAIN', function() self:EnableElement('Experience') argcheck(self) end)
		elseif(UnitLevel('player') == MAX_PLAYER_LEVEL) then
			self:DisableElement('Experience')
		else
			update(self)
		end
	elseif(self.unit == 'pet') then
		if(UnitExists('pet') and UnitLevel('pet') ~= UnitLevel('player')) then
			self.Experience:Show()
			update(self)
		else
			self.Experience:Hide()
		end
	end
end

-- Only validate the player pet on load
local function petcheck(self, event, unit)
	if(unit == 'player') then
		argcheck(self)
	end
end

local function enable(self, unit)
	local bar = self.Experience
	if(bar) then
		if(not bar:GetStatusBarTexture()) then
			bar:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

		if(unit == 'player') then
			self:RegisterEvent('PLAYER_XP_UPDATE', argcheck)
			self:RegisterEvent('PLAYER_LEVEL_UP', argcheck)

			if(bar.Rested) then
				self:RegisterEvent('UPDATE_EXHAUSTION', argcheck)
				bar.Rested:SetFrameLevel(1)
			end
		elseif(unit == 'pet' and select(2, UnitClass('player')) == 'HUNTER') then
			self:RegisterEvent('UNIT_PET_EXPERIENCE', argcheck)
			self:RegisterEvent('UNIT_PET', petcheck)

			-- Avoid rested for pet unit
			if(bar.Rested) then
				bar.Rested:Hide()

				if(bar.bg) then
					bar.bg:SetParent(bar)
				end

				if(bar.Rested:GetBackdrop()) then
					bar:SetBackdrop(bar.Rested:GetBackdrop())
					bar:SetBackdropColor(bar.Rested:GetBackdropColor())
				end
			end
		end

		if(bar.Tooltip) then
			bar:EnableMouse()
			bar:HookScript('OnLeave', GameTooltip_Hide)
			bar:HookScript('OnEnter', tooltip)
		end

		return true
	end
end

local function disable(self)
	local bar = self.Experience
	if(bar) then
		if(self.unit == 'player') then
			self:UnregisterEvent('PLAYER_XP_UPDATE', argcheck)
			self:UnregisterEvent('PLAYER_LEVEL_UP', argcheck)
			bar:Hide()

			if(bar.Rested) then
				self:UnregisterEvent('UPDATE_EXHAUSTION', argcheck)
				bar.Rested:Hide()
			end
		elseif(self.unit == 'pet') then
			self:UnregisterEvent('UNIT_PET_EXPERIENCE', argcheck)
			self:UnregisterEvent('UNIT_PET', petcheck)
			bar:Hide()
		end
	end
end

oUF:AddElement('Experience', argcheck, enable, disable)
