local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local max = max
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local function HandleButton(button)
	S:HandleButton(button, nil, nil, nil, true, nil, nil, nil, true)
	button:SetScale(E.uiscale)
	button:Size(200, 50)
end

function S:Blizzard_BarbershopUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.barber) then return end

	local frame = _G.BarberShopFrame
	HandleButton(frame.ResetButton)
	HandleButton(frame.CancelButton)
	HandleButton(frame.AcceptButton)
end
S:AddCallbackForAddon('Blizzard_BarbershopUI')

local function HandleNextPrev(button)
	S:HandleNextPrevButton(button)

	-- remove these to fix error on SetHighlightAtlas from AlphaHighlightButtonMixin
	button:SetScript('OnMouseUp', nil)
	button:SetScript('OnMouseDown', nil)
end

local function SetSelectedCategory(list)
	if list.selectionPopoutPool then
		for frame in list.selectionPopoutPool:EnumerateActive() do
			if not frame.IsSkinned then
				if frame.DecrementButton then
					HandleNextPrev(frame.DecrementButton)
					HandleNextPrev(frame.IncrementButton)
				end

				if frame.Label then
					frame.Label:FontTemplate()
				end

				local button = frame.Button
				if button then
					if button.HighlightTexture then
						button.HighlightTexture:SetAlpha(0)
					end

					if button.NormalTexture then
						button.NormalTexture:SetAlpha(0)
					end

					local popout = button.Popout
					if popout then
						local r, g, b, a = unpack(E.media.backdropfadecolor)
						popout:StripTextures()
						popout:SetTemplate('Transparent')
						popout:SetBackdropColor(r, g, b, max(a, 0.8))
					end

					S:HandleButton(button, nil, nil, nil, true)
					button.backdrop:SetInside(nil, 4, 4)
				end

				frame.IsSkinned = true
			end
		end
	end

	local pool = list.pools and list.pools:GetPool('CharCustomizeOptionCheckButtonTemplate')
	if pool then
		for frame in pool:EnumerateActive() do
			if not frame.isSkinned then
				if frame.Button then
					S:HandleCheckBox(frame.Button)
				end

				if frame.Label then
					frame.Label:FontTemplate()
				end
			end
		end
	end
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

	hooksecurefunc(frame, 'SetSelectedCategory', SetSelectedCategory)
end

S:AddCallbackForAddon('Blizzard_CharacterCustomize')
