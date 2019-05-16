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

	-- Reposition the Level Badge
	AzeriteEssenceUI.PowerLevelBadgeFrame:ClearAllPoints()
	AzeriteEssenceUI.PowerLevelBadgeFrame:SetPoint("TOPLEFT", 0, 0)

	S:HandlePortraitFrame(AzeriteEssenceUI, true)
	S:HandleScrollBar(AzeriteEssenceUI.EssenceList.ScrollBar)

	for _, button in pairs(AzeriteEssenceUI.EssenceList.buttons) do
		button:DisableDrawLayer('ARTWORK')
		S:HandleIcon(button.Icon)
		button:StyleButton()
		button:CreateBackdrop()
		button.backdrop:SetAllPoints()
		--button.PendingGlow:SetTexture() --needs some love
	end

	-- ToDO: Skin the HeaderButton
end

S:AddCallbackForAddon("Blizzard_AzeriteEssenceUI", "AzeriteEssenceUI", LoadSkin)
