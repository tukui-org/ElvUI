local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.losscontrol ~= true then return end

	--/run LossOfControlFrame.fadeTime = 2000; LossOfControlFrame_SetUpDisplay(LossOfControlFrame, true, 'CONFUSE', 2094, 'Disoriented', [[Interface\Icons\Spell_Shadow_MindSteal]], 72101.9765625, 7.9950003623962, 8, 0, 5, 2)
	local LossOfControlFrame = _G["LossOfControlFrame"]
	local IconBackdrop = CreateFrame("Frame", nil, LossOfControlFrame)
	IconBackdrop:SetTemplate()
	IconBackdrop:SetOutside(LossOfControlFrame.Icon)
	IconBackdrop:SetFrameLevel(LossOfControlFrame:GetFrameLevel() - 1)

	LossOfControlFrame.Icon:SetTexCoord(.1, .9, .1, .9)
	LossOfControlFrame:StripTextures()
	LossOfControlFrame.AbilityName:ClearAllPoints()
	LossOfControlFrame:Size(LossOfControlFrame.Icon:GetWidth() + 50)

	local font = E.media.normFont
	hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(self)
		self.Icon:ClearAllPoints()
		self.Icon:Point("CENTER", self, "CENTER", 0, 0)

		self.AbilityName:ClearAllPoints()
		self.AbilityName:Point("BOTTOM", self, 0, -28)
		self.AbilityName.scrollTime = nil;
		self.AbilityName:FontTemplate(font, 20, 'OUTLINE')

		self.TimeLeft.NumberText:ClearAllPoints()
		self.TimeLeft.NumberText:Point("BOTTOM", self, 4, -58)
		self.TimeLeft.NumberText.scrollTime = nil;
		self.TimeLeft.NumberText:FontTemplate(font, 20, 'OUTLINE')

		self.TimeLeft.SecondsText:ClearAllPoints()
		self.TimeLeft.SecondsText:Point("BOTTOM", self, 0, -80)
		self.TimeLeft.SecondsText.scrollTime = nil;
		self.TimeLeft.SecondsText:FontTemplate(font, 20, 'OUTLINE')

		-- always stop shake animation on start
		if self.Anim:IsPlaying() then
			self.Anim:Stop()
		end
	end)
end

S:AddCallback("LossControl", LoadSkin)
