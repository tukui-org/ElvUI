local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local select = select
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AzeriteRespec ~= true then return end

	local AzeriteRespecFrame = _G["AzeriteRespecFrame"]
	AzeriteRespecFrame.Background:Hide()
	AzeriteRespecFrame:StripTextures()
	AzeriteRespecFrame:SetTemplate("Transparent")

	local ItemSlot = AzeriteRespecFrame.ItemSlot
	ItemSlot:SetSize(64, 64)
	ItemSlot:SetPoint("CENTER", AzeriteRespecFrame)
	ItemSlot.Icon:SetInside()
	ItemSlot.GlowOverlay:SetAlpha(0)

	ItemSlot:CreateBackdrop("Transparent")
	ItemSlot.backdrop:SetBackdropColor(.6, 0, .6, .5)
	S:HandleTexture(ItemSlot.Icon)

	local ButtonFrame = AzeriteRespecFrame.ButtonFrame
	ButtonFrame:GetRegions():Hide()
	ButtonFrame.ButtonBorder:Hide()
	ButtonFrame.ButtonBottomBorder:Hide()

	ButtonFrame.MoneyFrameEdge:Hide()
	ButtonFrame.MoneyFrame:ClearAllPoints()
	ButtonFrame.MoneyFrame:SetPoint("BOTTOMRIGHT", ButtonFrame.MoneyFrameEdge, 7, 5)

	S:HandleButton(ButtonFrame.AzeriteRespecButton, true)
	S:HandleCloseButton(AzeriteRespecFrame.CloseButton)
end

S:AddCallbackForAddon("Blizzard_AzeriteRespecUI", "AzeriteRespec", LoadSkin)
