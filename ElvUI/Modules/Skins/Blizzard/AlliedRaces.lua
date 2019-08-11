local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local select = select

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AlliedRaces ~= true then return end

	local AlliedRacesFrame = _G.AlliedRacesFrame

	if E.private.skins.parchmentRemover.enable then
		S:HandlePortraitFrame(AlliedRacesFrame, true)
		select(2, AlliedRacesFrame.ModelFrame:GetRegions()):Hide()

		local scrollFrame = AlliedRacesFrame.RaceInfoFrame.ScrollFrame
		scrollFrame.ScrollBar.Border:Hide()
		scrollFrame.ScrollBar.ScrollUpBorder:Hide()
		scrollFrame.ScrollBar.ScrollDownBorder:Hide()
		S:HandleScrollBar(scrollFrame.ScrollBar)

		scrollFrame.Child.ObjectivesFrame:StripTextures()
		scrollFrame.Child.ObjectivesFrame:CreateBackdrop("Transparent")

		AlliedRacesFrame.RaceInfoFrame.AlliedRacesRaceName:SetTextColor(1, .8, 0)
		scrollFrame.Child.RaceDescriptionText:SetTextColor(1, 1, 1)
		scrollFrame.Child.RacialTraitsLabel:SetTextColor(1, .8, 0)
	else
		AlliedRacesFrame.NineSlice:SetAlpha(0)
		_G.AlliedRacesFramePortrait:SetAlpha(0)
		_G.AlliedRacesFrameBg:SetAlpha(0)
		AlliedRacesFrame.TitleBg:SetAlpha(0)
		AlliedRacesFrame.ModelFrame:StripTextures()

		AlliedRacesFrame:CreateBackdrop("Transparent")

		local scrollFrame = AlliedRacesFrame.RaceInfoFrame.ScrollFrame
		scrollFrame.ScrollBar.Border:Hide()
		scrollFrame.ScrollBar.ScrollUpBorder:Hide()
		scrollFrame.ScrollBar.ScrollDownBorder:Hide()
		S:HandleScrollBar(scrollFrame.ScrollBar)

		S:HandleCloseButton(_G.AlliedRacesFrameCloseButton)
	end

	AlliedRacesFrame:HookScript("OnShow", function(self)
		for button in self.abilityPool:EnumerateActive() do
			select(3, button:GetRegions()):Hide()
			S:HandleIcon(button.Icon, true)
			if E.private.skins.parchmentRemover.enable then
				button.Text:SetTextColor(1, 1, 1)
			end
		end
	end)
end

S:AddCallbackForAddon("Blizzard_AlliedRacesUI", "AlliedRaces", LoadSkin)
