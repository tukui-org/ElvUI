local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AzeriteRespec ~= true then return end

	local AzeriteRespecFrame = _G["AzeriteRespecFrame"]
	-- We can't use StripTextures() otherwise all gets killed. Not coolio!
	AzeriteRespecFramePortraitFrame:Hide()
	AzeriteRespecFramePortrait:Hide()
	AzeriteRespecFrameTitleBg:Hide()
	AzeriteRespecFrameTopBorder:Hide()
	AzeriteRespecFrameTopRightCorner:Hide()
	AzeriteRespecFrameRightBorder:Hide()
	AzeriteRespecFrameLeftBorder:Hide()
	AzeriteRespecFrameBottomBorder:Hide()
	AzeriteRespecFrameBotRightCorner:Hide()
	AzeriteRespecFrameBotLeftCorner:Hide()
	AzeriteRespecFrameBg:Hide()
	AzeriteRespecFrame.ButtonFrame:StripTextures()
	AzeriteRespecFrame.ButtonFrame.AzeriteRespecButton.LeftSeparator:Hide()
	AzeriteRespecFrame.ButtonFrame.MoneyFrameEdge:Hide()

	AzeriteRespecFrame:CreateBackdrop("Transparent")
	AzeriteRespecFrame.backdrop:SetAllPoints()

	S:HandleButton(AzeriteRespecFrame.ButtonFrame.AzeriteRespecButton)
	S:HandleCloseButton(AzeriteRespecFrameCloseButton)
end

S:AddCallbackForAddon("Blizzard_AzeriteRespecUI", "AzeriteRespec", LoadSkin)