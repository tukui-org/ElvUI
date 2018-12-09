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
	AzeriteRespecFrame:SetClipsChildren(true)
	AzeriteRespecFrame.Background:Hide()
	AzeriteRespecFrame:StripTextures()
	AzeriteRespecFrame:SetTemplate("Transparent")

	local Lines = AzeriteRespecFrame:CreateTexture(nil, "BACKGROUND")
	Lines:ClearAllPoints()
	Lines:SetPoint("TOPLEFT", -50, 25)
	Lines:SetPoint("BOTTOMRIGHT")
	Lines:SetTexture([[Interface\Transmogrify\EtherealLines]], true, true)
	Lines:SetHorizTile(true)
	Lines:SetVertTile(true)
	Lines:SetAlpha(0.5)

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

	-- Hide the damn Tutorial Tooltip
	local HelpBox = AzeriteRespecFrame.HelpBox
	HelpBox:SetAlpha(0)

	S:HandleButton(ButtonFrame.AzeriteRespecButton, true)
	S:HandleCloseButton(AzeriteRespecFrame.CloseButton)
end

S:AddCallbackForAddon("Blizzard_AzeriteRespecUI", "AzeriteRespec", LoadSkin)
