local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon('Blizzard_BarbershopUI', nil, nil, nil, nil, nil, 'barber')

if E.Modern then -- classic has this addon too, but without CharCustomizeFrame
	S:AddCallbackForAddon('Blizzard_CharacterCustomize', nil, nil, nil, nil, nil, 'barber') -- yes, it belongs also to the BarberUI
end

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

	local options = list.pools:GetPool('CustomizationOptionCheckButtonTemplate')
	for frame in options:EnumerateActive() do
		if not frame.IsSkinned then
			S:HandleCheckBox(frame.Button)
			frame.Label:FontTemplate()

			frame.IsSkinned = true
		end
	end
end

function S:Blizzard_CharacterCustomize()
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
	local frame = _G.BarberShopFrame
	if E.Modern then
		S:HandleButton(frame.ResetButton, nil, nil, nil, true, nil, nil, nil, true)
		S:HandleButton(frame.CancelButton, nil, nil, nil, true, nil, nil, nil, true)
		S:HandleButton(frame.AcceptButton, nil, nil, nil, true, nil, nil, nil, true)

		if E.Forever then
			S:HandleCheckBox(frame.SDToggleButton) -- HD models toggle, shown by C_GameRules.IsSDHDToggleEnabled
		end
	else
		S:HandleFrame(frame)

		for _, selector in next, frame.Selector do
			S:HandleNextPrevButton(selector.Prev)
			S:HandleNextPrevButton(selector.Next)
		end

		S:HandleButton(_G.BarberShopFrameResetButton, nil, nil, nil, true, nil, nil, nil, true)
		S:HandleButton(_G.BarberShopFrameCancelButton, nil, nil, nil, true, nil, nil, nil, true)
		S:HandleButton(_G.BarberShopFrameOkayButton, nil, nil, nil, true, nil, nil, nil, true)
	end
end
