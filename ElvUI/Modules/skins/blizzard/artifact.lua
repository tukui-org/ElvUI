local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.artifact ~= true then return end
	
	ArtifactFrame:StripTextures()
	ArtifactFrame:SetTemplate("Transparent")
	ArtifactFrame.BorderFrame:StripTextures()
	S:HandleCloseButton(ArtifactFrame.CloseButton)
	
	for i = 1, 2 do
		-- Needs Review
		-- _G["ArtifactFrameTab" .. i]:ClearAllPoints()
		-- _G["ArtifactFrameTab" .. i]:SetAllPoints(ArtifactFrame)
		S:HandleTab(_G["ArtifactFrameTab" .. i])
	end
end

S:RegisterSkin("Blizzard_ArtifactUI", LoadSkin)