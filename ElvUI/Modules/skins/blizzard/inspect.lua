local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, unpack = pairs, unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: INSPECTED_UNIT, LE_EXPANSION_LEVEL_CURRENT, MAX_PLAYER_LEVEL_TABLE

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.inspect ~= true then return end

	local InspectFrame = _G["InspectFrame"]
	InspectFrame:StripTextures(true)
	InspectFrameInset:StripTextures(true)
	InspectFrame:SetTemplate('Transparent')
	S:HandleCloseButton(InspectFrameCloseButton)
	S:HandleButton(InspectPaperDollFrame.ViewButton)

	--Create portrait element for the PvP Frame so we can see prestige
	local portrait = InspectPVPFrame:CreateTexture(nil, "OVERLAY")
	portrait:SetSize(57,57);
	portrait:SetPoint("CENTER", InspectPVPFrame.PortraitBackground, "CENTER", 0, 0);
	--Kill background
	InspectPVPFrame.PortraitBackground:Kill()
	--Reposition portrait by repositioning the background
	InspectPVPFrame.PortraitBackground:ClearAllPoints()
	InspectPVPFrame.PortraitBackground:SetPoint("TOPLEFT", 5, -5)
	--Reposition the wreath
	InspectPVPFrame.SmallWreath:ClearAllPoints()
	InspectPVPFrame.SmallWreath:SetPoint("TOPLEFT", -2, -25)

	-- PVE Talents
	for i = 1, 7 do
		for j = 1, 3 do
			local button = _G["TalentsTalentRow"..i.."Talent"..j]

			button:StripTextures()
			button:CreateBackdrop("Default")

			button.icon:SetAllPoints()
			button.icon:SetTexCoord(unpack(E.TexCoords))
		end
	end

	-- PVP Talents
	-- Probably needs some adjustments
	local InspectPVPFrame = _G["InspectPVPFrame"]

	local trinketSlot = InspectPVPFrame.TrinketSlot
	trinketSlot.Border:Hide()
	trinketSlot.Texture:SetTexCoord(unpack(E.TexCoords))

	local talentSlot1 = InspectPVPFrame.TalentSlot1
	talentSlot1.Border:Hide()
	talentSlot1.Texture:SetTexCoord(unpack(E.TexCoords))

	local talentSlot2 = InspectPVPFrame.TalentSlot2
	talentSlot2.Border:Hide()
	talentSlot2.Texture:SetTexCoord(unpack(E.TexCoords))

	local talentSlot3 = InspectPVPFrame.TalentSlot3
	talentSlot3.Border:Hide()
	talentSlot3.Texture:SetTexCoord(unpack(E.TexCoords))

	for i = 1, 4 do
		S:HandleTab(_G["InspectFrameTab"..i])
	end

	InspectModelFrame:StripTextures()
	InspectModelFrame:CreateBackdrop("Default")
	InspectModelFrame.backdrop:Point("TOPLEFT", E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
	InspectModelFrame.backdrop:Point("BOTTOMRIGHT", E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

	InspectModelFrameBorderTopLeft:Kill()
	InspectModelFrameBorderTopRight:Kill()
	InspectModelFrameBorderTop:Kill()
	InspectModelFrameBorderLeft:Kill()
	InspectModelFrameBorderRight:Kill()
	InspectModelFrameBorderBottomLeft:Kill()
	InspectModelFrameBorderBottomRight:Kill()
	InspectModelFrameBorderBottom:Kill()
	InspectModelFrameBorderBottom2:Kill()

	--Re-add the overlay texture which was removed via StripTextures
	InspectModelFrame.BackgroundOverlay:SetColorTexture(0, 0, 0)

	-- Give inspect frame model backdrop it's color back
	for _, corner in pairs({"TopLeft","TopRight","BotLeft","BotRight"}) do
		local bg = _G["InspectModelFrameBackground"..corner];
		if bg then
			bg:SetDesaturated(false);
			bg.ignoreDesaturated = true; -- so plugins can prevent this if they want.
			hooksecurefunc(bg, "SetDesaturated", function(bckgnd, value)
				if value and bckgnd.ignoreDesaturated then
					bckgnd:SetDesaturated(false);
				end
			end)
		end
	end

	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot",
	}
	for _, slot in pairs(slots) do
		local icon = _G["Inspect"..slot.."IconTexture"]
		slot = _G["Inspect"..slot]
		slot:StripTextures()
		slot:StyleButton(false)
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
		slot:SetFrameLevel(slot:GetFrameLevel() + 2)
		slot:CreateBackdrop("Default")
		slot.backdrop:SetAllPoints()

		hooksecurefunc(slot.IconBorder, 'SetVertexColor', function(self, r, g, b)
			self:GetParent().backdrop:SetBackdropBorderColor(r,g,b)
			self:SetTexture("")
		end)
		hooksecurefunc(slot.IconBorder, 'Hide', function(self)
			self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)
	end

	InspectPVPFrame.BG:Kill()
	InspectGuildFrameBG:Kill()
	InspectTalentFrame:StripTextures()
end

S:AddCallbackForAddon("Blizzard_InspectUI", "Inspect", LoadSkin)
