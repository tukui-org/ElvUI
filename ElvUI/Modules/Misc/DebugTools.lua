local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local D = E:GetModule('DebugTools')

--WoW API / Variables
local _G = _G
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local GetCVarBool = GetCVarBool
local StaticPopup_Hide = StaticPopup_Hide

function D:ModifyErrorFrame()
	local ScriptErrorsFrame = _G.ScriptErrorsFrame
	ScriptErrorsFrame.ScrollFrame.Text.cursorOffset = 0
	ScriptErrorsFrame.ScrollFrame.Text.cursorHeight = 0
	ScriptErrorsFrame.ScrollFrame.Text:SetScript("OnEditFocusGained", nil)

	local function ScriptErrors_UnHighlightText()
		ScriptErrorsFrame.ScrollFrame.Text:HighlightText(0, 0)
	end
	hooksecurefunc(ScriptErrorsFrame, 'Update', ScriptErrors_UnHighlightText)

	-- Unhighlight text when focus is hit
	local function UnHighlightText(self) self:HighlightText(0, 0) end
	ScriptErrorsFrame.ScrollFrame.Text:HookScript("OnEscapePressed", UnHighlightText)

	ScriptErrorsFrame:Size(500, 300)
	ScriptErrorsFrame.ScrollFrame:Size(ScriptErrorsFrame:GetWidth() - 45, ScriptErrorsFrame:GetHeight() - 71)

	local BUTTON_WIDTH = 75
	local BUTTON_HEIGHT = 23
	local BUTTON_SPACING = 2

	-- Add a first button
	local firstButton = CreateFrame("Button", nil, ScriptErrorsFrame, "UIPanelButtonTemplate")
	firstButton:Point("BOTTOMLEFT", ScriptErrorsFrame.Reload, "BOTTOMRIGHT", BUTTON_SPACING, 0)
	firstButton:SetText("First")
	firstButton:Height(BUTTON_HEIGHT)
	firstButton:Width(BUTTON_WIDTH)
	firstButton:SetScript("OnClick", function()
		ScriptErrorsFrame.index = 1
		ScriptErrorsFrame:Update()
	end)
	ScriptErrorsFrame.firstButton = firstButton

	-- Also add a Last button for errors
	local lastButton = CreateFrame("Button", nil, ScriptErrorsFrame, "UIPanelButtonTemplate")
	lastButton:Point("BOTTOMRIGHT", ScriptErrorsFrame.Close, "BOTTOMLEFT", -BUTTON_SPACING, 0)
	lastButton:Height(BUTTON_HEIGHT)
	lastButton:Width(BUTTON_WIDTH)
	lastButton:SetText("Last")
	lastButton:SetScript("OnClick", function()
		ScriptErrorsFrame.index = #(ScriptErrorsFrame.order)
		ScriptErrorsFrame:Update()
	end)
	ScriptErrorsFrame.lastButton = lastButton

	D:ScriptErrorsFrame_UpdateButtons()
	D:Unhook(ScriptErrorsFrame, 'OnShow')
end

function D:ScriptErrorsFrame_UpdateButtons()
	local ScriptErrorsFrame = _G.ScriptErrorsFrame
	if not ScriptErrorsFrame.firstButton then return end

	local numErrors = #ScriptErrorsFrame.order;
	local index = ScriptErrorsFrame.index;
	if ( index == 0 ) then
		ScriptErrorsFrame.lastButton:Disable()
		ScriptErrorsFrame.firstButton:Disable()
	else
		if ( numErrors == 1 ) then
			ScriptErrorsFrame.lastButton:Disable()
			ScriptErrorsFrame.firstButton:Disable()
		else
			ScriptErrorsFrame.lastButton:Enable()
			ScriptErrorsFrame.firstButton:Enable()
		end
	end
end

function D:ScriptErrorsFrame_OnError(_, _, keepHidden)
	if keepHidden or D.MessagePrinted or not InCombatLockdown() or GetCVarBool('scriptErrors') ~= true then return; end

	E:Print(L["|cFFE30000Lua error recieved. You can view the error message when you exit combat."])
	D.MessagePrinted = true;
end

function D:PLAYER_REGEN_ENABLED()
	_G.ScriptErrorsFrame:SetParent(_G.UIParent)
	D.MessagePrinted = nil;
end

function D:PLAYER_REGEN_DISABLED()
	_G.ScriptErrorsFrame:SetParent(self.HideFrame)
end

function D:TaintError(event, addonName, addonFunc)
	if GetCVarBool('scriptErrors') ~= true or E.db.general.taintLog ~= true then return end
	_G.ScriptErrorsFrame:OnError(L["%s: %s tried to call the protected function '%s'."]:format(event, addonName or "<name>", addonFunc or "<func>"), false, false)
end

function D:StaticPopup_Show(name)
	if(name == "ADDON_ACTION_FORBIDDEN") then
		StaticPopup_Hide(name);
	end
end

function D:Initialize()
	self.Initialized = true
	self.HideFrame = CreateFrame('Frame')
	self.HideFrame:Hide()

	local ScriptErrorsFrame = _G.ScriptErrorsFrame
	self:SecureHookScript(ScriptErrorsFrame, 'OnShow', D.ModifyErrorFrame)
	self:SecureHook(ScriptErrorsFrame, 'UpdateButtons', D.ScriptErrorsFrame_UpdateButtons)
	self:SecureHook(ScriptErrorsFrame, 'OnError', D.ScriptErrorsFrame_OnError)
	self:SecureHook('StaticPopup_Show')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent("ADDON_ACTION_BLOCKED", "TaintError")
	self:RegisterEvent("ADDON_ACTION_FORBIDDEN", "TaintError")
end

E:RegisterModule(D:GetName())
