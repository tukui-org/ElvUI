local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

function S:LossOfControlFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.losscontrol) then return end

	--/run LossOfControlFrame.fadeTime = 2000; LossOfControlFrame_SetUpDisplay(LossOfControlFrame, true, 'CONFUSE', 2094, 'Disoriented', [[Interface\Icons\Spell_Shadow_MindSteal]], 72101.9765625, 7.9950003623962, 8, 0, 5, 2)
	local LossOfControlFrame = _G.LossOfControlFrame
	local IconBackdrop = CreateFrame('Frame', nil, LossOfControlFrame)
	IconBackdrop:SetTemplate()
	IconBackdrop:SetOutside(LossOfControlFrame.Icon)
	IconBackdrop:SetFrameLevel(LossOfControlFrame:GetFrameLevel() - 1)

	LossOfControlFrame.Icon:SetTexCoord(.1, .9, .1, .9)
	LossOfControlFrame:StripTextures()
	LossOfControlFrame.AbilityName:ClearAllPoints()
	LossOfControlFrame:Size(LossOfControlFrame.Icon:GetWidth() + 50)

	hooksecurefunc('LossOfControlFrame_SetUpDisplay', function(s)
		s.Icon:ClearAllPoints()
		s.Icon:Point('CENTER', s, 'CENTER', 0, 0)

		s.AbilityName:ClearAllPoints()
		s.AbilityName:Point('BOTTOM', s, 0, -28)
		s.AbilityName.scrollTime = nil
		s.AbilityName:FontTemplate(nil, 20, 'OUTLINE')

		s.TimeLeft.NumberText:ClearAllPoints()
		s.TimeLeft.NumberText:Point('BOTTOM', s, 4, -58)
		s.TimeLeft.NumberText.scrollTime = nil
		s.TimeLeft.NumberText:FontTemplate(nil, 20, 'OUTLINE')

		s.TimeLeft.SecondsText:ClearAllPoints()
		s.TimeLeft.SecondsText:Point('BOTTOM', s, 0, -80)
		s.TimeLeft.SecondsText.scrollTime = nil
		s.TimeLeft.SecondsText:FontTemplate(nil, 20, 'OUTLINE')

		-- always stop shake animation on start
		if s.Anim:IsPlaying() then
			s.Anim:Stop()
		end
	end)
end

S:AddCallback('LossOfControlFrame')
