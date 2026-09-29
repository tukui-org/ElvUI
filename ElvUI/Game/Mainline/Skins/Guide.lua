local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_NewPlayerExperience()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guide) then return end

	S:HandleButton(_G.KeyboardMouseConfirmButton)

	local walk = _G.TutorialWalk_Frame.ContainerFrame
	walk.STRAFELEFT.KeyBind:SetTextColor(1, .8, 0)
	walk.STRAFERIGHT.KeyBind:SetTextColor(1, .8, 0)
	walk.MOVEFORWARD.KeyBind:SetTextColor(1, .8, 0)
	walk.MOVEBACKWARD.KeyBind:SetTextColor(1, .8, 0)

	local singleKey = _G.TutorialSingleKey_Frame.ContainerFrame
	singleKey.KeyBind.KeyBind:SetTextColor(1, .8, 0)
end

function S:Blizzard_NewPlayerExperienceGuide()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guide) then return end

	local frame = _G.GuideFrame
	S:HandlePortraitFrame(frame)
	frame.Title:SetTextColor(1, 1, 1)

	local scrollFrame = frame.ScrollFrame
	S:HandleTrimScrollBar(scrollFrame.ScrollBar)
	S:HandleButton(scrollFrame.ConfirmationButton)

	local scrollChild = scrollFrame.Child
	scrollChild.ObjectivesFrame:StripTextures()
	scrollChild.ObjectivesFrame:SetTemplate('Transparent')
	scrollChild.Text:SetTextColor(1, 1, 1)
end

S:AddCallbackForAddon('Blizzard_NewPlayerExperience')
S:AddCallbackForAddon('Blizzard_NewPlayerExperienceGuide')
