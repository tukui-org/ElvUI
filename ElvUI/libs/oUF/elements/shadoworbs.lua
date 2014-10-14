if select(2, UnitClass('player')) ~= "PRIEST" then return end

local _, ns = ...
local oUF = ns.oUF or oUF

local SHADOW_ORBS_SHOW_LEVEL = SHADOW_ORBS_SHOW_LEVEL
local PRIEST_BAR_NUM_LARGE_ORBS = PRIEST_BAR_NUM_LARGE_ORBS
local PRIEST_BAR_NUM_SMALL_ORBS = PRIEST_BAR_NUM_SMALL_ORBS
local SPELL_POWER_SHADOW_ORBS = SPELL_POWER_SHADOW_ORBS
local SHADOW_ORB_MINOR_TALENT_ID = SHADOW_ORB_MINOR_TALENT_ID
local SHADOW_ORBS_SHOW_LEVEL = SHADOW_ORBS_SHOW_LEVEL

oUF.colors.shadowOrbs = {1, 1, 1}

local function Update(self, event, unit)
	local pb = self.ShadowOrbs
	if(pb.PreUpdate) then
		pb:PreUpdate()
	end
	
	local spec = GetSpecialization()
	local numOrbs = UnitPower("player", SPELL_POWER_SHADOW_ORBS)
	local totalOrbs = IsSpellKnown(SHADOW_ORB_MINOR_TALENT_ID) and 5 or 3

	for i = 1, totalOrbs do
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
		self:RegisterEvent("UNIT_POWER", Update)
		pb:Show()

		-- Here we set the number of orbs show
		if totalOrbs == 5 and not pb[4]:IsShown() then
			pb[4]:Show()
			pb[5]:Show()
		elseif totalOrbs ~= 5 and pb[4]:IsShown() then
			pb[4]:Hide()
			pb[5]:Hide()
		end		
	else
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Update)
		self:UnregisterEvent("UNIT_POWER", Update)
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
		
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Update)
		self:RegisterEvent("PLAYER_LEVEL_UP", Update)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", Update)
		self:RegisterEvent("UNIT_DISPLAYPOWER", Update)
		self:RegisterEvent("UNIT_POWER", Update)

		for i = 1, 5 do
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
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Update)
		self:UnregisterEvent("PLAYER_LEVEL_UP", Update)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Update)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Update)
		self:UnregisterEvent("UNIT_POWER", Update)
	end
end

oUF:AddElement('ShadowOrbs', Update, Enable, Disable)