local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LO = E:GetModule('Layout')
local DT = E:GetModule('DataTexts')

local _G = _G
local pairs = pairs
local CreateFrame = CreateFrame
-- GLOBALS: HideLeftChat, HideRightChat, HideBothChat

local PANEL_HEIGHT = 22
local SIDE_BUTTON_WIDTH = 18

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
	LO.BottomPanel:Height(PANEL_HEIGHT)
	LO.BottomPanel:SetScript('OnShow', Panel_OnShow)
	E.FrameLocks.ElvUI_BottomPanel = true
	Panel_OnShow(LO.BottomPanel)
	LO:BottomPanelVisibility()

	LO.TopPanel = CreateFrame('Frame', 'ElvUI_TopPanel', E.UIParent)
	LO.TopPanel:SetTemplate('Transparent')
	LO.TopPanel:Point('TOPLEFT', E.UIParent, 'TOPLEFT', -1, 1)
	LO.TopPanel:Point('TOPRIGHT', E.UIParent, 'TOPRIGHT', 1, 1)
	LO.TopPanel:Height(PANEL_HEIGHT)
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

local function ChatButton_OnEnter(self)
	if E.db[self.parent:GetName()..'Faded'] then
		self.parent:Show()
		E:UIFrameFadeIn(self.parent, 0.25, self.parent:GetAlpha(), 1)
		if E.db.chat.fadeChatToggles then
			E:UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
		end
	end

	if not self.parent.editboxforced then
		local GameTooltip = _G.GameTooltip
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Left Click:"], L["Toggle Chat Frame"], 1, 1, 1)
		GameTooltip:Show()
	end
end

local function ChatButton_OnLeave(self)
	if E.db[self.parent:GetName()..'Faded'] then
		E:UIFrameFadeOut(self.parent, 0.25, self.parent:GetAlpha(), 0)
		if E.db.chat.fadeChatToggles then
			E:UIFrameFadeOut(self, 0.25, self:GetAlpha(), 0)
		end
	end

	_G.GameTooltip:Hide()
end

local function ChatButton_OnClick(self)
	_G.GameTooltip:Hide()

	local fadeToggle = E.db.chat.fadeChatToggles
	local name = self.parent:GetName()..'Faded'
	if E.db[name] then
		E.db[name] = nil
		E:UIFrameFadeIn(self.parent, 0.2, self.parent:GetAlpha(), 1)
		if fadeToggle then
			E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
		end
	else
		E.db[name] = true
		E:UIFrameFadeOut(self.parent, 0.2, self.parent:GetAlpha(), 0)
		if fadeToggle then
			E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0)
		end
	end
end

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

local channelButtons = {
	_G.ChatFrameChannelButton,
	_G.ChatFrameToggleVoiceDeafenButton,
	_G.ChatFrameToggleVoiceMuteButton
}

function LO:ToggleChatTabPanels(rightOverride, leftOverride)
	if E.private.chat.enable and not E.db.chat.hideVoiceButtons then
		local parent = (E.db.chat.panelTabBackdrop and _G.LeftChatTab) or _G.LeftChatPanel
		for _, button in pairs(channelButtons) do
			button.Icon:SetParent(parent)
		end
	end

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

