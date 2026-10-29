local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_AlliedRacesUI', nil, nil, nil, nil, nil, 'alliedRaces')

local function AlliedRaces_OnShow(frame)
	for button in frame.abilityPool:EnumerateActive() do
		local _, _, region3 = button:GetRegions()
		region3:Hide()

		S:HandleIcon(button.Icon, true)

		if E.private.skins.parchmentRemoverEnable then
			button.Text:SetTextColor(1, 1, 1)
		end
	end
end

function S:Blizzard_AlliedRacesUI()
	local AlliedRacesFrame = _G.AlliedRacesFrame
	local AlliedScrollFrame = AlliedRacesFrame.RaceInfoFrame.ScrollFrame

	if E.private.skins.parchmentRemoverEnable then
		S:HandlePortraitFrame(AlliedRacesFrame)

		local _, region2 = AlliedRacesFrame.ModelScene:GetRegions()
		region2:Hide()

		AlliedScrollFrame.Child.ObjectivesFrame:StripTextures()
		AlliedScrollFrame.Child.ObjectivesFrame:SetTemplate('Transparent')

		AlliedRacesFrame.RaceInfoFrame.AlliedRacesRaceName:SetTextColor(1, .8, 0)
		AlliedScrollFrame.Child.RaceDescriptionText:SetTextColor(1, 1, 1)
		AlliedScrollFrame.Child.RacialTraitsLabel:SetTextColor(1, .8, 0)
	else
		AlliedRacesFrame.NineSlice:SetAlpha(0)
		_G.AlliedRacesFramePortrait:SetAlpha(0)
		_G.AlliedRacesFrameBg:SetAlpha(0)
		AlliedRacesFrame.ModelScene:StripTextures()
		AlliedRacesFrame:SetTemplate('Transparent')

		S:HandleCloseButton(_G.AlliedRacesFrameCloseButton)
	end

	S:HandleTrimScrollBar(AlliedScrollFrame.ScrollBar)
	S:HandleModelSceneControlButtons(AlliedRacesFrame.ModelScene.ControlFrame)

	AlliedRacesFrame:HookScript('OnShow', AlliedRaces_OnShow)
end
