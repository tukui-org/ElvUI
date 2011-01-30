--[[
	Omen skin by Darth Android / Telroth - Black Dragonflight
	
	Skins Omen to look like TelUI.
	
	Todo:
	 + Reorganize to allow skin subclass overrides
	 + Reorganize to allow layout subclass overrides
	
	File version v15.37
	(C)2010 Darth Android / Telroth - Black Dragonflight
]]

local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


if not Mod_AddonSkins or not IsAddOnLoaded("Omen") or not C["skin"].omen == true then return end

local Omen = LibStub("AceAddon-3.0"):GetAddon("Omen")

Mod_AddonSkins:RegisterSkin("Omen",function(Skin, skin, Layout, layout, config)
	
	-- Skin Bar Texture
	Omen.UpdateBarTextureSettings_ = Omen.UpdateBarTextureSettings
	Omen.UpdateBarTextureSettings = function(self)
		for i, v in ipairs(self.Bars) do
			v.texture:SetTexture(config.normTexture)
		end
	end

	-- Skin Bar fonts
	Omen.UpdateBarLabelSettings_ = Omen.UpdateBarLabelSettings
	Omen.UpdateBarLabelSettings = function(self)
		self:UpdateBarLabelSettings_()
		for i, v in ipairs(self.Bars) do
			v.Text1:SetFont(config.font,self.db.profile.Bar.FontSize)
			v.Text2:SetFont(config.font,self.db.profile.Bar.FontSize)
			v.Text3:SetFont(config.font,self.db.profile.Bar.FontSize)
		end
	end
	-- Skin Title Bar
	Omen.UpdateTitleBar_ = Omen.UpdateTitleBar
	Omen.UpdateTitleBar = function(self)
		Omen.db.profile.Scale = 1
		Omen.db.profile.Background.EdgeSize = 1
		Omen.db.profile.Background.BarInset = config.borderWidth
		Omen.db.profile.TitleBar.UseSameBG = true
		self:UpdateTitleBar_()
		self.TitleText:SetFont(config.font,self.db.profile.TitleBar.FontSize)
		self.BarList:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT",0,-1)
	end
	--Skin Title/Bars backgrounds
	Omen.UpdateBackdrop_ = Omen.UpdateBackdrop
	Omen.UpdateBackdrop = function(self)
		Omen.db.profile.Scale = 1
		Omen.db.profile.Background.EdgeSize = 1
		Omen.db.profile.Background.BarInset = config.borderWidth
		self:UpdateBackdrop_()
		skin:SkinBackgroundFrame(self.BarList)
		skin:SkinBackgroundFrame(self.Title)
		self.BarList:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT",0,-1)
	end
	-- Hook bar creation to apply settings
	local omen_mt = getmetatable(Omen.Bars)
	local oldidx = omen_mt.__index
	omen_mt.__index = function(self, barID)
	    local bar = oldidx(self, barID)
	    Omen:UpdateBarTextureSettings()
	    Omen:UpdateBarLabelSettings()
	    return bar
	end
	-- Option Overrides
	Omen.db.profile.Bar.Spacing = 2
	-- Force updates
	Omen:UpdateBarTextureSettings()
	Omen:UpdateBarLabelSettings()
	Omen:UpdateTitleBar()
	Omen:UpdateBackdrop()
	Omen:ReAnchorBars()
	Omen:ResizeBars()

end)

