local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LO = E:NewModule('Layout', 'AceEvent-3.0');

--Cache global variables
--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame
local UIFrameFadeIn, UIFrameFadeOut = UIFrameFadeIn, UIFrameFadeOut

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: HideLeftChat, HideRightChat, HideBothChat, LeftChatPanel, RightChatPanel, Minimap
-- GLOBALS: GameTooltip, LeftChatToggleButton, RightChatToggleButton, LeftChatTab, RightChatTab
-- GLOBALS: LeftChatDataPanel, LeftMiniPanel, RightChatDataPanel, RightMiniPanel, ElvConfigToggle

local PANEL_HEIGHT = 22;
local SIDE_BUTTON_WIDTH = 16;

E.Layout = LO;

local function Panel_OnShow(self)
	self:SetFrameLevel(0)
	self:SetFrameStrata('BACKGROUND')
end

function LO:Initialize()
	self:CreateChatPanels()
	self:CreateMinimapPanels()


	self.BottomPanel = CreateFrame('Frame', 'ElvUI_BottomPanel', E.UIParent)
	self.BottomPanel:SetTemplate('Transparent')
	self.BottomPanel:Point('BOTTOMLEFT', E.UIParent, 'BOTTOMLEFT', -1, -1)
	self.BottomPanel:Point('BOTTOMRIGHT', E.UIParent, 'BOTTOMRIGHT', 1, -1)
	self.BottomPanel:Height(PANEL_HEIGHT)
	self.BottomPanel:SetScript('OnShow', Panel_OnShow)
	E.FrameLocks['ElvUI_BottomPanel'] = true;
	Panel_OnShow(self.BottomPanel)
	self:BottomPanelVisibility()

	self.TopPanel = CreateFrame('Frame', 'ElvUI_TopPanel', E.UIParent)
	self.TopPanel:SetTemplate('Transparent')
	self.TopPanel:Point('TOPLEFT', E.UIParent, 'TOPLEFT', -1, 1)
	self.TopPanel:Point('TOPRIGHT', E.UIParent, 'TOPRIGHT', 1, 1)
	self.TopPanel:Height(PANEL_HEIGHT)
	self.TopPanel:SetScript('OnShow', Panel_OnShow)
	Panel_OnShow(self.TopPanel)
	E.FrameLocks['ElvUI_TopPanel'] = true;
	self:TopPanelVisibility()
end

function LO:BottomPanelVisibility()
	if E.db.general.bottomPanel and not E.global.tukuiMode then
		self.BottomPanel:Show()
	else
		self.BottomPanel:Hide()
	end
end

function LO:TopPanelVisibility()
	if E.db.general.topPanel then
		self.TopPanel:Show()
	else
		self.TopPanel:Hide()
	end
end

local function ChatPanelLeft_OnFade(self)
	LeftChatPanel:Hide()
end

local function ChatPanelRight_OnFade(self)
	RightChatPanel:Hide()
end

local function ChatButton_OnEnter(self, ...)
	if E.db[self.parent:GetName()..'Faded'] then
		self.parent:Show()
		UIFrameFadeIn(self.parent, 0.2, self.parent:GetAlpha(), 1)
		UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	end

	if not self.parent.editboxforced then
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Left Click:"], L["Toggle Chat Frame"], 1, 1, 1)
		GameTooltip:Show()
	end
end

local function ChatButton_OnLeave(self, ...)
	if E.db[self.parent:GetName()..'Faded'] then
		UIFrameFadeOut(self.parent, 0.2, self.parent:GetAlpha(), 0)
		UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0)
		self.parent.fadeInfo.finishedFunc = self.parent.fadeFunc
	end
	GameTooltip:Hide()
end

local function ChatButton_OnClick(self, btn)
	GameTooltip:Hide()

	if E.db[self.parent:GetName()..'Faded'] then
		E.db[self.parent:GetName()..'Faded'] = nil
		UIFrameFadeIn(self.parent, 0.2, self.parent:GetAlpha(), 1)
		UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	else
		E.db[self.parent:GetName()..'Faded'] = true
		UIFrameFadeOut(self.parent, 0.2, self.parent:GetAlpha(), 0)
		UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0)
		self.parent.fadeInfo.finishedFunc = self.parent.fadeFunc
	end
