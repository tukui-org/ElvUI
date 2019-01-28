local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, unpack = pairs, unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.inspect ~= true then return end

	local InspectFrame = _G.InspectFrame
	S:HandlePortraitFrame(InspectFrame, true)
	S:HandleButton(_G.InspectPaperDollFrame.ViewButton)

	--Create portrait element for the PvP Frame so we can see prestige
	local InspectPVPFrame = _G.InspectPVPFrame
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

	local InspectModelFrame = _G.InspectModelFrame
	InspectModelFrame:StripTextures()
	InspectModelFrame:CreateBackdrop("Default")
	InspectModelFrame.backdrop:Point("TOPLEFT", E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
	InspectModelFrame.backdrop:Point("BOTTOMRIGHT", E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

	_G.InspectModelFrameBorderTopLeft:Kill()
	_G.InspectModelFrameBorderTopRight:Kill()
	_G.InspectModelFrameBorderTop:Kill()
	_G.InspectModelFrameBorderLeft:Kill()
	_G.InspectModelFrameBorderRight:Kill()
	_G.InspectModelFrameBorderBottomLeft:Kill()
	_G.InspectModelFrameBorderBottomRight:Kill()
	_G.InspectModelFrameBorderBottom:Kill()
	_G.InspectModelFrameBorderBottom2:Kill()

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

	for _, Slot in pairs({_G.InspectPaperDollItemsFrame:GetChildren()}) do
		if Slot:IsObjectType("Button") or Slot:IsObjectType("ItemButton") then
			S:HandleTexture(Slot.icon)
			Slot:StripTextures()
			Slot:SetTemplate()
			Slot:StyleButton()
			Slot.icon:SetInside()

			Slot.IconBorder:SetAlpha(0)
			hooksecurefunc(Slot.IconBorder, 'SetVertexColor', function(_, r, g, b) Slot:SetBackdropBorderColor(r, g, b) end)
			hooksecurefunc(Slot.IconBorder, 'Hide', function() Slot:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
		end
	end

	InspectPVPFrame.BG:Kill()
	_G.InspectGuildFrameBG:Kill()
	_G.InspectTalentFrame:StripTextures()
end

S:AddCallbackForAddon("Blizzard_InspectUI", "Inspect", LoadSkin)
