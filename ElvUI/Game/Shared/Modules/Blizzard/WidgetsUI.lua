local E, L, V, P, G = unpack(ElvUI)
local BL = E:GetModule('Blizzard')
local NP = E:GetModule('NamePlates')

local _G = _G
local next = next
local pairs = pairs
local strmatch = strmatch
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local ignoreWidget = {
	[283] = 3463 -- Cosmic Energy
}

function BL:UIWidgetTemplateStatusBar()
	local forbidden = self:IsForbidden()
	local bar = self.Bar

	if forbidden and bar then
		if bar.tooltip then bar.tooltip = nil end -- EmbeddedItemTooltip is tainted just block the tooltip
		return
	elseif forbidden or (self.widgetID == ignoreWidget[self.widgetSetID]) or not bar then
		return -- we don't want to handle these widgets
	end

	bar.BGLeft:SetAlpha(0)
	bar.BGRight:SetAlpha(0)
	bar.BGCenter:SetAlpha(0)
	bar.BorderLeft:SetAlpha(0)
	bar.BorderRight:SetAlpha(0)
	bar.BorderCenter:SetAlpha(0)
	bar.Spark:SetAlpha(0)

	if not bar.backdrop then
		bar:CreateBackdrop('Transparent')

		if NP.Initialized and strmatch(self:GetDebugName(), 'NamePlate') then
			self:SetIgnoreParentScale(true)
			self:SetIgnoreParentAlpha(true)
		else
			self:SetScale(0.99) -- scaling for Simpy
		end

		if self.Label then -- title
			self.Label:FontTemplate(nil, nil, 'SHADOW')
		end

		if bar.Label then -- percent text
			bar.Label:FontTemplate(nil, nil, 'SHADOW')
		end
	end
end

function BL:BelowMinimap_CaptureBar()
	if not self.LeftLine or not self.LeftBar then return end

	self.LeftLine:SetAlpha(0)
	self.RightLine:SetAlpha(0)
	self.BarBackground:SetAlpha(0)
	self.SparkNeutral:SetAlpha(0)

	self.GlowPulseAnim:Stop()
	self.Glow1:SetAlpha(0)
	self.Glow2:SetAlpha(0)
	self.Glow3:SetAlpha(0)

	self.LeftBar:SetVertexColor(0.2, 0.6, 1.0)
	self.RightBar:SetVertexColor(0.9, 0.2, 0.2)
	self.NeutralBar:SetVertexColor(0.8, 0.8, 0.8)

	self.LeftBar:SetTexture(E.media.normTex)
	self.RightBar:SetTexture(E.media.normTex)
	self.NeutralBar:SetTexture(E.media.normTex)

	if not self.backdrop then
		self:CreateBackdrop()

		local x = E.PixelMode and 1 or 2
		self.backdrop:Point('TOPLEFT', self.LeftBar, -x, x)
		self.backdrop:Point('BOTTOMRIGHT', self.RightBar, x, -x)
	else
		self.backdrop:OffsetFrameLevel(-1, self)
	end
end

function BL:BelowMinimap_EmberCourt() end

local captureBarSkins = {
	[2] = BL.BelowMinimap_CaptureBar,
	[252] = BL.BelowMinimap_EmberCourt
}

function BL:BelowMinimap_UpdateBar(_, container)
	if self:IsForbidden() or not container then return end

	local skinFunc = captureBarSkins[container.widgetSetID]
	if skinFunc then skinFunc(self) end
end

function BL:UIWidgetTemplateCaptureBar(widgetInfo, container)
	if container == _G.UIWidgetBelowMinimapContainerFrame and container.ProcessWidget then
		return -- handled by ProcessWidget hook instead
	end

	BL.BelowMinimap_UpdateBar(self, widgetInfo, container)
end

function BL:BelowMinimap_ProcessWidget(widgetID)
	if not self or not self.widgetFrames then return end

	if widgetID then
		local bar = self.widgetFrames[widgetID]
		if bar then -- excuse me?
			BL.BelowMinimap_UpdateBar(bar, nil, self)
		end
	else -- we reloading?
		for _, bar in next, self.widgetFrames do
			BL.BelowMinimap_UpdateBar(bar, nil, self)
		end
	end
end

