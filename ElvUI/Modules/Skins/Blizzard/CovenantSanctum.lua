local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

-- SHADOWLANDS

local function ReskinTalents(self)
	for frame in self.talentPool:EnumerateActive() do
		if not frame.IsSkinned then
			frame.Border:SetAlpha(0)
			frame.Background:SetAlpha(0)

			frame:CreateBackdrop('Transparent')
			frame.backdrop:SetInside()

			frame.Highlight:SetColorTexture(1, 1, 1, .25)
			frame.Highlight:SetInside(frame.backdrop)
			S:HandleIcon(frame.Icon, true)
			frame.Icon:SetPoint("TOPLEFT", 7, -7)

			frame.IsSkinned = true
		end
	end
end

local function ReskinUpgrades(frame)
	if not frame then return end

	if not frame.IsSkinned then
		if frame.Border then frame.Border:SetAlpha(0) end
		if frame.RankBorder then frame.RankBorder:SetAlpha(0) end
		if frame.CircleMask then frame.CircleMask:Kill() end

		if frame.Icon then
			S:HandleIcon(frame.Icon, true)
		end

		-- 9.0 Shadowlands -- HALP!!
		-- TO DO: Make the highlight and selected texture pretty
		--frame.HighlightTexture:SetOutside(frame.Icon)
		--frame.SelectedTexture:SetOutside(frame.Icon)

		frame.IsSkinned = true
	end
end

function S:Blizzard_CovenantSanctum()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.CovenantSanctum) then return end

	local frame = _G.CovenantSanctumFrame

	frame:HookScript('OnShow', function()
		if not frame.backdrop then
			frame:CreateBackdrop('Transparent')
			frame.NineSlice:SetAlpha(0)

			frame.LevelFrame.Background:SetAlpha(0)
			frame.LevelFrame.Level:FontTemplate()

			local UpgradesTab = frame.UpgradesTab
			UpgradesTab.Background:SetAlpha(0)
			UpgradesTab.Background:CreateBackdrop('Transparent')
			S:HandleButton(UpgradesTab.DepositButton)

			ReskinUpgrades(UpgradesTab.TravelUpgrade)
			ReskinUpgrades(UpgradesTab.DiversionUpgrade)
			ReskinUpgrades(UpgradesTab.AdventureUpgrade)
			ReskinUpgrades(UpgradesTab.UniqueUpgrade)
			--ReskinUpgrades(UpgradesTab.ReservoirUpgrade) -- maybe not cool to skin :thinking:

			local TalentList = frame.UpgradesTab.TalentsList
			TalentList.Divider:SetAlpha(0)
			TalentList.BackgroundTile:SetAlpha(0)
			TalentList:CreateBackdrop('Transparent')
			S:HandleButton(TalentList.UpgradeButton)

			hooksecurefunc(TalentList, "Refresh", ReskinTalents)
		end
	end)

	S:HandleCloseButton(_G.CovenantSanctumFrameCloseButton)
	S:HandleTab(_G.CovenantSanctumFrameTab1)
	S:HandleTab(_G.CovenantSanctumFrameTab2)
	_G.CovenantSanctumFrameTab1:ClearAllPoints()
	_G.CovenantSanctumFrameTab1:Point('BOTTOMLEFT', frame, 23, -32) --default is: 23, 9
end

S:AddCallbackForAddon('Blizzard_CovenantSanctum')
