local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.artifact ~= true then return end

	local ArtifactFrame = _G["ArtifactFrame"]
	ArtifactFrame:StripTextures()
	ArtifactFrame:CreateBackdrop("Transparent")
	ArtifactFrame.BorderFrame:StripTextures()
	S:HandleCloseButton(ArtifactFrame.CloseButton)

	for i = 1, 2 do
		S:HandleTab(_G["ArtifactFrameTab" .. i])
	end

	local ArtifactFrameTab1 = _G["ArtifactFrameTab1"]
	ArtifactFrameTab1:ClearAllPoints()
	ArtifactFrameTab1:SetPoint("TOPLEFT", ArtifactFrame, "BOTTOMLEFT", 0, 0)

	ArtifactFrame.ForgeBadgeFrame.ItemIcon:Hide()
	ArtifactFrame.ForgeBadgeFrame.ForgeLevelBackground:ClearAllPoints()
	ArtifactFrame.ForgeBadgeFrame.ForgeLevelBackground:SetPoint("TOPLEFT", ArtifactFrame)

	--Tutorial
	S:HandleCloseButton(ArtifactFrame.KnowledgeLevelHelpBox.CloseButton)
	S:HandleCloseButton(ArtifactFrame.AppearanceTabHelpBox.CloseButton)
end

S:AddCallbackForAddon("Blizzard_ArtifactUI", "Artifact", LoadSkin)