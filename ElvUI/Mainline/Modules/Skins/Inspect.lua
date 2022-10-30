local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

local function SkinPvpTalents(slot)
	local icon = slot.Texture
	slot:StripTextures()
	S:HandleIcon(icon, true)
	slot.Border:Hide()
end


local function HandleTabs()
	local tab = _G.InspectFrameTab1
	local index, lastTab = 1, tab
	while tab do
		S:HandleTab(tab)

		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('TOPLEFT', _G.InspectFrame, 'BOTTOMLEFT', -3, 0)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -5, 0)
			lastTab = tab
		end

		index = index + 1
		tab = _G['InspectFrameTab'..index]
	end
end

function S:Blizzard_InspectUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect) then return end

	local InspectFrame = _G.InspectFrame
	S:HandlePortraitFrame(InspectFrame)
	S:HandleButton(_G.InspectPaperDollFrame.ViewButton)
	S:HandleButton(_G.InspectPaperDollItemsFrame.InspectTalents)

	_G.SpecializationRing:Hide()
	S:HandleIcon(_G.SpecializationSpecIcon, true)
	_G.SpecializationSpecIcon:Size(55, 55) -- 70, 70 default size

	-- Create portrait element for the PvP Frame so we can see prestige
	local InspectPVPFrame = _G.InspectPVPFrame
	local portrait = InspectPVPFrame:CreateTexture(nil, 'OVERLAY')
	portrait:Size(55, 55)
	InspectPVPFrame.SmallWreath:ClearAllPoints()
	InspectPVPFrame.SmallWreath:Point('TOPLEFT', -2, -25)

	-- PvP Talents
	for i = 1, 3 do
		SkinPvpTalents(InspectPVPFrame['TalentSlot'..i])
	end

	-- Tabs
	HandleTabs()

	_G.InspectPaperDollItemsFrame.InspectTalents:ClearAllPoints()
	_G.InspectPaperDollItemsFrame.InspectTalents:Point('TOPRIGHT', _G.InspectFrame, 'BOTTOMRIGHT', 0, -1)

	local InspectModelFrame = _G.InspectModelFrame
	InspectModelFrame:StripTextures()
	InspectModelFrame:CreateBackdrop()
	InspectModelFrame.backdrop:Point('TOPLEFT', E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
	InspectModelFrame.backdrop:Point('BOTTOMRIGHT', E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

	-- Background Artwork
	if E.private.skins.parchmentRemoverEnable then
		_G.InspectGuildFrameBG:Kill()
		_G.InspectPVPFrame.BG:Kill()
		_G.InspectTalentFrame:StripTextures()
	end

	_G.InspectModelFrameBorderTopLeft:Kill()
	_G.InspectModelFrameBorderTopRight:Kill()
	_G.InspectModelFrameBorderTop:Kill()
	_G.InspectModelFrameBorderLeft:Kill()
	_G.InspectModelFrameBorderRight:Kill()
	_G.InspectModelFrameBorderBottomLeft:Kill()
	_G.InspectModelFrameBorderBottomRight:Kill()
	_G.InspectModelFrameBorderBottom:Kill()
	_G.InspectModelFrameBorderBottom2:Kill()

	-- Re-add the overlay texture which was removed via StripTextures
	InspectModelFrame.BackgroundOverlay:SetColorTexture(0, 0, 0)

	-- Give inspect frame model backdrop it's color back
	for _, corner in pairs({'TopLeft','TopRight','BotLeft','BotRight'}) do
		local bg = _G['InspectModelFrameBackground'..corner]
		if bg then
			bg:SetDesaturated(false)
			bg.ignoreDesaturated = true -- so plugins can prevent this if they want.
			hooksecurefunc(bg, 'SetDesaturated', function(bckgnd, value)
				if value and bckgnd.ignoreDesaturated then
					bckgnd:SetDesaturated(false)
				end
			end)
		end
	end

	for _, Slot in pairs({_G.InspectPaperDollItemsFrame:GetChildren()}) do
		if Slot:IsObjectType('Button') or Slot:IsObjectType('ItemButton') then
			if not Slot.icon then return end

			S:HandleIcon(Slot.icon, true)
			Slot.icon.backdrop:SetFrameLevel(Slot:GetFrameLevel())
			Slot.icon:SetInside()
			Slot:StripTextures()
			Slot:StyleButton()

			S:HandleIconBorder(Slot.IconBorder, Slot.icon.backdrop)
		end
	end
end

S:AddCallbackForAddon('Blizzard_InspectUI')
