local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "QuartzSkin"
local function SkinQuartz(self)
	local Q3 = LibStub("AceAddon-3.0"):GetAddon("Quartz3")
	if not Q3 then return end
	
	local font = AS.LSM:Fetch("font",E.db.general.font) 
	local fontSize = 12

	SkinQuartzBar = function(self, bar)
		if not self.IconBorder then
			self.IconBorder = CreateFrame("Frame", nil, self)
			self.IconBorder:CreateBackdrop()
			self.IconBorder:SetPoint("TOPLEFT",self.Icon, "TOPLEFT", 0, 0)
			self.IconBorder:SetPoint("BOTTOMRIGHT", self.Icon, "BOTTOMRIGHT", 0, 0)
		end
		if self.config.hideicon then
			self.IconBorder:Hide()
		else
			self.IconBorder:Show()
		end
		if not self.Bar.backdrop then self.Bar:CreateBackdrop() end
	end

	local template = Q3.CastBarTemplate.template
	
	template.ApplySettings_ = template.ApplySettings
	template.ApplySettings = function (self)
		self:ApplySettings_()
		self:SetWidth(self.config.w + 2 * 2)
		self:SetHeight(self.config.h + 2 * 2)

		self.Bar:SetFrameStrata("HIGH")
		self:SetFrameStrata("HIGH")
	end
	template.UNIT_SPELLCAST_NOT_INTERRUPTIBLE_ = template.UNIT_SPELLCAST_NOT_INTERRUPTIBLE
	template.UNIT_SPELLCAST_NOT_INTERRUPTIBLE = function(self, event, unit)
		self:UNIT_SPELLCAST_NOT_INTERRUPTIBLE_(event, unit)
		SkinQuartzBar(self)
	end
	template.UNIT_SPELLCAST_START_ = template.UNIT_SPELLCAST_START
	template.UNIT_SPELLCAST_START = function(self, event, unit)
		self:UNIT_SPELLCAST_START_(event, unit)
		SkinQuartzBar(self)
	end
	template.UNIT_SPELLCAST_CHANNEL_START_ = template.UNIT_SPELLCAST_CHANNEL_START
	template.UNIT_SPELLCAST_CHANNEL_START = function(self, event, unit)
		self:UNIT_SPELLCAST_CHANNEL_START_(event, unit)
		SkinQuartzBar(self)
	end

	Q3:ApplySettings()

	print("If you are experiencing performance issue's (eg. locking spellcasts, extereme lag spikes) while using the Quartz Skin. Please disable the Quartz skin.")
end

AS:RegisterSkin(name,SkinQuartz)
