local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

function S:Blizzard_BindingUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.binding) then return end

	local KB = _G.KeyBindingFrame
	for _, v in next, { 'defaultsButton', 'unbindButton', 'okayButton', 'cancelButton' } do
		S:HandleButton(KB[v])
	end

	S:HandleFrame(KB, true)
	S:HandleFrame(KB.categoryList, true)
	S:HandleFrame(KB.bindingsContainer, true)

	KB.header:StripTextures()
	KB.header:ClearAllPoints()
	KB.header:Point('TOP', KB, 'TOP', 0, -4)

	_G.KeyBindingFrameScrollFrame:StripTextures()
	S:HandleScrollBar(_G.KeyBindingFrameScrollFrameScrollBar)

	S:HandleCheckBox(KB.characterSpecificButton)

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

	KB.okayButton:Point('BOTTOMLEFT', KB.unbindButton, 'BOTTOMRIGHT', 3, 0)
	KB.cancelButton:Point('BOTTOMLEFT', KB.okayButton, 'BOTTOMRIGHT', 3, 0)
	KB.unbindButton:Point('BOTTOMRIGHT', KB, 'BOTTOMRIGHT', -211, 16)
end

S:AddCallbackForAddon('Blizzard_BindingUI')
