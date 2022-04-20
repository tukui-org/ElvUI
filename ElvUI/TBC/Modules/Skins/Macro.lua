local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local format = format

function S:Blizzard_MacroUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.macro) then return end

	local MacroFrame = _G.MacroFrame
	S:HandlePortraitFrame(MacroFrame)
	MacroFrame:Width(334)

	_G.MacroFrameTextBackground:StripTextures()
	_G.MacroFrameTextBackground:SetTemplate('Transparent')
	_G.MacroButtonScrollFrame:StripTextures()
	_G.MacroButtonScrollFrame:CreateBackdrop('Transparent')

	S:HandleScrollBar(_G.MacroButtonScrollFrameScrollBar)
	S:HandleScrollBar(_G.MacroFrameScrollFrameScrollBar)

	local buttons = {
		_G.MacroSaveButton,
		_G.MacroCancelButton,
		_G.MacroDeleteButton,
		_G.MacroNewButton,
		_G.MacroExitButton,
		_G.MacroEditButton,
		_G.MacroFrameTab1,
		_G.MacroFrameTab2,
	}

	for i = 1, #buttons do
		buttons[i]:StripTextures()
		S:HandleButton(buttons[i])
	end

	_G.MacroNewButton:ClearAllPoints()
	_G.MacroNewButton:Point('RIGHT', _G.MacroExitButton, 'LEFT', -2 , 0)

	for i = 1, 2 do
		local tab = _G[format('MacroFrameTab%s', i)]
		tab:Height(22)
	end

	_G.MacroFrameTab1:Point('TOPLEFT', MacroFrame, 'TOPLEFT', 12, -39)
	_G.MacroFrameTab2:Point('LEFT', _G.MacroFrameTab1, 'RIGHT', 4, 0)

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
			b:SetTemplate('Transparent')
		end

		if t then
			t:SetTexCoord(unpack(E.TexCoords))
			t:Point('TOPLEFT', 1, -1)
			t:Point('BOTTOMRIGHT', -1, 1)
		end
	end

	local MacroPopupFrame = _G.MacroPopupFrame
	S:HandleButton(MacroPopupFrame.BorderBox.OkayButton)
	local cancel_btn = MacroPopupFrame.BorderBox.CancelButton
	S:HandleButton(cancel_btn)
	cancel_btn:ClearAllPoints()
	cancel_btn:Point('RIGHT', MacroPopupFrame.BorderBox, 'BOTTOMRIGHT', -5, 15)
	S:HandleScrollBar(_G.MacroPopupScrollFrameScrollBar)
	S:HandleEditBox(_G.MacroPopupEditBox)
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
