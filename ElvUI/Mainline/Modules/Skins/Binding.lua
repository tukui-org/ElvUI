local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function updateNewGlow(self)
	self.backdrop:SetBackdropBorderColor(0, self.NewOutline:IsShown() and 0.8 or 0, 0)
end

local function HandleScrollChild(self)
	for _, child in next, { self.ScrollTarget:GetChildren() } do
		local icon = child.Icon
		if icon and not icon.IsSkinned then
			S:HandleIcon(icon)
			icon:Point('LEFT', 3, 0)

			child.Background:Hide()
			child:CreateBackdrop(nil, nil, nil, true, nil, nil, nil, true)

			S:HandleButton(child.DeleteButton)
			child.DeleteButton:Size(20)
			child.FrameHighlight:SetInside(child.bg)
			child.FrameHighlight:SetColorTexture(1, 1, 1, .20)

			child.NewOutline:SetTexture('')
			child.BindingText:FontTemplate()
			hooksecurefunc(child, 'Init', updateNewGlow)

			icon.IsSkinned = true
		end
	end
end

local function UpdateButtonColor(button, isSelected)
	if isSelected then
		button.Portrait.backdrop:SetBackdropBorderColor(1, .8, 0)
	else
		button.Portrait.backdrop:SetBackdropBorderColor(0, 0, 0)
	end
end

local function HandlePortraitIcon(button, texture)
	button:StripTextures()
	button.Portrait:SetTexture(texture)
	S:HandleIcon(button.Portrait, true)
	button.Portrait.backdrop:SetBackdropColor(0, 0, 0)
	button.Highlight:SetColorTexture(1, 1, 1, .25)
	button.Highlight:SetInside(button.Portrait.backdrop)
	hooksecurefunc(button, 'SetSelectedState', UpdateButtonColor)
end

function S:Blizzard_ClickBindingUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.binding) then return end

	local frame = _G.ClickBindingFrame
	S:HandlePortraitFrame(frame)

	frame.TutorialButton.Ring:Hide()
	frame.TutorialButton:Point('TOPLEFT', frame, 'TOPLEFT', -12, 12)

	for _, v in next, { 'ResetButton', 'AddBindingButton', 'SaveButton' } do
		S:HandleButton(frame[v])
	end

	S:HandleTrimScrollBar(frame.ScrollBar)
	frame.ScrollBoxBackground:Hide()
	hooksecurefunc(frame.ScrollBox, 'Update', HandleScrollChild)

	-- Tutorial Frame ugly af WIP
	local tutorial = frame.TutorialFrame
	tutorial.NineSlice:StripTextures()
	tutorial:SetTemplate('Transparent')

	local titleBG = tutorial.TitleBg or tutorial.Bg
	if titleBG then
		titleBG:Hide()
	end

	HandlePortraitIcon(frame.SpellbookPortrait, 136830)
	HandlePortraitIcon(frame.MacrosPortrait, 136377)

	if frame.EnableMouseoverCastCheckbox then
		S:HandleCheckBox(frame.EnableMouseoverCastCheckbox)
	end
end

S:AddCallbackForAddon('Blizzard_ClickBindingUI')
