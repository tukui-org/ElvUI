local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local select = select
local unpack = unpack
local hooksecurefunc = hooksecurefunc

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

	ArtifactFrame.AppearancesTab:HookScript("OnShow", function(self)
		for i=1, self:GetNumChildren() do
			local child = select(i, self:GetChildren())
			if child and child.appearanceID and not child.backdrop then
				child:CreateBackdrop("Transparent")
				child.SwatchTexture:SetTexCoord(.20,.80,.20,.80)
				child.SwatchTexture:SetInside(child.backdrop)
				child.Border:SetAlpha(0)
				child.Background:SetAlpha(0)
				child.HighlightTexture:SetAlpha(0)
				child.HighlightTexture.SetAlpha = E.noop
				if child.Selected:IsShown() then
					child.backdrop:SetBackdropBorderColor(1,1,1)
				end
				child.Selected:SetAlpha(0)
				child.Selected.SetAlpha = E.noop
				hooksecurefunc(child.Selected, "SetShown", function(_, isActive)
					if isActive then
						child.backdrop:SetBackdropBorderColor(1,1,1)
					else
						child.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end
				end)
			end
		end
	end)
end

S:AddCallbackForAddon("Blizzard_ArtifactUI", "Artifact", LoadSkin)
