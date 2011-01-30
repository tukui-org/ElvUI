--[[
	DXE skin by Darth Android / Telroth - Black Dragonflight
	
	Skins DXE to look like TelUI.
	
	File version v37.37
	(C)2010 Darth Android / Telroth - Black Dragonflight
]]
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


if not Mod_AddonSkins or not IsAddOnLoaded("DXE") or not C["skin"].dxe == true then return end
local DXE = DXE
local _G = getfenv(0)

--Hide a frame... FOREVER!
local function kill(frame)
	if frame.dead then return end
	frame:Hide()
	frame:HookScript("OnShow",frame.Hide)
	frame.dead = true
end

local dummy = dummy or function() end

Mod_AddonSkins:RegisterSkin("DXE",function(Skin, skin, Layout, layout, config)
	--[[ Kill DXE's skinning ]]
	DXE.NotifyBarTextureChanged = dummy
	DXE.NotifyBorderChanged = dummy
	DXE.NotifyBorderColorChanged = dummy
	DXE.NotifyBorderEdgeSizeChanged = dummy
	DXE.NotifyBackgroundTextureChanged = dummy
	DXE.NotifyBackgroundInsetChanged = dummy
	DXE.NotifyBackgroundColorChanged = dummy
	--[[ Hook Window Creation ]]
	DXE.CreateWindow_ = DXE.CreateWindow
	DXE.CreateWindow = function(self, name, width, height)
		local win = self:CreateWindow_(name, width, height)
		skin:SkinBackgroundFrame(win)
		return win
	end
	-- Skin the pane
	skin:SkinFrame(DXE.Pane)
	-- Hook Health frames (Skin & spacing)
	DXE.LayoutHealthWatchers_ = DXE.LayoutHealthWatchers
	DXE.LayoutHealthWatchers = function(self)
		self.db.profile.Pane.BarSpacing = config.barSpacing
		self:LayoutHealthWatchers_()
		for i,hw in ipairs(self.HW) do
			if hw:IsShown() then
				skin:SkinFrame(hw)
				kill(hw.border)
				hw.healthbar:SetStatusBarTexture(config.normTexture)
			end
		end
	end
	DXE.Alerts.RefreshBars_ = DXE.Alerts.RefreshBars
	DXE.Alerts.RefreshBars = function(self)
		if self.refreshing then return end
		self.refreshing = true
		self.db.profile.BarSpacing = config.barSpacing
		self.db.profile.IconXOffset = config.barSpacing
		self:RefreshBars_()
		local i = 1
		-- This wastes so much CPU, Please DXE, give us a reference to the bar pool!
		while _G["DXEAlertBar"..i] do
			local bar = _G["DXEAlertBar"..i]
			bar:SetScale(1)
			bar:SetAlpha(1)
			bar.SetAlpha = dummy
			-- F U SCALE!
			bar.SetScale = dummy
			skin:SkinDXEBar(bar)
			i = i + 1
		end
		self.refreshing = false
	end
	
	DXE.Alerts.Dropdown_ = DXE.Alerts.Dropdown
	DXE.Alerts.Dropdown = function(self,...)
		self:Dropdown_(...)
		self:RefreshBars()
	end
	
	DXE.Alerts.CenterPopup_ = DXE.Alerts.CenterPopup
	DXE.Alerts.CenterPopup = function(self,...)
		self:CenterPopup_(...)
		self:RefreshBars()
	end
	
	DXE.Alerts.Simple_ = DXE.Alerts.Simple
	DXE.Alerts.Simple = function(self,...)
		self:Simple_(...)
		self:RefreshBars()
	end
	
	function Skin:SkinDXEBar(bar)
		-- The main bar
		self:SkinFrame(bar)
		bar.bg:SetTexture(nil)
		kill(bar.border)
		bar.statusbar:SetStatusBarTexture(config.normTexture)
		bar.statusbar:ClearAllPoints()
		bar.statusbar:SetPoint("TOPLEFT",config.borderWidth, -config.borderWidth)
		bar.statusbar:SetPoint("BOTTOMRIGHT",-config.borderWidth, config.borderWidth)
		-- Right Icon
		self:SkinFrame(bar.righticon)
		kill(bar.righticon.border)
		bar.righticon.t:SetTexCoord(unpack(config.buttonZoom))
		bar.righticon.t:ClearAllPoints()
		bar.righticon.t:SetPoint("TOPLEFT",config.borderWidth, -config.borderWidth)
		bar.righticon.t:SetPoint("BOTTOMRIGHT",-config.borderWidth, config.borderWidth)
		bar.righticon.t:SetDrawLayer("ARTWORK")
		-- Left Icon
		self:SkinFrame(bar.lefticon)
		kill(bar.lefticon.border)
		bar.lefticon.t:SetTexCoord(unpack(config.buttonZoom))
		bar.lefticon.t:ClearAllPoints()
		bar.lefticon.t:SetPoint("TOPLEFT",config.borderWidth, -config.borderWidth)
		bar.lefticon.t:SetPoint("BOTTOMRIGHT",-config.borderWidth, config.borderWidth)
		bar.lefticon.t:SetDrawLayer("ARTWORK")
	end
	
	-- Force some updates
	DXE:LayoutHealthWatchers()
	DXE.Alerts:RefreshBars()
	kill(DXE.Pane.border)
	
	if not DXEDB then DXEDB = {} end
	if not DXEDB["profiles"] then DXEDB["profiles"] = {} end
	if not DXEDB["profiles"][E.myname.." - "..GetRealmName()] then DXEDB["profiles"][E.myname.." - "..GetRealmName()] = {} end
	if not DXEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"] then DXEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"] = {} end
	DXEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"]["BackgroundTexture"] = "Elvui Blank"
	DXEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"]["BarTexture"] = "Elvui Gloss"
	DXEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"]["Border"] = "None"
	DXEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"]["Font"] = "Elvui Font"
	DXEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"]["TimerFont"] = "Elvui Font"
end)

