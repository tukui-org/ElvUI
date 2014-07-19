if select(2, UnitClass('player')) ~= "PRIEST" then return end

local _, ns = ...
local oUF = ns.oUF or oUF

local SHADOW_ORBS_SHOW_LEVEL = SHADOW_ORBS_SHOW_LEVEL
local PRIEST_BAR_NUM_ORBS = PRIEST_BAR_NUM_ORBS

oUF.colors.shadowOrbs = {1, 1, 1}

local function Update(self, event, unit)
	local pb = self.ShadowOrbs
	if(pb.PreUpdate) then
		pb:PreUpdate()
	end
	
	local numOrbs = UnitPower("player", SPELL_POWER_SHADOW_ORBS)

	for i = 1, PRIEST_BAR_NUM_ORBS do
		if i <= numOrbs then
			pb[i]:SetAlpha(1)
		else
			pb[i]:SetAlpha(.2)
		end
	end
	
	local spec = GetSpecialization()
	local level = UnitLevel("player")

	if spec == SPEC_PRIEST_SHADOW and level > SHADOW_ORBS_SHOW_LEVEL then
		self:RegisterEvent("UNIT_DISPLAYPOWER", Update)
		self:RegisterEvent("UNIT_POWER_FREQUENT", Update)
		pb:Show()
	else
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Update)
		self:UnregisterEvent("UNIT_POWER_FREQUENT", Update)
		pb:Hide()
	end	
	
	if(pb.PostUpdate) then
		pb:PostUpdate()
	end	
end

local ForceUpdate = function(element)
	return Update(element.__owner, "ForceUpdate")
end

local function Enable(self, unit)
	local pb = self.ShadowOrbs
	if pb and unit == "player" then
		pb.__owner = self
		pb.ForceUpdate = ForceUpdate
		
		self:RegisterEvent("PLAYER_LEVEL_UP", Update)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", Update)
		self:RegisterEvent("UNIT_DISPLAYPOWER", Update)
		self:RegisterEvent("UNIT_POWER_FREQUENT", Update)

		for i = 1, 3 do
			if not pb[i]:GetStatusBarTexture() then
				pb[i]:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end
			
			pb[i]:SetStatusBarColor(unpack(oUF.colors.shadowOrbs))
			pb[i]:SetFrameLevel(pb:GetFrameLevel() + 1)
			pb[i]:GetStatusBarTexture():SetHorizTile(false)
		end
		
		return true
	end
end

local function Disable(self)
	if self.ShadowOrbs then
		self:UnregisterEvent("PLAYER_LEVEL_UP", Update)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Update)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Update)
		self:UnregisterEvent("UNIT_POWER_FREQUENT", Update)
	end
end

oUF:AddElement('ShadowOrbs', Update, Enable, Disable)