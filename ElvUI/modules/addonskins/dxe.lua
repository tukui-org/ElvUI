local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not IsAddOnLoaded("DXE") or not C["skin"].dxe == true or not DXE then return end

local DXE = DXE
local _G = getfenv(0)
local barSpacing = E.Scale(1, 1)
local borderWidth = E.Scale(2, 2)
local buttonZoom = {.09,.91,.09,.91}
local movers = {
	"DXEAlertsCenterStackAnchor",
	"DXEAlertsWarningStackAnchor",
	"DXEDistributorStackAnchor",
	"DXEAlertsTopStackAnchor",
	"DXEArrowsAnchor1",
	"DXEArrowsAnchor2",
	"DXEArrowsAnchor3",
}

local function SkinDXEBar(bar)
	-- The main bar
	bar:SetTemplate("Transparent")
	bar.bg:SetTexture(nil)
	bar.border:Kill()
	bar.statusbar:SetStatusBarTexture(C["media"].normTex)
	bar.statusbar:ClearAllPoints()
	bar.statusbar:SetPoint("TOPLEFT",borderWidth, -borderWidth)
	bar.statusbar:SetPoint("BOTTOMRIGHT",-borderWidth, borderWidth)
	
	-- Right Icon
	bar.righticon:SetTemplate("Default")
	bar.righticon.border:Kill()
	bar.righticon.t:SetTexCoord(unpack(buttonZoom))
	bar.righticon.t:ClearAllPoints()
	bar.righticon.t:SetPoint("TOPLEFT", borderWidth, -borderWidth)
	bar.righticon.t:SetPoint("BOTTOMRIGHT", -borderWidth, borderWidth)
	bar.righticon.t:SetDrawLayer("ARTWORK")
	
	-- Left Icon
	bar.lefticon:SetTemplate("Default")
	bar.lefticon.border:Kill()
	bar.lefticon.t:SetTexCoord(unpack(buttonZoom))
	bar.lefticon.t:ClearAllPoints()
	bar.lefticon.t:SetPoint("TOPLEFT",borderWidth, -borderWidth)
	bar.lefticon.t:SetPoint("BOTTOMRIGHT",-borderWidth, borderWidth)
	bar.lefticon.t:SetDrawLayer("ARTWORK")
end

--Kill DXE's skinning
DXE.NotifyBarTextureChanged = E.dummy
DXE.NotifyBorderChanged = E.dummy
DXE.NotifyBorderColorChanged = E.dummy
DXE.NotifyBorderEdgeSizeChanged = E.dummy
DXE.NotifyBackgroundTextureChanged = E.dummy
DXE.NotifyBackgroundInsetChanged = E.dummy
DXE.NotifyBackgroundColorChanged = E.dummy

--Hook Window Creation
DXE.CreateWindow_ = DXE.CreateWindow
DXE.CreateWindow = function(self, name, width, height)
	local win = self:CreateWindow_(name, width, height)
	win:SetTemplate("Transparent")
	return win
end

-- Skin the pane
DXE.Pane:SetTemplate("Transparent")

-- Hook Health frames (Skin & spacing)
DXE.LayoutHealthWatchers_ = DXE.LayoutHealthWatchers
DXE.LayoutHealthWatchers = function(self)
	self.db.profile.Pane.BarSpacing = barSpacing
	self:LayoutHealthWatchers_()
	for i,hw in ipairs(self.HW) do
		if hw:IsShown() then
			hw:SetTemplate("Transparent")
			hw.border:Kill()
			hw.healthbar:SetStatusBarTexture(C["media"].normTex)
		end
	end
end

DXE.Alerts.RefreshBars_ = DXE.Alerts.RefreshBars
DXE.Alerts.RefreshBars = function(self)
	if self.refreshing then return end
	self.refreshing = true
	self.db.profile.BarSpacing = barSpacing
	self.db.profile.IconXOffset = barSpacing
	self:RefreshBars_()
	local i = 1
	while _G["DXEAlertBar"..i] do
		local bar = _G["DXEAlertBar"..i]
		bar:SetScale(1)
		bar.SetScale = E.dummy
		SkinDXEBar(bar)
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

-- Force some updates
DXE:LayoutHealthWatchers()
DXE.Alerts:RefreshBars()
DXE.Pane.border:Kill()

