local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local select = select
local unpack = unpack
local hooksecurefunc = hooksecurefunc

function S:Blizzard_ArtifactUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.artifact) then return end

	local ArtifactFrame = _G.ArtifactFrame
	ArtifactFrame:StripTextures()
	ArtifactFrame:SetTemplate('Transparent')
	ArtifactFrame.BorderFrame:StripTextures()
	S:HandleCloseButton(ArtifactFrame.CloseButton)

	for i = 1, 2 do
		S:HandleTab(_G['ArtifactFrameTab' .. i])
	end

	local ArtifactFrameTab1 = _G.ArtifactFrameTab1
	ArtifactFrameTab1:ClearAllPoints()
	ArtifactFrameTab1:Point('TOPLEFT', ArtifactFrame, 'BOTTOMLEFT', 0, 0)

	ArtifactFrame.ForgeBadgeFrame.ItemIcon:Hide()
	ArtifactFrame.ForgeBadgeFrame.ForgeLevelBackground:ClearAllPoints()
	ArtifactFrame.ForgeBadgeFrame.ForgeLevelBackground:Point('TOPLEFT', ArtifactFrame)

	ArtifactFrame.AppearancesTab:HookScript('OnShow', function(s)
		for i=1, s:GetNumChildren() do
			local child = select(i, s:GetChildren())
			if child and child.appearanceID and not child.backdrop then
				child:CreateBackdrop('Transparent')
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

				hooksecurefunc(child.Selected, 'SetShown', function(_, isActive)
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

S:AddCallbackForAddon('Blizzard_ArtifactUI')