function LO:SetDataPanelStyle()
	_G.LeftChatToggleButton:SetTemplate(E.db.datatexts.panels.LeftChatDataPanel.backdrop and (E.db.datatexts.panels.LeftChatDataPanel.panelTransparency and 'Transparent' or 'Default') or 'NoBackdrop', true)
	_G.RightChatToggleButton:SetTemplate(E.db.datatexts.panels.RightChatDataPanel.backdrop and (E.db.datatexts.panels.RightChatDataPanel.panelTransparency and 'Transparent' or 'Default') or 'NoBackdrop', true)
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

	LeftChatTab:ClearAllPoints()
	RightChatTab:ClearAllPoints()
	LeftChatDataPanel:ClearAllPoints()
	RightChatDataPanel:ClearAllPoints()

	LeftChatTab:Point('TOPLEFT', LeftChatPanel, 'TOPLEFT', 2, -2)
	LeftChatTab:Point('BOTTOMRIGHT', LeftChatPanel, 'TOPRIGHT', -2, -PANEL_HEIGHT-2)
	RightChatTab:Point('TOPRIGHT', RightChatPanel, 'TOPRIGHT', -2, -2)
	RightChatTab:Point('BOTTOMLEFT', RightChatPanel, 'TOPLEFT', 2, -PANEL_HEIGHT-2)

	local SPACING = E.PixelMode and 1 or -1
	local SIDE_BUTTON = E.db.chat.hideChatToggles and 0 or (SIDE_BUTTON_WIDTH+1)
	if E.db.chat.LeftChatDataPanelAnchor == 'ABOVE_CHAT' then
		LeftChatDataPanel:Point('BOTTOMRIGHT', LeftChatPanel, 'TOPRIGHT', 0, -SPACING)
		LeftChatDataPanel:Point('TOPLEFT', LeftChatPanel, 'TOPLEFT', SIDE_BUTTON, 1 + PANEL_HEIGHT)
		LeftChatToggleButton:Point('BOTTOMRIGHT', LeftChatDataPanel, 'BOTTOMLEFT', 1, 0)
		LeftChatToggleButton:Point('TOPLEFT', LeftChatDataPanel, 'TOPLEFT', -(SIDE_BUTTON_WIDTH + 1), 0)
	else
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMRIGHT', 0, SPACING)
		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', SIDE_BUTTON, -(1 + PANEL_HEIGHT))
		LeftChatToggleButton:Point('TOPRIGHT', LeftChatDataPanel, 'TOPLEFT', 1, 0)
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatDataPanel, 'BOTTOMLEFT', -(SIDE_BUTTON_WIDTH + 1), 0)
	end

	if E.db.chat.RightChatDataPanelAnchor == 'ABOVE_CHAT' then
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'TOPLEFT', 0, -SPACING)
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'TOPRIGHT', -SIDE_BUTTON, 1 + PANEL_HEIGHT)
		RightChatToggleButton:Point('BOTTOMLEFT', RightChatDataPanel, 'BOTTOMRIGHT', -1, 0)
		RightChatToggleButton:Point('TOPRIGHT', RightChatDataPanel, 'TOPRIGHT', SIDE_BUTTON_WIDTH + 1, 0)
	else
		RightChatDataPanel:Point('TOPLEFT', RightChatPanel, 'BOTTOMLEFT', 0, SPACING)
		RightChatDataPanel:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', -SIDE_BUTTON, -(1 + PANEL_HEIGHT))
		RightChatToggleButton:Point('TOPLEFT', RightChatDataPanel, 'TOPRIGHT', -1, 0)
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatDataPanel, 'BOTTOMRIGHT', SIDE_BUTTON_WIDTH + 1, 0)
	end
end

function LO:SetChatTabStyle()
	local tabStyle = (E.db.chat.panelTabTransparency and "Transparent") or nil
	local glossTex = (not tabStyle and true) or nil

	_G.LeftChatTab:SetTemplate(tabStyle, glossTex)
	_G.RightChatTab:SetTemplate(tabStyle, glossTex)
end

function LO:ToggleChatPanels()
	_G.LeftChatDataPanel:SetShown(E.db.datatexts.panels.LeftChatDataPanel.enable)
	_G.LeftChatToggleButton:SetShown(not E.db.chat.hideChatToggles and E.db.datatexts.panels.LeftChatDataPanel.enable)

	_G.RightChatDataPanel:SetShown(E.db.datatexts.panels.RightChatDataPanel.enable)
	_G.RightChatToggleButton:SetShown(not E.db.chat.hideChatToggles and E.db.datatexts.panels.RightChatDataPanel.enable)

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

function LO:CreateChatPanels()
	--Left Chat
	local lchat = CreateFrame('Frame', 'LeftChatPanel', E.UIParent)
	lchat:SetFrameStrata('BACKGROUND')
	lchat:SetFrameLevel(300)
	lchat:Size(E.db.chat.panelWidth, E.db.chat.panelHeight)
	lchat:Point('BOTTOMLEFT', E.UIParent, 4, 27)
	lchat:CreateBackdrop('Transparent')
	lchat.backdrop.ignoreBackdropColors = true
	lchat.backdrop:SetAllPoints()
	lchat.FadeObject = {finishedFunc = finishFade, finishedArg1 = lchat, finishedFuncKeep = true}
	E:CreateMover(lchat, 'LeftChatMover', L["Left Chat"], nil, nil, nil, nil, nil, 'chat,general')

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
	rchat:Size(E.db.chat.separateSizes and E.db.chat.panelWidthRight or E.db.chat.panelWidth, E.db.chat.separateSizes and E.db.chat.panelHeightRight or E.db.chat.panelHeight)
	rchat:Point('BOTTOMRIGHT', E.UIParent, -4, 27)
	rchat:CreateBackdrop('Transparent')
	rchat.backdrop.ignoreBackdropColors = true
	rchat.backdrop:SetAllPoints()
	rchat.FadeObject = {finishedFunc = finishFade, finishedArg1 = rchat, finishedFuncKeep = true}
	E:CreateMover(rchat, 'RightChatMover', L["Right Chat"], nil, nil, nil, nil, nil, 'chat,general')

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
	panel:Point('TOPLEFT', _G.Minimap, 'BOTTOMLEFT', -1, 0)
	panel:Point('BOTTOMRIGHT', _G.Minimap, 'BOTTOMRIGHT', 1, -PANEL_HEIGHT)
	panel:Hide()
	DT:RegisterPanel(panel, E.db.datatexts.panels.MinimapPanel.numPoints, 'ANCHOR_BOTTOMLEFT', 0, -4)
end

E:RegisterModule(LO:GetName())
