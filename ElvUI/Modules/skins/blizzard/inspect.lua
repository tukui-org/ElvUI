local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, unpack = pairs, unpack
--WoW API / Variables
local GetPrestigeInfo = GetPrestigeInfo
local UnitPrestige = UnitPrestige
local UnitLevel = UnitLevel
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
	--Update texture according to prestige
	hooksecurefunc("InspectPVPFrame_Update", function()
		local level = UnitLevel(INSPECTED_UNIT);
		if not (level < MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_LEVEL_CURRENT]) then
			local prestigeLevel = UnitPrestige(INSPECTED_UNIT);
			if (prestigeLevel > 0) then
				portrait:SetTexture(GetPrestigeInfo(prestigeLevel));
			end
		end
	end)

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
	for i = 1, 6 do
		for j = 1, 3 do
			local button = _G["InspectPVPFrameTalentRow"..i.."Talent"..j]

			button:StripTextures()
			button:CreateBackdrop("Default")

			button.Icon:SetAllPoints()
			button.Icon:SetTexCoord(unpack(E.TexCoords))
		end
	end

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
	InspectModelFrameBackgroundOverlay:Kill()

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