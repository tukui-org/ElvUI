local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LO = E:GetModule('Layout')
local DT = E:GetModule('DataTexts')
local CH = E:GetModule('Chat')

local _G = _G
local CreateFrame = CreateFrame
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
-- GLOBALS: HideLeftChat, HideRightChat, HideBothChat

local BAR_HEIGHT = 22
local TOGGLE_WIDTH = 18

local function Panel_OnShow(self)
	self:SetFrameLevel(200)
	self:SetFrameStrata('BACKGROUND')
end

function LO:Initialize()
	LO.Initialized = true
	LO:CreateChatPanels()
	LO:CreateMinimapPanels()
	LO:SetDataPanelStyle()

	LO.BottomPanel = CreateFrame('Frame', 'ElvUI_BottomPanel', E.UIParent)
	LO.BottomPanel:SetTemplate('Transparent')
	LO.BottomPanel:Point('BOTTOMLEFT', E.UIParent, 'BOTTOMLEFT', -1, -1)
	LO.BottomPanel:Point('BOTTOMRIGHT', E.UIParent, 'BOTTOMRIGHT', 1, -1)
	LO.BottomPanel:Height(BAR_HEIGHT)
	LO.BottomPanel:SetScript('OnShow', Panel_OnShow)
	E.FrameLocks.ElvUI_BottomPanel = true
	Panel_OnShow(LO.BottomPanel)
	LO:BottomPanelVisibility()

	LO.TopPanel = CreateFrame('Frame', 'ElvUI_TopPanel', E.UIParent)
	LO.TopPanel:SetTemplate('Transparent')
	LO.TopPanel:Point('TOPLEFT', E.UIParent, 'TOPLEFT', -1, 1)
	LO.TopPanel:Point('TOPRIGHT', E.UIParent, 'TOPRIGHT', 1, 1)
	LO.TopPanel:Height(BAR_HEIGHT)
	LO.TopPanel:SetScript('OnShow', Panel_OnShow)
	Panel_OnShow(LO.TopPanel)
	E.FrameLocks.ElvUI_TopPanel = true
	LO:TopPanelVisibility()
end

function LO:BottomPanelVisibility()
	LO.BottomPanel:SetShown(E.db.general.bottomPanel)
end

function LO:TopPanelVisibility()
	LO.TopPanel:SetShown(E.db.general.topPanel)
end

local function finishFade(self)
	if self:GetAlpha() == 0 then
		self:Hide()
	end
end

local function fadeChatPanel(self, duration, alpha)
	if alpha == 1 then
		self.parent:Show()
	end

	E:UIFrameFadeOut(self.parent, duration, self.parent:GetAlpha(), alpha)

	if E.db.chat.fadeChatToggles then
		E:UIFrameFadeOut(self, duration, self:GetAlpha(), alpha)
	end
end

local function ChatButton_OnEnter(self)
	if E.db[self.parent:GetName()..'Faded'] then
		fadeChatPanel(self, 0.3, 1)
	end

	if not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 4)
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:AddDoubleLine(L["Left Click:"], L["Toggle Chat Frame"], 1, 1, 1)
		_G.GameTooltip:Show()
	end
end

local function ChatButton_OnLeave(self)
	if E.db[self.parent:GetName()..'Faded'] then
		fadeChatPanel(self, 0.3, 0)
	end

	if not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:Hide()
	end
end

local function ChatButton_OnClick(self)
	local name = self.parent:GetName()..'Faded'
	if E.db[name] then
		E.db[name] = nil
		fadeChatPanel(self, 0.2, 1)
	else
		E.db[name] = true
		fadeChatPanel(self, 0.2, 0)
	end

	if not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:Hide()
	end
end

-- these are used by the bindings and options
function HideLeftChat()
	ChatButton_OnClick(_G.LeftChatToggleButton)
end

function HideRightChat()
	ChatButton_OnClick(_G.RightChatToggleButton)
end

function HideBothChat()
	ChatButton_OnClick(_G.LeftChatToggleButton)
	ChatButton_OnClick(_G.RightChatToggleButton)
end

function LO:ToggleChatTabPanels(rightOverride, leftOverride)
	if leftOverride or not E.db.chat.panelTabBackdrop then
		_G.LeftChatTab:Hide()
	else
		_G.LeftChatTab:Show()
	end

	if rightOverride or not E.db.chat.panelTabBackdrop then
		_G.RightChatTab:Hide()
	else
		_G.RightChatTab:Show()
	end
end

