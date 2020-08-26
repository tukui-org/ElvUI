local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs, unpack = pairs, unpack
local hooksecurefunc = hooksecurefunc
local GetInventoryItemLink = GetInventoryItemLink
local IsCorruptedItem = IsCorruptedItem

local function UpdateCorruption(self)
	local unit = _G.InspectFrame.unit
	local itemLink = unit and GetInventoryItemLink(unit, self:GetID())
	self.Eye:SetShown(itemLink and IsCorruptedItem(itemLink))
end

function S:Blizzard_InspectUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect) then return end

	local InspectFrame = _G.InspectFrame
	S:HandlePortraitFrame(InspectFrame, true)
	S:HandleButton(_G.InspectPaperDollFrame.ViewButton)

	_G.SpecializationRing:Hide()
	S:HandleIcon(_G.SpecializationSpecIcon, true)
	_G.SpecializationSpecIcon:SetSize(55, 55) -- 70, 70 default size

	--Create portrait element for the PvP Frame so we can see prestige
	local InspectPVPFrame = _G.InspectPVPFrame
	local portrait = InspectPVPFrame:CreateTexture(nil, 'OVERLAY')
	portrait:SetSize(55, 55)
	portrait:SetPoint('CENTER', InspectPVPFrame.PortraitBackground, 'CENTER', 0, 0)
	InspectPVPFrame.PortraitBackground:Kill()
	InspectPVPFrame.PortraitBackground:ClearAllPoints()
	InspectPVPFrame.PortraitBackground:SetPoint('TOPLEFT', 5, -5)
	InspectPVPFrame.SmallWreath:ClearAllPoints()
	InspectPVPFrame.SmallWreath:SetPoint('TOPLEFT', -2, -25)

	-- PVE Talents
	for i = 1, 7 do
		for j = 1, 3 do
			local button = _G['TalentsTalentRow'..i..'Talent'..j]

			button:StripTextures()
			S:HandleIcon(button.icon, true)
		end
	end

	-- PVP Talents
	local function SkinPvpTalents(slot)
		local icon = slot.Texture
		slot:StripTextures()
		S:HandleIcon(icon, true)
		slot.Border:Hide()
	end

	for i = 1, 3 do
		SkinPvpTalents(InspectPVPFrame['TalentSlot'..i])
	end

	SkinPvpTalents(InspectPVPFrame.TrinketSlot)

	for i = 1, 4 do
		S:HandleTab(_G['InspectFrameTab'..i])
	end

	local InspectModelFrame = _G.InspectModelFrame
	InspectModelFrame:StripTextures()
	InspectModelFrame:CreateBackdrop()
	InspectModelFrame.backdrop:SetPoint('TOPLEFT', E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
	InspectModelFrame.backdrop:SetPoint('BOTTOMRIGHT', E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

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
	for _, corner in pairs({'TopLeft','TopRight','BotLeft','BotRight'}) do
		local bg = _G['InspectModelFrameBackground'..corner];
		if bg then
			bg:SetDesaturated(false);
			bg.ignoreDesaturated = true; -- so plugins can prevent this if they want.
			hooksecurefunc(bg, 'SetDesaturated', function(bckgnd, value)
				if value and bckgnd.ignoreDesaturated then
					bckgnd:SetDesaturated(false);
				end
			end)
		end
	end

	for _, Slot in pairs({_G.InspectPaperDollItemsFrame:GetChildren()}) do
		if Slot:IsObjectType('Button') or Slot:IsObjectType('ItemButton') then
			S:HandleIcon(Slot.icon)
			Slot:StripTextures()
			Slot:SetTemplate()
			Slot:StyleButton()
			Slot.icon:SetInside()

			if not Slot.Eye then
				Slot.Eye = Slot:CreateTexture()
				Slot.Eye:SetAtlas('Nzoth-inventory-icon')
				Slot.Eye:SetInside()
			end

			Slot.IconBorder:SetAlpha(0)
			hooksecurefunc(Slot.IconBorder, 'SetVertexColor', function(_, r, g, b) Slot:SetBackdropBorderColor(r, g, b) end)
			hooksecurefunc(Slot.IconBorder, 'Hide', function() Slot:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
		end
	end

	InspectPVPFrame.BG:Kill()
	_G.InspectGuildFrameBG:Kill()
	_G.InspectTalentFrame:StripTextures()

	hooksecurefunc('InspectPaperDollItemSlotButton_Update', function(button)
		UpdateCorruption(button)
	end)
end

S:AddCallbackForAddon('Blizzard_InspectUI')
