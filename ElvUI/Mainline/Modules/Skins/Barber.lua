local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:Blizzard_BarbershopUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.barber) then return end

	local frame = _G.BarberShopFrame
	S:HandleButton(frame.ResetButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(frame.CancelButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(frame.AcceptButton, nil, nil, nil, true, nil, nil, nil, true)
end
S:AddCallbackForAddon('Blizzard_BarbershopUI')

local function HandleButton(button)
	S:HandleNextPrevButton(button)

	-- remove these to fix error on SetHighlightAtlas from AlphaHighlightButtonMixin
	button:SetScript('OnMouseUp', nil)
	button:SetScript('OnMouseDown', nil)
end

function S:Blizzard_CharacterCustomize()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.barber) then return end -- yes, it belongs also to tbe BarberUI

	-- backdrop is ugly, so dont use a style
	local frame = _G.CharCustomizeFrame
	S:HandleButton(frame.SmallButtons.ResetCameraButton, nil, nil, true)
	S:HandleButton(frame.SmallButtons.ZoomOutButton, nil, nil, true)
	S:HandleButton(frame.SmallButtons.ZoomInButton, nil, nil, true)
	S:HandleButton(frame.SmallButtons.RotateLeftButton, nil, nil, true)
	S:HandleButton(frame.SmallButtons.RotateRightButton, nil, nil, true)

	hooksecurefunc(frame, 'SetSelectedCatgory', function(list)
		if list.selectionPopoutPool then
			for button in list.selectionPopoutPool:EnumerateActive() do
				if not button.IsSkinned then
					HandleButton(button.DecrementButton)
					HandleButton(button.IncrementButton)

					local popoutButton = button.SelectionPopoutButton
					popoutButton.HighlightTexture:SetAlpha(0)
					popoutButton.NormalTexture:SetAlpha(0)

					popoutButton.Popout:StripTextures()
					popoutButton.Popout:SetTemplate('Transparent')

					S:HandleButton(popoutButton, nil, nil, nil, true)
					popoutButton.backdrop:SetInside(nil, 4, 4)

					button.IsSkinned = true
				end
			end
		end

		local optionPool = list.pools and list.pools:GetPool('CharCustomizeOptionCheckButtonTemplate')
		if optionPool then
			for button in optionPool:EnumerateActive() do
				if not button.isSkinned then
					S:HandleCheckBox(button.Button)
				end
			end
		end
	end)
end
S:AddCallbackForAddon('Blizzard_CharacterCustomize')
