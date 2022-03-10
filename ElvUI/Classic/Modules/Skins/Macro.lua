local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack

function S:Blizzard_MacroUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.macro) then return end

	local MacroFrame = _G.MacroFrame
	S:HandleFrame(MacroFrame, true, nil, -5, 0, -2, -1)

	_G.MacroFrameCloseButton:Point('TOPRIGHT', 0, 2)

	_G.MacroFrameTextBackground:StripTextures()
	_G.MacroFrameTextBackground:CreateBackdrop('Default')
	_G.MacroFrameTextBackground.backdrop:Point('TOPLEFT', 0, -3)
	_G.MacroFrameTextBackground.backdrop:Point('BOTTOMRIGHT', -3, 2)

	_G.MacroButtonScrollFrame:StripTextures()
	_G.MacroButtonScrollFrame:CreateBackdrop('Default')
	_G.MacroButtonScrollFrame:Point('TOPLEFT', 8, -65)

	S:HandleScrollBar(_G.MacroButtonScrollFrameScrollBar)
	S:HandleScrollBar(_G.MacroFrameScrollFrameScrollBar)

	local buttons = {
		_G.MacroSaveButton,
		_G.MacroCancelButton,
		_G.MacroDeleteButton,
		_G.MacroNewButton,
		_G.MacroExitButton,
		_G.MacroEditButton,
	}

	for i = 1, #buttons do
		buttons[i]:StripTextures()
		S:HandleButton(buttons[i])
	end

	_G.MacroCancelButton:ClearAllPoints()
	_G.MacroCancelButton:Point('TOPRIGHT', _G.MacroFrameTextBackground.backdrop, 'TOPRIGHT', 0, 34)
	_G.MacroSaveButton:Point('BOTTOMLEFT', _G.MacroCancelButton, 'TOPLEFT', 0, 2)

	_G.MacroDeleteButton:Point('BOTTOMLEFT', 0, 4)
	_G.MacroExitButton:Point('BOTTOMRIGHT', -7, 4)

	_G.MacroNewButton:ClearAllPoints()
	_G.MacroNewButton:SetPoint('TOPRIGHT', _G.MacroExitButton, 'TOPLEFT', -2 , 0)

	for i = 1, 2 do
		local tab = _G['MacroFrameTab'..i]
		tab:StripTextures()
		S:HandleButton(tab)

		tab:Height(22)
		tab:ClearAllPoints()

		if i == 1 then
			tab:Point('TOPLEFT', MacroFrame, 'TOPLEFT', 7, -40)
			tab:Width(125)
		elseif i == 2 then
			tab:Point('TOPRIGHT', MacroFrame, 'TOPRIGHT', -35, -40)
			tab:Width(168)
		end

		tab.SetWidth = E.noop
	end

	--Reposition edit button
	_G.MacroEditButton:ClearAllPoints()
	_G.MacroEditButton:Point('BOTTOMLEFT', _G.MacroFrameSelectedMacroButton, 'BOTTOMRIGHT', 10, 0)

	-- Regular scroll bar
	S:HandleScrollBar(_G.MacroButtonScrollFrame)

	-- Big icon
	_G.MacroFrameSelectedMacroButton:StripTextures()
	_G.MacroFrameSelectedMacroButton:StyleButton(true)
	_G.MacroFrameSelectedMacroButton:GetNormalTexture():SetTexture()
	_G.MacroFrameSelectedMacroButton:SetTemplate()
	_G.MacroFrameSelectedMacroButtonIcon:SetTexCoord(unpack(E.TexCoords))
	_G.MacroFrameSelectedMacroButtonIcon:Point('TOPLEFT', 1, -1)
	_G.MacroFrameSelectedMacroButtonIcon:Point('BOTTOMRIGHT', -1, 1)

	-- Skin all buttons
	for i = 1, _G.MAX_ACCOUNT_MACROS do
		local b = _G['MacroButton'..i]
		local t = _G['MacroButton'..i..'Icon']

		if b then
			b:StripTextures()
			b:StyleButton(true)
			b:SetTemplate(nil, true)
		end

		if t then
			t:SetTexCoord(unpack(E.TexCoords))
			t:Point('TOPLEFT', 1, -1)
			t:Point('BOTTOMRIGHT', -1, 1)
		end
	end

	local MacroPopupFrame = _G.MacroPopupFrame
	S:HandleButton(_G.MacroPopupFrame.BorderBox.OkayButton)
	_G.MacroPopupFrame.BorderBox.OkayButton:Point('TOPRIGHT', _G.MacroPopupFrame.BorderBox.CancelButton, 'TOPLEFT', -2, 0)
	S:HandleButton(_G.MacroPopupFrame.BorderBox.CancelButton)
	_G.MacroPopupFrame.BorderBox.CancelButton:Point('BOTTOMRIGHT', _G.MacroPopupFrame.BorderBox, 'BOTTOMRIGHT', -4, 4)

	_G.MacroPopupScrollFrame:CreateBackdrop('Default')
	_G.MacroPopupScrollFrame.backdrop:Point('BOTTOMRIGHT', -2, -1)
	_G.MacroPopupScrollFrame:Point('TOPLEFT', _G.MacroPopupFrame.BorderBox, 'TOPLEFT', 25, -75)

	S:HandleScrollBar(_G.MacroPopupScrollFrameScrollBar)
	S:HandleEditBox(_G.MacroPopupEditBox)
	_G.MacroPopupEditBox:Point('TOPLEFT', 25, -25)

	_G.MacroPopupNameLeft:SetTexture()
	_G.MacroPopupNameMiddle:SetTexture()
	_G.MacroPopupNameRight:SetTexture()

	MacroPopupFrame:HookScript('OnShow', function(frame)
		frame:ClearAllPoints()
		frame:Point('TOPLEFT', MacroFrame, 'TOPRIGHT', 2, 0)

		if not frame.isSkinned then
			S:HandleIconSelectionFrame(frame, _G.NUM_MACRO_ICONS_SHOWN, 'MacroPopupButton', 'MacroPopup')
		end
	end)
end

S:AddCallbackForAddon('Blizzard_MacroUI')
