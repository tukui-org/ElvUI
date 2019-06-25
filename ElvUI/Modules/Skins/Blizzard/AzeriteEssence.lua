local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local ipairs, pairs, unpack = ipairs, pairs, unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local C_AzeriteEssence_CanOpenUI = C_AzeriteEssence.CanOpenUI

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AzeriteEssence ~= true then return end
	if not C_AzeriteEssence_CanOpenUI() then return end

	local AzeriteEssenceUI = _G.AzeriteEssenceUI
	local r, g, b = unpack(E.media.rgbvaluecolor)

	S:HandlePortraitFrame(AzeriteEssenceUI, true)
	S:HandleScrollBar(AzeriteEssenceUI.EssenceList.ScrollBar)

	-- Reposition the Level Badge
	AzeriteEssenceUI.PowerLevelBadgeFrame:ClearAllPoints()
	AzeriteEssenceUI.PowerLevelBadgeFrame:SetPoint('TOPLEFT')
	AzeriteEssenceUI.PowerLevelBadgeFrame.Ring:Hide()
	AzeriteEssenceUI.PowerLevelBadgeFrame.BackgroundBlack:Hide()

	AzeriteEssenceUI.OrbBackground:SetAllPoints(AzeriteEssenceUI.ItemModelScene)
	AzeriteEssenceUI.OrbRing:SetSize(483, 480)

	local HeaderButton = AzeriteEssenceUI.EssenceList.HeaderButton
	HeaderButton:DisableDrawLayer('BORDER')
	HeaderButton:DisableDrawLayer('BACKGROUND')

	HeaderButton:CreateBackdrop()
	HeaderButton.backdrop:SetPoint('TOPLEFT', HeaderButton.ExpandedIcon, -4, 6)
	HeaderButton.backdrop:SetPoint('BOTTOMRIGHT', HeaderButton.ExpandedIcon, 4, -6)
	HeaderButton:SetScript('OnEnter', function()
		HeaderButton.backdrop:SetBackdropColor(r, g, b, .25)
	end)
	HeaderButton:SetScript('OnLeave', function()
		HeaderButton.backdrop:SetBackdropColor(0, 0, 0, 0)
	end)

	for _, milestoneFrame in pairs(AzeriteEssenceUI.Milestones) do
		if milestoneFrame.LockedState then
			milestoneFrame.LockedState.UnlockLevelText:SetTextColor(.6, .8, 1)
		end
	end

	hooksecurefunc(AzeriteEssenceUI.EssenceList, 'Refresh', function(self)
		for i, button in ipairs(self.buttons) do
			if not button.isSkinned then
				S:HandleIcon(button.Icon)
				button:CreateBackdrop()
				button.backdrop:SetAllPoints()

				button.PendingGlow:SetTexture("")
				local h1 = button:GetHighlightTexture()
				h1:SetColorTexture(r, g, b, .25)
				h1:SetOutside(button.backdrop)

				button.IsSkinned = true
			end
			button.Background:SetTexture("")

			if button:IsShown() then
				if button.PendingGlow:IsShown() then
					button.backdrop:SetBackdropBorderColor(1, .8, 0)
				else
					button.backdrop:SetBackdropBorderColor(0, 0, 0)
				end
			end
		end
	end)
end

S:AddCallbackForAddon("Blizzard_AzeriteEssenceUI", "AzeriteEssenceUI", LoadSkin)