end

function HideLeftChat()
	ChatButton_OnClick(LeftChatToggleButton)
end

function HideRightChat()
	ChatButton_OnClick(RightChatToggleButton)
end

function HideBothChat()
	ChatButton_OnClick(LeftChatToggleButton)
	ChatButton_OnClick(RightChatToggleButton)
end

function LO:ToggleChatTabPanels(rightOverride, leftOverride)
	if leftOverride or not E.db.chat.panelTabBackdrop then
		LeftChatTab:Hide()
	else
		LeftChatTab:Show()
	end

	if rightOverride or not E.db.chat.panelTabBackdrop then
		RightChatTab:Hide()
	else
		RightChatTab:Show()
	end
end

function LO:SetChatTabStyle()
	if E.db.chat.panelTabTransparency then
		LeftChatTab:SetTemplate("Transparent")
		RightChatTab:SetTemplate("Transparent")
	else
		LeftChatTab:SetTemplate("Default", true)
		RightChatTab:SetTemplate("Default", true)
	end
end

function LO:SetDataPanelStyle()
	if E.db.datatexts.panelTransparency then
		LeftChatDataPanel:SetTemplate("Transparent")
		LeftChatToggleButton:SetTemplate("Transparent")
		LeftMiniPanel:SetTemplate("Transparent")
		RightChatDataPanel:SetTemplate("Transparent")
		RightChatToggleButton:SetTemplate("Transparent")
		RightMiniPanel:SetTemplate("Transparent")
		ElvConfigToggle:SetTemplate("Transparent")
	else
		LeftChatDataPanel:SetTemplate("Default", true)
		LeftChatToggleButton:SetTemplate("Default", true)
		LeftMiniPanel:SetTemplate("Default", true)
		RightChatDataPanel:SetTemplate("Default", true)
		RightChatToggleButton:SetTemplate("Default", true)
		RightMiniPanel:SetTemplate("Default", true)
		ElvConfigToggle:SetTemplate("Default", true)
	end
end

function LO:ToggleChatPanels()
	LeftChatDataPanel:ClearAllPoints()
	RightChatDataPanel:ClearAllPoints()
	local SPACING = E.Border*3 - E.Spacing

	if E.db.datatexts.leftChatPanel then
		LeftChatDataPanel:Show()
		LeftChatToggleButton:Show()
	else
		LeftChatDataPanel:Hide()
		LeftChatToggleButton:Hide()
	end

	if E.db.datatexts.rightChatPanel then
		RightChatDataPanel:Show()
		RightChatToggleButton:Show()
	else
		RightChatDataPanel:Hide()
		RightChatToggleButton:Hide()
	end
	
	local panelBackdrop = E.db.chat.panelBackdrop
	if(E.global.tukuiMode) then
		panelBackdrop = 'HIDEBOTH'
		RightChatToggleButton:Hide()
		LeftChatToggleButton:Hide()
	end
	
	if panelBackdrop == 'SHOWBOTH' then
		LeftChatPanel.backdrop:Show()
		RightChatPanel.backdrop:Show()
		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', SPACING + SIDE_BUTTON_WIDTH, SPACING)
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMRIGHT', -SPACING, (SPACING + PANEL_HEIGHT))
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'BOTTOMLEFT', SPACING, SPACING)
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'BOTTOMRIGHT', -(SPACING + SIDE_BUTTON_WIDTH), SPACING + PANEL_HEIGHT)
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', SPACING, SPACING)
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', -SPACING, SPACING)
		LO:ToggleChatTabPanels()
	elseif panelBackdrop == 'HIDEBOTH' then
		LeftChatPanel.backdrop:Hide()
		RightChatPanel.backdrop:Hide()
		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', SIDE_BUTTON_WIDTH, 0)
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMRIGHT', 0, PANEL_HEIGHT)
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'BOTTOMLEFT')
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'BOTTOMRIGHT', -SIDE_BUTTON_WIDTH, PANEL_HEIGHT)
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT')
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT')
		LO:ToggleChatTabPanels(true, true)
	elseif panelBackdrop == 'LEFT' then
		LeftChatPanel.backdrop:Show()
		RightChatPanel.backdrop:Hide()
		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', SPACING + SIDE_BUTTON_WIDTH, SPACING)
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMRIGHT', -SPACING, (SPACING + PANEL_HEIGHT))
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'BOTTOMLEFT')
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'BOTTOMRIGHT', -SIDE_BUTTON_WIDTH, PANEL_HEIGHT)
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', SPACING, SPACING)
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT')
		LO:ToggleChatTabPanels(true)
	else
		LeftChatPanel.backdrop:Hide()
		RightChatPanel.backdrop:Show()
		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', SIDE_BUTTON_WIDTH, 0)
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMRIGHT', 0, PANEL_HEIGHT)
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'BOTTOMLEFT', SPACING, SPACING)
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'BOTTOMRIGHT', -(SPACING + SIDE_BUTTON_WIDTH), SPACING + PANEL_HEIGHT)
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT')
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', -SPACING, SPACING)
		LO:ToggleChatTabPanels(nil, true)
	end