--Force some default profile options
if not DXEDB then DXEDB = {} end
if not DXEDB["profiles"] then DXEDB["profiles"] = {} end
if not DXEDB["profiles"][E.myname.." - "..GetRealmName()] then DXEDB["profiles"][E.myname.." - "..E.myrealm] = {} end
if not DXEDB["profiles"][E.myname.." - "..GetRealmName()]["Globals"] then DXEDB["profiles"][E.myname.." - "..E.myrealm]["Globals"] = {} end
DXEDB["profiles"][E.myname.." - "..E.myrealm]["Globals"]["BackgroundTexture"] = "ElvUI Blank"
DXEDB["profiles"][E.myname.." - "..E.myrealm]["Globals"]["BarTexture"] = "ElvUI Norm"
DXEDB["profiles"][E.myname.." - "..E.myrealm]["Globals"]["Border"] = "None"
DXEDB["profiles"][E.myname.." - "..E.myrealm]["Globals"]["Font"] = "ElvUI Font"
DXEDB["profiles"][E.myname.." - "..E.myrealm]["Globals"]["TimerFont"] = "ElvUI Font"

local function PositionDXEAnchor()
	if not DXEAlertsTopStackAnchor then return end
	DXEAlertsTopStackAnchor:ClearAllPoints()
	if E.CheckAddOnShown() == true then
		if C["chat"].showbackdrop == true and E.ChatRightShown == true then
			DXEAlertsTopStackAnchor:Point("TOP", ChatRBGDummy, "TOP", 14, 4)	
		else
			DXEAlertsTopStackAnchor:Point("TOP", ChatRBGDummy, "TOP", 14, -28)
		end	
	else
		DXEAlertsTopStackAnchor:Point("BOTTOMRIGHT", E.UIParent, "BOTTOMRIGHT", -49, 25)		
	end
end

local c = {}
function SkinRWIcon(addon, text, r, g, b, _, _, _, _, _, icon)
	if not c[r] then c[r] = {} end
	if not c[r][g] then c[r][g] = {} end
	if not c[r][g][b] then c[r][g][b] = {r = r, g = g, b = b} end
	if icon then text = "|T"..icon..":16:16:-3:0:256:256:20:235:20:235|t"..text end
	RaidNotice_AddMessage(RaidWarningFrame, text, c[r][g][b])
end
	
--Hook bar to chatframe, rest of this is handled inside chat.lua and chatanimation.lua
local DXE_Skin = CreateFrame("Frame")
DXE_Skin:RegisterEvent("PLAYER_ENTERING_WORLD")
DXE_Skin:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent(event)
		self = nil
		
		--DXE doesn't like the pane timer font to listen for some reason
		DXE.Pane.timer.left:SetFont(C["media"].font, 18)
		DXE.Pane.timer.right:SetFont(C["media"].font, 12)
		
		for i=1, #movers do
			if _G[movers[i]] then
				_G[movers[i]]:SetTemplate("Transparent")
			end
		end
		
		if C["skin"].hookdxeright == true then
			PositionDXEAnchor()
			
			if Skada and Skada:GetWindows() and Skada:GetWindows()[1] and C["skin"].embedright == "Skada" then
				Skada:GetWindows()[1].bargroup:HookScript("OnShow", function() PositionDXEAnchor() end)
				Skada:GetWindows()[1].bargroup:HookScript("OnHide", function() PositionDXEAnchor() end)
			elseif Recount_MainWindow and C["skin"].embedright == "Recount" then
				Recount_MainWindow:HookScript("OnShow", function() PositionDXEAnchor() end)
				Recount_MainWindow:HookScript("OnHide", function() PositionDXEAnchor() end)
			elseif OmenAnchor and C["skin"].embedright == "Omen" then
				OmenAnchor:HookScript("OnShow", function() PositionDXEAnchor() end)
				OmenAnchor:HookScript("OnHide", function() PositionDXEAnchor() end)		
			end	
		end
		local sink = LibStub:GetLibrary("LibSink-2.0")
		if sink and sink.handlers and sink.handlers.RaidWarning then
			sink.handlers.RaidWarning = SkinRWIcon
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		PositionDXEAnchor()
	elseif event == "PLAYER_REGEN_ENABLED" then
		PositionDXEAnchor()
	end
end)

if C["skin"].hookdxeright == true then
	DXE_Skin:RegisterEvent("PLAYER_REGEN_ENABLED")
	DXE_Skin:RegisterEvent("PLAYER_REGEN_DISABLED")

	ChatRBG:HookScript("OnHide", function(self)
		PositionDXEAnchor()
	end)
	
	ChatRBG:HookScript("OnShow", function(self)
		PositionDXEAnchor()
	end)	
end