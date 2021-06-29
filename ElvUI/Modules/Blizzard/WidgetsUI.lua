local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local unpack = unpack
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local atlasColors = {
	['UI-Frame-Bar-Fill-Blue']				= {0.2, 0.6, 1.0},
	['UI-Frame-Bar-Fill-Red']				= {0.9, 0.2, 0.2},
	['UI-Frame-Bar-Fill-Yellow']			= {1.0, 0.6, 0.0},
	['objectivewidget-bar-fill-left']		= {0.2, 0.6, 1.0},
	['objectivewidget-bar-fill-right']		= {0.9, 0.2, 0.2},
	['EmberCourtScenario-Tracker-barfill']	= {0.9, 0.2, 0.2},
}

local function UpdateBarTexture(bar, atlas)
	if atlasColors[atlas] then
		bar:SetStatusBarTexture(E.media.normTex)
		bar:SetStatusBarColor(unpack(atlasColors[atlas]))
	end
end

local function TopCenterPosition(self, _, b)
	local holder = _G.TopCenterContainerHolder
	if b and (b ~= holder) then
		self:ClearAllPoints()
		self:Point('CENTER', holder)
		self:SetParent(holder)
	end
end

local function BelowMinimapPosition(self, _, b)
	local holder = _G.BelowMinimapContainerHolder
	if b and (b ~= holder) then
		self:ClearAllPoints()
		self:Point('CENTER', holder)
		self:SetParent(holder)
	end
end

local function PowerWidgetPosition(self, _, b)
	local holder = _G.PowerWidgetContainerHolder
	if b and (b ~= holder) then
		self:ClearAllPoints()
		self:Point('CENTER', holder)
		self:SetParent(holder)
	end
end

function B:UIWidgetTemplateStatusBar()
	local bar = self.Bar
	local atlas = bar:GetStatusBarAtlas()
	UpdateBarTexture(bar, atlas)

	if not bar.backdrop then
		bar:CreateBackdrop('Transparent')

		bar.BGLeft:SetAlpha(0)
		bar.BGRight:SetAlpha(0)
		bar.BGCenter:SetAlpha(0)
		bar.BorderLeft:SetAlpha(0)
		bar.BorderRight:SetAlpha(0)
		bar.BorderCenter:SetAlpha(0)
		bar.Spark:SetAlpha(0)
	end
end

local function PVPCaptureBar(self)
	self.LeftLine:SetAlpha(0)
	self.RightLine:SetAlpha(0)
	self.BarBackground:SetAlpha(0)
	self.Glow1:SetAlpha(0)
	self.Glow2:SetAlpha(0)
	self.Glow3:SetAlpha(0)

	self.LeftBar:SetTexture(E.media.normTex)
	self.RightBar:SetTexture(E.media.normTex)
	self.NeutralBar:SetTexture(E.media.normTex)

	self.LeftBar:SetVertexColor(0.2, 0.6, 1.0)
	self.RightBar:SetVertexColor(0.9, 0.2, 0.2)
	self.NeutralBar:SetVertexColor(0.8, 0.8, 0.8)

	if not self.backdrop then
		local x = E.PixelMode and 1 or 2

		self:CreateBackdrop()
		self.backdrop:Point('TOPLEFT', self.LeftBar, -x, x)
		self.backdrop:Point('BOTTOMRIGHT', self.RightBar, x, -x)
	end
end

local function EmberCourtCaptureBar() end
local CaptureBarSkins = {
	[2] = PVPCaptureBar,
	[252] = EmberCourtCaptureBar
}

function B:UIWidgetTemplateCaptureBar(_, widgetContainer)
	if not widgetContainer then return end
	local skinFunc = CaptureBarSkins[widgetContainer.widgetSetID]
	if skinFunc then skinFunc(self) end
end

function B:Handle_UIWidgets()
	local topCenterContainer = _G.UIWidgetTopCenterContainerFrame
	local belowMiniMapcontainer = _G.UIWidgetBelowMinimapContainerFrame
	local powerBarContainer = _G.UIWidgetPowerBarContainerFrame

	local topCenterHolder = CreateFrame('Frame', 'TopCenterContainerHolder', E.UIParent)
	topCenterHolder:Point('TOP', E.UIParent, 'TOP', 0, -30)
	topCenterHolder:Size(10, 58)

	local belowMiniMapHolder = CreateFrame('Frame', 'BelowMinimapContainerHolder', E.UIParent)
	belowMiniMapHolder:Point('TOPRIGHT', _G.Minimap, 'BOTTOMRIGHT', 0, -16)
	belowMiniMapHolder:Size(128, 40)

	local powerWidgetHolder = CreateFrame('Frame', 'PowerWidgetContainerHolder', E.UIParent)
	powerWidgetHolder:Point('CENTER', E.UIParent, 'TOP', 0, -75)
	powerWidgetHolder:Size(100, 20)

	E:CreateMover(topCenterHolder, 'TopCenterContainerMover', L["TopWidget"], nil, nil, nil,'ALL,SOLO,WIDGETS')
	E:CreateMover(belowMiniMapHolder, 'BelowMinimapContainerMover', L["BelowMinimapWidget"], nil, nil, nil,'ALL,SOLO,WIDGETS')
	E:CreateMover(powerWidgetHolder, 'PowerBarContainerMover', L["PowerBarWidget"], nil, nil, nil,'ALL,SOLO,WIDGETS')

	topCenterContainer:ClearAllPoints()
	topCenterContainer:Point('CENTER', topCenterHolder)

	belowMiniMapcontainer:ClearAllPoints()
	belowMiniMapcontainer:Point('CENTER', belowMiniMapHolder)

	powerBarContainer:ClearAllPoints()
	powerBarContainer:Point('CENTER', powerWidgetHolder)

	hooksecurefunc(topCenterContainer, 'SetPoint', TopCenterPosition)
	hooksecurefunc(belowMiniMapcontainer, 'SetPoint', BelowMinimapPosition)
	hooksecurefunc(powerBarContainer, 'SetPoint', PowerWidgetPosition)

	-- Credits ShestakUI
	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, 'Setup', B.UIWidgetTemplateStatusBar)
	hooksecurefunc(_G.UIWidgetTemplateCaptureBarMixin, 'Setup', B.UIWidgetTemplateCaptureBar)
end
