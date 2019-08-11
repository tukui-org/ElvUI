local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AzeriteRespec ~= true then return end

	local AzeriteRespecFrame = _G.AzeriteRespecFrame
	AzeriteRespecFrame:SetClipsChildren(true)
	AzeriteRespecFrame.Background:Hide()
	AzeriteRespecFrame:StripTextures()
	AzeriteRespecFrame:SetTemplate("Transparent")

	local Lines = AzeriteRespecFrame:CreateTexture(nil, "BACKGROUND")
	Lines:ClearAllPoints()
	Lines:Point("TOPLEFT", -50, 25)
	Lines:Point("BOTTOMRIGHT")
	Lines:SetTexture([[Interface\Transmogrify\EtherealLines]], true, true)
	Lines:SetHorizTile(true)
	Lines:SetVertTile(true)
	Lines:SetAlpha(0.5)

	local ItemSlot = AzeriteRespecFrame.ItemSlot
	ItemSlot:Size(64, 64)
	ItemSlot:Point("CENTER", AzeriteRespecFrame)
	ItemSlot.Icon:SetInside()
	ItemSlot.GlowOverlay:SetAlpha(0)

	ItemSlot:CreateBackdrop("Transparent")
	ItemSlot.backdrop:SetBackdropColor(.6, 0, .6, .5)
	S:HandleIcon(ItemSlot.Icon)

	local ButtonFrame = AzeriteRespecFrame.ButtonFrame
	ButtonFrame:GetRegions():Hide()
	ButtonFrame.ButtonBorder:Hide()
	ButtonFrame.ButtonBottomBorder:Hide()

	ButtonFrame.MoneyFrameEdge:Hide()
	ButtonFrame.MoneyFrame:ClearAllPoints()
	ButtonFrame.MoneyFrame:Point("BOTTOMRIGHT", ButtonFrame.MoneyFrameEdge, 7, 5)

	-- Hide the damn Tutorial Tooltip
	local HelpBox = AzeriteRespecFrame.HelpBox
	HelpBox:SetAlpha(0)

	S:HandleButton(ButtonFrame.AzeriteRespecButton, true)
	S:HandleCloseButton(AzeriteRespecFrame.CloseButton)
end

S:AddCallbackForAddon("Blizzard_AzeriteRespecUI", "AzeriteRespec", LoadSkin)
