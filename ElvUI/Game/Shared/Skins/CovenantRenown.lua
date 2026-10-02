local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon('Blizzard_CovenantRenown', nil, nil, nil, nil, nil, 'covenantRenown')

local function Covenant_SetupData(frame)
	frame.CloseButton.Border:Hide()

	if E.private.skins.parchmentRemoverEnable then
		frame:StripTextures()
		frame:SetTemplate('Transparent')
	end
end

function S:Blizzard_CovenantRenown()
	local frame = _G.CovenantRenownFrame
	S:HandleCloseButton(frame.CloseButton)

	local skipButton = frame.LevelSkipButton
	S:HandleButton(skipButton, nil, nil, nil, true)
	skipButton:SetNormalFontObject('ElvUIFontSmall')
	skipButton:SetHighlightFontObject('ElvUIFontSmall')
	skipButton:SetDisabledFontObject('ElvUIFontSmall')

	hooksecurefunc(frame, 'SetUpCovenantData', Covenant_SetupData)

	if E.private.skins.parchmentRemoverEnable then
		frame.TrackFrame:SetTemplate('Transparent')
	end
end
