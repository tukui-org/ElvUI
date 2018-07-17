local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local select = select
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function SkinEtheralFrame(frame)
	frame.CornerTL:Hide()
	frame.CornerTR:Hide()
	frame.CornerBL:Hide()
	frame.CornerBR:Hide()

	local name = frame:GetName()
	_G[name.."LeftEdge"]:Hide()
	_G[name.."RightEdge"]:Hide()
	_G[name.."TopEdge"]:Hide()
	_G[name.."BottomEdge"]:Hide()

	local bg = select(23, frame:GetRegions())
	bg:ClearAllPoints()
	bg:SetPoint("TOPLEFT", -50, 25)
	bg:SetPoint("BOTTOMRIGHT")
	bg:SetTexture([[Interface\Transmogrify\EtherealLines]], true, true)
	bg:SetHorizTile(true)
	bg:SetVertTile(true)
	bg:SetAlpha(0.5)
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AzeriteRespec ~= true then return end

	local AzeriteRespecFrame = _G["AzeriteRespecFrame"]
	-- We can't use StripTextures() otherwise all gets killed. Not coolio!
	AzeriteRespecFrame:SetClipsChildren(true)
	AzeriteRespecFrame.Background:Hide()
	SkinEtheralFrame(AzeriteRespecFrame)

	AzeriteRespecFramePortraitFrame:Hide()
	AzeriteRespecFramePortrait:Hide()
	AzeriteRespecFrameTitleBg:Hide()
	AzeriteRespecFrameTopBorder:Hide()
	AzeriteRespecFrameTopRightCorner:Hide()
	AzeriteRespecFrameRightBorder:Hide()
	AzeriteRespecFrameLeftBorder:Hide()
	AzeriteRespecFrameBottomBorder:Hide()
	AzeriteRespecFrameBotRightCorner:Hide()
	AzeriteRespecFrameBotLeftCorner:Hide()
	AzeriteRespecFrameBg:Hide()

	local ItemSlot = AzeriteRespecFrame.ItemSlot
	ItemSlot:SetSize(64, 64)
	ItemSlot:SetPoint("CENTER", AzeriteRespecFrame)
	ItemSlot.Icon:ClearAllPoints()
	ItemSlot.Icon:SetPoint("TOPLEFT", 1, -1)
	ItemSlot.Icon:SetPoint("BOTTOMRIGHT", -1, 1)
	ItemSlot.GlowOverlay:SetAlpha(0)

	AzeriteRespecFrame.ItemSlot:CreateBackdrop("Transparent")
	AzeriteRespecFrame.ItemSlot.backdrop:SetBackdropColor(153/255, 0/255, 153/255, 0.5)
	S:CropIcon(AzeriteRespecFrame.ItemSlot.Icon)

	local ButtonFrame = AzeriteRespecFrame.ButtonFrame
	ButtonFrame:GetRegions():Hide()
	ButtonFrame.ButtonBorder:Hide()
	ButtonFrame.ButtonBottomBorder:Hide()

	ButtonFrame.MoneyFrameEdge:Hide()
	ButtonFrame.MoneyFrame:ClearAllPoints()
	ButtonFrame.MoneyFrame:SetPoint("BOTTOMRIGHT", ButtonFrame.MoneyFrameEdge, 7, 5)

	AzeriteRespecFrame:CreateBackdrop("Transparent")
	AzeriteRespecFrame.backdrop:SetAllPoints()

	S:HandleButton(AzeriteRespecFrame.ButtonFrame.AzeriteRespecButton)
	S:HandleCloseButton(AzeriteRespecFrameCloseButton)
end

S:AddCallbackForAddon("Blizzard_AzeriteRespecUI", "AzeriteRespec", LoadSkin)