do
	local function DataPanelStyle(panel, db)
		panel.forcedBorderColors = (db.border == false and {0,0,0,0}) or nil
		panel:SetTemplate(db.backdrop and (db.panelTransparency and 'Transparent' or 'Default') or 'NoBackdrop', true)

		if db.border ~= nil then
			if panel.iborder then panel.iborder:SetShown(db.border) end
			if panel.oborder then panel.oborder:SetShown(db.border) end
		end
	end

	function LO:SetDataPanelStyle()
		DataPanelStyle(_G.LeftChatToggleButton, E.db.datatexts.panels.LeftChatDataPanel)
		DataPanelStyle(_G.RightChatToggleButton, E.db.datatexts.panels.RightChatDataPanel)
	end
end

local barHeight = BAR_HEIGHT + 1
local toggleWidth = TOGGLE_WIDTH + 1
function LO:RefreshChatMovers()
	local LeftChatPanel = _G.LeftChatPanel
	local RightChatPanel = _G.RightChatPanel
	local LeftChatMover = _G.LeftChatMover
	local RightChatMover = _G.RightChatMover

	local Left = LeftChatPanel:GetPoint()
	local Right = RightChatPanel:GetPoint()
	local showRightPanel = E.db.datatexts.panels.RightChatDataPanel.enable
	local showLeftPanel = E.db.datatexts.panels.LeftChatDataPanel.enable
	if not showLeftPanel or E.db.chat.LeftChatDataPanelAnchor == 'ABOVE_CHAT' then
		LeftChatPanel:Point(Left, LeftChatMover, 0, 0)
	elseif showLeftPanel then
		LeftChatPanel:Point(Left, LeftChatMover, 0, barHeight)
	end
	if not showRightPanel or E.db.chat.RightChatDataPanelAnchor == 'ABOVE_CHAT' then
		RightChatPanel:Point(Right, RightChatMover, 0, 0)
	elseif showRightPanel then
		RightChatPanel:Point(Right, RightChatMover, 0, barHeight)
	end

	-- mover sizes: same as in CH.PositionChats for panels but including the datatext bar height
	local panelWidth, panelHeight = E:Scale(E.db.chat.panelWidth), E:Scale(E.db.chat.panelHeight)
	LeftChatMover:SetSize(panelWidth, panelHeight + (showLeftPanel and barHeight or 0))
	if E.db.chat.separateSizes then
		RightChatMover:SetSize(E:Scale(E.db.chat.panelWidthRight), E:Scale(E.db.chat.panelHeightRight) + E:Scale(showRightPanel and barHeight or 0))
	else
		RightChatMover:SetSize(panelWidth, panelHeight + E:Scale(showRightPanel and barHeight or 0))
	end
end

function LO:RepositionChatDataPanels()
	local LeftChatTab = _G.LeftChatTab
	local RightChatTab = _G.RightChatTab
	local LeftChatPanel = _G.LeftChatPanel
	local RightChatPanel = _G.RightChatPanel
	local LeftChatDataPanel = _G.LeftChatDataPanel
	local RightChatDataPanel = _G.RightChatDataPanel
	local LeftChatToggleButton = _G.LeftChatToggleButton
	local RightChatToggleButton = _G.RightChatToggleButton

	if E.private.chat.enable then
		LeftChatTab:ClearAllPoints()
		RightChatTab:ClearAllPoints()
		LeftChatTab:Point('TOPLEFT', LeftChatPanel, 'TOPLEFT', 2, -2)
		LeftChatTab:Point('BOTTOMRIGHT', LeftChatPanel, 'TOPRIGHT', -2, -BAR_HEIGHT-2)
		RightChatTab:Point('TOPRIGHT', RightChatPanel, 'TOPRIGHT', -2, -2)
		RightChatTab:Point('BOTTOMLEFT', RightChatPanel, 'TOPLEFT', 2, -BAR_HEIGHT-2)
	end

	LeftChatDataPanel:ClearAllPoints()
	RightChatDataPanel:ClearAllPoints()

	local SPACING = E.PixelMode and 1 or -1
	local sideButton = E.db.chat.hideChatToggles and 0 or toggleWidth
	if E.db.chat.LeftChatDataPanelAnchor == 'ABOVE_CHAT' then
		LeftChatDataPanel:Point('BOTTOMRIGHT', LeftChatPanel, 'TOPRIGHT', 0, -SPACING)
		LeftChatDataPanel:Point('TOPLEFT', LeftChatPanel, 'TOPLEFT', sideButton, barHeight)
		LeftChatToggleButton:Point('BOTTOMRIGHT', LeftChatDataPanel, 'BOTTOMLEFT', SPACING, 0)
		LeftChatToggleButton:Point('TOPLEFT', LeftChatDataPanel, 'TOPLEFT', -toggleWidth, 0)
	else
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMRIGHT', 0, SPACING)
		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', sideButton, -barHeight)
		LeftChatToggleButton:Point('TOPRIGHT', LeftChatDataPanel, 'TOPLEFT', SPACING, 0)
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatDataPanel, 'BOTTOMLEFT', -toggleWidth, 0)
	end

	if E.db.chat.RightChatDataPanelAnchor == 'ABOVE_CHAT' then
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'TOPLEFT', 0, -SPACING)
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'TOPRIGHT', -sideButton, barHeight)
		RightChatToggleButton:Point('BOTTOMLEFT', RightChatDataPanel, 'BOTTOMRIGHT', -SPACING, 0)
		RightChatToggleButton:Point('TOPRIGHT', RightChatDataPanel, 'TOPRIGHT', toggleWidth, 0)
	else
		RightChatDataPanel:Point('TOPLEFT', RightChatPanel, 'BOTTOMLEFT', 0, SPACING)
		RightChatDataPanel:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', -sideButton, -barHeight)
		RightChatToggleButton:Point('TOPLEFT', RightChatDataPanel, 'TOPRIGHT', -SPACING, 0)
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatDataPanel, 'BOTTOMRIGHT', toggleWidth, 0)
	end

	LO:RefreshChatMovers()
