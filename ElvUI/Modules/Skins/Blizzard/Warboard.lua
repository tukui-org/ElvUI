local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_WarboardUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.Warboard) then return end

	local WarboardQuestChoiceFrame = _G.WarboardQuestChoiceFrame
	WarboardQuestChoiceFrame:StripTextures()
	WarboardQuestChoiceFrame.NineSlice:Hide()
	WarboardQuestChoiceFrame:CreateBackdrop('Transparent')

	WarboardQuestChoiceFrame.Background:Hide()
	WarboardQuestChoiceFrame.Title:DisableDrawLayer('BACKGROUND')

	for i = 1, 4 do
		local option = WarboardQuestChoiceFrame['Option'..i]
		for x = 1, #option.OptionButtonsContainer.Buttons do
			S:HandleButton(option.OptionButtonsContainer.Buttons[x])
		end
		option.ArtworkBorder:SetAlpha(0)
	end

	local WarboardQuestChoiceDelayed = function(s)
		if not s then return end

		local frame
		for i = 1, 4 do
			frame = s['Option'..i]
			if frame and frame.WidgetContainer then
				S:SkinWidgetContainer(frame.WidgetContainer)
			end
		end
	end

	WarboardQuestChoiceFrame:HookScript('OnShow', function(s)
		if s.CloseButton.Border then s.CloseButton.Border:SetAlpha(0) end
		E:Delay(0.5, WarboardQuestChoiceDelayed, s)
	end)

	S:HandleCloseButton(WarboardQuestChoiceFrame.CloseButton)
end

S:AddCallbackForAddon('Blizzard_WarboardUI')
