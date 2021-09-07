local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:SkinTutorial()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tutorial) then return end

	S:HandleFrame(_G.TutorialFrame, false)

	for i = 1, _G.MAX_TUTORIAL_ALERTS do
		local button = _G['TutorialFrameAlertButton'..i]
		local icon = button:GetNormalTexture()

		button:Size(35, 45)
		button:SetTemplate('Default', true)
		button:StyleButton(nil, true)

		icon:SetInside()
		icon:SetTexCoord(0.09, 0.40, 0.11, 0.56)
	end

	S:HandleCheckBox(_G.TutorialFrameCheckButton)

	S:HandleButton(_G.TutorialFrameOkayButton)
end

S:AddCallback('SkinTutorial')
