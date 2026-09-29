local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local C_AzeriteEssence_CanOpenUI = C_AzeriteEssence.CanOpenUI

local function EssenceListScrollUpdateChild(button)
	if not button.IsSkinned then
		button:DisableDrawLayer('ARTWORK')
		button:StyleButton()

		local icon = button.Icon
		if icon then
			S:HandleIcon(icon, true)

			icon:ClearAllPoints()
			icon:Point('TOPLEFT', button, 4, -4)
			icon:Size(33)
		end

		button:CreateBackdrop('Transparent')
		button.backdrop:SetInside(button, 1, 1)
		button.hover:SetInside(button.backdrop)

		if button.PendingGlow then
			button.PendingGlow:SetColorTexture(0.9, 0.8, 0.1, 0.3)
			button.PendingGlow:SetInside(button.backdrop)
		end

		button.IsSkinned = true
	end
end

local function EssenceListScrollUpdate(frame)
	frame:ForEachFrame(EssenceListScrollUpdateChild)
end

function S:Blizzard_AzeriteEssenceUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.azeriteEssence) then return end
	if not C_AzeriteEssence_CanOpenUI() then return end

	local AzeriteEssenceUI = _G.AzeriteEssenceUI
	S:HandlePortraitFrame(AzeriteEssenceUI)

	-- Reposition the Level Badge
	AzeriteEssenceUI.PowerLevelBadgeFrame:ClearAllPoints()
	AzeriteEssenceUI.PowerLevelBadgeFrame:Point('TOPLEFT')
	AzeriteEssenceUI.PowerLevelBadgeFrame.Ring:Hide()
	AzeriteEssenceUI.PowerLevelBadgeFrame.BackgroundBlack:Hide()

	AzeriteEssenceUI.OrbBackground:SetAllPoints(AzeriteEssenceUI.ItemModelScene)
	AzeriteEssenceUI.OrbRing:Size(483, 480)

	S:HandleTrimScrollBar(AzeriteEssenceUI.EssenceList.ScrollBar)

	-- Essence List on the right
	hooksecurefunc(AzeriteEssenceUI.EssenceList.ScrollBox, 'Update', EssenceListScrollUpdate)
end

S:AddCallbackForAddon('Blizzard_AzeriteEssenceUI')