end

function LO:CreateChatPanels()
	local SPACING = E.Border*3 - E.Spacing

	--Left Chat
	local lchat = CreateFrame('Frame', 'LeftChatPanel', E.UIParent)
	lchat:SetFrameStrata('BACKGROUND')
	lchat:Size(E.db.chat.panelWidth, E.db.chat.panelHeight)
	lchat:Point('BOTTOMLEFT', E.UIParent, 4, 4)
	lchat:SetFrameLevel(lchat:GetFrameLevel() + 2)
	lchat:CreateBackdrop('Transparent')
	lchat.backdrop:SetAllPoints()
	E:CreateMover(lchat, "LeftChatMover", L["Left Chat"])


	--Background Texture
	lchat.tex = lchat:CreateTexture(nil, 'OVERLAY')
	lchat.tex:SetInside()
	lchat.tex:SetTexture(E.db.chat.panelBackdropNameLeft)
	lchat.tex:SetAlpha(E.db.general.backdropfadecolor.a - 0.7 > 0 and E.db.general.backdropfadecolor.a - 0.7 or 0.5)

	--Left Chat Tab
	local lchattab = CreateFrame('Frame', 'LeftChatTab', LeftChatPanel)
	lchattab:Point('TOPLEFT', lchat, 'TOPLEFT', SPACING, -SPACING)
	lchattab:Point('BOTTOMRIGHT', lchat, 'TOPRIGHT', -SPACING, -(SPACING + PANEL_HEIGHT))
	lchattab:SetTemplate(E.db.chat.panelTabTransparency == true and 'Transparent' or 'Default', true)

	--Left Chat Data Panel
	local lchatdp = CreateFrame('Frame', 'LeftChatDataPanel', LeftChatPanel)
	lchatdp:Point('BOTTOMLEFT', lchat, 'BOTTOMLEFT', SPACING + SIDE_BUTTON_WIDTH, SPACING)
	lchatdp:Point('TOPRIGHT', lchat, 'BOTTOMRIGHT', -SPACING, (SPACING + PANEL_HEIGHT))
	lchatdp:SetTemplate(E.db.datatexts.panelTransparency and 'Transparent' or 'Default', true)

	E:GetModule('DataTexts'):RegisterPanel(lchatdp, 3, 'ANCHOR_TOPLEFT', -17, 4)

	--Left Chat Toggle Button
	local lchattb = CreateFrame('Button', 'LeftChatToggleButton', E.UIParent)
	lchattb.parent = LeftChatPanel
	LeftChatPanel.fadeFunc = ChatPanelLeft_OnFade
	lchattb:Point('TOPRIGHT', lchatdp, 'TOPLEFT', E.Border - E.Spacing*3, 0)
	lchattb:Point('BOTTOMLEFT', lchat, 'BOTTOMLEFT', SPACING, SPACING)
	lchattb:SetTemplate(E.db.datatexts.panelTransparency and 'Transparent' or 'Default', true)
	lchattb:SetScript('OnEnter', ChatButton_OnEnter)
	lchattb:SetScript('OnLeave', ChatButton_OnLeave)
	lchattb:SetScript('OnClick', ChatButton_OnClick)
	lchattb.text = lchattb:CreateFontString(nil, 'OVERLAY')
	lchattb.text:FontTemplate()
	lchattb.text:Point('CENTER')
	lchattb.text:SetJustifyH('CENTER')
	lchattb.text:SetText('<')

	--Right Chat
	local rchat = CreateFrame('Frame', 'RightChatPanel', E.UIParent)
	rchat:SetFrameStrata('BACKGROUND')
	rchat:Size(E.db.chat.separateSizes and E.db.chat.panelWidthRight or E.db.chat.panelWidth, E.db.chat.separateSizes and E.db.chat.panelHeightRight or E.db.chat.panelHeight)
	rchat:Point('BOTTOMRIGHT', E.UIParent, -4, 4)
	rchat:SetFrameLevel(rchat:GetFrameLevel() + 2)
	rchat:CreateBackdrop('Transparent')
	rchat.backdrop:SetAllPoints()
	E:CreateMover(rchat, "RightChatMover", L["Right Chat"])

	--Background Texture
	rchat.tex = rchat:CreateTexture(nil, 'OVERLAY')
	rchat.tex:SetInside()
	rchat.tex:SetTexture(E.db.chat.panelBackdropNameRight)
	rchat.tex:SetAlpha(E.db.general.backdropfadecolor.a - 0.7 > 0 and E.db.general.backdropfadecolor.a - 0.7 or 0.5)

	--Right Chat Tab
	local rchattab = CreateFrame('Frame', 'RightChatTab', RightChatPanel)
	rchattab:Point('TOPRIGHT', rchat, 'TOPRIGHT', -SPACING, -SPACING)
	rchattab:Point('BOTTOMLEFT', rchat, 'TOPLEFT', SPACING, -(SPACING + PANEL_HEIGHT))
	rchattab:SetTemplate(E.db.chat.panelTabTransparency == true and 'Transparent' or 'Default', true)

	--Right Chat Data Panel
	local rchatdp = CreateFrame('Frame', 'RightChatDataPanel', RightChatPanel)
	rchatdp:Point('BOTTOMLEFT', rchat, 'BOTTOMLEFT', SPACING, SPACING)
	rchatdp:Point('TOPRIGHT', rchat, 'BOTTOMRIGHT', -(SPACING + SIDE_BUTTON_WIDTH), SPACING + PANEL_HEIGHT)
	rchatdp:SetTemplate(E.db.datatexts.panelTransparency and 'Transparent' or 'Default', true)
	E:GetModule('DataTexts'):RegisterPanel(rchatdp, 3, 'ANCHOR_TOPRIGHT', 17, 4)

	--Right Chat Toggle Button
	local rchattb = CreateFrame('Button', 'RightChatToggleButton', E.UIParent)
	rchattb.parent = RightChatPanel
	RightChatPanel.fadeFunc = ChatPanelRight_OnFade
	rchattb:Point('TOPLEFT', rchatdp, 'TOPRIGHT', -E.Border + E.Spacing*3, 0)
	rchattb:Point('BOTTOMRIGHT', rchat, 'BOTTOMRIGHT', -SPACING, SPACING)
	rchattb:SetTemplate(E.db.datatexts.panelTransparency and 'Transparent' or 'Default', true)
	rchattb:RegisterForClicks('AnyUp')
	rchattb:SetScript('OnEnter', ChatButton_OnEnter)
	rchattb:SetScript('OnLeave', ChatButton_OnLeave)
	rchattb:SetScript('OnClick', ChatButton_OnClick)
	rchattb.text = rchattb:CreateFontString(nil, 'OVERLAY')
	rchattb.text:FontTemplate()
	rchattb.text:Point('CENTER')
	rchattb.text:SetJustifyH('CENTER')
	rchattb.text:SetText('>')

	--Load Settings
	if E.db['LeftChatPanelFaded'] then
		LeftChatToggleButton:SetAlpha(0)
		LeftChatPanel:Hide()
	end

	if E.db['RightChatPanelFaded'] then
		RightChatToggleButton:SetAlpha(0)
		RightChatPanel:Hide()
	end

	self:ToggleChatPanels()
