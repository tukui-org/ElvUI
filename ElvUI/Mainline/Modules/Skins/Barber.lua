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

	hooksecurefunc(frame, 'SetSelectedCategory', function(list)
		if list.selectionPopoutPool then
			for popout in list.selectionPopoutPool:EnumerateActive() do
				if not popout.IsSkinned then
					HandleButton(popout.DecrementButton)
					HandleButton(popout.IncrementButton)

					local button = popout.Button
					button.HighlightTexture:SetAlpha(0)
					button.NormalTexture:SetAlpha(0)

					button.Popout:StripTextures()
					button.Popout:SetTemplate('Transparent')

					S:HandleButton(button, nil, nil, nil, true)
					button.backdrop:SetInside(nil, 4, 4)

					popout.IsSkinned = true
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
