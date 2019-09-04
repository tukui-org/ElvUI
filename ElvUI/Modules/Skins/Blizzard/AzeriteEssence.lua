local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables
local C_AzeriteEssence_CanOpenUI = C_AzeriteEssence.CanOpenUI

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AzeriteEssence ~= true then return end
	if not C_AzeriteEssence_CanOpenUI() then return end

	local AzeriteEssenceUI = _G.AzeriteEssenceUI
	S:HandlePortraitFrame(AzeriteEssenceUI, true)

	-- Reposition the Level Badge
	AzeriteEssenceUI.PowerLevelBadgeFrame:ClearAllPoints()
	AzeriteEssenceUI.PowerLevelBadgeFrame:SetPoint('TOPLEFT')
	AzeriteEssenceUI.PowerLevelBadgeFrame.Ring:Hide()
	AzeriteEssenceUI.PowerLevelBadgeFrame.BackgroundBlack:Hide()

	AzeriteEssenceUI.OrbBackground:SetAllPoints(AzeriteEssenceUI.ItemModelScene)
	AzeriteEssenceUI.OrbRing:SetSize(483, 480)

	S:HandleScrollBar(AzeriteEssenceUI.EssenceList.ScrollBar)

	-- Essence List on the right
	for _, button in pairs(AzeriteEssenceUI.EssenceList.buttons) do
		button:DisableDrawLayer('ARTWORK')
		button:StyleButton()

		S:HandleIcon(button.Icon)
		button.Icon:SetPoint("LEFT", button, "LEFT", 6, 0)

		button:CreateBackdrop()
		button.backdrop:SetPoint("TOPLEFT", 2, -3)
		button.backdrop:SetPoint("BOTTOMRIGHT", -2, 3)
	end

	-- Header on the Essence List
	AzeriteEssenceUI:HookScript('OnShow', function(self)
		self.EssenceList.HeaderButton:StripTextures()
		if not self.EssenceList.HeaderButton.backdrop then
			self.EssenceList.HeaderButton:CreateBackdrop('Transparent')
			self.EssenceList.HeaderButton.backdrop:SetAllPoints()
		end
	end)
end

S:AddCallbackForAddon("Blizzard_AzeriteEssenceUI", "AzeriteEssenceUI", LoadSkin)
