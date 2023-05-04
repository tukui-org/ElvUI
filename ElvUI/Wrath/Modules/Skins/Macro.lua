local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local hooksecurefunc = hooksecurefunc

function S:Blizzard_MacroUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.macro) then return end

	local MacroFrame = _G.MacroFrame
	S:HandlePortraitFrame(MacroFrame)
	MacroFrame:Width(360)

	_G.MacroFrame.MacroSelector.ScrollBox:StripTextures()
	_G.MacroFrame.MacroSelector.ScrollBox:SetTemplate('Transparent')
	_G.MacroFrameTextBackground.NineSlice:SetTemplate('Transparent')

	S:HandleTrimScrollBar(MacroFrame.MacroSelector.ScrollBar)
	S:HandleScrollBar(_G.MacroFrameScrollFrameScrollBar)

	for _, button in next, {
		_G.MacroSaveButton,
		_G.MacroCancelButton,
		_G.MacroDeleteButton,
		_G.MacroNewButton,
		_G.MacroExitButton,
		_G.MacroEditButton,
		_G.MacroFrameTab1,
		_G.MacroFrameTab2,
	} do
		button:StripTextures()
		S:HandleButton(button)
	end

	_G.MacroNewButton:ClearAllPoints()
	_G.MacroNewButton:Point('RIGHT', _G.MacroExitButton, 'LEFT', -2 , 0)

	for i = 1, 2 do
		_G['MacroFrameTab'..i]:Height(22)
	end

	_G.MacroFrameTab1:Point('TOPLEFT', MacroFrame, 'TOPLEFT', 12, -39)
	_G.MacroFrameTab2:Point('LEFT', _G.MacroFrameTab1, 'RIGHT', 4, 0)

	-- Reposition General / Character tab text to center
	_G.MacroFrameTab1.Text:SetAllPoints(_G.MacroFrameTab1)
	_G.MacroFrameTab2.Text:SetAllPoints(_G.MacroFrameTab2)

	--Reposition edit button
	_G.MacroEditButton:ClearAllPoints()
	_G.MacroEditButton:Point('BOTTOMLEFT', _G.MacroFrameSelectedMacroButton, 'BOTTOMRIGHT', 10, 0)

	-- Big icon
	_G.MacroFrameSelectedMacroButton:StripTextures()
	_G.MacroFrameSelectedMacroButton:StyleButton()
	_G.MacroFrameSelectedMacroButton:GetNormalTexture():SetTexture()
	_G.MacroFrameSelectedMacroButton:SetTemplate()
	_G.MacroFrameSelectedMacroButton.Icon:SetInside()
	_G.MacroFrameSelectedMacroButton.Icon:SetTexCoord(unpack(E.TexCoords))

	-- handle the macro buttons
	hooksecurefunc(MacroFrame.MacroSelector.ScrollBox, 'Update', function()
		for _, button in next, { MacroFrame.MacroSelector.ScrollBox.ScrollTarget:GetChildren() } do
			if button.Icon and not button.isSkinned then
				S:HandleItemButton(button, true)
			end
		end
	end)

	-- New icon selection
	_G.MacroPopupFrame:HookScript('OnShow', function(frame)
		if not frame.isSkinned then
			S:HandleIconSelectionFrame(frame, nil, nil, 'MacroPopup')
		end
	end)
end

S:AddCallbackForAddon('Blizzard_MacroUI')
