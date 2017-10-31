local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local GetCVar = GetCVar
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.debug ~= true then return end

	local ScriptErrorsFrame = _G["ScriptErrorsFrame"]
	ScriptErrorsFrame:SetParent(E.UIParent)
	ScriptErrorsFrame:SetTemplate('Transparent')
	S:HandleScrollBar(ScriptErrorsFrameScrollBar)
	S:HandleCloseButton(ScriptErrorsFrameClose)
	ScriptErrorsFrame.ScrollFrame.Text:FontTemplate(nil, 13)
	ScriptErrorsFrame.ScrollFrame:CreateBackdrop('Default')
	ScriptErrorsFrame.ScrollFrame:SetFrameLevel(ScriptErrorsFrame.ScrollFrame:GetFrameLevel() + 2)
	EventTraceFrame:SetTemplate("Transparent")
	local texs = {
		"TopLeft",
		"TopRight",
		"Top",
		"BottomLeft",
		"BottomRight",
		"Bottom",
		"Left",
		"Right",
		"TitleBG",
		"DialogBG",
	}

	for i=1, #texs do
		_G["ScriptErrorsFrame"..texs[i]]:SetTexture(nil)
		_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
	end

	S:HandleButton(ScriptErrorsFrame.Reload)
	S:HandleButton(ScriptErrorsFrame.Close)
	S:HandleButton(ScriptErrorsFrame.firstButton)
	S:HandleButton(ScriptErrorsFrame.lastButton)
	S:HandleNextPrevButton(ScriptErrorsFrame.PreviousError, nil, true)
	S:HandleNextPrevButton(ScriptErrorsFrame.NextError)

	FrameStackTooltip:HookScript("OnShow", function(self)
		local noscalemult = E.mult * GetCVar('uiScale')
		self:SetBackdrop({
			bgFile = E["media"].blankTex,
			edgeFile = E["media"].blankTex,
			tile = false, tileSize = 0, edgeSize = noscalemult,
			insets = { left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
		})
		self:SetBackdropColor(unpack(E["media"].backdropfadecolor))
		self:SetBackdropBorderColor(unpack(E["media"].bordercolor))
	end)

	EventTraceTooltip:HookScript("OnShow", function(self)
		self:SetTemplate("Transparent")
	end)

	S:HandleCloseButton(EventTraceFrameCloseButton)
end

S:AddCallbackForAddon("Blizzard_DebugTools", "SkinDebugTools", LoadSkin)