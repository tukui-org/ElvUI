local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:Blizzard_RuneforgeUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.runeforge) then return end

	local frame = _G.RuneforgeFrame
	frame.Title:FontTemplate(nil, 22)

	S:HandleButton(frame.CreateFrame.CraftItemButton)
	S:HandleButton(frame.CreateFrame.CloseButton)

	local powerFrame = frame.CraftingFrame.PowerFrame
	powerFrame:StripTextures()
	powerFrame:CreateBackdrop()

	local pageControl = powerFrame.PageControl
	S:HandleNextPrevButton(pageControl.BackwardButton)
	S:HandleNextPrevButton(pageControl.ForwardButton)

	hooksecurefunc(powerFrame.PowerList, 'RefreshListDisplay', function(self)
		if not self.elements then return end

		for i = 1, self:GetNumElementFrames() do
			local button = self.elements[i]
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
