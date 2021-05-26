local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_NewPlayerExperienceGuide()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guide) then return end

	local frame = _G.GuideFrame
	S:HandlePortraitFrame(frame)

	S:HandleScrollBar(frame.ScrollFrame.ScrollBar)
	S:HandleButton(frame.ScrollFrame.ConfirmationButton)

	frame.ScrollFrame.Child.ObjectivesFrame:StripTextures()
	frame.ScrollFrame.Child.ObjectivesFrame:SetTemplate('Transparent')

	-- Texts if parchment is enabled
	-- TO DO: Add Parchment option
	frame.Title:SetTextColor(1, 1, 1)
	frame.ScrollFrame.Child.Text:SetTextColor(1, 1, 1)
end

S:AddCallbackForAddon('Blizzard_NewPlayerExperienceGuide')
