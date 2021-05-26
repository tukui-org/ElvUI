local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local C_AzeriteEssence_CanOpenUI = C_AzeriteEssence.CanOpenUI

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

	S:HandleScrollBar(AzeriteEssenceUI.EssenceList.ScrollBar)

	-- Essence List on the right
	for _, button in pairs(AzeriteEssenceUI.EssenceList.buttons) do
		button:DisableDrawLayer('ARTWORK')
		button:StyleButton()

		S:HandleIcon(button.Icon)
		button.Icon:Point('LEFT', button, 'LEFT', 6, 0)

		button:CreateBackdrop()
		button.backdrop:Point('TOPLEFT', 2, -3)
		button.backdrop:Point('BOTTOMRIGHT', -2, 3)
	end

	-- Header on the Essence List
	AzeriteEssenceUI:HookScript('OnShow', function(s)
		s.EssenceList.HeaderButton:StripTextures()
		s.EssenceList.HeaderButton:SetTemplate('Transparent')
	end)
end

S:AddCallbackForAddon('Blizzard_AzeriteEssenceUI')
