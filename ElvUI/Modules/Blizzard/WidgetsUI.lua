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

local function UpdatePosition(frame, _, anchor)
	local holder = frame.containerHolder
	if holder and anchor and anchor ~= holder then
		frame:ClearAllPoints()
		frame:Point('CENTER', holder)
		frame:SetParent(holder)
	end
end

function B:BuildWidgetHolder(holderName, moverName, localeName, container, point, relativeTo, relativePoint, x, y, width, height, config)
	local holder = (holderName and CreateFrame('Frame', holderName, E.UIParent)) or container
	if width and height then holder:Size(width, height) end

	holder:Point(point, relativeTo, relativePoint, x, y)
	E:CreateMover(holder, moverName, localeName, nil, nil, nil, config)

	container.containerHolder = (holderName and holder) or _G[moverName]

	UpdatePosition(container, E.UIParent)
	hooksecurefunc(container, 'SetPoint', UpdatePosition)
end

function B:UpdateDurabilityScale()
	_G.DurabilityFrame:SetScale(E.db.general.durabilityScale or 1)
end

function B:Handle_UIWidgets()
	B:BuildWidgetHolder('TopCenterContainerHolder', 'TopCenterContainerMover', L["TopCenterWidget"], _G.UIWidgetTopCenterContainerFrame, 'TOP', E.UIParent, 'TOP', 0, -30, 50, 20, 'ALL,SOLO,WIDGETS')
	B:BuildWidgetHolder('PowerBarContainerHolder', 'PowerBarContainerMover', L["PowerBarWidget"], _G.UIWidgetPowerBarContainerFrame, 'CENTER', E.UIParent, 'TOP', 0, -75, 100, 20, 'ALL,SOLO,WIDGETS')
	B:BuildWidgetHolder('MawBuffsBelowMinimapHolder', 'MawBuffsBelowMinimapMover', L["MawBuffsWidget"], _G.MawBuffsBelowMinimapFrame, 'TOP', _G.Minimap, 'BOTTOM', 0, -25, 250, 50, 'ALL,SOLO,WIDGETS')
	B:BuildWidgetHolder('BelowMinimapContainerHolder', 'BelowMinimapContainerMover', L["BelowMinimapWidget"], _G.UIWidgetBelowMinimapContainerFrame, 'TOPRIGHT', _G.Minimap, 'BOTTOMRIGHT', 0, -16, 128, 40, 'ALL,SOLO,WIDGETS')

	B:BuildWidgetHolder('EventToastHolder', 'EventToastMover', L["EventToastWidget"], _G.EventToastManagerFrame, 'TOP', E.UIParent, 'TOP', 0, -150, 200, 20, 'ALL,SOLO,WIDGETS')
	B:BuildWidgetHolder('BossBannerHolder', 'BossBannerMover', L["BossBannerWidget"], _G.BossBanner, 'TOP', E.UIParent, 'TOP', 0, -125, 200, 20, 'ALL,SOLO,WIDGETS')

	B:BuildWidgetHolder(nil, 'GMMover', L["GM Ticket Frame"], _G.TicketStatusFrame, 'TOPLEFT', E.UIParent, 'TOPLEFT', 250, -5, nil, nil, 'ALL,GENERAL')

	_G.DurabilityFrame:SetFrameStrata('HIGH')
	local duraWidth, duraHeight = _G.DurabilityFrame:GetSize()
	B:BuildWidgetHolder('DurabilityFrameHolder', 'DurabilityFrameMover', L["Durability Frame"], _G.DurabilityFrame, 'TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300, duraWidth, duraHeight, 'ALL,GENERAL')
	B:UpdateDurabilityScale()

	-- Credits ShestakUI
	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, 'Setup', B.UIWidgetTemplateStatusBar)
	hooksecurefunc(_G.UIWidgetTemplateCaptureBarMixin, 'Setup', B.UIWidgetTemplateCaptureBar)
end
