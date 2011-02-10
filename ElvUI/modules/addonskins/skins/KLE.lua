local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


if not Mod_AddonSkins or not IsAddOnLoaded("KLE") then return end
local KLE = KLE
local _G = getfenv(0)

--Hide a frame... FOREVER!
local function kill(frame)
	if frame.dead then return end
	frame:Hide()
	frame:HookScript("OnShow",frame.Hide)
	frame.dead = true
end

local dummy = dummy or function() end

Mod_AddonSkins:RegisterSkin("KLE",function(Skin, skin, Layout, layout, config)
	--[[ Kill KLE's skinning ]]
	KLE.NotifyBarTextureChanged = dummy
	KLE.NotifyBorderChanged = dummy
	KLE.NotifyBorderColorChanged = dummy
	KLE.NotifyBorderEdgeSizeChanged = dummy
	KLE.NotifyBackgroundTextureChanged = dummy
	KLE.NotifyBackgroundInsetChanged = dummy
	KLE.NotifyBackgroundColorChanged = dummy
	--[[ Hook Window Creation ]]
	KLE.CreateWindow_ = KLE.CreateWindow
	KLE.CreateWindow = function(self, name, width, height)
		local win = self:CreateWindow_(name, width, height)
		skin:SkinBackgroundFrame(win)
		return win
	end
	-- Skin the pane
	skin:SkinFrame(KLE.Pane)
	-- Hook Health frames (Skin & spacing)
	KLE.LayoutHealthWatchers_ = KLE.LayoutHealthWatchers
	KLE.LayoutHealthWatchers = function(self)
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
	KLE.Alerts.RefreshBars_ = KLE.Alerts.RefreshBars
	KLE.Alerts.RefreshBars = function(self)
		if self.refreshing then return end
		self.refreshing = true
		self.db.profile.BarSpacing = config.barSpacing
		self.db.profile.IconXOffset = config.barSpacing
		self:RefreshBars_()
		local i = 1
		-- This wastes so much CPU, Please KLE, give us a reference to the bar pool!
		while _G["KLEAlertBar"..i] do
			local bar = _G["KLEAlertBar"..i]
			bar:SetScale(1)
			bar:SetAlpha(1)
			bar.SetAlpha = dummy
			-- F U SCALE!
			bar.SetScale = dummy
			skin:SkinKLEBar(bar)
			i = i + 1
		end
		self.refreshing = false
	end
	
	KLE.Alerts.Dropdown_ = KLE.Alerts.Dropdown
	KLE.Alerts.Dropdown = function(self,...)
		self:Dropdown_(...)
		self:RefreshBars()
	end
	
	KLE.Alerts.CenterPopup_ = KLE.Alerts.CenterPopup
	KLE.Alerts.CenterPopup = function(self,...)
		self:CenterPopup_(...)
		self:RefreshBars()
	end
	
	KLE.Alerts.Simple_ = KLE.Alerts.Simple
	KLE.Alerts.Simple = function(self,...)
		self:Simple_(...)
		self:RefreshBars()
	end
	
	function Skin:SkinKLEBar(bar)
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
	KLE:LayoutHealthWatchers()
	KLE.Alerts:RefreshBars()
	kill(KLE.Pane.border)
	
	if not KLEDB then KLEDB = {} end
	if not KLEDB["profiles"] then KLEDB["profiles"] = {} end
	if not KLEDB["profiles"][E.myname.." - "..GetRealmName()] then KLEDB["profiles"][E.myname.." - "..GetRealmName()] = {} end
	if not KLEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"] then KLEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"] = {} end
	KLEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"]["BackgroundTexture"] = "Elvui Blank"
	KLEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"]["BarTexture"] = "Elvui Gloss"
	KLEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"]["Border"] = "None"
	KLEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"]["Font"] = "Elvui Font"
	KLEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"]["TimerFont"] = "Elvui Font"
end)

