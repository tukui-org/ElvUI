local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LO = E:NewModule('Layout', 'AceEvent-3.0');

local PANEL_HEIGHT = 22;
local SIDE_BUTTON_WIDTH = 16;

E.Layout = LO;

function LO:Initialize()
	self:CreateChatPanels()
	self:CreateMinimapPanels()
	self:CreateExtraDataBarPanels()
	self:CreateMoverPopup()
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

	if self == LeftChatToggleButton then
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L['Left Click:'], L['Toggle Chat Frame'], 1, 1, 1)
	else
		GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT', 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L['Left Click:'], L['Toggle Chat Frame'], 1, 1, 1)
		GameTooltip:AddDoubleLine(L['Right Click:'], L['Toggle Embedded Addon'], 1, 1, 1)
	end

	GameTooltip:Show()
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
	if btn == 'RightButton' then
		if IsAddOnLoaded('Recount') and E.db.skins.embedRight == 'Recount' then
			ToggleFrame(Recount_MainWindow)
		elseif IsAddOnLoaded('Omen') and E.db.skins.embedRight == 'Omen' then
			ToggleFrame(OmenAnchor)
		elseif IsAddOnLoaded('Skada') and E.db.skins.embedRight == 'Skada' then
			Skada:ToggleWindow()
		end
	else
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

function LO:ToggleChatPanels()
	LeftChatDataPanel:ClearAllPoints()
	RightChatDataPanel:ClearAllPoints()
	if E.db.general.panelBackdrop == 'SHOWBOTH' then
		LeftChatPanel.backdrop:Show()
		LeftChatTab:Show()
		RightChatPanel.backdrop:Show()
		RightChatTab:Show()		
		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', 5 + SIDE_BUTTON_WIDTH, 5)
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMRIGHT', -5, (5 + PANEL_HEIGHT))		
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'BOTTOMLEFT', 5, 5)
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'BOTTOMRIGHT', -(5 + SIDE_BUTTON_WIDTH), 5 + PANEL_HEIGHT)		
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', 5, 5)
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', -5, 5)
	elseif E.db.general.panelBackdrop == 'HIDEBOTH' then
		LeftChatPanel.backdrop:Hide()
		LeftChatTab:Hide()
		RightChatPanel.backdrop:Hide()
		RightChatTab:Hide()		
		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', SIDE_BUTTON_WIDTH, 0)
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMRIGHT', 0, PANEL_HEIGHT)		
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'BOTTOMLEFT')
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'BOTTOMRIGHT', -SIDE_BUTTON_WIDTH, PANEL_HEIGHT)		
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT')
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT')
	elseif E.db.general.panelBackdrop == 'LEFT' then
		LeftChatPanel.backdrop:Show()
		LeftChatTab:Show()
		RightChatPanel.backdrop:Hide()
		RightChatTab:Hide()		
		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', 5 + SIDE_BUTTON_WIDTH, 5)
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMRIGHT', -5, (5 + PANEL_HEIGHT))			
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'BOTTOMLEFT')
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'BOTTOMRIGHT', -SIDE_BUTTON_WIDTH, PANEL_HEIGHT)			
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', 5, 5)
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT')
	else
		LeftChatPanel.backdrop:Hide()
		LeftChatTab:Hide()
		RightChatPanel.backdrop:Show()
		RightChatTab:Show()		
		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', SIDE_BUTTON_WIDTH, 0)
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMRIGHT', 0, PANEL_HEIGHT)			
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'BOTTOMLEFT', 5, 5)
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'BOTTOMRIGHT', -(5 + SIDE_BUTTON_WIDTH), 5 + PANEL_HEIGHT)		
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT')
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', -5, 5)
	end
end

