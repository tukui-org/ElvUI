local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local select = select

function S:Blizzard_AlliedRacesUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.alliedRaces) then return end

	local AlliedRacesFrame = _G.AlliedRacesFrame
	if E.private.skins.parchmentRemoverEnable then
		S:HandlePortraitFrame(AlliedRacesFrame)
		select(2, AlliedRacesFrame.ModelFrame:GetRegions()):Hide()

		local scrollFrame = AlliedRacesFrame.RaceInfoFrame.ScrollFrame
		scrollFrame.ScrollBar.Border:Hide()
		scrollFrame.ScrollBar.ScrollUpBorder:Hide()
		scrollFrame.ScrollBar.ScrollDownBorder:Hide()
		S:HandleScrollBar(scrollFrame.ScrollBar)

		scrollFrame.Child.ObjectivesFrame:StripTextures()
		scrollFrame.Child.ObjectivesFrame:SetTemplate('Transparent')

		AlliedRacesFrame.RaceInfoFrame.AlliedRacesRaceName:SetTextColor(1, .8, 0)
		scrollFrame.Child.RaceDescriptionText:SetTextColor(1, 1, 1)
		scrollFrame.Child.RacialTraitsLabel:SetTextColor(1, .8, 0)
	else
		AlliedRacesFrame.NineSlice:SetAlpha(0)
		_G.AlliedRacesFramePortrait:SetAlpha(0)
		_G.AlliedRacesFrameBg:SetAlpha(0)
		AlliedRacesFrame.TitleBg:SetAlpha(0)
		AlliedRacesFrame.ModelFrame:StripTextures()
		AlliedRacesFrame:SetTemplate('Transparent')

		local scrollFrame = AlliedRacesFrame.RaceInfoFrame.ScrollFrame
		scrollFrame.ScrollBar.Border:Hide()
		scrollFrame.ScrollBar.ScrollUpBorder:Hide()
		scrollFrame.ScrollBar.ScrollDownBorder:Hide()
		S:HandleScrollBar(scrollFrame.ScrollBar)

		S:HandleCloseButton(_G.AlliedRacesFrameCloseButton)
	end

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
