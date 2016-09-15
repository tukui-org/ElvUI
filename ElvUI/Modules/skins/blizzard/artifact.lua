local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.artifact ~= true then return end
	
	ArtifactFrame:StripTextures()
	ArtifactFrame:CreateBackdrop("Transparent")
	ArtifactFrame.BorderFrame:StripTextures()
	S:HandleCloseButton(ArtifactFrame.CloseButton)
	
	for i = 1, 2 do
		S:HandleTab(_G["ArtifactFrameTab" .. i])
	end
	
	ArtifactFrameTab1:ClearAllPoints()
	ArtifactFrameTab1:SetPoint("TOPLEFT", ArtifactFrame, "BOTTOMLEFT", 0, 0)

	ArtifactFrame.ForgeBadgeFrame.ForgeClassBadgeIcon:Hide()
	ArtifactFrame.ForgeBadgeFrame.ForgeLevelBackground:ClearAllPoints()
	ArtifactFrame.ForgeBadgeFrame.ForgeLevelBackground:SetPoint("TOPLEFT", ArtifactFrame)
end

S:AddCallbackForAddon("Blizzard_ArtifactUI", "Artifact", LoadSkin)