function LO:CreateChatPanels()
	--Left Chat
	local lchat = CreateFrame('Frame', 'LeftChatPanel', E.UIParent)
	lchat:SetFrameStrata('BACKGROUND')
	lchat:Size(E.db.general.panelWidth, E.db.general.panelHeight)		
	lchat:Point('BOTTOMLEFT', E.UIParent, 4, 4)
	lchat:CreateBackdrop('Transparent')
	lchat.backdrop:SetAllPoints()
	
	--Background Texture
	lchat.tex = lchat:CreateTexture(nil, 'OVERLAY')
	lchat.tex:Point('TOPLEFT', lchat, 'TOPLEFT', 2, -2)
	lchat.tex:Point('BOTTOMRIGHT', lchat, 'BOTTOMRIGHT', -2, 2)
	lchat.tex:SetTexture(E.db.general.panelBackdropNameLeft)
	lchat.tex:SetAlpha(E.db.general.backdropfadecolor.a - 0.7 > 0 and E.db.general.backdropfadecolor.a - 0.7 or 0.5)
	
	--Left Chat Tab
	local lchattab = CreateFrame('Frame', 'LeftChatTab', LeftChatPanel)
	lchattab:Point('TOPLEFT', lchat, 'TOPLEFT', 5, -5)
	lchattab:Point('BOTTOMRIGHT', lchat, 'TOPRIGHT', -5, -(5 + PANEL_HEIGHT))
	lchattab:SetTemplate('Default', true)
	
	--Left Chat Data Panel
	local lchatdp = CreateFrame('Frame', 'LeftChatDataPanel', LeftChatPanel)
	lchatdp:Point('BOTTOMLEFT', lchat, 'BOTTOMLEFT', 5 + SIDE_BUTTON_WIDTH, 5)
	lchatdp:Point('TOPRIGHT', lchat, 'BOTTOMRIGHT', -5, (5 + PANEL_HEIGHT))
	lchatdp:SetTemplate('Default', true)
	
	E:GetModule('DataTexts'):RegisterPanel(lchatdp, 3, 'ANCHOR_TOPLEFT', -17, 4)
	
	--Left Chat Toggle Button
	local lchattb = CreateFrame('Button', 'LeftChatToggleButton', E.UIParent)
	lchattb.parent = LeftChatPanel
	LeftChatPanel.fadeFunc = ChatPanelLeft_OnFade
	lchattb:Point('TOPRIGHT', lchatdp, 'TOPLEFT', -1, 0)
	lchattb:Point('BOTTOMLEFT', lchat, 'BOTTOMLEFT', 5, 5)
	lchattb:SetTemplate('Default', true)
	lchattb:SetScript('OnEnter', ChatButton_OnEnter)
	lchattb:SetScript('OnLeave', ChatButton_OnLeave)
	lchattb:SetScript('OnClick', ChatButton_OnClick)
	lchattb.text = lchattb:CreateFontString(nil, 'OVERLAY')
	lchattb.text:FontTemplate()
	lchattb.text:SetPoint('CENTER')
	lchattb.text:SetJustifyH('CENTER')
	lchattb.text:SetText('<')
	
	--Right Chat
	local rchat = CreateFrame('Frame', 'RightChatPanel', E.UIParent)
	rchat:SetFrameStrata('BACKGROUND')
	rchat:Size(E.db.general.panelWidth, E.db.general.panelHeight)
	rchat:Point('BOTTOMRIGHT', E.UIParent, -4, 4)
	rchat:CreateBackdrop('Transparent')
	rchat.backdrop:SetAllPoints()
	
	--Background Texture
	rchat.tex = rchat:CreateTexture(nil, 'OVERLAY')
	rchat.tex:Point('TOPLEFT', rchat, 'TOPLEFT', 2, -2)
	rchat.tex:Point('BOTTOMRIGHT', rchat, 'BOTTOMRIGHT', -2, 2)
	rchat.tex:SetTexture(E.db.general.panelBackdropNameRight)
	rchat.tex:SetAlpha(E.db.general.backdropfadecolor.a - 0.7 > 0 and E.db.general.backdropfadecolor.a - 0.7 or 0.5)	
	
	--Right Chat Tab
	local rchattab = CreateFrame('Frame', 'RightChatTab', RightChatPanel)
	rchattab:Point('TOPRIGHT', rchat, 'TOPRIGHT', -5, -5)
	rchattab:Point('BOTTOMLEFT', rchat, 'TOPLEFT', 5, -(5 + PANEL_HEIGHT))
	rchattab:SetTemplate('Default', true)
	
	--Right Chat Data Panel
	local rchatdp = CreateFrame('Frame', 'RightChatDataPanel', RightChatPanel)
	rchatdp:Point('BOTTOMLEFT', rchat, 'BOTTOMLEFT', 5, 5)
	rchatdp:Point('TOPRIGHT', rchat, 'BOTTOMRIGHT', -(5 + SIDE_BUTTON_WIDTH), 5 + PANEL_HEIGHT)
	rchatdp:SetTemplate('Default', true)
	E:GetModule('DataTexts'):RegisterPanel(rchatdp, 3, 'ANCHOR_TOPRIGHT', 17, 4)
	
	--Right Chat Toggle Button
	local rchattb = CreateFrame('Button', 'RightChatToggleButton', E.UIParent)
	rchattb.parent = RightChatPanel
	RightChatPanel.fadeFunc = ChatPanelRight_OnFade
	rchattb:Point('TOPLEFT', rchatdp, 'TOPRIGHT', 1, 0)
	rchattb:Point('BOTTOMRIGHT', rchat, 'BOTTOMRIGHT', -5, 5)
	rchattb:SetTemplate('Default', true)
	rchattb:RegisterForClicks('AnyUp')
	rchattb:SetScript('OnEnter', ChatButton_OnEnter)
	rchattb:SetScript('OnLeave', ChatButton_OnLeave)
	rchattb:SetScript('OnClick', ChatButton_OnClick)
	rchattb.text = rchattb:CreateFontString(nil, 'OVERLAY')
	rchattb.text:FontTemplate()
	rchattb.text:SetPoint('CENTER')
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
	lminipanel:Point('TOPLEFT', Minimap, 'BOTTOMLEFT', -2, -3)
	lminipanel:Point('BOTTOMRIGHT', Minimap, 'BOTTOM', -21, -(3 + PANEL_HEIGHT))
	lminipanel:SetTemplate('Default', true)
	E:GetModule('DataTexts'):RegisterPanel(lminipanel, 1, 'ANCHOR_BOTTOMLEFT', lminipanel:GetWidth() * 2, -4)
	
	local rminipanel = CreateFrame('Frame', 'RightMiniPanel', Minimap)
	rminipanel:Point('TOPRIGHT', Minimap, 'BOTTOMRIGHT', 2, -3)
	rminipanel:Point('BOTTOMLEFT', Minimap, 'BOTTOM', -20, -(3 + PANEL_HEIGHT))
	rminipanel:SetTemplate('Default', true)
	E:GetModule('DataTexts'):RegisterPanel(rminipanel, 1, 'ANCHOR_BOTTOM', 0, -4)
	
	if E.db.general.minimapPanels then
		LeftMiniPanel:Show()
		RightMiniPanel:Show()
	else
		LeftMiniPanel:Hide()
		RightMiniPanel:Hide()
	end
	
	local configtoggle = CreateFrame('Button', 'ElvConfigToggle', Minimap)
	configtoggle:Point('TOPLEFT', rminipanel, 'TOPRIGHT', 1, 0)
	configtoggle:Point('BOTTOMLEFT', rminipanel, 'BOTTOMRIGHT', 1, 0)
	configtoggle:RegisterForClicks('AnyUp')
	configtoggle:Width(E.RBRWidth)
	configtoggle:SetTemplate('Default', true)
	configtoggle.text = configtoggle:CreateFontString(nil, 'OVERLAY')
	configtoggle.text:FontTemplate()
	configtoggle.text:SetText('C')
	configtoggle.text:SetPoint('CENTER')
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
		GameTooltip:AddDoubleLine(L['Left Click:'], L['Toggle Configuration'], 1, 1, 1)
		
		if E.db.datatexts.battleground then
			GameTooltip:AddDoubleLine(L['Right Click:'], L['Show BG Texts'], 1, 1, 1)	
		end
		GameTooltip:Show()
	end)
	configtoggle:SetScript('OnLeave', function(self)
		GameTooltip:Hide()
	end)
