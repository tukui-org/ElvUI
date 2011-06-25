local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


if not IsAddOnLoaded("Omen") or not C["skin"].omen == true then return end

local Omen = LibStub("AceAddon-3.0"):GetAddon("Omen")
local borderWidth = E.Scale(2, 2)

-- Skin Bar Texture
Omen.UpdateBarTextureSettings_ = Omen.UpdateBarTextureSettings
Omen.UpdateBarTextureSettings = function(self)
	for i, v in ipairs(self.Bars) do
		v.texture:SetTexture(C["media"].normTex)
	end
end

-- Skin Bar fonts
Omen.UpdateBarLabelSettings_ = Omen.UpdateBarLabelSettings
Omen.UpdateBarLabelSettings = function(self)
	self:UpdateBarLabelSettings_()
	for i, v in ipairs(self.Bars) do
		v.Text1:SetFont(C["media"].font, self.db.profile.Bar.FontSize)
		v.Text2:SetFont(C["media"].font, self.db.profile.Bar.FontSize)
		v.Text3:SetFont(C["media"].font, self.db.profile.Bar.FontSize)
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
	self.TitleText:SetFont(C["media"].font, self.db.profile.TitleBar.FontSize)
	self.BarList:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT", 0, -1)
end

--Skin Title/Bars backgrounds
Omen.UpdateBackdrop_ = Omen.UpdateBackdrop
Omen.UpdateBackdrop = function(self)
	Omen.db.profile.Scale = 1
	Omen.db.profile.Background.EdgeSize = 1
	Omen.db.profile.Background.BarInset = borderWidth
	self:UpdateBackdrop_()
	self.BarList:SetTemplate("Transparent")
	self.Title:SetTemplate("Transparent")
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
Omen.db.profile.Bar.Texture = "ElvUI Norm"
Omen.db.profile.Bar.Font = "ElvUI Font"
Omen.db.profile.Bar.Height = 18
Omen.db.profile.TitleBar.Font = "ElvUI Font"
Omen.db.profile.Background.Texture = "ElvUI Blank"

-- Force updates
Omen:UpdateBarTextureSettings()
Omen:UpdateBarLabelSettings()
Omen:UpdateTitleBar()
Omen:UpdateBackdrop()
Omen:ReAnchorBars()
Omen:ResizeBars()

if C["skin"].embedright == "Omen" then
	local Omen_Skin = CreateFrame("Frame")
	Omen_Skin:RegisterEvent("PLAYER_ENTERING_WORLD")
	Omen_Skin:SetScript("OnEvent", function(self)
		self:UnregisterAllEvents()
		self = nil
		
		Omen.UpdateTitleBar = function() end
		OmenTitle:Kill()
		OmenBarList:ClearAllPoints()
		OmenBarList:SetAllPoints(ChatRPlaceHolder)
		Omen.db.profile.FrameStrata = "3-MEDIUM"
	end)
	
	if ChatRBGTab then
		local button = CreateFrame('Button', 'OmenToggleSwitch', ChatRBGTab)
		button:Width(90)
		button:Height(ChatRBGTab:GetHeight() - 4)
		button:Point("RIGHT", ChatRBGTab, "RIGHT", -2, 0)
		
		button.tex = button:CreateTexture(nil, 'OVERLAY')
		button.tex:SetTexture([[Interface\AddOns\ElvUI\media\textures\vehicleexit.tga]])
		button.tex:Point('TOPRIGHT', -2, -2)
		button.tex:Height(button:GetHeight() - 4)
		button.tex:Width(16)
		
		button:FontString(nil, C["media"].font, 12, 'THINOUTLINE')
		button.text:SetPoint('RIGHT', button.tex, 'LEFT')
		button.text:SetTextColor(unpack(C["media"].valuecolor))
		
		button:SetScript('OnEnter', function(self) button.text:SetText(L.addons_toggle..' Omen') end)
		button:SetScript('OnLeave', function(self) self.tex:Point('TOPRIGHT', -2, -2); button.text:SetText(nil) end)
		button:SetScript('OnMouseDown', function(self) self.tex:Point('TOPRIGHT', -4, -4) end)
		button:SetScript('OnMouseUp', function(self) self.tex:Point('TOPRIGHT', -2, -2) end)
		button:SetScript('OnClick', function(self) ToggleFrame(OmenBarList) end)
	end		
	
	if C["skin"].embedrighttoggle == true then
		ChatRBG:HookScript("OnShow", function() OmenBarList:Hide() end)
		ChatRBG:HookScript("OnHide", function() OmenBarList:Show() end)
	end		
end