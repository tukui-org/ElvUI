local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Warboard ~= true then return end

	local WarboardQuestChoiceFrame = _G["WarboardQuestChoiceFrame"]
	WarboardQuestChoiceFrame:CreateBackdrop("Transparent")

	S:HandleCloseButton(WarboardQuestChoiceFrame.CloseButton)
	S:HandleButton(WarboardQuestChoiceFrameOption1.OptionButton)
	S:HandleButton(WarboardQuestChoiceFrameOption2.OptionButton)
	S:HandleButton(WarboardQuestChoiceFrameOption3.OptionButton)

	WarboardQuestChoiceFrame.Top:Hide()
	WarboardQuestChoiceFrame.Bottom:Hide()
	WarboardQuestChoiceFrame.Left:Hide()
	WarboardQuestChoiceFrame.Right:Hide()

	WarboardQuestChoiceFrameTopRightCorner:Hide()
	WarboardQuestChoiceFrame.topLeftCorner:Hide()
	WarboardQuestChoiceFrame.topBorderBar:Hide()
	WarboardQuestChoiceFrameBotRightCorner:Hide()
	WarboardQuestChoiceFrameBotLeftCorner:Hide()
	WarboardQuestChoiceFrameBottomBorder:Hide()
	WarboardQuestChoiceFrame.leftBorderBar:Hide()
	WarboardQuestChoiceFrameRightBorder:Hide()

	WarboardQuestChoiceFrame.GarrCorners:Hide()

	WarboardQuestChoiceFrame.Background:Hide()
	WarboardQuestChoiceFrame.Title.Left:Hide()
	WarboardQuestChoiceFrame.Title.Right:Hide()
	WarboardQuestChoiceFrame.Title.Middle:Hide()

	WarboardQuestChoiceFrame.Header:SetSize(354, 105)
	WarboardQuestChoiceFrame.Header:SetPoint("TOP", 0, 80)
	WarboardQuestChoiceFrame.Title:SetSize(500, 85)
	WarboardQuestChoiceFrame.Title.Text:FontTemplate(nil, 22)
end

S:AddCallbackForAddon("Blizzard_WarboardUI", "Warboard", LoadSkin)