end

function LO:SetChatTabStyle()
	local tabStyle = (E.db.chat.panelTabTransparency and 'Transparent') or nil
	local glossTex = (not tabStyle and true) or nil

	_G.LeftChatTab:SetTemplate(tabStyle, glossTex)
	_G.RightChatTab:SetTemplate(tabStyle, glossTex)
end

function LO:ToggleChatPanels()
	local showRightPanel = E.db.datatexts.panels.RightChatDataPanel.enable
	local showLeftPanel = E.db.datatexts.panels.LeftChatDataPanel.enable

	_G.RightChatDataPanel:SetShown(showRightPanel)
	_G.LeftChatDataPanel:SetShown(showLeftPanel)

	local showToggles = not E.db.chat.hideChatToggles
	_G.LeftChatToggleButton:SetShown(showToggles and showLeftPanel)
	_G.RightChatToggleButton:SetShown(showToggles and showRightPanel)

	LO:RefreshChatMovers()

	local panelBackdrop = E.db.chat.panelBackdrop
	if panelBackdrop == 'SHOWBOTH' then
		_G.LeftChatPanel.backdrop:Show()
		_G.RightChatPanel.backdrop:Show()
		LO:ToggleChatTabPanels()
	elseif panelBackdrop == 'HIDEBOTH' then
		_G.LeftChatPanel.backdrop:Hide()
		_G.RightChatPanel.backdrop:Hide()
		LO:ToggleChatTabPanels(true, true)
	elseif panelBackdrop == 'LEFT' then
		_G.LeftChatPanel.backdrop:Show()
		_G.RightChatPanel.backdrop:Hide()
		LO:ToggleChatTabPanels(true)
	else
		_G.LeftChatPanel.backdrop:Hide()
		_G.RightChatPanel.backdrop:Show()
		LO:ToggleChatTabPanels(nil, true)
	end
end

function LO:ResaveChatPosition()
	if not E.private.chat.enable then return end

	local name, chat = self.name
	if name == 'LeftChatMover' then
		chat = CH.LeftChatWindow
	elseif name == 'RightChatMover' then
		chat = CH.RightChatWindow
	end

	if chat and chat:GetLeft() then
		FCF_SavePositionAndDimensions(chat)
	end
end