end

function LO:CreateMinimapPanels()
	local lminipanel = CreateFrame('Frame', 'LeftMiniPanel', Minimap)

	lminipanel:Point('TOPLEFT', Minimap, 'BOTTOMLEFT', -E.Border, -E.Spacing*3)
	lminipanel:Point('BOTTOMRIGHT', Minimap, 'BOTTOM', 0, -(E.Spacing*3 + PANEL_HEIGHT))
	lminipanel:SetTemplate(E.db.datatexts.panelTransparency and 'Transparent' or 'Default', true)
	E:GetModule('DataTexts'):RegisterPanel(lminipanel, 1, 'ANCHOR_BOTTOMLEFT', lminipanel:GetWidth() * 2, -4)

	local rminipanel = CreateFrame('Frame', 'RightMiniPanel', Minimap)
	rminipanel:Point('TOPRIGHT', Minimap, 'BOTTOMRIGHT', E.Border, -(E.Spacing*3))
	rminipanel:Point('BOTTOMLEFT', lminipanel, 'BOTTOMRIGHT', -E.Border + (E.Spacing*3), 0)
	rminipanel:SetTemplate(E.db.datatexts.panelTransparency and 'Transparent' or 'Default', true)
	E:GetModule('DataTexts'):RegisterPanel(rminipanel, 1, 'ANCHOR_BOTTOM', 0, -4)

	if E.db.datatexts.minimapPanels then
		LeftMiniPanel:Show()
		RightMiniPanel:Show()
	else
		LeftMiniPanel:Hide()
		RightMiniPanel:Hide()
	end

	local configtoggle = CreateFrame('Button', 'ElvConfigToggle', Minimap)
	if E.db.auras.consolidatedBuffs.position == "LEFT" then
		configtoggle:Point('TOPRIGHT', lminipanel, 'TOPLEFT', (E.Border - (E.Spacing*3)), 0)
		configtoggle:Point('BOTTOMRIGHT', lminipanel, 'BOTTOMLEFT', (E.Border + (E.Spacing*3)), 0)
	else
		configtoggle:Point('TOPLEFT', rminipanel, 'TOPRIGHT', (-E.Border + (E.Spacing*3)), 0)
		configtoggle:Point('BOTTOMLEFT', rminipanel, 'BOTTOMRIGHT', (-E.Border + (E.Spacing*3)), 0)
	end
	configtoggle:RegisterForClicks('AnyUp')
	configtoggle:Width(E.ConsolidatedBuffsWidth - (E.Border*2))
	configtoggle:SetTemplate(E.db.datatexts.panelTransparency and 'Transparent' or 'Default', true)
	configtoggle.text = configtoggle:CreateFontString(nil, 'OVERLAY')
	configtoggle.text:FontTemplate(E.LSM:Fetch("font", E.db.datatexts.font), E.db.datatexts.fontSize, E.db.datatexts.fontOutline)
	configtoggle.text:SetText('C')
	configtoggle.text:Point('CENTER')
	configtoggle.text:SetJustifyH('CENTER')
	configtoggle:SetScript('OnClick', function(self, btn)
		if btn == 'LeftButton' then
			E:ToggleConfig()
		else
			E:BGStats()
		end
	end)
	configtoggle:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 0, -4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Left Click:"], L["Toggle Configuration"], 1, 1, 1)

		if E.db.datatexts.battleground then
			GameTooltip:AddDoubleLine(L["Right Click:"], L["Show BG Texts"], 1, 1, 1)
		end
		GameTooltip:Show()
	end)
	configtoggle:SetScript('OnLeave', function(self)
		GameTooltip:Hide()
	end)
	
	if(E.global.tukuiMode) then
		local BottomLine = CreateFrame("Frame", nil, E.UIParent)
		BottomLine:SetTemplate()
		BottomLine:Size(2)
		BottomLine:Point("BOTTOMLEFT", 15, 15)
		BottomLine:Point("BOTTOMRIGHT", -15, 15)
		BottomLine:SetFrameStrata("BACKGROUND")
		BottomLine:SetFrameLevel(0)

		local LeftVerticalLine = CreateFrame("Frame", nil, BottomLine)
		LeftVerticalLine:SetTemplate()
		LeftVerticalLine:Point("BOTTOMLEFT", 0, 0)
		LeftVerticalLine:SetFrameLevel(0)
		LeftVerticalLine:SetFrameStrata("BACKGROUND")


		local RightVerticalLine = CreateFrame("Frame", nil, BottomLine)
		RightVerticalLine:SetTemplate()
		RightVerticalLine:Point("BOTTOMRIGHT", 0, 0)
		RightVerticalLine:SetFrameLevel(0)
		RightVerticalLine:SetFrameStrata("BACKGROUND")


		local CubeLeft = CreateFrame("Frame", nil, LeftVerticalLine)
		CubeLeft:SetTemplate()
		CubeLeft:Size(10)
		CubeLeft:Point("BOTTOM", LeftVerticalLine, "TOP", 0, 0)
		CubeLeft:EnableMouse(true)
		CubeLeft:SetFrameLevel(0)
		CubeLeft:SetScript("OnMouseDown", function(self, Button)
			if (Button == "LeftButton") then	
				ToggleFrame(ChatMenu)
			end
		end)

		local CubeRight = CreateFrame("Frame", nil, RightVerticalLine)
		CubeRight:SetTemplate()
		CubeRight:Size(10)
		CubeRight:Point("BOTTOM", RightVerticalLine, "TOP", 0, 0)
		CubeRight:EnableMouse(true)
		CubeRight:SetFrameLevel(0)
		CubeRight:SetScript("OnMouseDown", function(self, Button)
			if (Button == "LeftButton") then	
				ToggleCharacter("ReputationFrame")
			end
		end)
		
		hooksecurefunc(E:GetModule("Chat"), "PositionChat", function()
			LeftVerticalLine:Size(2, E.db.chat.panelHeight - 40)
			RightVerticalLine:Size(2, (E.db.chat.separateSizes and E.db.chat.panelHeightRight or E.db.chat.panelHeight) - 40)	
		end)
	end
	
	local f = CreateFrame("Frame", 'BottomMiniPanel', Minimap)
	f:SetPoint("BOTTOM", Minimap, "BOTTOM")
	f:Width(75)
	f:Height(20)
	f:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	E:GetModule('DataTexts'):RegisterPanel(f, 1, 'ANCHOR_BOTTOM', 0, -10)
	
	f = CreateFrame("Frame", 'TopMiniPanel', Minimap)
	f:SetPoint("TOP", Minimap, "TOP")
	f:Width(75)
	f:Height(20)
	f:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	E:GetModule('DataTexts'):RegisterPanel(f, 1, 'ANCHOR_BOTTOM', 0, -10)		
	
	f = CreateFrame("Frame", 'TopLeftMiniPanel', Minimap)
	f:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
	f:Width(75)
	f:Height(20)
	f:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	E:GetModule('DataTexts'):RegisterPanel(f, 1, 'ANCHOR_BOTTOMLEFT', 0, -10)	

	f = CreateFrame("Frame", 'TopRightMiniPanel', Minimap)
	f:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT")
	f:Width(75)
	f:Height(20)
	f:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	E:GetModule('DataTexts'):RegisterPanel(f, 1, 'ANCHOR_BOTTOMRIGHT', 0, -10)	
	
	f = CreateFrame("Frame", 'BottomLeftMiniPanel', Minimap)
	f:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT")
	f:Width(75)
	f:Height(20)
	f:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	E:GetModule('DataTexts'):RegisterPanel(f, 1, 'ANCHOR_BOTTOMLEFT', 0, -10)	

	f = CreateFrame("Frame", 'BottomRightMiniPanel', Minimap)
	f:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT")
	f:Width(75)
	f:Height(20)
	f:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	E:GetModule('DataTexts'):RegisterPanel(f, 1, 'ANCHOR_BOTTOMRIGHT', 0, -10)
end

E:RegisterModule(LO:GetName())