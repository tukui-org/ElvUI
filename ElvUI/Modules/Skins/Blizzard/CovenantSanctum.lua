local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

-- 9.0 SHADOWLANDS

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

function S:Blizzard_CovenantSanctum()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.covenantSanctum) then return end

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

			local TalentList = frame.UpgradesTab.TalentsList
			TalentList.Divider:SetAlpha(0)
			TalentList.BackgroundTile:SetAlpha(0)
			TalentList:CreateBackdrop('Transparent')
			S:HandleButton(TalentList.UpgradeButton)

			S:HandleCloseButton(_G.CovenantSanctumFrame.CloseButton)

			hooksecurefunc(TalentList, "Refresh", ReskinTalents)
		end
	end)

	S:HandleTab(_G.CovenantSanctumFrameTab1)
	S:HandleTab(_G.CovenantSanctumFrameTab2)
	_G.CovenantSanctumFrameTab1:ClearAllPoints()
	_G.CovenantSanctumFrameTab1:SetPoint('BOTTOMLEFT', frame, 23, -32) --default is: 23, 9
end

S:AddCallbackForAddon('Blizzard_CovenantSanctum')