function LO:CreateChatPanels()
	--Left Chat
	local lchat = CreateFrame('Frame', 'LeftChatPanel', E.UIParent)
	lchat:SetFrameStrata('BACKGROUND')
	lchat:SetFrameLevel(300)
	lchat:Size(100, 100)
	lchat:Point('BOTTOMLEFT', E.UIParent, 4, 4)
	lchat:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, true)
	lchat.backdrop.callbackBackdropColor = CH.Panel_ColorUpdate
	lchat.FadeObject = {finishedFunc = finishFade, finishedArg1 = lchat, finishedFuncKeep = true}
	E:CreateMover(lchat, 'LeftChatMover', L["Left Chat"], nil, nil, LO.ResaveChatPosition, nil, nil, 'chat,general', true)

	--Background Texture
	local lchattex = lchat:CreateTexture(nil, 'OVERLAY')
	lchattex:SetInside()
	lchattex:SetTexture(E.db.chat.panelBackdropNameLeft)
	lchattex:SetAlpha(E.db.general.backdropfadecolor.a - 0.7 > 0 and E.db.general.backdropfadecolor.a - 0.7 or 0.5)
	lchat.tex = lchattex

	--Left Chat Tab
	CreateFrame('Frame', 'LeftChatTab', lchat)

	--Left Chat Data Panel
	local lchatdp = CreateFrame('Frame', 'LeftChatDataPanel', lchat)
	DT:RegisterPanel(lchatdp, 3, 'ANCHOR_TOPLEFT', -17, 4)

	--Left Chat Toggle Button
	local lchattb = CreateFrame('Button', 'LeftChatToggleButton', E.UIParent)
	lchattb:SetNormalTexture(E.Media.Textures.ArrowUp)
	lchattb:SetFrameStrata('BACKGROUND')
	lchattb:SetFrameLevel(301)
	lchattb:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	lchattb:SetScript('OnEnter', ChatButton_OnEnter)
	lchattb:SetScript('OnLeave', ChatButton_OnLeave)
	lchattb:SetScript('OnClick', function(lcb, btn)
		if btn == 'LeftButton' then
			ChatButton_OnClick(lcb)
		end
	end)

	local lchattbtex = lchattb:GetNormalTexture()
	lchattbtex:SetRotation(E.Skins.ArrowRotation.left)
	lchattbtex:ClearAllPoints()
	lchattbtex:Point('CENTER')
	lchattbtex:Size(12)
	lchattb.texture = lchattbtex
	lchattb.OnEnter = ChatButton_OnEnter
	lchattb.OnLeave = ChatButton_OnLeave
	lchattb.parent = lchat

	--Right Chat
	local rchat = CreateFrame('Frame', 'RightChatPanel', E.UIParent)
	rchat:SetFrameStrata('BACKGROUND')
	rchat:SetFrameLevel(300)
	rchat:Size(100, 100)
	rchat:Point('BOTTOMRIGHT', E.UIParent, -4, 4)
	rchat:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, true)
	rchat.backdrop.callbackBackdropColor = CH.Panel_ColorUpdate
	rchat.FadeObject = {finishedFunc = finishFade, finishedArg1 = rchat, finishedFuncKeep = true}
	E:CreateMover(rchat, 'RightChatMover', L["Right Chat"], nil, nil, LO.ResaveChatPosition, nil, nil, 'chat,general', true)

	--Background Texture
	local rchattex = rchat:CreateTexture(nil, 'OVERLAY')
	rchattex:SetInside()
	rchattex:SetTexture(E.db.chat.panelBackdropNameRight)
	rchattex:SetAlpha(E.db.general.backdropfadecolor.a - 0.7 > 0 and E.db.general.backdropfadecolor.a - 0.7 or 0.5)
	rchat.tex = rchattex

	--Right Chat Tab
	CreateFrame('Frame', 'RightChatTab', rchat)

	--Right Chat Data Panel
	local rchatdp = CreateFrame('Frame', 'RightChatDataPanel', rchat)
	DT:RegisterPanel(rchatdp, 3, 'ANCHOR_TOPRIGHT', 17, 4)

	--Right Chat Toggle Button
	local rchattb = CreateFrame('Button', 'RightChatToggleButton', E.UIParent)
	rchattb:SetNormalTexture(E.Media.Textures.ArrowUp)
	rchattb:RegisterForClicks('AnyUp')
	rchattb:SetFrameStrata('BACKGROUND')
	rchattb:SetFrameLevel(301)
	rchattb:SetScript('OnEnter', ChatButton_OnEnter)
	rchattb:SetScript('OnLeave', ChatButton_OnLeave)
	rchattb:SetScript('OnClick', function(rcb, btn)
		if btn == 'LeftButton' then
			ChatButton_OnClick(rcb)
		end
	end)

	local rchattbtex = rchattb:GetNormalTexture()
	rchattbtex:SetRotation(E.Skins.ArrowRotation.right)
	rchattbtex:ClearAllPoints()
	rchattbtex:Point('CENTER')
	rchattbtex:Size(12)
	rchattb.texture = rchattbtex
	rchattb.parent = rchat

	--Load Settings
	local fadeToggle = E.db.chat.fadeChatToggles
	if E.db.LeftChatPanelFaded then
		if fadeToggle then
			_G.LeftChatToggleButton:SetAlpha(0)
		end

		lchat:Hide()
	end

	if E.db.RightChatPanelFaded then
		if fadeToggle then
			_G.RightChatToggleButton:SetAlpha(0)
		end

		rchat:Hide()
	end

	LO:ToggleChatPanels()
	LO:SetChatTabStyle()
end

function LO:CreateMinimapPanels()
	local panel = CreateFrame('Frame', 'MinimapPanel', _G.Minimap)
	panel:Point('TOPLEFT', _G.Minimap, 'BOTTOMLEFT', -E.Border, E.PixelMode and 0 or -3)
	panel:Point('BOTTOMRIGHT', _G.Minimap, 'BOTTOMRIGHT', E.Border, -BAR_HEIGHT)
	panel:Hide()
	DT:RegisterPanel(panel, E.db.datatexts.panels.MinimapPanel.numPoints, 'ANCHOR_BOTTOM', 0, -4)
end

E:RegisterModule(LO:GetName())
