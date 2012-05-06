local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local DXE = DXE
local _G = getfenv(0)
local barSpacing = 1
local borderWidth = 2
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

local c = {}
function SkinRWIcon(addon, text, r, g, b, _, _, _, _, _, icon)
	if not E[r] then E[r] = {} end
	if not E[r][g] then E[r][g] = {} end
	if not E[r][g][b] then E[r][g][b] = {r = r, g = g, b = b} end
	if icon then text = "|T"..icon..":16:16:-3:0:256:256:20:235:20:235|t"..text end
	RaidNotice_AddMessage(RaidWarningFrame, text, E[r][g][b])
end

local function SkinDXEBar(bar)
	-- The main bar
	bar:SetTemplate("Transparent")
	bar.bg:SetTexture(nil)
	bar.border:Kill()
	bar.statusbar:SetStatusBarTexture(E["media"].normTex)
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

local function LoadSkin()
	if E.private.skins.dxe.enable ~= true then return end

	--Kill DXE's skinning
	DXE.NotifyBarTextureChanged = E.noop
	DXE.NotifyBorderChanged = E.noop
	DXE.NotifyBorderColorChanged = E.noop
	DXE.NotifyBorderEdgeSizeChanged = E.noop
	DXE.NotifyBackgroundTextureChanged = E.noop
	DXE.NotifyBackgroundInsetChanged = E.noop
	DXE.NotifyBackgroundColorChanged = E.noop

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
				hw.healthbar:SetStatusBarTexture(E["media"].normTex)
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
			bar.SetScale = E.noop
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

	DXE.Pane.timer.left:FontTemplate(nil, 18)
	DXE.Pane.timer.right:FontTemplate(nil, 12)
	
	for i=1, #movers do
		if _G[movers[i]] then
			_G[movers[i]]:SetTemplate("Transparent")
		end
	end	

	local sink = LibStub:GetLibrary("LibSink-2.0")
	if sink and sink.handlers and sink.handlers.RaidWarning then
		sink.handlers.RaidWarning = SkinRWIcon
	end	
end

S:RegisterSkin('DXE', LoadSkin)