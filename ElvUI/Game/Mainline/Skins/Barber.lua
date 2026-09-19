local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function SetSelectedCategory(list)
	for option in list.dropdownPool:EnumerateActive() do
		if not option.IsSkinned then
			S:HandleButton(option.Dropdown)
			S:HandleButton(option.DecrementButton)
			S:HandleButton(option.IncrementButton)

			option.IsSkinned = true
		end
	end

	for slider in list.sliderPool:EnumerateActive() do
		if not slider.IsSkinned then
			S:HandleSliderFrame(slider)

			slider.IsSkinned = true
		end
	end

	for frame in list.pools:GetPool('CustomizationOptionCheckButtonTemplate'):EnumerateActive() do
		if not frame.IsSkinned then
			S:HandleCheckBox(frame.Button)
			frame.Label:FontTemplate()

			frame.IsSkinned = true
		end
	end
end

function S:Blizzard_CharacterCustomize()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.barber) then return end -- yes, it belongs also to the BarberUI

	-- backdrop is ugly, so dont use a style
	local frame = _G.CharCustomizeFrame
	S:HandleButton(frame.SmallButtons.ResetCameraButton, nil, nil, true)
	S:HandleButton(frame.SmallButtons.ZoomOutButton, nil, nil, true)
	S:HandleButton(frame.SmallButtons.ZoomInButton, nil, nil, true)
	S:HandleButton(frame.SmallButtons.RotateLeftButton, nil, nil, true)
	S:HandleButton(frame.SmallButtons.RotateRightButton, nil, nil, true)

	hooksecurefunc(frame, 'AddMissingOptions', SetSelectedCategory)
end

function S:Blizzard_BarbershopUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.barber) then return end

	local frame = _G.BarberShopFrame
	S:HandleButton(frame.ResetButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(frame.CancelButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(frame.AcceptButton, nil, nil, nil, true, nil, nil, nil, true)
end

S:AddCallbackForAddon('Blizzard_BarbershopUI')
S:AddCallbackForAddon('Blizzard_CharacterCustomize')