end

function LO:CreateExtraDataBarPanels()
	local chattab1 = CreateFrame('Frame', 'ChatTab_Datatext_Panel', E.UIParent)
	chattab1:SetScript('OnShow', function(self)
		chattab1:Point("TOPRIGHT", RightChatTab, "TOPRIGHT", 0, 0)
		chattab1:Point("BOTTOMLEFT", RightChatTab, "BOTTOMLEFT", (E.db.general.panelWidth / 3), 0)
	end)
	chattab1:Hide()
	E:GetModule('DataTexts'):RegisterPanel(chattab1, 2, 'ANCHOR_BOTTOM', 0, -4)
	
	local bottom_bar = CreateFrame('Frame', 'Bottom_Datatext_Panel', E.UIParent)
	bottom_bar:SetTemplate('Default', true)
	bottom_bar:SetFrameStrata('BACKGROUND')
	bottom_bar:SetScript('OnShow', function(self)
		self:Point("TOPLEFT", ElvUI_Bar1, "BOTTOMLEFT", 0, -E.mult); 
		self:Size(ElvUI_Bar1:GetWidth(), PANEL_HEIGHT); 
		E:CreateMover(self, "BottomBarMover", "Bottom Datatext Frame") 
	end)
	E:GetModule('DataTexts'):RegisterPanel(Bottom_Datatext_Panel, 3, 'ANCHOR_BOTTOM', 0, -4)
	bottom_bar:Hide()
	
	RightChatTab:HookScript("OnHide", function() 
		chattab1:Hide() 
	end)
	RightChatTab:HookScript("OnShow", function() 
		chattab1:Show() 
		chattab1:SetAlpha(RightChatTab:GetAlpha()) 
	end)
