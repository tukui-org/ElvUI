local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon('Blizzard_RuneforgeUI', nil, nil, nil, nil, nil, 'runeforge')

local function RefreshListDisplay(list)
	local lists = list.elements
	if not lists then return end -- Blizzard bails while hidden, before the list is initialized

	for i = 1, #lists do -- GetNumElementFrames
		local button = lists[i]
		if not button.IsSkinned then
			button.Border:SetAlpha(0)
			button.CircleMask:Hide()
			S:HandleIcon(button.Icon, true)

			button.IsSkinned = true
		end
	end
end

function S:Blizzard_RuneforgeUI()
	local frame = _G.RuneforgeFrame
	frame.Title:FontTemplate(nil, 22)
	S:HandleCloseButton(frame.CloseButton)
	S:HandleButton(frame.CreateFrame.CraftItemButton)

	local powerFrame = frame.CraftingFrame.PowerFrame
	local pageControl = powerFrame.PageControl
	S:HandleNextPrevButton(pageControl.BackwardButton)
	S:HandleNextPrevButton(pageControl.ForwardButton)

	hooksecurefunc(powerFrame.PowerList, 'RefreshListDisplay', RefreshListDisplay)
end
