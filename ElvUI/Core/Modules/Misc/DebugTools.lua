local E, L, V, P, G = unpack(ElvUI)
local D = E:GetModule('DebugTools')

local _G = _G
local format = format
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local GetCVarBool = GetCVarBool
local StaticPopup_Hide = StaticPopup_Hide

local BUTTON_WIDTH = 75
local BUTTON_HEIGHT = 23
local BUTTON_SPACING = 2

D.HideFrame = CreateFrame('Frame')

local function UnHighlightText(text)
	text:HighlightText(0, 0)
end

local function FirstButton_OnClick(button)
	button.frame.index = 1
	button.frame:Update()
end

local function LastButton_OnClick(button)
	button.frame.index = #button.frame.order
	button.frame:Update()
end

local function ScriptErrors_UnHighlightText()
	_G.ScriptErrorsFrame.ScrollFrame.Text:HighlightText(0, 0)
end

function D:ModifyErrorFrame()
	local frame = _G.ScriptErrorsFrame
	frame.ScrollFrame.Text.cursorOffset = 0
	frame.ScrollFrame.Text.cursorHeight = 0
	frame.ScrollFrame.Text:SetScript('OnEditFocusGained', nil)

	hooksecurefunc(frame, 'Update', ScriptErrors_UnHighlightText)

	-- Unhighlight text when focus is hit
	frame.ScrollFrame.Text:HookScript('OnEscapePressed', UnHighlightText)
	frame:Size(500, 300)
	frame.ScrollFrame:Size(frame:GetWidth() - 45, frame:GetHeight() - 71)

	-- Add a first button
	local firstButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
	firstButton:Point('BOTTOMLEFT', frame.Reload, 'BOTTOMRIGHT', BUTTON_SPACING, 0)
	firstButton:SetText('First')
	firstButton:Size(BUTTON_WIDTH, BUTTON_HEIGHT)
	firstButton:SetScript('OnClick', FirstButton_OnClick)
	firstButton.frame = frame
	frame.firstButton = firstButton

	-- Also add a Last button for errors
	local lastButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
	lastButton:Point('BOTTOMRIGHT', frame.Close, 'BOTTOMLEFT', -BUTTON_SPACING, 0)
	lastButton:Size(BUTTON_WIDTH, BUTTON_HEIGHT)
	lastButton:SetText('Last')
	lastButton:SetScript('OnClick', LastButton_OnClick)
	lastButton.frame = frame
	frame.lastButton = lastButton

	D:ScriptErrorsFrame_UpdateButtons()
	D:Unhook(frame, 'OnShow')
end

function D:ScriptErrorsFrame_UpdateButtons()
	local frame = _G.ScriptErrorsFrame
	if not frame.firstButton then return end

	if frame.index == 0 or #frame.order == 1 then
		frame.lastButton:Disable()
		frame.firstButton:Disable()
	else
		frame.lastButton:Enable()
		frame.firstButton:Enable()
	end
end

function D:ScriptErrorsFrame_OnError(_, _, keepHidden)
	if keepHidden or D.MessagePrinted or not InCombatLockdown() or not GetCVarBool('scriptErrors') then return end

	E:Print(L["|cFFE30000Lua error recieved. You can view the error message when you exit combat."])
	D.MessagePrinted = true
end

function D:PLAYER_REGEN_ENABLED()
	_G.ScriptErrorsFrame:SetParent(_G.UIParent)
	D.MessagePrinted = nil
end

function D:PLAYER_REGEN_DISABLED()
	_G.ScriptErrorsFrame:SetParent(D.HideFrame)
end

function D:TaintError(event, addonName, addonFunc)
	if not E.db.general.taintLog or not GetCVarBool('scriptErrors') then return end
	_G.ScriptErrorsFrame:OnError(format(L["%s: %s tried to call the protected function '%s'."], event, addonName or '<name>', addonFunc or '<func>'), false, false)
end

function D:StaticPopup_Show(name)
	if name == 'ADDON_ACTION_FORBIDDEN' then
		StaticPopup_Hide(name)
	end
end

function D:Initialize()
	D.Initialized = true
	D.HideFrame:Hide()

	local frame = _G.ScriptErrorsFrame
	D:SecureHookScript(frame, 'OnShow', D.ModifyErrorFrame)
	D:SecureHook(frame, 'UpdateButtons', D.ScriptErrorsFrame_UpdateButtons)
	D:SecureHook(frame, 'OnError', D.ScriptErrorsFrame_OnError)
	D:SecureHook('StaticPopup_Show')

	D:RegisterEvent('PLAYER_REGEN_DISABLED')
	D:RegisterEvent('PLAYER_REGEN_ENABLED')
	D:RegisterEvent('ADDON_ACTION_BLOCKED', 'TaintError')
	D:RegisterEvent('ADDON_ACTION_FORBIDDEN', 'TaintError')
end

E:RegisterModule(D:GetName())
