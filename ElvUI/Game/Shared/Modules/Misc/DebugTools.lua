local E, L, V, P, G = unpack(ElvUI)
local D = E:GetModule('DebugTools')

local _G = _G
local hooksecurefunc = hooksecurefunc

local InCombatLockdown = InCombatLockdown
local CreateFrame = CreateFrame
local UIParent = UIParent

local StaticPopup_Hide = StaticPopup_Hide
local GetCVarBool = C_CVar.GetCVarBool

local BUTTON_WIDTH = 75
local BUTTON_HEIGHT = 23
local BUTTON_SPACING = 2

D.HideFrame = CreateFrame('Frame')

function D:ClearHighlight()
	self:HighlightText(0, 0)
end

function D:ScriptErrors_ClearHighlight()
	D.ClearHighlight(self.ScrollFrame.Text)
end

function D:OnClick_FirstButton()
	self.frame.index = 1
	self.frame:Update()
end

function D:OnClick_LastButton()
	local data = D:GetErrorData(self.frame)
	if not data then return end

	self.frame.index = #data
	self.frame:Update()
end

function D:GetErrorData(frame)
	return frame.errorData or frame.order
end

function D:ModifyErrorFrame()
	local frame = _G.ScriptErrorsFrame
	frame.ScrollFrame.Text.cursorOffset = 0
	frame.ScrollFrame.Text.cursorHeight = 0
	frame.ScrollFrame.Text:SetScript('OnEditFocusGained', nil)

	hooksecurefunc(frame, 'Update', D.ScriptErrors_ClearHighlight)

	-- Unhighlight text when focus is hit
	frame.ScrollFrame.Text:HookScript('OnEscapePressed', D.ClearHighlight)
	frame:Size(500, 300)
	frame.ScrollFrame:Size(frame:GetWidth() - 45, frame:GetHeight() - 71)

	-- Add a first button
	local firstButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
	firstButton:Point('BOTTOMLEFT', frame.Reload, 'BOTTOMRIGHT', BUTTON_SPACING, 0)
	firstButton:SetText('First')
	firstButton:Size(BUTTON_WIDTH, BUTTON_HEIGHT)
	firstButton:SetScript('OnClick', D.OnClick_FirstButton)
	firstButton.frame = frame
	frame.firstButton = firstButton

	-- Also add a Last button for errors
	local lastButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
	lastButton:Point('BOTTOMRIGHT', frame.Close, 'BOTTOMLEFT', -BUTTON_SPACING, 0)
	lastButton:Size(BUTTON_WIDTH, BUTTON_HEIGHT)
	lastButton:SetText('Last')
	lastButton:SetScript('OnClick', D.OnClick_LastButton)
	lastButton.frame = frame
	frame.lastButton = lastButton

	D:ScriptErrorsFrame_UpdateButtons()
	D:Unhook(frame, 'OnShow')
end

function D:ScriptErrorsFrame_UpdateButtons()
	local frame = _G.ScriptErrorsFrame
	if not frame.firstButton then return end

	local data = D:GetErrorData(frame)
	if frame.index == 0 or (data and #data == 1) then
		frame.lastButton:Disable()
		frame.firstButton:Disable()
	else
		frame.lastButton:Enable()
		frame.firstButton:Enable()
	end
end

function D:ScriptErrorsFrame_OnError()
	if D.MessagePrinted or not InCombatLockdown() or not GetCVarBool('scriptErrors') then return end

	E:Print(L["|cFFE30000Lua error recieved. You can view the error message when you exit combat."])

	D.MessagePrinted = true
end

function D:PLAYER_REGEN_ENABLED()
	_G.ScriptErrorsFrame:SetParent(UIParent)

	D.MessagePrinted = nil
end

function D:PLAYER_REGEN_DISABLED()
	_G.ScriptErrorsFrame:SetParent(D.HideFrame)
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
	D:SecureHook(frame, 'DisplayMessageInternal', D.ScriptErrorsFrame_OnError)
	D:SecureHook('StaticPopup_Show')

	D:RegisterEvent('PLAYER_REGEN_DISABLED')
	D:RegisterEvent('PLAYER_REGEN_ENABLED')
end

E:RegisterModule(D:GetName())
