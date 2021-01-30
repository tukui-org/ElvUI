local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local unpack = unpack
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local atlasColors = {
	["UI-Frame-Bar-Fill-Blue"]			= {0.2, 0.6, 1.0},
	["UI-Frame-Bar-Fill-Red"]			= {0.9, 0.2, 0.2},
	["UI-Frame-Bar-Fill-Yellow"]		= {1.0, 0.6, 0.0},
	["objectivewidget-bar-fill-left"]	= {0.2, 0.6, 1.0},
	["objectivewidget-bar-fill-right"]	= {0.9, 0.2, 0.2}
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
		self:Point('CENTER', holder, 'CENTER')
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

function B:UIWidgetTemplateCaptureBar()
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
		self:CreateBackdrop()
		self.backdrop:Point('TOPLEFT', self.LeftBar, -2, 2)
		self.backdrop:Point('BOTTOMRIGHT', self.RightBar, 2, -2)
	end
end

function B:Handle_UIWidgets()
	local topCenterContainer = _G.UIWidgetTopCenterContainerFrame
	local belowMiniMapcontainer = _G.UIWidgetBelowMinimapContainerFrame

	local topCenterHolder = CreateFrame('Frame', 'TopCenterContainerHolder', E.UIParent)
	topCenterHolder:Point('TOP', E.UIParent, 'TOP', 0, -30)
	topCenterHolder:Size(10, 58)

	local belowMiniMapHolder = CreateFrame('Frame', 'BelowMinimapContainerHolder', E.UIParent)
	belowMiniMapHolder:Point('TOPRIGHT', _G.Minimap, 'BOTTOMRIGHT', 0, -16)
	belowMiniMapHolder:Size(128, 40)

	E:CreateMover(topCenterHolder, 'TopCenterContainerMover', L["UIWidgetTopContainer"], nil, nil, nil,'ALL,SOLO,WIDGETS')
	E:CreateMover(belowMiniMapHolder, 'BelowMinimapContainerMover', L["UIWidgetBelowMinimapContainer"], nil, nil, nil,'ALL,SOLO,WIDGETS')

	topCenterContainer:ClearAllPoints()
	topCenterContainer:Point('CENTER', topCenterHolder)

	belowMiniMapcontainer:ClearAllPoints()
	belowMiniMapcontainer:Point('CENTER', belowMiniMapHolder, 'CENTER')

	hooksecurefunc(topCenterContainer, 'SetPoint', TopCenterPosition)
	hooksecurefunc(belowMiniMapcontainer, 'SetPoint', BelowMinimapPosition)

	-- Credits ShestakUI
	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, 'Setup', B.UIWidgetTemplateStatusBar)
	hooksecurefunc(_G.UIWidgetTemplateCaptureBarMixin, 'Setup', B.UIWidgetTemplateCaptureBar)
end
