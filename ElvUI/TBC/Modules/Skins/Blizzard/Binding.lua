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
	}

	local KeyBindingFrame = _G.KeyBindingFrame
	for _, v in pairs(buttons) do
		S:HandleButton(KeyBindingFrame[v])
	end

	S:HandleFrame(KeyBindingFrame, true)
	S:HandleFrame(_G.KeyBindingFrameCategoryList, true)
	S:HandleFrame(KeyBindingFrame.bindingsContainer, true)

	KeyBindingFrame.header:StripTextures()
	KeyBindingFrame.header:ClearAllPoints()
	KeyBindingFrame.header:Point('TOP', KeyBindingFrame, 'TOP', 0, -4)

	_G.KeyBindingFrameScrollFrame:StripTextures()
	S:HandleScrollBar(_G.KeyBindingFrameScrollFrameScrollBar)

	S:HandleCheckBox(KeyBindingFrame.characterSpecificButton)

	for i = 1, _G.KEY_BINDINGS_DISPLAYED, 1 do
		local button1 = _G['KeyBindingFrameKeyBinding'..i..'Key1Button']
		local button2 = _G['KeyBindingFrameKeyBinding'..i..'Key2Button']
		button2:Point('LEFT', button1, 'RIGHT', 1, 0) -- Needed for new Pixel Perfect
	end

	hooksecurefunc('BindingButtonTemplate_SetupBindingButton', function(_, button)
		if not button.IsSkinned then
			local selected = button.selectedHighlight
			selected:SetTexture(E.media.normTex)
			selected:Point('TOPLEFT', E.mult, -E.mult)
			selected:Point('BOTTOMRIGHT', -E.mult, E.mult)
			selected:SetColorTexture(1, 1, 1, .25)
			S:HandleButton(button)

			button.IsSkinned = true
		end
	end)

	KeyBindingFrame.okayButton:Point('BOTTOMLEFT', KeyBindingFrame.unbindButton, 'BOTTOMRIGHT', 3, 0)
	KeyBindingFrame.cancelButton:Point('BOTTOMLEFT', KeyBindingFrame.okayButton, 'BOTTOMRIGHT', 3, 0)
	KeyBindingFrame.unbindButton:Point('BOTTOMRIGHT', KeyBindingFrame, 'BOTTOMRIGHT', -211, 16)
end

S:AddCallbackForAddon('Blizzard_BindingUI')
