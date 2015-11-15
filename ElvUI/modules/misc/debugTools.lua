local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local D = E:NewModule('DebugTools', 'AceEvent-3.0', 'AceHook-3.0');
E.DebugTools = D

--Cache global variables
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local ScriptErrorsFrame_Update = ScriptErrorsFrame_Update
local InCombatLockdown = InCombatLockdown
local GetCVarBool = GetCVarBool
local ScriptErrorsFrame_OnError = ScriptErrorsFrame_OnError
local StaticPopup_Hide = StaticPopup_Hide

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ScriptErrorsFrameScrollFrameText, ScriptErrorsFrame, ScriptErrorsFrameScrollFrame
-- GLOBALS: UIParent, IsAddOnLoaded, LoadAddOn

function D:ModifyErrorFrame()
	ScriptErrorsFrameScrollFrameText.cursorOffset = 0
	ScriptErrorsFrameScrollFrameText.cursorHeight = 0
	ScriptErrorsFrameScrollFrameText:SetScript("OnEditFocusGained", nil)

	--[[local Orig_ScriptErrorsFrame_Update = ScriptErrorsFrame_Update
	ScriptErrorsFrame_Update = function(...)
		if GetCVarBool('scriptErrors') ~= true then
			Orig_ScriptErrorsFrame_Update(...)
			return
		end

		-- Sometimes the locals table does not have an entry for an index, which can cause an argument #6 error
		-- in Blizzard_DebugTools.lua:430 and then cause a C stack overflow, this will prevent that
		local index = ScriptErrorsFrame.index
		if( not index or not ScriptErrorsFrame.order[index] ) then
			index = #(ScriptErrorsFrame.order)
		end

		if( index > 0 ) then
			ScriptErrorsFrame.locals[index] = ScriptErrorsFrame.locals[index] or L["No locals to dump"]
		end

		Orig_ScriptErrorsFrame_Update(...)

		-- Stop text highlighting again
		ScriptErrorsFrameScrollFrameText:HighlightText(0, 0)
	end]]
	local function ScriptErrors_UnHighlightText()
		ScriptErrorsFrameScrollFrameText:HighlightText(0, 0)
	end
	hooksecurefunc('ScriptErrorsFrame_Update', ScriptErrors_UnHighlightText)

	-- Unhighlight text when focus is hit
	local function UnHighlightText(self)
		self:HighlightText(0, 0)
	end
	ScriptErrorsFrameScrollFrameText:HookScript("OnEscapePressed", UnHighlightText)


	ScriptErrorsFrame:SetSize(500, 300)
	ScriptErrorsFrameScrollFrame:SetSize(ScriptErrorsFrame:GetWidth() - 45, ScriptErrorsFrame:GetHeight() - 71)

	local BUTTON_WIDTH = 75
	local BUTTON_HEIGHT = 24
	local BUTTON_SPACING = 2

	-- Add a first button
	local firstButton = CreateFrame("Button", nil, ScriptErrorsFrame, "UIPanelButtonTemplate")
	firstButton:SetPoint("BOTTOM", ScriptErrorsFrame, "BOTTOM", -((BUTTON_WIDTH + BUTTON_WIDTH/2) + (BUTTON_SPACING * 4)), 8)
	firstButton:SetText("First")
	firstButton:SetHeight(BUTTON_HEIGHT)
	firstButton:SetWidth(BUTTON_WIDTH)
	firstButton:SetScript("OnClick", function(self)
		ScriptErrorsFrame.index = 1
		ScriptErrorsFrame_Update()
	end)
	ScriptErrorsFrame.firstButton = firstButton

	-- Also add a Last button for errors
	local lastButton = CreateFrame("Button", nil, ScriptErrorsFrame, "UIPanelButtonTemplate")
	lastButton:SetPoint("BOTTOMLEFT", ScriptErrorsFrame.next, "BOTTOMRIGHT", BUTTON_SPACING, 0)
	lastButton:SetHeight(BUTTON_HEIGHT)
	lastButton:SetWidth(BUTTON_WIDTH)
	lastButton:SetText("Last")
	lastButton:SetScript("OnClick", function(self)
		ScriptErrorsFrame.index = #(ScriptErrorsFrame.order)
		ScriptErrorsFrame_Update()
	end)
	ScriptErrorsFrame.lastButton = lastButton

	ScriptErrorsFrame.previous:ClearAllPoints()
	ScriptErrorsFrame.previous:SetPoint("BOTTOMLEFT", firstButton, "BOTTOMRIGHT", BUTTON_SPACING, 0)
	ScriptErrorsFrame.previous:SetWidth(BUTTON_WIDTH)
	ScriptErrorsFrame.previous:SetHeight(BUTTON_HEIGHT)

	ScriptErrorsFrame.next:ClearAllPoints()
	ScriptErrorsFrame.next:SetPoint("BOTTOMLEFT", ScriptErrorsFrame.previous, "BOTTOMRIGHT", BUTTON_SPACING, 0)
	ScriptErrorsFrame.next:SetWidth(BUTTON_WIDTH)
	ScriptErrorsFrame.next:SetHeight(BUTTON_HEIGHT)

	ScriptErrorsFrame.close:ClearAllPoints()
	ScriptErrorsFrame.close:SetPoint("BOTTOMRIGHT", ScriptErrorsFrame, "BOTTOMRIGHT", -8, 8)
	ScriptErrorsFrame.close:SetSize(75, BUTTON_HEIGHT)

	ScriptErrorsFrame.indexLabel:ClearAllPoints()
	ScriptErrorsFrame.indexLabel:SetPoint("BOTTOMLEFT", ScriptErrorsFrame, "BOTTOMLEFT", -6, 8)
end

function D:ScriptErrorsFrame_UpdateButtons()
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

function D:ScriptErrorsFrame_OnError(_, keepHidden)
	if keepHidden or self.MessagePrinted or not InCombatLockdown() or GetCVarBool('scriptErrors') ~= true then return; end

	E:Print(L["|cFFE30000Lua error recieved. You can view the error message when you exit combat."])
	self.MessagePrinted = true;
end

function D:PLAYER_REGEN_ENABLED()
	ScriptErrorsFrame:SetParent(UIParent)
	self.MessagePrinted = nil;
end

function D:PLAYER_REGEN_DISABLED()
	ScriptErrorsFrame:SetParent(self.HideFrame)
end

function D:TaintError(event, addonName, addonFunc)
	if GetCVarBool('scriptErrors') ~= true or E.db.general.taintLog ~= true then return end
	ScriptErrorsFrame_OnError(L["%s: %s tried to call the protected function '%s'."]:format(event, addonName or "<name>", addonFunc or "<func>"), false)
end

function D:StaticPopup_Show(name)
	if(name == "ADDON_ACTION_FORBIDDEN") then
		StaticPopup_Hide(name);
	end
end

function D:Initialize()
	self.HideFrame = CreateFrame('Frame')
	self.HideFrame:Hide()

	if( not IsAddOnLoaded("Blizzard_DebugTools") ) then
		LoadAddOn("Blizzard_DebugTools")
	end

	self:ModifyErrorFrame()
	self:SecureHook('ScriptErrorsFrame_UpdateButtons')
	self:SecureHook('ScriptErrorsFrame_OnError')
	self:SecureHook('StaticPopup_Show')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent("ADDON_ACTION_BLOCKED", "TaintError")
	self:RegisterEvent("ADDON_ACTION_FORBIDDEN", "TaintError")
end

E:RegisterModule(D:GetName())