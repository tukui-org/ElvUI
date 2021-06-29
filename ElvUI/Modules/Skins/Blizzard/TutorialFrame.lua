local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:TutorialFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tutorials) then return end

	_G.TutorialFrame:DisableDrawLayer('BORDER')
	_G.TutorialFrame:CreateBackdrop('Transparent')
	_G.TutorialFrameBackground:Hide()
	_G.TutorialFrameBackground.Show = E.noop

	S:HandleCloseButton(_G.TutorialFrameCloseButton)
	S:HandleButton(_G.TutorialFrameOkayButton)
	S:HandleNextPrevButton(_G.TutorialFramePrevButton, 'left')
	S:HandleNextPrevButton(_G.TutorialFrameNextButton, 'right')
end

S:AddCallback('TutorialFrame')
