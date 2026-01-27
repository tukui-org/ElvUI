local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_NewPlayerExperience()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guide) then return end

	S:HandleButton(_G.KeyboardMouseConfirmButton)

	local frame = _G.NPE_TutorialWalk_Frame
	local container = frame and frame.ContainerFrame
	if container then
		container.TURNLEFT.KeyBind:SetTextColor(1, .8, 0)
		container.TURNRIGHT.KeyBind:SetTextColor(1, .8, 0)
		container.MOVEFORWARD.KeyBind:SetTextColor(1, .8, 0)
		container.MOVEBACKWARD.KeyBind:SetTextColor(1, .8, 0)
	end

	local singleKey = _G.NPE_TutorialSingleKey_Frame
	local singleContainer = singleKey and singleKey.ContainerFrame
	if singleContainer and singleContainer.KeyBind then
		singleContainer.KeyBind.KeyBind:SetTextColor(1, .8, 0)
	end
end

function S:Blizzard_NewPlayerExperienceGuide()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guide) then return end

	local frame = _G.GuideFrame
	S:HandlePortraitFrame(frame)
	frame.Title:SetTextColor(1, 1, 1)

	local scrollFrame = frame.ScrollFrame
	S:HandleScrollBar(scrollFrame.ScrollBar)
	S:HandleButton(scrollFrame.ConfirmationButton)

	local scrollChild = scrollFrame.Child
	scrollChild.ObjectivesFrame:StripTextures()
	scrollChild.ObjectivesFrame:SetTemplate('Transparent')
	scrollChild.Text:SetTextColor(1, 1, 1)
end

S:AddCallbackForAddon('Blizzard_NewPlayerExperience')
S:AddCallbackForAddon('Blizzard_NewPlayerExperienceGuide')
