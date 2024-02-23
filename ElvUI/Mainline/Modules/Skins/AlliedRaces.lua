local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local select = select

function S:Blizzard_AlliedRacesUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.alliedRaces) then return end

	local AlliedRacesFrame = _G.AlliedRacesFrame
	local AlliedScrollFrame = AlliedRacesFrame.RaceInfoFrame.ScrollFrame

	if E.private.skins.parchmentRemoverEnable then
		S:HandlePortraitFrame(AlliedRacesFrame)
		select(2, AlliedRacesFrame.ModelScene:GetRegions()):Hide()

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

	AlliedRacesFrame:HookScript('OnShow', function(s)
		for button in s.abilityPool:EnumerateActive() do
			select(3, button:GetRegions()):Hide()
			S:HandleIcon(button.Icon, true)

			if E.private.skins.parchmentRemoverEnable then
				button.Text:SetTextColor(1, 1, 1)
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_AlliedRacesUI')