end

function ExtraDataBarSetup()
	ChatTab_Datatext_Panel:Show()
	Bottom_Datatext_Panel:Show()
end

function LO:PLAYER_ENTERING_WORLD(...)
	ExtraDataBarSetup()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
end

function LO:CreateMoverPopup()
	local f = CreateFrame("Frame", "ElvUIMoverPopupWindow", UIParent)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:SetWidth(360)
	f:SetHeight(110)
	f:SetTemplate('Transparent')
	f:SetPoint("TOP", 0, -50)
	f:Hide()
	f:SetScript("OnShow", function() PlaySound("igMainMenuOption"); E:Grid_Show() end)
	f:SetScript("OnHide", function() PlaySound("gsTitleOptionExit"); E:Grid_Hide() end)

	local S = E:GetModule('Skins')

	local header = CreateFrame('Button', nil, f)
	header:SetTemplate('Default', true)
	header:SetWidth(100); header:SetHeight(25)
	header:SetPoint("CENTER", f, 'TOP')
	header:SetFrameLevel(header:GetFrameLevel() + 2)
	header:EnableMouse(true)
	header:RegisterForClicks('AnyUp', 'AnyDown')
	header:SetScript('OnMouseDown', function() f:StartMoving() end)
	header:SetScript('OnMouseUp', function() f:StopMovingOrSizing() end)
	
	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:SetPoint("CENTER", header, "CENTER")
	title:SetText('ElvUI')
		
	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:SetPoint("TOPLEFT", 18, -32)
	desc:SetPoint("BOTTOMRIGHT", -18, 48)
	desc:SetText(L["Movers unlocked. Move them now and click Lock when you are done."])

	local snapping = CreateFrame("CheckButton", "ElvUISnapping", f, "OptionsCheckButtonTemplate")
	_G[snapping:GetName() .. "Text"]:SetText(L["Sticky Frames"])

	snapping:SetScript("OnShow", function(self)
		self:SetChecked(E.db.general.stickyFrames)
	end)

	snapping:SetScript("OnClick", function(self)
		E.db.general.stickyFrames = self:GetChecked()
	end)

	local lock = CreateFrame("Button", "ElvUILock", f, "OptionsButtonTemplate")
	_G[lock:GetName() .. "Text"]:SetText(L["Lock"])

	lock:SetScript("OnClick", function(self)
		local ACD = LibStub("AceConfigDialog-3.0")
		E:MoveUI(false)
		self:GetParent():Hide()
		ACD['Open'](ACD, 'ElvUI') 
	end)
	
	local align = CreateFrame('EditBox', 'AlignBox', f, 'InputBoxTemplate')
	align:Width(24)
	align:Height(17)
	align:SetAutoFocus(false)
	align:SetScript("OnEscapePressed", function(self)
		self:SetText(E.db.gridSize)
		EditBox_ClearFocus(self)
	end)
	align:SetScript("OnEnterPressed", function(self)
		local text = self:GetText()
		if tonumber(text) then
			if tonumber(text) <= 256 and tonumber(text) >= 4 then
				E.db.gridSize = tonumber(text)
			else
				self:SetText(E.db.gridSize)
			end
		else
			self:SetText(E.db.gridSize)
		end
		E:Grid_Show()
		EditBox_ClearFocus(self)
	end)
	align:SetScript("OnEditFocusLost", function(self)
		self:SetText(E.db.gridSize)
	end)
	align:SetScript("OnEditFocusGained", align.HighlightText)
	align:SetScript('OnShow', function(self)
		EditBox_ClearFocus(self)
		self:SetText(E.db.gridSize)
	end)
	
	align.text = align:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	align.text:SetPoint('RIGHT', align, 'LEFT', -4, 0)
	align.text:SetText(L['Grid Size:'])

	--position buttons
	snapping:SetPoint("BOTTOMLEFT", 14, 10)
	lock:SetPoint("BOTTOMRIGHT", -14, 14)
	align:SetPoint('TOPRIGHT', lock, 'TOPLEFT', -4, -2)
	
	S:HandleCheckBox(snapping)
	S:HandleButton(lock)
	S:HandleEditBox(align)
	
	f:RegisterEvent('PLAYER_REGEN_DISABLED')
	f:SetScript('OnEvent', function(self)
		if self:IsShown() then
			self:Hide()
		end
	end)
end

LO:RegisterEvent('PLAYER_ENTERING_WORLD')
E:RegisterModule(LO:GetName())