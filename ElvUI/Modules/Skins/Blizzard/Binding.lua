local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

function S:Blizzard_BindingUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.binding) then return end

	local buttons = {
		'defaultsButton',
		'unbindButton',
		'okayButton',
		'cancelButton',
		'quickKeybindButton'
	}

	local KeyBindingFrame = _G.KeyBindingFrame
	for _, v in pairs(buttons) do
		S:HandleButton(KeyBindingFrame[v])
	end

	_G.KeyBindingFrameScrollFrame:StripTextures()
	S:HandleScrollBar(_G.KeyBindingFrameScrollFrameScrollBar)

	S:HandleCheckBox(KeyBindingFrame.characterSpecificButton)
	KeyBindingFrame.Header:StripTextures()
	KeyBindingFrame.Header:ClearAllPoints()
	KeyBindingFrame.Header:Point('TOP', KeyBindingFrame, 'TOP', 0, -4)
	KeyBindingFrame:StripTextures()
	KeyBindingFrame:SetTemplate('Transparent')

	_G.KeyBindingFrameCategoryList:StripTextures()
	_G.KeyBindingFrameCategoryList:SetTemplate('Transparent')
	KeyBindingFrame.bindingsContainer:StripTextures()
	KeyBindingFrame.bindingsContainer:SetTemplate('Transparent')

	for i = 1, _G.KEY_BINDINGS_DISPLAYED, 1 do
		local button1 = _G['KeyBindingFrameKeyBinding'..i..'Key1Button']
		local button2 = _G['KeyBindingFrameKeyBinding'..i..'Key2Button']
		button2:Point('LEFT', button1, 'RIGHT', 1, 0) -- Needed for new Pixel Perfect
	end

	hooksecurefunc('BindingButtonTemplate_SetupBindingButton', function(_, button)
		if not button.IsSkinned then
			local selected = button.selectedHighlight
			selected:SetTexture(E.media.normTex)
			selected:Point('TOPLEFT', 1, -1)
			selected:Point('BOTTOMRIGHT', -1, 1)
			selected:SetColorTexture(1, 1, 1, .25)
			S:HandleButton(button)

			button.IsSkinned = true
		end
	end)

	-- QuickKeybind
	local Quickie = _G.QuickKeybindFrame
	Quickie:StripTextures()
	Quickie.Header:StripTextures()
	Quickie:SetTemplate('Transparent')

	local quickies = {
		'okayButton',
		'defaultsButton',
		'cancelButton'
	}

	for _, v in pairs(quickies) do
		S:HandleButton(Quickie[v])
	end

	S:HandleCheckBox(Quickie.characterSpecificButton)
end

S:AddCallbackForAddon('Blizzard_BindingUI')
