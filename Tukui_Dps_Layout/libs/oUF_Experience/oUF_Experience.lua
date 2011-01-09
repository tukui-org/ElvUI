if TukuiCF.unitframes.enable ~= true then return end
if not oUF then return end
--[[

	Elements handled:
	 .Experience [statusbar]
	 .Experience.Rested [statusbar] (optional, must be parented to Experience)
	 .Experience.Text [fontstring] (optional)

	Booleans:
	 - noTooltip

	Functions that can be overridden from within a layout:
	 - PostUpdate(element unit, min, max)

--]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF Experience was unable to locate oUF install')

local hunterPlayer = select(2, UnitClass('player')) == 'HUNTER'

local function GetXP(unit)
	if(unit == 'pet') then
		return GetPetExperience()
	else
		return UnitXP(unit), UnitXPMax(unit)
	end
end

local function SetTooltip(self)
	local unit = self:GetParent().unit
	local min, max = GetXP(unit)

	local bars = unit == 'pet' and 6 or 20

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM', 0, -5)
	GameTooltip:AddLine(string.format('XP: %d / %d (%d%% - %d bars)', min, max, min/max * 100, bars))
	GameTooltip:AddLine(string.format('Remaining: %d (%d%% - %d bars)', max - min, (max - min) / max * 100, bars * (max - min) / max))

	if(self.rested) then
		GameTooltip:AddLine(string.format('|cff0090ffRested: +%d (%d%%)', self.rested, self.rested / max * 100))
	end

	GameTooltip:Show()
end

local function Update(self, event, owner)
	if(event == 'UNIT_PET' and owner ~= 'player') then return end

	local experience = self.Experience
	-- Conditional hiding
	if(self.unit == 'player') then
		if(UnitLevel('player') == MAX_PLAYER_LEVEL) then
			return experience:Hide()
		end
	elseif(self.unit == 'pet') then
		local _, hunterPet = HasPetUI()
		if(not self.disallowVehicleSwap and UnitHasVehicleUI('player')) then
			return experience:Hide()
		elseif(not hunterPet or (UnitLevel('pet') == UnitLevel('player'))) then
			return experience:Hide()
		end
	else
		return experience:Hide()
	end

	local unit = self.unit
	local min, max = GetXP(unit)
	experience:SetMinMaxValues(0, max)
	experience:SetValue(min)
	experience:Show()

	if(experience.Text) then
		experience.Text:SetFormattedText('%d / %d', min, max)
	end

	if(experience.Rested) then
		local rested = GetXPExhaustion()
		if(unit == 'player' and rested and rested > 0) then
			experience.Rested:SetMinMaxValues(0, max)
			experience.Rested:SetValue(math.min(min + rested, max))
			experience.rested = rested
		else
			experience.Rested:SetMinMaxValues(0, 1)
			experience.Rested:SetValue(0)
			experience.rested = nil
		end
	end

	if(experience.PostUpdate) then
		return experience:PostUpdate(unit, min, max)
	end
end

local function Enable(self, unit)
	local experience = self.Experience
	if(experience) then
		local Update = experience.Update or Update

		self:RegisterEvent('PLAYER_XP_UPDATE', Update)
		self:RegisterEvent('PLAYER_LEVEL_UP', Update)
		self:RegisterEvent('UNIT_PET', Update)

		if(experience.Rested) then
			self:RegisterEvent('UPDATE_EXHAUSTION', Update)
			experience.Rested:SetFrameLevel(1)
		end

		if(hunterPlayer) then
			self:RegisterEvent('UNIT_PET_EXPERIENCE', Update)
		end

		if(not experience.noTooltip) then
			experience:EnableMouse()
			experience:HookScript('OnLeave', GameTooltip_Hide)
			experience:HookScript('OnEnter', SetTooltip)
		end

		if(not experience:GetStatusBarTexture()) then
			experience:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

		return true
	end
end

local function Disable(self)
	local experience = self.Experience
	if(experience) then
		local Update = experience.Update or Update

		self:UnregisterEvent('PLAYER_XP_UPDATE', Update)
		self:UnregisterEvent('PLAYER_LEVEL_UP', Update)
		self:UnregisterEvent('UNIT_PET', Update)

		if(experience.Rested) then
			self:UnregisterEvent('UPDATE_EXHAUSTION', Update)
		end

		if(hunterPlayer) then
			self:UnregisterEvent('UNIT_PET_EXPERIENCE', Update)
		end
	end
end

oUF:AddElement('Experience', Update, Enable, Disable)
