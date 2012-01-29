local E, L, DF = unpack(select(2, ...)); --Engine
local S = E:GetModule('Skins')

local borderWidth = 2

local function LoadSkin()
	if E.db.skins.omen.enable ~= true then return end
	
	-- Skin Bar Texture
	Omen.UpdateBarTextureSettings_ = Omen.UpdateBarTextureSettings
	Omen.UpdateBarTextureSettings = function(self)
		for i, v in ipairs(self.Bars) do
			v.texture:SetTexture(E["media"].normTex)
		end
	end

	-- Skin Bar fonts
	Omen.UpdateBarLabelSettings_ = Omen.UpdateBarLabelSettings
	Omen.UpdateBarLabelSettings = function(self)
		self:UpdateBarLabelSettings_()
		for i, v in ipairs(self.Bars) do
			v.Text1:FontTemplate(nil, self.db.profile.Bar.FontSize)
			v.Text2:FontTemplate(nil, self.db.profile.Bar.FontSize)
			v.Text3:FontTemplate(nil, self.db.profile.Bar.FontSize)
		end
	end

	-- Skin Title Bar
	Omen.UpdateTitleBar_ = Omen.UpdateTitleBar
	Omen.UpdateTitleBar = function(self)
		Omen.db.profile.Scale = 1
		Omen.db.profile.Background.EdgeSize = 1
		Omen.db.profile.Background.BarInset = borderWidth
		Omen.db.profile.TitleBar.UseSameBG = true
		self:UpdateTitleBar_()
		self.TitleText:FontTemplate(nil, self.db.profile.TitleBar.FontSize)
		self.BarList:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT", 0, -1)
	end

	--Skin Title/Bars backgrounds
	Omen.UpdateBackdrop_ = Omen.UpdateBackdrop
	Omen.UpdateBackdrop = function(self)
		Omen.db.profile.Scale = 1
		Omen.db.profile.Background.EdgeSize = 1
		Omen.db.profile.Background.BarInset = borderWidth
		self:UpdateBackdrop_()
		self.BarList:SetTemplate("Default")
		self.Title:SetTemplate("Default", true)
		self.BarList:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT", 0, -1)
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
	Omen.db.profile.Bar.Spacing = 1
	Omen.db.profile.Background.Texture = "ElvUI Blank"

	-- Force updates
	Omen:UpdateBarTextureSettings()
	Omen:UpdateBarLabelSettings()
	Omen:UpdateTitleBar()
	Omen:UpdateBackdrop()
	Omen:ReAnchorBars()
	Omen:ResizeBars()
end

S:RegisterSkin('Omen', LoadSkin)