local function UpdatePosition(frame, _, anchor)
	local holder = frame.containerHolder
	if holder and anchor ~= holder then
		frame:ClearAllPoints()
		frame:Point(frame.containerPoint, holder)
	end
end

function BL:BuildWidgetHolder(holderName, moverName, moverPoint, localeName, container, point, relativeTo, relativePoint, x, y, width, height, config)
	local holder = (holderName and CreateFrame('Frame', holderName, E.UIParent)) or container
	if width and height then holder:Size(width, height) end

	holder:Point(point, relativeTo, relativePoint, x, y)
	E:CreateMover(holder, moverName, localeName, nil, nil, nil, config)

	container.containerHolder = (holderName and holder) or _G[moverName]
	container.containerPoint = moverPoint

	UpdatePosition(container, E.UIParent)
	hooksecurefunc(container, 'SetPoint', UpdatePosition)
end

function BL:UpdateDurabilityScale()
	_G.DurabilityFrame:SetScale(E.db.general.durabilityScale or 1)
end

function BL:HandleWidgets()
	local BelowMinimapContainer = _G.UIWidgetBelowMinimapContainerFrame
	BL:BuildWidgetHolder('TopCenterContainerHolder', 'TopCenterContainerMover', 'CENTER', L["TopCenterWidget"], _G.UIWidgetTopCenterContainerFrame, 'TOP', E.UIParent, 'TOP', 0, -30, 125, 20, 'ALL,WIDGETS')
	BL:BuildWidgetHolder('BelowMinimapContainerHolder', 'BelowMinimapContainerMover', 'CENTER', L["BelowMinimapWidget"], BelowMinimapContainer, 'TOPRIGHT', _G.Minimap, 'BOTTOMRIGHT', 0, -16, 150, 30, 'ALL,WIDGETS')
	BL:BuildWidgetHolder(nil, 'GMMover', 'TOP', L["GM Ticket Frame"], _G.TicketStatusFrame, 'TOPLEFT', E.UIParent, 'TOPLEFT', 250, -5, nil, nil, 'ALL,GENERAL')

	if E.Retail then
		BL:BuildWidgetHolder('PowerBarContainerHolder', 'PowerBarContainerMover', 'CENTER', L["PowerBarWidget"], _G.UIWidgetPowerBarContainerFrame, 'TOP', E.UIParent, 'TOP', 0, -75, 100, 20, 'ALL,WIDGETS')
		BL:BuildWidgetHolder('EventToastHolder', 'EventToastMover', 'TOP', L["EventToastWidget"], _G.EventToastManagerFrame, 'TOP', E.UIParent, 'TOP', 0, -150, 200, 20, 'ALL,WIDGETS')
		BL:BuildWidgetHolder('BossBannerHolder', 'BossBannerMover', 'TOP', L["BossBannerWidget"], _G.BossBanner, 'TOP', E.UIParent, 'TOP', 0, -125, 200, 20, 'ALL,WIDGETS')

		-- handle power bar widgets after reload as Setup will have fired before this
		for _, widget in pairs(_G.UIWidgetPowerBarContainerFrame.widgetFrames) do
			BL.UIWidgetTemplateStatusBar(widget)
		end
	else
		local duraWidth, duraHeight = _G.DurabilityFrame:GetSize()
		_G.DurabilityFrame:SetFrameStrata('HIGH')

		BL:BuildWidgetHolder('DurabilityFrameHolder', 'DurabilityFrameMover', 'CENTER', L["Durability Frame"], _G.DurabilityFrame, 'TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300, duraWidth, duraHeight, 'ALL,GENERAL')
		BL:UpdateDurabilityScale()
	end

	-- Credits ShestakUI
	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, 'Setup', BL.UIWidgetTemplateStatusBar)
	hooksecurefunc(_G.UIWidgetTemplateCaptureBarMixin, 'Setup', BL.UIWidgetTemplateCaptureBar)

	-- Below Minimap Widgets
	if BelowMinimapContainer.ProcessWidget then
		hooksecurefunc(BelowMinimapContainer, 'ProcessWidget', BL.BelowMinimap_ProcessWidget)
	end

	BL.BelowMinimap_ProcessWidget(BelowMinimapContainer) -- finds any pre-existing capture bars
end
