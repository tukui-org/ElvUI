local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

----------------------------------------------------------------------------------------
--	Transmogrify skin (written by shestak)
----------------------------------------------------------------------------------------

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.transmogrify ~= true then return end
	TransmogrifyFrame:StripTextures()
	TransmogrifyFrame:SetTemplate("Transparent")
	TransmogrifyModelFrame:SetFrameLevel(TransmogrifyFrame:GetFrameLevel() + 2)

	local KillTextures = {
		"TransmogrifyModelFrameLines",
		"TransmogrifyModelFrameMarbleBg",
		"TransmogrifyFrameButtonFrameButtonBorder",
		"TransmogrifyFrameButtonFrameButtonBottomBorder",
		"TransmogrifyFrameButtonFrameMoneyLeft",
		"TransmogrifyFrameButtonFrameMoneyRight",
		"TransmogrifyFrameButtonFrameMoneyMiddle",
	}

	for _, texture in pairs(KillTextures) do
		_G[texture]:Kill()
	end

	select(2, TransmogrifyModelFrame:GetRegions()):Kill()
	TransmogrifyFrameButtonFrame:GetRegions():Kill()

	S:HandleButton(TransmogrifyApplyButton, true)
	TransmogrifyApplyButton:Point("BOTTOMRIGHT", TransmogrifyFrame, "BOTTOMRIGHT", -4, 4)
	S:HandleCloseButton(TransmogrifyArtFrameCloseButton)
	TransmogrifyArtFrame:StripTextures()

	local slots = {"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet",
	"Wrist", "Hands", "Back", "MainHand", "SecondaryHand"}

	for _, slot in pairs(slots) do
		local icon = _G["TransmogrifyFrame"..slot.."SlotIconTexture"]
		local slot = _G["TransmogrifyFrame"..slot.."Slot"]

		if slot then
			slot:StripTextures()
			slot:StyleButton(false)
			slot:SetFrameLevel(slot:GetFrameLevel() + 2)
			slot:CreateBackdrop("Default")
			slot.backdrop:SetAllPoints()

			icon:SetTexCoord(unpack(E.TexCoords))
			icon:ClearAllPoints()
			icon:SetInside()
		end
	end

	TransmogrifyConfirmationPopup:SetParent(UIParent)
	TransmogrifyConfirmationPopup:StripTextures()
	TransmogrifyConfirmationPopup:SetTemplate("Transparent")
	S:HandleButton(TransmogrifyConfirmationPopup.Button1)
	S:HandleButton(TransmogrifyConfirmationPopup.Button2)
	S:HandleItemButton(TransmogrifyConfirmationPopupItemFrame1, true)
	S:HandleItemButton(TransmogrifyConfirmationPopupItemFrame2, true)
end

S:RegisterSkin("Blizzard_ItemAlterationUI", LoadSkin)