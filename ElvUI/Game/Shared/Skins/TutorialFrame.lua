local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_FrameXML', 'TutorialFrame', nil, nil, nil, nil, 'tutorials')

function S:TutorialFrame()
	if E.Modern then
		_G.TutorialFrame:DisableDrawLayer('BORDER')
		_G.TutorialFrame:CreateBackdrop('Transparent')
		_G.TutorialFrameBackground:Hide()
		_G.TutorialFrameBackground.Show = E.noop

		S:HandleCloseButton(_G.TutorialFrameCloseButton)
		S:HandleNextPrevButton(_G.TutorialFramePrevButton, 'left')
		S:HandleNextPrevButton(_G.TutorialFrameNextButton, 'right')
	else
		S:HandleFrame(_G.TutorialFrame, false)

		for i = 1, _G.MAX_TUTORIAL_ALERTS do
			local button = _G['TutorialFrameAlertButton'..i]
			local icon = button:GetNormalTexture()

			button:Size(35, 45)
			button:SetTemplate(nil, true)
			button:StyleButton(nil, true)

			icon:SetInside()
			icon:SetTexCoord(0.09, 0.40, 0.11, 0.56)
		end

		S:HandleCheckBox(_G.TutorialFrameCheckButton)
	end

	S:HandleButton(_G.TutorialFrameOkayButton)
end
