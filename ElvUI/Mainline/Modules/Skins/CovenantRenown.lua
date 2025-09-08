local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:Blizzard_CovenantRenown()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.covenantRenown) then return end

	local frame = _G.CovenantRenownFrame
	S:HandleCloseButton(frame.CloseButton)

	if frame.LevelSkipButton then
		S:HandleButton(frame.LevelSkipButton, nil, nil, nil, true)
		frame.LevelSkipButton:GetNormalFontObject():SetFontObject('ElvUIFontSmall')
		frame.LevelSkipButton:GetHighlightFontObject():SetFontObject('ElvUIFontSmall')
		frame.LevelSkipButton:GetDisabledFontObject():SetFontObject('ElvUIFontSmall')
	end

	hooksecurefunc(frame, 'SetUpCovenantData', function(Frame)
		Frame.CloseButton.Border:Hide()

		if E.private.skins.parchmentRemoverEnable then
			Frame:StripTextures()
			Frame:SetTemplate('Transparent')
		end
	end)

	if E.private.skins.parchmentRemoverEnable then
		frame.TrackFrame:SetTemplate('Transparent')
	end
end

S:AddCallbackForAddon('Blizzard_CovenantRenown')
