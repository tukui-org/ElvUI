local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:Blizzard_RuneforgeUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.runeforge) then return end

	local frame = _G.RuneforgeFrame
	frame.Title:FontTemplate(nil, 22)
	S:HandleCloseButton(frame.CloseButton)

	S:HandleButton(frame.CreateFrame.CraftItemButton)

	local powerFrame = frame.CraftingFrame.PowerFrame

	local pageControl = powerFrame.PageControl
	S:HandleNextPrevButton(pageControl.BackwardButton)
	S:HandleNextPrevButton(pageControl.ForwardButton)

	hooksecurefunc(powerFrame.PowerList, 'RefreshListDisplay', function(list)
		if not list.elements then return end

		for i = 1, list:GetNumElementFrames() do
			local button = list.elements[i]
			if button and not button.IsSkinned then
				button.Border:SetAlpha(0)
				button.CircleMask:Hide()
				S:HandleIcon(button.Icon, true)

				button.IsSkinned = true
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_RuneforgeUI')
