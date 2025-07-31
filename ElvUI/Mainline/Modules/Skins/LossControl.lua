local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

-- check this on 11.2
function S:LossOfControlFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.losscontrol) then return end

	--/run LossOfControlFrame.fadeTime = 2000; LossOfControlFrame_SetUpDisplay(LossOfControlFrame, true, 'CONFUSE', 2094, 'Disoriented', [[Interface\Icons\Spell_Shadow_MindSteal]], 72101.9765625, 7.9950003623962, 8, 0, 5, 2)
	local LossOfControlFrame = _G.LossOfControlFrame
	local IconBackdrop = CreateFrame('Frame', nil, LossOfControlFrame)
	IconBackdrop:SetTemplate()
	IconBackdrop:SetOutside(LossOfControlFrame.Icon)
	IconBackdrop:OffsetFrameLevel(-1, LossOfControlFrame)

	LossOfControlFrame.Icon:SetTexCoord(.1, .9, .1, .9)
	LossOfControlFrame:StripTextures()
	LossOfControlFrame.AbilityName:ClearAllPoints()
	LossOfControlFrame:Size(LossOfControlFrame.Icon:GetWidth() + 50)

	hooksecurefunc(_G.LossOfControlMixin, 'SetUpDisplay', function(animate, data)
		self.Icon:ClearAllPoints()
		self.Icon:Point('CENTER', self, 'CENTER', 0, 0)

		self.AbilityName:ClearAllPoints()
		self.AbilityName:Point('BOTTOM', self, 0, -28)
		self.AbilityName.scrollTime = nil
		self.AbilityName:FontTemplate(nil, 20, 'OUTLINE')

		self.TimeLeft.NumberText:ClearAllPoints()
		self.TimeLeft.NumberText:Point('BOTTOM', self, 4, -58)
		self.TimeLeft.NumberText.scrollTime = nil
		self.TimeLeft.NumberText:FontTemplate(nil, 20, 'OUTLINE')

		self.TimeLeft.SecondsText:ClearAllPoints()
		self.TimeLeft.SecondsText:Point('BOTTOM', self, 0, -80)
		self.TimeLeft.SecondsText.scrollTime = nil
		self.TimeLeft.SecondsText:FontTemplate(nil, 20, 'OUTLINE')

		-- always stop shake animation on start
		if self.Anim:IsPlaying() then
			self.Anim:Stop()
		end
	end)
end

S:AddCallback('LossOfControlFrame')
